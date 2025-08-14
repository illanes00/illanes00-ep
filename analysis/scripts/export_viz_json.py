from pathlib import Path
import pandas as pd

IN = Path("data/processed")
OUT = Path("static/data"); OUT.mkdir(parents=True, exist_ok=True)

FILES = [
    "viz_sp_pct_pib_incl_ps.parquet",
    "viz_sp_pct_pib_excl_ps.parquet",
    "viz_sp_pct_gt_incl_ps.parquet",
    "viz_sp_pct_gt_excl_ps.parquet",
    "viz_sp_pesos22_excl_ps.parquet",
    "viz_sp_subsec_pct_pib.parquet",
    "viz_sp_subsec_pct_gt_sp.parquet",
    "viz_sp_subsec_pesos22.parquet",
]

for f in FILES:
    p = IN / f
    if not p.exists():
        print("⚠️ falta", p); continue
    df = pd.read_parquet(p)
    if "Year" in df.columns:
        df = df.sort_values("Year")
    out = OUT / f.replace(".parquet", ".json")
    # ✅ esto convierte NaN → null y respeta UTF-8
    out.write_text(df.to_json(orient="records", force_ascii=False), encoding="utf-8")
    print("→", out)

print("✅ Listo. Archivos estáticos en", OUT)
