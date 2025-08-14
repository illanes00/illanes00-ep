# illanes00-ep

Proyecto FastAPI + Flask para EP Datos. Estructura ordenada, entradas claras y variables de entorno documentadas.

## Estructura

- `app/`: paquete de aplicación (API FastAPI, frontend Flask, modelos, esquemas).
- `templates/` y `static/`: assets de frontend usados por Flask/StaticFiles.
- `alembic/`: migraciones de base de datos.
- `analysis/`: notebooks y scripts de análisis (no forman parte del runtime).
- `deploy/`: ejemplos de configuración (systemd, caddy, etc.).
- `asgi.py`: entrypoint ASGI (para `uvicorn` / `gunicorn -k uvicorn.workers.UvicornWorker`).
- `main.py`: alias minimal para `uvicorn main:app` (compatibilidad).

## Requisitos

- Python 3.10+
- Dependencias en `requirements.txt`

## Variables de entorno

Copiar `.env.example` a `.env` y ajustar:

- `SECRET_KEY`: clave para sesiones.
- `DATABASE_URL`: conexión SQLAlchemy (p.ej. `postgresql://user:pass@host/db`).
- `HOST` y `PORT`: bind del servidor local.

## Desarrollo

- Instalar dependencias: `pip install -r requirements.txt`
- Ejecutar en desarrollo:
  - `uvicorn asgi:app --reload --host 127.0.0.1 --port 8000`
  - o `uvicorn main:app --reload` (equivalente)

Swagger UI disponible en `/api-docs`. El frontend Flask se sirve en `/web`.

## Producción (ejemplos)

- Gunicorn (ASGI):
  - `gunicorn -k uvicorn.workers.UvicornWorker -w 2 -b 0.0.0.0:8000 asgi:app`
- Systemd: ver `deploy/systemd.service` como referencia y ajustar ruta/usuario.
- Caddy/Nginx: ver `deploy/caddy.conf` para TLS/reverse proxy.

## Notas de orden

- Evitar archivos generados en el repo (ver `.gitignore`).
- `run.py` y `wsgi_flask_only.py` se mantienen como compatibilidad; preferir `asgi.py`.

