# app/__init__.py
import os
from dotenv import load_dotenv
load_dotenv()   

from fastapi import FastAPI
from fastapi.responses import RedirectResponse
from fastapi.middleware.wsgi import WSGIMiddleware
from starlette.middleware.sessions import SessionMiddleware

from .flask_frontend import flask_app
from .routers.enusc import router as enusc_router
from .auth import router as auth_router



app = FastAPI(title="EP Datos API",
                  docs_url="/api-docs",          # Swagger UI
    redoc_url=None)

# 👉 usa un nombre de cookie que NO choque con Flask
app.add_middleware(
    SessionMiddleware,
    secret_key=os.getenv("SECRET_KEY"),
    session_cookie="ep_api_session"
)

from fastapi.staticfiles import StaticFiles

# asumiendo que tu carpeta static/ está en la raíz del proyecto
app.mount("/static", StaticFiles(directory="static"), name="static")

app.include_router(auth_router, prefix="/auth")
app.include_router(enusc_router)           # /v1/enusc
@app.get("/")
def _root():
    return RedirectResponse("/web")

app.mount("/web", WSGIMiddleware(flask_app))
# landing / dashboard
