<!--- 
    ZPL Barcode Service Test
    Bu dosya ZPL (Zebra Programming Language) desteğini test eder
--->
<cfscript>
writeOutput("<h1>ZPL Barkod Servisi Test</h1>");

// Test IP adresi
testIP = "192.168.2.9";
testPort = 9100;

writeOutput("<h2>Test Parametreleri:</h2>");
writeOutput("IP Adresi: " & testIP & "<br/>");
writeOutput("Port: " & testPort & "<br/>");
writeOutput("Dil: ZPL (Zebra Programming Language)<br/>");
writeOutput("<hr/>");

try {
    // BarcodeService örneği oluştur
    svc = createObject("component", "cfc.BarcodeService").init(
        printerIpAddress = testIP,
        printerPort = testPort,
        connectionTimeout = 5000,
        readTimeout = 10000
    );
    
    writeOutput("<h2>1. ZPL Barkod Testi (Code128)</h2>");
    
    zplBarcodeResult = svc.printBarcodeZPL(
        barcodeData = "ZPL123456789",
        barcodeType = "Code128",
        x = 50, y = 50,
        width = 2, height = 100,
        copies = 1
    );
    
    if (zplBarcodeResult.success) {
        writeOutput("<span style='color: green;'><strong>✓ ZPL Barkod BAŞARILI</strong></span><br/>");
        writeOutput("Mesaj: " & zplBarcodeResult.message & "<br/>");
    } else {
        writeOutput("<span style='color: red;'><strong>✗ ZPL Barkod BAŞARISIZ</strong></span><br/>");
        writeOutput("Hata: " & zplBarcodeResult.message & "<br/>");
    }
    
    writeOutput("İşlem: " & zplBarcodeResult.operation & "<br/>");
    writeOutput("Dil: " & zplBarcodeResult.language & "<br/>");
    writeOutput("Barkod Data: " & zplBarcodeResult.barcodeData & "<br/>");
    writeOutput("<hr/>");
    
    writeOutput("<h2>2. ZPL QR Code Testi</h2>");
    
    qrResult = svc.printBarcodeZPL(
        barcodeData = "https://www.example.com/test-qr-" & dateFormat(now(), "yyyymmdd"),
        barcodeType = "QR",
        x = 50, y = 200,
        width = 4, height = 100,
        copies = 1
    );
    
    if (qrResult.success) {
        writeOutput("<span style='color: green;'><strong>✓ QR Code BAŞARILI</strong></span><br/>");
        writeOutput("Mesaj: " & qrResult.message & "<br/>");
    } else {
        writeOutput("<span style='color: red;'><strong>✗ QR Code BAŞARISIZ</strong></span><br/>");
        writeOutput("Hata: " & qrResult.message & "<br/>");
    }
    
    writeOutput("QR Data: " & qrResult.barcodeData & "<br/>");
    writeOutput("<hr/>");
    
    writeOutput("<h2>3. ZPL Metin Testi</h2>");
    
    zplTextResult = svc.printTextZPL(
        text = "ZPL Test Mesajı - " & dateFormat(now(), "dd/mm/yyyy"),
        x = 50, y = 350,
        fontSize = "0",
        copies = 1
    );
    
    if (zplTextResult.success) {
        writeOutput("<span style='color: green;'><strong>✓ ZPL Metin BAŞARILI</strong></span><br/>");
        writeOutput("Mesaj: " & zplTextResult.message & "<br/>");
    } else {
        writeOutput("<span style='color: red;'><strong>✗ ZPL Metin BAŞARISIZ</strong></span><br/>");
        writeOutput("Hata: " & zplTextResult.message & "<br/>");
    }
    
    writeOutput("Metin: " & zplTextResult.text & "<br/>");
    writeOutput("<hr/>");
    
    writeOutput("<h2>4. Ham ZPL Komutu Testi</h2>");
    
    // Ham ZPL komutu - basit etiket
    rawZPL = "^XA" & chr(13) & chr(10) &
             "^FO50,50^A0N,30,20^FDHAM ZPL TEST^FS" & chr(13) & chr(10) &
             "^FO50,100^BCN,80,Y,N,N^FD123RAW456^FS" & chr(13) & chr(10) &
             "^XZ" & chr(13) & chr(10);
    
    rawResult = svc.sendRawZPL(rawZPL);
    
    if (rawResult.success) {
        writeOutput("<span style='color: green;'><strong>✓ Ham ZPL BAŞARILI</strong></span><br/>");
        writeOutput("Mesaj: " & rawResult.message & "<br/>");
    } else {
        writeOutput("<span style='color: red;'><strong>✗ Ham ZPL BAŞARISIZ</strong></span><br/>");
        writeOutput("Hata: " & rawResult.message & "<br/>");
    }
    
    writeOutput("Komut Uzunluğu: " & rawResult.commandLength & " byte<br/>");
    writeOutput("<hr/>");
    
    writeOutput("<h2>5. Karışık Etiket Testi</h2>");
    
    // Daha kompleks ZPL etiketi
    complexZPL = "^XA" & chr(13) & chr(10) &
                 "^FO50,30^A0N,25,15^FDÜRÜN ETİKETİ^FS" & chr(13) & chr(10) &
                 "^FO50,70^A0N,20,10^FDÜrün Kodu: PRD001^FS" & chr(13) & chr(10) &
                 "^FO50,100^A0N,20,10^FDTarih: " & dateFormat(now(), "dd/mm/yyyy") & "^FS" & chr(13) & chr(10) &
                 "^FO50,130^BCN,60,Y,N,N^FDPRD001-" & timeFormat(now(), "HHNNSS") & "^FS" & chr(13) & chr(10) &
                 "^FO300,50^BQN,2,4^FDQA,https://example.com/product/PRD001^FS" & chr(13) & chr(10) &
                 "^XZ" & chr(13) & chr(10);
    
    complexResult = svc.sendRawZPL(complexZPL);
    
    if (complexResult.success) {
        writeOutput("<span style='color: green;'><strong>✓ Karışık Etiket BAŞARILI</strong></span><br/>");
        writeOutput("Mesaj: " & complexResult.message & "<br/>");
    } else {
        writeOutput("<span style='color: red;'><strong>✗ Karışık Etiket BAŞARISIZ</strong></span><br/>");
        writeOutput("Hata: " & complexResult.message & "<br/>");
    }
    
    writeOutput("Komut Uzunluğu: " & complexResult.commandLength & " byte<br/>");
    
} catch (any e) {
    writeOutput("<h2 style='color: red;'>❌ Genel Hata</h2>");
    writeOutput("Mesaj: " & e.message & "<br/>");
    writeOutput("Detay: " & e.detail & "<br/>");
    writeOutput("Tip: " & e.type & "<br/>");
}

