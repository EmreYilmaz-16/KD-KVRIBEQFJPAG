<cfset my_url_action = 'purchase.list_order'>
<cfif attributes.active_company neq session.ep.company_id>
	<script type="text/javascript">
		alert("<cf_get_lang no ='213.İşlemin Şirketi İle Aktif Şirketiniz Farklı Çalıştığınız Şirketi Kontrol Ediniz'>!");
		window.location.href='<cfoutput>#request.self#?fuseaction=#my_url_action#</cfoutput>';
	</script>
	<cfabort>
</cfif>
<cfif not isdefined("attributes.rows_") or attributes.rows_ lte 0>
	<script type="text/javascript">
		alert("<cf_get_lang_main no ='313.Ürün Seçmediniz Lütfen Ürün Seçiniz'>!");
		window.location.href='<cfoutput>#cgi.referer#</cfoutput>';
	</script>
	<cfabort>
</cfif>

<cf_date tarih = "attributes.basket_due_value_date_">
<cf_date tarih = "attributes.order_date">
<!--- irsaliye tarihine gore ortalama vade tarihi --->
<cfif isdefined('attributes.basket_due_value_date_')>
	<cfset order_due_date = attributes.basket_due_value_date_>
<cfelse>
	<cfset order_due_date = ''>
</cfif>
<cfif not isdefined("new_dsn3_group_pur")><cfset new_dsn3_group_pur = dsn3></cfif>
<cfif not isdefined("is_from_import") and not isdefined("add_relation_rows")><!--- İmportta fonksiyonlar kendi sayfasında çağrılıyor --->
	<cfinclude template="/v16/objects/functions/add_relation_rows.cfm"><!--- sip,irs,fat satırlarının birbiri ile ilişkileri.. --->
</cfif>
<cfif isdefined("attributes.deliverdate") and isdate(attributes.deliverdate)>
	<cf_date tarih = "attributes.deliverdate">
</cfif>
<cfif isdefined("attributes.publishdate") and isdate(attributes.publishdate)>
	<cf_date tarih = "attributes.publishdate">
</cfif>
<cfif isdefined('attributes.process_cat') and len(attributes.process_cat)>
	<cfscript>
		attributes.currency_multiplier = '';
		paper_currency_multiplier ='';
		if(isDefined('attributes.kur_say') and len(attributes.kur_say))
			for(mon=1;mon lte attributes.kur_say;mon=mon+1)
			{
				if(evaluate("attributes.hidden_rd_money_#mon#") is session.ep.money2)
					attributes.currency_multiplier = evaluate('attributes.txt_rate2_#mon#/attributes.txt_rate1_#mon#');
				if(evaluate("attributes.hidden_rd_money_#mon#") is form.basket_money)
					paper_currency_multiplier = evaluate('attributes.txt_rate2_#mon#/attributes.txt_rate1_#mon#');
			}
	</cfscript>
	<cfquery name="get_type" datasource="#dsn3#">
		SELECT PROCESS_TYPE,PROCESS_CAT_ID,ACTION_FILE_NAME,ACTION_FILE_FROM_TEMPLATE,IS_BUDGET_RESERVED_CONTROL FROM SETUP_PROCESS_CAT WHERE PROCESS_CAT_ID = #attributes.process_cat#
	</cfquery>
