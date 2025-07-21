<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_SHIPPING_DEFAULTS
</cfquery>
<cfquery name="get_emp_pda_defaults" datasource="#dsn#">
	SELECT * FROM EZGI_PDA_DEPARTMENT_DEFAULTS
</cfquery>
<cfquery name="get_departments" datasource="#dsn#">
	SELECT        
    	D.DEPARTMENT_STATUS, 
        S.LOCATION_ID, 
        S.DEPARTMENT_ID, 
        D.DEPARTMENT_HEAD + '-' + S.COMMENT AS DEPO, 
        S.DEPARTMENT_LOCATION
	FROM            
   		DEPARTMENT AS D INNER JOIN
      	STOCKS_LOCATION AS S ON D.DEPARTMENT_ID = S.DEPARTMENT_ID
	ORDER BY 
    	D.BRANCH_ID, 
        D.DEPARTMENT_HEAD
</cfquery>
<table class="dph">
    <tr>
        <td class="dpht">&nbsp;<cfoutput>#getLang('main',3618)#</cfoutput></td>
        <td class="dphb">
        	<cfoutput>
				
            </cfoutput>
            &nbsp;&nbsp;
        </td>
	</tr>
</table>
<cfform name="upd_e_shipping_setup" method="post" action="#request.self#?fuseaction=prod.emptypopup_setup_ezgi_shipping">
<table class="dpm" align="center">
    <tr>
    	<td valign="top" class="dpml">
            <cf_form_box>	
            	<table>
                	<tr height="25px" >
                     	<td width="200px" valign="top" style="font-weight:bold">E-Shipping Ambar Fişi Kontrolü</td>
                   		<td width="70px" valign="top" style="text-align:left">
                         	<input type="checkbox" name="ambar_control" value="1" <cfif get_defaults.SHIPPING_CONTROL_TYPE eq 1>checked</cfif>>
                     	</td>
                     	<td width="150px" style="font-weight:bold">PDA Kontrol Tipi</td>
                     	<td width="140px">
                         	<select name="pda_control_type" style="width:120px; height:20px">
                            	<option value="1" <cfif get_defaults.PDA_CONTROL_TYPE eq 1>selected</cfif>>Satır Bazında</option>
                                <option value="2" <cfif get_defaults.PDA_CONTROL_TYPE eq 2>selected</cfif>>Belge Bazında</option>
                            </select>
                     	</td>
                        <td width="150px" style="font-weight:bold"></td>
                     	<td width="140px">
                         	
                     	</td>
                  	</tr>
                	<tr height="25px"  id="design_name_">
                     	<td valign="top" style="font-weight:bold">Sevkiyat Kontrol Miktar Giriş</td>
                      	<td valign="top">
                        	<input type="checkbox" name="e_shipping_control" value="1" <cfif get_defaults.IS_AMOUNT_INPUT_FREE eq 1>checked</cfif>>
                      	</td>
                     	<td valign="top" style="font-weight:bold">Barkod Uzunluğu</td>
                      	<td valign="top">
                        	<cfinput type="text" name="ean" value="#get_defaults.EAN#" style="width:50px">
                    	</td>
                        <td valign="top" style="font-weight:bold"></td>
                      	<td valign="top"></td>
                        <td valign="top"></td>
                  	</tr>
               	</table>
              	<cf_form_box_footer>
                 	<cf_workcube_buttons 
                     	is_upd='1' 
                      	is_delete = '0' 
                       	add_function='kontrol()'>
            	</cf_form_box_footer>
          	</cf_form_box>
            <cf_seperator title="#getLang('settings',2554)#" id="thickness_" is_closed="0">
           	<div id="thickness_" style="width:100%">
                <cf_form_list id="table2">
                    <thead style="width:100%">
                        <tr height="20px">
                        	<th style="text-align:center; width:20px" >
                            	<input type="button" class="eklebuton" title="<cf_get_lang_main no='170.Ekle'>" onclick="add_row_emp();">
                                <input type="hidden" name="record_num_emp" id="record_num_emp" value="<cfoutput>#get_emp_pda_defaults.recordcount#</cfoutput>">
                            </th>
                            <th style="text-align:center; width:30px" ><cf_get_lang_main no='1165.Sıra'></th>
                            <th style="text-align:center; width:250px" >Çalışan Adı</th>
                            <th style="text-align:center; width:280px" >Default Ambar Lokasyonu</th>
                            <th style="text-align:center; width:290px" >Default Mal Kabul Lokasyonu</th>
                            <th style="text-align:center; width:290px" >Default Sevkiyat Lokasyonu</th>
                            <th style="text-align:center; width:70px" >Power User</th>
                    	</tr>
                	</thead>
                	<tbody name="new_row_emp" id="new_row_emp">
                    	<cfif get_emp_pda_defaults.recordcount>
                    		<cfoutput query="get_emp_pda_defaults">
                            	<cfset ambar_deposu = ListGetAt(DEFAULT_MK_TO_RF_DEP,2)>
                                <cfset ambar_lokasyonu = ListGetAt(DEFAULT_MK_TO_RF_LOC,2)>
                                <cfset sevkiyat_deposu = ListGetAt(DEFAULT_RF_TO_SV_DEP,2)>
                                <cfset sevkiyat_lokasyonu = ListGetAt(DEFAULT_RF_TO_SV_LOC,2)>
                                <cfset kabul_deposu = ListGetAt(DEFAULT_MK_TO_RF_DEP,1)>
                                <cfset kabul_lokasyonu = ListGetAt(DEFAULT_MK_TO_RF_LOC,1)>
                               	<tr name="frm_row_emp" id="frm_row_emp#currentrow#">
                                 	<td style="height:20px; text-align:center">
                                        <a style="cursor:pointer" onclick="sil_emp(#currentrow#);">
                                       	 	<img src="/images/delete_list.gif" alt="<cf_get_lang_main no='51.Sil'>">
                                       	</a>
                                     	<input type="hidden" name="row_kontrol_emp#currentrow#" id="row_kontrol_emp#currentrow#" value="1">
                                    </td>
                                    <td style="text-align:right">#currentrow#&nbsp;</td>
                                    <td style="text-align:left">
                                    	<input type="hidden" name="employee_id_#currentrow#" id="employee_id_#currentrow#" value="#get_emp_pda_defaults.EPLOYEE_ID#">
                                     	<input type="text" name="employee_#currentrow#" id="employee_#currentrow#" value="#get_emp_info(get_emp_pda_defaults.EPLOYEE_ID,0,0)# " style="width:235px;" onFocus="AutoComplete_Create('record_employee','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','record_employee_id','','3','125');" autocomplete="off">
                                      	<a style="cursor:pointer" href"javascript://" onClick="pencere_ac_emp(#currentrow#);">
                                        	<img src="/images/plus_thin.gif" align="absmiddle" border="0">
                                       	</a>
                                    </td>
                                    <td style="text-align:left">
										<select name="ambar_#currentrow#" style="width:280px; height:20px">
                                        	<option value="">Seçiniz</option>
                                            <cfloop query="get_departments">
                                            	<option value="#get_departments.DEPARTMENT_LOCATION#" <cfif ambar_deposu eq get_departments.DEPARTMENT_ID and ambar_lokasyonu eq get_departments.LOCATION_ID>selected</cfif>>#get_departments.depo#</option>
                                            </cfloop>
                                        </select>
                                    </td>
                                    <td style="text-align:left">
                                    	<select name="kabul_#currentrow#" style="width:280px; height:20px">
                                        	<option value="">Seçiniz</option>
                                            <cfloop query="get_departments">
                                            	<option value="#get_departments.DEPARTMENT_LOCATION#" <cfif kabul_deposu eq get_departments.DEPARTMENT_ID and kabul_lokasyonu eq get_departments.LOCATION_ID>selected</cfif>>#get_departments.depo#</option>
                                            </cfloop>
                                        </select>
                                    </td>
                                    <td style="text-align:left">
                                    	<select name="sevkiyat_#currentrow#" style="width:280px; height:20px">
                                        	<option value="">Seçiniz</option>
                                            <cfloop query="get_departments">
                                            	<option value="#get_departments.DEPARTMENT_LOCATION#" <cfif sevkiyat_deposu eq get_departments.DEPARTMENT_ID and sevkiyat_lokasyonu eq get_departments.LOCATION_ID>selected</cfif>>#get_departments.depo#</option>
                                            </cfloop>
                                        </select>
                                  	</td>
                                    <td style="text-align:center">
                                    	<input type="checkbox" name="power_user_#currentrow#" value="1" <cfif get_emp_pda_defaults.POWER_USER eq 1>checked</cfif>>
                                  	</td>
                              	</tr>
                         	</cfoutput>
                    	<cfelse>
                            <tr>
                                <td colspan="4">&nbsp; <cf_get_lang_main no='72.Kayıt Yok'></td>
                            </tr>
                        </cfif>
                 	</tbody>
           		</cf_form_list>
        	</div>
      	</td>
  	</tr>
