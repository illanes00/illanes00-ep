# analysis/scripts/ingest_cead.py
from pathlib import Path
import pandas as pd

RAW_DIR = Path("data/raw/CEAD")
OUT = Path("static/data"); OUT.mkdir(parents=True, exist_ok=True)

# elige el primer parquet/csv que encuentres
candidates = list(RAW_DIR.glob("*.parquet")) + list(RAW_DIR.glob("*.csv")) + list(RAW_DIR.glob("*.feather"))
if not candidates:
    raise SystemExit(f"No encontré archivos en {RAW_DIR}. Sube un parquet/csv allí.")

path = sorted(candidates)[0]
if path.suffix == ".parquet":
    df = pd.read_parquet(path)
elif path.suffix == ".feather":
    import pyarrow.feather as ft
    df = ft.read_feather(path)
else:
    df = pd.read_csv(path)

# autodetección de columnas
year_col = next((c for c in df.columns if str(c).strip().lower() in {"year","año","anio","ano","anio_mes","ano_mes"}), None)
if not year_col:
    # intenta detectar números de 4 dígitos en nombres tipo "periodo"/"fecha"
    year_col = next((c for c in df.columns if "año" in str(c).lower() or "anio" in str(c).lower() or "year" in str(c).lower()), None)
if not year_col:
    raise SystemExit("CEAD: no hallé columna de año (Year/Año/Anio/...). Mira las columnas y te digo cómo mapearlas.")

crime_col = next((c for c in df.columns if str(c).lower() in {"delito","tipo_delito","tipodelito","categoria","categoria_delito"}), None)

# forzar int si es posible
df = df.copy()
try:
    df[year_col] = pd.to_numeric(df[year_col], errors="coerce").astype("Int64")
except Exception:
    pass

# 1) total anual (conteo de filas o suma de una col "n"/"count" si existe)
count_col = next((c for c in df.columns if str(c).lower() in {"n","count","conteo","casos"}), None)
if count_col:
    tot = df.groupby(year_col, dropna=True)[count_col].sum().reset_index().rename(columns={year_col:"Year", count_col:"value"})
else:
    tot = df.groupby(year_col, dropna=True).size().reset_index(name="value").rename(columns={year_col:"Year"})

OUT.joinpath("viz_cead_total.json").write_text(tot.to_json(orient="records", force_ascii=False), encoding="utf-8")

# 2) top 10 por tipo de delito del último año (si existe columna delito)
if crime_col:
    last = int(tot["Year"].max())
    top = df.loc[df[year_col]==last, crime_col].value_counts().head(10).index.tolist()
    sub = df[df[crime_col].isin(top)]
    if count_col:
        grp = sub.groupby([year_col, crime_col])[count_col].sum().reset_index()
    else:
        grp = sub.groupby([year_col, crime_col]).size().reset_index(name="value")
    wide = grp.pivot_table(index=year_col, columns=crime_col, values="value", aggfunc="sum").reset_index().rename(columns={year_col:"Year"})
    OUT.joinpath("viz_cead_top.json").write_text(wide.to_json(orient="records", force_ascii=False), encoding="utf-8")

print("✅ CEAD listo:", OUT)
