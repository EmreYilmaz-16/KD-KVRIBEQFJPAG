<cfset module_name="sales">
<cfquery name="get_shippng_plan" datasource="#dsn3#">
	SELECT     
    	ESR.SHIP_RESULT_ID, 
        ESR.DELIVER_EMP, 
        ESR.NOTE, 
        ESR.DELIVER_PAPER_NO, 
        ESR.REFERENCE_NO, 
        ESR.OUT_DATE, 
        SM.SHIP_METHOD, 
        ESR.SHIP_METHOD_TYPE, 
        ESR.DELIVERY_DATE, 
        ESR.DEPARTMENT_ID, 
        ESR.SHIP_STAGE, 
        ESR.COMPANY_ID, 
        ESR.PARTNER_ID, 
        ESR.CONSUMER_ID, 
        ESR.IS_TYPE, 
        ESR.LOCATION_ID
	FROM         
    	EZGI_SHIP_RESULT AS ESR INNER JOIN
    	#dsn_alias#.SHIP_METHOD AS SM ON ESR.SHIP_METHOD_TYPE = SM.SHIP_METHOD_ID
	WHERE     
    	ESR.SHIP_RESULT_ID = #attributes.iid#
</cfquery>

<cfif get_shippng_plan.recordcount>
	<cfparam name="attributes.reference_no" default="#get_shippng_plan.REFERENCE_NO#">
    <cfparam name="attributes.ship_method_id" default="#get_shippng_plan.SHIP_METHOD_TYPE#">
    <cfparam name="attributes.ship_method_name" default="#get_shippng_plan.SHIP_METHOD#">
    <cfquery name="get_department" datasource="#dsn#">
		SELECT     
        	DEPARTMENT.DEPARTMENT_HEAD, 
            DEPARTMENT.BRANCH_ID, 
            DEPARTMENT.DEPARTMENT_ID, 
            STOCKS_LOCATION.LOCATION_ID, 
            STOCKS_LOCATION.COMMENT
		FROM         
    		DEPARTMENT INNER JOIN
        	STOCKS_LOCATION ON DEPARTMENT.DEPARTMENT_ID = STOCKS_LOCATION.DEPARTMENT_ID
  	  	WHERE     
        	DEPARTMENT.DEPARTMENT_ID = #get_shippng_plan.DEPARTMENT_ID# AND 
            STOCKS_LOCATION.LOCATION_ID = #get_shippng_plan.LOCATION_ID#    
	</cfquery>
    <cfparam name="attributes.branch_id" default="#get_department.BRANCH_ID#">
    <cfparam name="attributes.department_id" default="#get_department.DEPARTMENT_ID#">
    <cfparam name="attributes.location_id" default="#get_department.LOCATION_ID#">
    <cfparam name="attributes.department_name" default="#get_department.DEPARTMENT_HEAD#-#get_department.COMMENT#">
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
            ORR.PRODUCT_NAME2,
            S.PRODUCT_NAME,
            S.STOCK_CODE,
            S.STOCK_CODE_2,
            (
            SELECT     
            	SPECT_MAIN_ID
			FROM         
            	SPECTS
			WHERE     
            	SPECT_VAR_ID = ORR.SPECT_VAR_ID
            ) AS SPECT_MAIN_ID,
            ESRR.ORDER_ROW_AMOUNT,
            ESRR.SHIP_RESULT_ID,
            ESRR.SHIP_RESULT_ROW_ID,
            ORR.ORDER_ROW_CURRENCY
		FROM         
        	ORDER_ROW AS ORR INNER JOIN
            ORDERS AS ORD ON ORR.ORDER_ID = ORD.ORDER_ID INNER JOIN
            STOCKS AS S ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
            EZGI_SHIP_RESULT_ROW AS ESRR ON ORR.ORDER_ROW_ID = ESRR.ORDER_ROW_ID
		WHERE     
        	ESRR.SHIP_RESULT_ID = #attributes.iid#
      	ORDER BY
        	ORR.ORDER_ROW_ID
	</cfquery>
    <cfset order_row_id_list = Valuelist(get_order_det.ORDER_ROW_ID)>
