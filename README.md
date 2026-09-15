# Pagina di disponibilita cifrata

Pagina statica che comunica ai soci di Pietro Ferrara le fasce in cui non e raggiungibile
perche si trova al campus universitario di Fisciano.

Il repository e pubblico perche GitHub Pages lo richiede, ma **il contenuto non lo e**: quello
che viene pubblicato e un blob cifrato. Chi apre l'indirizzo senza il codice legge soltanto
"Codice non valido".

## Come funziona

| File | Ruolo |
|---|---|
| `index.html` | Guscio: nessun dato, nessun testo oltre al messaggio di rifiuto |
| `404.html` | Copia del guscio, cosi ogni percorso inesistente si comporta allo stesso modo |
| `b.js` | Contiene il payload cifrato e lo decifra nel browser |
| `s.css` | Foglio di stile e caratteri Satoshi incorporati; non contiene dati |
| `robots.txt` | Chiede a ogni crawler di stare fuori |

Il contenuto e cifrato con **AES-256-GCM**. La chiave da 256 bit vive nel frammento
dell'URL, la parte dopo il `#`: i browser non la inviano mai al server, quindi non compare nei
log di GitHub, nei proxy aziendali o nei referer. Il tag GCM autentica il testo: una pagina
manomessa non si apre invece di aprirsi alterata.

Senza codice valido la pagina non emette nulla: nessuna richiesta di rete, nessun cookie,
nessuno storage, nessun form. La `Content-Security-Policy` e `default-src 'none'` con le sole
eccezioni necessarie a caricare il proprio foglio di stile e il proprio script.

## Aggiornare il contenuto

1. Modifica `sorgente/contenuto.html` (non versionato: sta solo sulla macchina).
2. Esegui `./cifra.sh sorgente/contenuto.html`. Riscrive il payload dentro `b.js` e stampa una
   chiave nuova.
3. Fai commit e push.

La chiave nuova invalida tutti i link distribuiti prima: e anche il modo per revocare l'accesso
a chi non deve piu vedere la pagina.

## Cosa la pagina non contiene

Nomi degli insegnamenti, aule, edifici, docenti, matricola, importi, ISEE. Solo i giorni e le
fasce orarie.

## Fonte dei dati

Calendario didattico di ateneo e orario ufficiale del primo semestre pubblicato l'8 settembre
2026, riletto il 9 settembre 2026.
