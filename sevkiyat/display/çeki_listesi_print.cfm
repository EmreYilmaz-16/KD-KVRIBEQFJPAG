
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <title>Çeki Listesi</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB" crossorigin="anonymous">
    <style>
        @media print {
            .no-print { display: none; }
            body { margin: 0; padding: 5mm; }
        }
        
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #fff;
        }
        
        .container {
            max-width: 100%;
            margin: 0;
            padding: 10px;
        }
        
        .header {
            text-align: center;
            border-bottom: 2px solid #333;
            padding-bottom: 15px;
            margin-bottom: 20px;
        }
        
        .header h1 {
            margin: 0;
            font-size: 24px;
            color: #333;
        }
        
        .summary-box {
            background-color: #f5f5f5;
            padding: 15px;
            margin-bottom: 20px;
            border: 1px solid #ddd;
        }
        
        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 15px;
        }
        
        .summary-item {
            padding: 8px;
        }
        
        .summary-label {
            font-weight: bold;
            font-size: 11px;
            color: #666;
            margin-bottom: 3px;
        }
        
        .summary-value {
            font-size: 14px;
            font-weight: bold;
            color: #000;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
            font-size: 12px;
        }
        
        thead {
            background-color: #333;
            color: white;
        }
        
        th {
            padding: 10px 8px;
            text-align: center;
            font-weight: bold;
            border: 1px solid #333;
        }
        
        td {
            padding: 8px;
            border: 1px solid #ddd;
            text-align: center;
        }
        
        tbody tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        
        .pallet-cell {
            background-color: #ddd;
            font-weight: bold;
            font-size: 14px;
            vertical-align: middle;
        }
        
        .total-cell {
            background-color: #e8f5e9;
            font-weight: bold;
            vertical-align: middle;
        }
        
        .product-code {
            font-weight: bold;
        }
        
        .footer {
            margin-top: 30px;
            padding-top: 15px;
            border-top: 1px solid #ddd;
            text-align: center;
            color: #666;
            font-size: 11px;
        }
        
        .print-button {
            background-color: #333;
            color: white;
            padding: 10px 25px;
            border: none;
            cursor: pointer;
            font-size: 14px;
            margin-bottom: 20px;
        }
        
        .print-button:hover {
            background-color: #555;
        }
        
        .button-container {
            text-align: center;
            margin-bottom: 20px;
        }
        
        .top-section {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 20px;
            padding: 15px;
            background-color: #f5f5f5;
            border: 2px solid #333;
        }
        
        .logo-area {
            display: flex;
            gap: 20px;
            align-items: center;
            flex: 1;
        }
        
        .logo-box {
            padding: 10px;
            background: white;
            border: 1px solid #ddd;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .logo-box img {
            max-height: 60px;
            max-width: 150px;
            object-fit: contain;
        }
        
        .logo-text {
            font-weight: bold;
            font-size: 18px;
            color: #2c5282;
        }
        
        .company-name {
            font-size: 14px;
            color: #666;
            margin-top: 3px;
        }
        
        .title-box {
            background-color: #2c5282;
            color: white;
            padding: 15px 30px;
            text-align: center;
            font-size: 20px;
            font-weight: bold;
            letter-spacing: 3px;
        }
        
        .customer-info-section {
            display: flex;
            justify-content: space-between;
            margin-bottom: 20px;
            gap: 20px;
        }
        
        .customer-box {
            flex: 1;
            border: 2px solid #333;
            padding: 15px;
            background-color: #f9f9f9;
        }
        
        .customer-title {
            font-weight: bold;
            font-size: 16px;
            margin-bottom: 10px;
            color: #333;
            border-bottom: 2px solid #333;
            padding-bottom: 5px;
        }
        
        .customer-details {
            font-size: 13px;
            line-height: 1.6;
        }
        
        .date-box {
            border: 2px solid #333;
            padding: 15px;
            background-color: #f9f9f9;
            min-width: 200px;
        }
        
        .date-label {
            font-weight: bold;
            font-size: 14px;
            color: #333;
        }
        
        .date-value {
            font-size: 16px;
            font-weight: bold;
            margin-top: 5px;
        }
    </style>
