# analysis/scripts/patch_cofog_2023_2024.py
from pathlib import Path
import re
import numpy as np
import pandas as pd

BOOK = Path("data/raw/Dipres/articles-372115_doc_xls.xlsx")
BASE = Path("data/processed/dipres_sp.parquet")
OUT  = BASE
SHEETS = [("CFEGCT", "Pesos"), ("CFEGCT$24","Pesos22"), ("CFEGCT%PIB","PIB"), ("CFEGCT%GT","GT")]
YEARS = list(range(2015, 2025))
COFOG7 = set([ '7' ] + [ str(x) for x in range(701,711) ])

def sniff(raw):
    s = raw.astype(str)
    pos = np.where(s.eq("Partida").values)
    if len(pos[0])==0:
        raise RuntimeError("No encontré encabezado 'Partida'")
    r, c_part = int(pos[0][0]), int(pos[1][0])
    c_code = max(0, c_part-1)
    cols = []
    for j in range(c_part+1, raw.shape[1]):
        for rr in (r, r+1, r+2):
            if rr < raw.shape[0]:
                m = re.search(r"(20\d{2})", str(raw.iat[rr,j]))
                if m and int(m.group(1)) in YEARS:
                    cols.append(j); break
    if not cols:
        raise RuntimeError("No detecté columnas de años")
    return r, c_code, c_part, sorted(set(cols))

def read_sheet(name, pref):
    raw = pd.read_excel(BOOK, sheet_name=name, engine="openpyxl", header=None)
    r, c_code, c_part, cols = sniff(raw)
    # nombres de año
    labels=[]
    for j in cols:
        cell = str(raw.iat[r,j]) or str(raw.iat[r+1,j])
        y = re.search(r"(20\d{2})", cell).group(1)
        labels.append(f"{pref}_{y}")
    block = raw.iloc[r+1:, [c_code, c_part]+cols].copy()
    block.columns = ["A","Partida"] + labels
    block["A"] = block["A"].astype(str).str.extract(r"(\d{1,3})", expand=False)
    block["A1"] = block["A"].str[:3]
    block = block[block["A"].isin(COFOG7) | block["A1"].isin(COFOG7)]
    return block

def melt(df, pref):
    vcols = [c for c in df.columns if c.startswith(pref+"_")]
    out = df.melt(id_vars=["A","A1","Partida"], value_vars=vcols, var_name="k", value_name=pref)
    out["Year"] = out["k"].str.extract(r"(20\d{2})").astype(int)
    out = out.drop(columns=["k"])
    return out

def main():
    if not BOOK.exists():
        raise SystemExit(f"No existe {BOOK}")
    parts=[]
    for sh,pref in SHEETS:
        b = read_sheet(sh, pref)
        parts.append(melt(b, pref))
    add = parts[0]
    for b in parts[1:]:
        add = add.merge(b, on=["A","A1","Partida","Year"], how="outer")
    add = add[(add["Year"]>=2015) & (add["Year"]<=2024)].copy()

    base = pd.read_parquet(BASE) if BASE.exists() else pd.DataFrame()
    if not base.empty:
        keep = ["A","A1","Partida","Year","Pesos22","PIB","GT"]
        # normaliza nombres en base (algunos scripts guardan Pesos22_value, etc.)
        base = base.rename(columns={c:f"{c.split('_')[0]}" for c in base.columns})
        for c in keep:
            if c not in base.columns: base[c]=np.nan
        full = pd.concat([base[keep], add[keep]], ignore_index=True).drop_duplicates(["A","A1","Partida","Year"], keep="last")
    else:
        full = add

    OUT.parent.mkdir(parents=True, exist_ok=True)
    full.to_parquet(OUT, index=False)
    print("✅ dipres_sp.parquet:", int(full["Year"].min()), "–", int(full["Year"].max()))
    # hint para subsectores: A1 únicos
    print("A1 únicos:", sorted(set(full["A1"].dropna().astype(str))))
if __name__=="__main__":
    main()
