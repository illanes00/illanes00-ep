"""ETL: Defunciones por arma de fuego (DEIS 2016‑2022)
-------------------------------------------------------
Lee el CSV bruto publicado por el Departamento de Estadísticas e
Información de Salud (DEIS), filtra las categorías de causa básica
relacionadas con disparos de armas de fuego y genera un Parquet con
conteos anuales (totales y hasta el 8‑nov para comparabilidad
interanual).

Se apoya en la configuración centralizada de `metadata.py` para evitar
paths mágicos.
"""
from __future__ import annotations

import sys
from pathlib import Path

import pandas as pd

# ── Cargar rutas desde metadata -------------------------------------------------
try:
    from analysis.metadata import METADATA  # type: ignore
except ModuleNotFoundError:
    sys.stderr.write("❌  No encuentro metadata.py; añade la carpeta raíz a PYTHONPATH.\n")
    raise

META = METADATA["deis_gunshot_deaths"]
RAW_FILE: Path = META["sources"]["deis_csv"]  # CSV de origen
OUT_PATH: Path = META["processed_path"]        # Parquet de salida

# ── Parámetros de filtrado -------------------------------------------------------
GUNSHOT_CODES = {7, 8, 9, 81, 82}  # códigos tras .astype('category').cat.codes
DATE_CUTOFF = (11, 8)              # 8‑nov (mes, día)

# ── Renombre de columnas originales (primeras 27) -------------------------------
COLS_RENAME = {
    "v1": "ano",            "v2": "fecha",             "v3": "sexo",
    "v4": "edad_tipo",      "v5": "edad_cant",         "v6": "codigo_comuna",
    "v7": "glosa_comuna",   "v8": "glosa_region",      "v9": "diag1",
    "v10": "capitulo_diag1", "v11": "glosa_capitulo_diag1",
    "v12": "codigo_grupo_diag1",      "v13": "glosa_grupo_diag1",
    "v14": "codigo_categoria_diag1",  "v15": "glosa_categoria_diag1",
    "v16": "codigo_subcategoria_diag1","v17": "glosa_subcategoria_diag1",
    "v18": "diag2",          "v19": "capitulo_diag2",   "v20": "glosa_capitulo_diag2",
    "v21": "codigo_grupo_diag2",      "v22": "glosa_grupo_diag2",
    "v23": "codigo_categoria_diag2",  "v24": "glosa_categoria_diag2",
    "v25": "codigo_subcategoria_diag2","v26": "glosa_subcategoria_diag2",
    "v27": "lugar_defuncion",
}

# ════════════════════════════════════════════════════════════════════════════════

def main() -> None:
    if not RAW_FILE.exists():
        sys.stderr.write(f"❌  No encuentro el archivo bruto: {RAW_FILE}\n")
        sys.exit(1)

    # ── 1) Leer CSV ───────────────────────────────────────────────
    df = pd.read_csv(
        RAW_FILE,
        sep=";",                   # DEIS separa con «;»
        header=None,               # <── ① NO hay cabecera
        names=list(COLS_RENAME.keys()),   # <── ② asignamos v1…v27
        usecols=range(27),         #     ③ ignora columnas extra, si las hubiera
        dtype=str,
        encoding="latin-1",
        encoding_errors="replace",
    )

    df.rename(columns=COLS_RENAME, inplace=True)

    cat_col, fecha_col, ano_col = "glosa_categoria_diag2", "fecha", "ano"

    # ── 4) Filtrar causas arma de fuego
    df["razones"] = df[cat_col].astype("category").cat.codes
    df_gun = df[df["razones"].isin(GUNSHOT_CODES)].copy()

    # ── 5) Parsear fechas y año
    df_gun["fecha_dt"] = pd.to_datetime(df_gun[fecha_col], errors="coerce", dayfirst=True)
    df_gun.dropna(subset=["fecha_dt"], inplace=True)
    df_gun["ano"] = df_gun[ano_col].astype(int)

    # ── 6) Conteos
    total = df_gun.groupby("ano", sort=True)["fecha_dt"].size().rename("muertes_total")
    m_cut, d_cut = DATE_CUTOFF
    mask_ytd = (
        (df_gun["fecha_dt"].dt.month < m_cut) |
        ((df_gun["fecha_dt"].dt.month == m_cut) & (df_gun["fecha_dt"].dt.day <= d_cut))
    )
    ytd = (
        df_gun[mask_ytd]
        .groupby("ano", sort=True)["fecha_dt"]
        .size()
        .rename("muertes_hasta_8nov")
    )

    # ── 7) Guardar
    out = pd.concat([total, ytd], axis=1).reset_index(names=["ano"])
    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    out.to_parquet(OUT_PATH, index=False)
    print(f"✅  Guardado: {OUT_PATH.relative_to(Path.cwd())}  ({len(out)} filas)")


if __name__ == "__main__":
    main()
