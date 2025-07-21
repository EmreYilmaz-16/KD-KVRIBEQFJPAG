<cfset module_name="sales">
<cfquery name="get_department_name" datasource="#DSN#">
	SELECT 
		SL.LOCATION_ID,
		SL.COMMENT,
		D.DEPARTMENT_ID,
		D.DEPARTMENT_HEAD,
		D.BRANCH_ID
	FROM
		STOCKS_LOCATION SL,
		DEPARTMENT D
	WHERE 
		SL.DEPARTMENT_ID = D.DEPARTMENT_ID
		AND D.BRANCH_ID IN (SELECT BRANCH_ID FROM BRANCH WHERE COMPANY_ID = #session.ep.company_id#)
	ORDER BY
		D.DEPARTMENT_HEAD,
		SL.COMMENT
</cfquery>
<cfquery name="get_ship_row" datasource="#dsn2#">
	SELECT  
    	SIR.DISPATCH_SHIP_ID,   
    	SIR.PRODUCT_ID, 
        SIR.AMOUNT, 
        SIR.UNIT, 
        SIR.STOCK_ID, 
        SIR.NAME_PRODUCT, 
        SIR.SPECT_VAR_ID, 
        SIR.SPECT_VAR_NAME, 
        SIR.SHIP_ROW_ID, 
      	S.STOCK_CODE,
        (SELECT DELIVER_DATE FROM SHIP_INTERNAL WHERE DISPATCH_SHIP_ID = SIR.DISPATCH_SHIP_ID) AS DELIVER_DATE
	FROM         
    	SHIP_INTERNAL_ROW AS SIR INNER JOIN
     	#dsn3_alias#.STOCKS AS S ON SIR.STOCK_ID = S.STOCK_ID
	WHERE     
    	SIR.DISPATCH_SHIP_ID = #attributes.ship_id#     
</cfquery>
<cfquery name="get_ship" datasource="#dsn2#">
	SELECT        
    	SI.DELIVER_DATE, 
        SI.DEPARTMENT_OUT, 
        SI.LOCATION_OUT, 
        SI.DEPARTMENT_IN, 
        SI.LOCATION_IN, 
        SH.SHIP_ID, 
        SH.SHIP_NUMBER, 
        ISNULL(SH.IS_DELIVERED,0) AS IS_DELIVERED,
        (SELECT COMMENT FROM #dsn_alias#.STOCKS_LOCATION WHERE DEPARTMENT_ID = SI.DEPARTMENT_OUT AND LOCATION_ID = SI.LOCATION_OUT) AS COMMENT
	FROM            
    	SHIP_INTERNAL AS SI LEFT OUTER JOIN
  		SHIP AS SH ON SI.DISPATCH_SHIP_ID = SH.DISPATCH_SHIP_ID
	WHERE        
    	SI.DISPATCH_SHIP_ID = #attributes.ship_id#
</cfquery>
<cfset location_info_ = get_location_info(get_ship.department_out,get_ship.location_out)>
<cfset attributes.out_departments = '#get_ship.DEPARTMENT_OUT#-#get_ship.LOCATION_OUT#'>
<cfset attributes.in_departments = '#get_ship.DEPARTMENT_IN#-#get_ship.LOCATION_IN#'>
<table class="dph">
	<tr> 
		<td class="dpht"><cf_get_lang_main no='3557.Sevk Talebi Düzenleme'></td>
	</tr>
</table>
<cf_seperator id="iliskili_fatura" header="#getLang('myhome',1276)#">
<cfform name="orders" action="#request.self#?fuseaction=sales.emptypopup_upd_ezgi_ship_internal_deliverdate" method="post">
	<cfinput type="hidden" name="ship_id" value="#attributes.ship_id#">
    <table id="iliskili_fatura" width="100%">
        <tr height="35">
            <td style="text-align:left; width:205px">
            	<cf_get_lang_main no='233.Teslim Tarihi'> : 
                <cfinput type="text" name="delivery_date" id="delivery_date" value="#dateformat(get_ship_row.deliver_date,'dd/mm/yyyy')#" validate="eurodate" required="Yes" style="width:85px;"><cf_wrk_date_image date_field="delivery_date">
            </td>
            <td style="text-align:left; width:285px">
            	<cfoutput>#getLang('main',1631)#</cfoutput> :
            	<select name="out_departments" id="out_departments" style="width:180px;height:20px">
                	<option value=""><cfoutput>#getLang('main',2234)#</cfoutput></option>
                  	<cfoutput query="get_department_name">
                      	<option value="#department_id#-#location_id#" <cfif isdefined("attributes.out_departments") and attributes.out_departments is '#department_id#-#location_id#'>selected</cfif>>#department_head#-#comment#</option>
                	</cfoutput>
              	</select>
            </td>
            <td style="text-align:left; width:285px">
            	<cfoutput>#getLang('prod',193)#</cfoutput> :
            	<select name="in_departments" id="in_departments" style="width:180px;height:20px">
                	<option value=""><cfoutput>#getLang('main',2234)#</cfoutput></option>
                  	<cfoutput query="get_department_name">
                      	<option value="#department_id#-#location_id#" <cfif isdefined("attributes.in_departments") and attributes.in_departments is '#department_id#-#location_id#'>selected</cfif>>#department_head#-#comment#</option>
                	</cfoutput>
              	</select>
            </td>
            <cfif len(get_ship.SHIP_ID)>
                <td style="text-align:left; width:155px">
                    <cfoutput>#getLang('main',1790)#</cfoutput> : 
                  	<cfoutput>
                    	<a href="#request.self#?fuseaction=stock.add_ship_dispatch&event=upd&ship_id=#get_ship.SHIP_ID#" class="tableyazi">
							#get_ship.SHIP_NUMBER#
                      	</a>
                  	</cfoutput>
                </td>
                <td style="text-align:left; width:105px">
                	<cfoutput>#getLang('stock',439)#</cfoutput> : 
                    <cfif get_ship.IS_DELIVERED>
                    	<img src="images/production/true.png" border="0" style="height:15px; width:15px" />
                    <cfelse>
                    	<img src="images/production/false.png" border="0" style="height:15px; width:15px" />
                    </cfif>
                </td>
            <cfelse>
            	<td>
                	<cf_workcube_buttons is_upd='1' delete_page_url='#request.self#?fuseaction=stock.emptypopup_upd_dispatch_internaldemand&event=del&shipDel=1&upd_id=#attributes.ship_id#&head=#location_info_#'>
                </td>
            </cfif>
            <td></td>
        </tr>
        <tr>
            <td colspan="7">
                <cf_medium_list>
                    <thead>
                        <tr>
                            <th><cf_get_lang_main no='1165.Sıra'></th> 
                            <th><cf_get_lang_main no='106.Stok Kodu'></th>
                            <th><cf_get_lang_main no='245.Ürün'></th>
                            <th><cfoutput>#getLang('objects',1535)#</cfoutput></th>
                            <th width="50" style="text-align:right;"><cf_get_lang_main no='223.Miktar'></th>
                            <th width="15"></th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfif get_ship_row.recordcount>
                            <cfoutput query="get_ship_row">
                                <tr>
                                	<td>#currentrow#</td>
                                    <td>#STOCK_CODE#</td>
                                    <td>#NAME_PRODUCT#</td>
                                    <td>#SPECT_VAR_NAME#</td>
                                    <td style="text-align:right;">#TLFormat(amount,2)#</td>
                                    <td style="text-align:center;">
                                      	<a href="javascript://" onClick="sil(#DISPATCH_SHIP_ID#,#SHIP_ROW_ID#);"><img src="/images/delete_list.gif" align="absmiddle" border="0"></a>

                                    </td>
                                </tr>
                                
                            </cfoutput>
                        </cfif>
                    </tbody>
                    <tfoot>
                        
                    </tfoot>
                </cf_medium_list>
            </td>      
        </tr>
    </table>
</cfform>
<script language="javascript">
	function sil(ship_id,ship_row_id)
	{	
		sor = confirm('<cf_get_lang_main no='3556.Satırı Silmek İstediğinizden Emin misiniz?'>');
		if(sor == true)
			windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_del_ezgi_dispatch_row&ship_id='+ship_id+'&ship_row_id='+ship_row_id,'small');
		else
			return false;
	}
</script>	