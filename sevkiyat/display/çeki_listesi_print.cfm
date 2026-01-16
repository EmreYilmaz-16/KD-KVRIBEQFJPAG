<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Çeki Listesi</title>
    <style>
        @media print {
            .no-print { display: none; }
            body { margin: 0; padding: 15px; }
        }
        
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        
        .header {
            text-align: center;
            border-bottom: 3px solid #333;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        
        .header h1 {
            margin: 0;
            font-size: 28px;
            color: #333;
            text-transform: uppercase;
            letter-spacing: 2px;
        }
        
        .info-section {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 30px;
            padding: 20px;
            background-color: #f9f9f9;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        
        .info-item {
            display: flex;
            padding: 8px 0;
        }
        
        .info-label {
            font-weight: bold;
            color: #555;
            min-width: 150px;
        }
        
        .info-value {
            color: #000;
        }
        
        .packing-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            font-size: 14px;
        }
        
        .packing-table thead {
            background-color: #2c3e50;
            color: white;
        }
        
        .packing-table th {
            padding: 12px 8px;
            text-align: center;
            font-weight: bold;
            border: 1px solid #34495e;
        }
        
        .packing-table td {
            padding: 10px 8px;
            border: 1px solid #ddd;
            text-align: center;
        }
        
        .packing-table tbody tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        
        .packing-table tbody tr:hover {
            background-color: #f0f0f0;
        }
        
        .pallet-cell {
            background-color: #ecf0f1;
            font-weight: bold;
            font-size: 16px;
            vertical-align: middle;
        }
        
        .total-cell {
            background-color: #e8f5e9;
            font-weight: bold;
            vertical-align: middle;
        }
        
        .product-code {
            font-weight: bold;
            color: #2c3e50;
        }
        
        .footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 2px solid #ddd;
            text-align: center;
            color: #777;
            font-size: 12px;
        }
        
        .print-button {
            background-color: #3498db;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            margin-bottom: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
        }
        
        .print-button:hover {
            background-color: #2980b9;
        }
        
        .summary-box {
            background-color: #e3f2fd;
            padding: 15px;
            border-left: 5px solid #2196f3;
            margin-bottom: 20px;
            border-radius: 3px;
        }
        
        .summary-item {
            display: inline-block;
            margin-right: 30px;
            font-size: 16px;
        }
        
        .summary-label {
            font-weight: bold;
            color: #1976d2;
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

<cfoutput>
<div class="container">
    <button class="print-button no-print" onclick="window.print();">🖨️ Yazdır</button>
    
    <div class="header">
        <h1>📦 ÇEKİ LİSTESİ</h1>
    </div>
    
    <div class="info-section">
        <div class="info-item">
            <span class="info-label">Paket Kodu:</span>
            <span class="info-value">#palletCode#</span>
        </div>
        <div class="info-item">
            <span class="info-label">Paket Tipi:</span>
            <span class="info-value">#palletType#</span>
        </div>
        <div class="info-item">
            <span c width="10%">Palet No</th>
                <th width="15%">Stok Kodu</th>
                <th width="35%">Ürün Adı</th>
                <th width="12%">Miktar</th>
                <th width="13%">Birim Ağırlık (kg)</th>
                <th width="15%">Toplam Ağırlık (kg)</th>
            </tr>
        </thead>
        <tbody>
            <cfoutput query="getSubPalletRows" group="PALLET_ID">
                <cfset firstRow = true>
                <cfoutput>
                    <tr>
                        <cfif firstRow>
                            <td rowspan="#rowCounts[PALLET_ID]#" class="pallet-cell">#PALLET_NUMBER#</td>
                        </cfif>
                        <td class="product-code">#PRODUCT_CODE_2#</td>
                        <td style="text-align: left; padding-left: 15px;">#PRODUCT_NAME#</td>
                        <td>#NumberFormat(MIKTAR, "9,999,999.99")#</td>
                        <td>#NumberFormat(WEIGHT, "9,999,999.99")#</td>
                        <cfif firstRow>
                            <td rowspan="#rowCounts[PALLET_ID]#" class="total-cell">#NumberFormat(palletTws[PALLET_ID], "9,999,999.99")#</td>
                            <cfset firstRow = false>
                        </cfif>
                    </tr>
                </cfoutput>
            </cfoutput>
        </tbody>
    </table>
    
    <div class="footer">
        <p>Bu belge otomatik olarak oluşturulmuştur.</p>
    </div>
</div>
</cfoutput>

</body>
</html     <th>Ürün Adı</th>
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
                            <td rowspan="#rowCounts[PALLET_ID]#">#PALLET_NUMBER#</td>
                        </cfif>
                        <td>#PRODUCT_CODE_2#</td>
                        <td>#PRODUCT_NAME#</td>
                        <td>#NumberFormat(MIKTAR, "9,999,999.99")#</td>
                        <td>#NumberFormat(WEIGHT, "9,999,999.99")#</td>
                        <cfif firstRow>
                            <td rowspan="#rowCounts[PALLET_ID]#">#NumberFormat(palletTws[PALLET_ID], "9,999,999.99")#</td>
                            <cfset firstRow = false>
                        </cfif>
                    </tr>
                </cfoutput>
            </cfoutput>
        </tbody>
    </table>

