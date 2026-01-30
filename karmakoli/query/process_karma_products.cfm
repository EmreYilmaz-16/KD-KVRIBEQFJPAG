<cfdump var="#attributes#">
<cfset FormData=deserializeJSON(attributes.SELECTED_PRODUCTS)>
<cfdump var="#FormData#">
<cfdump var="#FormData#" label="FormData">

<cfset attributes.process_cat=88>
<cfset form.process_cat=88>
<cfset attributes.process_type_pbs=111>
<cfquery name="IsSavedBefore" datasource="#dsn2#">
    SELECT * FROM STOCK_FIS WHERE PBS_ID=#attributes.EMIR_ID# AND PBS_ACTION_TYPE=1
</cfquery>
<cfif IsSavedBefore.recordcount gt 0>
    <cfset  attributes.ACTIVE_PERIOD = session.ep.period_id>
    <cfset attributes.old_process_type=attributes.process_type_pbs>
    <cfset attributes.type_id=attributes.process_type_pbs>
    <cfset attributes.upd_id=IsSavedBefore.FIS_ID>
    <cfset form.upd_id=IsSavedBefore.FIS_ID>
    <cfset attributes.pageHead=IsSavedBefore.FIS_NUMBER>
    <cfset attributes.del_fis=1>
    <cfset attributes.delEvent=1>
    <cfinclude template="/v16/stock/query/upd_fis_pbs.cfm">
    <cfquery name="getOldSerials" datasource="#dsn3#">
        SELECT * FROM KARMA_EMIR_ROWS WHERE EMIR_ID=#attributes.EMIR_ID#
    </cfquery>
    <cfloop query="getOldSerials">
        <cfif len(getOldSerials.SERIAL_NO) gt 0>
            <cfquery name="UP_SER" datasource="#DSN3#">
                UPDATE SERIAL_IN_OUT_PBS SET IS_ALIVE=1 WHERE SERIAL_NUMBER='#getOldSerials.SERIAL_NO#' 
            </cfquery>
        </cfif>
    </cfloop>
    <cfquery name="DelKarmaRows" datasource="#dsn3#">
        DELETE FROM KARMA_EMIR_ROWS WHERE EMIR_ID=#attributes.EMIR_ID#
    </cfquery>

   
</cfif>


<cfscript>
grouped = {}; // geçici struct

for(item in FormData){

    pid = item.PRODUCT_ID;

    if( !structKeyExists(grouped, pid) ){
        grouped[pid] = {
            PRODUCT_ID = pid,
            QUANTITY   = 0
        };
    }

    grouped[pid].QUANTITY += item.QUANTITY;
}

// struct → array
result = [];
for(k in grouped){
    arrayAppend(result, grouped[k]);
}

writeDump(result);
</cfscript>
<cfset attributes.row_count=arrayLen(result)>
<cfloop from="1" to="#attributes.row_count#" index="i">
    <cfquery name="getStok" datasource="#dsn3#">
        SELECT * FROM STOCKS WHERE PRODUCT_ID=#result[i].PRODUCT_ID#    
    </cfquery>
    <cfset "attributes.STOCKID#i#"=getStok.STOCK_ID>
    <cfset "attributes.AMOUNT#i#"=result[i].QUANTITY>
    <cfset "attributes.SHELF_CODE_IN#i#"="">
    <cfset "attributes.SHELF_CODE_OUT#i#"="">
    <cfset "attributes.serino#i#"="">
</cfloop>
<cfset attributes.dep_out =attributes.PACKAGING_STORE>
<cfset attributes.dep_in =attributes.PACKAGING_STORE>

