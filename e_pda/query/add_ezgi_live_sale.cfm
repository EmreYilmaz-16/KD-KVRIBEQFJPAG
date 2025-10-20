<cfdump  var="BURADAYIM">

<cfset current_row_list = ''>
<cfset stock_id_list = ''>
<cfquery name="get_shelf_control" datasource="#dsn3#"> <!---Depoda Raf Var mı--->
	SELECT  
    	PRODUCT_PLACE_ID 
   	FROM 
    	PRODUCT_PLACE 
   	WHERE 
    	LOCATION_ID = #Listgetat(attributes.TXT_DEPARTMENT_IN,2,'-')# AND 
        STORE_ID = #Listgetat(attributes.TXT_DEPARTMENT_IN,1,'-')#
</cfquery>
<cfif get_shelf_control.recordcount>
	<cfset shelf_control = 1>
<cfelse>
	<cfset shelf_control = 0>
</cfif>
<cfset form.process_cat = attributes.process_cat_id>
<cfloop from="1" to="#attributes.row_count#" index="i">
	<cfif isdefined('attributes.row_kontrol#i#') and Evaluate('attributes.row_kontrol#i#') gt 0>
    	<cfset stock_id_list = ListAppend( stock_id_list,Evaluate('attributes.STOCKID#i#'))>
        <cfset current_row_list = ListAppend(current_row_list,i)>
        <cfif isdefined('attributes.SHELF_CODE#i#') and len(Evaluate('attributes.SHELF_CODE#i#'))>
        	<cfif attributes.sales_type eq 3> <!---Stok Hareketi Yapılacaksa--->
				<cfif shelf_control eq 1 and Evaluate('attributes.SHELF_CODE#i#') lte 0><!--- Eğer Depoda Raf Varsa ve Formdan Raf Bilgisi Gelmemişse İşlemi Durdur-İkinci Kontrol--->
                    <script type="text/javascript">
                        alert('Raf Kodu Boş Gelmektedir Lütfen Tekrar Deneyin!');
                        window.history.go(-1)
                    </script>
                    <cfabort>
                </cfif>
            </cfif>
            <cfquery name="get_shelf_id" datasource="#dsn3#">
                SELECT        
                    PRODUCT_PLACE_ID
                FROM            
                    PRODUCT_PLACE
                WHERE        
                    SHELF_CODE = '#Evaluate('attributes.SHELF_CODE#i#')#'
            </cfquery>
            <cfset 'attributes.SHELF_NUMBER_TXT_#i#' = Evaluate('attributes.SHELF_CODE#i#')> 
            <cfset 'attributes.SHELF_NUMBER_#i#' = get_shelf_id.PRODUCT_PLACE_ID>
      	<cfelse>
        	<cfset 'attributes.SHELF_NUMBER_TXT_#i#' = ''> 
            <cfset 'attributes.SHELF_NUMBER_#i#' = ''>
        </cfif>
        <cfquery name="GET_LOT_K_KONT_ID" datasource="#dsn3#">
            SELECT     
                PU.PRODUCT_UNIT_ID, 
                PU.MAIN_UNIT, 
                PS.PRICE, 
                PS.MONEY,
                S.BARCOD,
                S.PRODUCT_NAME, 
                S.TAX, 
                S.STOCK_ID, 
                S.PRODUCT_ID,
                S.STOCK_CODE
            FROM         
                STOCKS AS S INNER JOIN
                PRICE_STANDART AS PS ON S.PRODUCT_ID = PS.PRODUCT_ID INNER JOIN
                PRODUCT_UNIT AS PU ON S.PRODUCT_ID = PU.PRODUCT_ID
            WHERE     
                PU.IS_MAIN = 1 AND 
                PS.PRICESTANDART_STATUS = 1 AND 
                PS.PURCHASESALES = 0 AND
                S.STOCK_ID = #Evaluate('attributes.STOCKID#i#')#
            ORDER BY 	
                S.PRODUCT_NAME
        </cfquery>
        <cfquery name="get_spect" datasource="#dsn3#">
            SELECT 
                SPECT_VAR_ID, 
                SPECT_VAR_NAME
            FROM            
                SPECTS
            WHERE        
                SPECT_VAR_ID IN
                                (
                                    SELECT        
                                        MAX(SPECT_VAR_ID) AS SPECT_VAR_ID
                                    FROM            
                                        SPECTS AS SPECTS_1
                                    WHERE        
                                        STOCK_ID = #Evaluate('attributes.STOCKID#i#')#
                                )
        </cfquery>
		<cfoutput query="GET_LOT_K_KONT_ID">
            <cfset 'attributes.AMOUNT_OTHER#i#' = Evaluate('attributes.AMOUNT#i#')>
            <cfset 'attributes.UNIT#i#' = GET_LOT_K_KONT_ID.MAIN_UNIT>
            <cfset 'attributes.UNIT_ID#i#' = GET_LOT_K_KONT_ID.PRODUCT_UNIT_ID> 
            <cfset 'attributes.STOCK_CODE#i#' = GET_LOT_K_KONT_ID.STOCK_CODE> 
            <cfset 'attributes.STOCK_ID#i#' = GET_LOT_K_KONT_ID.STOCK_ID> 
            <cfset 'attributes.PRODUCT_ID#i#' = GET_LOT_K_KONT_ID.PRODUCT_ID> 
            <cfset 'attributes.PRODUCT_NAME#i#' = GET_LOT_K_KONT_ID.PRODUCT_NAME> 
            <cfset 'attributes.ACTION_ROW_ID#i#' = 0>
            <cfset 'attributes.TAX#i#' = GET_LOT_K_KONT_ID.TAX>
        </cfoutput>
        <cfif get_spect.recordcount>
            <cfoutput query="get_spect">
                <cfset 'attributes.SPECT_NAME#i#' = get_spect.SPECT_VAR_NAME>
                <cfset 'attributes.SPECT_ID#i#' = get_spect.SPECT_VAR_ID> 
            </cfoutput>
        <cfelse>
            <cfset 'attributes.SPECT_NAME#i#' = ''>
           	<cfset 'attributes.SPECT_ID#i#' = ''> 
        </cfif>
    </cfif>
