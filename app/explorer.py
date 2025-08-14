from flask import Blueprint, current_app, jsonify, render_template, request, abort, send_from_directory
from pathlib import Path
import pyarrow.parquet as pq

bp = Blueprint("explorer", __name__)

def _root():
    return Path(current_app.config.get("ROOT_DIR", Path(__file__).resolve().parents[1]))

def _safe(base: Path, rel: str) -> Path:
    p = (base / rel).resolve()
    if not str(p).startswith(str(base.resolve())): abort(400)
    return p

@bp.get("/files")
def files_view(): return render_template("explorer.html")

@bp.get("/api/list")
def api_list():
    base=_root()/ "data"; q=request.args.get("path",""); d=_safe(base,q)
    if not d.exists(): abort(404)
    items=[]
    if d.is_dir():
        for f in sorted(d.iterdir(), key=lambda x:(x.is_file(), x.name.lower())):
            if f.name.startswith("."): continue
            items.append({"name":f.name,"is_dir":f.is_dir(),"size":(f.stat().st_size if f.is_file() else None),"rel":str((Path(q)/f.name) if q else f.name)})
    else:
        items.append({"name":d.name,"is_dir":False,"size":d.stat().st_size,"rel":str(q)})
    return jsonify({"cwd":str(q), "items":items})

@bp.get("/api/raw/<path:relpath>")
def api_raw(relpath):
    base=_root()/ "data"; p=_safe(base,relpath)
    if not p.exists(): abort(404)
    return send_from_directory(base, relpath, as_attachment=False)

@bp.get("/api/datasets")
def api_datasets():
    proc=_root()/ "data" / "processed"
    return jsonify(sorted(f.name for f in proc.glob("*.parquet")))

@bp.get("/api/datasets/<path:filename>")
def api_dataset_preview(filename):
    p=(_root()/ "data" / "processed" / filename).resolve()
    if not p.is_file(): abort(404)
    df=pq.read_table(str(p)).to_pandas().head(100)
    return jsonify(df.to_dict(orient="records"))

@bp.get("/api/columns/<path:dataset>")
def api_columns(dataset):
    p=(_root()/ "data" / "processed" / dataset).resolve()
    if not p.is_file(): abort(404)
    t=pq.read_table(str(p), use_threads=True)
    all_cols=[c for c in t.schema.names if not c.startswith("__")]
    prev=t.to_pandas().head(5)
    cols=[c for c in all_cols if c in prev and prev[c].notna().any()]
    return jsonify(cols)

@bp.get("/api/series/<path:dataset>")
def api_series(dataset):
    p=(_root()/ "data" / "processed" / dataset).resolve()
    if not p.is_file(): abort(404)
    vars_=[v for v in request.args.get("vars","").split(",") if v]
    if not vars_: abort(400)
    start=request.args.get("start"); end=request.args.get("end")
    table=pq.ParquetFile(str(p)).read(columns=vars_)
    import pandas as pd
    df=table.to_pandas()[vars_]; x=vars_[0]
    if x.lower() in {"año","anio","year"}:
        df[x]=df[x].astype(int).astype(str); df=df.sort_values(x)
        if start: df=df[df[x].astype(int)>=int(start)]
        if end:   df=df[df[x].astype(int)<=int(end)]
    else:
        df=df.sort_values(x)
        if start and (pd.api.types.is_numeric_dtype(df[x])): df=df[df[x]>=float(start)]
        if end   and (pd.api.types.is_numeric_dtype(df[x])): df=df[df[x]<=float(end)]
    return jsonify({c:df[c].tolist() for c in df.columns})

@bp.get("/viz")
def viz_view():
    proc=_root()/ "data" / "processed"
    files=sorted(f.name for f in proc.glob("*.parquet"))
    return render_template("viz.html", files=files)

@bp.post("/api/agg")
def api_agg():
    """
    body JSON:
      {
        "dataset": "enusc_micro_2024.parquet" | "enusc_micro_08_24.parquet",
        "group": ["ANIO","REGION"],         # variables de agrupación
        "measure": {"var":"VP_DC","stat":"prop"},  # stat: prop|mean|sum|count
        "weight": "Fact_Pers_Reg",          # tomado desde codebook según año/unidad
        "filters": [{"var":"KISH","op":"==","val":1}]
      }
    """
    import pandas as pd, pyarrow.parquet as pq
    body = request.get_json(force=True)
    p = (_root()/ "data"/"processed"/ body["dataset"]).resolve()
    cols = set(sum([body["group"], [body["measure"]["var"], body.get("weight","")]], []))
    t = pq.read_table(str(p), columns=[c for c in cols if c]).to_pandas()

    # filtros
    for flt in body.get("filters", []):
        if flt["op"]=="==": t = t[t[flt["var"]]==flt["val"]]
        elif flt["op"]=="in": t = t[t[flt["var"]].isin(flt["val"])]
        # puedes añadir >=, <=, etc.

    w = body.get("weight")
    if w and w in t:
        t["_w"]=t[w].astype(float)
    else:
        t["_w"]=1.0

    g = t.groupby(body["group"], dropna=False)
    y = body["measure"]["var"]

    stat = body["measure"]["stat"]
    if stat=="prop":    # proporción ponderada de y==1
        num = g.apply(lambda df: (df[y]==1).astype(float).mul(df["_w"]).sum())
        den = g["_w"].sum()
        out = (num/den).reset_index(name="prop")
    elif stat=="mean":
        num = g.apply(lambda df: df[y].astype(float).mul(df["_w"]).sum())
        den = g["_w"].sum()
        out = (num/den).reset_index(name="mean")
    elif stat=="sum":
        out = (g.apply(lambda df: df[y].astype(float).mul(df["_w"]).sum())
                .reset_index(name="sum"))
    else:  # count
        out = g.size().reset_index(name="n")

    return jsonify(out.to_dict(orient="records"))
