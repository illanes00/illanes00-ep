import os, sys, subprocess, importlib, importlib.util
from pathlib import Path

CWD = Path(__file__).resolve().parent
sys.path.insert(0, str(CWD))

# .env opcional
try:
    from dotenv import load_dotenv  # type: ignore
    load_dotenv(CWD / ".env")
except Exception:
    pass

PORT = os.getenv("PORT", "8000")
HOST = os.getenv("HOST", "127.0.0.1")

def exists(modfile):
    p = CWD / modfile
    return p.exists() and importlib.util.spec_from_file_location(modfile.replace(".py",""), p)

# 1) WSGI (wsgi:app)
if exists("wsgi.py"):
    sys.exit(subprocess.call([sys.executable,"-m","gunicorn", f"--bind={HOST}:{PORT}", "wsgi:app"]))

# 2) FastAPI (main:app)
if exists("main.py"):
    try:
        main = importlib.import_module("main")
        if getattr(main, "app", None) is not None:
            sys.exit(subprocess.call([sys.executable,"-m","uvicorn", "main:app", "--host", HOST, "--port", PORT]))
    except Exception:
        pass

# 3) Flask clásico (app:app)
if exists("app.py"):
    try:
        appmod = importlib.import_module("app")
        if getattr(appmod, "app", None) is not None:
            sys.exit(subprocess.call([sys.executable,"-m","gunicorn", f"--bind={HOST}:{PORT}", "app:app"]))
    except Exception:
        pass

# 4) Fallback mínimo con /health
from flask import Flask  # type: ignore
app = Flask(__name__)

@app.get("/health")
def health():
    return {"ok": True}

if __name__ == "__main__":
    app.run(host=HOST, port=int(PORT))
