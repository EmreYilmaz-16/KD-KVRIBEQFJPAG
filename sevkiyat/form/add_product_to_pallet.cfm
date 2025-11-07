<cfquery name="getPaperSerials" datasource="#dsn3#">
    SELECT (
        SELECT DISTINCT
            SG.SERIAL_NO,SG.STOCK_ID
        FROM w3Qa_1.SHIPPING_PALLET_SVK_PBS SP
        LEFT JOIN w3Qa_1.EZGI_SHIP_RESULT ESR ON ESR.SHIP_RESULT_ID = SP.ORDER_ID
        LEFT JOIN (
            SELECT FIS_ID, REF_NO, 2 AS PERIODID FROM w3Qa_2025_1.STOCK_FIS
            UNION ALL
            SELECT FIS_ID, REF_NO, 1 AS PERIODID FROM w3Qa_2024_1.STOCK_FIS
        ) SF ON SF.REF_NO = ESR.DELIVER_PAPER_NO
        LEFT JOIN w3Qa_1.SERVICE_GUARANTY_NEW SG ON SG.PROCESS_ID = SF.FIS_ID AND SG.PERIOD_ID = SF.PERIODID
        WHERE SP.PALLET_ID=<cfqueryparam value="#Val(attributes.pallet_id)#" cfsqltype="cf_sql_integer">
        FOR JSON PATH
    ) AS T
</cfquery>
   <cfquery name="getSavedPalletRows" datasource="#dsn3#">
        SELECT (
        SELECT SPR.SERIAL_NUMBER,
               SPR.PRODUCT_ID,
               SPR.STOCK_ID,
               P.PRODUCT_CODE_2
        FROM w3Qa_1.SHIPPING_PALLET_ROWS_PBS SPR
        INNER JOIN w3Qa_product.PRODUCT P ON P.PRODUCT_ID = SPR.PRODUCT_ID
        WHERE SPR.PALLET_ID = <cfqueryparam value="#Val(attributes.pallet_id)#" cfsqltype="cf_sql_integer">
        FOR JSON PATH
        ) AS T
    </cfquery>

<cfdump var="#getSavedPalletRows#">

<script>
    var paperSerials=<cfoutput>#getPaperSerials.T#</cfoutput>;

    var savedPalletRows=<cfoutput>#getSavedPalletRows.T#</cfoutput>;
</script>

