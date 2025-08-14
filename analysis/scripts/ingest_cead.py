from pathlib import Path
import pandas as pd

INP = Path("data/raw/CEAD/cead_delincuencia_chile.parquet")
OUT = Path("static/data"); OUT.mkdir(parents=True, exist_ok=True)

df = pd.read_parquet(INP)

# Derivar Year desde 'fecha' y normalizar nombres
if "fecha" in df.columns:
    df["Year"] = pd.to_datetime(df["fecha"], errors="coerce").dt.year
else:
    # fallback: busca algo tipo 'anio'/'año'
    for c in ("Year","Año","ANIO","anio","ano"):
        if c in df.columns:
            df = df.rename(columns={c:"Year"})
            break
    if "Year" not in df.columns:
        raise SystemExit("No hallé columna de año (ni 'fecha' para derivar).")

if "delito" in df.columns:
    df = df.rename(columns={"delito":"Delito"})
elif "Delito" not in df.columns:
    # crea una categoría genérica si no hay detalle
    df["Delito"] = "Total"

# La métrica es 'delito_n' si existe; sino contamos filas
value_col = "delito_n" if "delito_n" in df.columns else None

# 1) total anual
if value_col:
    tot = df.groupby("Year", as_index=False)[value_col].sum().rename(columns={value_col:"value"})
else:
    tot = df.groupby("Year", as_index=False).size().rename(columns={"size":"value"})
OUT.joinpath("viz_cead_total.json").write_text(
    tot.to_json(orient="records", force_ascii=False), encoding="utf-8")

# 2) top 10 delitos del último año (ancho por columnas)
last = int(tot["Year"].max())
if "Delito" in df.columns:
    if value_col:
        sub = (df[df["Year"]==last]
               .groupby("Delito", as_index=False)[value_col].sum()
               .sort_values(value_col, ascending=False).head(10))
        top = sub["Delito"].tolist()
        wide = (df[df["Delito"].isin(top)]
                .groupby(["Year","Delito"], as_index=False)[value_col].sum()
                .pivot(index="Year", columns="Delito", values=value_col)
                .reset_index().sort_values("Year"))
    else:
        # sin valor explícito, usar conteos
        sub = (df[df["Year"]==last]
               .groupby("Delito", as_index=False).size()
               .sort_values("size", ascending=False).head(10))
        top = sub["Delito"].tolist()
        wide = (df[df["Delito"].isin(top)]
                .groupby(["Year","Delito"], as_index=False).size()
                .pivot(index="Year", columns="Delito", values="size")
                .reset_index().sort_values("Year"))
    OUT.joinpath("viz_cead_top.json").write_text(
        wide.to_json(orient="records", force_ascii=False), encoding="utf-8")

print("✅ CEAD listo →", OUT)
