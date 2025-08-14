import os
from dotenv import load_dotenv
from fastapi import APIRouter
from authlib.integrations.starlette_client import OAuth, OAuthError
from starlette.config import Config
from starlette.requests import Request
from starlette.responses import RedirectResponse
from starlette.exceptions import HTTPException

# carga variables de .env (GOOGLE_CLIENT_ID, ALLOWED_DOMAIN…)
load_dotenv()

config = Config(".env")
oauth = OAuth(config)
oauth.register(
    name="google",
    server_metadata_url="https://accounts.google.com/.well-known/openid-configuration",
    client_kwargs={"scope": "openid email profile"},
)

router = APIRouter()

@router.get("/login")
async def login(request: Request):
    redirect_uri = request.url_for("auth")
    return await oauth.google.authorize_redirect(request, redirect_uri)

@router.get("/auth")
async def auth(request: Request):
    try:
        token = await oauth.google.authorize_access_token(request)
    except OAuthError:
        return RedirectResponse("/")
    # Google a veces no devuelve id_token, así que hacemos fallback a userinfo
    if token.get("id_token"):
        user = await oauth.google.parse_id_token(request, token)
    else:
        user = await oauth.google.userinfo(token=token)
    # valida dominio
    if user.get("hd") != os.getenv("ALLOWED_DOMAIN"):
        return RedirectResponse("/")  # fuera 😎
    # guarda en sesión
    request.session["user"] = dict(user)
    return RedirectResponse("/dashboard")

def login_required(req: Request):
    if req.session.get("user") is None:
        raise HTTPException(status_code=401)

# app/auth.py  (añadir)
@router.get("/user")
async def whoami(request: Request):
    return request.session.get("user", {})
