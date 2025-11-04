
<cfquery name="getPaletBilgi" datasource="#dsn3#">
    SELECT * FROM w3Qa_1.SHIPPING_PALLETS_PBS WHERE ID=#attributes.pallet_id#
</cfquery>
    
<cfquery name="get_hazir_sevk" datasource="#dsn3#">
    SELECT * FROM (
SELECT SHIP_RESULT_ID,DELIVER_PAPER_NO,COMPANY_ID,
ISNULL((
    SELECT SUM(AMOUNT) FROM (
    SELECT AMOUNT FROM #dsn#_#session.ep.PERIOD_YEAR#_1.STOCK_FIS SF
        LEFT JOIN #dsn#_#session.ep.PERIOD_YEAR#_1.STOCK_FIS_ROW AS SFR ON SF.FIS_ID=SFR.FIS_ID
    WHERE SF.REF_NO=ESR.DELIVER_PAPER_NO
    UNION ALL
     SELECT AMOUNT FROM #dsn#_#(session.ep.PERIOD_YEAR)-1#_1.STOCK_FIS SF
        LEFT JOIN #dsn#_#(session.ep.PERIOD_YEAR)-1#_1.STOCK_FIS_ROW AS SFR ON SF.FIS_ID=SFR.FIS_ID
    WHERE SF.REF_NO=ESR.DELIVER_PAPER_NO
    ) RT

),0) AS HAZ_MIK,
ISNULL((SELECT SUM(ISNULL(ORDER_ROW_AMOUNT,0)) FROM #dsn3#.EZGI_SHIP_RESULT_ROW WHERE SHIP_RESULT_ID=ESR.SHIP_RESULT_ID),0) AS SVK_MIK
(SELECT COUNT(*) FROM SHIPPING_PALLET_SVK_PBS WHERE ORDER_ID=ESR.SHIP_RESULT_ID AND PALLET_ID=#attributes.pallet_id#) AS IN_PALLET 
 FROM #dsn3#.EZGI_SHIP_RESULT AS ESR  
) AS T
WHERE HAZ_MIK =SVK_MIK
AND COMPANY_ID=#getPaletBilgi.COMPANY_ID#
</cfquery>
<CFFORM method="post" action="#request.self#?fuseaction=#attributes.fuseaction#">
<table>
    <tr>
        
        <td>Teslimat Belge No:</td>
        <td>Hazir Miktar:</td>
        <td>Sevk Miktar:</td>
    </tr>
<cfoutput query="get_hazir_sevk">
    <tr>
        
        
  
        
        <td>#DELIVER_PAPER_NO#</td>
  
   
    
        
        <td>#HAZ_MIK#</td>

        
        <td>#SVK_MIK#</td>
    <td>
        <input type="checkbox" name="IID" value="#SHIP_RESULT_ID#" <cfif IN_PALLET GT 0> checked disabled </cfif>>
    </td>
    </tr>
    
</table>

<input type="hidden" name="pallet_id" value="#attributes.pallet_id#">
<input type="hidden" name="is_submit" value="1">
<input type="submit" name="submit_add_to_pallet" value="Palete Ekle">


</CFFORM>


<cfif attributes.is_submit eq 1>
    <cfloop list="#form.IID#" index="sid">
        <cfquery name="insert_to_pallet" datasource="#dsn3#">
            INSERT INTO w3Qa_1.SHIPPING_PALLET_SVK_PBS
            (PALLET_ID,ORDER_ID)
            VALUES
            (
                <cfqueryparam value="#attributes.pallet_id#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#sid#" cfsqltype="cf_sql_integer">,
            )
        </cfquery>
    </cfloop>
</cfif>