</head>
<body>
<cfset dsn3="w3Qa_1">
<cfset dsn="w3Qa">
<cfquery name="getPalletInfo" datasource="#dsn3#">
    SELECT DISTINCT 
        SPB.PALLET_CODE,
        SPB.PALLET_TYPE,
        SPB.MAIN_PALET_ID,
        SP.ORDER_ID,
        O.COMPANY_ID,
        O.SHIP_ADDRESS_ID,
        C.NICKNAME,
        C.COMPANY_ADDRESS,
        C.FIRMA_ULKE_ADI,
        C.FIRMA_IL_ADI,
        C.FIRMA_ILCE_ADI,
        SUBE_BILGI.COMPBRANCH__NAME,
        SUBE_BILGI.COMPBRANCH_ADDRESS,
        SUBE_BILGI.SUBE_ULKE_ADI,
        SUBE_BILGI.SUBE_IL_ADI,
        SUBE_BILGI.SUBE_ILCE_ADI
    FROM [w3Qa_1].[SHIPPING_PALLET_SVK_PBS] SP
    LEFT JOIN w3Qa_1.EZGI_SHIP_RESULT AS ESR ON ESR.SHIP_RESULT_ID=SP.ORDER_ID
    LEFT JOIN w3Qa_1.EZGI_SHIP_RESULT_ROW AS ESRR ON ESRR.SHIP_RESULT_ID=SP.ORDER_ID
    LEFT JOIN w3Qa_1.ORDERS AS O ON O.ORDER_ID=ESRR.ORDER_ID
    LEFT JOIN w3Qa_1.SHIPPING_PALLETS_PBS SPB ON SPB.ID=SP.PALLET_ID
    LEFT JOIN (
        SELECT 
            COMPANY_ID,
            COMPANY_ADDRESS,
            NICKNAME,
            SCO.COUNTRY_NAME AS FIRMA_ULKE_ADI,
            SC.CITY_NAME AS FIRMA_IL_ADI,
            SCN.COUNTY_NAME AS FIRMA_ILCE_ADI
        FROM w3Qa.COMPANY CB 
        LEFT JOIN w3Qa.SETUP_COUNTRY AS SCO ON SCO.COUNTRY_ID=CB.COUNTRY 
        LEFT JOIN w3Qa.SETUP_CITY AS SC ON SC.CITY_ID=CB.CITY
        LEFT JOIN w3Qa.SETUP_COUNTY AS SCN ON SCN.COUNTY_ID=CB.COUNTY
    ) AS C ON C.COMPANY_ID=O.COMPANY_ID
    LEFT JOIN (
        SELECT 
            COMPBRANCH_ID,
            COMPBRANCH_ADDRESS,
            COMPBRANCH__NAME,
            SCO.COUNTRY_NAME AS SUBE_ULKE_ADI,
            SC.CITY_NAME AS SUBE_IL_ADI,
            SCN.COUNTY_NAME AS SUBE_ILCE_ADI
        FROM w3Qa.COMPANY_BRANCH CB 
        LEFT JOIN w3Qa.SETUP_COUNTRY AS SCO ON SCO.COUNTRY_ID=CB.COUNTRY_ID 
        LEFT JOIN w3Qa.SETUP_CITY AS SC ON SC.CITY_ID=CB.CITY_ID 
        LEFT JOIN w3Qa.SETUP_COUNTY AS SCN ON SCN.COUNTY_ID=CB.COUNTY_ID
    ) AS SUBE_BILGI ON SUBE_BILGI.COMPBRANCH_ID=O.SHIP_ADDRESS_ID
    WHERE SP.PALLET_ID IN (
        SELECT ID FROM w3Qa_1.SHIPPING_PALLETS_PBS 
        WHERE ID=<cfqueryparam value="#Val(attributes.pallet_id)#" cfsqltype="cf_sql_integer"> 
        OR MAIN_PALET_ID=<cfqueryparam value="#Val(attributes.pallet_id)#" cfsqltype="cf_sql_integer">
    )
</cfquery>

<cfif len(getPalletInfo.MAIN_PALET_ID) eq 0>
    <cfquery name="getSubPalletRows" datasource="#dsn3#">
    SELECT 
S.STOCK_ID,
S.PRODUCT_CODE_2,
S.PRODUCT_NAME,SUM(AMOUNT)AS MIKTAR,SPR.PALLET_ID,ISNULL(SP.PALLET_NUMBER,1) PALLET_NUMBER,S.PRODUCT_ID,PU.WEIGHT,
PU.WEIGHT*SUM(AMOUNT) AS TW
FROM [w3Qa_1].[SHIPPING_PALLET_ROWS_PBS] AS SPR 
LEFT JOIN [w3Qa_1].[STOCKS] AS S ON S.STOCK_ID=SPR.STOCK_ID
LEFT JOIN [w3Qa_1].[SHIPPING_PALLETS_PBS] AS SP ON SP.ID=SPR.PALLET_ID
LEFT JOIN w3Qa_1.PRODUCT_UNIT AS PU ON PU.PRODUCT_ID=S.PRODUCT_ID
WHERE SP.MAIN_PALET_ID=<cfqueryparam value="#Val(attributes.pallet_id)#" cfsqltype="cf_sql_integer"> OR SP.ID=<cfqueryparam value="#Val(attributes.pallet_id)#" cfsqltype="cf_sql_integer">
GROUP BY 
S.STOCK_ID,S.PRODUCT_CODE_2,S.PRODUCT_NAME,SPR.PALLET_ID,SP.PALLET_NUMBER,S.PRODUCT_ID,PU.WEIGHT
ORDER BY PALLET_NUMBER        
    </cfquery>
    <cfelse>
    <cfquery name="getSubPalletRows" datasource="#dsn3#">
    SELECT 
    SPR.PALLET_ID,
