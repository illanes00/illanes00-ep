#!/usr/bin/env python
"""
Normaliza nombres de archivos en data/raw y actualiza metadata.py
uso:
    python analysis/scripts/rename_raw.py --dry-run
    python analysis/scripts/rename_raw.py --apply
"""
import re, json, argparse, textwrap
from pathlib import Path
import unicodedata as ud
import shutil, sys

ROOT = Path(__file__).resolve().parents[2]      # /ep-seguridad
RAW  = ROOT / "data" / "raw"
META = ROOT / "analysis" / "metadata.py"

def slugify(s: str) -> str:
    # ≈ “Functional_Expenditures_COFOG PIB Argentina.xlsx” → functional_expenditures_cofog_pib_argentina.xlsx
    s = ud.normalize("NFKD", s).encode("ascii","ignore").decode().lower()
    s = re.sub(r"[^\w\s.-]", " ", s)             # quita signos raros
    s = re.sub(r"\s+", "_",  s)                  # espacios → _
    s = s.replace(",", "")                       # sin comas
    return s

def collect_files():
    return [p for p in RAW.rglob("*") if p.is_file()]

def build_plan():
    plan = {}
    for p in collect_files():
        target = p.with_name(slugify(p.name))
        if target != p:
            plan[str(p)] = str(target)
    return plan

def apply(plan, dry=True):
    for old,new in plan.items():
        old_p, new_p = Path(old), Path(new)
        if dry:
            print(f"[DRY] {old_p.relative_to(RAW)}  →  {new_p.relative_to(RAW)}")
        else:
            new_p.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(old, new)
    if not dry:
        print("✔ Renombrados:", len(plan))

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply", action="store_true", help="realiza los cambios")
    ap.add_argument("--plan",  type=Path, help="exporta plan a json")
    args = ap.parse_args()

    plan = build_plan()
    if args.plan:
        with open(args.plan,"w") as fh: json.dump(plan, fh, indent=2)
        print("Plan guardado en", args.plan)

    apply(plan, dry=not args.apply)

if __name__ == "__main__":
    main()
