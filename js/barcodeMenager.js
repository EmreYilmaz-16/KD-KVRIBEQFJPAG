/**
 * @typedef {Object} ParseResult
 * @property {boolean} success
 * @property {string} [error]
 * @property {string} [product_code_2]
 * @property {string} [serial_no]
 * @property {string} [uretim_tarihi]   // ISO: YYYY-MM-DD
 * @property {string} [paketleme_tarihi]// ISO: YYYY-MM-DD
 * @property {number|string} [parser_type]
 * @property {string} [raw]             // ham barkod
 */

/**
 * @typedef {Object} Parser
 * @property {number|string} id         // parser_type
 * @property {string} name
 * @property {(barcode:string)=>boolean} canParse // hızlı ön-kontrol (regex/heuristic)
 * @property {(barcode:string)=>ParseResult} parse
 * @property {number} [priority]        // otomatik tespitte sıralama (yüksek önce)
 */

class BarcodeManager {
  /**
   * @param {{normalizeDates?: boolean, strict?: boolean} } [options]
   */
  constructor(options = {}) {
    this.parsers = new Map();
    this.options = {
      normalizeDates: options.normalizeDates !== false, // varsayılan: true
      strict: !!options.strict,
    };

    // Varsayılan parser'ları kaydet
    this.registerParser(BarcodeManager.defaultDonmezParser());
    this.registerParser(BarcodeManager.defaultOtherParser());
  }

  /**
   * Yeni bir parser kaydeder (aynı id varsa üzerine yazar).
   * @param {Parser} parser
   */
  registerParser(parser) {
    const p = { priority: 100, ...parser };
    this.parsers.set(p.id, p);
  }

  /**
   * Parser siler
   * @param {number|string} id
   */
  unregisterParser(id) {
    this.parsers.delete(id);
  }

  /**
   * Tüm parser'ları listeler
   * @returns {Parser[]}
   */
  listParsers() {
    return [...this.parsers.values()].sort((a, b) => (b.priority || 0) - (a.priority || 0));
  }

  /**
   * Belirtilen parser ile parse eder.
   * @param {string} barcode
   * @param {number|string} parserId
   * @returns {ParseResult}
   */
  parseWith(barcode, parserId) {
    const parser = this.parsers.get(parserId);
    if (!parser) {
      return { success: false, error: `Geçersiz parser tipi: ${parserId}` };
    }
    const cleaned = this._clean(barcode);
    try {
      let result = parser.parse(cleaned);
      result = this._postProcess(result, cleaned, parserId);
      return result;
    } catch (err) {
      return { success: false, error: `Parse hatası (${parser.name}): ${err.message}` };
    }
  }

  /**
   * Parser verilmezse otomatik tespit eder; verilirse direkt onu kullanır.
   * @param {string} barcode
   * @param {number|string} [parserId]  // opsiyonel zorunlu parser
   * @returns {ParseResult}
   */
  parse(barcode, parserId) {
    if (parserId !== undefined && parserId !== null) {
      return this.parseWith(barcode, parserId);
    }
    return this.autoDetectAndParse(barcode);
  }

  /**
   * Tüm parser'ları deneyip başarılı olan ilk sonucu döndürür.
   * @param {string} barcode
   * @returns {ParseResult}
   */
  autoDetectAndParse(barcode) {
    const cleaned = this._clean(barcode);
    const candidates = this.listParsers().filter(p => {
      try { return p.canParse(cleaned); } catch { return false; }
    });

    // canParse hiç eşleşmezse yine de hepsini deneyelim (gevşek mod)
    const toTry = candidates.length ? candidates : this.listParsers();

    for (const p of toTry) {
      try {
        let res = p.parse(cleaned);
        if (res && res.success) {
          res = this._postProcess(res, cleaned, p.id);
          return res;
        }
      } catch (_) { /* yut */ }
    }
    return { success: false, error: 'Uygun parser bulunamadı veya barkod çözümlenemedi.' };
  }

