# -*- coding: utf-8 -*-
from __future__ import annotations
import unicodedata as ud
from pathlib import Path
import pandas as pd
import numpy as np

BASE = Path("data/processed/dipres_sp.parquet")
OUT = Path("data/processed"); OUT.mkdir(parents=True, exist_ok=True)

# pediste hasta 2024; si faltan años en el parquet, simplemente no aparecen
YEARS = list(range(2013, 2025))

def deacc(s:str)->str:
    return "".join(c for c in ud.normalize("NFKD", s) if not ud.combining(c))
def norm(s:str)->str:
    s = deacc(s or "").lower().strip()
    return " ".join(s.split())

MAP_FUNC = {
    "orden y seguridad publica":"Seguridad Pública","seguridad publica":"Seguridad Pública","orden publico y seguridad":"Seguridad Pública",
    "servicios publicos generales":"Servicios Públicos","defensa":"Defensa",
    "vivienda":"Vivienda","vivienda y servicios comunitarios":"Vivienda",
    "cultura":"Cultura","recreacion cultura y religion":"Cultura",
    "salud":"Salud","educacion":"Educación","asuntos economicos":"Asuntos Económicos",
    "proteccion social":"Protección Social",
    "medio ambiente":"Medioambiente","proteccion del medio ambiente":"Medioambiente",
}
FUNC_ORDER = ["Seguridad Pública","Servicios Públicos","Defensa","Vivienda","Cultura",
              "Salud","Educación","Protección Social","Asuntos Económicos","Medioambiente"]

MAP_SUB = {
    "701":"Servicios de policía",
    "702":"Tribunales de justicia",
    "703":"Prisiones",
    "704":"Otro","705":"Otro","706":"Otro","707":"Otro","708":"Otro","709":"Otro","710":"Otro",
    "servicios de policia":"Servicios de policía",
    "tribunales de justicia":"Tribunales de justicia",
    "prisiones":"Prisiones",
    "otros":"Otro","otros servicios":"Otro","otros servicios de orden y seguridad publica":"Otro"
}

def wide(df_long, col_name, cols_keep=("Year",)):
    w = df_long.pivot_table(index=list(cols_keep), columns="categoria", values=col_name, aggfunc="first")
    w = w.reset_index()
    cols_keep_present = [c for c in cols_keep if c in w.columns]
    series_cols = [c for c in w.columns if c not in cols_keep_present]
    ordered = [c for c in FUNC_ORDER if c in series_cols] + [c for c in series_cols if c not in FUNC_ORDER]
    return w[cols_keep_present + ordered]

