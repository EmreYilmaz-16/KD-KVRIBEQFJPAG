<!---
    CFML Excel Preview Script
    Bu dosya upload_excel.cfm'den gelen Excel dosyasını önce gösterir, kullanıcı onayından sonra veritabanına aktarır
--->

<cfparam name="form.excelFile" default="">
<cfparam name="form.confirmImport" default="false">
<cfparam name="form.uploadedFile" default="">

<!--- Sayfa başlangıç ayarları --->
<cfsetting requesttimeout="300" showdebugoutput="false">

<!--- Veritabanı bağlantı ayarları (projenize göre düzenleyin) --->
<cfset dsn = "W3Qa">

<!--- Upload klasörü ayarları --->
<cfset uploadPath = expandPath("./uploads/")>

<!--- Upload klasörünü kontrol et ve oluştur --->
<cfif not directoryExists(uploadPath)>
    <cfdirectory action="create" directory="#uploadPath#">
</cfif>

<cfset allowedExtensions = "xlsx,xls">
<cfset maxFileSize = 10485760> <!--- 10MB --->

<!--- Sonuç değişkenleri --->
<cfset uploadSuccess = false>
<cfset importSuccess = false>
<cfset showPreview = false>
<cfset errorMessage = "">
<cfset successCount = 0>
<cfset errorCount = 0>
<cfset uploadedFileName = "">
<cfset errorDetails = arrayNew(1)>