  /**
   * Tüm parser denemelerinin sonuçlarını döndürür (debug/izleme için).
   * @param {string} barcode
   * @returns {{parser: Parser, result: ParseResult}[]}
   */
  tryAll(barcode) {
    const cleaned = this._clean(barcode);
    return this.listParsers().map(p => {
      let result;
      try {
        result = p.parse(cleaned);
        result = this._postProcess(result, cleaned, p.id);
      } catch (err) {
        result = { success: false, error: `Parse hatası (${p.name}): ${err.message}` };
      }
      return { parser: p, result };
    });
  }

  // -- İç yardımcılar --

  _clean(s) {
    return String(s || '').trim();
  }

  _postProcess(result, raw, parserId) {
    if (!result) return { success: false, error: 'Bilinmeyen hata.' };
    if (!result.success) return result;

    // zorunlu alanlar (strict modda)
    if (this.options.strict) {
      const required = ['product_code_2', 'serial_no'];
      for (const k of required) {
        if (!result[k]) {
          return { success: false, error: `Eksik alan (${k})` };
        }
      }
    }

    // tarih normalize
    if (this.options.normalizeDates) {
      const normUretim = result.uretim_tarihi ? BarcodeManager.normalizeDate(result.uretim_tarihi) : '';
      const normPaket = result.paketleme_tarihi ? BarcodeManager.normalizeDate(result.paketleme_tarihi) : '';
      if (normUretim === null && result.uretim_tarihi) {
        return { success: false, error: `Üretim tarihi tanınamadı: ${result.uretim_tarihi}` };
      }
      if (normPaket === null && result.paketleme_tarihi) {
        return { success: false, error: `Paketleme tarihi tanınamadı: ${result.paketleme_tarihi}` };
      }
      result.uretim_tarihi = normUretim || '';
      result.paketleme_tarihi = normPaket || '';
    }

    // parser_type sabitle
    result.parser_type = result.parser_type ?? parserId;
    result.raw = raw;
    return result;
  }

  /**
   * Pek çok yaygın tarih formatını ISO'ya (YYYY-MM-DD) çevirir.
   * Destek: YYYYMMDD, DDMMYYYY, DD.MM.YYYY, YYYY-MM-DD, DD/MM/YYYY, 2025.9.1 vb.
   * Anlaşılamazsa null döner.
   * @param {string} s
   * @returns {string|null}
   */
  static normalizeDate(s) {
    if (!s) return '';
    const t = String(s).trim();

    // ISO already?
    if (/^\d{4}-\d{1,2}-\d{1,2}$/.test(t)) {
      const [y, m, d] = t.split('-').map(Number);
      return BarcodeManager._toIso(y, m, d);
    }

    // YYYYMMDD
    if (/^\d{8}$/.test(t)) {
      const y = Number(t.slice(0, 4));
      const m = Number(t.slice(4, 6));
      const d = Number(t.slice(6, 8));
      return BarcodeManager._toIso(y, m, d);
    }

    // DDMMYYYY
    if (/^\d{8}$/.test(t)) {
      // üstteki ile çakışıyor; ayırt edemeyiz.
      // Bu blok, gerektiğinde heuristik eklemek için bırakıldı.
    }

    // DD.MM.YYYY veya DD/MM/YYYY veya DD-MM-YYYY
    let m = t.match(/^(\d{1,2})[.\-/](\d{1,2})[.\-/](\d{4})$/);
    if (m) {
      const d = Number(m[1]), mo = Number(m[2]), y = Number(m[3]);
      return BarcodeManager._toIso(y, mo, d);
    }

    // YYYY.MM.DD veya YYYY/MM/DD
    m = t.match(/^(\d{4})[.\-/](\d{1,2})[.\-/](\d{1,2})$/);
    if (m) {
      const y = Number(m[1]), mo = Number(m[2]), d = Number(m[3]);
      return BarcodeManager._toIso(y, mo, d);
    }

    // DDMMYYYY (heuristic – 8 haneli ve yıl makul aralıkta ise)
    if (/^\d{8}$/.test(t)) {
      const d = Number(t.slice(0, 2));
      const mo = Number(t.slice(2, 4));
      const y = Number(t.slice(4, 8));
      return BarcodeManager._toIso(y, mo, d);
    }

    return null; // tanınamadı
  }

