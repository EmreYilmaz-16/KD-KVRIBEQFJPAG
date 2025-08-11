<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>GTIP Import Test</title>
</head>
<body>
    <h2>GTIP Import Sistemi Test</h2>
    
    <h3>Veritabanı Bağlantı Testi</h3>
    <cftry>
        <!--- Veritabanı bağlantısını tespit et --->
        <cfset dsn = "">
        <cfif isDefined("application.datasource")>
            <cfset dsn = application.datasource>
        <cfelseif isDefined("request.datasource")>
            <cfset dsn = request.datasource>
        <cfelse>
            <!--- Varsayılan datasource adını buraya yazın --->
            <cfset dsn = "kd_database">
        </cfif>
        
        <p><strong>Kullanılan Datasource:</strong> #dsn#</p>
        
        <!--- PRODUCT tablosu test sorgusu --->
        <cfquery name="testQuery" datasource="#dsn#" maxrows="5">
            SELECT PRODUCT_CODE_2, GTIP_NUMBER 
            FROM PRODUCT 
            WHERE PRODUCT_CODE_2 IS NOT NULL
            ORDER BY PRODUCT_CODE_2
        </cfquery>
        
        <p style="color: green;"><strong>✓ Veritabanı bağlantısı başarılı!</strong></p>
        <p><strong>PRODUCT tablosu örnek veriler:</strong></p>
        
        <table border="1" cellpadding="5" cellspacing="0">
            <tr>
                <th>PRODUCT_CODE_2 (ETA Kodu)</th>
                <th>GTIP_NUMBER</th>
            </tr>
            <cfloop query="testQuery">
                <tr>
                    <td>#PRODUCT_CODE_2#</td>
                    <td>
                        <cfif len(GTIP_NUMBER) gt 0>
                            #GTIP_NUMBER#
                        <cfelse>
                            <em style="color: #999;">Boş</em>
                        </cfif>
                    </td>
                </tr>
            </cfloop>
        </table>
        
        <cfcatch type="any">
            <div style="color: red; background-color: #ffe6e6; padding: 10px; border-radius: 5px;">
                <strong>✗ Veritabanı bağlantı hatası:</strong><br>
                <strong>Hata:</strong> #cfcatch.message#<br>
                <strong>Detay:</strong> #cfcatch.detail#<br>
                <strong>Datasource:</strong> #dsn#
                
                <h4>Çözüm Önerileri:</h4>
                <ul>
                    <li>ColdFusion Administrator'da datasource ayarlarını kontrol edin</li>
                    <li>Datasource adının doğru olduğundan emin olun</li>
                    <li>Veritabanı sunucusunun çalıştığından emin olun</li>
                    <li>PRODUCT tablosunun var olduğundan emin olun</li>
                </ul>
            </div>
        </cfcatch>
    </cftry>
    
    <br>
    <p>
        <a href="gtip_import.cfm" style="background-color: #4CAF50; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px;">GTIP Import Sayfasına Git</a>
        <a href="create_template.cfm" style="background-color: #2196F3; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px; margin-left: 10px;">Excel Şablonu Oluştur</a>
    </p>
</body>
</html>
