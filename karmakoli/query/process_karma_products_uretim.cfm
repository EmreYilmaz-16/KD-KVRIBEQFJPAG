
<cfset attributes.process_cat=87>
<cfset attributes.process_type_pbs=110>

<cfset attributes.row_count=1>
<cfset attributes.STOCKID1=attributes.produced_stockid>
<cfset attributes.AMOUNT1=attributes.uretim_miktari>
<cfset attributes.dep_out =attributes.PACKAGING_STORE>
<cfset attributes.dep_in =attributes.PACKAGING_STORE>
<cfset attributes.serino1="">
<cfinclude template="/AddOns/Partner/e_pda/query/add_ambar_fis_no_relocate.cfm">
<cfset svc = createObject("component", "AddOns.Partner.cfc.service_guaranty")>
<cfset recordEmp = session.ep.userid>
<cfloop from="1" to="#attributes.uretim_miktari#" index="i">
    <cfset SERI_NO_SER =generateSerialNo("REL", attributes.produced_stockid)>
    <cfset data = {
        STOCK_ID = attributes.STOCKID1,
        SERIAL_NO = "#SERI_NO_SER#",
        LOT_NO = "",
        IN_OUT = 1,
        PROCESS_CAT = attributes.process_type_pbs,
        PROCESS_ID = 0,
        PROCESS_NO = "",
        PERIOD_ID = #session.ep.period_id#,
        DEPARTMENT_ID = attributes.DEPARTMENT_OUT,
        LOCATION_ID = attributes.LOCATION_OUT,
        IS_SARF = 0,
        IS_SERI_SONU = 0,
        WRK_ID = "#evaluate("WRK_PBS_CCC#attributes.produced_pid#")#-#createUUID()#",
        RECORD_DATE = now(),
        RECORD_EMP = recordEmp,
        WRK_ROW_ID = "#evaluate("WRK_PBS_CCC#attributes.produced_pid#")#",
        IS_RETURN = 0,
        IS_RMA = 0,
        IS_SERVICE = 0,
        SALE_COMPANY_ID = -1,
        UNIT_TYPE = 1,
        UNIT_ROW_QUANTITY = 1,
        SHELF_NUMBER = ""
    }>
    <cfset result_svc=svc.saveServiceGuaranty(data, recordEmp)>
<cfquery name="AddSerial" datasource="#dsn3#">
    INSERT INTO [#dsn3#].[SERIAL_IN_OUT_PBS] 
([SERIAL_NUMBER],
 [IS_ALIVE],
 [IN_GUARANTY_ID],
 [OUT_GUARANTY_ID],
 [PURCHASE_DATE],
 [STOCK_ID]) 
VALUES 
('#SERI_NO_SER#',
 1,
 -1,
 NULL,
 GETDATE(),
 #attributes.STOCKID1#)
</cfquery>
</cfloop>
<cfquery name="UP" datasource="#DSN3#">
    UPDATE SERVICE_GUARANTY_NEW SET PROCESS_NO='#PBS_FIS_NO#',PROCESS_ID=#PBS_FIS_ID# WHERE PROCESS_ID=0;
</cfquery>

<cfquery name="UP_SF" datasource="#DSN2#">
    UPDATE STOCK_FIS SET PBS_ID=#attributes.EMIR_ID#,PBS_ACTION_TYPE=1 WHERE FIS_ID=#PBS_FIS_ID#;
</cfquery>

<cfquery name="UPEMIR" datasource="#DSN3#">
    UPDATE KARMA_EMIR SET CURRENT_STATUS=3 WHERE KARMA_EMIR_ID=#attributes.EMIR_ID#;
</cfquery>

<cfinclude template="/AddOns/Partner/etiket/form/db_import_karma_emir.cfm">


<cffunction name="generateSerialNo" access="public" returntype="string" output="false">
    <cfargument name="prefix" type="string" required="true">
    <cfargument name="product_id" type="numeric" required="true">
    <cfset var serialNo = "">
    <cfset var timestamp = getTickCount()>
    <cfset var uniquePart = replace(createUUID(), "-", "", "ALL")>
    <cfset var randomNum = randRange(10000, 99999)>
    <cfset serialNo = "#arguments.prefix#-#arguments.product_id#-#left(uniquePart, 12)#">
    <cfreturn serialNo>
</cffunction>

<script>
window.opener.location.reload();
    window.close();
</script>








