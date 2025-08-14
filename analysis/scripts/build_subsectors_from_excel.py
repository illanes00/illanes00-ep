# analysis/scripts/build_subsectors_from_excel.py
from pathlib import Path
import pandas as pd, json, math, re

EXCEL = Path("data/raw/Dipres/articles-372115_doc_xls.xlsx")
OUT = Path("static/data"); OUT.mkdir(parents=True, exist_ok=True)

MAP = {
    "7041": "Servicios de policía",
    "7042": "Tribunales de justicia",
    "7043": "Prisiones",
}

def read_sheet(sheet):
    xl = pd.ExcelFile(EXCEL)
    df = xl.parse(sheet, header=None)
    # fila con años (tú mismo mostraste que está en la 6, índice 5)
    years = [(j, int(df.iat[5, j])) for j in range(df.shape[1])
             if isinstance(df.iat[5, j], (int, float)) and 2000 <= df.iat[5, j] <= 2100]
    cols = [j for j, y in years]
    ys   = [y for j, y in years]
    return df, cols, ys

def series_for_code(df, cols, code):
    # Busca fila cuyo col0 o col1 empiezan con el código
    row_idx = None
    for i in range(df.shape[0]):
        a = df.iat[i,0]; b = df.iat[i,1] if df.shape[1]>1 else None
        s0 = str(a).strip() if a is not None else ""
        s1 = str(b).strip() if b is not None else ""
        if s0.startswith(code) or s1.startswith(code):
            row_idx = i; break
    if row_idx is None:
        return None
    vals = []
    for j in cols:
        v = df.iat[row_idx, j]
        if isinstance(v, (int,float)) and math.isfinite(v):
            vals.append(float(v))
        else:
            vals.append(None)
    return vals

def build_subsec(sheet, fname):
    df, cols, ys = read_sheet(sheet)
    # 704 total
    tot = series_for_code(df, cols, "704")
    # 7041..7043
    parts = {}
    for code, name in MAP.items():
        s = series_for_code(df, cols, code)
        parts[name] = s if s else [None]*len(cols)

    # "Otro" = total - sum(7041..7043) si hay total; si no, suma de 7044.. y listo
    otro = []
    for k in range(len(cols)):
        if tot and all(parts[n][k] is not None for n in MAP.values()):
            s = tot[k]
            if s is None: otro.append(None); continue
            rest = sum(parts[n][k] for n in MAP.values())
            otro.append(s - rest)
        else:
            # intenta sumar 7044..7049
            acc = 0.0; found = False
            for c in [f"704{d}" for d in range(4,10)]:
                s = series_for_code(df, cols, c)
                if s and s[k] is not None:
                    acc += s[k]; found = True
            otro.append(acc if found else None)

    # arma wide
    rows = []
    for i, y in enumerate(ys):
        row = {"Year": int(y)}
        for name in MAP.values():
            row[name] = parts[name][i] if parts[name] else None
        row["Otro"] = otro[i]
        rows.append(row)
    Path(OUT / fname).write_text(json.dumps(rows, ensure_ascii=False), encoding="utf-8")

def main():
    # % del PIB, % del gasto (dentro de Seguridad), y Pesos 2024
    build_subsec("CFEGCT%PIB",   "viz_sp_subsec_pct_pib.json")
    build_subsec("CFEGCT%GT",    "viz_sp_subsec_pct_gt_sp.json")
    build_subsec("CFEGCT$24",    "viz_sp_subsec_pesos22.json")  # lo escribimos con el mismo nombre pero ahora base 2024

if __name__ == "__main__":
    main()