writeOutput("<hr/>");
writeOutput("<h2>ZPL vs PPL Karşılaştırması</h2>");
writeOutput("<table border='1' style='border-collapse: collapse; width: 100%;'>");
writeOutput("<tr style='background-color: #f0f0f0;'>");
writeOutput("<th>Özellik</th><th>PPL</th><th>ZPL</th>");
writeOutput("</tr>");
writeOutput("<tr>");
writeOutput("<td>Başlangıç</td><td>STX (Chr(2))</td><td>^XA</td>");
writeOutput("</tr>");
writeOutput("<tr>");
writeOutput("<td>Bitiş</td><td>ETX (Chr(3))</td><td>^XZ</td>");
writeOutput("</tr>");
writeOutput("<tr>");
writeOutput("<td>Barkod (Code128)</td><td>B komutu</td><td>^BC komutu</td>");
writeOutput("</tr>");
writeOutput("<tr>");
writeOutput("<td>Metin</td><td>T komutu</td><td>^A + ^FD komutları</td>");
writeOutput("</tr>");
writeOutput("<tr>");
writeOutput("<td>QR Code</td><td>Sınırlı</td><td>^BQ komutu</td>");
writeOutput("</tr>");
writeOutput("<tr>");
writeOutput("<td>Yaygınlık</td><td>Çeşitli markalar</td><td>Zebra tabanlı</td>");
writeOutput("</tr>");
writeOutput("</table>");

writeOutput("<hr/>");
writeOutput("<h2>Test Tamamlandı</h2>");
writeOutput("Zaman: " & dateFormat(now(), "dd/mm/yyyy") & " " & timeFormat(now(), "HH:nn:ss") & "<br/>");
</cfscript>

<style>
body { font-family: Arial, sans-serif; margin: 20px; }
h1 { color: #333; }
h2 { color: #666; margin-top: 20px; }
hr { margin: 20px 0; }
table { margin: 10px 0; }
th, td { padding: 8px; text-align: left; }
</style>