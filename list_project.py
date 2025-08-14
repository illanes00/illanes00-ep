#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Genera UN solo archivo de contexto liviano para ChatGPT:
  - Se llama PROJECT_CONTEXT.txt (o usa --out).
  - Primero: TREE sólo con archivos "clave".
  - Luego: PREVIEW de esos archivos (máx 400 líneas cada uno por defecto).
Pensado para repos con /data/ gigante: se excluye por defecto.

"Archivos clave" por defecto: .py, .html, .css, .js, .do, .txt, .md, .env*, .json, .ini, .cfg, .toml, .bnb
Se pueden ajustar con --exts.

Ejemplos:
  python3 list_project.py
  python3 list_project.py --max-lines 400 --out project_context.txt
  python3 list_project.py --exts ".py,.html,.css,.js,.do" --skip-globs "data/**,**/*.parquet"
"""
from __future__ import annotations
import argparse, io, sys, os
from pathlib import Path
from fnmatch import fnmatch

DEFAULT_EXTS = {
    ".py", ".html", ".css", ".js", ".do",
    ".txt", ".md", ".json", ".ini", ".cfg", ".toml", ".bnb",
}
# .env y .env.* siempre se incluyen aunque no tengan extensión
ALWAYS_INCLUDE_ENV = True

SKIP_DIR_NAMES = {
    ".git", ".hg", ".svn", "__pycache__", ".mypy_cache", ".pytest_cache",
    "node_modules", "venv", ".venv", ".cache", ".merge", "_merge",
    "dist", "build", "versions",
    # directorios de datos pesados
    "data",
}
# globs grandes a excluir por defecto (puedes vaciar con --skip-globs "")
DEFAULT_SKIP_GLOBS = [
    "data/**",
    "analysis/data/**",
    "app/tools/data/**",
    "tools/data/**",
    "**/*.parquet", "**/*.csv", "**/*.tsv",
    "**/*.xls", "**/*.xlsx",
    "**/*.sav", "**/*.dta",
    "**/*.pdf", "**/*.zip",
    "static/**/*.png", "static/**/*.jpg", "static/**/*.jpeg", "static/**/*.svg", "static/**/*.webp",
]

BINARY_EXTS = {".png",".jpg",".jpeg",".gif",".pdf",".webp",".ico",".svg",".woff",".woff2",".ttf",".zip",".gz",".parquet",".sav",".dta",".xls",".xlsx",".csv",".tsv"}

def looks_like_env(p: Path) -> bool:
    n = p.name
    return n == ".env" or n.startswith(".env.") or n.endswith(".env") or n.endswith(".env.sample")

def is_binary_by_ext(p: Path) -> bool:
    return p.suffix.lower() in BINARY_EXTS

def parse_exts(exts_arg: str | None) -> set[str]:
    if not exts_arg:
        return set(DEFAULT_EXTS)
    out = set()
    for raw in exts_arg.split(","):
        s = raw.strip()
        if not s:
            continue
        if not s.startswith("."):
            s = "." + s
        out.add(s.lower())
    return out

def should_include(path: Path, include_exts: set[str], only_tree: bool=False) -> bool:
    # incluir .env siempre
    if ALWAYS_INCLUDE_ENV and looks_like_env(path):
        return True
    # extensión
    ext = path.suffix.lower()
    if ext in include_exts:
        return True
    # archivos sin extensión: incluir sólo si parecen config/texto y estamos en TREE (para dar contexto mínimo)
    if only_tree and ext == "":
        names = {"Makefile","Dockerfile",".envrc",".flaskenv",".python-version",".tool-versions"}
        if path.name in names:
            return True
    return False

def walk_relevant(root: Path, include_exts: set[str], skip_dirs: set[str], skip_globs: list[str]) -> list[Path]:
    files: list[Path] = []
    root = root.resolve()
    for cur, dirnames, filenames in os.walk(root):
        # podar directorios por nombre
        dirnames[:] = [d for d in dirnames if d not in skip_dirs]
        # ruta relativa en str para globs
        rel_dir = Path(cur).relative_to(root).as_posix() or "."
        # filtrar por globs de directorios (si matchea, no descendemos)
        kill = set()
        for d in dirnames:
            rel = (Path(rel_dir)/d).as_posix()
            if any(fnmatch(rel, pat) for pat in skip_globs):
                kill.add(d)
        if kill:
            dirnames[:] = [d for d in dirnames if d not in kill]
        # archivos
        for fn in filenames:
            p = Path(cur) / fn
            rel = p.relative_to(root).as_posix()
            if any(fnmatch(rel, pat) for pat in skip_globs):
                continue
            if should_include(p, include_exts, only_tree=False):
                files.append(p)
    files.sort(key=lambda x: x.as_posix().lower())
    return files

def build_tree(root: Path, files: list[Path], include_exts: set[str]) -> str:
    """Árbol sólo con directorios que contienen archivos relevantes (o subdirs con ellos)."""
    rels = [f.relative_to(root) for f in files]
    # Set de dirs que deben aparecer
    show_dirs = {Path(".")}
    for r in rels:
        # sólo mostramos en tree los files de interés (misma regla que previews, pero sin binarios)
        if should_include(root / r, include_exts, only_tree=True):
            parent = r.parent
            while True:
                show_dirs.add(parent if str(parent) else Path("."))
                if parent == Path("."):
                    break
                parent = parent.parent
    # Construir árbol
    lines = [root.name + "/"]
    def list_dir(rel_dir: Path, prefix: str):
        # subdirs visibles
        subs = sorted({d for d in show_dirs if d.parent == rel_dir and d != rel_dir}, key=lambda p: p.name.lower())
        # files visibles directamente en este dir
        files_here = sorted([r for r in rels if r.parent == rel_dir and should_include(root/r, include_exts, only_tree=True)],
                            key=lambda p: p.name.lower())
        entries = [("dir", d) for d in subs] + [("file", f) for f in files_here]
        for i, (kind, entry) in enumerate(entries):
            tee = "└── " if i == len(entries) - 1 else "├── "
            if kind == "dir":
                lines.append(prefix + tee + entry.name + "/")
                list_dir(entry, prefix + ("    " if i == len(entries) - 1 else "│   "))
            else:
                lines.append(prefix + tee + entry.name)
    list_dir(Path("."), "")
    return "\n".join(lines)

def preview(path: Path, max_lines: int) -> list[str]:
    if is_binary_by_ext(path):
        return ["(skipped: binary)"]
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except Exception as e:
        return [f"(no preview: {e})"]
    lines = text.splitlines()
    if len(lines) > max_lines:
        lines = lines[:max_lines] + [f"... (truncated at {max_lines} lines)"]
    return lines

def main():
    ap = argparse.ArgumentParser(description="Dump tree + previews to a single, small TXT for ChatGPT.")
    ap.add_argument("--root", default=None, help="Project root (default: this file's parent)")
    ap.add_argument("--out", default="PROJECT_CONTEXT.txt", help="Output TXT file")
    ap.add_argument("--exts", default=None, help="Comma-separated extensions (e.g. .py,.html,.css,.js,.do)")
    ap.add_argument("--max-lines", type=int, default=400, help="Max lines per file in preview")
    ap.add_argument("--skip-dirs", default=None, help="Comma-separated dir names to skip (in addition to defaults)")
    ap.add_argument("--skip-globs", default=",".join(DEFAULT_SKIP_GLOBS),
                    help="Comma-separated glob patterns to skip (e.g. 'data/**,**/*.parquet')")
    args = ap.parse_args()

    root = Path(args.root).resolve() if args.root else Path(__file__).resolve().parent
    include_exts = parse_exts(args.exts)

    skip_dirs = set(SKIP_DIR_NAMES)
    if args.skip_dirs:
        skip_dirs |= {d.strip() for d in args.skip_dirs.split(",") if d.strip()}
    skip_globs = [g.strip() for g in (args.skip_globs or "").split(",") if g.strip()]

    files = walk_relevant(root, include_exts, skip_dirs, skip_globs)
    tree = build_tree(root, files, include_exts)

    buf = io.StringIO()
    buf.write("# PROJECT TREE (relevant only)\n")
    buf.write(tree + "\n\n")
    buf.write("# FILE PREVIEWS (up to {} lines each)\n\n".format(args.max_lines))

    for f in files:
        rel = f.relative_to(root)
        buf.write(f"===== {rel} =====\n")
        for line in preview(f, args.max_lines):
            buf.write(line.rstrip() + "\n")
        buf.write("\n")

    Path(args.out).write_text(buf.getvalue(), encoding="utf-8")
    print(f"✓ Wrote {args.out}")
    print(f"Files included: {len(files)}")
    print(f"Root: {root}")
    print(f"Skipped dirs: {sorted(skip_dirs)}")
    print(f"Skip globs: {skip_globs}")

if __name__ == "__main__":
    main()
