/* Disponibilita - accesso a due fattori.
   Il contenuto e cifrato con AES-256-GCM. La chiave non e scritta da nessuna parte:
   viene ricostruita nel browser da due segreti indipendenti.
     1. il codice nel frammento dell'URL, che il browser non invia mai al server
     2. la password, che non esce mai dalla pagina
   Chi ha solo il link non apre. Chi ha solo la password non apre. */
(function () {
  "use strict";

  // Nessun incorporamento in cornice: niente clickjacking.
  if (window.top !== window.self) {
    document.documentElement.textContent = "";
    return;
  }

  var PAYLOAD = "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";
  var SALE = "WXjU4H7VOkIIBmHvxffk5A==";
  var GIRI = 1000000;
  var INFO = "varen/disponibilita/v1";
  var INATTIVITA = 15 * 60 * 1000;

  var politica = window.trustedTypes
    ? trustedTypes.createPolicy("varen", { createHTML: function (s) { return s; } })
    : null;

  function byte(b64) {
    var grezzo = atob(b64), out = new Uint8Array(grezzo.length);
    for (var i = 0; i < grezzo.length; i++) out[i] = grezzo.charCodeAt(i);
    return out;
  }

  function daUrl(s) {
    s = s.replace(/-/g, "+").replace(/_/g, "/");
    while (s.length % 4) s += "=";
    return byte(s);
  }

  var cancello = document.getElementById("cancello");
  var modulo = document.getElementById("modulo");
  var campo = document.getElementById("password");
  var bottone = document.getElementById("apri");
  var avviso = document.getElementById("avviso");
  var contenuto = document.getElementById("contenuto");

  var codice = location.hash.replace(/^#/, "").replace(/^k_/, "").trim();
  var segreto = /^[A-Za-z0-9_-]{43}$/.test(codice) ? daUrl(codice) : null;
  var tentativi = 0;
  var occupato = false;

  cancello.hidden = false;
  if (!segreto || !window.crypto || !crypto.subtle) {
    modulo.hidden = true;
    avviso.textContent = "Link non valido. Serve il link completo, il codice dopo il cancelletto compreso.";
    return;
  }
  campo.focus();

  function dice(testo) { avviso.textContent = testo; }

  function chiave(password) {
    var enc = new TextEncoder();
    return crypto.subtle
      .importKey("raw", enc.encode(password), { name: "PBKDF2" }, false, ["deriveBits"])
      .then(function (k) {
        return crypto.subtle.deriveBits(
          { name: "PBKDF2", salt: byte(SALE), iterations: GIRI, hash: "SHA-256" }, k, 256);
      })
      .then(function (bit) {
        return crypto.subtle.importKey("raw", bit, { name: "HKDF" }, false, ["deriveKey"]);
      })
      .then(function (k) {
        return crypto.subtle.deriveKey(
          { name: "HKDF", hash: "SHA-256", salt: segreto, info: enc.encode(INFO) },
          k, { name: "AES-GCM", length: 256 }, false, ["decrypt"]);
      });
  }

  function apri(password) {
    var dati = byte(PAYLOAD);
    return chiave(password).then(function (k) {
      return crypto.subtle.decrypt(
        { name: "AES-GCM", iv: dati.subarray(0, 12), tagLength: 128 }, k, dati.subarray(12));
    });
  }

  function mostra(chiaro) {
    var html = new TextDecoder("utf-8").decode(chiaro);
    contenuto.innerHTML = politica ? politica.createHTML(html) : html;
    contenuto.hidden = false;
    cancello.remove();
    // Il codice sparisce dalla barra degli indirizzi: non resta in cronologia
    // ne nelle schermate condivise. Per riaprire serve di nuovo il link intero.
    history.replaceState(null, "", location.pathname + location.search);
    blocca();
  }

  function blocca() {
    var orologio;
    function riparti() {
      clearTimeout(orologio);
      orologio = setTimeout(function () {
        contenuto.innerHTML = politica ? politica.createHTML("") : "";
        contenuto.hidden = true;
        document.body.appendChild(document.createElement("div")).className = "cancello";
        document.body.lastChild.innerHTML = politica
          ? politica.createHTML("<p>Sessione chiusa per inattivita. Riapri il link.</p>")
          : "<p>Sessione chiusa per inattivita. Riapri il link.</p>";
      }, INATTIVITA);
    }
    ["pointerdown", "keydown", "scroll", "visibilitychange"].forEach(function (e) {
      addEventListener(e, riparti, { passive: true });
    });
    riparti();
  }

  modulo.addEventListener("submit", function (e) {
    e.preventDefault();
    if (occupato) return;
    var password = campo.value;
    if (!password) { dice("Inserisci la password."); return; }

    occupato = true;
    bottone.disabled = true;
    campo.disabled = true;
    dice("Sblocco in corso. Servono un paio di secondi.");

    // Ritardo crescente: rende lenta l'insistenza dal browser.
    var attesa = tentativi === 0 ? 0 : Math.min(8000, 500 * Math.pow(2, tentativi));

    setTimeout(function () {
      apri(password).then(function (chiaro) {
        campo.value = "";
        mostra(chiaro);
      }).catch(function () {
        tentativi++;
        campo.value = "";
        campo.disabled = false;
        bottone.disabled = false;
        occupato = false;
        dice("Password errata.");
        campo.focus();
      });
    }, attesa);
  });
})();
