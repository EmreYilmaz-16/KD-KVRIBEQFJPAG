<cfquery name="GET_ORDER" datasource="#DSN3#">
	SELECT 
		ORDERS.ORDER_NUMBER,
		ORDERS.ORDER_DATE,
		ORDERS.SHIP_METHOD,
		ORDERS.SHIP_ADDRESS,
		ORDERS.COMPANY_ID,
		ORDERS.PARTNER_ID,
		ORDERS.CONSUMER_ID,
        ORDERS.DELIVER_DEPT_ID, 
        ORDERS.LOCATION_ID, 
        ORDERS.REF_NO,
        ORDERS.ORDER_DETAIL,
        ORDERS.RESERVED,
		COMPANY_CREDIT.SHIP_METHOD_ID SHIP_METHOD_ID
  	FROM
		ORDERS
	        LEFT JOIN #dsn_alias#.COMPANY_CREDIT COMPANY_CREDIT ON ORDERS.COMPANY_ID = COMPANY_CREDIT.COMPANY_ID AND COMPANY_CREDIT.OUR_COMPANY_ID = #session.ep.company_id#
	WHERE
		ORDERS.ORDER_ID = #attributes.order_id#
</cfquery>
<cfif not GET_ORDER.RESERVED>
	<script type="text/javascript">
		alert("<cf_get_lang_main no='3565.Sipariş Rezerve Değildir. Sevk Planı Yapmak İçin Stok Rezerve Et Seçili Olmalıdır.!'>");
		window.close()
	</script>
    <cfabort>
</cfif>
<cfif not GET_ORDER.DELIVER_DEPT_ID>
	<script type="text/javascript">
		alert("<cf_get_lang_main no='782.Zorunlu Alan'> : <cf_get_lang_main no='1631.Çıkış Depo'>");
		window.close()
	</script>
    <cfabort>
</cfif>
<cfif len(get_order.ship_method) or len(get_order.ship_method_id)>
	<cfquery name="GET_SHIP_METHOD" datasource="#DSN#">
		SELECT 
        	SHIP_METHOD,SHIP_METHOD_ID 
      	FROM 
        	SHIP_METHOD 
        WHERE 
        	SHIP_METHOD_ID =
				<cfif len(get_order.ship_method)>
                	#get_order.ship_method#
              	<cfelse>
                	#get_order.SHIP_METHOD_ID#
              	</cfif> 
	</cfquery>
</cfif>
<cfquery name="get_service_cat" datasource="#dsn3#">
	SELECT SERVICECAT_ID, SERVICECAT FROM SERVICE_APPCAT ORDER BY SERVICECAT
</cfquery>
<cfquery name="get_shippng_plan" datasource="#dsn3#">
	SELECT     
    	ESR.SHIP_RESULT_ID, 
    	ESR.DELIVER_EMP, 
        ESR.NOTE, 
        ESR.DELIVER_PAPER_NO, 
        ESR.REFERENCE_NO, 
        ESR.OUT_DATE, 
        SM.SHIP_METHOD
	FROM         
    	EZGI_SHIP_RESULT AS ESR INNER JOIN
    	#dsn_alias#.SHIP_METHOD AS SM ON ESR.SHIP_METHOD_TYPE = SM.SHIP_METHOD_ID
	WHERE     
    	ESR.SHIP_RESULT_ID IN
                          	(
                           	SELECT     
                            	SHIP_RESULT_ID
                            FROM          
                            	EZGI_SHIP_RESULT_ROW
                            WHERE      
                            	ORDER_ID = #attributes.order_id#
                           	)
</cfquery>
<cfif GET_ORDER.recordcount>
	<cfparam name="attributes.reference_no" default="#GET_ORDER.REF_NO#">
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
        	DEPARTMENT.DEPARTMENT_ID = #GET_ORDER.DELIVER_DEPT_ID# AND 
            STOCKS_LOCATION.LOCATION_ID = #GET_ORDER.LOCATION_ID#    
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
            ORD.SALES_ADD_OPTION_ID,
            ORD.ORDER_STAGE,
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
            ) AS SPECT_MAIN_ID
            
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
	<cfquery name="get_ship_det" datasource="#DSN3#">
		SELECT   
        	ORR.ORDER_ROW_ID,      
        	S.SERVICE_NO, 
            S.SERVICE_ID
		FROM            
        	SERVICE AS S INNER JOIN
        	ORDER_ROW AS ORR ON S.EZGI_ORDER_ROW_ID = ORR.ORDER_ROW_ID
		WHERE        
        	ORR.ORDER_ID = #attributes.order_id#
	</cfquery>
	<cfoutput query="get_ship_det">
    	<cfset 'SERVICE_NO_#ORDER_ROW_ID#' = SERVICE_NO>
        <cfset 'SERVICE_ID_#ORDER_ROW_ID#' = SERVICE_ID>
    </cfoutput>
