# analysis/scripts/inventory_raw.py
import argparse, sys, csv
from pathlib import Path
sys.path.append(str(Path(__file__).parents[1]))
from analysis.metadata import RAW_DIR, METADATA

# ───────────────── helpers ──────────────────────────────────────────────────
def flatten(src):
    for v in src.values():
        if isinstance(v, dict):
            yield from flatten(v)
        else:
            yield Path(v).expanduser().resolve()

def collect():
    referenced = set()
    for meta in METADATA.values():
        referenced |= set(flatten(meta["sources"]))
    found = {p.resolve() for p in RAW_DIR.rglob("*") if p.is_file()}
    return {
        "match":   sorted(found & referenced),
        "missing": sorted(referenced - found),
        "orphan":  sorted(found - referenced),
    }

def to_txt(rows, dest):
    dest.parent.mkdir(parents=True, exist_ok=True)
    with open(dest, "w", encoding="utf-8") as fh:
        for p in rows:
            fh.write(str(p) + "\n")

# ───────────────── cli ──────────────────────────────────────────────────────
ap = argparse.ArgumentParser()
ap.add_argument("--list", choices=["match","missing","orphan"],
                help="imprime la lista elegida")
ap.add_argument("--out",  type=Path,
                help="carpeta donde guardar el .txt (opcional)")
ap.add_argument("--sort", choices=["alpha","size"], default="alpha",
                help="criterio de orden (alpha|size)")
args = ap.parse_args()

res = collect()

# orden opcional por tamaño de archivo
if args.sort == "size":
    for k,v in res.items():
        res[k] = sorted(v, key=lambda p: p.stat().st_size if p.exists() else 0)

# banner resumen (siempre)
print(f"✔ MATCH   : {len(res['match']):>4}")
print(f"❓ ORPHAN  : {len(res['orphan']):>4}")
print(f"✖ MISSING : {len(res['missing']):>4}")

if args.list:
    print(f"\n── {args.list.upper()} ──")
    for p in res[args.list]:
        print(p.relative_to(Path.cwd()))
    # exportar
    if args.out:
        dest = (args.out / f"{args.list}.txt").resolve()
        to_txt(res[args.list], dest)
        print(f"\n➡  Guardado en {dest}")
