from __future__ import annotations
from pathlib import Path
import pandas as pd
import unicodedata as ud
OUT = Path("static/data"); OUT.mkdir(parents=True, exist_ok=True)
BASE = Path("data/processed/dipres_sp.parquet")

def norm(s:str)->str:
    s = (s or "").strip().lower()
    s = "".join(c for c in ud.normalize("NFKD", s) if not ud.combining(c))
    return s

SUB_MAP = {
    "servicios de policia":"Servicios de policía",
    "tribunales de justicia":"Tribunales de justicia",
    "prisiones":"Prisiones",
    "servicios de proteccion contra incendios":"Otro",
    "orden publico y seguridad n.e.p.":"Otro",
    "orden publico y seguridad nep":"Otro",
}

def main():
    df = pd.read_parquet(BASE)
    df = df[df["Partida"].notna()].copy()
    df["partida_n"] = df["Partida"].map(norm)
    # quedarnos sólo con subfunciones de Seguridad Pública
    keys = list(SUB_MAP.keys())
    sub = df[df["partida_n"].isin(keys)].copy()
    sub["categoria"] = sub["partida_n"].map(SUB_MAP)

    # %PIB
    pib = sub.groupby(["Year","categoria"], as_index=False)["PIB_value"].sum()
    (OUT/"viz_sp_subsec_pct_pib.json").write_text(pib.pivot_table(index="Year", columns="categoria", values="PIB_value").reset_index().to_json(orient="records", force_ascii=False), encoding="utf-8")

    # Pesos 2022
    pesos = sub.groupby(["Year","categoria"], as_index=False)["Pesos22_value"].sum()
    (OUT/"viz_sp_subsec_pesos22.json").write_text(pesos.pivot_table(index="Year", columns="categoria", values="Pesos22_value").reset_index().to_json(orient="records", force_ascii=False), encoding="utf-8")

    # % del gasto en Seguridad (share dentro del total SP por año)
    tot_sp = pesos.groupby("Year")["Pesos22_value"].transform("sum")
    pesos["pct_gasto_seg"] = pesos["Pesos22_value"] / tot_sp * 100
    (OUT/"viz_sp_subsec_pct_gt_sp.json").write_text(pesos.pivot_table(index="Year", columns="categoria", values="pct_gasto_seg").reset_index().to_json(orient="records", force_ascii=False), encoding="utf-8")

    print("✅ Subsectores listos →", OUT)

if __name__ == "__main__":
    main()
