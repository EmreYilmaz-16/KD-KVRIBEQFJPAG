
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
    <cfset SERI_NO_SER =generateSerialNo("REL", attributes.produced_pid)>
    <cfset data = {
        STOCK_ID = attributes.STOCKID1,
        SERIAL_NO = "#SERI_NO_SER#",
        LOT_NO = "",
        IN_OUT = 1,
        PROCESS_CAT = attributes.process_type_pbs,
        PROCESS_ID = 0,
        PROCESS_NO = "",
        PERIOD_ID = #session.ep.period_id#,
        DEPARTMENT_ID = attributes.dep_out,
        LOCATION_ID = attributes.dep_in,
        IS_SARF = 0,
        IS_SERI_SONU = 0,
        WRK_ID = "#evaluate("WRK_PBS_CCC#item.PRODUCT_ID#")#-#createUUID()#",
        RECORD_DATE = now(),
        RECORD_EMP = recordEmp,
        WRK_ROW_ID = "#evaluate("WRK_PBS_CCC#item.PRODUCT_ID#")#",
        IS_RETURN = 0,
        IS_RMA = 0,
        IS_SERVICE = 0,
        SALE_COMPANY_ID = -1,
        UNIT_TYPE = 1
    }>
    <cfset result_svc=svc.saveServiceGuaranty(data, recordEmp)>

</cfloop>
<cfquery name="UP" datasource="#DSN3#">
    UPDATE SERVICE_GUARANTY_NEW SET PROCESS_NO='#PBS_FIS_NO#',PROCESS_ID=#PBS_FIS_ID# WHERE PROCESS_ID=0;
</cfquery>


<cffunction name="generateSerialNo" access="public" returntype="string" output="false">
    <cfargument name="prefix" type="string" required="true">
    <cfargument name="product_id" type="numeric" required="true">
    <cfset var serialNo = "">
    <cfset var uniquePart = createUUID()>
    <cfset serialNo = "#arguments.prefix#-#arguments.product_id#-#left(uniquePart, 8)#">
    <cfreturn serialNo>
</cffunction>



