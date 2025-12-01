<cfdump var="#attributes#" >
<cfset FormData=deserializeJson(attributes.DATA)>
<cfset BpaperData=deserializeJson(attributes.paperData)[1]>
<cfdump var="#FormData#">
<cfloop from="1" to="#arrayLen(FormData)#" index="i">
    <cfset row=FormData[i]>
    <cfdump var="#row#">
        <cfloop from="1" to="#arrayLen(row.serials)#" index="j">
            <cfset serial=row.serials[j]>
            <cfset isreaded=listLast(serial,"|")>
            <cfset serial=listFirst(serial,"|")>
            <cfset fromBarcode=listGetAt(serial,2,"|")>
            
            <cfdump var="#serial#">
            <cfdump var="#isreaded#">
            <cfif isreaded eq "0" >
                <cfif fromBarcode eq "1" >
                    <cfquery datasource="#dsn3#">
                        INSERT INTO [PBS_MAL_KABUL_BARCODES] 
([BARCODE],
 [STOCK_ID],
 [WRK_ROW_ID]) 
VALUES 
('#serial#',
 #row.stock_id#,
 '#row.wrk_row_id#')
                    </cfquery>
                <cfelse>

                <cfquery name="insSerial" datasource="#dsn3#" result="insResult">
                    INSERT INTO #dsn3#.SERVICE_GUARANTY_NEW (
    STOCK_ID,
    SERIAL_NO,
    IN_OUT,
    IS_PURCHASE,
    IS_SALE,
    IS_RETURN,
    IS_SERVICE,
    PROCESS_CAT,
    PROCESS_ID,
    PROCESS_NO,
    PERIOD_ID,
    DEPARTMENT_ID,
    LOCATION_ID,
    PURCHASE_GUARANTY_CATID,
    PURCHASE_START_DATE,
    PURCHASE_COMPANY_ID,
    PURCHASE_PARTNER_ID,
    IS_SARF,
    IS_SERI_SONU,
    WRK_ROW_ID,
    RECORD_DATE,
    RECORD_EMP,
    RECORD_IP,
    UPDATE_DATE,
    UPDATE_IP,
    UNIT_TYPE,
    UNIT_ROW_QUANTITY,
    WRK_ID
)
VALUES (
    #row.stock_id#,
    '#serial#',
    1,
    1,
    0,
    0,
    0,
    #BpaperData.SHIP_TYPE#,
    #BpaperData.SHIP_ID#,
    '#BpaperData.SHIP_NUMBER#',
    #session.ep.period_id#,
    #BpaperData.DEPARTMENT_IN#,
    #BpaperData.LOCATION_IN#,
    3,
    GETDATE(), -- Tarih ise tırnak içinde olmalı
    #BpaperData.COMPANY_ID#,
    #BpaperData.PARTNER_ID#,
    0,
    0,
    '#row.wrk_row_id#',
    GETDATE(), -- veya '[RECORD_DATE DEĞERİNİ YAZIN]'
    #session.ep.userid#,
    '#cgi.REMOTE_ADDR#',
    NULL, -- UPDATE_DATE genellikle başlangıçta NULL'dur
    NULL, -- UPDATE_IP genellikle başlangıçta NULL'dur
    1,
    1,
    'WRK_#dateFormat(now(),"ddmmyyyy")#_#timeFormat(now(),"HHMMSS")#_#randRange(1000,9999)#'  -- WRK_ID benzersiz bir değer olmalıdır
);
                </cfquery>
                <cfquery name="ins2" datasource="#dsn3#">

INSERT INTO [#dsn3#].[SERIAL_IN_OUT_PBS] (
    [SERIAL_NUMBER],
    [IS_ALIVE],
    [IN_GUARANTY_ID],
    [OUT_GUARANTY_ID],
    [PURCHASE_DATE],
    [SALE_DATE],
    [STOCK_ID]
)
VALUES (
    '#serial#',    -- Metin/String değerler tırnak içinde olmalıdır
    1,             -- IS_ALIVE (Genellikle bit/boolean tipindedir)
    #insResult.IDENTITYCOL#, -- Sayısal değerler tırnak içinde olmamalıdır
    NULL,
    GETDATE(), -- Tarih değerleri tırnak içinde olmalıdır (Örn: '2025-09-29')
    NULL,                         -- Eğer henüz satılmadıysa NULL kullanabilirsiniz.
    #row.stock_id#
);
                </cfquery>
            </cfif>
        </cfif>
        </cfloop>
</cfloop>
<script>
    window.location.href="/index.cfm?fuseaction=purchase._emptypopup_list_purchase_despatches_pbs";
</script>
<cfabort>