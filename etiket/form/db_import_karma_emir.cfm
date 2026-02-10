<cfquery name="getEmir" datasource="#dsn3#">
    SELECT EMIR_NO,KARMA_EMIR_ID FROM w3Qa_1.KARMA_EMIR WHERE KARMA_EMIR_ID=#attributes.EMIR_ID#
</cfquery>
<cfdump var="#getEmir#" label="getEmir">
<cfquery name="getPeriodS" datasource="#dsn#">
    SELECT PERIOD_ID,PERIOD_YEAR,OUR_COMPANY_ID FROM w3Qa.SETUP_PERIOD WHERE OUR_COMPANY_ID=1
</cfquery>
<cfdump var="#getPeriodS#" label="getPeriodS">
<cfquery name="GETSF" datasource="#DSN2#">
    SELECT * FROM (
<cfloop query="getPeriodS">
SELECT *,#PERIOD_ID# AS DONEM FROM #DSN#_#PERIOD_YEAR#_#OUR_COMPANY_ID#.STOCK_FIS 
    <cfif getPeriodS.currentRow NEQ getPeriodS.recordCount>UNION ALL</cfif>
</cfloop>
)AS T 
WHERE PBS_ACTION_TYPE=1 AND PBS_ID=#attributes.EMIR_ID# AND FIS_TYPE=110
</cfquery>
<cfdump var="#GETSF#" label="GETSF">

<CFIF GETSF.recordCount>
 <cfquery name="getSerials" datasource="#dsn3#">
    SELECT 
        SERIAL_NO AS SERI_NO,
        SGN.STOCK_ID,
        S.PRODUCT_CODE_2 as ETA_KODU,
        SGN.RECORD_DATE AS URETIM_TARIHI,
        SGN.RECORD_DATE AS PAKET_TARIHI,
        S.BARCOD,
        1 AS MIKTAR,
        '' AS MARKA,
        S.PRODUCT_NAME,
        SGN.PROCESS_ID AS SHIP_ROW_ID
         FROM w3Qa_1.SERVICE_GUARANTY_NEW AS SGN
        INNER JOIN STOCKS AS S ON S.STOCK_ID=SGN.STOCK_ID
    
     WHERE PROCESS_ID=#GETSF.FIS_ID# AND PROCESS_CAT=110 AND PERIOD_ID=#GETSF.DONEM#
 </cfquery>
<cfdump var="#getSerials#" label="getSerials">

<cfquery name="createImportLog" datasource="#dsn#" result="logResult">
                                    INSERT INTO etiket_import_log (
                                        import_date,
                                        file_name,
                                        file_size,
                                        status
                                    ) VALUES (
                                        GETDATE(),
                                        <cfqueryparam value="Database Import - PAKET_EMIR/STOCKS" cfsqltype="cf_sql_varchar">,
                                        <cfqueryparam value="0" cfsqltype="cf_sql_integer">,
                                        'PROCESSING'
                                    )
                                </cfquery>
                                <cfdump var="#logResult#" label="createImportLog">
                                 <cfset importResult.importId = logResult.generatedKey>
                                <cfloop query="getSerials" >
                                    <cfset etaKodu = getSerials.ETA_KODU>
                                    <cfset generatedSerial = getSerials.SERI_NO>
                                    <cfset uretimTarihi = getSerials.URETIM_TARIHI>
                                    <cfset paketTarihi = getSerials.PAKET_TARIHI>
                                    <cfset barkod = getSerials.BARCOD>
                                    <cfset marka = getSerials.MARKA>
                                        <cfset currentRow = getSerials.currentRow>

                                    <cfquery name="insertTempData" datasource="#dsn#">
                                                    INSERT INTO etiket_temp_data (
                                                        import_id,
                                                        eta_kodu,
                                                        seri_no,
                                                        uretim_tarihi,
                                                        paket_tarihi,
                                                        barkod,
                                                        miktar,
                                                        marka,
                                                        row_number,
                                                        created_date
                                                    ) VALUES (
                                                        <cfqueryparam value="#importResult.importId#" cfsqltype="cf_sql_integer">,
                                                        <cfqueryparam value="#etaKodu#" cfsqltype="cf_sql_varchar">,
                                                        <cfqueryparam value="#generatedSerial#" cfsqltype="cf_sql_varchar">,
                                                        <cfqueryparam value="#uretimTarihi#" cfsqltype="cf_sql_timestamp">,
                                                        <cfqueryparam value="#paketTarihi#" cfsqltype="cf_sql_timestamp">,
                                                        <cfqueryparam value="#barkod#" cfsqltype="cf_sql_varchar">,
                                                        <cfqueryparam value="1" cfsqltype="cf_sql_decimal">,
                                                        <cfqueryparam value="#marka#" cfsqltype="cf_sql_varchar">,
                                                        <cfqueryparam value="#currentRow#" cfsqltype="cf_sql_integer">,
                                                        GETDATE()
                                                    )
                                                </cfquery>
                                </cfloop>




</CFIF>