</cfif>
<cf_popup_box title="<cf_get_lang_main no='3566.Sevkiyat Planı Ekle'>">
<div style="text-align:right"><a href="javascript://" onclick="windowopen('index.cfm?fuseaction=objects.popup_print_files_old&print_type=32&action_id=<cfoutput>#get_shippng_plan.IS_TYPE#-#attributes.iid#</cfoutput>','page');"><img src="/images/print2.gif" alt=" Yazdır " border="0" title=" Yazdır ">
                                </a></div>
	<cfform name="add_packet_ship" id="add_packet_ship" method="post" action="#request.self#?fuseaction=sales.emptypopup_upd_ezgi_shipping&iid=#attributes.iid#">
		<table style="width:100%">
			
            <cfinput type="hidden" name="ship_result_id" value="#attributes.iid#">
            <cfif isdefined('order_row_id_list')>
            	<cfinput type="hidden" name="order_row_id_list" value="#order_row_id_list#">
            </cfif>
			<input type="hidden" name="order_comp" id="order_comp" value="<cfoutput>#get_par_info(get_shippng_plan.company_id,1,0,0)#</cfoutput>">
			<input type="hidden" name="order_cons" id="order_cons" value="<cfoutput>#get_cons_info(get_shippng_plan.consumer_id,1,0,0)#</cfoutput>">
			<cfif len(get_shippng_plan.ship_method)>
				<input type="hidden" name="order_type" id="order_type" value="<cfoutput>#get_shippng_plan.ship_method#</cfoutput>">
			<cfelse>
				<input type="hidden" name="order_type" id="order_type" value="">
			</cfif>
			<tr>
				<td width="110"><cf_get_lang_main no='1447.Süreç'>*</td>
				<td width="230"><cf_workcube_process is_upd='0' process_cat_width='170' is_detail='0'></td>
				<td><cfoutput>#getLang('report',1163)#</cfoutput> *</td>
				<td><input name="transport_no1" id="transport_no1" type="text" value="<cfoutput>#get_shippng_plan.DELIVER_PAPER_NO#</cfoutput>" readonly style="width:100px;"></td>
			</tr>
			<tr>
				<td><cf_get_lang_main no='107.Cari Hesap'> *</td>
				<td>
					<cfif get_shippng_plan.recordcount>
						<input type="hidden" name="consumer_id" id="consumer_id" value="<cfoutput>#get_shippng_plan.consumer_id#</cfoutput>">
						<input type="hidden" name="company_id" id="company_id" value="<cfoutput>#get_shippng_plan.company_id#</cfoutput>">
						<input type="hidden" name="partner_id" id="partner_id" value="<cfoutput>#get_shippng_plan.partner_id#</cfoutput>">
						<input type="text" name="company" id="company" value="<cfoutput>#get_par_info(get_shippng_plan.company_id,1,0,0)#</cfoutput>" readonly style="width:170px;">
					<cfelse>
						<input type="hidden" name="consumer_id" id="consumer_id" value="<cfif isdefined("attributes.consumer_id")><cfoutput>#attributes.consumer_id#</cfoutput></cfif>">
						<input type="hidden" name="company_id" id="company_id" value="<cfif isdefined("attributes.company_id")><cfoutput>#attributes.company_id#</cfoutput></cfif>">
						<input type="hidden" name="partner_id" id="partner_id" value="<cfif isdefined("attributes.partner_id")><cfoutput>#attributes.partner_id#</cfoutput></cfif>">
						<input type="text" name="company" id="company" value="<cfif isdefined("attributes.company")><cfoutput>#attributes.company#</cfoutput></cfif>" readonly style="width:170px;">
					</cfif>
				</td>
                <td><cf_get_lang_main no='1382.Referans No'></td>
				<td><input type="text" name="reference_no" id="reference_no" readonly="readonly" value="<cfoutput>#attributes.reference_no#</cfoutput>" maxlength="25" style="width:100px;"></td>
				
			</tr>
			<tr>
				<td><cf_get_lang_main no='166.Yetkili'> *</td>
				<td>
					<cfif get_shippng_plan.recordcount>
						<input type="text" name="member_name" id="member_name" value="<cfoutput>#get_par_info(get_shippng_plan.partner_id,0,-1,0)#</cfoutput>" readonly style="width:170px;">
					<cfelse>
						<input type="text" name="member_name" id="member_name" value="<cfif isdefined("attributes.member_name")><cfoutput>#attributes.member_name#</cfoutput></cfif>" readonly style="width:170px;">
					</cfif>
				</td>
                <td><cf_get_lang_main no='1631.Çıkış Depo'>*</td>
				<td>
					<input type="hidden" name="branch_id" id="branch_id" value="<cfif isdefined("attributes.branch_id")><cfoutput>#attributes.branch_id#</cfoutput></cfif>">
					<input type="hidden" name="department_id" id="department_id" value="<cfif isdefined("attributes.department_id")><cfoutput>#attributes.department_id#</cfoutput></cfif>">
					<input type="hidden" name="location_id" id="location_id" value="<cfif isdefined("attributes.location_id")><cfoutput>#attributes.location_id#</cfoutput></cfif>">
					<cfsavecontent variable="message"><cfoutput>#getLang('stock',296)#</cfoutput> !</cfsavecontent>
					<cfif isdefined("attributes.department_name")>
						<cfinput type="text" name="department_name" id="department_name" value="#attributes.department_name#" passthrough="readonly=yes" message="#message#" style="width:170px;">
					<cfelse>
						<cfinput type="text" name="department_name" id="department_name" value="" passthrough="readonly=yes" message="#message#" style="width:170px;">
					</cfif>
					<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_stores_locations&form_name=add_packet_ship&field_name=department_name&field_id=department_id&field_location_id=location_id&branch_id=branch_id','list')" ><img src="/images/plus_thin.gif" border="0" align="absbottom"></a>
				</td>
				
			</tr>
			<tr>
				<td><cf_get_lang_main no='1703.Sevk Yöntemi'> *</td>
				<td>
					<input type="hidden" name="ship_method_id" id="ship_method_id" value="<cfif isdefined("attributes.ship_method_id")><cfoutput>#attributes.ship_method_id#</cfoutput><cfelseif isdefined('get_ship_method')><cfoutput>#get_ship_method.ship_method_id#</cfoutput></cfif>">
					<input type="text" name="ship_method_name" id="ship_method_name" value="<cfif isdefined("attributes.ship_method_name")><cfoutput>#attributes.ship_method_name#</cfoutput><cfelseif isdefined('get_ship_method')><cfoutput>#get_ship_method.ship_method#</cfoutput></cfif>" readonly style="width:170px;">
					<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_ship_methods&field_name=add_packet_ship.ship_method_name&field_id=add_packet_ship.ship_method_id','medium');"><img src="/images/plus_thin.gif" align="absbottom" border="0"></a>
				</td>
				<td><cfoutput>#getLang('stock',286)#</cfoutput></td>
				<td>
					<cfsavecontent variable="message"><cfoutput>#getLang('stock',287)#</cfoutput> !</cfsavecontent>
					<cfinput type="text" name="action_date" id="action_date" value="#dateformat(get_shippng_plan.OUT_DATE,'dd/mm/yyyy')#" validate="eurodate" required="Yes" message="#message#" style="width:65px;">
					<cf_wrk_date_image date_field="action_date">
					<select name="start_h" id="start_h">
						<cfoutput>
							<cfloop from="0" to="23" index="i">
								<option value="#numberformat(i,00)#">#numberformat(i,00)#</option>
							</cfloop>
						</cfoutput>
					</select>
					<select name="start_m" id="start_m">
						<cfoutput>
							<cfloop from="0" to="59" index="i">
								<option value="#numberformat(i,00)#">#numberformat(i,00)#</option>
							</cfloop>
						</cfoutput>
					</select>
				</td>
			</tr>
			<tr>
				<td rowspan="2" valign="top"><cf_get_lang_main no='217.Açıklama'></td>
				<td rowspan="2" valign="top"><textarea name="note" id="note" style="width:170px;height:45px;"><cfoutput>#get_shippng_plan.NOTE#</cfoutput></textarea></td>
				<td><cf_get_lang_main no='233.Teslim Tarih'></td>
				<td>
					<cfsavecontent variable="message"><cfoutput>#getLang('stock',470)#</cfoutput>!</cfsavecontent>
					<cfinput type="text" name="deliver_date" id="deliver_date" value="#dateformat(get_shippng_plan.DELIVERY_DATE,'dd/mm/yyyy')#" validate="eurodate" style="width:65px;" message="#message#">
					<cf_wrk_date_image date_field="deliver_date">
					<select name="deliver_h" id="deliver_h">
						<cfoutput>
							<cfloop from="0" to="23" index="i">
								<option value="#numberformat(i,00)#">#numberformat(i,00)#</option>
							</cfloop>
						</cfoutput>
					</select>
					<select name="deliver_m" id="deliver_m">
						<cfoutput>
							<cfloop from="0" to="59" index="i">
								<option value="#numberformat(i,00)#">#numberformat(i,00)#</option>
							</cfloop>
						</cfoutput>
					</select>
				</td>
			</tr>
			<tr>
				<cfquery name="getHazirlama" datasource="#dsn2#">
					SELECT COUNT(*) AS CVC FROM (
SELECT * FROM #dsn#_#YEAR(NOW())#_#session.ep.company_id#.STOCK_FIS WHERE REF_NO='#get_shippng_plan.DELIVER_PAPER_NO#'
UNION ALL
SELECT * FROM #dsn#_#(year(now())-1)#_#session.ep.company_id#.STOCK_FIS WHERE REF_NO='#get_shippng_plan.DELIVER_PAPER_NO#'
)CC
				</cfquery>
				<td><cfoutput>#getLang('main',1349)# #getLang('stock',606)#</cfoutput></td>
				<td>
					<input type="hidden" name="deliver_id2" id="deliver_id2" value="<cfoutput>#get_shippng_plan.DELIVER_EMP#</cfoutput>">
					<input type="text" name="deliver_name2" id="deliver_name2" value="<cfoutput>#get_emp_info(get_shippng_plan.DELIVER_EMP,0,0)#</cfoutput>" readonly style="width:170px;">
					<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id2=add_packet_ship.deliver_id2&field_name=add_packet_ship.deliver_name2&select_list=1','list');"> <img src="/images/plus_thin.gif" border="0" align="absbottom"></a>
				</td>
			</tr>
            <tr>
            <td colspan="4">
				<!-----getHazirlama.CVC---->
				<cfif  0 eq 0>
				<cf_workcube_buttons is_upd='1' delete_page_url='#request.self#?fuseaction=sales.emptypopup_del_ezgi_shipping&ship_result_id=#attributes.iid#&type=2'>

				</cfif>
				</td>
            </tr>
		</table>
       	
		<cf_form_list>
			<thead>
				<tr> 
                	<th style="width:25px"><cf_get_lang_main no='1165.Sıra'></th>
                	<th style="width:80px"><cf_get_lang_main no='799.Sipariş No'></th>
                	<th style="width:100px"><cf_get_lang_main no='106.Stok Kodu'></th>
					<th style="width:250px"><cf_get_lang_main no='245.Ürün'></th>
					<!---<th style="width:60px"><cf_get_lang_main no='377.Özel Kod'></th>--->
                    <th style="width:200px"><cf_get_lang_main no='217.Açıklama'></th>
					<th style="width:80px"><cf_get_lang_main no='235.Spec'></th>
					<th style="text-align:right; width:60px"><cf_get_lang_main no='199.Sipariş'></th>
                    <th style="text-align:center; width:15px">&nbsp;</th>
				</tr>
			</thead>
			<tbody id="table2">
            	<cfset irs_top=0>
            	<cfif get_order_det.recordcount>
                    <cfoutput query="get_order_det">
                        <cfset stock_id=get_order_det.STOCK_ID>
                        <tr>
                        	<td style="text-align:right">#currentrow#</td>
                        	<td>
                            	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.list_order&event=upd&order_id=#get_order_det.order_id#','longpage');" class="tableyazi" title="<cf_get_lang_main no='3532.Satış Siparişine Git'>">
                            	#get_order_det.ORDER_NUMBER#
                                </a>
                           	</td>
                        	<td>#get_order_det.STOCK_CODE#</td>
                            <td>#get_order_det.PRODUCT_NAME#</td>
                            <!---<td>#get_order_det.STOCK_CODE_2#</td>--->
                            <td>#get_order_det.PRODUCT_NAME2#</td>
                            <td>
								<cfif len(SPECT_VAR_ID)>
									<a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=objects.popup_upd_spect&id=#SPECT_VAR_ID#&stock_id=#stock_id#','list');" class="tableyazi">#spect_main_id#-#spect_var_id#</a>	
								</cfif>
                            </td>
                            <td style="text-align:right;">#AmountFormat(ORDER_ROW_AMOUNT)#</td>
                            <td style="text-align:center;">
								 <!-----getHazirlama.CVC---->
								<cfif 0 eq 0>
                            	<cfif (isdefined('attributes.order_id') and attributes.order_id eq get_order_det.order_id) or not isdefined('attributes.order_id')>
									<cfif order_row_currency eq -8 or order_row_currency eq -9 or order_row_currency eq -10 or order_row_currency eq -3>
                                        <img src="/images/b_ok.gif" border="0" title="<cf_get_lang_main no='3570.İşlem Yapılamaz'>" />
                                    <cfelseif order_row_currency eq -6>
                                        <a href="javascript://" onClick="sil(1,#SHIP_RESULT_ROW_ID#,#SHIP_RESULT_ID#);"><img src="/images/delete_list.gif" align="absmiddle" border="0" title="<cf_get_lang_main no='1187.Dikkat'> !!! <cf_get_lang_main no='3538.Sevk Emri Verildi.'>"></a>
                                    <cfelse>
                                        <a href="javascript://" onClick="sil(1,#SHIP_RESULT_ROW_ID#,#SHIP_RESULT_ID#);"><img src="/images/delete_list.gif" align="absmiddle" border="0" title="<cf_get_lang_main no='51.Sil'>"></a>
                                    </cfif>
                              	<cfelse>
                                	<img src="/images/warning.gif" border="0" title="<cf_get_lang_main no='3572.Başka Siparişe Ait Sevk Planı Satırı'>" />
                                </cfif>
							</cfif>
                            </td>
                        </tr>
                    </cfoutput>
				</cfif>
            </tbody>
		</cf_form_list>
		
	</cfform>  
</cf_popup_box>      
<script type="text/javascript">
	function sil(type,ship_result_row_id,ship_result_id)
	{
		sor = confirm("<cf_get_lang_main no='3571.Silmek İstediğiniz Satır Kalıcı Olarak Silinecektir'>!");
		if(sor == true)
			window.location ='<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_del_ezgi_shipping&ship_result_row_id='+ship_result_row_id+'&ship_result_id='+ship_result_id+'&type='+type;
			else
				return false;
	}
</script>