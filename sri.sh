#!/bin/sh
# Rinomina foglio di stile e script con l'impronta del loro contenuto, poi
# riscrive riferimenti e hash Subresource Integrity in index.html e 404.html.
# Il nome che cambia a ogni build evita che la cache di GitHub serva un file
# vecchio contro un hash nuovo: il browser bloccherebbe il file.
set -e
python3 - <<'PY'
import hashlib, base64, pathlib, re, glob, os

def impronte(dati):
    return (hashlib.sha256(dati).hexdigest()[:8],
            "sha384-" + base64.b64encode(hashlib.sha384(dati).digest()).decode())

sorgenti = {"css": "s.css", "js": "b.js"}
for vecchio in glob.glob("s.*.css") + glob.glob("b.*.js"):
    if vecchio not in sorgenti.values():
        os.remove(vecchio)

nomi = {}
for tipo, base in sorgenti.items():
    dati = pathlib.Path(base).read_bytes()
    corto, sri = impronte(dati)
    nome = ("s.%s.css" if tipo == "css" else "b.%s.js") % corto
    pathlib.Path(nome).write_bytes(dati)
    nomi[tipo] = (nome, sri)

for f in ("index.html", "404.html"):
    p = pathlib.Path(f); s = p.read_text()
    s = re.sub(r'href="s[^"]*\.css" integrity="[^"]*"',
               'href="%s" integrity="%s"' % nomi["css"], s)
    s = re.sub(r'src="b[^"]*\.js" integrity="[^"]*"',
               'src="%s" integrity="%s"' % nomi["js"], s)
    p.write_text(s)

print("foglio di stile:", nomi["css"][0])
print("script:        ", nomi["js"][0])
PY
