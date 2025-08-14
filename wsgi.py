"""WSGI entrypoint: sólo frontend Flask.

Uso (producción WSGI):
  gunicorn -b 0.0.0.0:8000 wsgi:app
"""
from app.flask_frontend import flask_app as app

