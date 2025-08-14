#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ENUSC 2008-2021 – pipeline único
================================
• Limpia micro-datos 08-14 + 16-21 (2015 no existe).
• Escribe incrementalmente en Parquet (una row-group por año).
• Calcula medias ponderadas + EE y las guarda aparte.

Salida
------
data/processed/enusc_micro_08_21.parquet   (micro-datos)
data/processed/enusc_trends_08_21.parquet  (agregado anual)
"""

from __future__ import annotations
import gc
from pathlib import Path
from typing import Dict, List

import numpy as np
import pandas as pd
import pyreadstat
import pyarrow as pa
import pyarrow.parquet as pq
from statsmodels.stats.weightstats import DescrStatsW

# ─────────────────────────────────────────────────────────────
# PATHS & METADATA
# ─────────────────────────────────────────────────────────────
from analysis.metadata import RAW_DIR, PROC_DIR, METADATA

RAW = RAW_DIR
PROC = PROC_DIR
PROC.mkdir(parents=True, exist_ok=True)

DEST_MICRO = PROC / "enusc_micro_08_21.parquet"
DEST_TRENDS = PROC / "enusc_trends_08_21.parquet"

SAV_PATHS: Dict[int, Path] = METADATA["enusc_all"]["sources"]
KEEP_VARS: List[str] = [c.lower() for c in METADATA["enusc_all"]["keep_vars"]]

# ─────────────────────────────────────────────────────────────
# Tipos canónicos para schema homogéneo
# ─────────────────────────────────────────────────────────────
NUM_INT: List[str] = [
    "year", "enc_region", "rph_id", "enc_idr",
    "kish", "varstrat", "conglomerado",
    "rph_sexo", "rph_nivel", "working",
    "va_dc", "den_agreg", "rva_dc",
]
NUM_FLOAT: List[str] = [
    "fact_pers", "fact_hog",
    "pad", "pad_comuna", "pad_barrio", "future_victimization",
]

# utilidades de recodificación y pesos
BIN = {1: 1, 2: 0}
def wmean_se(x: pd.Series, w: pd.Series) -> tuple[float, float]:
    st = DescrStatsW(x, weights=w, ddof=0)
    return float(st.mean), float(st.std_mean)

# agrupación de edad (solo 2016-2018)
_ED_BINS = [0, 15, 20, 25, 30, 40, 50, 60, 70, 80, 90, np.inf]
_ED_LABS = list(range(len(_ED_BINS) - 1))

# import mapeos específicos
from analysis.scripts.clean_enusc_16_21 import CRIME_RENAME_1619, CRIME_RENAME_2021

# columnas base para leer
BASE_COLS: set[str] = set(KEEP_VARS) | {"rph_edad", "rph_p12", "rph_p9", "rph_situacion_laboral_a"} | set(CRIME_RENAME_1619) | set(CRIME_RENAME_2021)

# ─────────────────────────────────────────────────────────────
# Limpieza y recasteo por año
# ─────────────────────────────────────────────────────────────
def load_year(year: int, path: Path) -> pd.DataFrame:
    if not path.exists():
        print(f"⚠️  {year}: no se encontró {path.name}")
        return pd.DataFrame()

    # metadataonly devuelve (df_meta, meta)
    meta = pyreadstat.read_sav(path, metadataonly=True)[1]
    avail = {c.lower() for c in meta.column_names}
    use = [c for c in BASE_COLS if c.lower() in avail]

    df, _ = pyreadstat.read_sav(path, usecols=use, apply_value_formats=False, encoding="latin1")
    df.columns = [c.lower() for c in df.columns]
    df["year"] = year

    # bloque 2016+
    if year >= 2016:
        cmap = CRIME_RENAME_1619 if year < 2020 else CRIME_RENAME_2021
        df = df.rename(columns=cmap)
        for c in [col for col in df.columns if col.startswith("denuncio_")]:
            df[c] = df[c].map(BIN).astype("Int64")
        if year < 2019 and "rph_edad" in df:
            df["rph_edad"] = pd.cut(df["rph_edad"], bins=_ED_BINS, labels=_ED_LABS, right=False)

    else:
        # lógica 2008-2014 (resumida)
        mapping = {
            2008: {"enc_folio": "id_vivienda", "p22_nveces": "vict_gral_n"},
            # completar para cada año…
        }
        df = df.rename(columns={k.lower(): v for k, v in mapping.get(year, {}).items()})

    # completar columnas faltantes
    for col in KEEP_VARS:
        if col not in df:
            df[col] = pd.NA

    # casteo homogéneo
    for col in NUM_INT:
        df[col] = pd.to_numeric(df.get(col), errors="coerce").astype("Int64")
    if "rph_edad" in df:
        df["rph_edad"] = pd.to_numeric(df["rph_edad"], errors="coerce").astype("Float64")
    for col in NUM_FLOAT:
        df[col] = pd.to_numeric(df.get(col), errors="coerce").astype("Float64")

    # ordenar y devolver
    return df.reindex(columns=KEEP_VARS)

# ─────────────────────────────────────────────────────────────
# Escritura incremental en Parquet
# ─────────────────────────────────────────────────────────────
def build_micro():
    if DEST_MICRO.exists(): DEST_MICRO.unlink()
    writer: pq.ParquetWriter | None = None
    try:
        for yr in sorted(SAV_PATHS):
            df = load_year(yr, SAV_PATHS[yr])
            if df.empty: continue
            table = pa.Table.from_pandas(df, preserve_index=False)
            if writer is None:
                writer = pq.ParquetWriter(DEST_MICRO, table.schema, compression="zstd")
            writer.write_table(table, row_group_size=128_000)
            print(f"✓ {yr}: {len(df):,} filas grabadas")
            del df, table; gc.collect()
    finally:
        if writer: writer.close()

# ─────────────────────────────────────────────────────────────
# Agregado anual (media ponderada + EE)
# ─────────────────────────────────────────────────────────────
def build_trends():
    """
    Carga el .sav interanual (2008-2021) y calcula las medias ponderadas
    + errores estándar de pad, vp_dc, va_dc y rva_dc.
    """
    from analysis.metadata import METADATA
    inter_sav = METADATA["enusc_trends_08_21"]["sources"]["interannual_sav"]

    # columnas mínimas que necesitamos
    COLS = [
        "año",              # luego renombramos a 'year'
        "vp_dc", "va_dc", "rva_dc",
        "pad", "fact_pers_2019_2021", "fact_hog_2019_2021",
    ]

    # 1) cargar interanual
    df, _ = pyreadstat.read_sav(inter_sav, usecols=COLS, apply_value_formats=False)
    df = df.rename(columns={"año": "year"})

    # 2) para cada año, media ponderada + se
    rows = []
    for yr, grp in df.groupby("year", sort=True):
        pi = grp["fact_pers_2019_2021"].astype(float)
        ph = grp["fact_hog_2019_2021"].astype(float)

        def m(se):  # helper
            st = DescrStatsW(grp[se], weights=pi if "pad" in se or "vp_dc" in se else ph, ddof=0)
            return float(st.mean), float(st.std_mean)

        mean_pad, se_pad     = m("pad")
        mean_vic_i, se_vic_i = m("vp_dc")
        mean_vic_h, se_vic_h = m("va_dc")
        mean_revic, se_revic = m("rva_dc")

        rows.append({
            "year": yr,
            "mean_pad":    mean_pad,   "stderr_pad":   se_pad,
            "mean_vic_i":  mean_vic_i, "stderr_vic_i": se_vic_i,
            "mean_vic_h":  mean_vic_h, "stderr_vic_h": se_vic_h,
            "mean_revic":  mean_revic, "stderr_revic": se_revic,
        })

    trends = pd.DataFrame(rows).sort_values("year")
    trends.to_parquet(DEST_TRENDS, index=False)
    print(f"✅ Tendencias guardadas → {DEST_TRENDS.relative_to(PROC)} "
          f"({len(trends)} años)")


if __name__ == "__main__":
    build_micro()
    build_trends()
    print("🎉 Pipeline ENUSC terminado")
