<cfquery name="get_order_det1" datasource="#DSN3#">
	SELECT     
    	ORR.STOCK_ID, 
        ORR.QUANTITY, 
        ORR.ORDER_ROW_ID, 
        ORD.ORDER_ID, 
        ORD.ORDER_HEAD, 
        ORD.ORDER_NUMBER, 
        ISNULL(ORR.SPECT_VAR_ID, 0) AS SPECT_VAR_ID, 
        ORR.SPECT_VAR_NAME, 
        ORR.ORDER_ROW_CURRENCY,
        S.PRODUCT_NAME, 
        S.STOCK_CODE, 
        S.STOCK_CODE_2, 
        PO.LOT_NO, 
        PO.FINISH_DATE, 
        PO.P_ORDER_ID, 
        POR.TYPE
	FROM         
    	ORDERS AS ORD RIGHT OUTER JOIN
      	ORDER_ROW AS ORR INNER JOIN
       	STOCKS AS S ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
       	PRODUCTION_ORDERS AS PO INNER JOIN
       	PRODUCTION_ORDERS_ROW AS POR ON PO.P_ORDER_ID = POR.PRODUCTION_ORDER_ID ON ORR.ORDER_ROW_ID = POR.ORDER_ROW_ID ON 
      	ORD.ORDER_ID = ORR.ORDER_ID
	WHERE     
    	ORD.ORDER_ID = #attributes.order_id# AND 
        ISNULL(PO.PRODUCTION_LEVEL, 0) = N'0' AND
        S.IS_PRODUCTION = 1
	UNION ALL
	SELECT     
    	ORR.STOCK_ID, 
        ORR.QUANTITY, 
        ORR.ORDER_ROW_ID, 
        ORD.ORDER_ID, 
        ORD.ORDER_HEAD, 
        ORD.ORDER_NUMBER, 
        ISNULL(ORR.SPECT_VAR_ID, 0) AS SPECT_VAR_ID, 
        ORR.SPECT_VAR_NAME,
        ORR.ORDER_ROW_CURRENCY, 
        S.PRODUCT_NAME, 
        S.STOCK_CODE, 
        S.STOCK_CODE_2, 
        O1.ORDER_NUMBER AS LOT_NO, 
        O1.ORDER_DATE AS FINISH_DATE, 
        O1.ORDER_ID AS P_ORDER_ID, 
        3 AS TYPE
	FROM         
    	ORDER_ROW AS ORR INNER JOIN
        ORDERS AS ORD ON ORR.ORDER_ID = ORD.ORDER_ID INNER JOIN
        STOCKS AS S ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
        ORDER_ROW AS ORR1 ON ORR.WRK_ROW_ID = ORR1.WRK_ROW_RELATION_ID INNER JOIN
        ORDERS AS O1 ON ORR1.ORDER_ID = O1.ORDER_ID
	WHERE     
    	ORD.ORDER_ID = #attributes.order_id# AND 
        S.IS_PURCHASE = 1
	UNION ALL
	SELECT     
    	ORR.STOCK_ID, 
        ORR.QUANTITY, 
        ORR.ORDER_ROW_ID, 
        ORD.ORDER_ID, 
        ORD.ORDER_HEAD, 
        ORD.ORDER_NUMBER, 
        ISNULL(ORR.SPECT_VAR_ID, 0) AS SPECT_VAR_ID, 
        ORR.SPECT_VAR_NAME, 
        ORR.ORDER_ROW_CURRENCY,
        S.PRODUCT_NAME, 
        S.STOCK_CODE, 
        S.STOCK_CODE_2, 
        ORD1.ORDER_NUMBER AS LOT_NO, 
        ORD1.ORDER_DATE AS FINISH_DATE, 
        ORD1.ORDER_ID AS P_ORDER_ID, 
        4 AS TYPE
	FROM         
    	ORDER_ROW AS ORR INNER JOIN
        ORDERS AS ORD ON ORR.ORDER_ID = ORD.ORDER_ID INNER JOIN
        STOCKS AS S ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
        EZGI_ORDERS_ORDERS_REL ON ORR.ORDER_ROW_ID = EZGI_ORDERS_ORDERS_REL.S_ORDER_ROW_ID AND 
        ORR.ORDER_ID = EZGI_ORDERS_ORDERS_REL.S_ORDER_ID INNER JOIN
        ORDER_ROW AS ORR1 ON EZGI_ORDERS_ORDERS_REL.P_ORDER_ID = ORR1.ORDER_ID AND 
        EZGI_ORDERS_ORDERS_REL.P_ORDER_ROW_ID = ORR1.ORDER_ROW_ID INNER JOIN
        ORDERS AS ORD1 ON ORR1.ORDER_ID = ORD1.ORDER_ID
	WHERE     
    	ORD.ORDER_ID = #attributes.order_id# AND 
        (S.IS_PRODUCTION = 1 OR S.IS_PURCHASE = 1)
