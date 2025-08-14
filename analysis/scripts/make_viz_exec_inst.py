# analysis/scripts/make_viz_exec_inst.py
from pathlib import Path
import pandas as pd
OUT = Path("static/data"); OUT.mkdir(parents=True, exist_ok=True)

df = pd.read_parquet("data/processed/dipres_exec.parquet")
# Asegura columnas
need = ["year","Tipo","Gastos_2022","Gastos_PIB","Gastos_GT"]
df = df.rename(columns={"year":"Year"})
for c in ["Gastos_2022","Gastos_PIB","Gastos_GT"]:
    if c not in df.columns:
        raise SystemExit("Falta columna "+c+" en dipres_exec.parquet")

def wide(col, name):
    w = df.groupby(["Year","Tipo"], as_index=False)[col].sum()
    w = w.pivot_table(index="Year", columns="Tipo", values=col, aggfunc="sum").reset_index()
    OUT.joinpath(f"viz_sp_inst_{name}.json").write_text(w.to_json(orient="records", force_ascii=False), encoding="utf-8")

wide("Gastos_PIB",   "pct_pib")
# % del gasto en seguridad → normaliza por suma de esas instituciones (excluye otros tipos si los hubiera)
tot = df.groupby("Year")["Gastos_2022"].transform("sum")
part = df.copy()
part["pct_seguridad"] = part["Gastos_2022"] / tot * 100.0
w = part.groupby(["Year","Tipo"], as_index=False)["pct_seguridad"].sum().pivot_table(index="Year", columns="Tipo", values="pct_seguridad").reset_index()
OUT.joinpath("viz_sp_inst_pct_gt_sp.json").write_text(w.to_json(orient="records", force_ascii=False), encoding="utf-8")
wide("Gastos_2022", "pesos22")
print("✅ Instituciones listas →", OUT)
