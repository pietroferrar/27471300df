#!/bin/sh
# Ricifra il contenuto, genera una password e un codice nuovi, riscrive b.js.
# Uso: ./cifra.sh sorgente/contenuto.html [password]
# Senza password ne genera una da 100 bit. Le credenziali nuove invalidano
# tutti i link e le password distribuiti prima: e anche il modo per revocare.
set -e
[ -f "$1" ] || { echo "manca il file sorgente" >&2; exit 1; }
node -e '
const crypto = require("crypto"), fs = require("fs");
const ALFABETO = "0123456789ABCDEFGHJKMNPQRSTVWXYZ";
function parola(n) { const b = crypto.randomBytes(n); let s = ""; for (let i = 0; i < n; i++) s += ALFABETO[b[i] % 32]; return s; }
const password = process.argv[2] || [parola(5), parola(5), parola(5), parola(5)].join("-");
const segreto = crypto.randomBytes(32), sale = crypto.randomBytes(16), GIRI = 1000000;
const ikm = crypto.pbkdf2Sync(Buffer.from(password, "utf8"), sale, GIRI, 32, "sha256");
const chiave = Buffer.from(crypto.hkdfSync("sha256", ikm, segreto, Buffer.from("varen/disponibilita/v1", "utf8"), 32));
const iv = crypto.randomBytes(12);
const c = crypto.createCipheriv("aes-256-gcm", chiave, iv);
const cifrato = Buffer.concat([c.update(fs.readFileSync(process.argv[1])), c.final()]);
const payload = Buffer.concat([iv, cifrato, c.getAuthTag()]).toString("base64");
fs.writeFileSync("b.js", fs.readFileSync("b.js.modello", "utf8")
  .replace("__PAYLOAD__", payload).replace("__SALE__", sale.toString("base64")).replace("__GIRI__", String(GIRI)));
const b64url = (b) => b.toString("base64").replace(/\+/g,"-").replace(/\//g,"_").replace(/=+$/,"");
process.stdout.write("password: " + password + "\ncodice:   " + b64url(segreto) + "\n");
' "$1" "$2"
echo "Ora ricalcola gli hash SRI: ./sri.sh"
