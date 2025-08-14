from pathlib import Path
import re, csv, json

ROOT = Path(__file__).resolve().parents[2]          # repo root
DO_DIR = ROOT / "analysis" / "old_scripts"

ROWS = []
PAT = re.compile(r"^\s*(Title|Summary):\s*(.+)$", re.I)

for do in DO_DIR.rglob("*.do"):
    title = summ = "—"
    with open(do, encoding="latin1") as f:
        for line in f:
            m = PAT.match(line)
            if not m:
                continue
            if m.group(1).lower() == "title":
                title = m.group(2).strip()
            else:
                summ = m.group(2).strip()
            if title != "—" and summ != "—":
                break
    # Heurística simple para clasificar
    kind = (
        "master"   if "master" in do.name.lower()          else
        "cleaning" if re.search(r"\bclean|update\b", title, re.I) else
        "plot"     if re.search(r"\bgraph|plot|trends\b", title, re.I) else
        "analysis"
    )
    ROWS.append({"path": str(do.relative_to(ROOT)),
                 "title": title,
                 "summary": summ,
                 "kind": kind})

OUT = ROOT / "analysis" / "catalog_do.json"
OUT.write_text(json.dumps(ROWS, ensure_ascii=False, indent=2))
print(f"📄 Catalogo generado en {OUT}")

# opcional CSV legible
with open(OUT.with_suffix(".csv"), "w", newline="", encoding="utf8") as f:
    w = csv.DictWriter(f, fieldnames=ROWS[0].keys())
    w.writeheader(); w.writerows(ROWS)
