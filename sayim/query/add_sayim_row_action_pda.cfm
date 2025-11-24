<cfdump var="#attributes#">


<cfset Data=deserializeJSON(attributes.FORMDATA)>
<cfdump var="#Data#">
<cfset ErrorArray= arrayNew(1)>
<cfloop array="#Data#" index="item">
    <cfquery name="getStok" datasource="#DSN#">
            SELECT TOP 10 * FROM PBS_GETSTOCK WHERE PRODUCT_CODE_2='#item.Stok#'
    </cfquery>
    <cfif getStok.recordCount>
        <cfif getStok.recordCount gt 1>
            <cfset arrayAppend(ErrorArray, "Birden fazla ürün bulundu: " & item.Stok)>
        <cfelse>
            <cfset item.stockID=getStok.STOCK_ID[1]>
            <cfset item.productID=getStok.PRODUCT_ID[1]>
            <cfset item.productName=getStok.PRODUCT_NAME[1]>
            <cfloop array="#item.SerialNumbers#" index="sn">
                <cfif sn.isReadedBefore eq 1>
                    <!--- Daha önce okunduysa atla --->
                    <cfcontinue>
                </cfif>
               
                    <!--- Yeni seri numarası ekle --->
                    <cfquery datasource="#dsn3#">
                        INSERT INTO PBS_SERIAL_SAYIM_ROW (
                            SAYIM_ID,
                            SERIAL_NUMBER,
                            SHELF_NUMBER,
                            PRODUCT_CODE_2,
                            IN_OUT,
                            PRODUCT_ID,                            
                            STOCK_ID
                        ) VALUES (
                            <cfqueryparam value="#sayimId#" cfsqltype="cf_sql_integer">,
                            <cfqueryparam value="#trim(sn.Serial)#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#trim(item.Raf)#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#trim(item.Stok)#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="1" cfsqltype="cf_sql_bit">,
                            <cfqueryparam value="#item.productID#" cfsqltype="cf_sql_integer">,
                            <cfqueryparam value="#item.stockID#" cfsqltype="cf_sql_integer">
                        )
                    </cfquery>
                    
                

            </cfloop>
        </cfif>
    <cfelse>
        <cfset arrayAppend(ErrorArray, "Ürün bulunamadı: " & item.stock)>
    </cfif>
</cfloop>

<script>
            window.location.href="index.cfm?fuseaction=stock.emptypopup_list_sayim_pbs";
        </script>

<cfabort>
<cfset i=1>
<cfloop array="#Data#" index="item">
<cfquery name="getProductInfo" datasource="#dsn3#">
    SELECT PRODUCT_ID,STOCK_ID,PRODUCT_NAME FROM STOCKS WHERE PRODUCT_CODE_2='#item.Stok#'
</cfquery>
<cfset "attributes.SHELF_CODE_IN#i#"=item.Raf>
<cfset "attributes.STOCKID#i#"=getProductInfo.STOCK_ID>
<CFSET "attributes.AMOUNT#i#"=arraylen(item.SerialNumbers)>
<cfloop from="1" to="#arraylen(item.SerialNumbers)#" index="j">
    <cfset "attributes.SERIAL#i#_#j#"=item.SerialNumbers[j]>
</cfloop>
<cfdump var="#getProductInfo#">
<cfset i=i+1>
</cfloop>
<cfset attributes.fromSayim=1>
<cfset attributes.row_count=i-1>
<cfdump var="#attributes#">
<cfinclude template="add_ambar_fis.cfm">
