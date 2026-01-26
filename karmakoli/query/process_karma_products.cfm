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
    <cfset "attributes.serino#i#"=result[i].SERIAL_NO>
</cfloop>
<cfset attributes.dep_out =attributes.PACKAGING_STORE>
<cfset attributes.dep_in =attributes.PACKAGING_STORE>

<cfinclude template="/AddOns/Partner/e_pda/query/add_ambar_fis.cfm">


1 Sarf Fişi Yap
2 Seri Leri Düş
3 Üretim Çıkış Fişi Yap
4 Seri Üret
5 Seri Girişi Yap