S.STOCK_ID,     
S.PRODUCT_CODE_2,
S.PRODUCT_NAME,SUM(AMOUNT)AS MIKTAR,SPR.PALLET_ID,ISNULL(SP.PALLET_NUMBER,1) PALLET_NUMBER,S.PRODUCT_ID,PU.WEIGHT,
PU.WEIGHT*SUM(AMOUNT) AS TW
FROM [w3Qa_1].[SHIPPING_PALLET_ROWS_PBS] AS SPR
LEFT JOIN [w3Qa_1].[STOCKS] AS S ON S.STOCK_ID=SPR.STOCK_ID
LEFT JOIN [w3Qa_1].[SHIPPING_PALLETS_PBS] AS SP
ON SP.ID=SPR.PALLET_ID
LEFT JOIN w3Qa_1.PRODUCT_UNIT AS PU ON PU.PRODUCT_ID=S.PRODUCT_ID
WHERE SP.ID=<cfqueryparam value="#Val(attributes.pallet_id)#" cfsqltype="cf_sql_integer">
GROUP BY
S.STOCK_ID,     
S.PRODUCT_CODE_2,
S.PRODUCT_NAME,SPR.PALLET_ID,SP.PALLET_NUMBER,S.PRODUCT_ID,PU.WEIGHT
ORDER BY PALLET_NUMBER
        </cfquery>

</cfif>

<cfset totalWeight = 0>
<cfset palletCount = 0>
<cfset palletTws = StructNew()>
<cfloop query="getSubPalletRows">
    <cfset totalWeight = totalWeight + TW>
    <cfset palletCount = palletCount + 1>
    <cfif StructKeyExists(palletTws, getSubPalletRows.PALLET_ID)>
        <cfset palletTws[getSubPalletRows.PALLET_ID] = palletTws[getSubPalletRows.PALLET_ID] + TW>
    <cfelse>
        <cfset palletTws[getSubPalletRows.PALLET_ID] = TW>
    </cfif>


</cfloop>
<cfset totalWeightFormatted = NumberFormat(totalWeight, "9,999,999.99")>
<cfset palletCountFormatted = NumberFormat(palletCount, "9,999,999")>
<cfset currentDateTime = DateFormat(Now(), "dd.mm.yyyy") & " " & TimeFormat(Now(), "HH:mm:ss")>
<cfset palletCode = getPalletInfo.PALLET_CODE>
<cfset palletType = getPalletInfo.PALLET_TYPE>

