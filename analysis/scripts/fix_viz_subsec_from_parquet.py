# analysis/scripts/fix_viz_subsec_from_parquet.py
from pathlib import Path
import pandas as pd
import re, json

SRC = Path("data/processed/dipres_sp.parquet")
OUT = Path("static/data"); OUT.mkdir(parents=True, exist_ok=True)

def label_703(a):
    a = str(a)
    if a.startswith("7031"): return "Servicios de policía"
    if a.startswith("7033"): return "Tribunales de justicia"
    if a.startswith("7034"): return "Prisiones"
    if a.startswith("703"):  return "Otro"
    return None

def main():
    df = pd.read_parquet(SRC)
    # nos quedamos con códigos y columnas relevantes
    # columnas esperadas: A (código), Partida (desc), Year, PIB (%, de CFEGCT%PIB), GT (%, de CFEGCT%GT), Pesos24 o Pesos
    for col in ["PIB","GT","Pesos24","Pesos"]:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors="coerce")

    sub = df[df["A"].astype(str).str.startswith("703")].copy()
    sub["Subsector"] = sub["A"].map(label_703)
    sub = sub.dropna(subset=["Subsector","Year"])

    # 3A) % del PIB (es directo: columna "PIB")
    pib = (sub.groupby(["Year","Subsector"], as_index=False)["PIB"].sum())
    pib_w = pib.pivot(index="Year", columns="Subsector", values="PIB").reset_index()
    (OUT/"viz_sp_subsec_pct_pib.json").write_text(pib_w.to_json(orient="records", force_ascii=False), encoding="utf-8")

    # 3B) % del gasto en Seguridad (normalizar dentro de 703* por año)
    gt = (sub.groupby(["Year","Subsector"], as_index=False)["GT"].sum())
    den = gt.groupby("Year", as_index=False)["GT"].sum().rename(columns={"GT":"GT_tot703"})
    gt = gt.merge(den, on="Year", how="left")
    gt["pct_gt_sp"] = gt["GT"] / gt["GT_tot703"] * 100.0
    gtw = gt.pivot(index="Year", columns="Subsector", values="pct_gt_sp").reset_index()
    (OUT/"viz_sp_subsec_pct_gt_sp.json").write_text(gtw.to_json(orient="records", force_ascii=False), encoding="utf-8")

    # 3C) Pesos (usamos Pesos24 si está, si no Pesos nominal)
    valcol = "Pesos24" if "Pesos24" in sub.columns else "Pesos"
    pes = (sub.groupby(["Year","Subsector"], as_index=False)[valcol].sum())
    pesw = pes.pivot(index="Year", columns="Subsector", values=valcol).reset_index()
    (OUT/"viz_sp_subsec_pesos22.json").write_text(pesw.to_json(orient="records", force_ascii=False), encoding="utf-8")

    print("✅ Subsectores regenerados en static/data (hasta 2024)")

if __name__ == "__main__":
    main()
