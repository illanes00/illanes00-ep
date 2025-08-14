import os, re, flask, calendar
from collections import defaultdict
from dotenv import load_dotenv
from markdown import markdown as md_to_html
from bs4 import BeautifulSoup
from datetime import datetime
import json
from sqlalchemy import func
from app.models.whitelist import Whitelist    # ← añadir arriba de la función
from sqlalchemy.orm import selectinload
from flask import (
    Flask, render_template, session, redirect,
    request, jsonify
)
from functools import wraps

from app.db            import SessionLocal, engine, Base
from app.models.enusc  import EnuscInteranual
from app.models.blog   import BlogPost
from app.models.comment import Comment
from app.models.project import Project

from pathlib import Path
DOCS_DIR = Path("docs")   
DOCS_PATH = Path(__file__).resolve().parent.parent / "docs"

load_dotenv(os.path.join(os.path.dirname(__file__), "..", ".env"))

flask_app = Flask(
    __name__,
    template_folder="../templates",
    static_folder="../static",
    static_url_path="/static",
)
flask_app.secret_key = os.getenv("SECRET_KEY")

# ──────────────  utilidades  ──────────────
try:
    Base.metadata.create_all(bind=engine)
except Exception as e:
    print("[WARN] DB init skipped:", e)     # crea tablas al vuelo
flask_app.START_TIME = datetime.utcnow()

def login_required(fn):
    @wraps(fn)
    def wrapper(*a, **kw):
        if not session.get("user"):
            return redirect("/auth/login")
        return fn(*a, **kw)
    return wrapper


# ── Filtros/Helpers Jinja ──────────────────────────────────────────
import re
def link_hashtags(html: str) -> str:
    """Convierte #123 en enlace al post 123 si existe."""
    def repl(m):
        pid = int(m.group(1))
        return f'<a href="/blog/{pid}">#{pid}</a>'
    return re.sub(r"#(\d+)", repl, html)

def md(html_txt: str) -> str:
    """Markdown completo (para detalle)."""
    return md_to_html(html_txt, extensions=["fenced_code", "tables", "toc"])

def md_excerpt(md_txt: str, chars: int = 200) -> str:
    """Convierte a Markdown ▸ strip tags ▸ recorta."""
    raw_html = md(md_txt)
    text = BeautifulSoup(raw_html, "html.parser").get_text(" ", strip=True)
    return text[:chars] + ("…" if len(text) > chars else "")

MONTHS_ES = [
    "", "enero", "febrero", "marzo", "abril", "mayo", "junio",
    "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"
]
def month_es(month_idx: int) -> str:
    return MONTHS_ES[month_idx].capitalize()

flask_app.jinja_env.filters["markdown"]   = md
flask_app.jinja_env.filters["md_excerpt"] = md_excerpt

# ───────────────── BLOG ────────────────────────────────────────────
def _build_toc(html: str):
    """Devuelve HTML con anchors + una lista [{'level':2,'text','anchor'}]."""
    soup = BeautifulSoup(html, "html.parser")
    toc   = []
    for h in soup.find_all(re.compile(r"h[23]")):               # h2 / h3
        anchor = h.get("id") or re.sub(r"\W+", "-", h.text.lower())
        h["id"] = anchor
        toc.append({"level": int(h.name[1]), "text": h.text, "anchor": anchor})
    return str(soup), toc

from collections import OrderedDict

MESES_ES = {
    1:"enero",2:"febrero",3:"marzo",4:"abril",5:"mayo",6:"junio",
    7:"julio",8:"agosto",9:"septiembre",10:"octubre",11:"noviembre",12:"diciembre"
}

@flask_app.route("/blog")
@login_required
def blog_list(tag=None, author=None):
    mes_sel = request.args.get("month")             #   YYYY-MM opcional
    db = SessionLocal()
    q = db.query(BlogPost).order_by(BlogPost.created_at.desc())
    if mes_sel:
        q = q.filter(BlogPost.created_at.like(f"{mes_sel}-%"))
    if tag:    q = q.filter(BlogPost.tag==tag)
    if author: q = q.filter(BlogPost.author_email==author)
    posts = q.all()
    db.close()

    # ───── agrupar posts por mes (orden cronológico descendente) ─────
    agrupado: dict[str,dict] = OrderedDict()
    for p in posts:
        key   = p.created_at.strftime("%Y-%m")      # 2025-06
        label = f"{MESES_ES[p.created_at.month].capitalize()} {p.created_at.year}"
        if key not in agrupado:
            agrupado[key] = {"key":key, "label":label, "items":[]}
        agrupado[key]["items"].append(p)

    months = list(agrupado.values())                # ⇒ lista para el template
    total_posts = len(posts)
    return render_template("blog_list.html",
                        months=months,
                        month_selected=mes_sel,
                        total_posts=total_posts)


