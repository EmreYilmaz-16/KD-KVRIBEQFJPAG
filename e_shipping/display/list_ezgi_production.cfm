<cfquery name="get_order_det" datasource="#DSN3#">
	SELECT 
        1 TYPE,    
        P_ORDER_ID, 
        STOCK_ID, 
        START_DATE, 
        FINISH_DATE, 
        QUANTITY, 
        P_ORDER_NO, 
        LOT_NO, 
        IS_STAGE, 
        SPEC_MAIN_ID,
        ISNULL((
        SELECT 
        	SUM(QUANTITY) AS QUANTITY
      	FROM
        	(
            SELECT     
                ISNULL(ORR.QUANTITY,0) AS QUANTITY
            FROM          
                PRODUCTION_ORDERS AS PO INNER JOIN
                PRODUCTION_ORDERS_ROW AS POR ON PO.P_ORDER_ID = POR.PRODUCTION_ORDER_ID INNER JOIN
                ORDER_ROW AS ORR ON POR.ORDER_ROW_ID = ORR.ORDER_ROW_ID
            WHERE      
                PO.P_ORDER_ID = PRODUCTION_ORDERS.P_ORDER_ID AND 
                ORR.STOCK_ID = PRODUCTION_ORDERS.STOCK_ID
            UNION ALL
            SELECT     
                AMOUNT AS QUANTITY
            FROM         
                EZGI_P_ORDER_RESERVE_UPDATE
            WHERE     
                SPEC_MAIN_ID = PRODUCTION_ORDERS.SPEC_MAIN_ID AND 
                STOCK_ID = PRODUCTION_ORDERS.STOCK_ID AND 
                P_ORDER_ID = PRODUCTION_ORDERS.P_ORDER_ID
       		)TBL_E
     	),0) AS O_QUANTITY,
        (
        SELECT     
        	PRODUCT_ID
		FROM         
        	STOCKS
		WHERE     
        	STOCK_ID = PRODUCTION_ORDERS.STOCK_ID
        ) AS PRODUCT_ID
	FROM         
    	PRODUCTION_ORDERS
	WHERE     
    	STOCK_ID = #attributes.stock_id# AND 
        <cfif isdefined('attributes.spect_var_id') and attributes.spect_var_id neq 0>
        SPEC_MAIN_ID =  (
        				SELECT     
                        	SPECT_MAIN_ID
						FROM         
                        	SPECTS
						WHERE     
                        	SPECT_VAR_ID = #attributes.spect_var_id#
                     	) AND 
      	</cfif>                   
    	STATUS = 1
  	UNION ALL
    SELECT 
        2 TYPE, 
    	ORD_ROW.ORDER_ROW_ID P_ORDER_ID,    
        ORD_ROW.STOCK_ID, 
        ORDERS.ORDER_DATE START_DATE,
        ORD_ROW.DELIVER_DATE FINISH_DATE,
        ORD_ROW.QUANTITY,
        ORDERS.ORDER_NUMBER,
        '' AS LOT_NO,
        CASE 
        	WHEN 
            	ORD_ROW.ORDER_ROW_CURRENCY = -10 OR
                ORD_ROW.ORDER_ROW_CURRENCY = -9 OR
                ORD_ROW.ORDER_ROW_CURRENCY = -8 OR
                ORD_ROW.ORDER_ROW_CURRENCY = -3
           	THEN
            	7
          	WHEN
            	ORD_ROW.ORDER_ROW_CURRENCY = -5 OR
                ORD_ROW.ORDER_ROW_CURRENCY = -4 OR
                ORD_ROW.ORDER_ROW_CURRENCY = -2 OR
                ORD_ROW.ORDER_ROW_CURRENCY = -1
          	THEN
            	5
          	WHEN
            	ORD_ROW.ORDER_ROW_CURRENCY = -7 OR
                ORD_ROW.ORDER_ROW_CURRENCY = -6
        	THEN
            	6
          	END
            	AS IS_STAGE,           	            
        S.SPECT_MAIN_ID,
        ORDER_ROW.QUANTITY O_QUANTITY,
        ORD_ROW.PRODUCT_ID
    FROM         
    	ORDER_ROW AS ORD_ROW INNER JOIN
        ORDERS ON ORD_ROW.ORDER_ID = ORDERS.ORDER_ID INNER JOIN
        ORDER_ROW ON ORD_ROW.WRK_ROW_RELATION_ID = ORDER_ROW.WRK_ROW_ID LEFT OUTER JOIN
        SPECTS AS S ON ORD_ROW.SPECT_VAR_ID = S.SPECT_VAR_ID
	WHERE     
    	ORDERS.PURCHASE_SALES = 0 AND 
        ORDERS.ORDER_ZONE = 0 AND
        ORD_ROW.STOCK_ID = #attributes.stock_id# 
        <cfif isdefined('attributes.spect_var_id') and attributes.spect_var_id neq 0>
        AND  S.SPECT_MAIN_ID =  
        				(
        				SELECT     
                        	SPECT_MAIN_ID
						FROM         
                        	SPECTS
						WHERE     
                        	SPECT_VAR_ID = #attributes.spect_var_id#
                     	)
      	</cfif>  
    UNION ALL
  	SELECT 
        3 TYPE,
    	ORD_ROW.ORDER_ROW_ID P_ORDER_ID,    
        ORD_ROW.STOCK_ID, 
        ORDERS.ORDER_DATE START_DATE,
        ORD_ROW.DELIVER_DATE FINISH_DATE,
        ORD_ROW.QUANTITY,
        ORDERS.ORDER_NUMBER,
        '' AS LOT_NO,
        CASE 
        	WHEN 
            	ORD_ROW.ORDER_ROW_CURRENCY = -10 OR
                ORD_ROW.ORDER_ROW_CURRENCY = -9 OR
                ORD_ROW.ORDER_ROW_CURRENCY = -8 OR
                ORD_ROW.ORDER_ROW_CURRENCY = -3
           	THEN
            	7
          	WHEN
            	ORD_ROW.ORDER_ROW_CURRENCY = -5 OR
                ORD_ROW.ORDER_ROW_CURRENCY = -4 OR
                ORD_ROW.ORDER_ROW_CURRENCY = -2 OR
                ORD_ROW.ORDER_ROW_CURRENCY = -1
          	THEN
            	5
          	WHEN
            	ORD_ROW.ORDER_ROW_CURRENCY = -7 OR
                ORD_ROW.ORDER_ROW_CURRENCY = -6
        	THEN
            	6
          	END
            	AS IS_STAGE,           	            
        S.SPECT_MAIN_ID,
        (
        SELECT     
        	ISNULL(SUM(ORR.QUANTITY),0) AS QUANTITY
		FROM         
        	EZGI_ORDERS_ORDERS_REL AS E INNER JOIN
            ORDER_ROW AS ORR ON E.S_ORDER_ROW_ID = ORR.ORDER_ROW_ID AND E.S_ORDER_ID = ORR.ORDER_ID
		WHERE     
        	E.P_ORDER_ROW_ID = ORD_ROW.ORDER_ROW_ID 
        ) AS O_QUANTITY,
        ORD_ROW.PRODUCT_ID
	FROM
   		ORDER_ROW AS ORD_ROW INNER JOIN
        ORDERS ON ORD_ROW.ORDER_ID = ORDERS.ORDER_ID LEFT OUTER JOIN
        ORDER_ROW ON ORD_ROW.WRK_ROW_RELATION_ID = ORDER_ROW.WRK_ROW_ID LEFT OUTER JOIN
        SPECTS AS S ON ORD_ROW.SPECT_VAR_ID = S.SPECT_VAR_ID
	WHERE     
    	ORDERS.PURCHASE_SALES = 0 AND 
        ORDERS.ORDER_ZONE = 0 AND
        ORD_ROW.STOCK_ID = #attributes.stock_id# 
        <cfif isdefined('attributes.spect_var_id') and attributes.spect_var_id neq 0>
        AND  S.SPECT_MAIN_ID =  
        				(
        				SELECT     
                        	SPECT_MAIN_ID
						FROM         
                        	SPECTS
						WHERE     
                        	SPECT_VAR_ID = #attributes.spect_var_id#
                     	)
      	</cfif>  
        AND ORDER_ROW.WRK_ROW_ID IS NULL
  	ORDER BY
    	FINISH_DATE desc
