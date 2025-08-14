
# analysis/scripts/build_exec_from_consolidados.py
from pathlib import Path
import pandas as pd
import re

RAW  = Path("data/raw/Dipres")
CONS = RAW / "Data consolidada"
FORM = RAW / "Formación y Perfeccionamiento policial"
OUTP = Path("data/processed/dipres_exec.parquet")
OUTJ = Path("static/data"); OUTJ.mkdir(parents=True, exist_ok=True)

MAP = {
    "Carabineros_Consolidado.dta": "Carabineros de Chile",
    "PDI_Consolidado.dta": "PDI",
    "Gendarmeria_Consolidado.dta": "Gendarmería",
    "MP_Consolidado.dta": "Ministerio Público",
    "SML_Consolidado.dta": "SML",
    "Defensoria_Consolidado.dta": "Defensoría Penal Pública",
    "Formacion_Consolidado.dta": "Formación y Perfeccionamiento policial",
}

def to_int_year(s):
    try: return int(round(float(s)))
    except: return None

def read_consolidado_meta():
    p = CONS / "Consolidado.dta"
    df = pd.read_stata(p, convert_categoricals=False)
    # normaliza año
    df["Year"] = df["year"].apply(to_int_year)
    # nos quedamos con columnas necesarias por año (1 fila por año)
    keep = ["Year","Inflacion_acumulada","ponderador","Tipodecambionominaldól","PIBmillonesUSDúltimos12","TotalAño"]
    meta = (df[keep]
            .dropna(subset=["Year"])
            .sort_values("Year")
            .drop_duplicates("Year", keep="last"))
    # PIB en pesos corrientes: millones USD * 1e6 * tipo de cambio
    meta["PIB_pesos_corr"] = meta["PIBmillonesUSDúltimos12"] * 1_000_000 * meta["Tipodecambionominaldól"]
    # llevar a 2022 con ponderador
    meta["PIB_2022"] = meta["PIB_pesos_corr"] * meta["ponderador"]
    return meta[["Year","ponderador","PIB_2022"]]

def sum_exec_quarter(df):
    # suma por año la ejecución acumulada al 4° trimestre
    col = "EjecuciónacumuladaalCuartoTr"
    if col not in df.columns:
        raise SystemExit(f"Falta columna {col}")
    df[col] = pd.to_numeric(df[col], errors="coerce")
    g = (df.groupby("Year", as_index=False)[col].sum()
           .rename(columns={col: "Ejec_4T_corr"}))
    return g

def read_inst_dta():
    rows = []
    for fn, nombre in MAP.items():
        p = CONS / fn
        if not p.exists(): 
            print("⚠️ Falta", fn); 
            continue
        df = pd.read_stata(p, convert_categoricals=False)
        # normaliza año
        ycol = "year" if "year" in df.columns else "Year"
        df["Year"] = df[ycol].apply(to_int_year)
        df = df.dropna(subset=["Year"])
        # sumar ejecución 4T
        s = sum_exec_quarter(df)
        s["Tipo"] = nombre
        rows.append(s)
    base = pd.concat(rows, ignore_index=True)
    return base

def read_formacion_csv():
    if not FORM.exists(): 
        return pd.DataFrame(columns=["Year","Tipo","Ejec_4T_corr"])
    rows = []
    files = sorted(FORM.glob("*.csv"))
    # prioriza 4° trimestre si hay varios del mismo año
    by_year = {}
    for p in files:
        m = re.search(r"(20\d{2})", p.name)
        if not m: continue
        y = int(m.group(1))
        label = p.stem.lower()
        prio = 4 if "4" in label or "cuarto" in label else 3 if "3" in label else 2 if "2" in label else 1
        by_year.setdefault(y, (None, -1))
        if prio > by_year[y][1]:
            by_year[y] = (p, prio)
    # parsea con sep=';'
    for y,(p,_) in by_year.items():
        if p is None: continue
        try:
            df = pd.read_csv(p, sep=";")
        except:
            df = pd.read_csv(p)  # por si ya viene bien delimitado
        # busca columna de ejecución acumulada (ideal: cuarto trimestre)
        cand = [c for c in df.columns if re.search(r"(?i)Ejecuci[óo]n.*Cuarto|Ejecuci[óo]n.*4", c)]
        if not cand:
            cand = [c for c in df.columns if re.search(r"(?i)Ejecuci[óo]n.*Trimestre", c)]
        if not cand:
            cand = [c for c in df.columns if re.search(r"(?i)Ejecuci[óo]n|Vigente|Inicial|Monto|Total", c)]
        if not cand:
            val = 0.0
        else:
            vcol = cand[0]
            # normaliza números tipo "1.234.567" o "1.234,56"
            def parse_n(x):
                if pd.isna(x): return 0.0
                s = str(x).strip().replace(".", "").replace(",", ".")
                try: return float(s)
                except: return 0.0
            val = df[vcol].map(parse_n).sum()
        rows.append({"Year": y, "Tipo": "Formación y Perfeccionamiento policial", "Ejec_4T_corr": val})
    return pd.DataFrame(rows)

def main():
    meta = read_consolidado_meta()              # Year, ponderador, PIB_2022
    inst = read_inst_dta()                      # Year, Ejec_4T_corr, Tipo
    form = read_formacion_csv()                 # idem para Formación
    base = pd.concat([inst, form], ignore_index=True)

    # a pesos 2022
    base = base.merge(meta, on="Year", how="left")
    base["Gastos_2022"] = (base["Ejec_4T_corr"] * base["ponderador"]).fillna(0.0)

    # % del gasto en seguridad (suma de instituciones por año)
    tot_seg = base.groupby("Year")["Gastos_2022"].transform("sum")
    base["Gastos_GT"] = base["Gastos_2022"] / tot_seg * 100.0

    # % del PIB (PIB_2022 en los mismos pesos de referencia)
    base["Gastos_PIB"] = base["Gastos_2022"] / base["PIB_2022"] * 100.0

    # orden y persistencia
    keep = ["Year","Tipo","Gastos_2022","Gastos_GT","Gastos_PIB"]
    base = (base[keep].sort_values(["Year","Tipo"]).reset_index(drop=True))

    OUTP.parent.mkdir(parents=True, exist_ok=True)
    base.to_parquet(OUTP, index=False)
    print("✅ dipres_exec.parquet listo:", OUTP, "rango:", int(base["Year"].min()), "–", int(base["Year"].max()))

    # JSONs para el visor
    def pivot_and_dump(col, fname):
        w = base.pivot_table(index="Year", columns="Tipo", values=col, aggfunc="sum").reset_index()
        (OUTJ/fname).write_text(w.to_json(orient="records", force_ascii=False), encoding="utf-8")

    pivot_and_dump("Gastos_PIB", "viz_sp_inst_pct_pib.json")
    pivot_and_dump("Gastos_2022", "viz_sp_inst_pesos22.json")
    pivot_and_dump("Gastos_GT", "viz_sp_inst_pct_gt_sp.json")
    print("✅ JSONs instituciones →", OUTJ)

if __name__ == "__main__":
    main()
