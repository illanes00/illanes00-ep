#!/usr/bin/env python3
"""
ETL ▸ INE population projections 2016-2022
------------------------------------------
Lee el CSV original, deja 2016-2022, fusiona la Región XVI en la VIII
y guarda un parquet listo para mergear con cualquier dataset regional.

Ejecución:
    PYTHONPATH=. python analysis/scripts/clean_ine_projections.py
"""

import sys
from pathlib import Path

# Aseguramos que el paquete `analysis` esté en PYTHONPATH
sys.path.append(str(Path(__file__).resolve().parents[2]))

import pandas as pd
from analysis.metadata import METADATA

# Configuración desde metadata.py
CFG = METADATA["ine_projections"]
RAW_CSV = CFG["sources"]["raw_csv"]
OUT_PATH = CFG["processed_path"]

def main() -> None:
    # 1) Leer CSV
    df = pd.read_csv(RAW_CSV)

    # 2) Renombrar "Region" (u variantes) ➔ "region"
    #    detecta cualquier columna cuyo nombre lowercase sea 'region'
    rename_map = {col: "region" for col in df.columns if col.lower() == "region"}
    if not rename_map:
        raise KeyError(
            f"No encontré ninguna columna 'Region' en {RAW_CSV.name}. "
            f"Cabeceras: {df.columns.tolist()!r}"
        )
    df = df.rename(columns=rename_map)

    # 3) Agrupar por región sumando todas las columnas aYYYY que existan
    all_year_cols = [f"a{y}" for y in range(2002, 2036)]
    year_cols = [c for c in all_year_cols if c in df.columns]

    df = df.groupby("region", as_index=False)[year_cols].sum()

    # 4) Quedarnos con 2016-2022
    keep_cols = ["region"] + [f"a{y}" for y in range(2016, 2023) if f"a{y}" in df.columns]
    df = df[keep_cols]

    # 5) Wide → long
    df = df.melt(
        id_vars="region",
        var_name="year",
        value_name="poblacion",
    )
    df["year"] = df["year"].str.lstrip("a").astype(int)

    # 6) Fusionar Ñuble (region==16) en Biobío (8)
    if (df["region"] == 16).any():
        aux = df[df["region"] == 16].copy()
        aux["region"] = 8
        df = pd.concat([df, aux], ignore_index=True)
    df = df[df["region"] != 16]

    # 7) Ordenar y resetear índice
    df = df.sort_values(["region", "year"]).reset_index(drop=True)

    # 8) Guardar parquet
    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    df.to_parquet(OUT_PATH, index=False)
    print(f"✅ Guardado {OUT_PATH.relative_to(Path.cwd())} ({len(df):,} filas)")

if __name__ == "__main__":
    main()
