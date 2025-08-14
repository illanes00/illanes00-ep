"""ASGI entrypoint: expone `app` para Uvicorn/Gunicorn.

Uso:
  uvicorn asgi:app --reload
  gunicorn -k uvicorn.workers.UvicornWorker asgi:app
"""
from app import app

