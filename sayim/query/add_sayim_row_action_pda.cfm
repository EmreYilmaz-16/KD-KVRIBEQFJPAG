<cfdump var="#attributes#">


<cfset Data=deserializeJSON(attributes.FORMDATA)>
<cfdump var="#Data#">

<cfloop array="#Data#" index="item">
<cfquery name="getProductInfo" datasource="#dsn3#">
    SELECT * FROM STOCKS WHERE PRODUCT_CODE_2=#item.Stok#
</cfquery>
<cfdump var="#getProductInfo#">
</cfloop>