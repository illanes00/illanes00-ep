"""
Metadata y configuración de alto nivel para todos los pipelines del proyecto.

Ventajas de concentrarlo aquí
-----------------------------
1. **Trazabilidad completa** · Cada dataset tiene fuente(s), versión y salida procesada.  
2. **Automatización** · Otros scripts pueden recorrer `METADATA` y ejecutar ETL en batch
   (build all, tests, refresco diario, etc.).  
3. **Evitar “paths mágicos”** · Ningún script hard-codea rutas; todo se resuelve desde aquí.  
4. **Documentación viva** · Sirve como catálogo de los datos disponibles que puede leer tu
   app Flask o tus notebooks.  
"""

from pathlib import Path

BASE_DIR = Path(__file__).resolve().parents[1]      # carpeta /ep-seguridad
RAW_DIR  = BASE_DIR / "data" / "raw"
PROC_DIR = BASE_DIR / "data" / "processed"

METADATA = {
    "enusc_16_21": {
        "description": "Limpieza y unificación de ENUSC 2016–2021 (hogar y víctima).",
        "sources": {
            # año : ruta absoluta al .sav original
            2016: RAW_DIR / "ENUSC" / "base-de-datos---enusc-xiii.sav",
            2017: RAW_DIR / "ENUSC" / "base-de-datos---xiv-enusc-2017.sav",
            2018: RAW_DIR / "ENUSC" / "base-de-datos---xv-enusc-2018.sav",
            2019: RAW_DIR / "ENUSC" / "base-de-datos---xvi-enusc-2019-(sav).sav",
            2020: RAW_DIR / "ENUSC" / "base-usuario-17-enusc-2020-sav.sav",
            2021: RAW_DIR / "ENUSC" / "base-usuario-18-enusc-2021-sav05142b868f1445af8f592cf582239857.sav",
        },
        "processed_path": PROC_DIR / "enusc_16_21.parquet",
        # columnas que queremos conservar (el script eliminará el resto)
        "keep_vars": [
            # Identificadores & factores de expansión
            "rph_ID","enc_idr","enc_region","year",
            "Fact_pers","Fact_Hog","Kish","VarStrat","Conglomerado",
            # Socio-demográficos
            "rph_edad","rph_sexo","rph_nivel","working",
            # Percepción & fuentes de info
            "pad","pad_comuna","pad_barrio",
            "info_pais_frst","info_pais_scnd",
            "info_comuna_frst","info_comuna_scnd",
            "future_victimization",
            # Crímenes (experiencia victimal)
            "A1_1_1","B1_1_1","C1_1_1","D1_1_1",
            "E1_1_1","G1_1_1","H1_1_1",
            # Variables agregadas de la ENUSC
            "VA_DC","DEN_AGREG","RVA_DC",
            # Denuncia (estatus, cómo, por qué no)
            # Robo con violencia
            "denuncio_violencia","como_denuncio_violencia","porque_no_denuncio_violencia",
            # Robo por sorpresa
            "denuncio_sorpresa","como_denuncio_sorpresa","porque_no_denuncio_sorpresa",
            # Robo con fuerza en vivienda
            "denuncio_vivienda","como_denuncio_vivienda","porque_no_denuncio_vivienda",
            # Hurto
            "denuncio_hurto","como_denuncio_hurto","porque_no_denuncio_hurto",
            # Lesiones
            "denuncio_lesiones","como_denuncio_lesiones","porque_no_denuncio_lesiones",
            # Robo/hurto de vehículo
            "denuncio_de_vehiculos","como_denuncio_de_vehiculos","porque_no_denuncio_de_vehiculos",
            # Robo/hurto desde vehículo
            "denuncio_desde_vehiculos","como_denuncio_desde_vehiculos","porque_no_denuncio_desde_vehiculos",
        ],
    },
    # << añadir aquí nuevos datasets cuando los migres >>
}

