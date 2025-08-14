"""
Convierte los .sav ENUSC 2016-2021 en un parquet limpio y homogéneo.

Uso:
$ poetry run python analysis/scripts/clean_enusc_16_21.py
ó
$ source venv/bin/activate && python analysis/scripts/clean_enusc_16_21.py
"""

import pandas as pd
import pyreadstat
from pathlib import Path
from typing import Dict, Any, List

from analysis.metadata import METADATA   # asegúrate de que PYTHONPATH incluya /ep-seguridad

CFG: Dict[str, Any] = METADATA["enusc_16_21"]
SRC: Dict[int, Path] = CFG["sources"]
KEEP_VARS: List[str] = CFG["keep_vars"]
OUT_PATH: Path = CFG["processed_path"]


# ------------------------------------------------------------
# Utilidades de mapeo / normalización
# ------------------------------------------------------------
def binarize(series: pd.Series) -> pd.Series:
    """Convierte 1→1, 2→0, todo lo demás -> NaN."""
    return series.map({1: 1, 2: 0}).astype("Int64")


CRIME_RENAME_1619 = {    # mapping de 2016-2019
    "A13_1_1": "denuncio_violencia",
    "A14_1_1": "como_denuncio_violencia",
    "A18_1_1": "porque_no_denuncio_violencia",

    "B10_1_1": "denuncio_sorpresa",
    "B11_1_1": "como_denuncio_sorpresa",
    "B15_1_1": "porque_no_denuncio_sorpresa",

    "C10_1_1": "denuncio_vivienda",
    "C11_1_1": "como_denuncio_vivienda",
    "C15_1_1": "porque_no_denuncio_vivienda",

    "D7_1_1":  "denuncio_hurto",
    "D8_1_1":  "como_denuncio_hurto",
    "D12_1_1": "porque_no_denuncio_hurto",

    "E10_1_1": "denuncio_lesiones",
    "E11_1_1": "como_denuncio_lesiones",
    "E15_1_1": "porque_no_denuncio_lesiones",

    "G10_1_1": "denuncio_de_vehiculos",
    "G12_1_1": "como_denuncio_de_vehiculos",
    "G16_1_1": "porque_no_denuncio_de_vehiculos",

    "H9_1_1":  "denuncio_desde_vehiculos",
    "H10_1_1": "como_denuncio_desde_vehiculos",
    "H14_1_1": "porque_no_denuncio_desde_vehiculos",
}

CRIME_RENAME_2021 = {    # mapping de 2020-2021 (etiquetas distintas)
    "A4_1_1": "denuncio_violencia",
    "A5_1_1": "como_denuncio_violencia",
    "A6_1_1": "porque_no_denuncio_violencia",

    "B4_1_1": "denuncio_sorpresa",
    "B5_1_1": "como_denuncio_sorpresa",
    "B6_1_1": "porque_no_denuncio_sorpresa",

    "C3_1_1": "denuncio_vivienda",
    "C4_1_1": "como_denuncio_vivienda",
    "C5_1_1": "porque_no_denuncio_vivienda",

    "D4_1_1": "denuncio_hurto",
    "D5_1_1": "como_denuncio_hurto",
    "D6_1_1": "porque_no_denuncio_hurto",

    "E4_1_1": "denuncio_lesiones",
    "E5_1_1": "como_denuncio_lesiones",
    "E6_1_1": "porque_no_denuncio_lesiones",

    "G3_1_1": "denuncio_de_vehiculos",
    "G4_1_1": "como_denuncio_de_vehiculos",
    "G5_1_1": "porque_no_denuncio_de_vehiculos",

    "H3_1_1": "denuncio_desde_vehiculos",
    "H4_1_1": "como_denuncio_desde_vehiculos",
    "H5_1_1": "porque_no_denuncio_desde_vehiculos",
}

AGE_BINS = [0, 15, 20, 25, 30, 40, 50, 60, 70, 80, 90, float("inf")]
AGE_LABELS = list(range(11))  # 0..10


# ------------------------------------------------------------
# Función principal por año
# ------------------------------------------------------------
def clean_year(path: Path, year: int) -> pd.DataFrame:
    df, _ = pyreadstat.read_sav(path)
    df["year"] = year

    # ------------------------------------------------------------------
    # Renombres básicos
    if year < 2020:
        df = df.rename(columns={
            "P3_1_1": "pad",
            "P3_2_1": "pad_comuna",
            "P3_3_1": "pad_barrio",
            "P13_1_1": "future_victimization",
            "rph_p12": "working",
        })
        crime_map = CRIME_RENAME_1619
    elif year == 2020:
        df = df.rename(columns={
            "P1_1_1": "pad",
            "P1_2_1": "pad_comuna",
            "P1_3_1": "pad_barrio",
            "P3_1_1": "future_victimization",
            "rph_p9": "working",
        })
        crime_map = CRIME_RENAME_2021
    else:  # 2021
        df = df.rename(columns={
            "P1_1_1": "pad",
            "P1_2_1": "pad_comuna",
            "P1_3_1": "pad_barrio",
            "P4_1_1": "future_victimization",
            "rph_situacion_laboral_a": "working",
        })
        crime_map = CRIME_RENAME_2021

    # Renombre de info fuentes (no existe en 2020)
    if year < 2020:
        df = df.rename(columns={
            "P4_1_1": "info_pais_frst",
            "P4_1_2": "info_pais_scnd",
            "P5_1_1": "info_comuna_frst",
            "P5_1_2": "info_comuna_scnd",
        })
    else:
        df["info_pais_frst"] = pd.NA
        df["info_pais_scnd"] = pd.NA
        df["info_comuna_frst"] = pd.NA
        df["info_comuna_scnd"] = pd.NA

    # ------------------------------------------------------------------
    # Mapear variables de crimen / denuncia
    df = df.rename(columns=crime_map)

    # ------------------------------------------------------------------
    # Normalizaciones
    for col in ["pad", "pad_comuna", "pad_barrio", "future_victimization"]:
        if col in df.columns:
            df[col] = df[col].where(df[col] <= 1, 0)

    # Binarizar todas las denuncias
    denuncia_cols = [c for c in df.columns if c.startswith("denuncio_")]
    for c in denuncia_cols:
        df[c] = binarize(df[c])

    # Agrupar edad (solo 2016-2018)
    if year < 2019:
        df["rph_edad"] = pd.cut(df["rph_edad"], AGE_BINS, labels=AGE_LABELS, right=False)

    # Ajustes específicos
    if "porque_no_denuncio_lesiones" in df.columns:
        if year in (2020, 2021):
            df["porque_no_denuncio_lesiones"] = df["porque_no_denuncio_lesiones"].replace(14, 15)
        else:
            mask = df["porque_no_denuncio_lesiones"].between(5, 76, inclusive="left")
            df.loc[mask, "porque_no_denuncio_lesiones"] += 1

    return df


# ------------------------------------------------------------
# Driver
# ------------------------------------------------------------
def main() -> None:
    all_years = []
    for yr, p in SRC.items():
        if not p.exists():
            raise FileNotFoundError(p)
        print(f"• Procesando {yr} …")
        all_years.append(clean_year(p, yr))

    full = pd.concat(all_years, ignore_index=True)

    # dejar sólo columnas relevantes (si faltara alguna, se ignora)
    keep = [c for c in KEEP_VARS if c in full.columns]
    full = full[keep]

    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    full.to_parquet(OUT_PATH, index=False)
    print(f"✅ Dataset guardado en: {OUT_PATH.relative_to(Path.cwd())}")


if __name__ == "__main__":
    main()