<cfinclude template="/AddOns/Partner/e_pda/query/add_ambar_fis_no_relocate.cfm">
<cfset svc = createObject("component", "AddOns.Partner.cfc.service_guaranty")>
<cfset krmsvc = createObject("component", "AddOns.Partner.cfc.karmakoliService")>
<cfset recordEmp = session.ep.userid>
<cfloop array="#FormData#" index="item">
      <cfquery name="getStok" datasource="#dsn3#">
        SELECT * FROM STOCKS WHERE PRODUCT_ID=#item.PRODUCT_ID#    
    </cfquery>
    <cfif len(item.SERIAL_NO) gt 0>
         <cfset SERI_NO_SER=item.SERIAL_NO>   
            
        <cfquery name="GETSER" datasource="#DSN3#">
            SELECT * FROM #dsn3#.SERVICE_GUARANTY_NEW WHERE SERIAL_NO='#item.SERIAL_NO#'
        </cfquery>
        <cfquery name="UP_SER" datasource="#DSN3#">
                UPDATE SERIAL_IN_OUT_PBS SET IS_ALIVE=0 WHERE SERIAL_NUMBER='#item.SERIAL_NO#' 
            </cfquery>
        <cfset STOCK_ID_SER=getStok.STOCK_ID>
        <cfset data = {
            STOCK_ID = STOCK_ID_SER,
            SERIAL_NO = "#SERI_NO_SER#",
            LOT_NO = "#GETSER.LOT_NO#",
            IN_OUT = 0,
            PROCESS_CAT = attributes.process_type_pbs,
            PROCESS_ID = #PBS_FIS_ID#,
            PROCESS_NO = "#PBS_FIS_NO#",
            PERIOD_ID = #session.ep.period_id#,
            DEPARTMENT_ID = attributes.DEPARTMENT_OUT,
            LOCATION_ID = attributes.LOCATION_OUT,
            IS_SARF = 1,
            IS_SERI_SONU = 0,
            WRK_ID = "#evaluate("WRK_PBS_CCC#item.PRODUCT_ID#")#-#createUUID()#",
            WRK_ROW_ID = "#evaluate("WRK_PBS_CCC#item.PRODUCT_ID#")#",
            UNIT_ROW_QUANTITY = 1,
            SHELF_NUMBER = ""
        }>
    <cfset result_svc = svc.saveServiceGuaranty(data, recordEmp)>
    <CFSET data.EMIR_ID=attributes.EMIR_ID>
    <cfset data.PRODUCT_ID=item.PRODUCT_ID>
    <cfset data.FIS_ID=#PBS_FIS_ID#>
    
    <cfset result_krm = krmsvc.addKarmaKoliRows(data, recordEmp)>
        <cfelse>
            <cfset data = {
                EMIR_ID = #attributes.EMIR_ID#,
                SERIAL_NO = "",
                PRODUCT_ID = item.PRODUCT_ID,
                STOCK_ID = #getStok.STOCK_ID#,
                UNIT_ROW_QUANTITY = item.QUANTITY,
                PERIOD_ID = #session.ep.period_id#,
                WRK_ID = "",
                WRK_ROW_ID = "#evaluate("WRK_PBS_CCC#item.PRODUCT_ID#")#",
                FIS_ID = #PBS_FIS_ID#}>
        <cfset result_krm = krmsvc.addKarmaKoliRows(data, recordEmp)>
    </cfif>
    
    
    <cfoutput>
        İşlem tamamlandı: #item.PRODUCT_ID# - #item.QUANTITY# <br>
    </cfoutput>
</cfloop>
<cfquery name="UP" datasource="#DSN3#">
    UPDATE SERVICE_GUARANTY_NEW SET PROCESS_NO='#PBS_FIS_NO#',PROCESS_ID=#PBS_FIS_ID# WHERE PROCESS_ID=0;
</cfquery>
<cfquery name="UP_SF" datasource="#DSN2#">
    UPDATE STOCK_FIS SET PBS_ID=#attributes.EMIR_ID#,PBS_ACTION_TYPE=1 WHERE FIS_ID=#PBS_FIS_ID#;
</cfquery>


<cflocation url="index.cfm?fuseaction=objects.emptypopup_process_karma_uretim&produced_stockid=#attributes.produced_stockid#&produced_pid=#attributes.produced_pid#&uretim_miktari=#attributes.uretim_miktari#&PACKAGING_STORE=#attributes.PACKAGING_STORE#" addtoken="false">

1


1 Sarf Fişi Yap ok
2 Seri Leri Düş
3 Üretim Çıkış Fişi Yap
4 Seri Üret
5 Seri Girişi Yap