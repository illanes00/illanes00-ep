from pydantic import BaseModel

class EnuscOut(BaseModel):
    id_unico: int
    idr: int
    region: int
    region16: int | None
    sexo: int
    edad: int
    pad: int
    padb: int
    ped: int
    rvi: int
    rps: int
    rfv: int
    hur: int
    les: int
    prop_vehiculos: int
    rdv: int
    rddv: int
    va_dc: int
    vp_dc: int
    rva_dc: int
    fact_pers_2008_2019: float
    fact_hog_2008_2019: float
    varstrat: int
    conglomerado: int
    año: int
    fact_pers_2019_2022: float
    fact_hog_2019_2022: float

    class Config:
        orm_mode = True
