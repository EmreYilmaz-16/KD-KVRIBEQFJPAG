<cfdump var="#attributes#">
<cfset FormData=deserializeJSON(attributes.SELECTED_PRODUCTS)>
<cfdump var="#FormData#">
<cfdump var="#FormData#" label="FormData">

<cfset attributes.process_cat=88>

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
<cfset recordEmp = session.ep.userid>
<cfloop array="#FormData#" index="item">
    <cfif len(item.SERIAL_NO) gt 0>
         <cfset SERI_NO_SER=item.SERIAL_NO>        
        <cfquery name="GETSER" datasource="#DSN3#">
            SELECT * FROM #dsn3#.SERVICE_GUARANTY_NEW WHERE SERIAL_NO='#item.SERIAL_NO#'
        </cfquery>
        <cfset data = {STOCK_ID = STOCK_ID_SER,SERIAL_NO = "#SERI_NO_SER#",LOT_NO = "#GETSER.LOT_NO#",IN_OUT = 0,PROCESS_CAT = attributes.process_cat,PROCESS_ID = 0,PROCESS_NO = "",PERIOD_ID = #session.ep.period_id#,DEPARTMENT_ID = attributes.DEPARTMENT_OUT,LOCATION_ID = attributes.LOCATION_OUT,IS_SARF = 0,IS_SERI_SONU = 0,WRK_ID = "#WRK_PBS_CCC#-#createUUID()#",WRK_ROW_ID = "#WRK_PBS_CCC#",UNIT_ROW_QUANTITY = 1,SHELF_NUMBER = ""}>
    </cfif>
    
    
    <cfoutput>
        İşlem tamamlandı: #item.PRODUCT_ID# - #item.QUANTITY# <br>
    </cfoutput>
</cfloop>





1 Sarf Fişi Yap ok
2 Seri Leri Düş
3 Üretim Çıkış Fişi Yap
4 Seri Üret
5 Seri Girişi Yap