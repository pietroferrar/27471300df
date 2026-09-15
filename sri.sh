#!/bin/sh
# Ricalcola gli hash Subresource Integrity dentro index.html e 404.html.
set -e
python3 - <<'PY'
import hashlib, base64, pathlib, re
def sri(f):
    return "sha384-" + base64.b64encode(hashlib.sha384(pathlib.Path(f).read_bytes()).digest()).decode()
hcss, hjs = sri("s.css"), sri("b.js")
for f in ("index.html", "404.html"):
    p = pathlib.Path(f); s = p.read_text()
    s = re.sub(r'(s\.css" integrity=")[^"]*', r'\g<1>'+hcss, s)
    s = re.sub(r'(b\.js" integrity=")[^"]*', r'\g<1>'+hjs, s)
    p.write_text(s)
print("index.html e 404.html aggiornati")
PY