</cfif>
<cf_popup_box title="<cfoutput>#getLang('main',3513)#</cfoutput>">
	<cfform name="add_ssh" id="add_ssh" method="post" action="#request.self#?fuseaction=sales.emptypopup_add_ezgi_serve&order_id=#url.order_id#">
		<table>
            <cfinput type="hidden" name="order_row_id_list" value="#order_row_id_list#">
			<input type="hidden" name="order_comp" id="order_comp" value="<cfoutput>#get_par_info(get_order.company_id,1,0,0)#</cfoutput>">
			<input type="hidden" name="order_cons" id="order_cons" value="<cfoutput>#get_cons_info(get_order.consumer_id,1,0,0)#</cfoutput>">
			<input type="hidden" name="order_number" id="order_number" value="<cfoutput>#get_order.order_number#</cfoutput>">
			<cfif len(get_order.ship_address)>
				<input type="hidden" name="order_adress" id="order_adress" value="<cfoutput>#get_order.ship_address#</cfoutput>">
			<cfelse>
				<input type="hidden" name="order_adress" id="order_adress" value="">
			</cfif>
			<cfif len(get_order.ship_method)>
				<input type="hidden" name="order_type" id="order_type" value="<cfoutput>#get_ship_method.ship_method#</cfoutput>">
			<cfelse>
				<input type="hidden" name="order_type" id="order_type" value="">
			</cfif>
			<input type="hidden" name="order_date" id="order_date" value="<cfoutput>#dateformat(get_order.order_date,'dd/mm/yyyy')#</cfoutput>">
			<tr>
				<td width="120"><cf_get_lang_main no='1447.Süreç'>*</td>
				<td width="230"><cf_workcube_process is_upd='0' process_cat_width='170' is_detail='0'></td>
                <td><cfoutput>#getLang('report',742)#</cfoutput> *</td>
                <td>
               		<select name="service_cat" id="service_cat" style="width:170px; height:20px">
                    	<option value=""><cf_get_lang_main no='322.Seçiniz'></option>
						<cfoutput query="get_service_cat">
								<option value="#SERVICECAT_ID#">#SERVICECAT#</option>
						</cfoutput>
					</select>
                </td>
			</tr>
			<tr>
				<td><cf_get_lang_main no='107.Cari Hesap'> *</td>
				<td>
					<cfif len(attributes.order_id)>
						<input type="hidden" name="consumer_id" id="consumer_id" value="<cfoutput>#get_order.consumer_id#</cfoutput>">
						<input type="hidden" name="company_id" id="company_id" value="<cfoutput>#get_order.company_id#</cfoutput>">
						<input type="hidden" name="partner_id" id="partner_id" value="<cfoutput>#get_order.partner_id#</cfoutput>">
						<input type="text" name="company" id="company" value="<cfoutput>#get_par_info(get_order.company_id,1,0,0)#</cfoutput>" readonly style="width:170px;">
					<cfelse>
						<input type="hidden" name="consumer_id" id="consumer_id" value="<cfif isdefined("attributes.consumer_id")><cfoutput>#attributes.consumer_id#</cfoutput></cfif>">
						<input type="hidden" name="company_id" id="company_id" value="<cfif isdefined("attributes.company_id")><cfoutput>#attributes.company_id#</cfoutput></cfif>">
						<input type="hidden" name="partner_id" id="partner_id" value="<cfif isdefined("attributes.partner_id")><cfoutput>#attributes.partner_id#</cfoutput></cfif>">
						<input type="text" name="company" id="company" value="<cfif isdefined("attributes.company")><cfoutput>#attributes.company#</cfoutput></cfif>" readonly style="width:170px;">
					</cfif>
					<cfset str_linke_ait="&field_comp_id=add_ssh.company_id&field_partner=add_ssh.partner_id&field_consumer=add_ssh.consumer_id&field_comp_name=add_ssh.company&field_name=add_ssh.member_name&ship_method_id=add_ssh.ship_method_id&ship_method_name=add_ssh.ship_method_name&field_trans_comp_id=add_ssh.transport_comp_id&field_trans_comp_name=add_ssh.transport_comp_name&field_trans_deliver_id=add_ssh.transport_deliver_id&field_trans_deliver_name=add_ssh.transport_deliver_name">
					<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_all_pars<cfoutput>#str_linke_ait#</cfoutput>&select_list=7,8','list');">
					<img src="/images/plus_thin.gif"  align="absbottom" border="0"></a>
				</td>
                <td><cf_get_lang_main no='1382.Referans No'></td>
				<td><input type="text" name="reference_no" id="reference_no" readonly="readonly" value="<cfoutput>#attributes.reference_no#</cfoutput>" maxlength="25" style="width:100px;"></td>
				
			</tr>
			<tr>
				<td><cf_get_lang_main no='166.Yetkili'> *</td>
				<td>
					<cfif len(attributes.order_id)>
						<input type="text" name="member_name" id="member_name" value="<cfoutput>#get_par_info(get_order.partner_id,0,-1,0)#</cfoutput>" readonly style="width:170px;">
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
					<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_stores_locations&form_name=add_ssh&field_name=department_name&field_id=department_id&field_location_id=location_id&branch_id=branch_id','list')" ><img src="/images/plus_thin.gif" border="0" align="absbottom"></a>
				</td>
				
			</tr>
			<tr>
				<td><cf_get_lang_main no='1703.Sevk Yöntemi'> </td>
				<td>
					<input type="hidden" name="ship_method_id" id="ship_method_id" value="<cfif isdefined("attributes.ship_method_id")><cfoutput>#attributes.ship_method_id#</cfoutput><cfelseif isdefined('get_ship_method')><cfoutput>#get_ship_method.ship_method_id#</cfoutput></cfif>">
					<input type="text" name="ship_method_name" id="ship_method_name" value="<cfif isdefined("attributes.ship_method_name")><cfoutput>#attributes.ship_method_name#</cfoutput><cfelseif isdefined('get_ship_method')><cfoutput>#get_ship_method.ship_method#</cfoutput></cfif>" readonly style="width:170px;">
					<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_ship_methods&field_name=add_ssh.ship_method_name&field_id=add_ssh.ship_method_id','medium');"><img src="/images/plus_thin.gif" align="absbottom" border="0"></a>
				</td>
				<td><cfoutput>#getLang('call',102)#</cfoutput></td>
				<td>
					<cfsavecontent variable="message"><cfoutput>#getLang('call',102)#</cfoutput> !</cfsavecontent>
					<cfinput type="text" name="action_date" id="action_date" value="#dateformat(GET_ORDER.ORDER_DATE,'dd/mm/yyyy')#" validate="eurodate" required="Yes" message="#message#" style="width:65px;">
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
				<td rowspan="2" valign="top"><textarea name="note" id="note" style="width:170px;height:45px;"><cfoutput>#get_order.ORDER_DETAIL#</cfoutput></textarea></td>
				<td><cfoutput>#getLang('main',487)#</cfoutput></td>
				<td>
					<input type="hidden" name="deliver_id2" id="deliver_id2" value="<cfoutput>#session.ep.userid#</cfoutput>">
					<input type="text" name="deliver_name2" id="deliver_name2" value="<cfoutput>#get_emp_info(session.ep.userid,0,0)#</cfoutput>" readonly style="width:170px;">
					<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id2=add_ssh.deliver_id2&field_name=add_ssh.deliver_name2&select_list=1','list');"> <img src="/images/plus_thin.gif" border="0" align="absbottom"></a>
				</td>
			</tr>
			
		</table>
		<cf_form_list>
			<thead>
				<tr> 
                	<th style="width:100px"><cf_get_lang_main no='106.Stok Kodu'></th>
					<th style="width:350px"><cf_get_lang_main no='245.Ürün'></th>
					<th style="width:90px"><cfoutput>#getLang('objects',636)#</cfoutput></th>
					<th style="width:80px"><cf_get_lang_main no='235.Spec'></th>
					<th style="text-align:right; width:60px"><cf_get_lang_main no='199.Sipariş'></th>
					<th width="70"style="text-align:right;"><cfoutput>#getLang('service',256)#</cfoutput></th>
					<th style="text-align:right; width:50px"><cf_get_lang_main no='1032.Kalan'></th>
                    <th style="text-align:center; width:15px">&nbsp;
                    	<input type="checkbox" name="all_conv_product" id="all_conv_product" onClick="javascript: wrk_select_all2('all_conv_product','_conversion_product_',<cfoutput>#get_order_det.recordcount#</cfoutput>);">
                   </th>
				</tr>
			</thead>
			<tbody id="table2">
            	<cfset irs_top=0>
            	<cfif get_order_det.recordcount>
                    <cfoutput query="get_order_det">
                        <cfset stock_id=get_order_det.STOCK_ID>
                        <tr>
                        	<td>#get_order_det.STOCK_CODE#</td>
                            <td>#get_order_det.PRODUCT_NAME#</td>
                            <td>
                            	<cfif isdefined('SERVICE_ID_#ORDER_ROW_ID#')>
                                	<a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=service.list_service&event=upd&service_id=#Evaluate('SERVICE_ID_#ORDER_ROW_ID#')#&service_no=#Evaluate('SERVICE_NO_#ORDER_ROW_ID#')#','longpage');" class="tableyazi">
                                 		#Evaluate('SERVICE_NO_#ORDER_ROW_ID#')#
                                  	</a>
                                </cfif>
                            </td>
                            <td>
								<cfif len(SPECT_VAR_ID)>
									<a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=objects.popup_upd_spect&id=#SPECT_VAR_ID#&stock_id=#stock_id#','list');" class="tableyazi">#spect_main_id#-#spect_var_id#</a>	
								</cfif>
                            </td>
                            <td style="text-align:right;">#AmountFormat(get_order_det.QUANTITY)#</td>
                            <td style="text-align:right;">
                           		<cfif isdefined('SERVICE_ID_#ORDER_ROW_ID#')>
                                 	#AmountFormat(get_order_det.QUANTITY)#
                                <cfelse>
                                   -
                                </cfif>
                            </td>
                           	<td style="text-align:right;">
                                   	<cfset row_amount = get_order_det.QUANTITY>
                                	<input type="text" style="text-align:right; width:40px" readonly="readonly" name="row_amount_#ORDER_ROW_ID#" value="#amountformat(row_amount)#" />
                            </td>
                            
                            <td style="text-align:center;">
                            	<cfif not isdefined('SERVICE_ID_#ORDER_ROW_ID#')>
                           			<input type="checkbox" name="select_order_row_#ORDER_ROW_ID#" value="1" id="_conversion_product_#currentrow#"
                                       		 checked="checked" readonly="readonly"
                                    >
                                <cfelse>
                                	<img src="/images/c_ok.gif" border="0" title="#getLang('service',256)#"
                              	</cfif>
                            </td>
                        </tr>
                    </cfoutput>
				</cfif>
            </tbody>
		</cf_form_list>
		<cf_popup_box_footer>
         	<cf_workcube_buttons is_upd='0' add_function='control()'>
		</cf_popup_box_footer>
	</cfform>  
