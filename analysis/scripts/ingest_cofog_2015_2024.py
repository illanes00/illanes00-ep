# analysis/scripts/ingest_cofog_2015_2024.py
from pathlib import Path
import pandas as pd

BOOK = Path("data/raw/Dipres/articles-372115_doc_xls.xlsx")
OUT  = Path("data/processed/dipres_sp.parquet")
SHEETS = [("CFEGCT","Pesos"), ("CFEGCT$24","Pesos24"), ("CFEGCT%PIB","PIB"), ("CFEGCT%GT","GT")]
YEARS = list(range(2015, 2025))
COFOG7 = set(["7"] + [str(x) for x in range(701, 711)])

def read_block(sheet, pref):
    d = pd.read_excel(BOOK, sheet_name=sheet, engine="openpyxl", header=None)
    # fila de años: primera fila con >=5 valores entre 2010 y 2030
    header_row = None
    year_cols  = []
    for i in range(min(20, d.shape[0])):
        cols = []
        for j in range(d.shape[1]):
            v = d.iat[i,j]
            if isinstance(v,(int,float)) and 2010 <= v <= 2030:
                cols.append(j)
        if len(cols) >= 5:
            header_row = i
            year_cols = cols
            break
    if header_row is None or not year_cols:
        raise SystemExit(f"No detecté fila de años en {sheet}")

    # datos comienzan 2 filas después (códigos + descripciones + años)
    start = header_row + 2
    block = d.iloc[start:, [0,1] + year_cols].copy()
    # nombres de columnas con prefijo + año
    newcols = ["A","Partida"]
    for j in year_cols:
        yval = int(d.iat[header_row, j])
        newcols.append(f"{pref}_{yval}")
    block.columns = newcols

    # normaliza códigos/descr
    block["A"] = block["A"].astype(str).str.extract(r"(\d+)", expand=False)
    block = block.dropna(subset=["A","Partida"])
    block["A1"] = block["A"].str[:3]
    # filtra COFOG 7xx (seguridad + contexto comparable)
    block = block[block["A"].isin(COFOG7) | block["A1"].isin(COFOG7)].copy()
    return block

def melt_years(df, pref):
    value_cols = [c for c in df.columns if c.startswith(f"{pref}_")]
    if not value_cols:
        return pd.DataFrame(columns=["A","A1","Partida","Year",f"{pref}_value"])
    m = df.melt(id_vars=["A","A1","Partida"], value_vars=value_cols,
                var_name="col", value_name=f"{pref}_value")
    m["Year"] = m["col"].str.extract(r"(20\d{2})").astype(int)
    m = m.drop(columns=["col"])
    m = m[m["Year"].between(min(YEARS), max(YEARS))]
    return m

def main():
    pieces = []
    for sheet, pref in SHEETS:
        blk = read_block(sheet, pref)
        pieces.append(melt_years(blk, pref))
    out = pieces[0]
    for p in pieces[1:]:
        out = out.merge(p, on=["A","A1","Partida","Year"], how="outer")

    # concatena con parquet existente (si hay) y reemplaza 2015–2024 por los nuevos
    if OUT.exists():
        base = pd.read_parquet(OUT)
        base = base[~base["Year"].between(2015, 2024)]
        all_ = pd.concat([base, out], ignore_index=True)
    else:
        all_ = out

    OUT.parent.mkdir(parents=True, exist_ok=True)
    all_.to_parquet(OUT, index=False)
    print("✅ dipres_sp.parquet →", OUT, "rango:", int(all_["Year"].min()), "–", int(all_["Year"].max()))

if __name__ == "__main__":
    main()
