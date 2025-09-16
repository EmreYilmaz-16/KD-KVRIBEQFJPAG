<cfscript>
svc = createObject("component", "BarcodeService").init("192.168.2.9", 9100);

// Ping gibi: bağlantı kurulabiliyor mu?
isUp = svc.checkPrinterStatus();
writeOutput("Yazıcı durumu: " & (isUp ? "UP" : "DOWN") & "<br/>");

// Barkod
ok1 = svc.printBarcode(
    barcodeData = "123456789012",
    barcodeType = "EAN13",
    x = 20, y = 20,
    width = 2, height = 90,
    copies = 1
);
writeOutput("Barkod yazdırıldı mı? " & ok1 & "<br/>");

// Metin
ok2 = svc.printText(
    text = "EBD Tech - Test",
    x = 30, y = 140,
    fontSize = 3,
    copies = 1
);
writeOutput("Metin yazdırıldı mı? " & ok2 & "<br/>");
</cfscript>
