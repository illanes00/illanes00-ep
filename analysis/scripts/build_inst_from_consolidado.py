from pathlib import Path
import pandas as pd, json, unicodedata, re

BASE = Path("data/raw/Dipres/Data consolidada")
EXCEL = Path("data/raw/Dipres/articles-372115_doc_xls.xlsx")
OUT = Path("static/data"); OUT.mkdir(parents=True, exist_ok=True)

INST = ["Carabineros de Chile","PDI","Gendarmería","Ministerio Público","SML","Defensoría Penal Pública","Formación y Perfeccionamiento policial"]

def strip_accents(s:str)->str:
    s = unicodedata.normalize('NFD', s or "")
    s = s.encode('ascii','ignore').decode('ascii')
    s = re.sub(r'[^a-z0-9]+',' ', s.lower()).strip()
    return re.sub(r'\s+',' ', s)

CANON = {
    "carabineros de chile":"Carabineros de Chile",
    "pdi":"PDI","policia de investigaciones":"PDI",
    "gendarmeria":"Gendarmería","gendarmeria de chile":"Gendarmería",
    "ministerio publico":"Ministerio Público",
    "servicio medico legal":"SML","sml":"SML",
    "defensoria penal publica":"Defensoría Penal Pública",
    "formacion y perfeccionamiento policial":"Formación y Perfeccionamiento policial",
    "formacion y perfeccionamiento de carabineros":"Formación y Perfeccionamiento policial",
}

def load_sp_pct_pib():
    x = pd.ExcelFile(EXCEL)
    df = x.parse("CFEGCT%PIB", header=None)
    years=[(j, int(df.iat[5,j])) for j in range(df.shape[1]) if isinstance(df.iat[5,j],(int,float)) and 2000<=df.iat[5,j]<=2100]
    cols=[j for j,_ in years]; ys=[y for _,y in years]
    row=None
    for i in range(df.shape[0]):
        a=str(df.iat[i,0] or ""); b=str(df.iat[i,1] or "")
        if a.startswith("704") or "Seguridad" in b: row=i; break
    if row is None: raise SystemExit("No encontré 704 en CFEGCT%PIB")
    vals=[float(df.iat[row,j]) if isinstance(df.iat[row,j],(int,float)) else None for j in cols]
    sp=pd.DataFrame({"Year":ys,"SP_pct_PIB":vals}).dropna()
    sp["Year"]=sp["Year"].astype(int)
    return sp

def main():
    p = BASE/"Consolidado.dta"
    if not p.exists():
        raise SystemExit(f"No existe {p}")
    df = pd.read_stata(p, convert_categoricals=False)

    if "Tipo" not in df.columns:
        raise SystemExit("No hay columna 'Tipo' en Consolidado.dta")

    ycol = "year" if "year" in df.columns else "Year"
    gcol = next((c for c in ["Gastos","EjecuciónacumuladaalCuartoTr","PresupuestoVigente","PresupuestoInicial"] if c in df.columns), None)
    if gcol is None:
        raise SystemExit(f"No hallé columna de gastos en {p}. Cols: {list(df.columns)}")

    df["Tipo_norm"] = df["Tipo"].astype(str).map(lambda s: CANON.get(strip_accents(s)))
    df = df[df["Tipo_norm"].notna()].copy()

    df["Year"] = pd.to_numeric(df[ycol], errors="coerce").astype("Int64")
    df["G"]    = pd.to_numeric(df[gcol], errors="coerce").fillna(0.0)
    if "ponderador" in df.columns:
        df["G24"] = df["G"] * pd.to_numeric(df["ponderador"], errors="coerce").fillna(1.0)
    else:
        df["G24"] = df["G"]

    agg = df.groupby(["Year","Tipo_norm"], as_index=False)["G24"].sum()
    pesos = agg.pivot(index="Year", columns="Tipo_norm", values="G24").reset_index().sort_values("Year").rename_axis(None, axis=1)

    # ←—— CLAVE: garantiza que existan todas las columnas INST aunque no aparezcan en los datos
    for k in INST:
        if k not in pesos.columns:
            pesos[k] = 0.0
    pesos = pesos[["Year"] + INST].fillna(0.0)

    (OUT/"viz_sp_inst_pesos22.json").write_text(pesos.to_json(orient="records", force_ascii=False), encoding="utf-8")

    tot = pesos[INST].sum(axis=1).replace(0, pd.NA)
    pct_gt = pesos.copy()
    for c in INST:
        pct_gt[c] = (pct_gt[c] / tot) * 100.0
    pct_gt = pct_gt.fillna(0.0)
    (OUT/"viz_sp_inst_pct_gt_sp.json").write_text(pct_gt.to_json(orient="records", force_ascii=False), encoding="utf-8")

    sp = load_sp_pct_pib()
    share = pct_gt.merge(sp, on="Year", how="left")
    for c in INST:
        share[c] = (share[c]/100.0) * share["SP_pct_PIB"]
    pct_pib = share.drop(columns=["SP_pct_PIB"]).fillna(0.0)
    (OUT/"viz_sp_inst_pct_pib.json").write_text(pct_pib.to_json(orient="records", force_ascii=False), encoding="utf-8")

    print("✅ Instituciones listas → static/data")

if __name__ == "__main__":
    main()
