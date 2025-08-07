<!---
    CFML Excel Import Script
    Bu dosya upload_excel.cfm'den gelen Excel dosyasını işler ve PRODUCT_OEMS tablosuna aktarır
--->

<cfparam name="form.excelFile" default="">

<!--- Sayfa başlangıç ayarları --->
<cfsetting requesttimeout="300" showdebugoutput="false">

<!--- Veritabanı bağlantı ayarları (projenize göre düzenleyin) --->
<cfset dsn = "YOUR_DSN">

<!--- Upload klasörü ayarları --->
<cfset uploadPath = expandPath("./uploads/")>
<cfset allowedExtensions = "xlsx,xls">
<cfset maxFileSize = 10485760> <!--- 10MB --->

<!--- Sonuç değişkenleri --->
<cfset uploadSuccess = false>
<cfset importSuccess = false>
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
    <title>Excel İçe Aktarım Sonucu</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
        }
        
        .container {
            max-width: 900px;
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
        
        .back-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 8px;
            text-decoration: none;
            display: inline-block;
            margin-top: 20px;
            transition: all 0.3s ease;
        }
        
        .back-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }
        
        .stat-card {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
            border: 1px solid #dee2e6;
        }
        
        .stat-number {
            font-size: 2em;
            font-weight: bold;
            margin-bottom: 10px;
        }
        
        .stat-success { color: #28a745; }
        .stat-error { color: #dc3545; }
        .stat-total { color: #667eea; }
        
        .error-details {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 20px;
            margin-top: 20px;
            max-height: 300px;
            overflow-y: auto;
        }
        
        .error-item {
            background: white;
            padding: 10px;
            margin-bottom: 10px;
            border-left: 3px solid #dc3545;
            border-radius: 5px;
        }
        
        .progress-indicator {
            text-align: center;
            margin: 30px 0;
        }
        
        .spinner {
            border: 4px solid #f3f3f3;
            border-top: 4px solid #667eea;
            border-radius: 50%;
            width: 50px;
            height: 50px;
            animation: spin 1s linear infinite;
            margin: 0 auto 20px;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 Excel İçe Aktarım Sonucu</h1>
        </div>

<!--- Dosya yükleme işlemi --->
<cfif len(trim(form.excelFile))>
    <cftry>
        <!--- Dosya yükleme --->
        <cffile action="upload"
                filefield="excelFile"
                destination="#uploadPath#"
                nameconflict="makeunique"
                accept="#allowedExtensions#">
        
        <cfset uploadedFileName = cffile.serverFile>
        <cfset uploadSuccess = true>
        
        <div class="success-box">
            <h3>✅ Dosya Başarıyla Yüklendi</h3>
            <p><strong>Dosya Adı:</strong> #uploadedFileName#</p>
            <p><strong>Dosya Boyutu:</strong> #numberFormat(cffile.fileSize/1024, "999,999")# KB</p>
        </div>
        
        <div class="progress-indicator">
            <div class="spinner"></div>
            <p>Excel dosyası işleniyor ve veritabanına aktarılıyor...</p>
        </div>
        
        <!--- Excel dosyasını okuma ve veritabanına aktarma --->
        <cftry>
            <!--- Excel dosyasını oku --->
            <cfspreadsheet action="read"
                          src="#uploadPath##uploadedFileName#"
                          query="excelData"
                          headerrow="1"
                          sheet="1">
            
            <!--- Veri kontrolü --->
            <cfif excelData.recordCount GT 0>
                
                <!--- İstatistikler için sayaçlar --->
                <cfset totalRows = excelData.recordCount>
                <cfset successCount = 0>
                <cfset errorCount = 0>
                <cfset errorDetails = arrayNew(1)>
                
                <!--- Her satır için veritabanı işlemi --->
                <cfloop query="excelData">
                    <cftry>
                        <!--- ETA_KODU kontrolü (zorunlu alan) --->
                        <cfif isDefined("excelData.ETA_KODU") AND len(trim(excelData.ETA_KODU))>
                            
                            <!--- PRODUCT_OEMS tablosuna INSERT --->
                            <cfquery name="insertQuery" datasource="#dsn#">
                                INSERT INTO PRODUCT_OEMS (
                                    ETA_KODU
                                    <cfif isDefined("excelData.OEM_1") AND len(trim(excelData.OEM_1))>, OEM_1</cfif>
                                    <cfif isDefined("excelData.OEM_2") AND len(trim(excelData.OEM_2))>, OEM_2</cfif>
                                    <cfif isDefined("excelData.OEM_3") AND len(trim(excelData.OEM_3))>, OEM_3</cfif>
                                    <cfif isDefined("excelData.OEM_4") AND len(trim(excelData.OEM_4))>, OEM_4</cfif>
                                    <cfif isDefined("excelData.OEM_5") AND len(trim(excelData.OEM_5))>, OEM_5</cfif>
                                    <cfif isDefined("excelData.OEM_6") AND len(trim(excelData.OEM_6))>, OEM_6</cfif>
                                    <cfif isDefined("excelData.OEM_7") AND len(trim(excelData.OEM_7))>, OEM_7</cfif>
                                    <cfif isDefined("excelData.OEM_8") AND len(trim(excelData.OEM_8))>, OEM_8</cfif>
                                    <cfif isDefined("excelData.OEM_9") AND len(trim(excelData.OEM_9))>, OEM_9</cfif>
                                    <cfif isDefined("excelData.OEM_10") AND len(trim(excelData.OEM_10))>, OEM_10</cfif>
                                    <cfif isDefined("excelData.OEM_11") AND len(trim(excelData.OEM_11))>, OEM_11</cfif>
                                    <cfif isDefined("excelData.OEM_12") AND len(trim(excelData.OEM_12))>, OEM_12</cfif>
                                    <cfif isDefined("excelData.OEM_13") AND len(trim(excelData.OEM_13))>, OEM_13</cfif>
                                    <cfif isDefined("excelData.OEM_14") AND len(trim(excelData.OEM_14))>, OEM_14</cfif>
                                    <cfif isDefined("excelData.OEM_15") AND len(trim(excelData.OEM_15))>, OEM_15</cfif>
                                    <cfif isDefined("excelData.OEM_16") AND len(trim(excelData.OEM_16))>, OEM_16</cfif>
                                    <cfif isDefined("excelData.OEM_17") AND len(trim(excelData.OEM_17))>, OEM_17</cfif>
                                    <cfif isDefined("excelData.OEM_18") AND len(trim(excelData.OEM_18))>, OEM_18</cfif>
                                    <cfif isDefined("excelData.OEM_19") AND len(trim(excelData.OEM_19))>, OEM_19</cfif>
                                    <cfif isDefined("excelData.OEM_20") AND len(trim(excelData.OEM_20))>, OEM_20</cfif>
                                    <cfif isDefined("excelData.OEM_21") AND len(trim(excelData.OEM_21))>, OEM_21</cfif>
                                    <cfif isDefined("excelData.OEM_22") AND len(trim(excelData.OEM_22))>, OEM_22</cfif>
                                    <cfif isDefined("excelData.OEM_23") AND len(trim(excelData.OEM_23))>, OEM_23</cfif>
                                    <cfif isDefined("excelData.OEM_24") AND len(trim(excelData.OEM_24))>, OEM_24</cfif>
                                    <cfif isDefined("excelData.OEM_25") AND len(trim(excelData.OEM_25))>, OEM_25</cfif>
                                    <cfif isDefined("excelData.OEM_26") AND len(trim(excelData.OEM_26))>, OEM_26</cfif>
                                    <cfif isDefined("excelData.OEM_27") AND len(trim(excelData.OEM_27))>, OEM_27</cfif>
                                    <cfif isDefined("excelData.OEM_28") AND len(trim(excelData.OEM_28))>, OEM_28</cfif>
                                    <cfif isDefined("excelData.OEM_29") AND len(trim(excelData.OEM_29))>, OEM_29</cfif>
                                    <cfif isDefined("excelData.OEM_30") AND len(trim(excelData.OEM_30))>, OEM_30</cfif>
                                    <cfif isDefined("excelData.OEM_31") AND len(trim(excelData.OEM_31))>, OEM_31</cfif>
                                    <cfif isDefined("excelData.OEM_32") AND len(trim(excelData.OEM_32))>, OEM_32</cfif>
                                    <cfif isDefined("excelData.OEM_33") AND len(trim(excelData.OEM_33))>, OEM_33</cfif>
                                    <cfif isDefined("excelData.OEM_34") AND len(trim(excelData.OEM_34))>, OEM_34</cfif>
                                    <cfif isDefined("excelData.OEM_35") AND len(trim(excelData.OEM_35))>, OEM_35</cfif>
                                    <cfif isDefined("excelData.OEM_36") AND len(trim(excelData.OEM_36))>, OEM_36</cfif>
                                    <cfif isDefined("excelData.OEM_37") AND len(trim(excelData.OEM_37))>, OEM_37</cfif>
                                    <cfif isDefined("excelData.OEM_38") AND len(trim(excelData.OEM_38))>, OEM_38</cfif>
                                    <cfif isDefined("excelData.OEM_39") AND len(trim(excelData.OEM_39))>, OEM_39</cfif>
                                    <cfif isDefined("excelData.OEM_40") AND len(trim(excelData.OEM_40))>, OEM_40</cfif>
                                    <cfif isDefined("excelData.OEM_41") AND len(trim(excelData.OEM_41))>, OEM_41</cfif>
                                    <cfif isDefined("excelData.OEM_42") AND len(trim(excelData.OEM_42))>, OEM_42</cfif>
                                    <cfif isDefined("excelData.OEM_43") AND len(trim(excelData.OEM_43))>, OEM_43</cfif>
                                    <cfif isDefined("excelData.OEM_44") AND len(trim(excelData.OEM_44))>, OEM_44</cfif>
                                    <cfif isDefined("excelData.OEM_45") AND len(trim(excelData.OEM_45))>, OEM_45</cfif>
                                    <cfif isDefined("excelData.OEM_46") AND len(trim(excelData.OEM_46))>, OEM_46</cfif>
                                    <cfif isDefined("excelData.OEM_47") AND len(trim(excelData.OEM_47))>, OEM_47</cfif>
                                    <cfif isDefined("excelData.OEM_48") AND len(trim(excelData.OEM_48))>, OEM_48</cfif>
                                    <cfif isDefined("excelData.OEM_49") AND len(trim(excelData.OEM_49))>, OEM_49</cfif>
                                    <cfif isDefined("excelData.OEM_50") AND len(trim(excelData.OEM_50))>, OEM_50</cfif>
                                ) VALUES (
                                    <cfqueryparam value="#trim(excelData.ETA_KODU)#" cfsqltype="cf_sql_varchar">
                                    <cfif isDefined("excelData.OEM_1") AND len(trim(excelData.OEM_1))>, <cfqueryparam value="#trim(excelData.OEM_1)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_2") AND len(trim(excelData.OEM_2))>, <cfqueryparam value="#trim(excelData.OEM_2)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_3") AND len(trim(excelData.OEM_3))>, <cfqueryparam value="#trim(excelData.OEM_3)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_4") AND len(trim(excelData.OEM_4))>, <cfqueryparam value="#trim(excelData.OEM_4)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_5") AND len(trim(excelData.OEM_5))>, <cfqueryparam value="#trim(excelData.OEM_5)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_6") AND len(trim(excelData.OEM_6))>, <cfqueryparam value="#trim(excelData.OEM_6)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_7") AND len(trim(excelData.OEM_7))>, <cfqueryparam value="#trim(excelData.OEM_7)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_8") AND len(trim(excelData.OEM_8))>, <cfqueryparam value="#trim(excelData.OEM_8)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_9") AND len(trim(excelData.OEM_9))>, <cfqueryparam value="#trim(excelData.OEM_9)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_10") AND len(trim(excelData.OEM_10))>, <cfqueryparam value="#trim(excelData.OEM_10)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_11") AND len(trim(excelData.OEM_11))>, <cfqueryparam value="#trim(excelData.OEM_11)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_12") AND len(trim(excelData.OEM_12))>, <cfqueryparam value="#trim(excelData.OEM_12)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_13") AND len(trim(excelData.OEM_13))>, <cfqueryparam value="#trim(excelData.OEM_13)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_14") AND len(trim(excelData.OEM_14))>, <cfqueryparam value="#trim(excelData.OEM_14)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_15") AND len(trim(excelData.OEM_15))>, <cfqueryparam value="#trim(excelData.OEM_15)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_16") AND len(trim(excelData.OEM_16))>, <cfqueryparam value="#trim(excelData.OEM_16)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_17") AND len(trim(excelData.OEM_17))>, <cfqueryparam value="#trim(excelData.OEM_17)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_18") AND len(trim(excelData.OEM_18))>, <cfqueryparam value="#trim(excelData.OEM_18)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_19") AND len(trim(excelData.OEM_19))>, <cfqueryparam value="#trim(excelData.OEM_19)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_20") AND len(trim(excelData.OEM_20))>, <cfqueryparam value="#trim(excelData.OEM_20)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_21") AND len(trim(excelData.OEM_21))>, <cfqueryparam value="#trim(excelData.OEM_21)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_22") AND len(trim(excelData.OEM_22))>, <cfqueryparam value="#trim(excelData.OEM_22)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_23") AND len(trim(excelData.OEM_23))>, <cfqueryparam value="#trim(excelData.OEM_23)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_24") AND len(trim(excelData.OEM_24))>, <cfqueryparam value="#trim(excelData.OEM_24)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_25") AND len(trim(excelData.OEM_25))>, <cfqueryparam value="#trim(excelData.OEM_25)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_26") AND len(trim(excelData.OEM_26))>, <cfqueryparam value="#trim(excelData.OEM_26)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_27") AND len(trim(excelData.OEM_27))>, <cfqueryparam value="#trim(excelData.OEM_27)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_28") AND len(trim(excelData.OEM_28))>, <cfqueryparam value="#trim(excelData.OEM_28)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_29") AND len(trim(excelData.OEM_29))>, <cfqueryparam value="#trim(excelData.OEM_29)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_30") AND len(trim(excelData.OEM_30))>, <cfqueryparam value="#trim(excelData.OEM_30)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_31") AND len(trim(excelData.OEM_31))>, <cfqueryparam value="#trim(excelData.OEM_31)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_32") AND len(trim(excelData.OEM_32))>, <cfqueryparam value="#trim(excelData.OEM_32)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_33") AND len(trim(excelData.OEM_33))>, <cfqueryparam value="#trim(excelData.OEM_33)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_34") AND len(trim(excelData.OEM_34))>, <cfqueryparam value="#trim(excelData.OEM_34)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_35") AND len(trim(excelData.OEM_35))>, <cfqueryparam value="#trim(excelData.OEM_35)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_36") AND len(trim(excelData.OEM_36))>, <cfqueryparam value="#trim(excelData.OEM_36)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_37") AND len(trim(excelData.OEM_37))>, <cfqueryparam value="#trim(excelData.OEM_37)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_38") AND len(trim(excelData.OEM_38))>, <cfqueryparam value="#trim(excelData.OEM_38)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_39") AND len(trim(excelData.OEM_39))>, <cfqueryparam value="#trim(excelData.OEM_39)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_40") AND len(trim(excelData.OEM_40))>, <cfqueryparam value="#trim(excelData.OEM_40)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_41") AND len(trim(excelData.OEM_41))>, <cfqueryparam value="#trim(excelData.OEM_41)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_42") AND len(trim(excelData.OEM_42))>, <cfqueryparam value="#trim(excelData.OEM_42)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_43") AND len(trim(excelData.OEM_43))>, <cfqueryparam value="#trim(excelData.OEM_43)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_44") AND len(trim(excelData.OEM_44))>, <cfqueryparam value="#trim(excelData.OEM_44)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_45") AND len(trim(excelData.OEM_45))>, <cfqueryparam value="#trim(excelData.OEM_45)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_46") AND len(trim(excelData.OEM_46))>, <cfqueryparam value="#trim(excelData.OEM_46)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_47") AND len(trim(excelData.OEM_47))>, <cfqueryparam value="#trim(excelData.OEM_47)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_48") AND len(trim(excelData.OEM_48))>, <cfqueryparam value="#trim(excelData.OEM_48)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_49") AND len(trim(excelData.OEM_49))>, <cfqueryparam value="#trim(excelData.OEM_49)#" cfsqltype="cf_sql_varchar"></cfif>
                                    <cfif isDefined("excelData.OEM_50") AND len(trim(excelData.OEM_50))>, <cfqueryparam value="#trim(excelData.OEM_50)#" cfsqltype="cf_sql_varchar"></cfif>
                                )
                            </cfquery>
                            
                            <cfset successCount = successCount + 1>
                            
                        <cfelse>
                            <!--- ETA_KODU boş ise hata kaydet --->
                            <cfset errorCount = errorCount + 1>
                            <cfset arrayAppend(errorDetails, "Satır #currentRow#: ETA_KODU boş veya geçersiz")>
                        </cfif>
                        
                        <cfcatch type="any">
                            <!--- Veritabanı hatası --->
                            <cfset errorCount = errorCount + 1>
                            <cfset arrayAppend(errorDetails, "Satır #currentRow#: #cfcatch.message# - #cfcatch.detail#")>
                        </cfcatch>
                    </cftry>
                </cfloop>
                
                <cfset importSuccess = true>
                
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

