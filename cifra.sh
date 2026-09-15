#!/bin/sh
# Ricifra il contenuto e riscrive b.js con un payload nuovo.
# Uso: ./cifra.sh sorgente/contenuto.html
# Stampa la chiave nuova: da quel momento i link vecchi non aprono piu la pagina.
set -e
[ -f "$1" ] || { echo "manca il file sorgente" >&2; exit 1; }
node -e '
const crypto = require("crypto"), fs = require("fs");
const testo = fs.readFileSync(process.argv[1]);
const chiave = crypto.randomBytes(32), iv = crypto.randomBytes(12);
const c = crypto.createCipheriv("aes-256-gcm", chiave, iv);
const cifrato = Buffer.concat([c.update(testo), c.final()]);
const payload = Buffer.concat([iv, cifrato, c.getAuthTag()]).toString("base64");
const js = fs.readFileSync("b.js", "utf8").replace(/var PAYLOAD = "[^"]*";/, "var PAYLOAD = \"" + payload + "\";");
fs.writeFileSync("b.js", js);
process.stdout.write(chiave.toString("base64").replace(/\+/g,"-").replace(/\//g,"_").replace(/=+$/,"") + "\n");
' "$1"
