# WSGI entrypoint: sirve sólo el frontend Flask.
from app.flask_frontend import flask_app as app
