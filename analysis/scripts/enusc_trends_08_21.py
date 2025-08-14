#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""ENUSC 2008‑2021 • Tendencias de percepción y victimización
----------------------------------------------------------------
Genera una tabla anual con las medias ponderadas y errores estándar de:
    • Percepción de aumento de la delincuencia (PAD)
    • Victimización individual (vp_dc)
    • Victimización hogares (va_dc)
    • Revictimización hogares (rva_dc)

Salida → `data/processed/enusc_trends_08_21.parquet`

Uso
---
$ python enusc_trends_08_21.py
"""
from __future__ import annotations

import sys
from pathlib import Path
from typing import Dict, List

import numpy as np
import pandas as pd
import pyreadstat
from statsmodels.stats.weightstats import DescrStatsW

# ────────────────────────────────────────────────────────────────
# 1. Metadata & paths
# ────────────────────────────────────────────────────────────────
ROOT = Path(__file__).resolve().parents[1]        # /ep-seguridad
sys.path.append(str(ROOT))                        # para importar metadata

try:
    from metadata import RAW_DIR, PROC_DIR, METADATA  # type: ignore
except ImportError as exc:  # pragma: no cover
    raise SystemExit("❌  No encuentro metadata.py — verifica tu PYTHONPATH") from exc

INFO = METADATA["enusc_trends_08_21"]
SRC  = INFO["sources"]["interannual_sav"]
DEST = INFO["processed_path"]
DEST.parent.mkdir(parents=True, exist_ok=True)

# columnas mínimas (filtramos al leer → RAM friendly)
COLS = INFO["keep_vars"]

# ────────────────────────────────────────────────────────────────
# 2. Carga y limpieza
# ────────────────────────────────────────────────────────────────
print(f"→ Leyendo base interanual ENUSC: {SRC.name}")

df, _ = pyreadstat.read_sav(SRC, usecols=COLS, apply_value_formats=False)

df.rename(columns={"año": "year"}, inplace=True)   # cast sencillo

# ────────────────────────────────────────────────────────────────
# 3. Funciones auxiliares
# ────────────────────────────────────────────────────────────────

def wmean_se(series: pd.Series, weights: pd.Series) -> tuple[float, float]:
    """Media ponderada y su error estándar (ddof = 0)."""
    wstats = DescrStatsW(series, weights=weights, ddof=0)
    return float(wstats.mean), float(wstats.std_mean)

# ────────────────────────────────────────────────────────────────
# 4. Agregación anual
# ────────────────────────────────────────────────────────────────
rows: List[Dict[str, float]] = []

for yr, grp in df.groupby("year", sort=True):
    # Pesos individuales (pad, vp_dc)
    pi = grp["fact_pers_2019_2021"].astype(float)
    # Pesos hogares (va_dc, rva_dc)
    ph = grp["fact_hog_2019_2021"].astype(float)

    mean_pad,   se_pad   = wmean_se(grp["pad"],   pi)
    mean_vic_i, se_vic_i = wmean_se(grp["vp_dc"],  pi)
    mean_vic_h, se_vic_h = wmean_se(grp["va_dc"],  ph)
    mean_revic, se_revic = wmean_se(grp["rva_dc"], ph)

    rows.append({
        "year": yr,
        "mean_pad": mean_pad,   "stderr_pad":   se_pad,
        "mean_vic_i": mean_vic_i, "stderr_vic_i": se_vic_i,
        "mean_vic_h": mean_vic_h, "stderr_vic_h": se_vic_h,
        "mean_revic": mean_revic, "stderr_revic": se_revic,
    })

agg = pd.DataFrame(rows).sort_values("year")
agg.to_parquet(DEST, index=False)
print(f"✅  Guardado {DEST}  →  {len(agg)} registros"))
