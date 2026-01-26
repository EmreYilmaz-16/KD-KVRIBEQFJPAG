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




1 Sarf Fişi Yap
2 Seri Leri Düş
3 Üretim Çıkış Fişi Yap
4 Seri Üret
5 Seri Girişi Yap