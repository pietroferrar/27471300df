# Pagina di disponibilita, accesso a due fattori

Pagina statica che comunica ai soci di Pietro Ferrara le fasce in cui non e raggiungibile
perche si trova al campus universitario di Fisciano.

Il repository e pubblico perche GitHub Pages lo richiede. Il contenuto no: quello che viene
servito e un blob cifrato che senza le credenziali non dice nulla.

## I due fattori

| Fattore | Dove vive | A cosa serve |
|---|---|---|
| Codice | Nel frammento dell'URL, dopo il `#` | 256 bit di segreto che il browser non invia mai al server |
| Password | Solo nella testa di chi la conosce | 100 bit di entropia, digitata nella pagina |

Servono entrambi. Chi ha solo il link legge "Link non valido". Chi ha solo la password non ha
niente da aprire. Distribuiscili su due canali diversi: il link per iscritto, la password a voce.

## Come si costruisce la chiave

```
ikm    = PBKDF2-SHA256(password, sale, 1.000.000 di giri, 32 byte)
chiave = HKDF-SHA256(ikm, salt = codice del frammento, info = "varen/disponibilita/v1")
testo  = AES-256-GCM(chiave, iv, contenuto)
```

La chiave non e scritta da nessuna parte: nasce nel browser a ogni apertura. Il milione di giri
di PBKDF2 rende costoso ogni tentativo anche a chi si scarica il blob e lavora offline; i 100 bit
della password rendono quella strada comunque impraticabile.

Il tag GCM autentica il contenuto: un file manomesso non si apre invece di aprirsi alterato.

## Le altre difese

- `Content-Security-Policy: default-src 'none'`, con le sole eccezioni per il proprio foglio di
  stile e il proprio script. Niente rete, niente cookie, niente storage, niente form verso
  l'esterno, nessuna dipendenza da terzi.
- `require-trusted-types-for 'script'`: l'unico punto in cui la pagina scrive HTML passa da una
  policy dichiarata, il resto del DOM e chiuso.
- Subresource Integrity con SHA-384 su foglio di stile e script: un file sostituito non viene
  eseguito. Il nome dei due file porta l'impronta del contenuto, cosi la cache di GitHub non puo
  servire una versione vecchia contro un hash nuovo.
- La pagina si rifiuta di stare dentro una cornice: niente clickjacking.
- Dopo lo sblocco il codice sparisce dalla barra degli indirizzi, quindi non resta in cronologia
  ne nelle schermate condivise. Per riaprire serve di nuovo il link intero.
- Dopo quindici minuti di inattivita la pagina si richiude da sola.
- Ritardo crescente sui tentativi sbagliati.
- `404.html` e identico al guscio: ogni percorso inventato si comporta allo stesso modo.
- `robots.txt` e il meta `noindex` tengono fuori i crawler.

## File

| File | Ruolo |
|---|---|
| `index.html` | Guscio: nessun dato oltre al modulo della password |
| `404.html` | Copia del guscio |
| `b.js` | Payload cifrato e logica di sblocco; viene pubblicato come `b.<impronta>.js` |
| `b.js.modello` | Sorgente di `b.js`, senza payload |
| `s.css` | Stile e caratteri Satoshi incorporati; viene pubblicato come `s.<impronta>.css` |
| `cifra.sh` | Ricifra il contenuto e stampa credenziali nuove |
| `sri.sh` | Rinomina i file con l'impronta del contenuto e ricalcola gli hash Subresource Integrity |

## Aggiornare il contenuto o revocare l'accesso

1. Modifica `sorgente/contenuto.html`. La cartella `sorgente/` non e versionata: sta solo sulla
   macchina, insieme alle credenziali in chiaro.
2. `./cifra.sh sorgente/contenuto.html` — stampa password e codice nuovi.
3. `./sri.sh`
4. Commit e push.

Le credenziali nuove invalidano tutte quelle vecchie. Cambiarle e il modo per togliere l'accesso
a chi non deve piu vedere la pagina.

## Cosa la pagina non contiene

Nomi degli insegnamenti, aule, edifici, docenti, matricola, importi, ISEE. Solo i giorni e le
fasce orarie.

## Fonte dei dati

Calendario didattico di ateneo e orario ufficiale del primo semestre pubblicato l'8 settembre
2026, riletto il 9 settembre 2026.
