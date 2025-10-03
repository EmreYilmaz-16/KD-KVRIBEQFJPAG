/* BarcodeGenerator.js
 * Üç formatta barkod üretir: Donmez(1), DonmezYeni(3), Diger(2)
 * Seed'li PRNG, kontrol edilebilir alanlar, toplu üretim ve doğrulama içerir.
 */

class BarcodeGenerator {
  /**
   * @param {{
   *   seed?: number,                 // deterministik üretim için
   *   defaultDateRange?: {start: string, end: string}, // ISO "YYYY-MM-DD"
   *   ensureUniqueSerials?: boolean  // true ise aynı çağrı süresince seri'leri benzersizler
   * }} opts
   */
  constructor(opts = {}) {
    this.seed = Number.isFinite(opts.seed) ? opts.seed : Math.floor(Math.random() * 1e9);
    this._state = this.seed;
    this.defaultDateRange = opts.defaultDateRange || { start: "2024-01-01", end: "2026-12-31" };
    this.ensureUniqueSerials = !!opts.ensureUniqueSerials;
    this._serialSet = new Set();
  }

  // --- Basit, hızlı, seed’li PRNG (LCG) ---
  _rand() {
    // Numerical Recipes LCG
    this._state = (1664525 * this._state + 1013904223) % 0x100000000;
    return this._state / 0x100000000;
  }
  _ri(min, max) { // integer [min, max]
    return Math.floor(this._rand() * (max - min + 1)) + min;
  }
  _pick(arr) { return arr[this._ri(0, arr.length - 1)]; }

  // --- Yardımcılar ---
  randomDigits(n) {
    let s = "";
    for (let i = 0; i < n; i++) s += this._ri(0, 9);
    return s;
  }
  randomUpper(n) {
    let s = "";
    for (let i = 0; i < n; i++) s += String.fromCharCode(65 + this._ri(0, 25));
    return s;
  }
  randomAlnum(n) {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    let s = "";
    for (let i = 0; i < n; i++) s += chars[this._ri(0, chars.length - 1)];
    return s;
  }
  randomProductCode7() {
    // Senin örneklerine yakın: K03.0791, K10.04442 gibi
    const k = this._pick(["K", "P", "X", "Y", "Z"]);
    const a = this.randomDigits(2);
    const b = this.randomDigits(this._pick([4, 5]));
    return `${k}${a}.${b}`; // uzunluğu ≥7; Donmez parser ilk 7 karakteri alıyor
  }

  // Tarih seç ve biçimle
  randomDateISO(range = this.defaultDateRange) {
    const start = new Date(range.start + "T00:00:00Z").getTime();
    const end = new Date(range.end + "T00:00:00Z").getTime();
    const ts = this._ri(start, end);
    const d = new Date(ts);
    const y = d.getUTCFullYear();
    const m = String(d.getUTCMonth() + 1).padStart(2, "0");
    const day = String(d.getUTCDate()).padStart(2, "0");
    return `${y}-${m}-${day}`;
  }
  formatDateLikeManager(dateISO) {
    // Manager'ın normalizeDate'inin anlayacağı formatlardan rastgele biri
    const [y, m, d] = dateISO.split("-");
    const formats = [
      `${y}-${m}-${d}`,
      `${y}${m}${d}`,
      `${d}.${m}.${y}`,
      `${d}/${m}/${y}`,
      `${y}/${m}/${d}`,
      `${m}.${y}`,
      `${m}/${y.slice(2)}`
    ];
    return this._pick(formats);
  }

  // Benzersiz seri üretimi (isteğe bağlı)
  _uniqueSerial(baseLen = 6) {
    for (let tries = 0; tries < 10000; tries++) {
      const s = this.randomUpper(2) + this.randomDigits(baseLen);
      if (!this.ensureUniqueSerials || !this._serialSet.has(s)) {
        if (this.ensureUniqueSerials) this._serialSet.add(s);
        return s;
      }
    }
    // fallback
    const s = this.randomUpper(2) + this.randomDigits(baseLen) + this.randomUpper(1);
    if (this.ensureUniqueSerials) this._serialSet.add(s);
    return s;
  }

  // ---- ÜRETİCİLER ----

  /**
   * Dönmez (parser 1): "XXXXXX-X-X-TARİH-SERİ"
   * @param {{
   *   productCode7?: string,  // ilk parça, en az 7 uzun; parser ilk 7'yi alır
   *   part2?: string,         // tek karakter tavsiye (örn: A)
   *   part3?: string,         // tek karakter tavsiye (örn: 1)
   *   date?: string,          // Manager’ın anlayacağı biçimler; verilmezse random
   *   serial?: string,        // verilmezse random
   *   dateRange?: {start:string, end:string}
   * }} o
   */
  generateDonmez(o = {}) {
    const code = o.productCode7 || this.randomProductCode7();
    const p2 = o.part2 || this._pick(["A", "B", "C", "D"]);
    const p3 = o.part3 || String(this._ri(1, 9));
    const dateISO = o.date
      ? o.date
      : this.randomDateISO(o.dateRange || this.defaultDateRange);
    const dateLike = this.formatDateLikeManager(dateISO);
    const serial = o.serial || this._uniqueSerial(6);
    return `${code}-${p2}-${p3}-${dateLike}-${serial}`;
  }