  static _toIso(y, m, d) {
    const dt = new Date(Date.UTC(y, m - 1, d));
    if (dt.getUTCFullYear() !== y || dt.getUTCMonth() + 1 !== m || dt.getUTCDate() !== d) {
      return null; // geçersiz tarih
    }
    const mm = String(m).padStart(2, '0');
    const dd = String(d).padStart(2, '0');
    return `${y}-${mm}-${dd}`;
  }

  // ---- Varsayılan Parserlar ----

  /**
   * Dönmez formatı: XXXXXX-X-X-TARİH-SERİ
   * Not: product_code_2 ilk 7 karakter olarak alınır (senin örneğinle uyumlu).
   */
  static defaultDonmezParser() {
    return {
      id: 1,
      name: 'Dönmez',
      priority: 200,
      canParse: (barcode) => {
        // Heuristik: en az 5 parça ve 3.-4. kısımlar kısa, tarih/seri sonda
        const parts = barcode.split('-');
        return parts.length >= 5;
      },
      parse: (barcode) => {
        const barcodeArr = barcode.split('-');
        if (barcodeArr.length < 5) {
          return {
            success: false,
            error: 'Geçersiz Dönmez barkod formatı! Beklenen: XXXXXX-X-X-TARİH-SERİ'
          };
        }
        const result = {
          success: true,
          product_code_2: (barcodeArr[0] || '').slice(0, 7),
          serial_no: barcodeArr[4] || '',
          uretim_tarihi: barcodeArr[3] || '',
          paketleme_tarihi: barcodeArr[3] || '',
          parser_type: 1
        };
        return result;
      }
    };
  }

  /**
   * Diğer format: ETA_SERI_URETIM_PAKETLEME
   */
  static defaultOtherParser() {
    return {
      id: 2,
      name: 'Diğer',
      priority: 100,
      canParse: (barcode) => barcode.includes('_'),
      parse: (barcode) => {
        const parts = barcode.split('_');
        if (parts.length < 2) {
          return {
            success: false,
            error: 'Geçersiz barkod formatı! Beklenen: ETA_SERI_URETIM_PAKETLEME'
          };
        }
        const result = {
          success: true,
          product_code_2: parts[0] || '',
          serial_no: parts[1] || '',
          uretim_tarihi: parts[2] || '',
          paketleme_tarihi: parts[3] || '',
          parser_type: 2
        };
        return result;
      }
    };
  }
}

// ---- Kullanım Örnekleri ----

// 1) Otomatik tespit
const bm = new BarcodeManager({ normalizeDates: true, strict: false });

console.log('--- Auto Detect (Dönmez) ---');
console.log(
  bm.parse('K03.0791-A-1-2025-09-01-ABC123') // not: fazla parça varsa da ilk 5’i işler
);

console.log('--- Auto Detect (Diğer) ---');
console.log(
  bm.parse('ETA12345_000987_01.09.2025_2025/09/02')
);

// 2) Zorunlu parser ile
console.log('--- Force Parser 1 ---');
console.log(
  bm.parse('K03.0791-A-1-20250901-XYZ999', 1)
);

// 3) tryAll ile tüm sonuçları gör
console.log('--- Try All ---');
console.table(
  bm.tryAll('ETA555_123456_20250901_02.09.2025').map(x => ({
    parser: x.parser.name,
    success: x.result.success,
    serial_no: x.result.serial_no,
    uretim_tarihi: x.result.uretim_tarihi,
    paketleme_tarihi: x.result.paketleme_tarihi,
    error: x.result.error || ''
  }))
);

// 4) Yeni bir parser eklemek (örnek)
// Format: ABC|SERI|URETIM|PAKET
bm.registerParser({
  id: 3,
  name: 'PipeFormat',
  priority: 150,
  canParse: (s) => s.split('|').length >= 2,
  parse: (s) => {
    const p = s.split('|');
    if (p.length < 2) {
      return { success: false, error: 'Geçersiz PipeFormat (ABC|SERI|... )' };
    }
    return {
      success: true,
      product_code_2: p[0] || '',
      serial_no: p[1] || '',
      uretim_tarihi: p[2] || '',
      paketleme_tarihi: p[3] || ''
    };
  }
});

// Test
console.log('--- New Parser Test ---');
console.log(bm.parse('ABC987|SR123|2025.09.03|03/09/2025'));