</cf_popup_box>      
<script type="text/javascript">
	
	function wrk_select_all2(all_conv_product,_conversion_product_,number)
	{
		for(var cl_ind=1; cl_ind <= number; cl_ind++)
		{
			if(document.getElementById(all_conv_product).checked == true)
			{
				if(document.getElementById('_conversion_product_'+cl_ind).checked == false)
					document.getElementById('_conversion_product_'+cl_ind).checked = true;
			}
			else
			{
				if(document.getElementById('_conversion_product_'+cl_ind).checked == true)
					document.getElementById('_conversion_product_'+cl_ind).checked = false;
			}
		}
	}
	function control()
	{
		
		if (document.getElementById("company_id").value == "" && document.getElementById("consumer_id").value == "")
		{
			alert("<cf_get_lang_main no='1553.Önce Cari Hesap Seçiniz'>");
			return false;
		}	

		if(document.getElementById("service_cat").value == "")	
		{
			alert("<cfoutput>#getLang('settings',1407)#</cfoutput>!");
			document.getElementById('department_name').focus();
			return false;
		}
		if(document.getElementById("department_name").value == "")	
		{
			alert("<cf_get_lang_main no='782.Zorunlu Alan'> : <cf_get_lang_main no='1631.Çıkış Depo'>!");
			document.getElementById('department_name').focus();
			return false;
		}
		<cfoutput query="get_order_det">
			sira = #currentrow#;
			if (document.getElementById('_conversion_product_'+sira).checked == false)
			{
				alert("<cfoutput>#getLang('invoice',39)#</cfoutput>!");
				return false;
			}
		</cfoutput>
	}
	function connectAjax(crtrow,ship_result_id)
	{
		var load_url_ = '<cfoutput>#request.self#?fuseaction=sales.emptypopup_ajax_ezgi_shipping_detail</cfoutput>&ship_result_id='+ship_result_id;
		AjaxPageLoad(load_url_,'DISPLAY_ORDER_STOCK_INFO'+crtrow,1);
	}
</script>