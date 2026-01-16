<cfset dsn3="w3Qa_1">
<cfset dsn="w3Qa">
<cfquery name="getPalletInfo" datasource="#dsn3#">
    SELECT PALLET_CODE,PALLET_TYPE,MAIN_PALET_ID FROM #dsn3#.SHIPPING_PALLETS_PBS 
    WHERE ID=<cfqueryparam value="#Val(attributes.pallet_id)#" cfsqltype="cf_sql_integer">
</cfquery>

<cfif len(getPalletInfo.MAIN_PALET_ID)>
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
<cfdump var="#getSubPalletRows#" label="getSubPalletRows">


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

    <div>
        <strong>Paket Kodu:</strong> #palletCode#<br>
        <strong>Paket Tipi:</strong> #palletType#<br>
        <strong>Toplam Ağırlık:</strong> #totalWeightFormatted# kg<br>
        <strong>Paket Sayısı:</strong> #palletCountFormatted#<br>
        <strong>Tarih ve Saat:</strong> #currentDateTime#
    </div>
    <cfset rowCounts = StructNew()>
    <cfloop query="getSubPalletRows">
        <cfif NOT StructKeyExists(rowCounts, PALLET_ID)>
            <cfset rowCounts[PALLET_ID] = 0>
        </cfif>
        <cfset rowCounts[PALLET_ID] = rowCounts[PALLET_ID] + 1>
    </cfloop>
    
    <table class="table table-bordered table-striped">
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