@flask_app.route("/blog/<int:post_id>")
@login_required
def blog_detail(post_id):
    db   = SessionLocal()
    post = (db.query(BlogPost)
              .options(selectinload(BlogPost.comments))   # carga eager
              .get(post_id))
    if not post:
        db.close()
        return ("No encontrado", 404)

    html = md(post.content)
    html = link_hashtags(html)
    html, toc = _build_toc(html)

    resp = render_template("blog_detail.html",
                           post=post, html=html, toc=toc)
    db.close()
    return resp


@flask_app.route("/blog/new", methods=["GET", "POST"])
@flask_app.route("/blog/<int:post_id>/edit", methods=["GET", "POST"])
@login_required
def blog_form(post_id=None):
    db   = SessionLocal()
    post = db.get(BlogPost, post_id) if post_id else None

    if request.method == "POST":
        title  = request.form["title"]
        content= request.form["content"]
        tag    = request.form.get("tag")  # ✔
        if post:
           post.title, post.content, post.tag = title, content, tag
        else:
            post = BlogPost(title=title, content=content, tag=tag,
                    author_email=session["user"]["email"])
            db.add(post)
        db.commit()
        pid = post.id
        db.close()
        return redirect(f"/blog/{pid}")

    db.close()
    return render_template("blog_form.html", post=post)


@flask_app.route("/blog/<int:post_id>/delete", methods=["POST"])
@login_required
def blog_delete(post_id):
    db = SessionLocal(); post = db.get(BlogPost, post_id)
    if post:
        db.delete(post); db.commit()
    db.close()
    return redirect("/blog")

# ── AJAX – vistas y likes ─────────────────────────────────────────
@flask_app.post("/blog/<int:post_id>/view")
@login_required
def blog_add_view(post_id):
    db = SessionLocal(); post = db.get(BlogPost, post_id)
    total = 0
    if post:
        post.views += 1
        total = post.views
        db.commit()
    db.close()
    return jsonify({"views": total})


@flask_app.post("/blog/<int:post_id>/like")
@login_required
def blog_add_like(post_id):
    db = SessionLocal(); post = db.get(BlogPost, post_id)
    total = 0
    if post:
        post.likes += 1
        total = post.likes
        db.commit()
    db.close()
    return jsonify({"likes": total})

# ─────────────── DASHBOARD ────────────────────────────────────────
@flask_app.route("/dashboard")
@login_required
def dashboard():
    db = SessionLocal()

    # KPI -------------------------------------------------
    total_enusc  = db.query(EnuscInteranual).count()
    total_posts  = db.query(BlogPost).count()
    total_sets   = 1
    total_comments = db.query(Comment).count()
    projects_total = db.query(Project).count()
    projects_open  = db.query(Project).filter(Project.status != "cerrado").count()

    # series ---------------------------------------------
    serie = (db.query(EnuscInteranual.año,
                      func.sum(EnuscInteranual.rvi))
               .group_by(EnuscInteranual.año)
               .order_by(EnuscInteranual.año)
               .all())

    from sqlalchemy import func
    fmt = (func.strftime("%Y-%m", BlogPost.created_at) if engine.url.get_backend_name().startswith("sqlite") else func.to_char(BlogPost.created_at, "YYYY-MM"))
    serie_posts = (db.query(fmt.label("m"),
                            func.count())
                     .group_by("m")
                     .order_by("m")
                     .all())
    db.close()

    years,  values  = zip(*serie)          if serie       else ([],[])
    months, counts  = zip(*serie_posts)    if serie_posts else ([],[])

    # uptime ---------------------------------------------
    delta  = datetime.utcnow() - flask_app.START_TIME
    h, rem = divmod(int(delta.total_seconds()), 3600); m, s = divmod(rem, 60)
    uptime = f"{h:02d}:{m:02d}:{s:02d}"

    return render_template(
        "dashboard.html",
        kpi = {
            "enusc": total_enusc,
            "posts": total_posts,
            "datasets": total_sets,
            "uptime": uptime,
            "comments": total_comments,
            "projects_total": projects_total,
            "projects_open": projects_open
        },
        chart_data  = {"years": years, "values": values},
        chart_posts = {"months": months, "counts": counts}
    )


# ---------- LANDING & SECCIONES “estáticas” ----------

@flask_app.route("/")
def home():
    """Landing page /index.html"""
    return render_template("index.html")