  /**
   * Dönmez Yeni (parser 3):
   * En az 6 parça üretiriz ki parser'ın indexleri tutsun:
   * [0]=codeMain, [1]=codeSub  → product_code_2 = "0 1"
   * [4]=tarih, [5]=seri
   * Arada [2],[3] için kısa parçalar koyuyoruz.
   * @param {{
   *   codeMain?: string,
   *   codeSub?: string,
   *   mid2?: string,
   *   mid3?: string,
   *   date?: string,
   *   serial?: string,
   *   dateRange?: {start:string, end:string}
   * }} o
   */
  generateDonmezYeni(o = {}) {
    const codeMain = o.codeMain || this.randomProductCode7();
    const codeSub = o.codeSub || this.randomUpper(1) + this.randomDigits(1); // örn: A1
    const mid2 = o.mid2 || this._pick(["X", "Y", "Z"]);
    const mid3 = o.mid3 || String(this._ri(10, 99));
    const dateISO = o.date
      ? o.date
      : this.randomDateISO(o.dateRange || this.defaultDateRange);
    const dateLike = this.formatDateLikeManager(dateISO);
    const serial = o.serial || this._uniqueSerial(7);
    // 6 parça:
    // 0: codeMain, 1: codeSub, 2: mid2, 3: mid3, 4: tarih, 5: seri
    return `${codeMain}-${codeSub}-${mid2}-${mid3}-${dateLike}-${serial}`;
  }

  /**
   * Diğer (parser 2): "ETA_SERI_URETIM_PAKETLEME" (alt çizgi)
   * @param {{
   *   eta?: string,               // ürün/ETA
   *   serial?: string,
   *   uretim?: string,            // Manager-friendly tarih
   *   paketleme?: string,         // Manager-friendly tarih
   *   dateRange?: {start:string, end:string}
   * }} o
   */
  generateDiger(o = {}) {
    const eta = o.eta || `ETA${this.randomDigits(5)}`;
    const serial = o.serial || this._uniqueSerial(6);
    const range = o.dateRange || this.defaultDateRange;
    const uISO = o.uretim || this.randomDateISO(range);
    const pISO = o.paketleme || this.randomDateISO(range);
    const u = this.formatDateLikeManager(uISO);
    const p = this.formatDateLikeManager(pISO);
    return `${eta}_${serial}_${u}_${p}`;
  }

  /**
   * Tür’e göre üret
   * @param {1|2|3|'donmez'|'diger'|'donmezYeni'} type
   * @param {object} options
   * @returns {string}
   */
  generate(type, options = {}) {
    const t = String(type).toLowerCase();
    if (t === "1" || t === "donmez") return this.generateDonmez(options);
    if (t === "3" || t === "donmezyeni" || t === "dönmezyeni") return this.generateDonmezYeni(options);
    if (t === "2" || t === "diger" || t === "diğer") return this.generateDiger(options);
    throw new Error(`Bilinmeyen tür: ${type}`);
  }

  /**
   * Karışık toplu üretim
   * @param {number} count
   * @param {{
   *   weights?: {donmez?: number, donmezYeni?: number, diger?: number},
   *   perTypeOptions?: {donmez?:object, donmezYeni?:object, diger?:object}
   * }} cfg
   * @returns {string[]}
   */
  bulk(count, cfg = {}) {
    const w = Object.assign({ donmez: 2, donmezYeni: 1, diger: 1 }, cfg.weights || {});
    const bag = [
      ...Array(w.donmez).fill("donmez"),
      ...Array(w.donmezYeni).fill("donmezYeni"),
      ...Array(w.diger).fill("diger"),
    ];
    const res = [];
    for (let i = 0; i < count; i++) {
      const type = this._pick(bag);
      const opt = (cfg.perTypeOptions && cfg.perTypeOptions[type]) || {};
      res.push(this.generate(type, opt));
    }
    return res;
  }

  /**
   * Üret + BarcodeManager ile doğrula (parse et)
   * @param {BarcodeManager} bm
   * @param {1|2|3|'donmez'|'diger'|'donmezYeni'} type
   * @param {object} options
   * @returns {{barcode:string, parse: ParseResult}}
   */
  generateAndParse(bm, type, options = {}) {
    const code = this.generate(type, options);
    const parsed = bm.parse(code);
    return { barcode: code, parse: parsed };
  }
}

/* ---------- Kullanım Örnekleri ----------

import { BarcodeManager } from './BarcodeManager.js';
// veya mevcut sınıfın tanımlı olduğu dosyadan içe al

const bm = new BarcodeManager({ normalizeDates: true, strict: false });

// Deterministik sonuçlar için seed verilebilir:
const gen = new BarcodeGenerator({ seed: 42, ensureUniqueSerials: true });

// Tekil üretimler:
const b1 = gen.generate('donmez');         // "K03.0791-A-1-2025-09-01-ABC123" benzeri
const b2 = gen.generate('donmezYeni');     // 6 parçalı yeni Dönmez
const b3 = gen.generate('diger');          // "ETA12345_SR123_URETIM_PAKET"

// Özelleştirme:
const b4 = gen.generate('donmez', {
  productCode7: 'K10.04442',
  part2: 'B',
  part3: '2',
  date: '20250901',    // manager normalize edecek
  serial: 'DN123456'
});

// Toplu:
const set = gen.bulk(10, {
  weights: { donmez: 3, donmezYeni: 1, diger: 2 },
});

// Üret + Parse sonucu:
const { barcode, parse } = gen.generateAndParse(bm, 'donmezYeni');
console.log(barcode, parse);

----------------------------------------- */

export { BarcodeGenerator };
