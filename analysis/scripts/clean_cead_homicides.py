"""
Limpia y transforma el fichero CEAD de homicidios 2016-2022:

(1) Lee el Excel de CEAD.
(2) Renombra columnas año, escala valores (÷1e10) — formato raro del Excel.
(3) Normaliza nombres de región y codifica `region` 1-16 (RM=13).
(4) `collapse`: suma por región; luego reshape a formato largo.
(5) Merge con proyecciones INE 2016-2022 para obtener población.
(6) Calcula tasa por 100 000 hab.; ajusta la serie país (suma ponderada).
(7) Guarda parquet `cead_homicides.parquet`.
"""

from __future__ import annotations

import unicodedata as ud
from pathlib import Path

import pandas as pd
from pandas import DataFrame as DF

from analysis.metadata import METADATA

CFG = METADATA["cead_homicides"]
SRC = CFG["sources"]
OUT = CFG["processed_path"]


# ─────────────────────────── helpers ──────────────────────────── #

YEARS = list(range(2016, 2023))
YEAR_COLS = {y: y for y in YEARS} 

REG_MAP = {
    # etiquetas que vienen “rotas” por UTF-8
    "Región de Arica y Parinacota": "XV",
    "Región de Tarapacá": "I",
    "Región de Antofagasta": "II",
    "Región de Atacama": "III",
    "Región de Coquimbo": "IV",
    "Región de Valparaíso": "V",
    "Región Metropolitana": "RM",
    "Región del Lib. Bernardo O'Higgins": "VI",
    "Región del Maule": "VII",
    "Región del Biobío": "VIII",
    "Región de La Araucanía": "IX",
    "Región de Los Ríos": "XIV",
    "Región de Los Lagos": "X",
    "Región de Aysén": "XI",
    "Región de Magallanes": "XII",
    # fila total país
    "TOTAL PAÍS": "TOTAL",
}

REG_CODE = {
    "I": 1, "II": 2, "III": 3, "IV": 4, "V": 5, "VI": 6,
    "VII": 7, "VIII": 8, "IX": 9, "X": 10, "XI": 11, "XII": 12,
    "RM": 13, "XIV": 14, "XV": 15, "XVI": 8,   # Ñuble → Biobío para suma histórica
    "TOTAL": 0,
}


def _strip_accents(s: str) -> str:     # útil para cualquier Excel “corrupto”
    return ud.normalize("NFKD", s).encode("ASCII", "ignore").decode()


# ─────────────────────────── main ETL ─────────────────────────── #

def load_cead() -> DF:
    df = pd.read_excel(
        SRC["excel_raw"], sheet_name="Hoja1", engine="openpyxl", header=None
    )

    # encabezados: A=Región, B..H  = años 2016-22
    df = df.iloc[:, :1 + len(YEARS)]
    df.columns = ["Región", *YEAR_COLS.values()]

    # descartar encabezado “Unidad Territorial”
    df = df[df["Región"].str.contains("Región") | df["Región"].str.contains("TOTAL", case=False)]

    # normalizar nombres UTF-8 y mapear a sigla roman-número
    df["Región"] = df["Región"].map(lambda x: REG_MAP.get(_strip_accents(x), x))

    # divide entre 10¹⁰     (en Stata: /10000000000)
    for col in YEAR_COLS.values():
        df[col] = df[col] / 10_000_000_000

    return df


def tidy(df: DF) -> DF:
    # región numérica
    df["region"] = df["Región"].map(REG_CODE)

    # colapsa por región (solo suma por si hay sub-filas)
    df = (
        df.groupby(["region", "Región"], as_index=False)
        [list(YEAR_COLS.values())].sum()          # ← list(…) en vez de dict_values
    )

    # reshape
    long = df.melt(
        id_vars=["region", "Región"],
        value_vars=YEAR_COLS.values(),
        var_name="Año",
        value_name="Homicidios_noweight",
    )
    long["Año"] = long["Año"].astype(int)         # ← conversión directa

    return long


def merge_pop(df: DF) -> DF:
    pop = pd.read_parquet(SRC["proj_pop"])
    if "year" in pop.columns:
        pop = pop.rename(columns={"year": "Año"})
    pop["Año"] = pop["Año"].astype(int)

    merged = df.merge(pop, how="left", on=["region", "Año"])
    merged["Homicidios"] = (
        merged["Homicidios_noweight"] / merged["poblacion"] * 1e5
    )

    # ── TOTAL PAÍS ───────────────────────────────────────────────
    pais = (
        merged.groupby("Año", as_index=False)
              .agg({"Homicidios_noweight": "sum",
                    "poblacion":           "sum"})
    )
    pais["Región"] = "Total país"
    pais["region"] = 0
    pais["Homicidios"] = pais["Homicidios_noweight"] / pais["poblacion"] * 1e5
    # ─────────────────────────────────────────────────────────────

    merged = pd.concat([merged, pais], ignore_index=True)
    return merged



def add_normalised(df: DF) -> DF:
    """Normaliza la serie nacional al promedio 2016-18 (=1)."""
    base = (
        df.query("Región == 'Total país' and Año <= 2018")
        ["Homicidios"].mean()
    )
    df["Homicidios_norm"] = df["Homicidios"] / base
    return df


def main() -> None:
    cead = load_cead()
    tidy_df = tidy(cead)
    merged = merge_pop(tidy_df)
    final = add_normalised(merged)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    final.to_parquet(OUT, index=False)
    print(f"✅ CEAD homicidios listo → {OUT.relative_to(Path.cwd())}")


if __name__ == "__main__":
    main()
