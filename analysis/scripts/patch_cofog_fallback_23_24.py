from pathlib import Path
import pandas as pd, re

RAW = Path("data/raw/Dipres/Gasto Público")
OUT = Path("data/processed/dipres_sp.parquet")

def read_any(book):
    xl = pd.ExcelFile(book)
    # busca hoja con COFOG / Clasificación funcional
    cand = [s for s in xl.sheet_names if re.search(r'(?i)func|cofog|clasif', s)] or xl.sheet_names
    for sh in cand:
        # barrido de filas para encontrar encabezado con 'Partida'
        df0 = pd.read_excel(book, sheet_name=sh, header=None, nrows=50)
        row = None
        for r in range(len(df0)):
            vals = [str(v) for v in (df0.iloc[r].tolist())]
            if any(re.search(r'(?i)partida', v or '') for v in vals):
                row = r; break
        if row is None: continue
        df = pd.read_excel(book, sheet_name=sh, header=row)
        # normaliza columnas claves si existen
        cols = {c:c for c in df.columns}
        if "Partida" not in cols:
            alt = next((c for c in df.columns if re.search(r'(?i)partida', str(c))), None)
            if alt: df = df.rename(columns={alt:"Partida"})
        if "Año" in df.columns: df = df.rename(columns={"Año":"Year"})
        if "AÑO" in df.columns: df = df.rename(columns={"AÑO":"Year"})
        # intenta seleccionar sólo columnas que empiecen con codigos o métricas
        keep = [c for c in df.columns if re.search(r'(?i)partida|year|PIB|GT|Pesos', str(c))]
        if len(keep)>=3:
            return df[keep]
    raise SystemExit(f"No pude leer COFOG desde {book}")

def main():
    out = []
    for y in (2023, 2024):
        bk = RAW / f"Estado de Operaciones del gobierno {y}.xlsx"
        df = read_any(bk)
        df["Year"] = y
        out.append(df)
    new = pd.concat(out, ignore_index=True)
    # concatena con parquet existente si ya hay
    if OUT.exists():
        base = pd.read_parquet(OUT)
        # preferimos dropear Year duplicado de esos años
        base = base[~base["Year"].isin([2023, 2024])]
        all_ = pd.concat([base, new], ignore_index=True, sort=False)
    else:
        all_ = new
    all_.to_parquet(OUT, index=False)
    print("OK →", OUT)
if __name__ == "__main__":
    main()
