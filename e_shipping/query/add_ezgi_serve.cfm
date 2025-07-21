<cfif not ListLen(attributes.order_row_id_list)>
	<script type="text/javascript">
		alert("<cfoutput>#getLang('invoice',39)#</cfoutput>!");
		window.close()
	</script>
    <cfabort>
</cfif>
<cf_date tarih='attributes.order_date'>
<cflock name="#CREATEUUID()#" timeout="20">
	<cftransaction>
        <cfloop list="#attributes.order_row_id_list#" index="i">
        	<cfquery name="GET_STOCK_INFO" datasource="#DSN3#">
            	SELECT        
                	ORR.STOCK_ID, 
                    S.PRODUCT_ID, 
                    ORR.QUANTITY, 
                    ORR.UNIT, 
                    ORR.PRICE,
                    ORR.SPECT_VAR_ID, 
                    S.PRODUCT_NAME, 
                    S.PRODUCT_CODE, 
                    ORR.PRODUCT_NAME2, 
                    SP.SPECT_VAR_NAME, 
                    SP.SPECT_MAIN_ID,
                    O.COMMETHOD_ID, 
                    O.PRIORITY_ID, 
                    O.CITY_ID, 
                    O.COUNTY_ID,
                    O.PROJECT_ID, 
                    O.SHIP_ADDRESS, 
                    O.ORDER_NUMBER,
                    CI.CITY_NAME, 
                    CO.COUNTY_NAME
				FROM            
                	ORDER_ROW AS ORR INNER JOIN
                	STOCKS AS S ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
                  	ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID LEFT OUTER JOIN
                	#dsn_alias#.SETUP_CITY AS CI ON O.CITY_ID = CI.CITY_ID LEFT OUTER JOIN
                  	#dsn_alias#.SETUP_COUNTY AS CO ON O.COUNTY_ID = CO.COUNTY_ID LEFT OUTER JOIN
                  	SPECTS AS SP ON ORR.SPECT_VAR_ID = SP.SPECT_VAR_ID
				WHERE        
                	ORR.ORDER_ROW_ID = #i#
            </cfquery>
            <cfif len(attributes.company_id)>
                <cfquery name="get_order_info" datasource="#dsn3#">
                    SELECT        
                        CP.COMPANY_PARTNER_NAME+' '+CP.COMPANY_PARTNER_SURNAME ADI, 
                        CP.COMPANY_PARTNER_EMAIL EMAIL, 
                        C.FULLNAME,
                        COMPANY_TELCODE+' '+COMPANY_TEL1 TELEFON,
                        C.SALES_COUNTY
                    FROM            
                        #dsn_alias#.COMPANY_PARTNER AS CP INNER JOIN
                        #dsn_alias#.COMPANY C ON CP.COMPANY_ID = C.COMPANY_ID
                    WHERE        
                        CP.COMPANY_ID = #attributes.company_id# AND 
                        CP.PARTNER_ID = #attributes.partner_id#
                </cfquery>
            <cfelseif len(attributes.consumer_id)>
            	<cfquery name="get_order_info" datasource="#dsn3#">
                	SELECT        
                        CONSUMER_NAME+' '+CONSUMER_SURNAME ADI, 
                        CONSUMER_EMAIL EMAIL,
                        CONSUMER_NAME+' '+CONSUMER_SURNAME FULLNAME,
                        CONSUMER_WORKTELCODE+' '+CONSUMER_WORKTEL TELEFON,
                        SALES_COUNTY
					FROM            
                    	#dsn_alias#.CONSUMER
					WHERE        
                    	CONSUMER_ID = #attributes.consumer_id#
                </cfquery>
            <cfelse>
            
            </cfif>
            <cf_papers paper_type="SERVICE_APP">
            <cfset system_paper_no=paper_code & '-' & paper_number>
            <cfset system_paper_no_add=paper_number>
            <cfquery name="UPD_GEN_PAP" datasource="#DSN3#">
                UPDATE
                    GENERAL_PAPERS
                SET
                    SERVICE_APP_NUMBER = <cfqueryparam cfsqltype="cf_sql_integer" value="#system_paper_no_add#">
                WHERE
                    SERVICE_APP_NUMBER IS NOT NULL
            </cfquery>
            <cfquery name="ADD_SERVICE" datasource="#DSN3#" result="my_result">
                INSERT INTO
                    SERVICE
                    (
                        SERVICE_ACTIVE,
                        ISREAD,
                        SERVICECAT_ID,
                        SERVICE_STATUS_ID,
                        STOCK_ID,	
                        PRIORITY_ID,
                        COMMETHOD_ID,
                        SERVICE_HEAD,
                        SERVICE_DETAIL,
                        SERVICE_COUNTY_ID,
                        SERVICE_CITY_ID,
                        SERVICE_ADDRESS,
                        SERVICE_COUNTY,
                        SERVICE_CITY,
                        DEAD_LINE,
                        DEAD_LINE_RESPONSE,
                        APPLY_DATE,
                        START_DATE,
                      	SERVICE_PRODUCT_ID,				
                        SERVICE_BRANCH_ID,
                        DEPARTMENT_ID,
                        LOCATION_ID,
                        SERVICE_DEFECT_CODE,				
                        APPLICATOR_NAME,
                        APPLICATOR_COMP_NAME,
                        PRODUCT_NAME,
                        GUARANTY_START_DATE,
                        GUARANTY_INSIDE,
                        INSIDE_DETAIL,
                        SERVICE_NO,
                        BRING_NAME,
                        BRING_EMAIL,
                        DOC_NO,
                        BRING_TEL_NO,
                        BRING_MOBILE_NO,
                        BRING_DETAIL,
                        ACCESSORY,
                        ACCESSORY_DETAIL,
                        SUBSCRIPTION_ID,
                        RELATED_COMPANY_ID,
                        SALE_ADD_OPTION_ID,
                        PROJECT_ID,
                        IS_SALARIED,
                        SHIP_METHOD,
                        BRING_SHIP_METHOD_ID,
                        CUS_HELP_ID,
                        OTHER_COMPANY_ID,
                        OTHER_COMPANY_BRANCH_ID,
                        INSIDE_DETAIL_SELECT,
                        ACCESSORY_DETAIL_SELECT,
                        SERVICECAT_SUB_ID,
                        SERVICECAT_SUB_STATUS_ID,
                        WORKGROUP_ID,
                        CALL_SERVICE_ID,
                        SZ_ID,
                        RECORD_DATE,
                        RECORD_MEMBER,
                        SERVICE_EMPLOYEE_ID,
                        INTERVENTION_DATE,
                        FINISH_DATE,
                        SPEC_MAIN_ID,
                        TIME_CLOCK_HOUR,
                        TIME_CLOCK_MINUTE,
                        <cfif len(attributes.company_id)>
                            SERVICE_PARTNER_ID,
                            SERVICE_COMPANY_ID,					
                        <cfelseif len(attributes.consumer_id)>
                            SERVICE_CONSUMER_ID,
                        </cfif>
                        EZGI_ORDER_ROW_ID
                    )
                    VALUES
                    (
                        1,
                        0,
                        #attributes.service_cat#,
                        #attributes.process_stage#,
                        #GET_STOCK_INFO.stock_id#,
                        <cfif len(GET_STOCK_INFO.PRIORITY_ID)>#GET_STOCK_INFO.PRIORITY_ID#<cfelse>NULL</cfif>,
                        <cfif len(GET_STOCK_INFO.COMMETHOD_ID)>#GET_STOCK_INFO.COMMETHOD_ID#<cfelse>NULL</cfif>,
                        '#GET_STOCK_INFO.order_number#',				
                        '#LTrim(GET_STOCK_INFO.PRODUCT_NAME2)#',
                        <cfif len(GET_STOCK_INFO.county_id)>#GET_STOCK_INFO.county_id#<cfelse>NULL</cfif>,
                        <cfif len(GET_STOCK_INFO.city_id)>#GET_STOCK_INFO.city_id#<cfelse>NULL</cfif>,
                        <cfif len(GET_STOCK_INFO.ship_address)>'#GET_STOCK_INFO.ship_address#'<cfelse>NULL</cfif>,
                        <cfif len(GET_STOCK_INFO.county_name)>'#GET_STOCK_INFO.county_name#'<cfelse>NULL</cfif>,
                        <cfif len(GET_STOCK_INFO.city_name)>'#GET_STOCK_INFO.city_name#'<cfelse>NULL</cfif>,
                        NULL,
                        NULL,
                        <cfif len(attributes.order_date)>#attributes.order_date#<cfelse>NULL</cfif>,
                        NULL,
                        #GET_STOCK_INFO.product_id#,
                        <cfif isDefined("attributes.branch_id") and len(attributes.branch_id)>#attributes.branch_id#<cfelse>NULL</cfif>,
                        <cfif len(attributes.department_id)>#attributes.department_id#<cfelse>NULL</cfif>,
                        <cfif len(attributes.location_id)>#attributes.location_id#<cfelse>NULL</cfif>,
                        NULL,
                        '#get_order_info.ADI#',
                        '#left(get_order_info.FULLNAME,200)#',
                        '#GET_STOCK_INFO.PRODUCT_NAME#',
                        NULL,
                        0,
                        NULL,
                        '#system_paper_no#',
                        NULL,
                        <cfif len(get_order_info.email)>'#get_order_info.email#'<cfelse>NULL</cfif>,
                        NULL,
                        <cfif len(get_order_info.telefon)>'#get_order_info.telefon#'<cfelse>NULL</cfif>,
                        NULL,
                        NULL,
                        0,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        <cfif len(GET_STOCK_INFO.project_id)>#GET_STOCK_INFO.project_id#,<cfelse>NULL,</cfif>
                        <cfif GET_STOCK_INFO.PRICE gt 0>1<cfelse>0</cfif>,
                        <cfif isdefined("attributes.ship_method") and len(attributes.ship_method) and len(attributes.ship_method_name)>#attributes.ship_method#<cfelse>NULL</cfif>,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        <cfif len(get_order_info.sales_county)>#get_order_info.sales_county#<cfelse>NULL</cfif>,
                        #now()#,
                        #session.ep.userid#,
                        NULL,
                        NULL,
                        NULL,
                        <cfif len(GET_STOCK_INFO.SPECT_MAIN_ID)>#GET_STOCK_INFO.SPECT_MAIN_ID#<cfelse>NULL</cfif>,
                        NULL,
                        NULL,
                        <cfif len(attributes.company_id)>
                            #attributes.partner_id#,
                            #attributes.company_id#,					
                        <cfelseif len(attributes.consumer_id)>
                            #attributes.consumer_id#,
                        </cfif>
                        #i#
                    )
             </cfquery>
            <cfquery name="GET_SERVICE1" datasource="#DSN3#" maxrows="1">
                SELECT  
                    RELATED_COMPANY_ID,
                    SERVICE_ACTIVE,
                    SERVICE_NO,
                    SERVICECAT_ID,
                    PRO_SERIAL_NO,
                    STOCK_ID,
                    PRODUCT_NAME,
                    SERVICE_SUBSTATUS_ID,
                    SERVICE_STATUS_ID,
                    GUARANTY_ID,
                    GUARANTY_PAGE_NO,
                    PRIORITY_ID,
                    COMMETHOD_ID,
                    SERVICE_HEAD,
                    SERVICE_DETAIL,
                    SERVICE_ADDRESS,
                    SERVICE_COUNTY_ID,
                    SERVICE_CITY_ID,
                    SERVICE_COUNTY,
                    SERVICE_CITY,
                    SERVICE_CONSUMER_ID,
                    NOTES,
                    APPLY_DATE,
                    START_DATE,
                    SERVICE_PRODUCT_ID,
                    SERVICE_DEFECT_CODE,
                    APPLICATOR_NAME,
                    PROJECT_ID,
                    RECORD_DATE,
                    RECORD_MEMBER,
                    UPDATE_DATE,
                    UPDATE_MEMBER,
                    RECORD_PAR,
                    UPDATE_PAR,
                    OTHER_COMPANY_ID,
                    SHIP_METHOD,
                    SERVICE_ID,
                    SERVICECAT_SUB_ID,
                    SERVICECAT_SUB_STATUS_ID,
                    WORKGROUP_ID,
                    CALL_SERVICE_ID,
                    INTERVENTION_DATE,
                    FINISH_DATE,
                    GUARANTY_INSIDE
                FROM 
                    SERVICE 
                WHERE 
                    RECORD_MEMBER = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#"> AND 
                    SERVICE_NO = <cfqueryparam cfsqltype="cf_sql_varchar" value="#system_paper_no#"> 
                ORDER BY 
                    SERVICE_ID DESC
            </cfquery>
        </cfloop>
	</cftransaction>