</table>
</cfform>
<script type="text/javascript">
	var row_count_emp=document.upd_e_shipping_setup.record_num_emp.value;
	document.getElementById('default_name').focus();
	function kontrol()
	{
		if(document.getElementById("default_name").value == "")
		{
			alert("<cf_get_lang_main no='782.Girilmesi Zorunlu Alan'> <cf_get_lang_main no='2914.Renk Adı'> !");
			document.getElementById('default_name').focus();
			return false;
		}
	}
	function add_row_emp()
	{
		
		row_count_emp++;
		var newRow_emp;
		var newCell_emp;
		newRow_emp = document.getElementById("new_row_emp").insertRow(document.getElementById("new_row_emp").rows.length);
		newRow_emp.setAttribute("name","frm_row_emp" + row_count_emp);
		newRow_emp.setAttribute("id","frm_row_emp" + row_count_emp);
		newRow_emp.setAttribute("NAME","frm_row_emp" + row_count_emp);
		newRow_emp.setAttribute("ID","frm_row_emp" + row_count_emp);
		
		document.upd_e_shipping_setup.record_num_emp.value = row_count_emp;
		newCell_emp = newRow_emp.insertCell(newRow_emp.cells.length);
		newCell_emp.innerHTML = '<a style="cursor:pointer" onclick="sil_emp(' + row_count_emp + ');" ><img src="/images/delete_list.gif" alt="<cf_get_lang_main no='51.Sil'>" border="0"></a>';	
		
		document.upd_e_shipping_setup.record_num_emp.value = row_count_emp;
		newCell_emp = newRow_emp.insertCell(newRow_emp.cells.length);
		newCell_emp.innerHTML = row_count_emp;
		
		<!---newCell_emp=newRow_emp.insertCell(newRow_emp.cells.length);
		newCell_emp.setAttribute('nowrap','nowrap');
		newCell_emp.innerHTML = '<input type="hidden" name="employee_id_' + row_count_emp +'" id="employee_id_' + row_count_emp +'" value=""><input type="text" name="employee_' + row_count_emp +'" id="employee_' + row_count_emp +'" value="" style="width:235px;">
                                      	<a style="cursor:pointer" href"javascript://" onClick="pencere_ac_emp('+ row_count_emp +');"><img src="/images/plus_thin.gif" align="absmiddle" border="0"></a>'
		
		newCell_emp=newRow_emp.insertCell(newRow_emp.cells.length);
		newCell_emp.setAttribute('nowrap','nowrap');
		newCell_emp.innerHTML = '<input type="hidden" value="1" id="row_kontrol_emp' + row_count_emp +'" name="row_kontrol_emp' + row_count_emp +'"><input type="text" name="urun_emp' + row_count_emp +'" id="urun_emp'+ row_count_emp +'" style="width:195px;"><input type="hidden" name="pid_emp' + row_count_emp +'" id="pid_emp'+ row_count_emp +'"><input type="hidden" name="stock_id_emp' + row_count_emp +'" id="stock_id_emp' + row_count_emp +'"> <a style="cursor:pointer" href"javascript://" onClick="pencere_ac_emp('+ row_count_emp +');"><img src="/images/plus_thin.gif" align="absmiddle" border="0"></a>';
		
		newCell_emp=newRow_emp.insertCell(newRow_emp.cells.length);
		newCell_emp.innerHTML = '<input type="text" id="quantity_emp' + row_count_emp +'" name="quantity_emp' + row_count_emp +'" value="<cfoutput>#TlFormat(1,4)#</cfoutput>" style="width:50px; text-align:right;">';--->
	}
	function pencere_ac_emp(no_emp)
	{
		alert('AA');
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=employee_id_" + no_emp +"&field_name=employee_" + no_emp +"&select_list=1",'list','popup_list_positions');
	}

	function sil_emp(sy_emp)
	{
		
		var element_emp=eval("upd_e_shipping_setup.row_kontrol_emp"+sy_emp);
		element_emp.value=0;
		var element_emp=eval("frm_row_emp"+sy_emp);
		element_emp.style.display="none";		
	} 
</script>