<div class="container">
    <div class="button-container no-print">
        <button class="print-button" onclick="window.print()">Yazdır</button>
    </div>
    
    <div class="top-section">
        <div class="logo-area">
            <div class="logo-box">
                <img src="https://www.kacmazlar.com/Storage/Hotload/Upload/DirectUpload/kdtekniklogo.png" alt="KD TEKNİK">
            </div>
            <div class="logo-box">
                <img src="https://www.kacmazlar.com/Storage/Hotload/Upload/General/kacmazlar-logo.png" alt="KAÇMAZLAR">
            </div>
            <div class="logo-box">
                <img src="https://www.kdteknik.com.tr/upload/bayiler/reliable-logo.png" alt="RELIABLE">
            </div>
        </div>
        <div class="title-box">
            ÇEKİ LİSTESİ
        </div>
    </div>
    
    <div class="customer-info-section">
        <div class="customer-box">
            <div class="customer-title">MÜŞTERİ</div>
            <div class="customer-details">
                <cfoutput>
                    <cfif len(trim(getPalletInfo.SHIP_ADDRESS_ID)) and len(trim(getPalletInfo.COMPBRANCH__NAME))>
                        <!--- Şube bilgileri varsa şubeyi göster --->
                        <strong>#getPalletInfo.NICKNAME#-#getPalletInfo.COMPBRANCH__NAME#</strong><br>
                        <cfif len(trim(getPalletInfo.COMPBRANCH_ADDRESS))>
                            #getPalletInfo.COMPBRANCH_ADDRESS#<br>
                        </cfif>
                        <cfif len(trim(getPalletInfo.SUBE_ILCE_ADI))>
                            #getPalletInfo.SUBE_ILCE_ADI# - 
                        </cfif>
                        <cfif len(trim(getPalletInfo.SUBE_IL_ADI))>
                            #getPalletInfo.SUBE_IL_ADI#
                        </cfif>
                        <cfif len(trim(getPalletInfo.SUBE_ULKE_ADI))>
                            <br>#getPalletInfo.SUBE_ULKE_ADI#
                        </cfif>
                    <cfelse>
                        <!--- Şube yoksa firma bilgilerini göster --->
                        <strong>#getPalletInfo.NICKNAME#</strong><br>
                        <cfif len(trim(getPalletInfo.COMPANY_ADDRESS))>
                            #getPalletInfo.COMPANY_ADDRESS#<br>
                        </cfif>
                        <cfif len(trim(getPalletInfo.FIRMA_ILCE_ADI))>
                            #getPalletInfo.FIRMA_ILCE_ADI# - 
                        </cfif>
                        <cfif len(trim(getPalletInfo.FIRMA_IL_ADI))>
                            #getPalletInfo.FIRMA_IL_ADI#
                        </cfif>
                        <cfif len(trim(getPalletInfo.FIRMA_ULKE_ADI))>
                            <br>#getPalletInfo.FIRMA_ULKE_ADI#
                        </cfif>
                    </cfif>
                </cfoutput>
            </div>
        </div>
        <div class="date-box">
            <div class="customer-title">TARİH</div>
            <div class="date-value">#currentDateTime#</div>
        </div>
    </div>
    <cfoutput>
    <div class="summary-box">
        <div class="summary-grid">
            <div class="summary-item">
                <div class="summary-label">Paket Kodu</div>
                <div class="summary-value">#palletCode#</div>
            </div>
            <div class="summary-item">
                <div class="summary-label">Paket Tipi</div>
                <div class="summary-value">#palletType#</div>
            </div>
            <div class="summary-item">
                <div class="summary-label">Toplam Ağırlık</div>
                <div class="summary-value">#totalWeightFormatted# kg</div>
            </div>
            <div class="summary-item">
                <div class="summary-label">Paket Sayısı</div>
                <div class="summary-value">#palletCountFormatted#</div>
            </div>
            <div class="summary-item">
                <div class="summary-label">Tarih & Saat</div>
                <div class="summary-value">#currentDateTime#</div>
            </div>
        </div>
    </div>
    </cfoutput>
    <cfset rowCounts = StructNew()>
    <cfloop query="getSubPalletRows">
        <cfif NOT StructKeyExists(rowCounts, PALLET_ID)>
            <cfset rowCounts[PALLET_ID] = 0>
        </cfif>
        <cfset rowCounts[PALLET_ID] = rowCounts[PALLET_ID] + 1>
    </cfloop>
    
    <table>
        <thead>
            <tr>
                <th>Palet No</th>
                <th>Stok Kodu</th>
                <th>Ürün Adı</th>
                <th>Miktar</th>
                <th>Birim Ağırlık (kg)</th>
                <th>Toplam Ağırlık (kg)</th>
            </tr>
        </thead>
        <tbody>
            <cfoutput query="getSubPalletRows" group="PALLET_ID">
                <cfset firstRow = true>
                <cfoutput>
                    <tr>
                        <cfif firstRow>
                            <td class="pallet-cell" rowspan="#rowCounts[PALLET_ID]#">#PALLET_NUMBER#</td>
                        </cfif>
                        <td class="product-code">#PRODUCT_CODE_2#</td>
                        <td style="text-align: left;">#PRODUCT_NAME#</td>
                        <td>#NumberFormat(MIKTAR, "9,999,999.99")#</td>
                        <td>#NumberFormat(WEIGHT, "9,999,999.99")#</td>
                        <cfif firstRow>
                            <td class="total-cell" rowspan="#rowCounts[PALLET_ID]#">#NumberFormat(palletTws[PALLET_ID], "9,999,999.99")#</td>
                            <cfset firstRow = false>
                        </cfif>
                    </tr>
                </cfoutput>
            </cfoutput>
        </tbody>
    </table>
    
    <div class="footer">
        <p>Sistem tarafından otomatik oluşturulmuştur - #currentDateTime#</p>
    </div>
</div>

</body>
</html>