</cfloop>
<cfset session.ep.userid = session.ep.userid>
<cfset session.ep.period_id = session.ep.period_id>
<cfset session.ep.name = session.ep.name>
<cfset session.ep.surname = session.ep.surname>
<cfset session.ep.our_company_info.spect_type = session.ep.our_company_info.spect_type>
<cfset session.ep.our_company_info.is_cost = 1><!---Dikkat Firmaya Göre Değişir--->
<cfset session.ep.company_id = session.ep.company_id>
<cfset session.ep.user_location = session.ep.user_location>
<cfif ListLen(current_row_list)>
	<!---Sipariş Bilgileri--->
    <cfquery name="GET_ADDRESS" datasource="#DSN#">
        SELECT 
            C.CITY, 
            C.COUNTY, 
            C.COMPANY_ADDRESS, 
            C.SEMT,	
            SETUP_CITY.CITY_NAME,
            SETUP_COUNTY.COUNTY_NAME
        FROM 
            COMPANY C, 
            SETUP_CITY, 
            SETUP_COUNTY 
        WHERE 
            C.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#"> AND
            C.CITY = SETUP_CITY.CITY_ID AND
            C.COUNTY = SETUP_COUNTY.COUNTY_ID 
    </cfquery>
    <cfset attributes.paymethod_id = ''>
    <cfset attributes.paymethod = ''>
    <cfset attributes.ref_member_type ='none'>
    <cfset attributes.ship_address_city_id = get_address.city>
	<cfset attributes.ship_address_county_id = get_address.county>
    <cfset attributes.ship_address = '#get_address.company_address# #get_address.semt# #get_address.county_name# #get_address.city_name#'>
    <cfset ship_address_id = -1>
    <cfset attributes.deliver_dept_id = Listgetat(attributes.TXT_DEPARTMENT_OUT,1,'-')>
    <cfset attributes.deliver_loc_id = Listgetat(attributes.TXT_DEPARTMENT_OUT,2,'-')>
    <cfset attributes.deliver_dept_name = 'depo'>
    <cfset attributes.active_company = session.ep.company_id>
    <cfset attributes.basket_due_value_date_ = attributes.order_date>
    <cfset attributes.deliverdate = attributes.order_date>
    <cfset attributes.order_employee_id = session.ep.userid>
    <cfset attributes.order_employee = get_emp_info(session.ep.userid,0,0)>
    <cfset attributes.order_head = 'PDA Siparişiniz'>
   <!--- Sipariş Bilgileri--->
    <cfset attributes.ROWS_ = listlen(stock_id_list)>
    <cfset attributes.DEPARTMENT_OUT = Listgetat(attributes.TXT_DEPARTMENT_IN,1,'-')>
    <cfset attributes.LOCATION_OUT = Listgetat(attributes.TXT_DEPARTMENT_IN,2,'-')> 
    <cfset attributes.DEPARTMENT_IN = Listgetat(attributes.TXT_DEPARTMENT_OUT,1,'-')>
    <cfset attributes.LOCATION_IN = Listgetat(attributes.TXT_DEPARTMENT_OUT,2,'-')> 
    <cfset attributes.EMPLOYEE_ID = session.ep.userid>
    <cfset attributes.ACTIVE_PERIOD = session.ep.period_id>
    <cfset attributes.BASKET_DISCOUNT_TOTAL = 0>
    <cfset attributes.BASKET_EMPLOYEE1 = ''>  
    <cfset attributes.BASKET_EMPLOYEE_ID1 = ''> 
    <cfset attributes.BASKET_EXTRA_INFO1 = ''>  
    <cfset attributes.BASKET_GROSS_TOTAL = 0>  
    <cfset attributes.BASKET_ID = 12> 
    <cfset attributes.BASKET_MEMBER_PRICECAT = '' > 
    <cfset attributes.BASKET_NET_TOTAL = 0>  
    <cfset attributes.BASKET_OTV_1 = 0> 
    <cfset attributes.BASKET_OTV_COUNT = 1>  
    <cfset attributes.BASKET_OTV_FROM_TAX_PRICE = 0>
    <cfset attributes.BASKET_OTV_TOTAL = 0>
    <cfset attributes.BASKET_OTV_VALUE_1 = 0>
    <cfset attributes.BASKET_TAX_1 = 0>
    <cfset attributes.BASKET_TAX_VALUE_1 = 0>
    <cfset attributes.BASKET_PRICE_ROUND_NUMBER = 4>  
    <cfset attributes.BASKET_RATE_ROUND_NUMBER_ =4>
    <cfset attributes.BASKET_SPECT_TYPE =0> 
    <cfset attributes.BASKET_TOTAL_ROUND_NUMBER_ = 2>
    <cfset attributes.BASKET_TAX_COUNT = 1>  
    <cfset attributes.BASKET_TAX_TOTAL = 0> 
    <cfset attributes.CONTROL_FIELD_VALUE =-1>
    <cfset attributes.EXTRA_COST_RATE =''> 
    <cfset attributes.INDIRIM_TOTAL = 0>
    <cfset attributes.INTERNALDEMAND_ID_LIST = ''>
    <cfset attributes.IS_GENERAL_PROM = 0> 
    <cfset attributes.OLD_GENERAL_PROM_AMOUNT = ''>  
    <cfset attributes.OTHER_MONEY_VALUE_1 = 0> 
    <cfset attributes.OTHER_MONEY_1 = 'TL'>
    <cfset attributes.PROD_ORDER = ''>  
    <cfset attributes.PROD_ORDER_NUMBER = ''>  
    <cfset attributes.PROJECT_HEAD = ''> 
    <cfset attributes.PROJECT_HEAD_IN = ''>  
    <cfset attributes.PROJECT_ID = ''>  
    <cfset attributes.PROJECT_ID_IN = ''>  
    <cfset attributes.RD_MONEY = 1>  
    <cfset attributes.REF_NO = ''> 
    <cfset attributes.ROW_COST_TOTAL =0>
    <cfset attributes.SALE_PRODUCT = ''>  
    <cfset attributes.SEARCH_PROCESS_DATE = ''>
    <cfset attributes.SERVICE_ID = ''>  
    <cfset attributes.SERVICE_NAME = ''>
    <cfset attributes.TODAY_DATE_ = now()>
    <cfset attributes.USE_BASKET_PROJECT_DISCOUNT_ = 0>   
    <cfset attributes.WORK_HEAD = 0>  
    <cfset attributes.WORK_ID = 0> 
    <cfset attributes.WRK_SUBMIT_BUTTON = 'Kaydet'> 
    <cfset attributes.X_COST_ACC = 1>
    <cfset BASKET_KUR_EKLE = 0>
    <cfloop list="#current_row_list#" index="k">
    	<cfset 'attributes.SHELF_NUMBER_TXT#k#' = ''> 
      	<cfset 'attributes.SHELF_NUMBER#k#' = ''>
		<cfset 'attributes.BASKET_ROW_DEPARTMAN#k#' = ''>  
        <cfset 'attributes.DARA#k#' = 0>  
        <cfset 'attributes.DARALI#k#' = 1>  
        <cfset 'attributes.DELIVER_DATE#k#' = ''>  
        <cfset 'attributes.DELIVER_DEPT#k#' = ''> 
        <cfset 'attributes.DUEDATE#k#' = ''>  
        <cfset 'attributes.EK_TUTAR#k#' = ''>  
        <cfset 'attributes.EK_TUTAR_COST#k#' = ''>  
        <cfset 'attributes.EK_TUTAR_MARJ#k#' = ''>  
        <cfset 'attributes.EK_TUTAR_OTHER_TOTAL#k#' = 0>  
        <cfset 'attributes.EK_TUTAR_PRICE#k#' = ''>  
        <cfset 'attributes.EK_TUTAR_TOTAL#k#' = 0>
        <cfset 'attributes.EXTRA_COST#k#' = 0> 
        <cfset 'attributes.INDIRIM10#k#' = 0>  
        <cfset 'attributes.INDIRIM1#k#' = 0>  
        <cfset 'attributes.INDIRIM2#k#' = 0>  
        <cfset 'attributes.INDIRIM3#k#' = 0>  
        <cfset 'attributes.INDIRIM4#k#' = 0>  
        <cfset 'attributes.INDIRIM5#k#' = 0>  
        <cfset 'attributes.INDIRIM6#k#' = 0>  
        <cfset 'attributes.INDIRIM7#k#' = 0>  
        <cfset 'attributes.INDIRIM8#k#' = 0>  
        <cfset 'attributes.INDIRIM9#k#' = 0>  
        <cfset 'attributes.ISKONTO_TUTAR#k#' = 0>  
        <cfset 'attributes.IS_COMMISSION#k#' = 0>
        <cfset 'attributes.IS_INVENTORY#k#' = 1>
        <cfset 'attributes.KARMA_PRODUCT_ID#k#' = ''>
        <cfset 'attributes.IS_PRODUCTION#k#' = 0>  
        <cfset 'attributes.IS_PROMOTION#k#' = 0> 
        <cfset 'attributes.LIST_PRICE#k#' = 0> 
        <cfset 'attributes.LOT_NO#k#' = ''> 
        <cfset 'attributes.LIST_PRICE_DISCOUNT#k#' = ''> 
        <cfset 'attributes.MANUFACT_CODE#k#' = ''>  
        <cfset 'attributes.MARJ#k#' = ''> 
        <cfset 'attributes.NET_MALIYET#k#' = 0>  
        <cfset 'attributes.NUMBER_OF_INSTALLMENT#k#' = 0>  
        <cfset 'attributes.ORDER_CURRENCY#k#' = -1>  
        <cfset 'attributes.OTHER_MONEY_GROSS_TOTAL#k#' = 0> 
        <cfset 'attributes.OTHER_MONEY#k#' = 'TL'>
        <cfset 'attributes.OTHER_MONEY_#k#' = 'TL'>
        <cfset 'attributes.OTV_ORAN#k#' = 0>  
        <cfset 'attributes.PBS_CODE#k#' = ''>  
        <cfset 'attributes.PBS_ID#k#' = ''>  
        <cfset 'attributes.PRICE#k#' = 0> 
        <cfset 'attributes.PRICE_CAT#k#' = ''>  
        <cfset 'attributes.PRICE_NET#k#' = 0>  
        <cfset 'attributes.PRICE_NET_DOVIZ#k#' = 0> 
        <cfset 'attributes.PRICE_OTHER#k#' = 0>  
        <cfset 'attributes.PRODUCT_NAME_OTHER#k#' =''>
        <cfset 'attributes.PROMOSYON_MALIYET#k#' = ''>  
        <cfset 'attributes.PROMOSYON_YUZDE#k#' = ''>  
        <cfset 'attributes.PROM_RELATION_ID#k#' = ''>  
        <cfset 'attributes.PROM_STOCK_ID#k#' = ''>  
        <cfset 'attributes.RELATED_ACTION_ID#k#' = ''>  
        <cfset 'attributes.RELATED_ACTION_TABLE#k#' = ''>  
        <cfset 'attributes.RESERVE_DATE#k#' = ''>  
        <cfset 'attributes.RESERVE_TYPE#k#' = -3> 
        <cfset 'attributes.ROW_CATALOG_ID#k#' = ''>  
        <cfset 'attributes.ROW_HEIGHT#k#' = ''>  
        <cfset 'attributes.ROW_LASTTOTAL#k#' = 0>  
        <cfset 'attributes.ROW_NETTOTAL#k#' = 0>  
        <cfset 'attributes.ROW_OTVTOTAL#k#' = 0>  
        <cfset 'attributes.ROW_PROJECT_ID#k#' = ''>  
        <cfset 'attributes.ROW_PROJECT_NAME#k#' = ''>  
        <cfset 'attributes.ROW_PROMOTION_ID#k#' = ''>  
        <cfset 'attributes.ROW_SERVICE_ID#k#' = ''>  
        <cfset 'attributes.ROW_SHIP_ID#k#' = 0>  
        <cfset 'attributes.ROW_TAXTOTAL#k#' = 0>  
        <cfset 'attributes.ROW_TOTAL#k#' = 0>  
        <cfset 'attributes.ROW_UNIQUE_RELATION_ID#k#' = ''>  
        <cfset 'attributes.ROW_WIDTH#k#' = ''>
        <cfset 'attributes.ROW_DEPTH#k#' = ''>
        <cfset 'attributes.TO_SHELF_NUMBER#k#' = ''>  
      	<cfset 'attributes.TO_SHELF_NUMBER_TXT#k#' = ''>
        <cfset 'attributes.SPECIAL_CODE#k#' = ''>  
        <cfset 'attributes.TAX_PRICE#k#' = ''>  
        <cfset 'attributes.UNIT_OTHER#k#' = ''>  
        <cfset 'attributes.WRK_ROW_RELATION_ID#k#' = ''>
    	<cfset 'attributes.WRK_ROW_ID#k#' = "#round(rand()*65)##dateformat(now(),'YYYYMMDD')##timeformat(now(),'HHmmssL')##session.ep.userid##round(rand()*100)#">
    </cfloop>