def main():
    df = pd.read_parquet(BASE)

    if "year" in df.columns and "Year" not in df.columns:
        df = df.rename(columns={"year":"Year"})

    df["Partida_norm"] = df["Partida"].map(lambda x: MAP_FUNC.get(norm(str(x)), str(x)))
    df["categoria"]    = df["Partida_norm"]
    df["Subsector_norm"] = df["A1"].map(lambda x: MAP_SUB.get(norm(str(x)), str(x) if pd.notna(x) else None)) if "A1" in df.columns else None

    df = df[df["Year"].isin(YEARS)].copy()

    need = {"Year","categoria","PIB_value","GT_value","Pesos22_value","Partida_norm"}
    miss = [c for c in need if c not in df.columns]
    if miss:
        raise SystemExit(f"Faltan columnas en {BASE}: {miss}")

    # 1) % PIB (incluye PS) + SP+
    pib_long = df.groupby(["Year","categoria"], as_index=False)["PIB_value"].sum()
    pib_wide = wide(pib_long, "PIB_value")
    if "Seguridad Pública" in pib_wide.columns:
        pib_wide["Seguridad Pública +"] = pib_wide["Seguridad Pública"] + 0.49
    else:
        pib_wide["Seguridad Pública +"] = np.nan
    pib_wide.to_parquet(OUT/"viz_sp_pct_pib_incl_ps.parquet", index=False)

    # 2) % PIB (excluye PS en la visualización)
    pib_ex = pib_wide.drop(columns=[c for c in pib_wide.columns if c=="Protección Social"], errors="ignore")
    pib_ex.to_parquet(OUT/"viz_sp_pct_pib_excl_ps.parquet", index=False)

    # 3) % del Gasto Total (incluye PS) + SP+ con Δ basado en PIB 2022
    gt_long = df.groupby(["Year","categoria"], as_index=False)["GT_value"].sum()
    gt_wide = wide(gt_long, "GT_value")
    pesos_wide_all = wide(df.groupby(["Year","categoria"], as_index=False)["Pesos22_value"].sum(), "Pesos22_value")
    try:
        sp_2022_pesos = float(pesos_wide_all.loc[pesos_wide_all["Year"]==2022, "Seguridad Pública"].iloc[0])
        sp_2022_pctPIB = float(pib_wide.loc[pib_wide["Year"]==2022, "Seguridad Pública"].iloc[0])
        pib_2022_pesos = sp_2022_pesos / (sp_2022_pctPIB/100.0)
        delta = 0.0049 * pib_2022_pesos
    except Exception:
        delta = 0.0  # si falta 2022 o la categoría, seguimos sin SP+
    gt_plus = []
    for _, row in pesos_wide_all.iterrows():
        total = float(row.drop(labels=["Year"]).sum(skipna=True))
        sp = float(row.get("Seguridad Pública", np.nan))
        gt_plus.append(np.nan if np.isnan(sp) or total<=0 else (sp+delta)/(total+delta)*100.0)
    gt_wide["Seguridad Pública +"] = gt_plus
    gt_wide.to_parquet(OUT/"viz_sp_pct_gt_incl_ps.parquet", index=False)

    # 4) % del Gasto Total excluyendo PS (reescala denominador) + SP+
    gt_ex = gt_wide.copy()
    if "Protección Social" in gt_ex.columns:
        den = 100.0 - gt_ex["Protección Social"]
        for c in [col for col in gt_ex.columns if col not in ("Year","Protección Social")]:
            gt_ex[c] = gt_ex[c] / den * 100.0
        gt_ex = gt_ex.drop(columns=["Protección Social"])
    gt_ex.to_parquet(OUT/"viz_sp_pct_gt_excl_ps.parquet", index=False)

    # 5) Pesos 2022 por función (excluye PS) + SP+ (constante Δ)
    pesos_wide = pesos_wide_all.drop(columns=["Protección Social"], errors="ignore").copy()
    if delta>0 and "Seguridad Pública" in pesos_wide.columns:
        pesos_wide["Seguridad Pública +"] = pesos_wide["Seguridad Pública"] + delta
    else:
        pesos_wide["Seguridad Pública +"] = np.nan
    pesos_wide.to_parquet(OUT/"viz_sp_pesos22_excl_ps.parquet", index=False)

    # 6) Subsectores Seguridad: % PIB
    sp_sub = df[df["Partida_norm"]=="Seguridad Pública"].copy()
    sp_sub = sp_sub[pd.notna(sp_sub["Subsector_norm"])]
    sub_pib = sp_sub.groupby(["Year","Subsector_norm"], as_index=False)["PIB_value"].sum()
    sub_pib = sub_pib.rename(columns={"Subsector_norm":"categoria"})
    wide(sub_pib, "PIB_value").to_parquet(OUT/"viz_sp_subsec_pct_pib.parquet", index=False)

    # 7) Subsectores: % del gasto en Seguridad
    sub_pesos = sp_sub.groupby(["Year","Subsector_norm"], as_index=False)["Pesos22_value"].sum()
    tot_sp = sub_pesos.groupby("Year")["Pesos22_value"].transform("sum")
    sub_pesos["pct_gasto_seguridad"] = sub_pesos["Pesos22_value"] / tot_sp * 100.0
    sub_pesos = sub_pesos.rename(columns={"Subsector_norm":"categoria"})
    wide(sub_pesos[["Year","categoria","pct_gasto_seguridad"]], "pct_gasto_seguridad")\
        .to_parquet(OUT/"viz_sp_subsec_pct_gt_sp.parquet", index=False)

    # 8) Subsectores: pesos 2022
    wide(sub_pesos.rename(columns={"pct_gasto_seguridad":"_drop"}), "Pesos22_value")\
        .to_parquet(OUT/"viz_sp_subsec_pesos22.parquet", index=False)

    print("✅ Datasets para el visualizador listos en:", OUT)

if __name__ == "__main__":
    main()