<!--- Sonuçları göster --->
<cfif uploadSuccess AND importSuccess>
    
    <div class="success-box">
        <h3>🎉 İçe Aktarım Başarıyla Tamamlandı!</h3>
        <p>Excel dosyasındaki veriler PRODUCT_OEMS tablosuna aktarıldı.</p>
    </div>
    
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-number stat-total">#totalRows#</div>
            <div>Toplam Satır</div>
        </div>
        <div class="stat-card">
            <div class="stat-number stat-success">#successCount#</div>
            <div>Başarılı</div>
        </div>
        <div class="stat-card">
            <div class="stat-number stat-error">#errorCount#</div>
            <div>Hatalı</div>
        </div>
    </div>
    
    <cfif errorCount GT 0>
        <div class="error-box">
            <h4>⚠️ Bazı Satırlarda Hata Oluştu</h4>
            <p>#errorCount# satır işlenemedi. Detayları aşağıda görebilirsiniz:</p>
        </div>
        
        <div class="error-details">
            <h4>Hata Detayları:</h4>
            <cfloop array="#errorDetails#" index="errorDetail">
                <div class="error-item">
                    #errorDetail#
                </div>
            </cfloop>
        </div>
    </cfif>

<cfelseif len(errorMessage)>
    
    <div class="error-box">
        <h3>❌ Hata Oluştu</h3>
        <p>#errorMessage#</p>
    </div>
    
<cfelse>
    
    <div class="info-box">
        <h3>ℹ️ Bilgi</h3>
        <p>Henüz bir dosya yüklenmedi veya işlem tamamlanmadı.</p>
    </div>
    
</cfif>

        <div style="text-align: center;">
            <a href="upload_excel.cfm" class="back-btn">🔙 Yeni Dosya Yükle</a>
        </div>
        
    </div>
    
    <script>
        // Sayfa yüklendiğinde spinner'ı gizle
        document.addEventListener('DOMContentLoaded', function() {
            const spinner = document.querySelector('.progress-indicator');
            if (spinner) {
                setTimeout(function() {
                    spinner.style.display = 'none';
                }, 2000);
            }
        });
    </script>
</body>
</html>