</cfif>
<!---Satış Sipariş Kaydı--->
add order öbcesi
    <cfinclude template="add_order.cfm">
    <cfset order_id = GET_MAX_ORDER.max_id>
<!---Satış Sipariş Kaydı--->
<cfif attributes.sales_type eq 2 or attributes.sales_type eq 3>
	<!---E-Shipping Kaydı--->
    <cfset ATTRIBUTES.XML_MULTIPLE_COUNTING_FIS =1>
    <cfset ATTRIBUTES.FIS_DATE_H  ="00">
    <cfset ATTRIBUTES.FIS_DATE_M  ="0">
    <cftransaction>
    	<cfquery name="upd_order_row" datasource="#dsn3#"> <!---Sipariş Satırları Sevk Olacak--->
            UPDATE ORDER_ROW SET ORDER_ROW_CURRENCY = -6 WHERE ORDER_ID = #order_id#
        </cfquery> 
        <cfquery name="get_GEN_PAP" datasource="#DSN3#">
            SELECT        
                SHIP_FIS_NO,
                SHIP_FIS_NUMBER,
                SHIP_FIS_NO + '-' + CAST(SHIP_FIS_NUMBER+1 AS CHAR(6)) AS FISNO
            FROM            
                GENERAL_PAPERS
            WHERE        
                GENERAL_PAPERS_ID = 1
        </cfquery>
        <CFSET NEW_NUMBER = (get_GEN_PAP.SHIP_FIS_NUMBER*1) + 1>
        <cfquery name="ADD_SHIP_RESULT" datasource="#DSN3#" result="MAX_ID">
            INSERT INTO 
                EZGI_SHIP_RESULT
                (
                SHIP_METHOD_TYPE, 
                DELIVER_EMP, 
                DELIVER_PAPER_NO, 
                DELIVERY_DATE, 
                DEPARTMENT_ID, 
                SHIP_STAGE, 
                COMPANY_ID, 
                PARTNER_ID, 
                OUT_DATE, 
                IS_TYPE, 
                LOCATION_ID, 
                RECORD_EMP, 
                RECORD_IP, 
                RECORD_DATE
                )
            SELECT        
                1 AS SHIP_METHOD, 
                ORDER_EMPLOYEE_ID, 
                '#get_GEN_PAP.FISNO#', 
                DELIVERDATE, 
                DELIVER_DEPT_ID, 
                #attributes.process_stage_eshipping#, 
                COMPANY_ID, 
                PARTNER_ID, 
                ORDER_DATE, 
                1 AS TYPE, 
                LOCATION_ID, 
                RECORD_EMP, 
                RECORD_IP, 
                RECORD_DATE
            FROM            
                ORDERS
            WHERE        
                ORDER_ID = #order_id#
        </cfquery>
        <cfquery name="UPD_GEN_PAP" datasource="#DSN3#">
            UPDATE GENERAL_PAPERS SET SHIP_FIS_NUMBER = #NEW_NUMBER# WHERE SHIP_FIS_NUMBER IS NOT NULL
        </cfquery>
        <cfquery name="ADD_SHIP_RESULT_ROW" datasource="#DSN3#">
            INSERT INTO 
                EZGI_SHIP_RESULT_ROW
                (
                SHIP_RESULT_ID, 
                ORDER_ID, 
                ORDER_ROW_ID, 
                ORDER_ROW_AMOUNT
                )
            SELECT        
                #MAX_ID.IDENTITYCOL#, 
                ORDER_ID, 
                ORDER_ROW_ID, 
                QUANTITY
            FROM            
                ORDER_ROW
            WHERE        
                ORDER_ID = #order_id#
        </cfquery>
    </cftransaction>
    <!---E-Shipping Kaydı--->
