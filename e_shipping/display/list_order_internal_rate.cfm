<cfquery name="GET_PERIOD_DIS_SHIP" datasource="#DSN#">
	SELECT 
    	PERIOD_YEAR, 
        OUR_COMPANY_ID, 
        PERIOD_ID 
  	FROM 
    	SETUP_PERIOD 
   	WHERE 
    	OUR_COMPANY_ID = #session.ep.company_id# AND 
        PERIOD_YEAR >2013 
  	ORDER BY 
    	PERIOD_YEAR
</cfquery>
<cfquery name="get_basket" datasource="#dsn3#">
	SELECT AMOUNT_ROUND FROM SETUP_BASKET WHERE B_TYPE = 1 AND BASKET_ID = 4 ORDER BY BASKET_ID
</cfquery>
<cfset amount_round = get_basket.amount_round>
<cfquery name="get_orders_ship" datasource="#dsn3#">
	SELECT
		PERIOD_ID AS SHIP_PERIOD_ID
	FROM
		EZGI_ORDERS_SHIP_INTERNAL
	WHERE
		ORDER_ID = #attributes.order_id#
</cfquery>
<cfset ship_list="">
<cfset period_list_ship = "">
<cfif get_orders_ship.recordcount>
	<cfif isdefined('attributes.order_id') and len(attributes.order_id)>
		<cfset period_list_ship = listsort(valuelist(get_orders_ship.SHIP_PERIOD_ID),"numeric","asc",",")>
        <cfquery name="get_period_ship_dsns" datasource="#dsn3#">
            SELECT PERIOD_YEAR,OUR_COMPANY_ID,PERIOD_ID FROM #dsn_alias#.SETUP_PERIOD WHERE PERIOD_ID IN (#period_list_ship#)
        </cfquery>
	</cfif>