# ── SEGURIDAD PÚBLICA • DIPRES ──────────────────────────────────────────────
METADATA["dipres_sp"] = {
    "description": (
        "Consolidación de la clasificación funcional (COFOG) que publica "
        "DIPRES para Chile y de los ficheros de comparación internacional. "
        "Incluye valores nominales, a pesos 2022, % PIB y % Gasto Total."
    ),
    # excel originales (van en data/raw/Dipres)
    "sources": {
        # — Chile (Dipres) —
        # Presupuestos 2013-2022
        "articles_311931": RAW_DIR / "Dipres" / "articles-311931_doc_xls.xlsx",
        # Presupuestos 2009-2018
        "articles_189249": RAW_DIR / "Dipres" / "articles-189249_doc_xls.xlsx",
        # Comparables internacionales (UE, WB, OCDE, LA…)
        "ue_po_s_pib": RAW_DIR / "UE" / "PO y S PIB.xlsx",
        "ue_po_s_gt": RAW_DIR / "UE" / "PO y S GT.xlsx",
        "wb_gdp_ppp": RAW_DIR / "API_NY.GDP.PCAP.PP.CD_DS2_es_excel_v2_5552700.xls",
        # LatAm COFOG
        "cofog_latam": {
            "arg": RAW_DIR / "Dipres" / "Functional_Expenditures_COFOG PIB Argentina.xlsx",
            "bra": RAW_DIR / "Dipres" / "Functional_Expenditures_COFOG PIB Brasil",
            "cri": RAW_DIR / "Dipres" / "Functional_Expenditures_COFOG PIB Costa Rica",
            "slv": RAW_DIR / "Dipres" / "Functional_Expenditures_COFOG PIB El Salvador",
            "gtm": RAW_DIR / "Dipres" / "Functional_Expenditures_COFOG PIB Guatemala",
        },
        # … añade aquí los csv de OCDE (“DP_LIVE…”) si los necesitas luego
    },
    # salida principal que genera el script:
    "processed_path": PROC_DIR / "dipres_sp.parquet",
    # columnas básicas
    "keep_vars": [
        "Partida", "A", "A1",          # códigos COFOG
        "Year",
        # Indicadores monetarios
        "Pesos_", "Pesos22_", "Pesos22_A",
        # Indicadores relativos
        "PIB_", "PIB_A", "GT_", "GT_A",
    ],
}
# ────────────────────────────────────────────────────────────────────────────

# ── SEGURIDAD PÚBLICA • EJECUCIÓN PRESUPUESTARIA POR INSTITUCIÓN ───────────
METADATA["dipres_exec"] = {
    "description": (
        "Ejecución 4º trimestre de los Programas 3101, 3102, 0901, 0401, "
        "0101, 3301 y 0301 (Carabineros, PDI, SMP, etc.) para 2012-2022.  "
        "Incluye ingresos, aporte fiscal y gastos; luego se normaliza a "
        "pesos 2022, %PIB y %Gasto Total."
    ),
    "sources": {
        "carabineros": RAW_DIR / "Dipres" / "Carabineros",
        "defensoria": RAW_DIR / "Dipres" / "Defensoría Penal Pública",
        "formacion": RAW_DIR / "Dipres" / "Formación y Perfeccionamiento policial",
        "gendarmeria": RAW_DIR / "Dipres" / "Gendarmería",
        "mp": RAW_DIR / "Dipres" / "Ministerio Público",
        "pdi": RAW_DIR / "Dipres" / "PDI",
        "sml": RAW_DIR / "Dipres" / "SML",
        # auxiliares
        "inflacion": RAW_DIR / "IPC General.xlsx",
        "tc_nominal": RAW_DIR / "TC nominal.xlsx",
        "pib_usd": RAW_DIR / "PIB en dolares.xlsx",
        "gasto_total": RAW_DIR / "Dipres" / "Gasto Público",
    },
    "years": list(range(2012, 2023)),
    "processed_path": PROC_DIR / "dipres_exec.parquet",
}
# ────────────────────────────────────────────────────────────────────────────

# ── CEAD • HOMICIDIOS 2016-2022 ─────────────────────────────────────────────
METADATA["cead_homicides"] = {
    "description": (
        "Conteo de homicidios policiales (CEAD) 2016-2022 por región + "
        "tasa por 100 mil hab. Incluye reshape largo y merge con las "
        "proyecciones poblacionales del INE."
    ),
    "sources": {
        "excel_raw": RAW_DIR / "CEAD" /
            "reportesEstadisticos-unidadTerritorial, CEAD homicidios con 2022 año completo.xlsx",
        "proj_pop": PROC_DIR / "ine_projections_16_22.parquet",   # ← ya la creaste antes
    },
    "processed_path": PROC_DIR / "cead_homicides.parquet",
}
# ─────────────────────────────────────────────────────────────────────────────

# ── INE • PROYECCIONES POBLACIONALES 2016-2022 ──────────────────────────────
METADATA["ine_projections"] = {
    "description": (
        "Proyecciones oficiales de población del INE (base 2017) "
        "por región y año. El ETL conserva únicamente 2016-2022 y, "
        "para mantener la serie en 15 regiones, suma la Región XVI "
        "Ñuble dentro de la VIII Biobío."
    ),
    "sources": {
        # CSV entregado por el INE (está en data/raw)
        "raw_csv": RAW_DIR / "ine_estimaciones-y-proyecciones-2002-2035_base-2017_region_base.csv",
    },
    # Salida que genera el script ETL (ver clean_ine_projections.py)
    "processed_path": PROC_DIR / "ine_projections_16_22.parquet",
    # Años que realmente se exportan — puede resultarte útil en los tests
    "years": list(range(2016, 2023)),
    # Columnas finales esperadas
    "keep_vars": ["region", "year", "poblacion"],
}
# ─────────────────────────────────────────────────────────────────────────────

