component displayname="BarcodeManager" hint="Barkod yönetimi ve parsing işlemleri için component" {

    // Constructor - Component başlatma
    public function init() {
        // Firma bazlı barkod formatları konfigürasyonu
        variables.config = {
            // Firma 1
            "firma1" = {
                "separator" = "_",
                "fields" = [
                    { "name" = "urunKodu", "index" = 1 },
                    { "name" = "seriNo", "index" = 2 },
                    { "name" = "uretimTarihi", "index" = 3 },
                    { "name" = "paketlemeTarihi", "index" = 4 },
                    { "name" = "barkod", "index" = 5 },
                    { "name" = "miktar", "index" = 6 },
                    { "name" = "marka", "index" = 7 }
                ]
            },
            
            // Firma 2
            "firma2" = {
                "separator" = "_",
                "fields" = [
                    { "name" = "urunKodu", "index" = 1 },
                    { "name" = "seriNo", "index" = 2 },
                    { "name" = "uretimTarihi", "index" = 3 },
                    { "name" = "paketlemeTarihi", "index" = 4 },
                    { "name" = "barkod", "index" = 5 },
                    { "name" = "miktar", "index" = 6 }
                ]
            },
            
            // Firma 3
            "firma3" = {
                "separator" = "-",
                "fields" = [
                    { "name" = "urunKodu", "index" = 1 },
                    { "name" = "miktar", "index" = 2 },
                    { "name" = "bos", "index" = 3 },
                    { "name" = "uretimTarihi", "index" = 4 },
                    { "name" = "seriNo", "index" = 5 }
                ]
            }
        };
        
        return this;
    }

    // Ana parser fonksiyonu
    public struct function parseBarcode(required string data, required string companyKey) {
        var result = {};
        
        if (!len(trim(arguments.data)) || !len(trim(arguments.companyKey)) || !structKeyExists(variables.config, arguments.companyKey)) {
            result.error = 'Geçersiz firma anahtarı veya barkod verisi';
            result.rawData = arguments.data;
            return result;
        }
        
        return parseBarcodeByConfig(arguments.data, variables.config[arguments.companyKey]);
    }

    // İç parser fonksiyonu
    private struct function parseBarcodeByConfig(required string data, required struct config) {
        var result = {};
        var parts = [];
        var field = {};
        
        if (!len(trim(arguments.data)) || !structCount(arguments.config)) {
            return {};
        }
        
        // String'i böl
        parts = listToArray(arguments.data, arguments.config.separator);
        result.rawData = arguments.data;
        
        // Field'ları parse et
        for (var i = 1; i <= arrayLen(arguments.config.fields); i++) {
            field = arguments.config.fields[i];
            if (field.index <= arrayLen(parts)) {
                result[field.name] = parts[field.index];
            } else {
                result[field.name] = '';
            }
        }
        
        // Tarih formatlaması yap
        if (structKeyExists(result, "uretimTarihi")) {
            result.uretimTarihi = formatDate(result.uretimTarihi);
        }
        if (structKeyExists(result, "paketlemeTarihi")) {
            result.paketlemeTarihi = formatDate(result.paketlemeTarihi);
        }
        
        return result;
    }

    // Tarih formatlama fonksiyonu
    private any function formatDate(string dateString) {
        var parts = [];
        var month = "";
        var year = "";
        var day = "";
        var currentYear = year(now());
        var currentCentury = 0;
        var yearNum = 0;
        var datePart = "";
        var resultDate = "";
        
        if (!len(trim(arguments.dateString))) {
            return "";
        }
        
        dateString = trim(arguments.dateString);
        
        try {
            // MM/YY formatı (02/25 gibi)
            if (find("/", dateString) && len(dateString) <= 5) {
                parts = listToArray(dateString, "/");
                if (arrayLen(parts) == 2) {
                    month = right("0" & parts[1], 2);
                    year = parts[2];
                    
                    if (len(year) == 2) {
                        currentCentury = int(currentYear / 100) * 100;
                        yearNum = val(year);
                        if (yearNum > 50) {
                            year = currentCentury - 100 + yearNum;
                        } else {
                            year = currentCentury + yearNum;
                        }
                    }
                    
                    return createDate(year, val(month), 1);
                }
            }
            
            // DDMMYYYY formatı (05092025 gibi)
            if (len(dateString) == 8 && reFind("^\d{8}$", dateString)) {
                day = left(dateString, 2);
                month = mid(dateString, 3, 2);
                year = right(dateString, 4);
                return createDate(val(year), val(month), val(day));
            }
            
            // DD.MM.YYYY formatı (18.05.2024 gibi)
            if (find(".", dateString)) {
                parts = listToArray(dateString, ".");
                if (arrayLen(parts) == 3) {
                    day = right("0" & parts[1], 2);
                    month = right("0" & parts[2], 2);
                    year = parts[3];
                    return createDate(val(year), val(month), val(day));
                }
            }
            
            // YYYY-MM-DD formatı
            if (find("-", dateString) && len(dateString) >= 8) {
                parts = listToArray(dateString, "-");
                if (arrayLen(parts) >= 3) {
                    datePart = parts[1] & "-" & parts[2] & "-" & parts[3];
                    if (isDate(datePart)) {
                        return parseDateTime(datePart);
                    }
                }
            }
            
            // Diğer standart formatları dene
            if (isDate(dateString)) {
                return parseDateTime(dateString);
            }
            
        } catch (any e) {
            writeLog(type="warning", text="Tarih formatlanamadı: #dateString# - Error: #e.message#");
        }
        
        return "";
    }

    // Yeni firma formatı ekleme
    public void function addCompanyFormat(required string companyKey, required struct config) {
        variables.config[arguments.companyKey] = arguments.config;
    }

    // Firma formatlarını listeleme
    public array function getCompanyFormats() {
        var result = [];
        var companyKeys = structKeyArray(variables.config);
        
        for (var i = 1; i <= arrayLen(companyKeys); i++) {
            var key = companyKeys[i];
            var format = {
                "key" = key,
                "separator" = variables.config[key].separator,
                "fieldCount" = arrayLen(variables.config[key].fields)
            };
            arrayAppend(result, format);
        }
        
        return result;
    }

    // Config'i döndür (debug amaçlı)
    public struct function getConfig() {
        return variables.config;
    }
}