</cfif>
<cfset wrk_id = dateformat(now(),'YYYYMMDD')&timeformat(now(),'HHmmss')&'_#session.ep.userid#_'&round(rand()*100)>
<cflock name="#CreateUUID()#" timeout="20">
<cftransaction>
	<cfif not (isdefined("attributes.order_number") and len(attributes.order_number))>
		<cfquery name="get_order_code" datasource="#new_dsn3_group_pur#">
			SELECT ORDER_NO, ORDER_NUMBER FROM GENERAL_PAPERS WHERE PAPER_TYPE = 1 AND ZONE_TYPE = 0
		</cfquery>
		<cfset paper_code = evaluate('get_order_code.ORDER_NO')>
		<cfset paper_number = evaluate('get_order_code.ORDER_NUMBER') +1>
		<cfset paper_full = '#paper_code#-#paper_number#'>
		<cfquery name="UPD_OFFER_CODE" datasource="#new_dsn3_group_pur#">
			UPDATE 
				GENERAL_PAPERS 
			SET 
				ORDER_NUMBER = ORDER_NUMBER+1
			WHERE 
				PAPER_TYPE = 1 
				AND ZONE_TYPE = 0
		</cfquery>
	<cfelse>
		<cfset paper_full = attributes.order_number>
	</cfif>
	<!--- ORDER_CURRENCY 1 DURUMUNDA BASLIYOR --->
	<cfquery name="INS_ORDER" datasource="#new_dsn3_group_pur#" result="my_result">
		INSERT INTO 
			ORDERS 
			(
			WRK_ID,
			ORDER_STATUS,
			ORDER_STAGE,
			ORDER_DATE,
			ORDER_NUMBER,
			PURCHASE_SALES,
			COMPANY_ID,
			PARTNER_ID,
			CONSUMER_ID,
			STARTDATE,
			DELIVERDATE,
			PRIORITY_ID,								   
			OFFER_ID,
			PAYMETHOD,
			ORDER_HEAD,
			ORDER_DETAIL,
			NETTOTAL,
			DELIVER_DEPT_ID,
			LOCATION_ID,
			SHIP_ADDRESS,
			SHIP_ADDRESS_ID,
			CITY_ID,
			COUNTY_ID,
			INVISIBLE,
			PUBLISHDATE,
		<cfif isdefined('attributes.basket_money')>
			OTHER_MONEY,
			OTHER_MONEY_VALUE,
		</cfif>
		<cfif isdefined('attributes.tax')>			
			TAX,
		</cfif>
			INCLUDED_KDV,
			RESERVED,
			SHIP_METHOD,
			PROJECT_ID,
			CATALOG_ID,
			TAXTOTAL,
			DISCOUNTTOTAL,
			GROSSTOTAL,
			ORDER_EMPLOYEE_ID,
			DUE_DATE,
			REF_NO,
			CARD_PAYMETHOD_ID,
			CARD_PAYMETHOD_RATE,
			WORK_ID,
            IS_FOREIGN,
			RECORD_DATE,
			RECORD_EMP,
			RECORD_IP,
			CONTRACT_ID,
			PROCESS_CAT,
			SA_DISCOUNT
			)
		VALUES  
			(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#wrk_id#">,
			<cfif isDefined("attributes.order_status")>1<cfelse>0</cfif>,
			#attributes.process_stage#,
			#attributes.order_date#,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#paper_full#">,
			0,
		<cfif Len(attributes.COMPANY_ID)>#attributes.COMPANY_ID#<cfelse>NULL</cfif>,
		<cfif len(attributes.PARTNER_ID)>#attributes.PARTNER_ID#<cfelse>NULL</cfif>,
		<cfif len(attributes.CONSUMER_ID)>#attributes.CONSUMER_ID#<cfelse>NULL</cfif>,
			#now()#,
		<cfif len(attributes.deliverdate)>
			#attributes.deliverdate#,
		<cfelse>
			NULL,
		</cfif>
			<cfif isdefined("attributes.PRIORITY_ID") and len(attributes.PRIORITY_ID)>#attributes.PRIORITY_ID#,<cfelse>1,</cfif>
			<cfif isdefined("attributes.offer_id") and len(attributes.offer_id)>#attributes.offer_id#<cfelse>NULL</cfif>,
		<cfif isdefined("attributes.paymethod_id") and len(attributes.paymethod_id) and len(attributes.pay_method)>
			#attributes.paymethod_id#,
		<cfelse>
			NULL,
		</cfif>
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.ORDER_HEAD#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.ORDER_DETAIL#">,
		<cfif isdefined("attributes.basket_net_total")>
			#attributes.basket_net_total#,
		<cfelse>
			0,
		</cfif>
		<cfif isdefined("attributes.deliver_dept_id") and len(attributes.deliver_dept_id) and len(attributes.deliver_dept_name)>
			#attributes.deliver_dept_id#,
		<cfelse>
			NULL,
		</cfif>
		<cfif isdefined("attributes.deliver_loc_id") and len(attributes.deliver_loc_id) and len(attributes.deliver_dept_name)>
			#attributes.deliver_loc_id#,
		<cfelse>
			NULL,
		</cfif>
		<cfif isdefined("attributes.ship_address") and len(attributes.ship_address)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.ship_address#"><cfelse>NULL</cfif>,
		<cfif isDefined("attributes.ship_address_id") and len(attributes.ship_address_id)>#attributes.ship_address_id#<cfelse>NULL</cfif>,
		<cfif isdefined("attributes.ship_address_city_id") and len(attributes.ship_address_city_id)>#attributes.ship_address_city_id#<cfelse>NULL</cfif>,
		<cfif isdefined("attributes.ship_address_county_id") and len(attributes.ship_address_county_id)>#attributes.ship_address_county_id#<cfelse>NULL</cfif>,
		<cfif isDefined("attributes.INVISIBLE")>
			1,
		<cfelse>
			0,
		</cfif>
		<cfif len(attributes.publishdate)>
			#attributes.publishdate#,
		<cfelse>
			NULL,
		</cfif>
		<cfif isdefined('attributes.basket_money')>
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.basket_money#">,
			#((attributes.basket_net_total*attributes.basket_rate1)/attributes.basket_rate2)#,
		</cfif>
		<cfif isdefined('attributes.tax')>
			#attributes.tax#,
		</cfif>
		<cfif isDefined("INCLUDED_KDV")>
			1,
		<cfelse>
			0,
		</cfif>
		<cfif isDefined('attributes.RESERVED')>1<cfelse>0</cfif>,
		<cfif len(attributes.ship_method_id)>#attributes.ship_method_id#<cfelse>NULL</cfif>,			
		<cfif isdefined("attributes.project_id") and len(attributes.project_id) and len(attributes.project_head)>
			#attributes.project_id#,
		<cfelse>
			NULL,
		</cfif>
		<cfif isdefined("attributes.catalog_id") and len(attributes.catalog_id) and len(attributes.catalog_name)>
			#attributes.catalog_id#,
		<cfelse>
			NULL,
		</cfif>
			#attributes.basket_tax_total#,
			#attributes.basket_discount_total#,
			#attributes.basket_gross_total#,
		<cfif isdefined("attributes.order_employee_id") and len(attributes.order_employee_id)>#attributes.order_employee_id#<cfelse>NULL</cfif>, 
		<cfif isdefined("order_due_date") and len(order_due_date)>#order_due_date#<cfelse>NULL</cfif>,
		<cfif isdefined("attributes.ref_no") and len(attributes.ref_no)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.ref_no#"><cfelse>NULL</cfif>,
		<cfif isdefined("attributes.card_paymethod_id") and len(attributes.card_paymethod_id)>
			#attributes.card_paymethod_id#,
			<cfif isdefined("attributes.commission_rate") and len(attributes.commission_rate)>
				#attributes.commission_rate#,
			<cfelse>
				NULL,
			</cfif>
		<cfelse>
			NULL,
			NULL,
		</cfif>
		<cfif isdefined("attributes.work_id") and len(trim(attributes.work_id))>#attributes.work_id#<cfelse>NULL</cfif>,
        <cfif isdefined("attributes.is_foreign")>1<cfelse>0</cfif>,
			#now()#,
			#session.ep.userid#,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#CGI.REMOTE_ADDR#">,
			<cfif (isdefined('attributes.contract_no') and len(attributes.contract_no)) and isdefined('attributes.contract_id') and len(attributes.contract_id)>#attributes.contract_id#<cfelse>NULL</cfif>,
			<cfif isdefined("attributes.PROCESS_CAT") and len(attributes.PROCESS_CAT)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.PROCESS_CAT#"><cfelse>NULL</cfif>,	
			<cfif isdefined("attributes.genel_indirim") and len(attributes.genel_indirim)>#attributes.genel_indirim#<cfelse>NULL</cfif>
			)
		</cfquery>

		<cfquery name="GET_ORDER" datasource="#new_dsn3_group_pur#">
			SELECT MAX(ORDER_ID) AS ORDER_ID FROM ORDERS WHERE WRK_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#wrk_id#">
		</cfquery>

		<cfif (isdefined('attributes.contract_no') and len(attributes.contract_no)) and isdefined('attributes.contract_id') and len(attributes.contract_id)>
			<cfquery name="get_contracts" datasource="#new_dsn3_group_pur#">
				SELECT ORDER_ID FROM RELATED_CONTRACT WHERE CONTRACT_ID = #attributes.contract_id#
			</cfquery>
			<cfset new_related_id	= '#get_contracts.ORDER_ID##GET_ORDER.ORDER_ID#,' />
			<cfquery datasource="#new_dsn3_group_pur#">
				UPDATE RELATED_CONTRACT SET ORDER_ID = '#new_related_id#' WHERE CONTRACT_ID = #attributes.contract_id#
			</cfquery>
		</cfif>

		<cfif attributes.rows_ neq 0>
			<cfloop from="1" to="#attributes.rows_#" index="i">
				<cf_date tarih="attributes.deliver_date#i#">
				<cf_date tarih="attributes.reserve_date#i#">
				<cfif session.ep.our_company_info.spect_type and isdefined('attributes.is_production#i#') and evaluate('attributes.is_production#i#') eq 1 and not (isdefined('attributes.spect_id#i#') and len(evaluate('attributes.spect_id#i#')))>
					<cfset dsn_type=new_dsn3_group_pur>
                    <cfinclude template="../../objects/query/add_basket_spec.cfm">
				</cfif>
				<cfquery name="ADD_ORDER_ROW_" datasource="#new_dsn3_group_pur#">
					INSERT INTO 
						ORDER_ROW 	 
						(
						ORDER_ID,
						ROW_INTERNALDEMAND_ID,
						RELATED_INTERNALDEMAND_ROW_ID,
						ROW_PRO_MATERIAL_ID,
						STOCK_ID,
						PRODUCT_ID,
						PRODUCT_NAME,
						QUANTITY,
					<cfif isdefined('attributes.price#i#') and  len(evaluate('attributes.price#i#'))>
						PRICE,
					</cfif>
						TAX,
						UNIT,
						UNIT_ID,
						DELIVER_DATE,
						DELIVER_DEPT,
						DELIVER_LOCATION,
						DISCOUNT_1,
						DISCOUNT_2,
						DISCOUNT_3,
						DISCOUNT_4,
						DISCOUNT_5,						
						DISCOUNT_6,
						DISCOUNT_7,
						DISCOUNT_8,
						DISCOUNT_9,
						DISCOUNT_10,						
						OTHER_MONEY,
						OTHER_MONEY_VALUE,
					<cfif isdefined('attributes.spect_id#i#') and len(evaluate('attributes.spect_id#i#'))>
						SPECT_VAR_ID,
						SPECT_VAR_NAME,
					</cfif>
						LOT_NO,
						PRICE_OTHER,
						NETTOTAL,
						IS_PROMOTION,
						DISCOUNT_COST,
						ORDER_ROW_CURRENCY,
						RESERVE_TYPE,
						RESERVE_DATE,
						EXTRA_COST,
						UNIQUE_RELATION_ID,
						PROM_RELATION_ID,
						PRODUCT_NAME2,
						AMOUNT2,
						UNIT2,
						EXTRA_PRICE,
						EK_TUTAR_PRICE,<!--- iscilik birim ücreti --->
						EXTRA_PRICE_TOTAL,
						EXTRA_PRICE_OTHER_TOTAL,
						SHELF_NUMBER,
						PRODUCT_MANUFACT_CODE,
						BASKET_EXTRA_INFO_ID,
						SELECT_INFO_EXTRA,
                    	DETAIL_INFO_EXTRA,
						BASKET_EMPLOYEE_ID,
						LIST_PRICE,
						PRICE_CAT,
						CATALOG_ID,
						NUMBER_OF_INSTALLMENT,
						DUEDATE,
						KARMA_PRODUCT_ID,
						OTV_ORAN,
						OTVTOTAL,
                        WRK_ROW_ID,
                        WRK_ROW_RELATION_ID,
                        RELATED_ACTION_ID,
                        RELATED_ACTION_TABLE,
						WIDTH_VALUE,
						DEPTH_VALUE,
						HEIGHT_VALUE,
						ROW_PROJECT_ID,
                        ROW_WORK_ID,
						DESCRIPTION
						<cfif isdefined("attributes.gtip_number#i#") and len(evaluate("attributes.gtip_number#i#"))>,GTIP_NUMBER</cfif>
						<cfif isdefined('attributes.row_exp_center_id#i#') and len(evaluate("attributes.row_exp_center_id#i#")) and isdefined('attributes.row_exp_center_name#i#') and len(evaluate("attributes.row_exp_center_name#i#"))>,EXPENSE_CENTER_ID</cfif>
						<cfif isdefined('attributes.row_exp_item_id#i#') and len(evaluate("attributes.row_exp_item_id#i#")) and isdefined('attributes.row_exp_item_name#i#') and len(evaluate("attributes.row_exp_item_name#i#"))>,EXPENSE_ITEM_ID</cfif>
						<cfif isdefined('attributes.row_activity_id#i#') and len(evaluate("attributes.row_activity_id#i#"))>,ACTIVITY_TYPE_ID</cfif>
						<cfif isdefined('attributes.row_acc_code#i#') and len(evaluate("attributes.row_acc_code#i#"))>,ACC_CODE</cfif>
						<cfif isdefined('attributes.row_bsmv_rate#i#') and len(evaluate("attributes.row_bsmv_rate#i#"))>,BSMV_RATE</cfif>
						<cfif isdefined('attributes.row_bsmv_amount#i#') and len(evaluate("attributes.row_bsmv_amount#i#"))>,BSMV_AMOUNT</cfif>
						<cfif isdefined('attributes.row_bsmv_currency#i#') and len(evaluate("attributes.row_bsmv_currency#i#"))>,BSMV_CURRENCY</cfif>
						<cfif isdefined('attributes.row_oiv_rate#i#') and len(evaluate("attributes.row_oiv_rate#i#"))>,OIV_RATE</cfif>
						<cfif isdefined('attributes.row_oiv_amount#i#') and len(evaluate("attributes.row_oiv_amount#i#"))>,OIV_AMOUNT</cfif>
						<cfif isdefined('attributes.row_tevkifat_rate#i#') and len(evaluate("attributes.row_tevkifat_rate#i#"))>,TEVKIFAT_RATE</cfif>
						<cfif isdefined('attributes.row_tevkifat_amount#i#') and len(evaluate("attributes.row_tevkifat_amount#i#"))>,TEVKIFAT_AMOUNT</cfif>
						)
					VALUES 
						(
						#GET_ORDER.ORDER_ID#,
						<cfif isdefined('attributes.internaldemand_id_list') and len(attributes.internaldemand_id_list) and isdefined("attributes.row_ship_id#i#") and len(evaluate('attributes.row_ship_id#i#')) and listfirst(evaluate('attributes.row_ship_id#i#'),';') neq 0>#listfirst(evaluate('attributes.row_ship_id#i#'),';')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.internaldemand_id_list') and len(attributes.internaldemand_id_list) and isdefined("attributes.row_ship_id#i#") and listlen(evaluate('attributes.row_ship_id#i#'),";") eq 2 and len(listgetat(evaluate('attributes.row_ship_id#i#'),2,';'))>#listgetat(evaluate('attributes.row_ship_id#i#'),2,';')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.pro_material_id_list') and len(attributes.pro_material_id_list) and isdefined("attributes.row_ship_id#i#") and len(evaluate('attributes.row_ship_id#i#')) and listfirst(evaluate('attributes.row_ship_id#i#'),';') neq 0>#listfirst(evaluate('attributes.row_ship_id#i#'),';')#<cfelse>NULL</cfif>,
							#evaluate("attributes.stock_id#i#")#,
							#evaluate("attributes.product_id#i#")#,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.product_name#i#')#">,
							#evaluate("attributes.amount#i#")#,
						<cfif isdefined('attributes.price#i#') and len(evaluate('attributes.price#i#'))>
							#evaluate('attributes.price#i#')#,
						</cfif>
							#evaluate("attributes.tax#i#")#,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.unit#i#')#">,
							#evaluate("attributes.unit_id#i#")#,
						<cfif isdefined("x_apply_deliverdate_to_rows") and x_apply_deliverdate_to_rows eq 1 and not (isdefined("attributes.deliver_date#i#") and len(evaluate('attributes.deliver_date#i#')))>
							<cfif len(attributes.deliverdate)>#attributes.deliverdate#<cfelse>NULL</cfif>,
                        <cfelse>                    
							<cfif isdefined("attributes.deliver_date#i#") and isdate(evaluate('attributes.deliver_date#i#'))>#evaluate('attributes.deliver_date#i#')#<cfelse>NULL</cfif>,
                        </cfif>                            
						<cfif isdefined("attributes.deliver_dept#i#") and len(trim(evaluate("attributes.deliver_dept#i#"))) and len(listfirst(evaluate("attributes.deliver_dept#i#"),"-"))>
							#listfirst(evaluate("attributes.deliver_dept#i#"),"-")#,
						<cfelseif len(attributes.deliver_dept_id)>
							#attributes.deliver_dept_id#,						
						<cfelse>
							NULL,
						</cfif>
						<cfif isdefined("attributes.deliver_dept#i#") and listlen(trim(evaluate("attributes.deliver_dept#i#")),"-") eq 2 and len(listlast(evaluate("attributes.deliver_dept#i#"),"-"))>
							#listlast(evaluate("attributes.deliver_dept#i#"),"-")#,
						<cfelseif len(attributes.deliver_loc_id)>
							#attributes.deliver_loc_id#,
						<cfelse>
							NULL,
						</cfif>
						<cfif isdefined('attributes.indirim1#i#')>#evaluate('attributes.indirim1#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.indirim2#i#')>#evaluate('attributes.indirim2#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.indirim3#i#')>#evaluate('attributes.indirim3#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.indirim4#i#')>#evaluate('attributes.indirim4#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.indirim5#i#')>#evaluate('attributes.indirim5#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.indirim6#i#')>#evaluate('attributes.indirim6#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.indirim7#i#')>#evaluate('attributes.indirim7#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.indirim8#i#')>#evaluate('attributes.indirim8#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.indirim9#i#')>#evaluate('attributes.indirim9#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.indirim10#i#')>#evaluate('attributes.indirim10#i#')#<cfelse>NULL</cfif>,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.other_money_#i#')#">,
						<cfif isdefined("attributes.other_money_value_#i#") and  len(evaluate("attributes.other_money_value_#i#"))>#evaluate("attributes.other_money_value_#i#")#<cfelse>1</cfif>,
						<cfif isdefined('attributes.spect_id#i#') and len(evaluate('attributes.spect_id#i#'))>
							#evaluate('attributes.spect_id#i#')#,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#left(evaluate('attributes.spect_name#i#'),500)#">,
						</cfif>
						<cfif isdefined('attributes.lot_no#i#') and len(evaluate('attributes.lot_no#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.lot_no#i#')#"><cfelse>NULL</cfif>,
						<cfif isdefined('attributes.price_other#i#') and len(evaluate('attributes.price_other#i#'))>#evaluate("attributes.price_other#i#")#<cfelse>NULL</cfif>,
						<cfif isdefined("attributes.row_nettotal#i#") and len(evaluate("attributes.row_nettotal#i#"))>#evaluate("attributes.row_nettotal#i#")#<cfelse>NULL</cfif>,
							0,
						<cfif isdefined('attributes.iskonto_tutar#i#') and len(evaluate('attributes.iskonto_tutar#i#'))>#evaluate('attributes.iskonto_tutar#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined("attributes.order_currency#i#") and len(evaluate("attributes.order_currency#i#"))>#evaluate("attributes.order_currency#i#")#<cfelse>-1</cfif>,
						<cfif isdefined("attributes.reserve_type#i#") and len(evaluate("attributes.reserve_type#i#")) and isdefined("attributes.order_currency#i#") and len(evaluate("attributes.order_currency#i#")) and evaluate("attributes.order_currency#i#") eq -9>-3<cfelseif isdefined("attributes.reserve_type#i#") and len(evaluate("attributes.reserve_type#i#"))>#evaluate("attributes.reserve_type#i#")#<cfelse>-1</cfif>,
						<cfif isdefined("attributes.reserve_date#i#") and len(evaluate("attributes.reserve_date#i#"))>#evaluate("attributes.reserve_date#i#")#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.extra_cost#i#') and len(evaluate('attributes.extra_cost#i#'))>#evaluate('attributes.extra_cost#i#')#<cfelse>0</cfif>,
						<cfif isdefined('attributes.row_unique_relation_id#i#') and len(evaluate('attributes.row_unique_relation_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.row_unique_relation_id#i#')#"><cfelse>NULL</cfif>,
						<cfif isdefined('attributes.prom_relation_id#i#') and len(evaluate('attributes.prom_relation_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.prom_relation_id#i#')#"><cfelse>NULL</cfif>,
						<cfif isdefined('attributes.product_name_other#i#') and len(evaluate('attributes.product_name_other#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.product_name_other#i#')#"><cfelse>NULL</cfif>,
						<cfif isdefined('attributes.amount_other#i#') and len(evaluate('attributes.amount_other#i#'))>#evaluate('attributes.amount_other#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.unit_other#i#') and len(evaluate('attributes.unit_other#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.unit_other#i#')#"><cfelse>NULL</cfif>,
						<cfif isdefined('attributes.ek_tutar#i#') and len(evaluate('attributes.ek_tutar#i#'))>#evaluate('attributes.ek_tutar#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.ek_tutar_price#i#') and len(evaluate('attributes.ek_tutar_price#i#'))>#evaluate('attributes.ek_tutar_price#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.ek_tutar_total#i#') and len(evaluate('attributes.ek_tutar_total#i#'))>#evaluate('attributes.ek_tutar_total#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.ek_tutar_other_total#i#') and len(evaluate('attributes.ek_tutar_other_total#i#'))>#evaluate('attributes.ek_tutar_other_total#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.shelf_number#i#') and len(evaluate('attributes.shelf_number#i#'))>#evaluate('attributes.shelf_number#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.manufact_code#i#') and len(evaluate('attributes.manufact_code#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.manufact_code#i#')#"><cfelse>NULL</cfif>,
						<cfif isdefined('attributes.basket_extra_info#i#') and len(evaluate('attributes.basket_extra_info#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.basket_extra_info#i#')#"><cfelse>NULL</cfif>,
						<cfif isdefined('attributes.select_info_extra#i#') and len(evaluate('attributes.select_info_extra#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.select_info_extra#i#')#"><cfelse>NULL</cfif>,
						<cfif isdefined('attributes.detail_info_extra#i#') and len(evaluate('attributes.detail_info_extra#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.detail_info_extra#i#')#"><cfelse>NULL</cfif>,
						<cfif isdefined('attributes.basket_employee_id#i#') and len(evaluate('attributes.basket_employee_id#i#')) and isdefined('attributes.basket_employee#i#') and len(evaluate('attributes.basket_employee#i#'))>#evaluate('attributes.basket_employee_id#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.list_price#i#') and len(evaluate('attributes.list_price#i#'))>#evaluate('attributes.list_price#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.price_cat#i#') and len(evaluate('attributes.price_cat#i#'))>#evaluate('attributes.price_cat#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.row_catalog_id#i#') and len(evaluate('attributes.row_catalog_id#i#'))>#evaluate('attributes.row_catalog_id#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.number_of_installment#i#') and len(evaluate('attributes.number_of_installment#i#'))>#evaluate('attributes.number_of_installment#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined("attributes.duedate#i#") and len(evaluate("attributes.duedate#i#"))>#evaluate("attributes.duedate#i#")#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.karma_product_id#i#') and len(evaluate('attributes.karma_product_id#i#'))>#evaluate('attributes.karma_product_id#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.otv_oran#i#') and len(evaluate('attributes.otv_oran#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.otv_oran#i#')#"><cfelse>NULL</cfif>,
						<cfif isdefined('attributes.row_otvtotal#i#') and len(evaluate('attributes.row_otvtotal#i#'))>#evaluate('attributes.row_otvtotal#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.wrk_row_id#i#') and len(evaluate('attributes.wrk_row_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.wrk_row_id#i#')#"><cfelse>NULL</cfif>,
						<cfif isdefined('attributes.wrk_row_relation_id#i#') and len(evaluate('attributes.wrk_row_relation_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.wrk_row_relation_id#i#')#"><cfelse>NULL</cfif>,
						<cfif isdefined('attributes.related_action_id#i#') and len(evaluate('attributes.related_action_id#i#'))>#evaluate('attributes.related_action_id#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.related_action_table#i#') and len(evaluate('attributes.related_action_table#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.related_action_table#i#')#"><cfelse>NULL</cfif>,
						<cfif isdefined('attributes.row_width#i#') and len(evaluate('attributes.row_width#i#'))>#evaluate('attributes.row_width#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.row_depth#i#') and len(evaluate('attributes.row_depth#i#'))>#evaluate('attributes.row_depth#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.row_height#i#') and len(evaluate('attributes.row_height#i#'))>#evaluate('attributes.row_height#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.row_project_id#i#') and len(evaluate('attributes.row_project_id#i#')) and isdefined('attributes.row_project_name#i#') and len(evaluate('attributes.row_project_name#i#'))>#evaluate('attributes.row_project_id#i#')#<cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.row_work_id#i#') and len(evaluate('attributes.row_work_id#i#')) and isdefined('attributes.row_work_name#i#') and len(evaluate('attributes.row_work_name#i#'))>#evaluate('attributes.row_work_id#i#')#<cfelse>NULL</cfif>,
						<cfif isdefined('attributes.description#i#') and len(evaluate('attributes.description#i#'))>'#evaluate('attributes.description#i#')#'<cfelse>NULL</cfif> 
						<cfif isdefined("attributes.gtip_number#i#") and len(evaluate("attributes.gtip_number#i#"))>,<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.gtip_number#i#')#"></cfif>
						<cfif isdefined('attributes.row_exp_center_id#i#') and len(evaluate("attributes.row_exp_center_id#i#")) and isdefined('attributes.row_exp_center_name#i#') and len(evaluate("attributes.row_exp_center_name#i#"))>,<cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.row_exp_center_id#i#')#"></cfif>
						<cfif isdefined('attributes.row_exp_item_id#i#') and len(evaluate("attributes.row_exp_item_id#i#")) and isdefined('attributes.row_exp_item_name#i#') and len(evaluate("attributes.row_exp_item_name#i#"))>,<cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.row_exp_item_id#i#')#"></cfif>
						<cfif isdefined('attributes.row_activity_id#i#') and len(evaluate("attributes.row_activity_id#i#"))>,<cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.row_activity_id#i#')#"></cfif>
						<cfif isdefined('attributes.row_acc_code#i#') and len(evaluate("attributes.row_acc_code#i#"))>,<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#evaluate('attributes.row_acc_code#i#')#"></cfif>
						<cfif isdefined('attributes.row_bsmv_rate#i#') and len(evaluate("attributes.row_bsmv_rate#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_bsmv_rate#i#')#"></cfif>
						<cfif isdefined('attributes.row_bsmv_amount#i#') and len(evaluate("attributes.row_bsmv_amount#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_bsmv_amount#i#')#"></cfif>
						<cfif isdefined('attributes.row_bsmv_currency#i#') and len(evaluate("attributes.row_bsmv_currency#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_bsmv_currency#i#')#"></cfif>
						<cfif isdefined('attributes.row_oiv_rate#i#') and len(evaluate("attributes.row_oiv_rate#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_oiv_rate#i#')#"></cfif>
						<cfif isdefined('attributes.row_oiv_amount#i#') and len(evaluate("attributes.row_oiv_amount#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_oiv_amount#i#')#"></cfif>
						<cfif isdefined('attributes.row_tevkifat_rate#i#') and len(evaluate("attributes.row_tevkifat_rate#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_tevkifat_rate#i#')#"></cfif>
						<cfif isdefined('attributes.row_tevkifat_amount#i#') and len(evaluate("attributes.row_tevkifat_amount#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_tevkifat_amount#i#')#"></cfif>
						)
				</cfquery>

			<cfquery name="get_max_order_row" datasource="#new_dsn3_group_pur#">
				SELECT MAX(ORDER_ROW_ID) AS ORDER_ROW_ID FROM ORDER_ROW
			</cfquery>
			<cfif isdefined('attributes.related_action_id#i#') and Evaluate('attributes.related_action_id#i#') gt 0 and isdefined('attributes.wrk_row_relation_id#i#') and Evaluate('attributes.wrk_row_relation_id#i#') gt 0>
                <cfscript>
					add_relation_rows(
						action_type:'add',
						action_dsn : '#new_dsn3_group_pur#',
						to_table:'ORDERS',
						from_table:'#evaluate("attributes.RELATED_ACTION_TABLE#i#")#',
						to_wrk_row_id : Evaluate("attributes.wrk_row_id#i#"),
						from_wrk_row_id :Evaluate("attributes.wrk_row_relation_id#i#"),
						amount : Evaluate("attributes.amount#i#"),
						to_action_id : GET_ORDER.ORDER_ID,
						from_action_id :Evaluate("attributes.related_action_id#i#")
						);
				</cfscript>
            </cfif>
			<cfset attributes.ROW_MAIN_ID = get_max_order_row.ORDER_ROW_ID>
			<cfset row_id = i>
			<cfset ACTION_TYPE_ID = 2>
			<cfset attributes.product_id = evaluate("attributes.product_id#i#")>
			<cfinclude template="add_assortment_textile_js.cfm">
			<cfinclude template="add_department_information.cfm">
			<!--- //  urun asortileri --->			

				<!--- bütçe rezerve kontrolü --->
				<cfif isdefined('attributes.process_cat') and len(attributes.process_cat) and isdefined("get_type.IS_BUDGET_RESERVED_CONTROL") and get_type.IS_BUDGET_RESERVED_CONTROL eq 1>
					<cfif isdefined('attributes.other_money_value_#i#') and len(evaluate("attributes.other_money_value_#i#"))>
						<cfset other_money_val = evaluate('attributes.other_money_value_#i#')>
					<cfelse>
						<cfset other_money_val = ''>
					</cfif>
					<cfif isdefined('attributes.other_money_#i#') and len(evaluate("attributes.other_money_#i#"))>
						<cfset other_money = evaluate('attributes.other_money_#i#')>
					<cfelse>
						<cfset other_money = ''>
					</cfif>
					<cfscript>
						butceci(
						action_id : GET_ORDER.ORDER_ID,
						muhasebe_db : dsn3,
						is_income_expense : true,
						process_type : get_type.process_type,
						product_tax: evaluate("attributes.tax#i#"),//kdv
						stock_id: evaluate("attributes.stock_id#i#"),
						product_id: evaluate("attributes.product_id#i#"),
						nettotal : wrk_round(evaluate("attributes.row_nettotal#i#")),
						other_money_value : other_money_val,
						action_currency : other_money,
						currency_multiplier : attributes.currency_multiplier,
						expense_date : attributes.order_date,
						expense_center_id : iif((isdefined("attributes.row_exp_center_id#i#") and len(evaluate('attributes.row_exp_center_id#i#'))),evaluate("attributes.row_exp_center_id#i#"),0),
						expense_item_id : iif((isdefined("attributes.row_exp_item_id#i#") and len(evaluate('attributes.row_exp_item_id#i#'))),evaluate("attributes.row_exp_item_id#i#"),0),
						detail : "#paper_full# #getLang('','Nolu Sipariş',64677)#",
						paper_no : '#paper_full#',
						branch_id : ListGetAt(session.ep.user_location,2,"-"),
						discounttotal: iif((isdefined("attributes.genel_indirim") and len('attributes.genel_indirim')),"#attributes.genel_indirim#",0),
						reserv_type :1, //expense_reserved_rows tablosuna gelir olarak yazılsın.
						project_id: iif(isdefined("attributes.project_id") and len(attributes.project_id), "attributes.project_id", DE('')),
						activity_type : evaluate("attributes.row_activity_id#i#"),
						invoice_row_id:attributes.ROW_MAIN_ID
						);
					</cfscript>
				</cfif>
			
			</cfloop>	
		</cfif>
		<!--- referans satıs siparisiyle kaydedilen siparis arasındaki baglantı  PAPER_RELATION'da tutuluyor--->
		<cfif isdefined('attributes.ref_paper_id') and len(attributes.ref_paper_id)>
			<cfquery name="ADD_PAPER_RELATION" datasource="#new_dsn3_group_pur#">
				INSERT INTO
				#dsn_alias#.PAPER_RELATION
					(
					PAPER_ID,
					PAPER_TABLE,
					PAPER_TYPE_ID,
					RELATED_PAPER_ID,
					RELATED_PAPER_TABLE,
					RELATED_PAPER_TYPE_ID,
					COMP_ID,
					PERIOD_ID
					)
				VALUES
					(
					#GET_ORDER.ORDER_ID#,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="ORDERS">,
					1,
					<cfif isdefined('attributes.pro_material_id') and len(attributes.pro_material_id)>
					#attributes.pro_material_id#,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="PRO_MATERIAL">,
					2,
					<cfelse>
					#attributes.ref_paper_id#,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="ORDERS">,
					1,
					</cfif>
					#session.ep.company_id#,
					#session.ep.period_id#
					)
			</cfquery>
		</cfif>
	<cfscript>
		basket_kur_ekle(action_id:GET_ORDER.ORDER_ID,table_type_id:3,process_type:0,basket_money_db:new_dsn3_group_pur);
		/*if(not isdefined("is_from_import") or not isdefined("add_reserve_row"))//importdan geliyorsa fonksiyon tanımlanmasın
			include('add_order_row_reserved_stock.cfm','\V16/objects\functions'); //rezerve edilen satırlar icin ORDER_ROW_RESERVED'a kayıt atıyor.*/
		add_reserve_row(
			reserve_order_id:GET_ORDER.ORDER_ID,
			reserve_action_type:0,
			is_order_process:0,
			is_purchase_sales:0,
			process_db : new_dsn3_group_pur,
			process_db_alias : "#new_dsn3_group_pur#."
			);
		if(isdefined('attributes.internaldemand_id_list') and len(attributes.internaldemand_id_list)) //siparis ic talepten olusturulacaksa
		{
			/*
			if(not isdefined("is_from_import") or not isdefined("add_internaldemand_row_relation"))//importdan geliyorsa fonksiyon tanımlanmasın
				include('add_internaldemand_relation.cfm','\V16/objects\functions'); */
			add_internaldemand_row_relation(
				to_related_action_id:GET_ORDER.ORDER_ID,
				to_related_action_type:0,
				action_status:0
				);
		}
		if(isdefined('attributes.pro_material_id_list') and len(attributes.pro_material_id_list)) //proje malzeme planı ile baglantısı olusturuluyor
		{/*
			if(not isdefined("is_from_import") or not isdefined("add_paper_relation"))//importdan geliyorsa fonksiyon tanımlanmasın
				include('add_paper_relation.cfm','\V16/objects\functions'); */
			add_paper_relation(
				to_paper_id :GET_ORDER.ORDER_ID,
				to_paper_table : 'ORDERS',
				to_paper_type :1,
				from_paper_table : 'PRO_MATERIAL',
				from_paper_type :2,
				relation_type : 1,
				action_status:0
				);
		}
	</cfscript>
	<cfset last_order_id_pur = GET_ORDER.ORDER_ID>
    <cfif not isdefined("first_order_id_pur")>
		<cfset first_order_id_pur = GET_ORDER.ORDER_ID>
    </cfif>
    <!---Ek Bilgiler--->
    <cfset attributes.info_id = my_result.IDENTITYCOL>
    <cfset attributes.is_upd = 0>
    <cfset attributes.info_type_id = -12>
    <cfinclude template="../../objects/query/add_info_plus2.cfm">
    <!---Ek Bilgiler--->
	<cf_workcube_process 
		is_upd='1' 
		data_source='#new_dsn3_group_pur#' 
		old_process_line='0'
		process_stage='#attributes.process_stage#' 
		record_member='#session.ep.userid#' 
		record_date='#now()#' 
		action_table='ORDERS'
		action_column='ORDER_ID'
		action_id='#GET_ORDER.ORDER_ID#'
		action_page='#request.self#?fuseaction=purchase.list_order&event=upd&order_id=#GET_ORDER.ORDER_ID#' 
		warning_description='#getLang('','Sipariş',57611)# : #paper_full#'>

	<cfif isdefined("attributes.process_cat") and len(attributes.process_cat)>
		<cf_workcube_process_cat 
			process_cat="#attributes.process_cat#"
			action_id = "#GET_ORDER.ORDER_ID#"
			action_table="ORDER"
			action_column="ORDER_ID"
			is_action_file = 1
			action_page='#request.self#?fuseaction=purchase.list_order&event=upd&order_id=#GET_ORDER.ORDER_ID#'
			action_file_name='#get_type.action_file_name#'
			action_db_type = '#dsn3#'
			is_template_action_file = '#get_type.action_file_from_template#'>
	</cfif>	
	</cftransaction>
</cflock>
<cfif isdefined('xml_import_pur')><cfset last_xml_import_pur = xml_import_pur></cfif>
<cfif isdefined('is_from_import')><cfset last_xml_import_pur = is_from_import></cfif>
<cfif isdefined("last_order_id_pur") and not isdefined("last_xml_import_pur")>
	<cfscript>
		add_company_related_action(action_id:last_order_id_pur,action_type:2);
	</cfscript>
</cfif>
<cfif not isdefined("last_xml_import_pur")><!--- importtan gelmiyorsa--->
	<cfset return_adress = "#request.self#?fuseaction=purchase.list_order&event=upd&order_id=#first_order_id_pur#">
	<script type="text/javascript">
		window.location.href="<cfoutput>#return_adress#</cfoutput>";
	</script>
</cfif>