</cflock>
<cfquery name="ADD_HISTORY" datasource="#DSN3#">
	INSERT INTO
		SERVICE_HISTORY
        (
            RELATED_COMPANY_ID,
            SERVICE_ACTIVE,
            SERVICECAT_ID,
            PRO_SERIAL_NO,
            STOCK_ID,
            PRODUCT_NAME,
            SERVICE_SUBSTATUS_ID,
            SERVICE_STATUS_ID,
            GUARANTY_ID,
            GUARANTY_PAGE_NO,
            PRIORITY_ID,
            COMMETHOD_ID,				
            SERVICE_HEAD,
            SERVICE_DETAIL,
            SERVICE_ADDRESS,
            SERVICE_COUNTY_ID,
            SERVICE_CITY_ID,
            SERVICE_COUNTY,
            SERVICE_CITY,
            SERVICE_CONSUMER_ID,
            NOTES,
            APPLY_DATE,
            FINISH_DATE,
            START_DATE,
            SERVICE_PRODUCT_ID,
            SERVICE_DEFECT_CODE,
            APPLICATOR_NAME,
            PROJECT_ID,
            RECORD_DATE,
            RECORD_MEMBER,
            UPDATE_DATE,
            UPDATE_MEMBER,
            RECORD_PAR,
            UPDATE_PAR,
            OTHER_COMPANY_ID,
            SHIP_METHOD,
            SERVICE_ID,
            SERVICECAT_SUB_ID,
            SERVICECAT_SUB_STATUS_ID,
            WORKGROUP_ID,
            CALL_SERVICE_ID,
            INTERVENTION_DATE,
            GUARANTY_INSIDE
        )
        VALUES
        (
            <cfif len(get_service1.RELATED_COMPANY_ID)>#get_service1.RELATED_COMPANY_ID#<cfelse>NULL</cfif>,
            #get_service1.service_active#,
            <cfif len(get_service1.servicecat_id)>#get_service1.servicecat_id#<cfelse>NULL</cfif>,
            <cfif len(get_service1.pro_serial_no)>'#get_service1.pro_serial_no#'<cfelse>NULL</cfif>,
            <cfif len(get_service1.stock_id)>#get_service1.stock_id#<cfelse>NULL</cfif>,
            <cfif len(get_service1.product_name)>'#get_service1.product_name#'<cfelse>NULL</cfif>,
            <cfif len(get_service1.service_substatus_id)>#get_service1.service_substatus_id#<cfelse>NULL</cfif>,
            <cfif len(get_service1.service_status_id)>#get_service1.service_status_id#<cfelse>NULL</cfif>,
            <cfif len(get_service1.guaranty_id)>#get_service1.guaranty_id#<cfelse>NULL</cfif>,
            <cfif len(get_service1.guaranty_page_no)>#get_service1.guaranty_page_no#<cfelse>NULL</cfif>,
            <cfif len(get_service1.priority_id)>#get_service1.priority_id#<cfelse>NULL</cfif>,
            <cfif len(get_service1.commethod_id)>#get_service1.commethod_id#<cfelse>NULL</cfif>,
            <cfif len(get_service1.service_head)>'#wrk_eval("get_service1.service_head")#'<cfelse>NULL</cfif>,
            <cfif len(get_service1.service_detail)>'#get_service1.service_detail#'<cfelse>NULL</cfif>,
            <cfif len(get_service1.service_address)>'#get_service1.service_address#'<cfelse>NULL</cfif>,
            <cfif len(get_service1.service_county_id)>#get_service1.service_county_id#<cfelse>NULL</cfif>,
            <cfif len(get_service1.service_city_id)>#get_service1.service_city_id#<cfelse>NULL</cfif>,
            <cfif len(get_service1.service_county)>'#get_service1.service_county#'<cfelse>NULL</cfif>,
            <cfif len(get_service1.service_city)>'#get_service1.service_city#'<cfelse>NULL</cfif>,
            <cfif len(get_service1.service_consumer_id)>#get_service1.service_consumer_id#<cfelse>NULL</cfif>,
            <cfif len(get_service1.notes)>'#get_service1.notes#'<cfelse>NULL</cfif>,
            <cfif len(get_service1.apply_date)>#createodbcdatetime(get_service1.apply_date)#<cfelse>NULL</cfif>,
            <cfif len(get_service1.finish_date)>#createodbcdatetime(get_service1.finish_date)#<cfelse>NULL</cfif>,
            <cfif len(get_service1.start_date)>#createodbcdatetime(get_service1.start_date)#<cfelse>NULL</cfif>,
            <cfif len(get_service1.service_product_id)>#get_service1.service_product_id#<cfelse>NULL</cfif>,
            <cfif len(get_service1.service_defect_code)>'#get_service1.service_defect_code#'<cfelse>NULL</cfif>,
            <cfif len(get_service1.applicator_name) and isdefined('get_service1.applicator_name')>'#get_service1.applicator_name#'<cfelse>NULL</cfif>,
            <cfif len(get_service1.project_id)>#get_service1.project_id#<cfelse>NULL</cfif>,
            <cfif len(get_service1.record_date)>#createodbcdatetime(get_service1.record_date)#<cfelse>NULL</cfif>,
            <cfif len(get_service1.record_member)>#get_service1.record_member#<cfelse>NULL</cfif>,
            <cfif len(get_service1.update_date)>#createodbcdatetime(get_service1.update_date)#<cfelse>NULL</cfif>,
            <cfif len(get_service1.update_member)>#get_service1.update_member#<cfelse>NULL</cfif>,
            <cfif len(get_service1.record_par)>#get_service1.record_par#<cfelse>NULL</cfif>,
            <cfif len(get_service1.update_par)>#get_service1.update_par#<cfelse>NULL</cfif>,
            <cfif len(get_service1.other_company_id)>#get_service1.other_company_id#<cfelse>NULL</cfif>,
            <cfif len(get_service1.ship_method)>#get_service1.ship_method#<cfelse>NULL</cfif>,						
            #get_service1.service_id#,
            <cfif len(get_service1.servicecat_sub_id)>#get_service1.servicecat_sub_id#<cfelse>NULL</cfif>,
            <cfif len(get_service1.servicecat_sub_status_id)>#get_service1.servicecat_sub_status_id#<cfelse>NULL</cfif>,
            <cfif len(get_service1.workgroup_id)>#get_service1.workgroup_id#<cfelse>NULL</cfif>,
            <cfif len(get_service1.call_service_id)>#get_service1.call_service_id#<cfelse>NULL</cfif>,
            <cfif len(get_service1.INTERVENTION_DATE)>#createodbcdatetime(get_service1.INTERVENTION_DATE)#<cfelse>NULL</cfif>,
            #get_service1.GUARANTY_INSIDE#
        )
</cfquery>
<script type="text/javascript">
		alert("<cf_get_lang_main no='1426.Kayıt İşleminiz Başarıyla Tamamlanmıştır.'>!");
		window.close()
</script>