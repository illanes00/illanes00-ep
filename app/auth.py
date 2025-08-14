# app/auth.py
import os, json, hashlib
from dotenv import load_dotenv
from fastapi import APIRouter
from authlib.integrations.starlette_client import OAuth, OAuthError
from starlette.config import Config
from starlette.requests import Request
from starlette.responses import RedirectResponse
from flask import Flask
from flask.sessions import SecureCookieSessionInterface
from app.models.whitelist import Whitelist
from app.db import SessionLocal


load_dotenv()
SECRET_KEY       = os.getenv("SECRET_KEY")
ALLOWED_DOMAIN   = os.getenv("ALLOWED_DOMAIN")
GOOGLE_CLIENT_ID = os.getenv("GOOGLE_CLIENT_ID")
GOOGLE_CLIENT_SECRET = os.getenv("GOOGLE_CLIENT_SECRET")

# --- Authlib / Google ---
config = Config(".env")
oauth = OAuth(config)
oauth.register(
    name="google",
    client_id=GOOGLE_CLIENT_ID,
    client_secret=GOOGLE_CLIENT_SECRET,
    server_metadata_url="https://accounts.google.com/.well-known/openid-configuration",
    client_kwargs={"scope": "openid email profile"},
)

router = APIRouter()
db = SessionLocal()          # ➊

@router.get("/login")
async def login(request: Request):
    return await oauth.google.authorize_redirect(
        request,
        request.url_for("auth")
    )

@router.get("/auth")
async def auth(request: Request):
    # 1) Intercambio code ➜ token
    try:
        token = await oauth.google.authorize_access_token(request)
    except OAuthError:
        return RedirectResponse("/")

    # 2) Siempre pedimos /userinfo  (sin parse_id_token)
    user = await oauth.google.userinfo(token=token)

    # 3) Valida dominio
    allowed = user.get("hd")==ALLOWED_DOMAIN or db.query(Whitelist).get(user["email"])
    if not allowed:
        return RedirectResponse("/")

    # ------------   COOKIE PARA FASTAPI  -----------------
    request.session["user"] = dict(user)       # usa ep_api_session

    # ------------   COOKIE PARA FLASK  -------------------
    #   Creamos un 'app' temporal sólo para firmar la cookie
    tmp_app = Flask(__name__)
    tmp_app.secret_key = SECRET_KEY
    signer = SecureCookieSessionInterface().get_signing_serializer(tmp_app)

    flask_cookie_value = signer.dumps({"user": dict(user)})

    # 4) Redirige con ambas cookies
    response = RedirectResponse("/dashboard")
    # Cookie para Flask
    response.set_cookie(
        "session",
        flask_cookie_value,
        httponly=True,
        secure=True,
        samesite="lax"
    )
    # (la cookie ep_api_session la añadirá SessionMiddleware solo)

    return response

# app/auth.py  (al final)
@router.get("/user")
async def whoami(request: Request):
    """Devuelve {} si no hay sesión; evita 401 para el fetch de la navbar."""
    return request.session.get("user", {})
