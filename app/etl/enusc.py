import csv
from sqlalchemy.orm import Session
from datetime import datetime
from app.db import SessionLocal, engine, Base
from app.models.enusc import EnuscInteranual

Base.metadata.create_all(bind=engine)

def run_etl(path_csv: str = "data/enusc_interanual_raw.csv"):
    db: Session = SessionLocal()
    with open(path_csv, encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f, delimiter=";")
        for row in reader:
            obj = EnuscInteranual(
                id_unico            = int(row["id_unico"]) if row["id_unico"].strip() else None,
                idr                 = int(row["idr"]) if row["idr"].strip() else None,
                region              = int(row["region"]) if row["region"].strip() else None,
                region16            = int(row["region16"]) if row["region16"].strip() else None,
                sexo                = int(row["sexo"]) if row["sexo"].strip() else None,
                edad                = int(row["edad"]) if row["edad"].strip() else None,
                pad                 = int(row["pad"]) if row["pad"].strip() else None,
                padb                = int(row["padb"]) if row["padb"].strip() else None,
                ped                 = int(row["ped"]) if row["ped"].strip() else None,
                rvi                 = int(row["rvi"]) if row["rvi"].strip() else None,
                rps                 = int(row["rps"]) if row["rps"].strip() else None,
                rfv                 = int(row["rfv"]) if row["rfv"].strip() else None,
                hur                 = int(row["hur"]) if row["hur"].strip() else None,
                les                 = int(row["les"]) if row["les"].strip() else None,
                prop_vehiculos      = int(row["prop_vehiculos"]) if row["prop_vehiculos"].strip() else None,
                rdv                 = int(row["rdv"]) if row["rdv"].strip() else None,
                rddv                = int(row["rddv"]) if row["rddv"].strip() else None,
                va_dc               = int(row["va_dc"]) if row["va_dc"].strip() else None,
                vp_dc               = int(row["vp_dc"]) if row["vp_dc"].strip() else None,
                rva_dc              = int(row["rva_dc"]) if row["rva_dc"].strip() else None,
                fact_pers_2008_2019 = float(row["fact_pers_2008_2019"].replace(",", ".")) if row["fact_pers_2008_2019"].strip() else None,
                fact_hog_2008_2019  = float(row["fact_hog_2008_2019"].replace(",", ".")) if row["fact_hog_2008_2019"].strip() else None,
                varstrat            = int(row["varstrat"]) if row["varstrat"].strip() else None,
                conglomerado        = int(row["conglomerado"]) if row["conglomerado"].strip() else None,
                año                 = int(row["año"]) if row["año"].strip() else None,
                fact_pers_2019_2022 = float(row["fact_pers_2019_2022"].replace(",", ".")) if row["fact_pers_2019_2022"].strip() else None,
                fact_hog_2019_2022  = float(row["fact_hog_2019_2022"].replace(",", ".")) if row["fact_hog_2019_2022"].strip() else None,
            )
            db.add(obj)
    db.commit()
    db.close()

if __name__ == "__main__":
    run_etl()