# ── ENUSC • 2008-2021 (hogar Kish = 1) ────────────────────────────────────────
METADATA["enusc_08_21_manual"] = {
    "description": (
        "Harmonización *mínima* de las ENUSC 2008-2021 para variables "
        "comparables con las rondas 2016-2021: identificador de vivienda, "
        "ponderador de hogar 15 regiones, estrato (VarStrat), selector Kish, "
        "nº de victimizaciones del hogar y nº de denuncias. "
        "Se filtra a Kish==1 y se exporta como parquet."
    ),
    # ficheros .sav originales tal como vienen del Ministerio del Interior
    "sources": {
        2008: RAW_DIR / "ENUSC" / "1. ENUSC V Base de Usuario 2008.sav",
        2009: RAW_DIR / "ENUSC" / "2. ENUSC VI Base Usuaro 2009.sav",
        2010: RAW_DIR / "ENUSC" / "3. ENUSC VII Base Usuario 2010.sav",
        2011: RAW_DIR / "ENUSC" / "4. ENUSC VIII Base Usuario 2011.sav",
        2012: RAW_DIR / "ENUSC" / "5. ENUSC IX  Base Usuario 2012.sav",
        2013: RAW_DIR / "ENUSC" / "6. ENUSC X Base Usuario 2013.sav",
        2014: RAW_DIR / "ENUSC" / "7. ENUSC XI Base Usuario 2014.sav",
        # 2015 se omitió; la ronda XII es incompleta y no se procesa
        2016: RAW_DIR / "ENUSC" / "base-de-datos---enusc-xiii.sav",
        2017: RAW_DIR / "ENUSC" / "base-de-datos---xiv-enusc-2017.sav",
        2018: RAW_DIR / "ENUSC" / "base-de-datos---xv-enusc-2018.sav",
        2019: RAW_DIR / "ENUSC" / "base-de-datos---xvi-enusc-2019-(sav).sav",
        2020: RAW_DIR / "ENUSC" / "base-usuario-17-enusc-2020-sav.sav",
        2021: RAW_DIR / "ENUSC" /
            "base-usuario-18-enusc-2021-sav05142b868f1445af8f592cf582239857.sav",
    },
    "years": list(range(2008, 2022)),           # 2008-2021
    "processed_path": PROC_DIR / "enusc_08_21_manual.parquet",
    "keep_vars": [
        "year", "ID_vivienda", "Fact_Hog_15reg_nuevo",
        "VarStrat", "kish",
        "vict_gral_n",          # n° de delitos sufridos por el hogar
        "denuncias_gral_n",     # n° de denuncias realizadas
    ],
}
# ─────────────────────────────────────────────────────────────────────────────

# ── ENUSC • Tendencias 2008-2021 ────────────────────────────────────────────
METADATA["enusc_trends_08_21"] = {
    "description": (
        "Serie anual 2008-2021 con las medias ponderadas (y errores estándar) de: "
        "• percepción de aumento de la delincuencia (PAD), "
        "• victimización individual (vp_dc), "
        "• victimización de hogares (va_dc) y "
        "• revictimización de hogares (rva_dc).  "
        "Calculadas a partir de la base interanual ENUSC y los pesos oficiales."
    ),
    "sources": {
        # coloca el .sav interanual donde ya lo tengas
        "interannual_sav": RAW_DIR / "ENUSC" / "base_interanual_enusc_2008_2021.sav",
    },
    "processed_path": PROC_DIR / "enusc_trends_08_21.parquet",
    "keep_vars": [
        # identificación & weights
        "año", "id_unico", "idr", "varstrat",
        "fact_pers_2019_2021", "fact_hog_2019_2021",
        # métricas
        "pad", "vp_dc", "va_dc", "rva_dc",
        # para cortes demográficos posteriores
        "sexo", "edad",
    ],
}

