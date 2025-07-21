<cfif isDefined("attributes.is_submit")><cfelse>
<cfquery name="getSR" datasource=#dsn3#>
select ESRR.*,ORR.*,O.COMPANY_ID,S.PRODUCT_CODE from EZGI_SHIP_RESULT_ROW AS ESRR
left JOIN ORDER_ROW AS ORR ON ORR.ORDER_ROW_ID=ESRR.ORDER_ROW_ID
LEFT JOIN ORDERS AS O ON O.ORDER_ID=ESRR.ORDER_ID
LEFT JOIN STOCKS AS S ON S.STOCK_ID = ORR.STOCK_ID
where SHIP_RESULT_ID=#listGetAt(attributes.action_id, 2,"-")#
</cfquery>


<cfform method="post" action="#request.self#?fuseaction=#attributes.fuseaction#">
<input type="submit" value="yazdir">
<cf_big_list >
<thead>
<tr><th>Ü.Kodu</th><th>Ürün</th><th>Miktar</th></tr></thead>
<tbody>

<cfoutput>
<input type="hidden" value="1" name="is_submit">
<input type="hidden" value="#getSR.COMPANY_ID#" name="COMPANY_ID">
<cfloop query="getSR">
    <tr>
    <td><input type="hidden" name="sidlist" value="#STOCK_ID#">
    #listGetAt(PRODUCT_CODE, listlen(PRODUCT_CODE,"."),".")# 
    </td><td>
    #PRODUCT_NAME#</td>
    <td><input type="number" value="1" name="emik_#STOCK_ID#">
    <input type="hidden" value="#QUANTITY#" name="sipmik_#STOCK_ID#">
    </td>
    </tr>
</cfloop>
</tbody>
</cfoutput>
</cf_big_list>
</cfform>
</cfif>
<cfif isDefined("attributes.is_submit")>
    
<cfloop list="#attributes.sidlist#" index="list_item">

<cfoutput>
<cfset yazmik=evaluate("attributes.emik_#list_item#")>
<cfif listLen(yazmik) gt 1>
    <cfset yazmik =listGetAt(yazmik,1)>
</cfif>
<cfquery name="getStkInfo" datasource="#dsn3#">
    SELECT * FROM STOCKS  AS S
    LEFT JOIN #DSN1#.SETUP_COMPANY_STOCK_CODE AS SCS ON SCS.STOCK_ID=S.STOCK_ID AND SCS.COMPANY_ID=#attributes.company_id#
    WHERE S.STOCK_ID =#list_item#
    
</cfquery>

<table style="width:100mm;height:44mm;top:0">
<cfloop from="1" to="#yazmik#" index="i" step="2">
<tr>
<td style="width:40mm;text-align:center;max-height:40mm;">
<cf_workcube_barcode type="code128" value="#getStkInfo.BARCOD#" show="1" width="35" height="40">
<br>
#getStkInfo.BARCOD#
<br>
(#evaluate("attributes.sipmik_#list_item#")#)
<br><!---- COMPANY_STOCK_CODE and COMPANY_PRODUCT_NAME----->
#right(getStkInfo.PRODUCT_CODE,6)#
<cfif len(getStkInfo.COMPANY_STOCK_CODE)><br>#getStkInfo.COMPANY_STOCK_CODE#<cfelse>
</cfif>
<br>
<cfif len(getStkInfo.COMPANY_STOCK_CODE)>#getStkInfo.COMPANY_PRODUCT_NAME#<cfelse>
#getStkInfo.PRODUCT_NAME#
</cfif>
</td>
<td></td>
<td style="width:40mm;text-align:center;max-height:40mm;"><cf_workcube_barcode type="code128" value="#getStkInfo.BARCOD#" show="1" width="35" height="40">
<br>
#getStkInfo.BARCOD#
<br>
(#evaluate("attributes.sipmik_#list_item#")#)
<br><!---- COMPANY_STOCK_CODE and COMPANY_PRODUCT_NAME----->
#right(getStkInfo.PRODUCT_CODE,6)#
<cfif len(getStkInfo.COMPANY_STOCK_CODE)><br>#getStkInfo.COMPANY_STOCK_CODE#<cfelse>
</cfif>
<br>
<cfif len(getStkInfo.COMPANY_STOCK_CODE)>#getStkInfo.COMPANY_PRODUCT_NAME#<cfelse>
#getStkInfo.PRODUCT_NAME#</cfif>
</td>
</tr>
  <tr>
                <td colspan="2"><div style="page-break-after:always"></div></td>
            </tr>
</cfloop>

</cfoutput>
</cfloop>

</cfif>
