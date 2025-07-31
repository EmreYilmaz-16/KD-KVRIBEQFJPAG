// BarcodeManager Sınıfı
class BarcodeManager {
    constructor() {
        // Firma bazlı barkod formatları konfigürasyonu
        this.config = {
            // Firma 1
            firma1: {
                separator: "_",
                fields: [
                    { name: "urunKodu", index: 0 },
                    { name: "seriNo", index: 1 },
                    { name: "uretimTarihi", index: 2 },
                    { name: "paketlemeTarihi", index: 3 },
                    { name: "barkod", index: 4 },
                    { name: "miktar", index: 5 },
                    { name: "marka", index: 6 }
                ]
            },
            
            // Firma 2
            firma2: {
                separator: "_",
                fields: [
                    { name: "urunKodu", index: 0 },
                    { name: "seriNo", index: 1 },
                    { name: "uretimTarihi", index: 2 },
                    { name: "paketlemeTarihi", index: 3 },
                    { name: "barkod", index: 4 },
                    { name: "miktar", index: 5 }
                ]
            },
            
            // Firma 3
            firma3: {
                separator: "-",
                fields: [
                    { name: "urunKodu", index: 0 },
                    { name: "miktar", index: 1 },
                    { name: "bos", index: 2 },
                    { name: "uretimTarihi", index: 3 },
                    { name: "seriNo", index: 4 }
                ]
            }
        };
    }

    // Ana parser fonksiyonu
    parseBarcode(data, companyKey) {
        if (!data || !companyKey || !this.config[companyKey]) {
            return {
                error: 'Geçersiz firma anahtarı veya barkod verisi',
                rawData: data
            };
        }
        
        return this._parseBarcodeByConfig(data, this.config[companyKey]);
    }

    // İç parser fonksiyonu
    _parseBarcodeByConfig(data, config) {
        if (!data || !config) return null;
        
        const parts = data.split(config.separator);
        const result = {
            rawData: data
        };
        
        // Field'ları parse et
        config.fields.forEach(field => {
            result[field.name] = parts[field.index] || '';
        });
        
        // Tarih formatlaması yap
        result.uretimTarihi = this._formatDate(result.uretimTarihi);
        result.paketlemeTarihi = this._formatDate(result.paketlemeTarihi);
        
        return result;
    }

    // Tarih formatlama fonksiyonu
    _formatDate(dateString) {
        if (!dateString || dateString.trim() === '') {
            return null;
        }
        
        dateString = dateString.trim();
        
        try {
            // MM/YY formatı (02/25 gibi)
            if (dateString.includes('/') && dateString.length <= 5) {
                const parts = dateString.split('/');
                if (parts.length === 2) {
                    const month = parts[0].padStart(2, '0');
                    let year = parts[1];
                    
                    if (year.length === 2) {
                        const currentYear = new Date().getFullYear();
                        const currentCentury = Math.floor(currentYear / 100) * 100;
                        const yearNum = parseInt(year);
                        year = yearNum > 50 ? (currentCentury - 100 + yearNum) : (currentCentury + yearNum);
                    }
                    
                    return new Date(year, parseInt(month) - 1, 1);
                }
            }
            
            // DDMMYYYY formatı (05092025 gibi)
            if (dateString.length === 8 && /^\d{8}$/.test(dateString)) {
                const day = dateString.substring(0, 2);
                const month = dateString.substring(2, 4);
                const year = dateString.substring(4, 8);
                return new Date(parseInt(year), parseInt(month) - 1, parseInt(day));
            }
            
            // DD.MM.YYYY formatı (18.05.2024 gibi)
            if (dateString.includes('.')) {
                const parts = dateString.split('.');
                if (parts.length === 3) {
                    const day = parts[0].padStart(2, '0');
                    const month = parts[1].padStart(2, '0');
                    const year = parts[2];
                    return new Date(parseInt(year), parseInt(month) - 1, parseInt(day));
                }
            }
            
            // YYYY-MM-DD formatı
            if (dateString.includes('-') && dateString.length >= 8) {
                const datePart = dateString.split('-').slice(0, 3).join('-');
                const date = new Date(datePart);
                if (!isNaN(date.getTime())) {
                    return date;
                }
            }
            
            // Diğer standart formatları dene
            const date = new Date(dateString);
            if (!isNaN(date.getTime())) {
                return date;
            }
            
        } catch (error) {
            console.warn('Tarih formatlanamadı:', dateString, error);
        }
        
        return null;
    }

    // Yeni firma formatı ekleme
    addCompanyFormat(companyKey, config) {
        this.config[companyKey] = config;
    }

    // Firma formatlarını listeleme
    getCompanyFormats() {
        return Object.keys(this.config).map(key => ({
            key: key,
            separator: this.config[key].separator,
            fieldCount: this.config[key].fields.length
        }));
    }
}