@flask_app.route("/api")          # link en la navbar
@login_required
def api_docs():
    return render_template("api.html")


@flask_app.route("/logout")
def logout():
    session.clear()
    return redirect("/")

# atajo para el botón “Ingresar con Google” de la navbar
@flask_app.route("/login")
def login_button():
    return redirect("/auth/login")



# ─────────────── DATASETS ──────────────────────────────────────────
import json
from flask import abort

@flask_app.route("/datasets")
@login_required
def datasets():
    """Listado de datasets disponibles."""
    return render_template("datasets.html")

@flask_app.route("/datasets/<string:ds>")
@login_required
def dataset_view(ds: str):
    """Tabla interactiva para un dataset."""
    if ds != "enusc":
        return abort(404)

    # ⚙️ columns → lista de {data,title}
    columns = [
        {"data": "id_unico", "title": "id_unico"},
        {"data": "region", "title": "Región"},
        {"data": "sexo", "title": "Sexo"},
        {"data": "edad", "title": "Edad"},
        {"data": "pad", "title": "PAD"},
        {"data": "rvi", "title": "RVI"},
        {"data": "año", "title": "Año"},
    ]  # muestra inicial, luego puedes agregar más

    return render_template(
        "dataset_table.html",
        ds_name="ENUSC Interanual",
        api_url = "/v1/enusc",      # DataTables lo consumirá
        columns_json = json.dumps(columns)
    )



@flask_app.route("/docs/<string:name>")
@login_required
def docs_page(name):
    md_file = DOCS_DIR / f"{name}.md"
    if not md_file.exists():
        abort(404)
    html = md(md_file.read_text(encoding="utf-8"))
    return render_template("docs_page.html",
                           files=[f.stem for f in DOCS_DIR.glob('*.md')],
                           current=name,
                           html=html)

@flask_app.route("/vis")
@login_required
def vis():
    return render_template("vis.html")

CODEBOOK = json.load(open("data/codebook_enusc.json", encoding="utf-8"))

@flask_app.route("/codebook")
@login_required
def codebook():
    return render_template("codebook.html", rows=CODEBOOK)

@flask_app.route("/docs")
@login_required
def docs():
    files = [p.name for p in sorted(DOCS_DIR.glob("*.md"))]
    return render_template("docs_tabs.html", files=files)

@flask_app.route("/docs/raw/<path:fname>")
@login_required
def docs_raw(fname):
    return flask.send_from_directory(DOCS_PATH, fname)

@flask_app.route("/blog/tag/<string:tag>")
@login_required
def blog_by_tag(tag):
    return blog_list(tag=tag)

@flask_app.route("/blog/author/<path:email>")
@login_required
def blog_by_author(email):
    return blog_list(author=email)


@flask_app.post("/blog/<int:post_id>/comment")
@login_required
def add_comment(post_id):
    txt = request.form.get("content", "").strip()
    if not txt:
        return "Empty", 400
    db = SessionLocal()
    from app.models.comment import Comment
    c = Comment(post_id=post_id, content=txt, author_email=session["user"]["email"])
    db.add(c); db.commit(); db.refresh(c); db.close()
    return render_template("comment_item.html", c=c)

@flask_app.route("/projects")
@login_required
def projects():
    db=SessionLocal()
    from app.models.project import Project
    pro = db.query(Project).order_by(Project.start_date).all(); db.close()
    return render_template("projects.html", projects=pro)

@flask_app.route("/datasets/upload", methods=["GET","POST"])
@login_required
def ds_upload():
    if request.method=="POST":
        f = request.files["file"]
        name = request.form["name"].strip()
        if not (f and name):
            return "Falta nombre o archivo",400
        import pandas as pd, pathlib, os
        path = pathlib.Path("data")/f"{name}.csv"
        f.save(path)
        # TODO: lanzar ETL en background; por ahora solo guardar
        return redirect("/datasets")
    return render_template("dataset_upload.html")

@flask_app.route("/access", methods=["GET","POST"])
@login_required
def access():
    db = SessionLocal()
    if request.method == "POST":
        email = request.form["email"].strip().lower()
        if email:
            db.merge(Whitelist(email=email))
            db.commit()
    wl = db.query(Whitelist).all()
    db.close()
    return render_template("access.html", wl=wl)

# === Explorer/Viz integrado ===
from pathlib import Path as _P
flask_app.config.setdefault("ROOT_DIR", _P(__file__).resolve().parent.parent)
from app.explorer import bp as explorer_bp
flask_app.register_blueprint(explorer_bp)
