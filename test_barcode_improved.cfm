<!--- 
    Improved Barcode Service Test
    Bu dosya geliştirilmiş BarcodeService.cfc'yi test eder
    Timeout ve hata yakalama iyileştirmeleriyle
--->
<cfscript>
writeOutput("<h1>Geliştirilmiş Barkod Servisi Test</h1>");

// Test IP adresi - gerçek yazıcı IP'si ile değiştirin
testIP = "192.168.2.9";  // veya gerçek yazıcı IP'niz
testPort = 9100;

writeOutput("<h2>Test Parametreleri:</h2>");
writeOutput("IP Adresi: " & testIP & "<br/>");
writeOutput("Port: " & testPort & "<br/>");
writeOutput("Connection Timeout: 5000ms<br/>");
writeOutput("Read Timeout: 10000ms<br/>");
writeOutput("<hr/>");

try {
    // BarcodeService örneği oluştur - uzun timeout'larla
    svc = createObject("component", "cfc.BarcodeService").init(
        printerIpAddress = testIP,
        printerPort = testPort,
        connectionTimeout = 5000,   // 5 saniye
        readTimeout = 10000         // 10 saniye
    );
    
    writeOutput("<h2>1. Ping Testi</h2>");
    pingResult = svc.pingHost();
    
    if (pingResult.status) {
        writeOutput("<span style='color: green;'><strong>✓ Ping BAŞARILI</strong></span><br/>");
        writeOutput("Mesaj: " & pingResult.message & "<br/>");
    } else {
        writeOutput("<span style='color: orange;'><strong>⚠ Ping BAŞARISIZ</strong></span><br/>");
        writeOutput("Mesaj: " & pingResult.message & "<br/>");
        if (structKeyExists(pingResult, "errorType")) {
            writeOutput("Hata Tipi: " & pingResult.errorType & "<br/>");
        }
    }
    writeOutput("Host IP: " & pingResult.hostIP & "<br/>");
    writeOutput("<hr/>");
    
    writeOutput("<h2>2. Port Bağlantı Testi</h2>");
    statusResult = svc.checkPrinterStatus();
    
    if (statusResult.status) {
        writeOutput("<span style='color: green;'><strong>✓ Port Bağlantısı BAŞARILI</strong></span><br/>");
        writeOutput("Mesaj: " & statusResult.message & "<br/>");
    } else {
        writeOutput("<span style='color: red;'><strong>✗ Port Bağlantısı BAŞARISIZ</strong></span><br/>");
        writeOutput("Hata: " & statusResult.message & "<br/>");
        writeOutput("Hata Tipi: " & statusResult.errorType & "<br/>");
        if (structKeyExists(statusResult, "errorDetail") && len(statusResult.errorDetail)) {
            writeOutput("Detay: " & statusResult.errorDetail & "<br/>");
        }
    }
    
    writeOutput("Target IP: " & statusResult.targetIP & "<br/>");
    writeOutput("Target Port: " & statusResult.targetPort & "<br/>");
    writeOutput("Connection Timeout: " & statusResult.connectionTimeout & "ms<br/>");
    writeOutput("<hr/>");
    
    // Eğer port bağlantısı başarılıysa devam et
    if (statusResult.status) {
        writeOutput("<h2>3. Barkod Yazdırma Testi</h2>");
        
        barcodeResult = svc.printBarcode(
            barcodeData = "TEST123456789",
            barcodeType = "Code128",
            x = 20, y = 20,
            width = 2, height = 90,
            copies = 1
        );
        
        if (barcodeResult.success) {
            writeOutput("<span style='color: green;'><strong>✓ Barkod yazdırma BAŞARILI</strong></span><br/>");
            writeOutput("Mesaj: " & barcodeResult.message & "<br/>");
        } else {
            writeOutput("<span style='color: red;'><strong>✗ Barkod yazdırma BAŞARISIZ</strong></span><br/>");
            writeOutput("Hata: " & barcodeResult.message & "<br/>");
            if (structKeyExists(barcodeResult, "errorType")) {
                writeOutput("Hata Tipi: " & barcodeResult.errorType & "<br/>");
            }
        }
        
        writeOutput("İşlem: " & barcodeResult.operation & "<br/>");
        writeOutput("Barkod Data: " & barcodeResult.barcodeData & "<br/>");
        writeOutput("Target IP: " & barcodeResult.targetIP & "<br/>");
        writeOutput("<hr/>");
        
        writeOutput("<h2>4. Metin Yazdırma Testi</h2>");
        
        textResult = svc.printText(
            text = "Test Mesajı - " & dateFormat(now(), "dd/mm/yyyy") & " " & timeFormat(now(), "HH:nn:ss"),
            x = 30, y = 140,
            fontSize = 3,
            copies = 1
        );
        
        if (textResult.success) {
            writeOutput("<span style='color: green;'><strong>✓ Metin yazdırma BAŞARILI</strong></span><br/>");
            writeOutput("Mesaj: " & textResult.message & "<br/>");
        } else {
            writeOutput("<span style='color: red;'><strong>✗ Metin yazdırma BAŞARISIZ</strong></span><br/>");
            writeOutput("Hata: " & textResult.message & "<br/>");
            if (structKeyExists(textResult, "errorType")) {
                writeOutput("Hata Tipi: " & textResult.errorType & "<br/>");
            }
        }
        
        writeOutput("İşlem: " & textResult.operation & "<br/>");
        writeOutput("Metin: " & textResult.text & "<br/>");
        writeOutput("Target IP: " & textResult.targetIP & "<br/>");
    } else {
        writeOutput("<h2>⚠️ Port bağlantısı başarısız olduğu için yazdırma testleri atlandı</h2>");
        
        writeOutput("<h3>Troubleshooting Önerileri:</h3>");
        writeOutput("<ul>");
        writeOutput("<li>Yazıcı IP adresini kontrol edin: " & testIP & "</li>");
        writeOutput("<li>Yazıcının açık olduğundan emin olun</li>");
        writeOutput("<li>Ağ bağlantısını kontrol edin</li>");
        writeOutput("<li>Port " & testPort & " açık olduğundan emin olun</li>");
        writeOutput("<li>Firewall ayarlarını kontrol edin</li>");
        writeOutput("<li>Ping atarak yazıcıya erişebildiğinizi doğrulayın</li>");
        writeOutput("</ul>");
    }
    
} catch (any e) {
    writeOutput("<h2 style='color: red;'>❌ Genel Hata</h2>");
    writeOutput("Mesaj: " & e.message & "<br/>");
    writeOutput("Detay: " & e.detail & "<br/>");
    writeOutput("Tip: " & e.type & "<br/>");
}

writeOutput("<hr/>");
writeOutput("<h2>Test Tamamlandı</h2>");
writeOutput("Zaman: " & dateFormat(now(), "dd/mm/yyyy") & " " & timeFormat(now(), "HH:nn:ss") & "<br/>");
</cfscript>

<style>
body { font-family: Arial, sans-serif; margin: 20px; }
h1 { color: #333; }
h2 { color: #666; margin-top: 20px; }
hr { margin: 20px 0; }
</style>