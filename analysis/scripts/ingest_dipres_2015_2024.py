# analysis/scripts/ingest_dipres_2015_2024.py
from __future__ import annotations
from pathlib import Path
import re
import numpy as np
import pandas as pd

BOOK = Path("data/raw/Dipres/articles-372115_doc_xls.xlsx")   # 2015–2024
BASE = Path("data/processed/dipres_sp.parquet")               # 2009–2022
OUT  = BASE                                                   # sobrescribe

SHEETS = [
    ("CFEGCT",      "Pesos"),
    ("CFEGCT$24",   "Pesos22"),       # usamos $24 como “base” para compat.
    ("CFEGCT%PIB",  "PIB"),
    ("CFEGCT%GT",   "GT"),
]

YEARS = list(range(2015, 2025))  # 2015…2024
COFOG_7 = tuple(str(x) for x in [7] + list(range(701, 711)))

def sniff_block(raw: pd.DataFrame) -> tuple[int,int,int, list[int]]:
    """
    Encuentra:
      - fila donde está 'Partida'
      - col idx de código (A) y Partida
      - columnas con años (2015–2024) en esa fila
    """
    raw_str = raw.astype(str)
    hit = np.where(raw_str.apply(lambda s: s.str.contains(r"^Partida$", case=False, na=False)).values)
    if len(hit[0]) == 0:
        raise RuntimeError("No se encontró encabezado 'Partida'.")
    r = int(hit[0][0])
    c_part = int(hit[1][0])

    # el código suele estar 1 col a la izquierda; si no, buscamos en las 3 previas
    cand_code = [c_part-1, c_part-2, c_part-3]
    c_code = next((c for c in cand_code if c >= 0), None)
    if c_code is None:
        c_code = c_part

    # columnas con años en esa fila
    cols_years = []
    for j in range(c_part+1, raw.shape[1]):
        cell = str(raw.iloc[r, j])
        m = re.search(r"(20\d{2})", cell)
        if m and int(m.group(1)) in YEARS:
            cols_years.append(j)
    if not cols_years:
        # fallback: busca los años en la fila siguiente
        rr = r+1
        for j in range(c_part+1, raw.shape[1]):
            cell = str(raw.iloc[rr, j])
            m = re.search(r"(20\d{2})", cell)
            if m and int(m.group(1)) in YEARS:
                cols_years.append(j)
    if not cols_years:
        raise RuntimeError("No detecté columnas de año 2015–2024")

    return r, c_code, c_part, cols_years

def read_sheet(sheet: str, prefix: str) -> pd.DataFrame:
    raw = pd.read_excel(BOOK, sheet_name=sheet, engine="openpyxl", header=None)
    r, c_code, c_part, cols_years = sniff_block(raw)

    block = raw.iloc[r+1:, [c_code, c_part] + cols_years].copy()
    block.columns = ["A", "Partida"] + [f"{prefix}_{re.search(r'(20\\d{2})', str(raw.iloc[r, j]) or str(raw.iloc[r+1, j])).group(1)}" for j in cols_years]

    # limpieza
    block["A"] = block["A"].astype(str).str.extract(r"(\\d{1,3})", expand=False)
    block["A1"] = block["A"].str[:3]
    # filtro COFOG 7xx
    block = block[block["A"].isin(COFOG_7) | block["A1"].isin(COFOG_7)]
    return block

def melt_years(df: pd.DataFrame, prefix: str) -> pd.DataFrame:
    value_cols = [c for c in df.columns if re.search(rf"^{prefix}_(20\\d{{4}}|20\\d{{2}})$", c) or re.search(rf"^{prefix}_20\\d{{2}}$", c)]
    if not value_cols:
        value_cols = [c for c in df.columns if c.startswith(prefix+"_")]
    out = df.melt(id_vars=["A","A1","Partida"], value_vars=value_cols,
                  var_name="col", value_name=f"{prefix}_value")
    out["Year"] = out["col"].str.extract(r"(20\\d{2})").astype(int)
    out = out.drop(columns=["col"])
    return out

def main():
    blocks = []
    for sheet, pref in SHEETS:
        blk = read_sheet(sheet, pref)
        blk = melt_years(blk, pref)
        blocks.append(blk)

    add = blocks[0]
    for b in blocks[1:]:
        add = add.merge(b, on=["A","A1","Partida","Year"], how="outer")

    add = add[(add["Year"]>=2015) & (add["Year"]<=2024)].copy()

    base = pd.read_parquet(BASE) if BASE.exists() else pd.DataFrame()
    if not base.empty:
        keep_cols = ["A","A1","Partida","Year","Pesos22_value","PIB_value","GT_value"]
        for c in keep_cols:
            if c not in base.columns: base[c] = np.nan
        full = pd.concat([base[keep_cols], add[keep_cols]], ignore_index=True)
        full = full.drop_duplicates(subset=["A","A1","Partida","Year"], keep="last")
    else:
        full = add.rename(columns={})

    OUT.parent.mkdir(parents=True, exist_ok=True)
    full.to_parquet(OUT, index=False)
    print("✅ dipres_sp.parquet extendido. Rango:", int(full["Year"].min()), "–", int(full["Year"].max()))

if __name__ == "__main__":
    main()
