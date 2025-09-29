<cfdump var="#attributes#" >
<cfset FormData=deserializeJson(attributes.DATA)>
<cfset paperData=deserializeJson(attributes.paperData)>
<cfdump var="#FormData#">
<cfloop from="1" to="#arrayLen(FormData)#" index="i">
    <cfset row=FormData[i]>
    <cfdump var="#row#">
        <cfloop from="1" to="#arrayLen(row.serials)#" index="j">
            <cfset serial=row.serials[j]>
            <cfset isreaded=listLast(serial,"|")>
            <cfset serial=listFirst(serial,"|")>
            
            <cfdump var="#serial#">
            <cfdump var="#isreaded#">
            <cfif isreaded eq "0">
                <cfquery name="insSerial" datasource="#application.dsn#">
                    INSERT INTO w3Qa_1.SERVICE_GUARANTY_NEW (
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
    WRK_ID,
    RECORD_DATE,
    RECORD_EMP,
    RECORD_IP,
    UPDATE_DATE,
    UPDATE_IP,
    UNIT_TYPE,
    UNIT_ROW_QUANTITY
)
VALUES (
    #row.stock_id#,
    '#serial#',
    1,
    1,
    0,
    0,
    0,
    #row.SHIP_TYPE#,
    #row.SHIP_ID#,
    '#row.SHIP_NUMBER#',
    #session.ep.period_id#,
    #row.DEPARTMENT_IN#,
    #row.LOCATION_IN#,
    3,
    GETDATE(), -- Tarih ise tırnak içinde olmalı
    #row.COMPANY_ID#,
    #row.PARTNER_ID#,
    0,
    0,
    '#row.wrk_row_id#',
    GETDATE(), -- veya '[RECORD_DATE DEĞERİNİ YAZIN]'
    #session.ep.userid#,
    '#cgi.REMOTE_ADDR#',
    NULL, -- UPDATE_DATE genellikle başlangıçta NULL'dur
    NULL, -- UPDATE_IP genellikle başlangıçta NULL'dur
    1,
    1
);
                </cfquery>
            </cfif>
        </cfloop>
</cfloop>
<cfabort>