"""
ETL de los ficheros COFOG de DIPRES + comparaciones internacionales.
Reproduce las transformaciones del do-file “SP Dipres.do”.

No genera los gráficos (eso lo haremos luego en un notebook), pero
entrega un parquet largo y limpio que los notebooks pueden plotear.

Requisitos:
    pandas >= 2.0
    openpyxl >= 3.1
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import Dict, Any, List, Tuple

import numpy as np
import pandas as pd
from pandas import DataFrame as DF

from analysis.metadata import METADATA   # 👈┐PYTHONPATH apunta a /ep-seguridad
                                         #   └────────────────────────────────

CFG: Dict[str, Any] = METADATA["dipres_sp"]
SRC: Dict[str, Path | Dict[str, Path]] = CFG["sources"]
OUT_PATH: Path = CFG["processed_path"]
KEEP_VARS: List[str] = CFG["keep_vars"]

# ─────────────────────────────────────────────────────────────────────────────
# 1. UTILIDADES
# ─────────────────────────────────────────────────────────────────────────────

COFOG_FILTER: Tuple[str, ...] = (
    "7",  # Orden público & seguridad (nivel 1)
    "701", "702", "703", "704", "705", "706", "707", "708", "709", "710"
)


def _read_chile_block(
    book: Path,
    sheet: str,
    cellrange: str,
    rename_map: Dict[str, str],
    prefix: str,
) -> DF:
    """
    Lee un bloque rectangular del Excel (por ej. “A6:L76”) sin depender de
    la lógica `cellrange[1:-1]` que fallaba cuando la letra era sólo una.

    1.   Detecta fila inicial y final a partir de la cadena `cellrange`.
    2.   Renombra las columnas por sus letras A-L para poder usar `rename_map`.
    3.   Filtra los códigos COFOG 7xx y hace `melt` igual que antes.
    """
    # ── 1 · parsear el rango --------------------------------------------------
    m = re.match(r"([A-Z]+)(\d+):([A-Z]+)(\d+)", cellrange)
    if m is None:
        raise ValueError(f"Cellrange mal formado: {cellrange!r}")
    col_ini, row_ini, col_fin, row_fin = m.groups()
    row_ini, row_fin = int(row_ini), int(row_fin)
    n_rows = row_fin - row_ini + 1

    # ── 2 · lectura -----------------------------------------------------------
    df = pd.read_excel(
        book,
        sheet_name=sheet,
        engine="openpyxl",
        header=None,                     # sin header — los nombres los ponemos
        skiprows=row_ini - 1,            # pandas cuenta desde 0
        nrows=n_rows,
        usecols=f"{col_ini}:{col_fin}",  # ej. "A:L"
    )

    # asigna letras A,B,C… a las columnas para que `rename_map` funcione
    letras = list("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    df.columns = letras[: df.shape[1]]
    df = df.rename(columns=rename_map)

    # ── 3 · filtrado COFOG y reshape -----------------------------------------
    df["A"]  = df["A"].astype(str)
    df["A1"] = df["A"].str.slice(0, 3)
    df = df[df["A"].isin(COFOG_FILTER) | df["A1"].isin(COFOG_FILTER)]

    value_cols = [c for c in df.columns if re.search(r"\d{4}$", c)]
    df = df.melt(
        id_vars=["A", "A1", "Partida"],
        value_vars=value_cols,
        var_name="Year",
        value_name=f"{prefix}_value",
    )
    df["Year"] = (
        df["Year"]
          .str.extract(r"(\d{4})", expand=False)  # saca los 4 dígitos
          .astype(int)
    )
    return df



def _merge_blocks(blocks: List[DF]) -> DF:
    """Hace merge 1:1 (Partida + Year) entre todos los dataframes."""
    out = blocks[0]
    for blk in blocks[1:]:
        out = out.merge(blk, on=["Partida", "Year", "A", "A1"], how="left")
    return out


def _rename_partidas(df: DF) -> DF:
    """Normaliza Partida quitando acentos y poniendo minúsculas sin espacios."""
    replacements = {
        "Actividades Recreativas, Cultura y Religión": "Actividades recreativas, cultura y religión",
        "Actividades Recreativas, Cultura y Religión": "Actividades recreativas, cultura y religión",
        "Asuntos Económicos": "Asuntos económicos",
        "Orden Público y Seguridad": "Orden público y seguridad",
        "Orden Público y Seguridad n.e.p.": "Orden público y seguridad n.e.p.",
        "Protección del Medio Ambiente": "Protección del medio ambiente",
        "Servicios Públicos Generales": "Servicios públicos generales",
        "Servicios de Protección contra Incendios": "Servicios de protección contra incendios",
        "Tribunales de Justicia": "Tribunales de justicia",
        "Vivienda y Servicios Comunitarios": "Vivienda y servicios comunitarios",
        "Protección Social": "Protección social",
    }
    df["Partida"] = df["Partida"].replace(replacements)
    return df


# ─────────────────────────────────────────────────────────────────────────────
# 2. CHILE: PRESUPUESTOS 2013-2022
# ─────────────────────────────────────────────────────────────────────────────

def build_chile_2013_2022() -> DF:
    book = SRC["articles_311931"]
    # ---- hojas + qué sufijo renombrar ----
    setups = [
        ("CFEGCT",        "Pesos"),
        ("CFEGCT$22",     "Pesos22"),
        ("CFEGCT%PIB",    "PIB"),
        ("CFEGCT%GT",     "GT"),
    ]
    blocks = []
    for sheet, prefix in setups:
        rename_map = {
            "B": "Partida",
            "C": f"{prefix}_2013", "D": f"{prefix}_2014", "E": f"{prefix}_2015",
            "F": f"{prefix}_2016", "G": f"{prefix}_2017", "H": f"{prefix}_2018",
            "I": f"{prefix}_2019", "J": f"{prefix}_2020", "K": f"{prefix}_2021",
            "L": f"{prefix}_2022",
        }
        blocks.append(
            _read_chile_block(book, sheet, "A6:L76", rename_map, prefix)
        )

    df = _merge_blocks(blocks)
    return _rename_partidas(df)


# ─────────────────────────────────────────────────────────────────────────────
# 3. CHILE: PRESUPUESTOS 2009-2018
# ─────────────────────────────────────────────────────────────────────────────

def build_chile_2009_2018() -> DF:
    book = SRC["articles_189249"]
    setups = [
        ("CFEGCT",              "Pesos"),
        ("CFEGCT$18",           "Pesos22"),
        ("CFEGCT%PIB",          "PIB"),
        ("CFEGCT%GastoTotal",   "GT"),
    ]
    blocks = []
    for sheet, prefix in setups:
        rename_map = {
            "B": "Partida",
            # 2009-2012 + 2013-2018 pero quitaremos las 13-18 al final
            "C": f"{prefix}_2009", "D": f"{prefix}_2010", "E": f"{prefix}_2011",
            "F": f"{prefix}_2012", "G": f"{prefix}_2013", "H": f"{prefix}_2014",
            "I": f"{prefix}_2015", "J": f"{prefix}_2016", "K": f"{prefix}_2017",
            "L": f"{prefix}_2018",
        }
        blk = _read_chile_block(book, sheet, "A6:L76", rename_map, prefix)

        # nos quedamos solo con 2009-2012 porque 13-18 ya los cubre book1
        blk = blk[blk["Year"] < 2013]
        blocks.append(blk)

    df = _merge_blocks(blocks)
    return _rename_partidas(df)


# ─────────────────────────────────────────────────────────────────────────────
# 4. POST-PROC: ajustes inflacion & “Aumento 2023”
# ─────────────────────────────────────────────────────────────────────────────

def add_aumento(df: DF) -> DF:
    """
    Replica la lógica Stata:
        Aumento = 1 500 millones CLP 2023 →
                  deflactado a pesos 2022 (-2,5 %) →
                  pasado a pesos (factor TC 2022 = 859,51) →
                  millones
    """
    inc_millions_2022 = ((1_500_000_000 * 100) / 102.5) * 859.51 / 1_000_000
    df["Aumento"] = inc_millions_2022
    df["Pesos22_A"] = df["Pesos22_value"] + df["Aumento"]

    # proporcionalmente aplicamos a % PIB y % GT
    df["PIB_A"] = df["PIB_value"] * df["Pesos22_A"] / df["Pesos22_value"]
    df["GT_A"] = df["GT_value"] * df["Pesos22_A"] / df["Pesos22_value"]
    return df


# ─────────────────────────────────────────────────────────────────────────────
# 5. INTERNACIONAL (⚠︎ resumido) – se deja preparado para futuro
# ─────────────────────────────────────────────────────────────────────────────

def build_international() -> DF:
    """
    Carga los PIB% de UE y LATAM.  Para no alargar, sólo se arma la tabla base
    (País, Year, PIB_, GT_, PIB_per, …).  Los cálculos de paridad PPA y los
    merges con OCDE se harán en notebooks específicos.
    """
    # Ejemplo mínimo: UE – % PIB
    ue = pd.read_excel(
        SRC["ue_po_s_pib"],
        sheet_name="Sheet 1",
        engine="openpyxl",
        header=0,
        usecols="A,B,D,F,H,J,L,N,P,R,T,V,X,Z",
        skiprows=11,
        nrows=33,
    )
    ue = ue.rename(columns={"GEOLabels": "Países"})
    ue = ue.melt(id_vars="Países", var_name="col", value_name="PIB_value")
    ue["Year"] = ue["col"].str.extract(r"(\d{4})").astype(int)
    ue = ue.drop(columns="col")
    return ue


# ─────────────────────────────────────────────────────────────────────────────
# 6. DRIVER
# ─────────────────────────────────────────────────────────────────────────────

def main() -> None:
    chile = pd.concat(
        [build_chile_2009_2018(), build_chile_2013_2022()],
        ignore_index=True,
    )
    chile = add_aumento(chile)

    # (opcional) Internacional → cuando lo necesites:
    # intl = build_international()
    # full = pd.concat([chile, intl], ignore_index=True, sort=False)
    full = chile

    # dejamos sólo columnas de interés
    keep_regex = re.compile(
        r"^(Partida|A|A1|Year|"
        r"Pesos22_A|Aumento|"
        r"(Pesos22|Pesos|PIB|PIB_A|GT|GT_A)_value$)"
    )
    cols = [c for c in full.columns if keep_regex.match(c)]
    full = full[cols]

    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    full.to_parquet(OUT_PATH, index=False)
    print(f"✅ Dipres-SP listo → {OUT_PATH.relative_to(Path.cwd())}")


if __name__ == "__main__":
    main()
