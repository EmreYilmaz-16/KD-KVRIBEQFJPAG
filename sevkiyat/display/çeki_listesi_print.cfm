<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Çeki Listesi</title>
    <style>
        @media print {
            .no-print { display: none; }
            body { margin: 0; padding: 15px; }
            .container { box-shadow: none; }
            .print-button { display: none; }
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
            background-color: #ffffff;
            padding: 40px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            border-radius: 12px;
        }
        
        .header {
            text-align: center;
            border-bottom: 4px solid #667eea;
            padding-bottom: 25px;
            margin-bottom: 35px;
            position: relative;
        }
        
        .header::after {
            content: '';
            position: absolute;
            bottom: -4px;
            left: 50%;
            transform: translateX(-50%);
            width: 100px;
            height: 4px;
            background: linear-gradient(90deg, #667eea, #764ba2);
            border-radius: 2px;
        }
        
        .header h1 {
            margin: 0 0 10px 0;
            font-size: 36px;
            color: #2c3e50;
            text-transform: uppercase;
            letter-spacing: 3px;
            font-weight: 700;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        
        .header .subtitle {
            color: #7f8c8d;
            font-size: 14px;
            font-weight: 400;
            letter-spacing: 1px;
        }
        
        .info-section {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 25px;
            margin-bottom: 35px;
            padding: 25px;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            border: none;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
        }
        
        .info-item {
            display: flex;
            flex-direction: column;
            padding: 15px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        
        .info-item:hover {
            transform: translateY(-3px);
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.2);
        }
        
        .info-label {
            font-weight: 600;
            color: #667eea;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 8px;
        }
        
        .info-value {
            color: #2c3e50;
            font-size: 18px;
            font-weight: 700;
        }
        
        .summary-box {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 25px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.3);
            color: white;
        }
        
        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
        }
        
        .summary-item {
            background: rgba(255, 255, 255, 0.15);
            padding: 15px;
            border-radius: 8px;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .summary-label {
            font-weight: 600;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 8px;
            opacity: 0.9;
        }
        
        .summary-value {
            font-size: 24px;
            font-weight: 700;
        }
        
        table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            margin-top: 25px;
            font-size: 14px;
            overflow: hidden;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        
        thead {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        th {
            padding: 16px 12px;
            text-align: center;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 12px;
            letter-spacing: 0.5px;
            border: none;
        }
        
        th:first-child {
            border-top-left-radius: 10px;
        }
        
        th:last-child {
            border-top-right-radius: 10px;
        }
        
        td {
            padding: 14px 12px;
            border-bottom: 1px solid #ecf0f1;
            border-right: 1px solid #ecf0f1;
            text-align: center;
        }
        
        td:last-child {
            border-right: none;
        }
        
        tbody tr {
            background-color: #ffffff;
            transition: all 0.3s ease;
        }
        
        tbody tr:nth-child(even) {
            background-color: #f8f9fa;
        }
        
        tbody tr:hover {
            background-color: #e8eaf6;
            transform: scale(1.01);
            box-shadow: 0 2px 8px rgba(102, 126, 234, 0.15);
        }
        
        .pallet-cell {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            font-weight: 700;
            font-size: 18px;
            vertical-align: middle;
            border-right: 2px solid #764ba2 !important;
        }
        
        .total-cell {
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
            color: white;
            font-weight: 700;
            vertical-align: middle;
            font-size: 16px;
        }
        
        .product-code {
            font-weight: 600;
            color: #667eea;
            font-family: 'Courier New', monospace;
        }
        
        .footer {
            margin-top: 50px;
            padding-top: 25px;
            border-top: 3px solid #ecf0f1;
            text-align: center;
            color: #95a5a6;
            font-size: 13px;
        }
        
        .print-button {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px 40px;
            border: none;
            border-radius: 50px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 600;
            margin-bottom: 25px;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
            transition: all 0.3s ease;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .print-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.5);
        }
        
        .print-button:active {
            transform: translateY(0);
        }
        
        .button-container {
            text-align: center;
            margin-bottom: 30px;
        }
    </style>
</head>
<body>
<cfset dsn3="w3Qa_1">
<cfset dsn="w3Qa">
<cfquery name="getPalletInfo" datasource="#dsn3#">
    SELECT PALLET_CODE,PALLET_TYPE,MAIN_PALET_ID FROM #dsn3#.SHIPPING_PALLETS_PBS 
    WHERE ID=<cfqueryparam value="#Val(attributes.pallet_id)#" cfsqltype="cf_sql_integer">
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
        <button class="print-button" onclick="window.print()">
            🖨️ Yazdır
        </button>
    </div>
    
    <div class="header">
        <h1>ÇEKİ LİSTESİ</h1>
        <div class="subtitle">Paket Detay Raporu</div>
    </div>
    
    <div class="summary-box">
        <div class="summary-grid">
            <div class="summary-item">
                <div class="summary-label">📦 Paket Kodu</div>
                <div class="summary-value">#palletCode#</div>
            </div>
            <div class="summary-item">
                <div class="summary-label">📋 Paket Tipi</div>
                <div class="summary-value">#palletType#</div>
            </div>
            <div class="summary-item">
                <div class="summary-label">⚖️ Toplam Ağırlık</div>
                <div class="summary-value">#totalWeightFormatted# kg</div>
            </div>
            <div class="summary-item">
                <div class="summary-label">📊 Paket Sayısı</div>
                <div class="summary-value">#palletCountFormatted#</div>
            </div>
            <div class="summary-item">
                <div class="summary-label">🕒 Tarih & Saat</div>
                <div class="summary-value">#currentDateTime#</div>
            </div>
        </div>
    </div>
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
                <th>🎯 Palet No</th>
                <th>🏷️ Stok Kodu</th>
                <th>📦 Ürün Adı</th>
                <th>📊 Miktar</th>
                <th>⚖️ Birim Ağırlık (kg)</th>
                <th>💪 Toplam Ağırlık (kg)</th>
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
                        <td style="text-align: left; padding-left: 15px;">#PRODUCT_NAME#</td>
                        <td style="font-weight: 600;">#NumberFormat(MIKTAR, "9,999,999.99")#</td>
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
        <p>Bu belge sistem tarafından otomatik olarak oluşturulmuştur.</p>
        <p>&copy; #Year(Now())# - Tüm Hakları Saklıdır</p>
    </div>
</div>

</body>
</html>