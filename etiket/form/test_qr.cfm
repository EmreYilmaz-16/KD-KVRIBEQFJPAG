<!--- QR Kod Test Sayfası --->
<html>
<head>
    <title>QR Kod Test</title>
</head>
<body>
    <h2>Workcube Barcode Custom Tag Test</h2>
    
    <cfset upload_folder = ExpandPath(".")>
    <cfset dir_seperator = "/">
    <cfif FindNoCase("Windows", server.os.name)>
        <cfset dir_seperator = "\">
    </cfif>
    
    <p>Test QR Kod:</p>
    <cftry>
        <cf_pbs_barcode 
            value="ABC123_SN001_30072025_31072025_1234567890_25.50_TestMarka" 
            type="qrcode" 
            width="150" 
            height="150" 
            show="1" 
            id="test_qr"
            path="#ExpandPath('./temp/')#"
            format="png">
        
        <p>QR Kod başarıyla oluşturuldu!</p>
    <cfcatch>
        <p>Hata: <cfoutput>#cfcatch.message#</cfoutput></p>
        <p>Detay: <cfoutput>#cfcatch.detail#</cfoutput></p>
    </cfcatch>
    </cftry>
    
    <p><a href="view_labels.cfm?import_id=7">Etiket Sayfasına Dön</a></p>
</body>
</html>
