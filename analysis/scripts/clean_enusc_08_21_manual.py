#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Cleaning ENUSC 2008-2021 (versión “manual”)
------------------------------------------
• Lee los .sav originales (2008-2014 + 2016-2021).
• Estandariza nombres de columnas y tipos.
• Calcula VarStrat, vict_gral_n y denuncias_gral_n según la
  lógica del .do.
• Filtra a Kish == 1.
• Exporta un único Parquet en data/processed.

Requisitos
----------
pip install pyreadstat pandas pyarrow numpy
"""

from pathlib import Path
import pandas as pd
import numpy as np
import pyreadstat  # ← lee .sav muy rápido

# ────────────────────────────────────────────────────────────
from analysis.metadata import BASE_DIR, RAW_DIR, PROC_DIR   # reutiliza paths


OUT_PATH = PROC_DIR / "enusc_08_21_manual.parquet"

# rutas a los .sav (idénticas a las del METADATA)
SAV_FILES = {
    2008: RAW_DIR / "1. ENUSC V Base de Usuario 2008.sav",
    2009: RAW_DIR / "2. ENUSC VI Base Usuaro 2009.sav",
    2010: RAW_DIR / "3. ENUSC VII Base Usuario 2010.sav",
    2011: RAW_DIR / "4. ENUSC VIII Base Usuario 2011.sav",
    2012: RAW_DIR / "5. ENUSC IX  Base Usuario 2012.sav",
    2013: RAW_DIR / "6. ENUSC X Base Usuario 2013.sav",
    2014: RAW_DIR / "7. ENUSC XI Base Usuario 2014.sav",
    # 2015 omitido
    2016: RAW_DIR / "base-de-datos---enusc-xiii.sav",
    2017: RAW_DIR / "base-de-datos---xiv-enusc-2017.sav",
    2018: RAW_DIR / "base-de-datos---xv-enusc-2018.sav",
    2019: RAW_DIR / "base-de-datos---xvi-enusc-2019-(sav).sav",
    2020: RAW_DIR / "base-usuario-17-enusc-2020-sav.sav",
    2021: RAW_DIR / (
        "base-usuario-18-enusc-2021-sav05142b868f1445af8f592cf582239857.sav"
    ),
}

KEEP_COLS = [
    "year", "ID_vivienda", "Fact_Hog_15reg_nuevo",
    "VarStrat", "kish",
    "vict_gral_n", "denuncias_gral_n",
]

# variables que, para 2016-2021, se usan para construir vict_gral_n / denuncias
VICT_COLS      = [f"{c}_N_Veces" for c in "A1_1_1 B1_1_1 C1_1_1 D1_1_1 E1_1_1 G1_1_1 H1_1_1".split()]
DENUNCIA_COLS  = [x.replace("1_1_", "2_1_") for x in VICT_COLS]

def read_and_clean(year: int, path: Path) -> pd.DataFrame:
    """Lee .sav, renombra y genera columnas estandarizadas."""
    print(f"→ Leyendo {year}")
    df, meta = pyreadstat.read_sav(path, apply_value_formats=False)

    df = df.copy()  # evitamos SettingWithCopyWarning

    # columna year
    df["year"] = year

    # ── renombres que cambian por año ─────────────────────────
    if year == 2008:
        df.rename(columns={
            "enc_folio": "ID_vivienda",
            "P22_NVeces": "vict_gral_n",
            "P23_Ncasos": "denuncias_gral_n",
            "Fact_Hog_15reg_nuevo": "Fact_Hog_15reg_nuevo",
        }, inplace=True)
        df["VarStrat"] = (df["year"].astype(str) + df["enc_rpc"].astype(str)).astype(int)

    elif year == 2009:
        df.rename(columns={
            "enc_idr": "ID_vivienda",
            "P22_nveces": "vict_gral_n",
            "p23_ncasos": "denuncias_gral_n",
        }, inplace=True)
        df["VarStrat"] = (df["year"].astype(str) + df["enc_comuna"].astype(str)).astype(int)

    elif year in (2010, 2011, 2012, 2013, 2014):
        # mismos nombres salvo 2010 para vict/denuncias
        rename_map = {
            "ID_Vivienda": "ID_vivienda",
            "P20_Nveces": "vict_gral_n",
            "P21_Ncasos": "denuncias_gral_n",
        }
        if year == 2010:
            rename_map = {
                "P24_NVeces": "vict_gral_n",
                "P25_Ncasos": "denuncias_gral_n",
            } | rename_map
        df.rename(columns=rename_map, inplace=True)
        df["VarStrat"] = (df["year"].astype(str) + df["enc_comuna"].astype(str)).astype(int)

    elif year >= 2016:
        # variables ya homogenizadas
        df.rename(columns={
            "enc_idr": "ID_vivienda",
            "Fact_Hog": "Fact_Hog_15reg_nuevo",
            "Kish": "kish",
        }, inplace=True)

        # ---- vict_gral_n / denuncias_gral_n ----
        df["vict_gral_n"]      = df[VICT_COLS].replace(0, np.nan).bfill(axis=1).iloc[:, 0]
        df["denuncias_gral_n"] = df[DENUNCIA_COLS].replace(0, np.nan).bfill(axis=1).iloc[:, 0]

        # VarStrat ya viene numérico
        df["VarStrat"] = df["VarStrat"].astype(int)

    # aseguramos presencia de columnas clave aun si faltan
    missing = set(KEEP_COLS) - set(df.columns)
    for col in missing:
        df[col] = np.nan

    df = df[KEEP_COLS]

    return df


# ── build global dataframe ──────────────────────────────────────────────────
frames = []
for yr, sav in SAV_FILES.items():
    if not sav.exists():
        print(f"⚠️  No se encontró {sav.name}; se omite {yr}")
        continue
    frames.append(read_and_clean(yr, sav))

enusc = pd.concat(frames, ignore_index=True)

# ── filtros finales ─────────────────────────────────────────────────────────
enusc = enusc[enusc["kish"] == 1]   # equivalente a “keep if kish==1” en Stata

# ── export ──────────────────────────────────────────────────────────────────
enusc.to_parquet(OUT_PATH, index=False)
print(f"\n✅  Dataset guardado en {OUT_PATH.relative_to(BASE_DIR)} "
      f"({len(enusc):,} filas)")
