from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db import SessionLocal
from app.models.enusc import EnuscInteranual
from app.schemas.enusc import EnuscOut
from fastapi import APIRouter, Depends
from fastapi.responses import Response, StreamingResponse   

router = APIRouter(prefix="/v1/enusc", tags=["ENUSC"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# app/routers/enusc.py  🔄

@router.get("/")
@router.get("") 
def list_enusc(
    skip:int=0, limit:int=100,
    region:int|None=None, año:int|None=None,
    human:int=0,                      # ← ***
    db: Session = Depends(get_db)
):
    q = db.query(EnuscInteranual)
    if region: q = q.filter(EnuscInteranual.region==region)
    if año:    q = q.filter(EnuscInteranual.año==año)
    rows = q.offset(skip).limit(limit).all()

    if human:
        from app.codebook import humanize
        return [humanize(r.__dict__) for r in rows]

    return rows

# app/routers/enusc.py  (nueva ruta)
@router.get("/download/{fmt}")
def dl(fmt:str, db: Session = Depends(get_db)):
    import pandas as pd, io, pyreadstat
    df = pd.read_sql("SELECT * FROM enusc_interanual LIMIT 50000", db.bind)
    if fmt=="csv":
        buf = io.StringIO(); df.to_csv(buf,index=False); mime="text/csv"
        return Response(buf.getvalue(),media_type=mime,
                        headers={"Content-Disposition":"attachment;filename=enusc.csv"})
    if fmt=="excel":
        buf = io.BytesIO(); df.to_excel(buf,index=False); mime="application/vnd.ms-excel"
    if fmt=="stata":
        buf = io.BytesIO(); pyreadstat.write_dta(df, buf); mime="application/x-stata"
    if fmt=="rdata":
        buf = io.BytesIO(); import pyreadr; pyreadr.write_rdata(buf, {"data":df}); mime="application/octet-stream"
    buf.seek(0)
    return StreamingResponse(buf, media_type=mime,
        headers={"Content-Disposition":f"attachment;filename=enusc.{fmt}"})


