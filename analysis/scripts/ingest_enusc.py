# analysis/scripts/ingest_enusc.py (mínimo)
from pathlib import Path
import pandas as pd
INP = Path("data/processed/enusc_trends_08_21.parquet")
OUT = Path("static/data"); OUT.mkdir(parents=True, exist_ok=True)

df = pd.read_parquet(INP)
canno = next((c for c in ["Year","Año","anio"] if c in df.columns), None)
cval  = next((c for c in ["victimizacion","Victimizacion","victim_total","victimizacion_total"] if c in df.columns), None)
if not (canno and cval): raise SystemExit("ENUSC: faltan columnas")
df = df.rename(columns={canno:"Year", cval:"value"})[["Year","value"]].sort_values("Year")
OUT.joinpath("viz_enusc_victim.json").write_text(df.to_json(orient="records", force_ascii=False), encoding="utf-8")
print("✅ ENUSC listo")