</cfif>
	<cfquery name="get_order_det" datasource="#DSN3#">
		SELECT
			ORR.STOCK_ID,
            ORR.QUANTITY,
            ORR.ORDER_ROW_ID,
            ORD.ORDER_ID,
            ORD.ORDER_HEAD, 
            ORD.ORDER_NUMBER,
            ORR.SPECT_VAR_ID,
            ORR.SPECT_VAR_NAME,
            S.PRODUCT_NAME,
            S.STOCK_CODE,
            S.STOCK_CODE_2
		FROM
			ORDER_ROW ORR,
			ORDERS ORD,
			STOCKS S
		WHERE
			ORD.ORDER_ID = ORR.ORDER_ID AND
			ORR.STOCK_ID = S.STOCK_ID AND 
            ORD.ORDER_ID = #attributes.order_id#
	</cfquery>
    <cfset order_row_id_list = Valuelist(get_order_det.ORDER_ROW_ID)>
    <cfquery name="get_teshir" datasource="#dsn3#">
    	SELECT ORDER_ROW_ID FROM EZGI_ORDER_TESHIR WHERE ORDER_ROW_ID IN (#order_row_id_list#)
    </cfquery>
    <cfoutput query="get_teshir">
    	<cfset 'teshir_#ORDER_ROW_ID#'= ORDER_ROW_ID>
  	</cfoutput>
	<cfif listlen(period_list_ship) and period_list_ship neq 0>
		<cfquery name="get_ship_det" datasource="#DSN3#">
        	SELECT
            	SHIP_YEAR,
                SHIP_ID,
                DELIVER_DATE,
                STOCK_ID,
                SPECT_VAR_ID,
                IRS_AMOUNT,
                SHIP_NUMBER,
                WRK_ROW_RELATION_ID,
                ROW_ORDER_ID
          	FROM	
            	(
                <cfloop query="get_period_DIS_SHIP">
                    SELECT     
                        #get_period_DIS_SHIP.PERIOD_YEAR# AS SHIP_YEAR, 
                        S.DISPATCH_SHIP_ID SHIP_ID,
                        S.DELIVER_DATE,
                        SR.STOCK_ID,
                        SR.SPECT_VAR_ID, 
                        AMOUNT AS IRS_AMOUNT,
                        '' AS SHIP_NUMBER,
                        ISNULL(WRK_ROW_RELATION_ID,0) AS WRK_ROW_RELATION_ID,
                        ROW_ORDER_ID
                    FROM          
                        #dsn#_#get_period_DIS_SHIP.PERIOD_YEAR#_#get_period_DIS_SHIP.OUR_COMPANY_ID#.SHIP_INTERNAL S,
                        #dsn#_#get_period_DIS_SHIP.PERIOD_YEAR#_#get_period_DIS_SHIP.OUR_COMPANY_ID#.SHIP_INTERNAL_ROW SR
                    WHERE
                        SR.DISPATCH_SHIP_ID=S.DISPATCH_SHIP_ID AND
                        SR.ROW_ORDER_ID IN (#order_row_id_list#) 
                    <cfif currentrow neq get_period_DIS_SHIP.recordcount> UNION ALL </cfif>					
				</cfloop>
                ) AS TBL
		</cfquery>
        <!---<cfdump expand="yes" var="#get_ship_det#">
        <cfabort>--->
        <cfquery name="get_ship_det_group" dbtype="query">
        	SELECT
            	SHIP_YEAR,
                SHIP_ID,
                DELIVER_DATE
           	FROM
            	get_ship_det
            GROUP BY
            	SHIP_YEAR,
                SHIP_ID,
                DELIVER_DATE
          	ORDER BY
           		SHIP_YEAR 	     

        </cfquery>
		<cfset ship_list_2=listsort(valuelist(get_ship_det.SHIP_ID),"numeric","asc",",")>
		<cfset ship_list=listsort(ListDeleteDuplicates(valuelist(get_ship_det.SHIP_ID)),"numeric","asc",",")>
	</cfif>
<table class="dph">
	<tr> 
		<td class="dpht"><cf_get_lang_main no='3558.Sipariş Talep Formu'><cfif get_orders_ship.recordcount>: <cfoutput>#get_order_det.ORDER_NUMBER# - #get_order_det.ORDER_HEAD#</cfoutput></cfif></td>
	</tr>
</table>
<cf_seperator id="iliskili_fatura" header="#getLang('campaign',244)# #getLang('myhome',1276)#">
<table id="iliskili_fatura" width="100%">
	<tr>
		<td>
				 <cf_medium_list>
					<thead>
						<tr> 
							<th><cf_get_lang_main no='245.Ürün'></th>
							<th><cf_get_lang_main no='106.Stok Kodu'></th>
							<th><cf_get_lang_main no='377.Özel Kod'></th>
							<th><cf_get_lang_main no='235.Spec'></th>
							<th width="50" style="text-align:right;"><cf_get_lang_main no='199.Sipariş'></th>
                            
							<cfoutput>
							<cfif get_orders_ship.recordcount>
                            	<cfif len(ship_list)>
                                    <cfloop query="get_ship_det_group">
                                        <th width="70"style="text-align:right;">
                                            Sevk Talebi<br/>
                                            	<cfif get_ship_det_group.ship_year eq session.ep.period_year>
                                                	<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=stock.add_dispatch_internaldemand&event=upd&ship_id=#get_ship_det_group.ship_id#</cfoutput>','longpage');" style="color:##FF0000">
                                                	(#dateformat(get_ship_det_group.DELIVER_DATE,'dd/mm/yyyy')#)
                                                	</a>
                                                <cfelse>
                                                	(#dateformat(get_ship_det_group.DELIVER_DATE,'dd/mm/yyyy')#)
                                                </cfif>
                                        </th>
                                    </cfloop>
								</cfif>
                            
							</cfif>
							</cfoutput>
                            </th>
                            <th width="20" style="text-align:center;">TŞH</th>
							<th width="50" style="text-align:right;"><cf_get_lang_main no='1032.Kalan'></th>
                            <th width="10" style="text-align:center;">&nbsp;<input type="checkbox" style="text-align:center;" alt="<cf_get_lang_main no='3009.Hepsini Seç'>" onClick="grupla(-1);"></th>
						</tr>
					</thead>
					<tbody>
                    
					<cfif get_order_det.recordcount>
                        <cfform name="ship_internal" action="#request.self#?fuseaction=prod.add_ezgi_metarial_control" method="post">
                        	<cfinput type="hidden" name="order_id" value="#attributes.order_id#">
                            <cfoutput query="get_order_det">
                                <cfset irs_top=0>
                                <cfset stock_id=get_order_det.STOCK_ID>
                                <tr>
                                    <td>#get_order_det.PRODUCT_NAME#</td>
                                    <td>#get_order_det.STOCK_CODE#</td>
                                    <td>#get_order_det.STOCK_CODE_2#</td>
                                    <td><cfif len(get_order_det.SPECT_VAR_ID)>#get_order_det.SPECT_VAR_NAME#-#get_order_det.SPECT_VAR_ID#</cfif></td>
                                    <td style="text-align:right;">#AmountFormat(get_order_det.QUANTITY)#</td>
                                    
                                        <cfif len(ship_list)>
                                            <cfloop list="#ship_list#" index="z">
                                                <cfquery name="get_amount_shp" dbtype="query">
                                                    SELECT IRS_AMOUNT,SHIP_ID FROM get_ship_det WHERE SHIP_ID=#z# AND STOCK_ID=#stock_id# <cfif Len(spect_var_id)>AND ROW_ORDER_ID = #ORDER_ROW_ID#</cfif> 
                                                </cfquery>

                                                <td style="text-align:right;">
                                                    <cfif get_amount_shp.recordcount neq 0 and len(get_amount_shp.IRS_AMOUNT)>
                                                        #AmountFormat(get_amount_shp.IRS_AMOUNT)#
                                                        <cfset irs_top=irs_top+get_amount_shp.IRS_AMOUNT>
                                                    <cfelse>
                                                        -
                                                    </cfif>
                                                </td>
                                            </cfloop>
                                        </cfif>
                                  	<td style="text-align:center;">
                                    	<cfif isdefined('teshir_#ORDER_ROW_ID#')>
                                    		<a href="javascript://" onClick="sil(#ORDER_ROW_ID#,#ORDER_ID#);"><img src="/images/delete_list.gif" align="absmiddle" border="0"></a>
                                      	<cfelse>
                                        	<cfif irs_top eq 0>
                                        		<a href="javascript://" onClick="ekle(#ORDER_ROW_ID#,#ORDER_ID#);"><img src="/images/plus_list.gif" align="absmiddle" border="0"></a>
                                            </cfif>
                                        </cfif>
                                    </td>
                                    <td style="text-align:right;">#AmountFormat(get_order_det.QUANTITY-irs_top)#</td>
                                    <td style="text-align:center;"><cfif get_order_det.QUANTITY-irs_top gt 0 and not isdefined('teshir_#ORDER_ROW_ID#')><input type="checkbox" name="select_production" value="#ORDER_ROW_ID#"><cfelse>&nbsp;</cfif></td>
                                </tr>
                            </cfoutput>
                        </cfform>
					</cfif>
					</tbody>
                    <tfoot>
                    	<tr class="color-list" height="35">
                        	<cfset row_len = 6 + Listlen(ship_list)>
                            <td align="right" valign="middle" colspan="<cfoutput>#row_len#</cfoutput>">&nbsp;</td>
                            <td align="right" valign="middle" colspan="2"><input type="button" value="<cf_get_lang_main no='3559.Sevk Talebi Oluştur'>" onClick="grupla();"></td>
                        </tr>
                    </tfoot>
				 </cf_medium_list>
</table>
<script language="javascript">
	function ekle(order_row_id,order_id)
	{	
		window.location ='<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_add_ezgi_teshir&order_row_id='+order_row_id+'&order_id='+order_id;	
	}
	function sil(order_row_id,order_id)
	{	
		window.location ='<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_del_ezgi_teshir&order_row_id='+order_row_id+'&order_id='+order_id;
	}
	function grupla(type)
		{//type sadece -1 olarak gelir,-1 geliyorsa hepsini seç demektir.
			order_row_id_list = '';
			chck_leng = document.getElementsByName('select_production').length;
			for(ci=0;ci<chck_leng;ci++)
			{
				var my_objets = document.all.select_production[ci];
				if(chck_leng == 1)
					var my_objets =document.all.select_production;
				if(type == -1)
				{//hepsini seç denilmişse	
					if(my_objets.checked == true)
						my_objets.checked = false;
					else
						my_objets.checked = true;
				}
				else
				{
					if(my_objets.checked == true)
						order_row_id_list +=my_objets.value+',';
				}
			}
			var order_id = document.all.order_id.value;
			order_row_id_list = order_row_id_list.substr(0,order_row_id_list.length-1);//sondaki virgülden kurtarıyoruz.
			if(order_row_id_list!='')
			{
			window.open('<cfoutput>#request.self#</cfoutput>?fuseaction=sales.add_ezgi_ship_internal&order_row_id_list='+order_row_id_list+'&order_id='+order_id);
			window.location.reload()
			}
		}
</script>