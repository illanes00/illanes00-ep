#!/usr/bin/env python3
"""Limpieza y homologación de ENUSC 2016-2021.

* Lee cada .sav original (ruta tomada de ``METADATA``).
* Estandariza nombres de variables, recodifica binarias y agrupa edad (para que todas
  las olas tengan categorías idénticas).
* Concatena y guarda un único Parquet listo para análisis.
"""

from __future__ import annotations

import re
from pathlib import Path

import pandas as pd
import pyreadstat
from tqdm import tqdm

# ---------------------------------------------------------------------------
# ░ Config global: paths & metadata ░
# ---------------------------------------------------------------------------

from analysis.metadata import BASE_DIR, RAW_DIR, PROC_DIR, METADATA  # noqa: E402  (local module)

OUT_PATH = PROC_DIR / "enusc_clean_16_21.parquet"

# Añadimos aquí, por claridad, el mapeo <año, ruta> —lo tomamos del METADATA previo
ENUSC_SOURCES: dict[int, Path] = {
    2016: METADATA["enusc_16_21"]["sources"][2016],
    2017: METADATA["enusc_16_21"]["sources"][2017],
    2018: METADATA["enusc_16_21"]["sources"][2018],
    2019: METADATA["enusc_16_21"]["sources"][2019],
    2020: METADATA["enusc_16_21"]["sources"][2020],
    2021: METADATA["enusc_16_21"]["sources"][2021],
}

# ---------------------------------------------------------------------------
# ░ Ayudas ░
# ---------------------------------------------------------------------------

BIN_LABELS = {0: 0, 1: 1, 2: 0}  # 1 ⇒ sí, 0 ⇒ no (re-codificamos "2" → 0)

# Agrupación de edades (<2019 las bases traen "edad" en años completos)
_EDAD_BINS = [0, 14, 19, 24, 29, 39, 49, 59, 69, 79, 89, 200]
_EDAD_LABELS = list(range(len(_EDAD_BINS) - 1))  # 0-10


# Variables que nos interesa mantener (super-set; si no existe se ignora)
KEEP_VARS = METADATA["enusc_16_21"]["keep_vars"]

# ---------------------------------------------------------------------------
# ░ Funciones de estandarización ░
# ---------------------------------------------------------------------------


def read_sav(path: Path) -> pd.DataFrame:
    """Cargar un archivo SPSS en un *DataFrame* utf-8 y con nombres en minúsculas."""
    df, meta = pyreadstat.read_sav(path, apply_value_formats=False)
    df.columns = [c.lower() for c in df.columns]
    return df


def homogenise(df: pd.DataFrame, year: int) -> pd.DataFrame:
    """Renombrar, recodificar y añadir columnas faltantes para que todas las olas 
    compartan el mismo *schema*.
    """
    df = df.copy()
    df["year"] = year

    # ---------- renombres específicos ----------
    RENAME_MAP_COMMON = {
        # percepción de aumento delincuencia (PAD)
        "p3_1_1": "pad",
        "p1_1_1": "pad",  # 2020-21
        "p3_2_1": "pad_comuna",
        "p1_2_1": "pad_comuna",
        "p3_3_1": "pad_barrio",
        "p1_3_1": "pad_barrio",
        # future victimization
        "p13_1_1": "future_victimization",
        "p3_1_1": "future_victimization",  # 2020
        "p4_1_1": "future_victimization",  # 2021
    }

    # renombres que cambian sólo en un subconjunto de años
    if year == 2019:
        RENAME_MAP_COMMON.update({
            "p14_77_1": "fv_other",
            "rph_p13": "rph_p12",  # alias
        })
    elif year in (2016, 2017, 2018):
        RENAME_MAP_COMMON.update({"p14_13_1": "fv_other"})
    elif year == 2020:
        RENAME_MAP_COMMON.update({"p4_77_1": "fv_other", "rph_p9": "working"})
    elif year == 2021:
        RENAME_MAP_COMMON.update({"p5_77_1": "fv_other"})

    df.rename(columns={k.lower(): v for k, v in RENAME_MAP_COMMON.items()}, inplace=True)

    # ---------- recodificaciones ----------
    # binarizar delitos (A1_1_1 …)
    bin_cols = [c for c in df.columns if re.fullmatch(r"[abdegh]1_1_1", c)]
    for col in bin_cols:
        df[col] = df[col].map(BIN_LABELS).astype("Int64")

    # reportes de denuncia
    report_cols = [c for c in df.columns if c.startswith("denuncio_")]
    for col in report_cols:
        df[col] = df[col].map(BIN_LABELS).astype("Int64")

    # grupos de edad (bases antiguas)
    if year < 2019 and "rph_edad" in df.columns:
        df["rph_edad"] = (
            pd.cut(
                df["rph_edad"],
                bins=_EDAD_BINS,
                labels=_EDAD_LABELS,
                right=True,
            )
            .astype("Int64")
        )

    # ---------- columnas faltantes ----------
    for col in KEEP_VARS:
        if col not in df.columns:
            df[col] = pd.NA

    return df[KEEP_VARS]


# ---------------------------------------------------------------------------
# ░ Main ░
# ---------------------------------------------------------------------------

def main() -> None:
    frames = []
    for year, path in ENUSC_SOURCES.items():
        print(f"→ Procesando {year}: {path.name}")
        df_raw = read_sav(path)
        frames.append(homogenise(df_raw, year))

    df_all = pd.concat(frames, ignore_index=True)

    # Guardar
    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    df_all.to_parquet(OUT_PATH, index=False)
    print(f"✅ Dataset unificado guardado en: {OUT_PATH.relative_to(BASE_DIR)}")


if __name__ == "__main__":
    main()
