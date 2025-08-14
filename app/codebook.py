# app/codebook.py
#  Diccionario compacto → etiqueta legible
REGION = {
    1:"Tarapacá", 2:"Antofagasta", 3:"Atacama", 4:"Coquimbo",
    5:"Valparaíso", 6:"O’Higgins", 7:"Maule", 8:"Biobío",
    9:"La Araucanía", 10:"Los Lagos", 11:"Aysén",
    12:"Magallanes", 13:"Metropolitana", 14:"Los Ríos",
    15:"Arica-Parinacota", 16:"Ñuble"
}
SEXO = {1:"Hombre", 2:"Mujer"}
EDAD = {
    0:"<15", 1:"15-19", 2:"20-24", 3:"25-29", 4:"30-39",
    5:"40-49", 6:"50-59", 7:"60-69", 8:"70-79", 9:"80-89", 10:"90+"
}
BIN = {0:"No", 1:"Sí"}               # para todas las dummies 0/1

def humanize(row: dict) -> dict:
    """Reemplaza códigos por etiquetas legibles en un registro ENUSC."""
    r = dict(row)                       # copia
    r["region"] = REGION.get(r["region"], r["region"])
    r["sexo"]   = SEXO.get(r["sexo"], r["sexo"])
    r["edad"]   = EDAD.get(r["edad"], r["edad"])
    for k,v in r.items():
        if k in {"pad","padb","ped","rvi","rps","rfv","hur","les",
                 "prop_vehiculos","rdv","rddv","va_dc","vp_dc","rva_dc"}:
            r[k] = BIN.get(v, v)
    return r
