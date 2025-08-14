"""
Consolida la ejecución presupuestaria por institución (Carabineros, PDI,
Gendarmería, MP, SML, DPP y Formación) del 4º trimestre -- 2012-2022.

Genera un único parquet largo (`dipres_exec.parquet`) con:
    * Ingresos / Aporte Fiscal / Gastos (nominales)
    * Ajustados a pesos 2022 (IPC)
    * % del PIB y % del Gasto Total
No dibuja gráficas: eso lo haremos en notebooks.

Requisitos:
    pandas>=2.0, openpyxl>=3.1
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import Dict, Any, List

import numpy as np
import pandas as pd
from pandas import DataFrame as DF

from analysis.metadata import METADATA

CFG: Dict[str, Any] = METADATA["dipres_exec"]
SRC = CFG["sources"]
YEARS: List[int] = CFG["years"]
OUT_PATH: Path = CFG["processed_path"]

# -----------------------------------------------------------------------------
# 1. utilidades
# -----------------------------------------------------------------------------

PROGRAMAS = {
    "carabineros":   ("Programa 3101", "Carabineros de Chile"),
    "formacion":     ("Programa 3102", "Formación y Perfeccionamiento policial"),
    "defensoria":    ("Programa 0901", "Defensoría Penal Pública"),
    "gendarmeria":   ("Programa 0401", "Gendarmería"),
    "mp":            ("Programa 0101", "Ministerio Público"),
    "pdi":           ("Programa 3301", "PDI"),
    "sml":           ("Programa 0301", "SML"),
}


COL_RENAME = {
    # la hoja empieza siempre en B6 (Clasificación Económica)
    "B": "ClasificaciónEconómica",
    "C": "PresupuestoVigente",
}


# analysis/scripts/clean_dipres_exec.py
def read_ejecucion(carpeta: Path, programa_sheet: str, years: List[int]) -> DF:
    dfs: List[DF] = []

    for y in years:
        # ── buscar XLS/XLSX ─────────────────────────────────────────────
        fpath = next(carpeta.glob(f"*{y}*xls*"), None)

        # ── ① FALLBACK a CSV trimestrales ───────────────────────────────
        if fpath is None:
            csvs = sorted(carpeta.glob(f"{y}-*.csv"))
            if not csvs:                        # sigue sin datos → avisar y saltar
                print(f"⚠️  {carpeta.name}: sin datos para {y}; se omite")
                continue
            fpath     = csvs[-1]                # nos quedamos con el último trimestre
            df        = pd.read_csv(fpath, sep=";|,", engine="python", encoding="latin-1", on_bad_lines="skip")
            # normalizar cabeceras
            df.columns = (df.columns.str.strip()
                                    .str.replace(" ", "_")
                                    .str.normalize("NFKD")
                                    .str.encode("ascii", "ignore")
                                    .str.decode())
        else:
            # lectura desde Excel (idéntica a la que ya tenías)
            engine = "openpyxl" if fpath.suffix.lower() in (".xlsx", ".xlsm") else "xlrd"
            df = pd.read_excel(
                fpath,
                sheet_name=programa_sheet,
                engine=engine,
                header=None,
                skiprows=5,
                usecols="B:C",
            )
            df.columns = ["ClasificaciónEconómica", "PresupuestoVigente"]

        # ── limpieza común para ambos formatos ──────────────────────────
        df = df[~df["ClasificaciónEconómica"].str.contains("Subt", na=False)]
        df["year"] = y
        # 1) Renombrar si venía del CSV
        if "presupuesto_vigente" in df.columns:
            df = df.rename(columns={
                "clasificacion_economica": "ClasificaciónEconómica",
                "presupuesto_vigente":    "PresupuestoVigente",
            })

        # 2) Limpiar y forzar a float
        df["PresupuestoVigente"] = (
            df["PresupuestoVigente"]
            .astype(str)
            .str.replace(r"[^\d,-]", "", regex=True)  # quita $ y espacios
            .str.replace(".", "", regex=False)        # miles → nada
            .str.replace(",", ".", regex=False)       # decimales , → .
            .str.strip()
            .replace("", np.nan)
            .astype(float)
        )
        dfs.append(df)


    return pd.concat(dfs, ignore_index=True)



def limpiar_clase(df: DF) -> DF:
    """Remueve espacios para igualar las etiquetas de Stata."""
    df["ClasificaciónEconómica"] = (
        df["ClasificaciónEconómica"].str.upper()
        .str.normalize("NFKD")
        .str.replace(" ", "", regex=False)
    )
    return df


# -----------------------------------------------------------------------------
# 2. carga de cada institución
# -----------------------------------------------------------------------------

def build_instituciones() -> DF:
    frames: List[DF] = []
    for clave, (sheet, etiqueta) in PROGRAMAS.items():
        carpeta = SRC[clave]
        df = read_ejecucion(carpeta, sheet, YEARS)
        df = limpiar_clase(df)
        df["Tipo"] = etiqueta
        frames.append(df)

    return pd.concat(frames, ignore_index=True)


# -----------------------------------------------------------------------------
# 3. IPC, tipo de cambio, PIB, gasto total
# -----------------------------------------------------------------------------

# ---- reemplaza get_ipc(), get_tc(), get_pib() por versiones tolerantes ----
def _read_fecha_col(xls_path: Path, sheet: str, col_range: str) -> DF:
    """Lee la hoja y devuelve un df con columna 'fecha' parseada a datetime."""
    df = pd.read_excel(
        xls_path,
        sheet_name=sheet,
        engine="openpyxl",
        header=0,
        usecols=col_range,
    )

    # La primera columna debería ser la fecha aunque el nombre varíe
    first = df.columns[0]
    df = df.rename(columns={first: "fecha"})
    df["fecha"] = pd.to_datetime(df["fecha"], errors="coerce")
    return df

def get_ipc() -> DF:
    df = _read_fecha_col(SRC["inflacion"], "Cuadro", "A:B")

    # ── nombre real de la 2ª columna (valor) ─────────────────────────
    val_col = [c for c in df.columns if c != "fecha"][0]   # la que no es 'fecha'
    df = df.rename(columns={val_col: "ipc_val"})

    df["year"] = df["fecha"].dt.year
    ipc = df.groupby("year", as_index=False)["ipc_val"].sum()

    ipc["inflacion_acum"] = ipc["ipc_val"][::-1].cumsum()[::-1]
    ipc["ponderador"]     = 1 + ipc["inflacion_acum"] / 100
    return ipc.set_index("year")[["ponderador"]]


# ───────────────────────── TC diciembre de cada año ──────────────────────────
def get_tc() -> DF:
    df = _read_fecha_col(SRC["tc_nominal"], "Cuadro", "A:B")
    val_col = next(c for c in df.columns if c != "fecha")      # ← detecta cabecera real
    df = df.rename(columns={val_col: "Tipodecambionominaldól"})

    df["year"] = df["fecha"].dt.year
    df["mes"]  = df["fecha"].dt.month
    df = df[(df["year"].between(2012, 2022)) & (df["mes"] == 12)]

    df["Tipodecambionominaldól"] = (
        df["Tipodecambionominaldól"]
          .astype(str)
          .str.replace(r"[^\d,.-]", "", regex=True)
          .str.replace(",", ".", regex=False)
          .astype(float)
    )
    return df.set_index("year")[["Tipodecambionominaldól"]]



# ───────────────────────── PIB USD diciembre de cada año ─────────────────────
def get_pib() -> DF:
    df = _read_fecha_col(SRC["pib_usd"], "Cuadro", "A:B")
    val_col = next(c for c in df.columns if c != "fecha")
    df = df.rename(columns={val_col: "PIBmillonesUSD"})

    df["year"] = df["fecha"].dt.year
    df["mes"]  = df["fecha"].dt.month
    df = df[df["mes"] == 12]

    df["PIBmillonesUSD"] = (
        df["PIBmillonesUSD"]
          .astype(str)
          .str.replace(r"[^\d,.-]", "", regex=True)
          .str.replace(",", ".", regex=False)
          .astype(float)
          * 1_000_000        # de millones → unidades
    )
    return df.set_index("year")[["PIBmillonesUSD"]]




def get_gasto_total() -> DF:
    """
    Extrae el monto «TOTAL GASTOS» de la hoja “Table 2” (o la primera hoja
    si no existe) de los archivos “Estado de Operaciones …”.  Tolera cambios
    de cabecera, de posición y de separadores de miles.
    """
    frames: list[dict[str, float]] = []

    for y in YEARS:
        fpath = next(SRC["gasto_total"].glob(f"*{y}*xls*"), None)
        if fpath is None:
            print(f"⚠️  Gasto total: no encontré archivo para {y}; se omite")
            continue

        xl = pd.ExcelFile(fpath, engine="openpyxl")
        sheet = "Table 2" if "Table 2" in xl.sheet_names else xl.sheet_names[0]
        df = pd.read_excel(fpath, sheet_name=sheet, engine="openpyxl", header=None)

        # 1 → renombra la primera columna a «concepto» para filtrar la fila
        df = df.rename(columns={0: "concepto"})

        # 2 → localiza la fila con cualquier variante de “total gastos”
        mask = df["concepto"].astype(str).str.contains(
            r"total\s+gastos", flags=re.I, regex=True, na=False
        )
        if not mask.any():
            print(f"⚠️  No hallé 'TOTAL GASTOS' en {fpath.name}; se omite")
            continue

        fila = df.loc[mask].iloc[0]

        # 3 → descarta la celda de texto y quédate con los numéricos
        monto = (
            pd.to_numeric(fila[1:], errors="coerce")  # salta col 0 (texto)
              .dropna()
              .iloc[-1]                               # último valor numérico
        )

        frames.append({"year": y, "GastoTotalCLP": float(monto)})

    res = pd.DataFrame(frames)
    if res.empty:
        raise RuntimeError("No se pudo extraer el gasto total de ningún año.")
    return res.set_index("year")




# -----------------------------------------------------------------------------
# 4. cálculos derivados
# -----------------------------------------------------------------------------

def add_derivatives(df: DF) -> DF:
    """Calcula Ingresos/Gastos desagregados y los indicadores derivados."""

    # pivot para trabajar más cómodo
    wide = df.pivot_table(
        index=["year", "Tipo"],
        columns="ClasificaciónEconómica",
        values="PresupuestoVigente",
        aggfunc="sum",
    ).fillna(0)

    wide["Ingresos"]       = wide.get("INGRESOS", 0)
    wide["Aporte_Fiscal"]  = wide.get("APORTEFISCAL", 0)
    wide["Gastos"]         = wide.get("GASTOS", 0)
    wide["Gastos_personal"] = wide.get("GASTOSENPERSONAL", 0)
    wide["Gastos_consumo"]  = wide.get("BIENESYSERVICIOSDECONSUMO", 0)

    wide["Otros_Ingresos"] = wide["Ingresos"] - wide["Aporte_Fiscal"]
    wide["Otros_Gastos"]   = (
        wide["Gastos"] - wide["Gastos_personal"] - wide["Gastos_consumo"]
    )

    # merge con auxiliares
    aux = (
    get_ipc()
      .join(get_tc(), how="left")
      .join(get_pib(), how="left")
      .join(get_gasto_total(), how="left")
)

    wide = wide.join(aux, on="year")

    # normalizados a 2022
    for col in ["Ingresos", "Aporte_Fiscal", "Otros_Ingresos",
                "Gastos", "Gastos_personal", "Gastos_consumo", "Otros_Gastos"]:
        wide[f"{col}_2022"] = wide[col] * wide["ponderador"]

    # % PIB y % Gasto Total
    for col in ["Ingresos", "Aporte_Fiscal", "Otros_Ingresos",
                "Gastos", "Gastos_personal", "Gastos_consumo", "Otros_Gastos"]:
        wide[f"{col}_PIB"] = (
            (wide[col] / wide["Tipodecambionominaldól"]) /
            wide["PIBmillonesUSD"]
        ) * 100
        wide[f"{col}_GT"] = (wide[col] / wide["GastoTotalCLP"]) * 100

    wide = wide.reset_index()
    return wide


# -----------------------------------------------------------------------------
# 5. driver
# -----------------------------------------------------------------------------

def main() -> None:
    base = build_instituciones()
    full = add_derivatives(base)

    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    full.to_parquet(OUT_PATH, index=False)
    print(f"✅ Ejecución presupuestaria lista → {OUT_PATH.relative_to(Path.cwd())}")


if __name__ == "__main__":
    main()