</cfquery>
<cfoutput query="get_order_det1">
	<cfset 'FINISH_DATE_#TYPE#_#ORDER_ROW_ID#'= FINISH_DATE>
</cfoutput>
<cfset order_row_id_list = Valuelist(get_order_det1.ORDER_ROW_ID)>
<cfquery name="get_order_det2" datasource="#DSN3#">
	SELECT     
    	ORR.STOCK_ID, 
        ORR.QUANTITY, 
        ORR.ORDER_ROW_ID, 
        ORD.ORDER_ID, 
        ORD.ORDER_HEAD, 
        ORD.ORDER_NUMBER, 
        ISNULL(ORR.SPECT_VAR_ID, 0) AS SPECT_VAR_ID, 
        ORR.SPECT_VAR_NAME, 
        ORR.ORDER_ROW_CURRENCY,
        S.PRODUCT_NAME, 
        S.STOCK_CODE, 
        S.STOCK_CODE_2, 
        '' AS LOT_NO, 
        '' AS FINISH_DATE, 
        0 AS P_ORDER_ID, 
        5 AS TYPE
	FROM         
    	ORDER_ROW AS ORR INNER JOIN
        STOCKS AS S ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
        ORDERS AS ORD ON ORR.ORDER_ID = ORD.ORDER_ID
	WHERE     
   		ORD.ORDER_ID = #attributes.order_id# AND 
        <cfif len(get_order_det1.ORDER_ROW_ID)>
       		ORR.ORDER_ROW_ID NOT IN (#order_row_id_list#) AND
        </cfif>
       	(S.IS_PRODUCTION = 1 OR S.IS_PURCHASE = 1)
</cfquery>
<cfquery name="get_order_det" dbtype="query">
	SELECT     
    	STOCK_ID, 
        QUANTITY, 
        ORDER_ROW_ID, 
        ORDER_ID, 
        ORDER_HEAD, 
        ORDER_NUMBER, 
        SPECT_VAR_ID, 
        SPECT_VAR_NAME,
        ORDER_ROW_CURRENCY, 
        PRODUCT_NAME, 
        STOCK_CODE, 
        STOCK_CODE_2, 
        LOT_NO, 
        P_ORDER_ID, 
        TYPE
	FROM
    	get_order_det1	   
	UNION ALL
    SELECT     
    	STOCK_ID, 
        QUANTITY, 
        ORDER_ROW_ID, 
        ORDER_ID, 
        ORDER_HEAD, 
        ORDER_NUMBER, 
        SPECT_VAR_ID, 
        SPECT_VAR_NAME,
        ORDER_ROW_CURRENCY, 
        PRODUCT_NAME, 
        STOCK_CODE, 
        STOCK_CODE_2, 
        LOT_NO, 
        P_ORDER_ID, 
        TYPE
	FROM
    	get_order_det2
  	ORDER BY
    	ORDER_ROW_ID      
</cfquery>
<cfset amount_round = 2>	
<table class="dph">
	<tr> 
		<td class="dpht"><cf_get_lang_main no='199.Sipariş'> <cf_get_lang_main no='44.Üretim'> <cf_get_lang_main no='577.ve'> <cf_get_lang_main no='1948.Tedarik'> <cf_get_lang_main no='1953.Rezerve'></td>
	</tr>
</table>
<cf_seperator id="iliskili_fatura" header="<cf_get_lang_main no='3441.İlişkili Üretim Emirleri'> <cf_get_lang_main no='577.ve'> <cf_get_lang_main no='2211.Satınalma Siparişleri'>">
<table id="iliskili_fatura" width="100%">
	<tr>
		<td>
			<cf_medium_list>
				<thead>
					<tr>
                    	<th><cf_get_lang_main no='1165.Sıra'></th> 
                    	<th><cf_get_lang_main no='106.Stok Kodu'></th>
						<th><cf_get_lang_main no='245.Ürün'></th>
                        <th><cfoutput>#getLang('objects',1535)#</cfoutput></th>
						<th width="50" style="text-align:right;"><cf_get_lang_main no='199.Sipariş'></th>
                        <th width="60"><cf_get_lang_main no='288.Bitiş Tarihi '></th>
                        <th width="70"><cfoutput>#getLang('prod',385)#</cfoutput></th>
                        <th width="15"></th>
					</tr>
				</thead>
				<tbody>
					<cfif get_order_det.recordcount>
                        <cfform name="orders" action="" method="post">
                            <cfoutput query="get_order_det">
                                <tr>
                                	<td>#currentrow#</td>
                                    <td>#get_order_det.STOCK_CODE#</td>
                                    <td>#get_order_det.PRODUCT_NAME#</td>
                                    <td>#get_order_det.SPECT_VAR_NAME#</td>
                                    <td style="text-align:right;">#TLFormat(get_order_det.QUANTITY,amount_round)#</td>
                                    <td style="text-align:center;">
                                    	<cfif isdefined('FINISH_DATE_#TYPE#_#ORDER_ROW_ID#')>
                                    		#DateFormat(Evaluate('FINISH_DATE_#TYPE#_#ORDER_ROW_ID#'),'dd/mm/yyyyY')#
                                   		</cfif>
                                    </td>
                                    <td style="text-align:center;">#lot_no#</td>
                                    <td style="text-align:center;">
										<cfif TYPE eq 2 or TYPE eq 4>
                                        	<a href="javascript://" onClick="sil(#ORDER_ID#,#ORDER_ROW_ID#,#P_ORDER_ID#,#TYPE#);"><img src="/images/delete_list.gif" align="absmiddle" border="0"></a>
                                      	<cfelseif TYPE eq 1 or TYPE eq 3>
                                        	<cfif session.ep.admin eq 1>
                                        		<a href="javascript://" onClick="sil(#ORDER_ID#,#ORDER_ROW_ID#,#P_ORDER_ID#,#TYPE#);"><img src="/images/delete_list.gif" align="absmiddle" border="0"></a>
                                            </cfif>
                                        <cfelse>
                                        	<cfif TYPE eq 5>
                                            	<!---<cfif ORDER_ROW_CURRENCY neq -9 and ORDER_ROW_CURRENCY neq -10 and ORDER_ROW_CURRENCY neq -8 and ORDER_ROW_CURRENCY neq -3>--->
													<a href="javascript://" onClick="ekle(#ORDER_ID#,#ORDER_ROW_ID#,#STOCK_ID#,#SPECT_VAR_ID#,#QUANTITY#);"><img src="/images/plus_list.gif" align="absmiddle" border="0"></a>
                                            	<!---<cfelse>
                                                	<img src="/images/c_ok.gif" align="absmiddle" border="0">
                                                </cfif>--->
                                        	</cfif>
                                        </cfif>
                                    </td>
                                </tr>
                            </cfoutput>
                        </cfform>
					</cfif>
				</tbody>
                <tfoot>
                	<tr class="color-list" height="35">
                      	<td align="right" valign="middle" colspan="8">&nbsp;<div id="groups_p"></div></td>
                   	</tr>
              	</tfoot>
			</cf_medium_list>
      	</td>      
	</tr>
</table>
<script language="javascript">
	function ekle(order_id,order_row_id,stock_id,spect_var_id,quantity)
	{	
		window.location ='<cfoutput>#request.self#</cfoutput>?fuseaction=sales.popup_list_ezgi_production&stock_id='+stock_id+'&order_id='+order_id+'&order_row_id='+order_row_id+'&spect_var_id='+spect_var_id+'&ord_quantity='+quantity;	
	}
	function sil(order_id,order_row_id,p_order_id,type)
	{	
		window.location ='<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_del_ezgi_order_rel&order_id='+order_id+'&order_row_id='+order_row_id+'&p_order_id='+p_order_id+'&type='+type;
	}
</script>	