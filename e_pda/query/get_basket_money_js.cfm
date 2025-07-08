<cffunction name="session_basket_kur_ekle">
	<!---
		by : 20031211
		notes : session da islemlere gore kur bilgisini gosterir.
		usage :
			process_type:1 upd 0 add
			invoice:1
			ship:2
			order:3
			offer:4
			servis:5
			stock_fis:6
			internmal_demand:7
			prroduct_catalog 8
			sale_quote:9
			subscription:13
		revisions : javascript version 20040209
	--->
	<cfargument name="action_id">
	<cfargument name="table_type_id">
	<cfargument name="to_table_type_id"> <!---belge baska bir belgeye cekiliyorsa (irsaliyenin faturaya cekilmesi gibi) bu parametre gonderilir.  --->
	<cfargument name="process_type" required="true">
	
	<cfif listfindnocase(employee_url,'#cgi.http_host#',';')>
		<cfset int_bsk_comp_id = SESSION.EP.COMPANY_ID>
		<cfset int_bsk_period_id = SESSION.EP.PERIOD_ID>
		<cfset str_money_bskt_func=SESSION.EP.MONEY>
		<cfset int_bsk_period_year=SESSION.EP.PERIOD_YEAR>
	<cfelseif listfindnocase(partner_url,'#cgi.http_host#',';')>
		<cfset int_bsk_comp_id = SESSION.PP.OUR_COMPANY_ID>
		<cfset int_bsk_period_id = SESSION.PP.PERIOD_ID>
		<cfset str_money_bskt_func=SESSION.PP.MONEY>
		<cfset int_bsk_period_year=SESSION.PP.PERIOD_YEAR>
	<cfelseif listfindnocase(server_url,'#cgi.http_host#',';')>
		<cfset int_bsk_comp_id = SESSION.WW.OUR_COMPANY_ID>
		<cfset int_bsk_period_id = SESSION.WW.PERIOD_ID>
		<cfset str_money_bskt_func=SESSION.WW.MONEY>
		<cfset int_bsk_period_year=SESSION.WW.PERIOD_YEAR>
	<cfelseif listfindnocase(pda_url,'#cgi.http_host#',';')>
		<cfset int_bsk_comp_id = SESSION.PDA.OUR_COMPANY_ID>
		<cfset int_bsk_period_id = SESSION.PDA.PERIOD_ID>
		<cfset str_money_bskt_func=SESSION.PDA.MONEY>
		<cfset int_bsk_period_year=SESSION.PDA.PERIOD_YEAR>
	</cfif>
	<cfquery name="get_standart_process_money" datasource="#dsn#">  <!--- muhasebe doneminden standart islem dövizini alıyor --->
		SELECT STANDART_PROCESS_MONEY FROM SETUP_PERIOD WHERE PERIOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#int_bsk_period_id#">
	</cfquery>
	<cfif arguments.process_type eq 1>
		<cfscript>
			switch (arguments.table_type_id)
			{
				case 1: fnc_table_name="INVOICE_MONEY"; fnc_dsn_name="#dsn2#";break;
				case 2: fnc_table_name="SHIP_MONEY"; fnc_dsn_name="#dsn2#"; break;
				case 3: fnc_table_name="ORDER_MONEY"; fnc_dsn_name="#dsn3#"; break;
				case 4: fnc_table_name="OFFER_MONEY"; fnc_dsn_name="#dsn3#"; break;
				case 5: fnc_table_name="SERVICE_MONEY"; fnc_dsn_name="#dsn3#";break;
				case 6: fnc_table_name="STOCK_FIS_MONEY"; fnc_dsn_name="#dsn2#"; break;
				case 7: fnc_table_name="INTERNALDEMAND_MONEY"; fnc_dsn_name="#dsn3#"; break;
				case 8: fnc_table_name="CATALOG_MONEY"; fnc_dsn_name="#dsn3#"; break;
				case 10: fnc_table_name="SHIP_INTERNAL_MONEY"; fnc_dsn_name="#dsn2#"; break;
				case 11: fnc_table_name="PAYROLL_MONEY"; fnc_dsn_name="#dsn2#"; break;
				case 12: fnc_table_name="VOUCHER_PAYROLL_MONEY"; fnc_dsn_name="#dsn2#"; break;
				case 13: fnc_table_name="SUBSCRIPTION_CONTRACT_MONEY"; fnc_dsn_name="#dsn3#"; break;				
				case 14: fnc_table_name="PRO_MATERIAL_MONEY"; fnc_dsn_name="#dsn#"; break;			
			}
			is_rate_from_pre_paper_ =1; /*belge kurunu bir önceki belgeden alır.*/
		</cfscript>
		<cfif isdefined('arguments.to_table_type_id') and arguments.to_table_type_id neq arguments.table_type_id> 
			<cfquery name="control_comp_rate_type" datasource="#dsn#">
				SELECT IS_RATE_FROM_PRE_PAPER FROM OUR_COMPANY_INFO WHERE COMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#int_bsk_comp_id#">
			</cfquery>
			<cfif len(control_comp_rate_type.IS_RATE_FROM_PRE_PAPER) and control_comp_rate_type.IS_RATE_FROM_PRE_PAPER eq 0>
				<cfset is_rate_from_pre_paper_ = 0>
			</cfif>
		</cfif>
		<cfif is_rate_from_pre_paper_> <!--- belgenin kuru bir önceki belgeden alınır veya kendi kur bilgisi getirilir--->
        	<cfquery name="Ger_Our_Comp_Info" datasource="#dsn#">
				SELECT IS_RATE_FROM_PRE_PAPER FROM OUR_COMPANY_INFO WHERE COMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#int_bsk_comp_id#">           	
            </cfquery>
        	<cfquery name="get_money_bskt" datasource="#fnc_dsn_name#">
				SELECT 
					<cfif int_bsk_period_year gte 2009>
						CASE WHEN TABLE_NAME.MONEY_TYPE ='YTL' THEN '<cfoutput>#str_money_bskt_func#</cfoutput>' ELSE TABLE_NAME.MONEY_TYPE END AS MONEY_TYPE,
					<cfelseif fnc_dsn_name is dsn3>
						CASE WHEN TABLE_NAME.MONEY_TYPE ='TL' THEN '<cfoutput>#str_money_bskt_func#</cfoutput>' ELSE TABLE_NAME.MONEY_TYPE END AS MONEY_TYPE,
					<cfelse>
						TABLE_NAME.MONEY_TYPE,
					</cfif> 
					TABLE_NAME.ACTION_ID,
					TABLE_NAME.RATE2,
					TABLE_NAME.RATE1,
					TABLE_NAME.IS_SELECTED
				FROM 
					#fnc_table_name#  TABLE_NAME
				WHERE 
					TABLE_NAME.ACTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.action_id#">
				ORDER BY TABLE_NAME.ACTION_MONEY_ID
			</cfquery>
			<cfif not get_money_bskt.recordcount>
				<cfquery name="get_money_bskt" datasource="#dsn#">
					SELECT 
						MONEY AS MONEY_TYPE,0 AS IS_SELECTED,* 
					FROM 
						SETUP_MONEY 
					WHERE 
						COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#int_bsk_comp_id#">
						AND PERIOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#int_bsk_period_id#">
						AND MONEY_STATUS=1 
					ORDER BY MONEY_ID
				</cfquery>
			</cfif>
		<cfelse>
			<cfquery name="get_comp_info" datasource="#dsn#">
				SELECT ISNULL(IS_SELECT_RISK_MONEY,0) IS_SELECT_RISK_MONEY FROM OUR_COMPANY_INFO WHERE COMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#int_bsk_comp_id#">
			</cfquery>
			<cfif get_comp_info.is_select_risk_money eq 1 and isdefined("attributes.comp_id") and len(attributes.comp_id) and (attributes.fuseaction is 'purchase.add_product_all_order' or attributes.fuseaction is 'invoice.add_sale_invoice_from_order' or attributes.fuseaction is 'invoice.form_add_bill_from_ship'  or (attributes.fuseaction is 'sales.form_add_order' and isdefined("attributes.upd_order")))>
				<cfquery name="get_comp_credit" datasource="#dsn#">
					SELECT PAYMENT_RATE_TYPE,MONEY FROM COMPANY_CREDIT WHERE COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.comp_id#"> AND COMPANY_CREDIT.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#int_bsk_comp_id#">
				</cfquery>
                <cfelseif get_comp_info.is_select_risk_money eq 1 and isdefined("attributes.cons_id") and len(attributes.cons_id) and (attributes.fuseaction is 'purchase.add_product_all_order' or attributes.fuseaction is 'invoice.add_sale_invoice_from_order' or attributes.fuseaction is 'invoice.form_add_bill_from_ship'  or (attributes.fuseaction is 'sales.form_add_order' and isdefined("attributes.upd_order")))>
				<cfquery name="get_comp_credit" datasource="#dsn#">
					SELECT PAYMENT_RATE_TYPE,MONEY FROM COMPANY_CREDIT WHERE CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.cons_id#"> AND COMPANY_CREDIT.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#int_bsk_comp_id#">
				</cfquery>
			</cfif>
			<cfquery name="get_pre_paper_money" datasource="#fnc_dsn_name#"><!--- onceki belgede secili olan doviz birimi alınıyor --->
				SELECT 
					<cfif int_bsk_period_year gte 2009>
						CASE WHEN MONEY_TYPE ='YTL' THEN '<cfoutput>#str_money_bskt_func#</cfoutput>' ELSE MONEY_TYPE END AS MONEY_TYPE
					<cfelseif fnc_dsn_name is dsn3>
						CASE WHEN MONEY_TYPE ='TL' THEN '<cfoutput>#str_money_bskt_func#</cfoutput>' ELSE MONEY_TYPE END AS MONEY_TYPE
					<cfelse>
						MONEY_TYPE
					</cfif> 
				FROM 
					#fnc_table_name# 
				WHERE 
					ACTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.action_id#">
					AND IS_SELECTED=1
			</cfquery>
			<cfif get_pre_paper_money.recordcount and len(get_pre_paper_money.MONEY_TYPE)>
				<cfset pre_paper_money=get_pre_paper_money.MONEY_TYPE>
			<cfelse>
				<cfset pre_paper_money=''>
			</cfif>
			<cfquery name="get_money_bskt" datasource="#dsn#">
				SELECT 
					MONEY AS MONEY_TYPE,
					<cfif isdefined("get_comp_credit") and get_comp_credit.recordcount>
						<cfif get_comp_credit.payment_rate_type eq 1>
							ISNULL(RATE3,1) RATE2,
						<cfelseif get_comp_credit.payment_rate_type eq 3>
							ISNULL(EFFECTIVE_PUR,1) RATE2,
						<cfelseif get_comp_credit.payment_rate_type eq 4>
							ISNULL(EFFECTIVE_SALE,RATE2) RATE2,
						<cfelse>
							RATE2 RATE2,
						</cfif>
					<cfelse>
						RATE2,
					</cfif>
					RATE1,
					<cfif len(pre_paper_money)><!--- kur onceki belgeden alınmıyor, fakat secili olan işlem dovizi onceki belgeden getiriliyor --->
						CASE WHEN MONEY ='<cfoutput>#pre_paper_money#</cfoutput>' THEN 1 ELSE 0 END AS IS_SELECTED,
					<cfelse>
						 0 AS IS_SELECTED,
					</cfif>
					* 
				FROM 
					SETUP_MONEY 
				WHERE
					COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#int_bsk_comp_id#">
					AND PERIOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#int_bsk_period_id#">
					AND MONEY_STATUS=1 
				ORDER BY MONEY_ID
			</cfquery>
		</cfif>
	<cfelse>
		<cfquery name="get_comp_info" datasource="#dsn#">
			SELECT ISNULL(IS_SELECT_RISK_MONEY,0) IS_SELECT_RISK_MONEY FROM OUR_COMPANY_INFO WHERE COMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#int_bsk_comp_id#">
		</cfquery>
		<cfif get_comp_info.is_select_risk_money eq 1 and isdefined("attributes.comp_id") and len(attributes.comp_id) and (attributes.fuseaction is 'purchase.add_product_all_order' or attributes.fuseaction is 'invoice.add_sale_invoice_from_order' or attributes.fuseaction is 'invoice.form_add_bill_from_ship'  or (attributes.fuseaction is 'sales.form_add_order' and isdefined("attributes.upd_order")))>
			<cfquery name="get_comp_credit" datasource="#dsn#">
				SELECT PAYMENT_RATE_TYPE,MONEY FROM COMPANY_CREDIT WHERE COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.comp_id#"> AND COMPANY_CREDIT.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#int_bsk_comp_id#">
			</cfquery>
            <cfelseif get_comp_info.is_select_risk_money eq 1 and isdefined("attributes.cons_id") and len(attributes.cons_id) and (attributes.fuseaction is 'purchase.add_product_all_order' or attributes.fuseaction is 'invoice.add_sale_invoice_from_order' or attributes.fuseaction is 'invoice.form_add_bill_from_ship'  or (attributes.fuseaction is 'sales.form_add_order' and isdefined("attributes.upd_order")))>
				<cfquery name="get_comp_credit" datasource="#dsn#">
					SELECT PAYMENT_RATE_TYPE,MONEY FROM COMPANY_CREDIT WHERE CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.cons_id#"> AND COMPANY_CREDIT.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#int_bsk_comp_id#">
				</cfquery>
		</cfif>
		<cfquery name="get_money_bskt" datasource="#dsn#">
			SELECT
				MONEY AS MONEY_TYPE,
				RATE1,
			<cfif isDefined("session.pp")>
				RATEPP2 RATE2,
			<cfelseif isDefined("session.ww")>
				RATEWW2 RATE2,
			<cfelse>
				<cfif isdefined("get_comp_credit") and get_comp_credit.recordcount>
					<cfif get_comp_credit.payment_rate_type eq 1>
						RATE3 RATE2,
					<cfelseif get_comp_credit.payment_rate_type eq 3>
						ISNULL(EFFECTIVE_PUR,1) RATE2,
					<cfelseif get_comp_credit.payment_rate_type eq 4>
						ISNULL(EFFECTIVE_SALE,1) RATE2,
					<cfelse>
						RATE2 RATE2,
					</cfif>
				<cfelse>
					RATE2,
				</cfif>
			</cfif>
			<cfif isdefined("get_comp_credit") and get_comp_credit.recordcount>
				CASE WHEN MONEY = <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_comp_credit.MONEY#"> THEN 1 ELSE 0 END AS IS_SELECTED
			<cfelse>
				0 AS IS_SELECTED
			</cfif>
			FROM
				SETUP_MONEY
			WHERE
				COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#int_bsk_comp_id#"> AND
				PERIOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#int_bsk_period_id#"> AND
				MONEY_STATUS = 1
			ORDER BY
				MONEY_ID
		</cfquery>
	</cfif>
	<script language="JavaScript1.3">
		moneyArray = new Array(<cfoutput>#get_money_bskt.recordcount#</cfoutput>);
		rate1Array = new Array(<cfoutput>#get_money_bskt.recordcount#</cfoutput>);
		rate2Array = new Array(<cfoutput>#get_money_bskt.recordcount#</cfoutput>);
		<cfoutput query="get_money_bskt">
			/*javascript array doldurulur*/
			<cfif int_bsk_period_year gte 2009 and get_money_bskt.MONEY_TYPE is 'YTL'>
				moneyArray[#currentrow-1#] = '#str_money_bskt_func#';
			<cfelse>
				moneyArray[#currentrow-1#] = '#MONEY_TYPE#';
			</cfif>
			rate1Array[#currentrow-1#] = #rate1#;
			rate2Array[#currentrow-1#] = #rate2#;
			/*javascript array doldurulur*/
		</cfoutput>
	</script>
</cffunction>

<cffunction name="basket_kur_ekle">
	<cfargument name="action_id" required="true">
	<cfargument name="table_type_id" required="true">
	<cfargument name="process_type" required="true">
	<cfargument name="basket_money_db" type="string" default="">
	<cfargument name="transaction_dsn">
	<!---
		by : Arzu BT 20031211
		notes : Basket_money tablosuna islemlere gore kur bilgilerini kaydeder.
		process_type:1 upd 0 add
		transaction_dsn : kullanılan sayfa içinde table dan farklı dsn tanımı olduğu durumlarda kullanılan dsn gönderilir.
		usage :
			invoice:1
			ship:2
			order:3
			offer:4
			servis:5
			stock_fis:6
			internmal_demand:7
			prroduct_catalog 8
			sale_quote:9
			subscription:13
		revisions : javascript version ergün koçak 20040209
		kullanim:
		<cfscript>
			basket_kur_ekle(action_id:MY_ID,table_type_id:1,process_type:0);
		</cfscript>		
	--->
	<cfscript>
		switch (arguments.table_type_id){
			case 1: fnc_table_name="INVOICE_MONEY"; fnc_dsn_name="#dsn2#";break;
			case 2: fnc_table_name="SHIP_MONEY"; fnc_dsn_name="#dsn2#"; break;
			case 3: fnc_table_name="ORDER_MONEY"; fnc_dsn_name="#dsn3#"; break;
			case 4: fnc_table_name="OFFER_MONEY"; fnc_dsn_name="#dsn3#"; break;
			case 5: fnc_table_name="SERVICE_MONEY"; fnc_dsn_name="#dsn3#";break;
			case 6: fnc_table_name="STOCK_FIS_MONEY"; fnc_dsn_name="#dsn2#"; break;
			case 7: fnc_table_name="INTERNALDEMAND_MONEY"; fnc_dsn_name="#dsn3#"; break;
			case 8: fnc_table_name="CATALOG_MONEY"; fnc_dsn_name="#dsn3#"; break;
			case 10: fnc_table_name="SHIP_INTERNAL_MONEY"; fnc_dsn_name="#dsn2#"; break;	
			case 11: fnc_table_name="PAYROLL_MONEY"; fnc_dsn_name="#dsn2#"; break;
			case 12: fnc_table_name="VOUCHER_PAYROLL_MONEY"; fnc_dsn_name="#dsn2#"; break;
			case 13: fnc_table_name="SUBSCRIPTION_CONTRACT_MONEY"; fnc_dsn_name="#dsn3#"; break;			
			case 14: fnc_table_name="PRO_MATERIAL_MONEY"; fnc_dsn_name="#dsn#"; break;
		}
		if(len(arguments.basket_money_db))fnc_dsn_name = "#arguments.basket_money_db#";
	</cfscript>
	<cfif not (isdefined('arguments.transaction_dsn') and len(arguments.transaction_dsn))>
		<cfset arguments.transaction_dsn = fnc_dsn_name>
		<cfset arguments.action_table_dsn_alias = ''>
	<cfelse>
		<cfset arguments.action_table_dsn_alias = '#fnc_dsn_name#.'>
	</cfif>
	<cfif arguments.process_type eq 1>
		<cfquery name="del_money_obj_bskt" datasource="#arguments.transaction_dsn#">
			DELETE FROM 
				#arguments.action_table_dsn_alias##fnc_table_name#
			WHERE 
				ACTION_ID=#arguments.action_id#
		</cfquery>
	</cfif>
	<cfloop from="1" to="#attributes.kur_say#" index="fnc_i">
		<cfquery name="add_money_obj_bskt" datasource="#arguments.transaction_dsn#">
			INSERT INTO #arguments.action_table_dsn_alias##fnc_table_name# 
			(
				ACTION_ID,
				MONEY_TYPE,
				RATE2,
				RATE1,
				IS_SELECTED
			)
			VALUES
			(
				#arguments.action_id#,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#wrk_eval('attributes.hidden_rd_money_#fnc_i#')#">,
				#evaluate("attributes.txt_rate2_#fnc_i#")#,
				#evaluate("attributes.txt_rate1_#fnc_i#")#,
				<cfif evaluate("attributes.hidden_rd_money_#fnc_i#") is attributes.BASKET_MONEY>
                    1
                <cfelse>
                    0
                </cfif>					
			)
		</cfquery>
	</cfloop>
</cffunction>