# ── ENUSC • Limpieza avanzada 2016-2021 ─────────────────────────────────────
METADATA["enusc_clean_16_21"] = {
    "description": (
        "Versión depurada de las encuestas ENUSC 2016-2021 con variables "
        "homologadas entre olas: percepción (PAD), fuentes de información, "
        "victimización/denuncia, sensación de inseguridad, factores de "
        "expansión y grupos sociodemográficos.  Incluye recodificación de "
        "binarias, agregación de edades y columnas faltantes rellenas con NA."
    ),
    "sources": METADATA["enusc_16_21"]["sources"],   # reutilizamos los .sav originales
    "processed_path": PROC_DIR / "enusc_clean_16_21.parquet",
    "depends_on": ["metadata.py", "enusc_clean_16_21.py"],
    "schema": {                       # columnas *garantizadas* tras la limpieza
        "index":   ["rph_id"],
        "time":    ["year"],
        "weights": ["fact_pers", "fact_hog", "kish", "varstrat", "conglomerado"],
        "demo":    ["rph_edad", "rph_sexo", "rph_nivel", "working"],
        "percep":  ["pad", "pad_comuna", "pad_barrio", "future_victimization"],
        "info":    ["info_pais_frst", "info_pais_scnd",
                    "info_comuna_frst", "info_comuna_scnd"],
        "victim":  ["va_dc", "rva_dc"] +                # hogares
                   ["a1_1_1", "b1_1_1", "c1_1_1",       # personas
                    "d1_1_1", "e1_1_1", "g1_1_1", "h1_1_1"],
        "report":  [c for c in METADATA["enusc_16_21"]["keep_vars"]
                    if c.startswith(("denuncio_", "como_denuncio_", "porque_no_denuncio_"))],
        "risk":    ["dk_walk_alone", "dk_house_alone", "dk_waiting_pt"],
        "fear":    [c for c in METADATA["enusc_16_21"]["keep_vars"]
                    if c.startswith("fv_")],
        "trust":   [c for c in METADATA["enusc_16_21"]["keep_vars"]
                    if c.startswith(("p21a", "p21b"))],
    },
}
# ────────────────────────────────────────────────────────────────────────────

# ── DEIS • Defunciones por arma de fuego 2016-2022 ────────────────────────────
METADATA["deis_gunshot_deaths"] = {
    "description": (
        "Defunciones cuyo diagnóstico básico corresponde a disparos de arma de "
        "fuego (códigos seleccionados de `glosa_categoria_diag2`) en las "
        "estadísticas vitales del DEIS para 2016-2022.  Se generan conteos "
        "anuales totales y un recorte hasta el 8-nov de cada año para"
        "comparaciones interanuales."
    ),
    "sources": {
        # CSV original publicado por el MINSAL (descarga 10-nov-2022)
        "deis_csv": RAW_DIR / "DEFUNCIONES_FUENTE_DEIS_2016_2022_10112022.csv",
    },
    # salida principal (incluye columnas: ano, muertes_total, muertes_hasta_8nov)
    "processed_path": PROC_DIR / "deis_gunshot_deaths.parquet",
    # variables mínimas que conserva el ETL antes de colapsar
    "keep_vars": ["ano", "fecha", "glosa_categoria_diag2"],
}
# ───────────────────────────────────────────────────────────────────────────────

# -------------------------------------------------------------------------
# ENUSC 2008-2021  (micro-datos unificados)
# -------------------------------------------------------------------------
ENUSC_ALL_SOURCES = {
    2008: RAW_DIR / "ENUSC" / "1. ENUSC V Base de Usuario 2008.sav",
    2009: RAW_DIR / "ENUSC" / "2. ENUSC VI Base Usuario 2009.sav",
    2010: RAW_DIR / "ENUSC" / "3. ENUSC VII Base Usuario 2010.sav",
    2011: RAW_DIR / "ENUSC" / "4. ENUSC VIII Base Usuario 2011.sav",
    2012: RAW_DIR / "ENUSC" / "5. ENUSC IX  Base Usuario 2012.sav",
    2013: RAW_DIR / "ENUSC" / "6. ENUSC X Base Usuario 2013.sav",
    2014: RAW_DIR / "ENUSC" / "7. ENUSC XI Base Usuario 2014.sav",
    2015: RAW_DIR / "ENUSC" / "8. ENUSC XII Base Usuario 2015.sav", 
    2016: RAW_DIR / "ENUSC" / "base-de-datos---enusc-xiii.sav",
    2017: RAW_DIR / "ENUSC" / "base-de-datos---xiv-enusc-2017.sav",
    2018: RAW_DIR / "ENUSC" / "base-de-datos---xv-enusc-2018.sav",
    2019: RAW_DIR / "ENUSC" / "base-de-datos---xvi-enusc-2019-(sav).sav",
    2020: RAW_DIR / "ENUSC" / "base-usuario-17-enusc-2020-sav.sav",
    2021: RAW_DIR / "ENUSC" / "base-usuario-18-enusc-2021-sav05142b868f1445af8f592cf582239857.sav",
}

METADATA["enusc_all"] = {
    "sources":     ENUSC_ALL_SOURCES,
    # Reutilizamos el mismo super-conjunto de columnas que usabas antes
    "keep_vars":   METADATA["enusc_16_21"]["keep_vars"],
}
