<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <title>Çeki Listesi</title>
    <style>
        @media print {
            .no-print { display: none; }
            body { margin: 0; padding: 10mm; }
        }
        
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #fff;
        }
        
        .container {
            max-width: 1000px;
            margin: 0 auto;
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
        <button class="print-button" onclick="window.print()">Yazdır</button>
    </div>
    
    <div class="header">
        <h1>ÇEKİ LİSTESİ</h1>
    </div>
    
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