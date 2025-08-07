<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hata Oluştu - Excel Import</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .error-container {
            max-width: 600px;
            background: white;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
            padding: 40px;
            text-align: center;
        }
        
        .error-icon {
            font-size: 4em;
            margin-bottom: 20px;
        }
        
        .error-title {
            color: #d63031;
            font-size: 2em;
            margin-bottom: 20px;
            font-weight: 600;
        }
        
        .error-message {
            color: #666;
            font-size: 1.1em;
            margin-bottom: 30px;
            line-height: 1.6;
        }
        
        .error-details {
            background: #f8f9fa;
            border-left: 4px solid #d63031;
            padding: 20px;
            margin: 20px 0;
            text-align: left;
            border-radius: 5px;
        }
        
        .error-details h4 {
            margin-top: 0;
            color: #d63031;
        }
        
        .error-details code {
            background: #e9ecef;
            padding: 2px 6px;
            border-radius: 3px;
            font-family: 'Courier New', monospace;
            font-size: 0.9em;
        }
        
        .back-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px 30px;
            border: none;
            border-radius: 8px;
            text-decoration: none;
            display: inline-block;
            margin: 10px;
            font-size: 1.1em;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .back-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
            text-decoration: none;
            color: white;
        }
        
        .error-code {
            font-family: 'Courier New', monospace;
            background: #2c3e50;
            color: #ecf0f1;
            padding: 15px;
            border-radius: 8px;
            font-size: 0.9em;
            text-align: left;
            margin: 15px 0;
            white-space: pre-wrap;
            overflow-x: auto;
        }
        
        .helpful-tips {
            background: #e8f5e8;
            border-left: 4px solid #27ae60;
            padding: 20px;
            margin: 20px 0;
            text-align: left;
            border-radius: 5px;
        }
        
        .helpful-tips h4 {
            margin-top: 0;
            color: #27ae60;
        }
        
        .helpful-tips ul {
            margin: 10px 0;
            padding-left: 20px;
        }
        
        .helpful-tips li {
            margin-bottom: 8px;
            color: #2c3e50;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-icon">⚠️</div>
        <h1 class="error-title">Bir Hata Oluştu</h1>
        
        <p class="error-message">
            Excel dosyası işlenirken beklenmeyen bir hata oluştu. 
            Lütfen dosyanızı kontrol edin ve tekrar deneyin.
        </p>
        
        <cfif isDefined("errorDetails")>
            <div class="error-details">
                <h4>🔍 Hata Detayları</h4>
                <p><strong>Hata Türü:</strong> <code>#htmlEditFormat(errorDetails.type)#</code></p>
                <p><strong>Mesaj:</strong> #htmlEditFormat(errorDetails.message)#</p>
                
                <cfif len(errorDetails.detail)>
                    <p><strong>Detay:</strong> #htmlEditFormat(errorDetails.detail)#</p>
                </cfif>
                
                <cfif len(errorDetails.template)>
                    <p><strong>Dosya:</strong> <code>#htmlEditFormat(errorDetails.template)#</code></p>
                </cfif>
                
                <cfif len(errorDetails.line)>
                    <p><strong>Satır:</strong> <code>#errorDetails.line#</code></p>
                </cfif>
                
                <p><strong>Zaman:</strong> #dateFormat(errorDetails.timestamp, "dd/mm/yyyy")# #timeFormat(errorDetails.timestamp, "HH:mm:ss")#</p>
            </div>
        </cfif>
        
        <div class="helpful-tips">
            <h4>💡 Olası Çözümler</h4>
            <ul>
                <li><strong>Dosya Formatı:</strong> Sadece .xlsx veya .xls formatında dosya yükleyin</li>
                <li><strong>Dosya Boyutu:</strong> Dosya boyutunun 10MB'dan küçük olduğundan emin olun</li>
                <li><strong>ETA_KODU Kolonu:</strong> Excel dosyanızda ETA_KODU kolonu bulunduğundan emin olun</li>
                <li><strong>Başlık Satırı:</strong> İlk satırın kolon başlıklarını içerdiğinden emin olun</li>
                <li><strong>Veritabanı Bağlantısı:</strong> Veri kaynağı ayarlarının doğru olduğundan emin olun</li>
                <li><strong>Karakter Kodlaması:</strong> Türkçe karakterler için UTF-8 kodlaması kullanın</li>
            </ul>
        </div>
        
        <cfif isDefined("url.debug") and url.debug eq "true">
            <div class="error-code">
<cfif isDefined("cfcatch")>
Teknik Detaylar:
Type: #cfcatch.type#
Message: #cfcatch.message#
Detail: #cfcatch.detail#
<cfif structKeyExists(cfcatch, "sql")>
SQL: #cfcatch.sql#
</cfif>
<cfif structKeyExists(cfcatch, "queryError")>
Query Error: #cfcatch.queryError#
</cfif>
Stack Trace:
<cfloop array="#cfcatch.stackTrace#" index="stackItem">
#stackItem.template# : #stackItem.line#
</cfloop>
</cfif>
            </div>
        </cfif>
        
        <div>
            <a href="upload_excel.cfm" class="back-btn">🔙 Ana Sayfaya Dön</a>
            <a href="javascript:history.back()" class="back-btn">↩️ Geri Git</a>
        </div>
        
        <p style="margin-top: 30px; color: #666; font-size: 0.9em;">
            Bu hata devam ederse sistem yöneticinize başvurun.<br>
            Hata Kodu: #hash(now())#
        </p>
    </div>
</body>
</html>