</cfquery>
<cfquery name="get_stock_info" datasource="#dsn3#">
	SELECT     
    	S.STOCK_CODE, 
        S.PRODUCT_NAME, 
        PU.MAIN_UNIT
	FROM         
    	STOCKS AS S LEFT OUTER JOIN
        PRODUCT_UNIT AS PU ON S.PRODUCT_ID = PU.PRODUCT_ID
	WHERE     
    	S.STOCK_ID = #attributes.stock_id# AND 
        PU.IS_MAIN = 1
</cfquery>
<cfset amount_round = 2>	
<table class="dph">
	<tr> 
		<td class="dpht"><cf_get_lang_main no='3452.Üretim Emirleri'> - <cf_get_lang_main no='245.Ürün'> : <cfoutput>#get_stock_info.PRODUCT_NAME# - #Amountformat(attributes.ord_quantity)# #get_stock_info.MAIN_UNIT#</cfoutput></td>
        <td width="20">
        	<a href="<cfoutput>#request.self#?fuseaction=sales.popup_list_order_production_rate&order_id=#attributes.order_id#"><img src="/images/outsource.gif" title="<cf_get_lang_main no='3390.Master Plana Geri Dön'>" border="0"></cfoutput></a>
        </td>
	</tr>
</table>
<table id="iliskili_fatura" width="100%">
	<tr>
		<td>
			<cf_medium_list>
				<thead>
					<tr> 
                    	<th width="70" style="text-align:center;"><cfoutput>#getLang('prod',385)#</cfoutput></th>
						<th style="text-align:center;"><cfoutput>#getLang('main',1677)#</cfoutput></th>
                        <th width="70" style="text-align:center;"><cfoutput>#getLang('main',243)#</cfoutput></th>
                        <th width="70" style="text-align:center;"><cf_get_lang_main no='288.Bitiş Tarihi'></th>
                        <th width="80" style="text-align:center;"><cfoutput>#getLang('main',2941)#</cfoutput></th>
                        <th width="20" style="text-align:center;"><cf_get_lang_main no='3341.DRM'></th>
                        <th width="80" style="text-align:center;"><cf_get_lang_main no='3561.Rezerve Miktar'></th>
                        <th width="15" style="text-align:center;"></th>
					</tr>
				</thead>
				<tbody>
					<cfif get_order_det.recordcount>
                        <cfform name="orders" action="" method="post">
                            <cfoutput query="get_order_det">
                                <tr>
                                	<td>#lot_no#</td>
                                    <td>#p_order_no#</td>
                                    <td>#DateFormat(START_DATE,'dd/mm/yyyyY')#</td>
                                    <td>#DateFormat(FINISH_DATE,'dd/mm/yyyyY')#</td>
                                    <td style="text-align:right;">#TLFormat(QUANTITY,amount_round)#</td>
                                    <td style="text-align:center;">
                                    	<cfif IS_STAGE eq 0>
                                        	<img src="/images/yellow_glob.gif" title="<cf_get_lang_main no='293.İşleniyor'>">
                                        <cfelseif IS_STAGE eq 1>
                                        	<img src="/images/green_glob.gif" title="<cfoutput>#getLang('objects2',1387)#</cfoutput>">
                                        <cfelseif IS_STAGE eq 2>
                                        	<img src="/images/red_glob.gif" title="<cf_get_lang_main no='1374.Tamamlandı'>">
                                       	<cfelseif IS_STAGE eq 5>
                                        	<img src="/images/yellow_glob.gif" title="<cf_get_lang_main no='3279.Başlamadı'>">
										<cfelseif IS_STAGE eq 6>
                                        	<img src="/images/green_glob.gif" title="<cf_get_lang_main no='1349.Sevk'> <cf_get_lang_main no='3201.Başladı'>">
                                        <cfelseif IS_STAGE eq 7>
                                        	<img src="/images/red_glob.gif" title="<cfoutput>#getLang('main',296)# #getLang('asset',17)#</cfoutput>">     
                                        <cfelse>
                                        	<img src="/images/grey_glob.gif" title="<cf_get_lang_main no='3279.Başlamadı'>">
                                        </cfif>
                                    </td>
                                    <td style="text-align:right;">
                                    	<a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=objects.popup_reserved_orders&taken=1&pid=#PRODUCT_ID#&p_order_id=#P_ORDER_ID#&type=#TYPE#','list');" class="tableyazi"> 
                                    		#TLFormat(O_QUANTITY,amount_round)#
                                   		</a>
                                    </td>
                                    <td style="text-align:center;">
										<cfif O_QUANTITY + attributes.ord_quantity lte QUANTITY>
                                        	<cfif TYPE eq 1>
											<a href="javascript://" onClick="ekle_(#attributes.ORDER_ID#,#attributes.ORDER_ROW_ID#,#P_ORDER_ID#,1);"><img src="/images/action_plus.gif" align="absmiddle" border="0" title="<cf_get_lang_main no='44.Üretim'> <cf_get_lang_main no='497.İlişkilendir'>"></a>
                                            <cfelse>
                                            	<a href="javascript://" onClick="ekle_(#attributes.ORDER_ID#,#attributes.ORDER_ROW_ID#,#P_ORDER_ID#,2);"><img src="/images/action_plus.gif" align="absmiddle" border="0" title="<cf_get_lang_main no='1948.Tedarik'> <cf_get_lang_main no='497.İlişkilendir'>"></a>
                                            </cfif>
                                      	<cfelse>
                                          	<img src="/images/action_pasif.gif" align="absmiddle" border="0" title="<cfoutput>#getLang('production',80)#</cfoutput>">    
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
	function ekle_(order_id,order_row_id,p_order_id,type)
	{	
		window.location ='<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_add_ezgi_order_rel&order_id='+order_id+'&order_row_id='+order_row_id+'&p_order_id='+p_order_id+'&type='+type;
	}
</script>	