<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Excel İçe Aktarım - Önizleme ve Onay</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
            padding: 40px;
        }
        
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        
        .success-box {
            background: #d4edda;
            border-left: 4px solid #28a745;
            padding: 20px;
            margin-bottom: 20px;
            border-radius: 5px;
        }
        
        .error-box {
            background: #f8d7da;
            border-left: 4px solid #dc3545;
            padding: 20px;
            margin-bottom: 20px;
            border-radius: 5px;
        }
        
        .info-box {
            background: #e3f2fd;
            border-left: 4px solid #2196f3;
            padding: 20px;
            margin-bottom: 20px;
            border-radius: 5px;
        }
        
        .warning-box {
            background: #fff3cd;
            border-left: 4px solid #ffc107;
            padding: 20px;
            margin-bottom: 20px;
            border-radius: 5px;
        }
        
        .preview-table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
            max-height: 400px;
            overflow-y: auto;
            display: block;
            white-space: nowrap;
        }
        
        .preview-table thead {
            background: #f8f9fa;
            position: sticky;
            top: 0;
        }
        
        .preview-table th,
        .preview-table td {
            border: 1px solid #dee2e6;
            padding: 8px 12px;
            text-align: left;
            min-width: 100px;
        }
        
        .preview-table th {
            background: #667eea;
            color: white;
            font-weight: 600;
        }
        
        .preview-table tbody {
            display: table;
            width: 100%;
        }
        
        .preview-table tr:nth-child(even) {
            background: #f8f9fa;
        }
        
        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 8px;
            font-size: 1.1em;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            margin: 10px;
            transition: all 0.3s ease;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .btn-success {
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
            color: white;
        }
        
        .btn-secondary {
            background: #6c757d;
            color: white;
        }
        
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.2);
        }
        
        .button-group {
            text-align: center;
            margin: 30px 0;
        }
        
        .stats-summary {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 15px;
            margin-top: 15px;
        }
        
        .stat-item {
            text-align: center;
            padding: 15px;
            background: white;
            border-radius: 8px;
            border: 1px solid #dee2e6;
        }
        
        .stat-number {
            font-size: 1.5em;
            font-weight: bold;
            color: #667eea;
        }
        
        .stat-label {
            font-size: 0.9em;
            color: #666;
            margin-top: 5px;
        }
        
        .table-wrapper {
            max-height: 500px;
            overflow: auto;
            border: 1px solid #dee2e6;
            border-radius: 8px;
        }
        
        .required-column {
            background: #ffe6e6 !important;
            font-weight: bold;
        }
        
        .empty-cell {
            background: #f8f8f8;
            color: #999;
            font-style: italic;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 Excel İçe Aktarım - Önizleme ve Onay</h1>
        </div>

<!--- Onay sonrası veritabanına aktarım --->
<cfif form.confirmImport EQ "true" AND len(form.uploadedFile)>
    
    <div class="info-box">
        <h3>⏳ Veritabanına Aktarılıyor...</h3>
        <p>Onaylanan veriler OEM tablosuna aktarılıyor. Lütfen bekleyin...</p>
    </div>
    
    <cftry>
        <!--- Debug: Dosya yolunu kontrol et --->
        <cfset fullFilePath = uploadPath & form.uploadedFile>
        <cfif NOT fileExists(fullFilePath)>
            <cfthrow message="Dosya bulunamadı: #fullFilePath#">
        </cfif>
        
        <!--- Excel dosyasını tekrar oku --->
        <cfspreadsheet action="read"
                      src="#fullFilePath#"
                      query="importData"
                      headerrow="1"
                      sheet="1">
        
        <!--- İstatistikler için sayaçlar --->
        <cfset totalRows = importData.recordCount>
        <cfset successCount = 0>
        <cfset errorCount = 0>
        <cfset errorDetails = arrayNew(1)>
        
        <!--- Kolon isimlerini al --->
        <cfset columnList = importData.columnList>
        <cfset etaKoduColumn = "">
        <cfif listFindNoCase(columnList, "ETA KODU")>
            <cfset etaKoduColumn = "ETA KODU">
        <cfelseif listFindNoCase(columnList, "ETA_KODU")>
            <cfset etaKoduColumn = "ETA_KODU">
        </cfif>
        
        <!--- Her satır için veritabanı işlemi --->
        <cfloop query="importData" startrow="2">

            <cftry>
               
                <!--- ETA_KODU kontrolü (zorunlu alan) --->
                <cfif len(trim(importData[etaKoduColumn][currentRow]))>
                    
                    <!--- ETA_KODU değerini al --->
                    <cfset etaKoduValue = trim(importData[etaKoduColumn][currentRow])>
                     <cfquery name="getProduct" datasource="W3Qa_1">
                    SELECT * FROM STOCKS WHERE PRODUCT_CODE_2= <cfqueryparam value="#etaKoduValue#" cfsqltype="cf_sql_nvarchar">
                </cfquery>
                    <cfif getProduct.recordCount EQ 0>
                        <cfset errorCount = errorCount + 1>
                        <cfset arrayAppend(errorDetails, "Satır #currentRow#: ETA_KODU '#etaKoduValue#' bulunamadı")>
                        <cfcontinue>
                    </cfif>

                    <!--- Her OEM kolonu için ayrı satır ekle --->
                    <cfloop from="1" to="50" index="i">
                        <cfset oemColumn = "OEM #i#">
                        <cfif listFindNoCase(columnList, oemColumn) AND len(trim(importData[oemColumn][currentRow]))>
                            <cfquery name="getExistingRecord" datasource="#dsn#">
                               SELECT BARCODE,STOCK_ID,UNIT_ID FROM [w3Qa_product].[STOCKS_BARCODES]  WHERE BARCODE=<cfqueryparam value="#trim(importData[oemColumn][currentRow])#" cfsqltype="cf_sql_nvarchar">
                               
                                -- SELECT * FROM PRODUCT_OEMS 
                                -- WHERE ETA_KODU = <cfqueryparam value="#etaKoduValue#" cfsqltype="cf_sql_nvarchar"> 
                                -- AND OEM_NO = <cfqueryparam value="#trim(importData[oemColumn][currentRow])#" cfsqltype="cf_sql_nvarchar">
                            </cfquery>
                            <cfif getExistingRecord.recordCount GT 0>
                                <cfset errorCount = errorCount + 1>
                                <cfset arrayAppend(errorDetails, "Satır #currentRow#: ETA_KODU '#etaKoduValue#' ve OEM '#trim(importData[oemColumn][currentRow])#' zaten mevcut")>
                                <cfcontinue>
                            </cfif>

                            <!--- PRODUCT_OEMS tablosuna INSERT (her OEM için ayrı satır) --->
                            <cfquery name="insertQuery" datasource="#dsn#_product">
                                -- INSERT INTO PRODUCT_OEMS (ETA_KODU, OEM_NO)
                                -- VALUES (
                                --     <cfqueryparam value="#etaKoduValue#" cfsqltype="cf_sql_nvarchar">,
                                --     <cfqueryparam value="#trim(importData[oemColumn][currentRow])#" cfsqltype="cf_sql_nvarchar">
                                -- )
                                INSERT INTO STOCKS_BARCODES (BARCODE,STOCK_ID,UNIT_ID) values (
                                    <cfqueryparam value="#trim(importData[oemColumn][currentRow])#" cfsqltype="cf_sql_nvarchar">,
                                    <cfqueryparam value="#getProduct.STOCK_ID#" cfsqltype="cf_sql_integer">,
                                    <cfqueryparam value="#getProduct.PRODUCT_UNIT_ID#" cfsqltype="cf_sql_integer">
                                )
                            </cfquery>
                            
                            <cfset successCount = successCount + 1>
                        </cfif>
                    </cfloop>
                    
                <cfelse>
                    <!--- ETA_KODU boş ise hata kaydet --->
                    <cfset errorCount = errorCount + 1>
                    <cfset arrayAppend(errorDetails, "Satır #currentRow#: ETA_KODU boş veya geçersiz")>
                </cfif>
                
                <cfcatch type="any">
                    <!--- Veritabanı hatası --->
                    <cfset errorCount = errorCount + 1>
                    <cfset arrayAppend(errorDetails, "Satır #currentRow#: #cfcatch.message#")>
                </cfcatch>
            </cftry>
        </cfloop>
        
        <cfset importSuccess = true>
        
        <!--- Başarı mesajı --->
        <div class="success-box">
            <h3>🎉 İçe Aktarım Başarıyla Tamamlandı!</h3>
            <cfoutput><p><strong>#successCount#</strong> adet OEM kaydı başarıyla OEM tablosuna eklendi.</p></cfoutput>
            <cfif errorCount GT 0>
            <cfoutput>    <p><strong>#errorCount#</strong> kayıt işlenemedi.</p>
            <p>Hatalar için lütfen aşağıdaki detaylara bakın.</p>
            <ul>
                <cfloop array="#errorDetails#" index="errorDetail">
                    <li>#errorDetail#</li>
                </cfloop>
            </ul>
            </cfoutput>
            </cfif>
        </div>
        
        <cfcatch type="any">
            <div class="error-box">
                <h3>❌ İçe Aktarım Hatası</h3>
                <cfdump var="#cfcatch#">
              <cfoutput> <p>#cfcatch.message#</p></cfoutput> 
            </div>
        </cfcatch>
    </cftry>

<!--- İlk dosya yükleme ve önizleme --->
<cfelseif len(trim(form.excelFile))>
    
    <cftry>
        <!--- Dosya yükleme --->
        <cffile action="upload"
                filefield="excelFile"
                destination="#uploadPath#"
                nameconflict="makeunique"
                accept="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,application/vnd.ms-excel">
        
        <cfset uploadedFileName = cffile.serverFile>
        <cfset uploadSuccess = true>
        
        <div class="success-box">
            <h3>✅ Dosya Başarıyla Yüklendi</h3>
            <p><strong>Dosya Adı:</strong> #uploadedFileName#</p>
            <p><strong>Dosya Boyutu:</strong> #numberFormat(cffile.fileSize/1024, "999,999")# KB</p>
        </div>
        
        <!--- Excel dosyasını okuma --->
        <cftry>
            <!--- Excel dosyasını oku --->
            <cfspreadsheet action="read"
                          src="#uploadPath##uploadedFileName#"
                          query="excelData"
                          headerrow="1"
                          sheet="1">
            
            <!--- Veri kontrolü --->
            <cfif excelData.recordCount GT 0>
                
                <cfset showPreview = true>
                <cfset totalRows = excelData.recordCount>
                
                <!--- Önizleme verilerini hazırla --->
                <cfset validRowCount = 0>
                <cfset invalidRowCount = 0>
                
                <!--- Kolon isimlerini al --->
                <cfset columnList = excelData.columnList>
                <cfset hasEtaKodu = listFindNoCase(columnList, "ETA KODU") OR listFindNoCase(columnList, "ETA_KODU")>
                
                <!--- ETA KODU kolon adını standartlaştır --->
                <cfset etaKoduColumn = "">
                <cfif listFindNoCase(columnList, "ETA KODU")>
                    <cfset etaKoduColumn = "ETA KODU">
                <cfelseif listFindNoCase(columnList, "ETA_KODU")>
                    <cfset etaKoduColumn = "ETA_KODU">
                </cfif>
                
                <cfloop query="excelData">
                    <!--- ETA_KODU kontrolü --->
                    <cfif hasEtaKodu AND len(trim(excelData[etaKoduColumn][currentRow]))>
                        <cfset validRowCount = validRowCount + 1>
                    <cfelse>
                        <cfset invalidRowCount = invalidRowCount + 1>
                    </cfif>
                </cfloop>
                
                <!--- İstatistikleri göster --->
                <div class="stats-summary">
                    <h3>📈 Veri Özeti</h3>
                    <div class="stats-grid">
                        <div class="stat-item">
                            <div class="stat-number">#totalRows#</div>
                            <div class="stat-label">Toplam Satır</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-number">#validRowCount#</div>
                            <div class="stat-label">Geçerli Kayıt</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-number">#invalidRowCount#</div>
                            <div class="stat-label">Eksik ETA_KODU</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-number">#listLen(columnList)#</div>
                            <div class="stat-label">Kolon Sayısı</div>
                        </div>
                    </div>
                </div>
                
                <cfif NOT hasEtaKodu>
                    <div class="error-box">
                        <h4>❌ Kritik Hata</h4>
                        <p>Excel dosyasında <strong>ETA KODU</strong> veya <strong>ETA_KODU</strong> kolonu bulunamadı. Bu kolon zorunludur.</p>
                    </div>
                <cfelseif invalidRowCount GT 0>
                    <div class="warning-box">
                        <h4>⚠️ Uyarı</h4>
                        <p><strong>#invalidRowCount#</strong> satırda ETA_KODU boş. Bu kayıtlar işlenmeyecek.</p>
                    </div>
                </cfif>
                
                <!--- Veri önizlemesi --->
                <div class="info-box">
                    <h3>👀 Veri Önizlemesi</h3>
                    <p>Aşağıda Excel dosyanızın ilk 10 satırı gösterilmektedir. Verileri kontrol edin ve onaylayın.</p>
                </div>
                
                <div class="table-wrapper">
                    <table class="preview-table">
                        <thead>
                            <tr>
                                <th style="background: #dc3545;">Satır</th>
                                <cfloop list="#columnList#" index="columnName">
                                    <th <cfif columnName EQ "ETA KODU" OR columnName EQ "ETA_KODU">class="required-column"</cfif>>
                                      <cfoutput>  #columnName#</cfoutput>
                                        <cfif columnName EQ "ETA KODU" OR columnName EQ "ETA_KODU">*</cfif>
                                    </th>
                                </cfloop>
                            </tr>
                        </thead>
                        <tbody>
                            <cfloop query="excelData" startrow="1" endrow="#min(10, excelData.recordCount)#">
                                <tr>
                                    <td style="background: #f8f9fa; font-weight: bold;"><cfoutput>#currentRow#</cfoutput></td>
                                    <cfloop list="#columnList#" index="columnName">
                                        <cfset cellValue = excelData[columnName][currentRow]>
                                        <td <cfif (columnName EQ "ETA KODU" OR columnName EQ "ETA_KODU") AND NOT len(trim(cellValue))>class="required-column"</cfif>
                                            <cfif NOT len(trim(cellValue))>class="empty-cell"</cfif>>
                                            <cfif len(trim(cellValue))>
                                               <cfoutput> #htmlEditFormat(cellValue)#</cfoutput>
                                            <cfelse>
                                                (boş)
                                            </cfif>
                                        </td>
                                    </cfloop>
                                </tr>
                            </cfloop>
                        </tbody>
                    </table>
                </div>
                
                <cfif excelData.recordCount GT 10>
                    <p style="text-align: center; color: #666; font-style: italic;">
                       <cfoutput>  ... ve #excelData.recordCount - 10# satır daha var</cfoutput>
                    </p>
                </cfif>
                
                <!--- Onay butonları --->
                <cfif hasEtaKodu AND validRowCount GT 0>
                    <form method="post" action="import_excel_preview.cfm">
                        <input type="hidden" name="confirmImport" value="true">
                        <input type="hidden" name="uploadedFile" value="<cfoutput>#uploadedFileName#</cfoutput>">
                        
                        <div class="button-group">
                            <button type="submit" class="btn btn-success">
                                ✅ Onayla ve Veritabanına Aktar (<cfoutput>#validRowCount#</cfoutput> kayıt)
                            </button>
                            <a href="upload_excel.cfm" class="btn btn-secondary">
                                🔙 İptal Et
                            </a>
                        </div>
                    </form>
                <cfelse>
                    <div class="button-group">
                        <a href="upload_excel.cfm" class="btn btn-secondary">
                            🔙 Yeni Dosya Seç
                        </a>
                    </div>
                </cfif>
                
            <cfelse>
                <cfset errorMessage = "Excel dosyası boş veya okunamıyor.">
            </cfif>
            
            <cfcatch type="any">
                <cfset errorMessage = "Excel dosyası okunurken hata oluştu: #cfcatch.message#">
            </cfcatch>
        </cftry>
        
        <cfcatch type="any">
            <cfset errorMessage = "Dosya yüklenirken hata oluştu: #cfcatch.message#">
        </cfcatch>
    </cftry>
    
<cfelse>
    <cfset errorMessage = "Dosya seçilmedi.">
</cfif>

<!--- Hata durumu --->
<cfif len(errorMessage)>
    <div class="error-box">
        <h3>❌ Hata Oluştu</h3>
       <cfoutput> <p>#errorMessage#</p></cfoutput>
    </div>
    
    <div class="button-group">
        <a href="upload_excel.cfm" class="btn btn-primary">🔙 Tekrar Dene</a>
    </div>
</cfif>

<!--- İçe aktarım başarılı ise tekrar yükleme linki --->
<cfif importSuccess>
    <div class="button-group">
        <a href="upload_excel.cfm" class="btn btn-primary">📄 Yeni Dosya Yükle</a>
    </div>
</cfif>

    </div>
</body>
</html>