</cfif>
<cfif attributes.sales_type eq 3> 
	<!---E-Shipping Kontrol--->
    <cfquery name="UPD_SEVKIYAT_KONTROL" datasource="#dsn3#">
        INSERT INTO 
            EZGI_SHIPPING_PACKAGE_LIST
            (
            SHIPPING_ID, 
            STOCK_ID, 
            AMOUNT, 
            CONTROL_AMOUNT, 
            CONTROL_STATUS, 
            TYPE, 
            RECORD_EMP, 
            RECORD_DATE
            )
        SELECT        
            E.SHIP_RESULT_ID, 
            ORR.STOCK_ID, 
            ORR.QUANTITY, 
            ORR.QUANTITY AS A, 
            2 AS B, 
            1 AS C, 
            #session.ep.userid#,
            #now()#
        FROM            
            EZGI_SHIP_RESULT_ROW AS E INNER JOIN
            ORDER_ROW AS ORR ON E.ORDER_ROW_ID = ORR.ORDER_ROW_ID
        WHERE        
            E.SHIP_RESULT_ID = #MAX_ID.IDENTITYCOL#
    </cfquery>
    <!---E-Shipping Kontrol--->
    
    <!---Ambar Fişi--->
    <cfset attributes.REF_NO = get_GEN_PAP.FISNO>
    <cf_papers paper_type="stock_fis">
    <cfif isdefined("paper_full") and isdefined("paper_number")>
        <cfset system_paper_no = paper_full>
    <cfelse>
        <cfset system_paper_no = "">
    </cfif>
    <cfset attributes.FIS_NO_ = system_paper_no> 
    <cfset attributes.FIS_DATE = Dateformat(now(),'dd/mm/yyyy')>
   	<cfloop list="#current_row_list#" index="k">
    	<cfset 'attributes.SHELF_NUMBER_TXT#k#' = Evaluate('attributes.SHELF_NUMBER_TXT_#k#')> 
      	<cfset 'attributes.SHELF_NUMBER#k#' = Evaluate('attributes.SHELF_NUMBER_#k#')>
   	</cfloop>
    <cfset attributes.process_cat = attributes.process_cat_id>
    <cf_get_lang_set module_name="stock">
    <cfinclude template="/v16/stock/query/check_our_period.cfm"> 
    <cfinclude template="/v16/stock/query/get_process_cat.cfm">
    <cfset attributes.fis_type = get_process_type.PROCESS_TYPE> 
    <!--- kontroller  & tanimlamalar --->
    <cfinclude template="/v16/stock/query/add_ship_fis_1.cfm">
    <!---  // kontroller & tanimlamalar --->
    
    <cflock name="#CreateUUID()#" timeout="60">
        <cftransaction>
            <cfinclude template="/v16/stock/query/add_ship_fis_2.cfm">
            <cfif isdefined("attributes.rows_")>
                <cfinclude template="/v16/stock/query/add_ship_fis_3.cfm">
                <cfinclude template="/v16/stock/query/add_ship_fis_4.cfm">
            <cfelse>
                <cfquery name="ADD_STOCK_FIS_ROW" datasource="#dsn2#">
                    INSERT INTO STOCK_FIS_ROW (FIS_NUMBER,FIS_ID) VALUES (<cfqueryparam cfsqltype="cf_sql_varchar" value="#FIS_NO#">,#GET_ID.MAX_ID#)
                </cfquery>
            </cfif>
            <!---Ek Bilgiler--->
            <cfset attributes.info_id = GET_ID.MAX_ID>
            <cfset attributes.is_upd = 0>
            <cfset attributes.info_type_id=-22>
            <cfinclude template="/v16/objects/query/add_info_plus2.cfm">
            <!---Ek Bilgiler--->
             <!---secilen islem kategorisine bir action file eklenmisse --->
                <cf_workcube_process_cat 
                    process_cat="#attributes.process_cat#"
                    action_id = "#GET_ID.MAX_ID#"
                    action_table="STOCK_FIS"
                    action_column="FIS_ID"
                    is_action_file = 1
                    action_page='#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.form_upd_fis&upd_id=#GET_ID.MAX_ID#'
                    action_file_name='#get_process_type.action_file_name#'
                    action_db_type = '#dsn2#'
                    is_template_action_file = '#get_process_type.action_file_from_template#'>
        </cftransaction>
    </cflock>
    <cfquery name="UPD_GEN_PAP" datasource="#DSN3#">
        UPDATE 
            GENERAL_PAPERS
        SET
            STOCK_FIS_NUMBER = #system_paper_no_add#
        WHERE
            STOCK_FIS_NUMBER IS NOT NULL
    </cfquery>
    <!---Ambar Fişi--->
</cfif>
<cfif not isdefined("attributes.is_mobile")>
	<script type="text/javascript">
    	window.location.href="<cfoutput>#request.self#?fuseaction=pda.pda_welcome</cfoutput>";
  	</script>
<cfelse>
 	<cflocation url="#request.self#?fuseaction=pda.pda_welcome" addtoken="No">
</cfif>
<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#"> <!---sayfanin en ustunde acilisi var --->

