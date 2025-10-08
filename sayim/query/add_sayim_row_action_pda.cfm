<cfdump var="#attributes#">


<cfset Data=deserializeJSON(attributes.FORMDATA)>
<cfdump var="#Data#">
<cfset i=1>
<cfloop array="#Data#" index="item">
<cfquery name="getProductInfo" datasource="#dsn3#">
    SELECT PRODUCT_ID,STOCK_ID,PRODUCT_NAME, FROM STOCKS WHERE PRODUCT_CODE_2='#item.Stok#'
</cfquery>
<cfset "attributes.SHELF_CODE_IN#i#"=item.Raf>
<cfset "attributes.STOCKID#i#"=getProductInfo.STOCK_ID>
<CFSET "attributes.AMOUNT#i#"=arraylen(item.SerialNumbers)>
<cfdump var="#getProductInfo#">
</cfloop>

<cfdump var="#attributes#">