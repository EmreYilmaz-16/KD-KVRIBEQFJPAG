<cfdump var="#attributes#">
<cfif isdefined("attributes.dep_in") and listlen(attributes.dep_in) eq 2>
    <cfset attributes.dep_in=listgetat(attributes.dep_in,1)>
</cfif>
<cfif isdefined("attributes.dep_out") and listlen(attributes.dep_out) eq 2>
    <cfset attributes.dep_out=listgetat(attributes.dep_out,1)>
</cfif>
<cfif attributes.process_cat eq "90fuseaction=pda.add_ambar_fis,90">
    <cfset attributes.process_cat=90>
</cfif>
<cfset current_row_list = ''>
<cfset stock_id_list = ''>
<cfset form.process_cat = attributes.process_cat>
POZİSYON=BENİM DÖNGÜM
<cfloop from="1" to="#attributes.ROW_COUNT#" index="i">
<!----<cfloop -- list="#attributes.action_id#" index="i">---->
	<cfset current_row_list = ListAppend(current_row_list,i,",")>
    <cfset stock_id_list = ListAppend(stock_id_list,evaluate("attributes.STOCKID#i#"))>
    <cfset 'STOCK_ID_#i#' = evaluate("attributes.STOCKID#i#")>
    <cfset 'STOCK_ID#i#' = evaluate("attributes.STOCKID#i#")>
    <cfset 'AMOUNT_#i#' = evaluate("attributes.AMOUNT#i#")> 
     <cfset SHELF_ID_IN="">
    <cfset SHELF_ID_OUT="">   
      <cfset SHELF_CODE_IN="">
    <cfset SHELF_CODE_OUT="">  
    <CFSET "SHELF_CODE_IN__#i#"="">
    <CFSET "SHELF_CODE_OUT__#i#"=""> 
    <cfif isDefined("attributes.change_shelf_fis")>
        <cfset SHELF_CODE_IN= evaluate("attributes.SHELF_CODE_IN#i#")>
        <cfset SHELF_CODE_OUT= evaluate("attributes.SHELF_CODE_OUT#i#")>
        <cfquery name="get_shelf_id" datasource="#dsn3#">
            SELECT PRODUCT_PLACE_ID FROM PRODUCT_PLACE WHERE SHELF_CODE = '#SHELF_CODE_IN#'
        </cfquery>
        <CFSET SHELF_ID_IN= get_shelf_id.PRODUCT_PLACE_ID>
        <CFSET "SHELF_CODE_IN__#i#"= SHELF_ID_IN>        
        <cfquery name="get_shelf_id" datasource="#dsn3#">
            SELECT PRODUCT_PLACE_ID FROM PRODUCT_PLACE WHERE SHELF_CODE = '#SHELF_CODE_OUT#' 
        </cfquery>
        <CFSET SHELF_ID_OUT= get_shelf_id.PRODUCT_PLACE_ID>
        <CFSET "SHELF_CODE_OUT__#i#"= SHELF_ID_OUT>
    <cfelse>
        <cfif isDefined("attributes.tersfis") and attributes.tersfis eq 1>
            <cfset SHELF_CODE_IN= "">
            <CFSET SHELF_CODE_OUT= evaluate("attributes.SHELF_CODE#i#")>
            <cfquery name="get_shelf_id" datasource="#dsn3#">
                SELECT        
                    PRODUCT_PLACE_ID
                FROM            
                    PRODUCT_PLACE
                WHERE        
                    SHELF_CODE = '#SHELF_CODE_OUT#'
            </cfquery>
        <CFSET SHELF_ID_OUT= get_shelf_id.PRODUCT_PLACE_ID>
           <CFSET "SHELF_CODE_IN__#i#"="">
    <CFSET "SHELF_CODE_OUT__#i#"="#SHELF_ID_OUT#"> 
        <cfelse>
            <cfset SHELF_CODE_IN= evaluate("attributes.SHELF_CODE#i#")>
            <CFSET SHELF_CODE_OUT= "">
        <cfquery name="get_shelf_id" datasource="#dsn3#">
            SELECT        
                PRODUCT_PLACE_ID
            FROM            
                PRODUCT_PLACE
            WHERE        
                SHELF_CODE = '#SHELF_CODE_IN#'
        </cfquery>
        <CFSET SHELF_ID_IN= get_shelf_id.PRODUCT_PLACE_ID>
        <CFSET "SHELF_CODE_IN__#i#"="#SHELF_ID_IN#">
        <CFSET "SHELF_CODE_OUT__#i#"=""> 
        </cfif>
    </cfif>
    
    
    

  <cfif isdefined('attributes.change_shelf_fis')> <!---Raf Değiştirme Fişinden Geliyorsa--->
        	<cfset 'attributes.SHELF_NUMBER#k#' = SHELF_ID_OUT>  
          	<cfset 'attributes.SHELF_NUMBER_TXT#k#' = SHELF_CODE_OUT> 
           	<cfset 'attributes.TO_SHELF_NUMBER#k#' = SHELF_ID_IN>  
          	<cfset 'attributes.TO_SHELF_NUMBER_TXT#k#' = SHELF_CODE_IN>
        <cfelse>
			<cfif isdefined('attributes.tersfis')> <!---Ambardan Mal Kabule Fişinden Geliyorsa--->
                <cfset 'attributes.SHELF_NUMBER#k#' = SHELF_ID_OUT>  
                <cfset 'attributes.SHELF_NUMBER_TXT#k#' = SHELF_CODE_OUT > 
                <cfset 'attributes.TO_SHELF_NUMBER#k#' = ''>  
                <cfset 'attributes.TO_SHELF_NUMBER_TXT#k#' = ''>
            <cfelse> <!---Mal Kabulden Ambara Fişinden Geliyorsa--->
                <cfset 'attributes.SHELF_NUMBER#k#' = ''>  
                <cfset 'attributes.SHELF_NUMBER_TXT#k#' = ''> 
                <cfset 'attributes.TO_SHELF_NUMBER#k#' = SHELF_ID_IN >  
                <cfset 'attributes.TO_SHELF_NUMBER_TXT#k#' = SHELF_CODE_IN>
            </cfif>
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
            S.STOCK_ID = #Evaluate('STOCK_ID_#i#')#
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
                                	STOCK_ID = #Evaluate('STOCK_ID_#i#')#
                          	)
    </cfquery>
    <cfoutput query="GET_LOT_K_KONT_ID">
    	<cfset 'PRODUCT_UNIT_ID_#i#' = GET_LOT_K_KONT_ID.PRODUCT_UNIT_ID>
        <cfset 'MAIN_UNIT_#i#' = GET_LOT_K_KONT_ID.MAIN_UNIT>
        <cfset 'PRICE_#i#' = GET_LOT_K_KONT_ID.PRICE>
        <cfset 'MONEY_#i#' = GET_LOT_K_KONT_ID.MONEY>
        <cfset 'BARCOD_#i#' = GET_LOT_K_KONT_ID.BARCOD>
        <cfset 'TAX_#i#' = GET_LOT_K_KONT_ID.TAX>
        <cfset 'PRODUCT_ID_#i#' = GET_LOT_K_KONT_ID.PRODUCT_ID>
        <cfset 'PRODUCT_NAME_#i#' = GET_LOT_K_KONT_ID.PRODUCT_NAME>
        <cfset 'STOCK_CODE_#i#' = GET_LOT_K_KONT_ID.STOCK_CODE>
    </cfoutput>
    <cfif get_spect.recordcount>
		<cfoutput query="get_spect">
            <cfset 'SPECT_ID#i#' = get_spect.SPECT_VAR_ID>
            <cfset 'SPECT_NAME#i#' = get_spect.SPECT_VAR_NAME>
        </cfoutput>
    <cfelse>
    	<cfset 'SPECT_ID#i#' = ''>
        <cfset 'SPECT_NAME#i#' = ''>
    </cfif>
</cfloop>
<cfset session.ep.our_company_info.is_cost = 1><!---Dikkat Firmaya Göre Değişir--->

<br>current row list 
POZİSYON=SATIRLAR 
<cfdump var="#current_row_list#">
<br>
<cfif ListLen(current_row_list)>
    <cf_papers paper_type="stock_fis">
    <cfif isdefined("paper_full") and isdefined("paper_number")>
        <cfset system_paper_no = paper_full>
    <cfelse>
        <cfset system_paper_no = "">

    </cfif>
    POZİSYON=STANDART FİŞ
    <cfdump  var="#system_paper_no#">
    <cfset attributes.ROWS_ = listlen(stock_id_list)>
    <cfset attributes.FIS_DATE_H = hour(now())>
    <cfset attributes.FIS_DATE_M = minute(now())>
    <cfset attributes.DEPARTMENT_OUT = Listgetat(attributes.dep_out,1,'-')>
    <cfset attributes.LOCATION_OUT = Listgetat(attributes.dep_out,2,'-')> 
    <cfset attributes.DEPARTMENT_IN = Listgetat(attributes.dep_in,1,'-')>
    <cfset attributes.LOCATION_IN = Listgetat(attributes.dep_in,2,'-')> 
    <cfset attributes.ACTIVE_PERIOD = session.ep.period_id>
    <cfset attributes.EMPLOYEE_ID = session.ep.userid>
    <cfset attributes.DETAIL = ''> 
    <cfset attributes.BASKET_DISCOUNT_TOTAL = 0>
    <cfset attributes.BASKET_EMPLOYEE1 = ''>  
    <cfset attributes.BASKET_EMPLOYEE_ID1 = ''> 
    <cfset attributes.BASKET_EXTRA_INFO1 = -1>  
    <cfset attributes.BASKET_GROSS_TOTAL = 0>  
    <cfset attributes.BASKET_ID = 12> 
    <cfset attributes.BASKET_MEMBER_PRICECAT = '' > 
    <cfset attributes.BASKET_MONEY = 'TL'>
    <cfset attributes.BASKET_NET_TOTAL = 0>  
    <cfset attributes.BASKET_OTV_1 = 0> 
    <cfset attributes.BASKET_OTV_COUNT = 1>  
    <cfset attributes.BASKET_OTV_FROM_TAX_PRICE = 0>
    <cfset attributes.BASKET_OTV_TOTAL = 0>
    <cfset attributes.BASKET_OTV_VALUE_1 = 0>
    <cfset attributes.BASKET_TAX_1 = 0>
    <cfset attributes.BASKET_TAX_VALUE_1 = 0>
    <cfset attributes.BASKET_PRICE_ROUND_NUMBER = 4>  
    <cfset attributes.BASKET_RATE1 = 1>
    <cfset attributes.BASKET_RATE2 = 1> 
    <cfset attributes.BASKET_RATE_ROUND_NUMBER_ =4>
    <cfset attributes.BASKET_SPECT_TYPE =0> 
    <cfset attributes.BASKET_TOTAL_ROUND_NUMBER_ = 2>
    <cfset attributes.BASKET_TAX_COUNT = 1>  
    <cfset attributes.BASKET_TAX_TOTAL = 0> 
    <cfset attributes.COMPANY_ID = ''>  
    <cfset attributes.CONSUMER_ID = ''> 
    <cfset attributes.CONTROL_FIELD_VALUE =-1>
    <cfset attributes.HIDDEN_RD_MONEY_1 = 'TL' >
    <cfset attributes.EXTRA_COST_RATE =''> 
    <cfset attributes.FIS_DATE = Dateformat(now(),'dd/mm/yyyy')>
    <cfset attributes.FIS_NO_ = system_paper_no> 
    <cfset FIS_NO_ = system_paper_no>
    <cfset attributes.INDIRIM_TOTAL = 0>
    <cfset attributes.INTERNALDEMAND_ID_LIST = ''>
    <cfset attributes.IS_BASKET_HIDDEN = 0>  
    <cfset attributes.IS_GENERAL_PROM = 0> 
    <cfset attributes.KUR_SAY = 1> 
    <cfset attributes.MEMBER_NAME = get_emp_info(session.ep.userid,0,0)>  
    <cfset attributes.MEMBER_TYPE = 'employee'>  
    <cfset attributes.OLD_GENERAL_PROM_AMOUNT = ''>  
    <cfset attributes.OTHER_MONEY_VALUE_1 = 0> 
    <cfset attributes.OTHER_MONEY_1 = 'TL'>
    <cfset attributes.PARTNER_ID = ''>  
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
    <cfset attributes.SEARCH_PROCESS_DATE = 'fis_date'>
    <cfset attributes.SERVICE_ID = ''>  
    <cfset attributes.SERVICE_NAME = ''>
    <cfset attributes.TODAY_DATE_ = now()>
    <cfset attributes.TXT_RATE1_1 = 1>
    <cfset attributes.TXT_RATE2_1 =1>  
    <cfset attributes.USE_BASKET_PROJECT_DISCOUNT_ = 0>   
    <cfset attributes.WORK_HEAD = 0>  
    <cfset attributes.WORK_ID = 0> 
    <cfset attributes.WRK_SUBMIT_BUTTON = 'Kaydet'> 
    <cfset attributes.X_COST_ACC = 1>
    <cfset BASKET_KUR_EKLE = 0>
    <cfset 	attributes.XML_MULTIPLE_COUNTING_FIS =1>
    POZİSYON=STANDART ROW DÖNGÜSÜ
    <cfloop list="#current_row_list#" index="k">
    	<cfset 'attributes.UNIT#k#' = Evaluate('MAIN_UNIT_#k#')>
        <cfset 'attributes.UNIT_ID#k#' = Evaluate('PRODUCT_UNIT_ID_#k#') > 
        <cfset 'attributes.STOCK_CODE#k#' = Evaluate('STOCK_CODE_#k#') > 
        <cfset 'attributes.STOCK_ID#k#' = Evaluate('STOCK_ID_#k#') >  
        <cfset 'attributes.PRODUCT_ID#k#' = Evaluate('PRODUCT_ID_#k#') > 
        <cfset 'attributes.PRODUCT_NAME#k#' = Evaluate('PRODUCT_NAME_#k#') > 
        <cfset 'attributes.AMOUNT#k#' = Evaluate('AMOUNT_#k#')>
        <cfset 'attributes.AMOUNT_OTHER#k#' = Evaluate('AMOUNT_#k#')>
        <cfset 'attributes.ACTION_ROW_ID#k#' = 0>
        <cfset 'attributes.BARCOD#k#' = Evaluate('BARCOD_#k#') >
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
        <cfset 'attributes.ROW_PAYMETHOD_ID#k#' = ''>  
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
        <!-----<cfif isdefined('attributes.change_shelf_fis')> <!---Raf Değiştirme Fişinden Geliyorsa--->
        	<cfset 'attributes.SHELF_NUMBER#k#' = Evaluate('SHELF_ID_#k#')>  
          	<cfset 'attributes.SHELF_NUMBER_TXT#k#' = Evaluate('SHELF_#k#')> 
           	<cfset 'attributes.TO_SHELF_NUMBER#k#' = Evaluate('SHELF_OTHER_ID_#k#')>  
          	<cfset 'attributes.TO_SHELF_NUMBER_TXT#k#' = Evaluate('SHELF_OTHER_#k#')>
        <cfelse>
			<cfif isdefined('attributes.tersfis')> <!---Ambardan Mal Kabule Fişinden Geliyorsa--->
                <cfset 'attributes.SHELF_NUMBER#k#' = Evaluate('SHELF_ID_#k#')>  
                <cfset 'attributes.SHELF_NUMBER_TXT#k#' = Evaluate('SHELF_#k#')> 
                <cfset 'attributes.TO_SHELF_NUMBER#k#' = ''>  
                <cfset 'attributes.TO_SHELF_NUMBER_TXT#k#' = ''>
            <cfelse> <!---Mal Kabulden Ambara Fişinden Geliyorsa--->
                <cfset 'attributes.SHELF_NUMBER#k#' = ''>  
                <cfset 'attributes.SHELF_NUMBER_TXT#k#' = ''> 
                <cfset 'attributes.TO_SHELF_NUMBER#k#' = Evaluate('SHELF_ID_#k#') >  
                <cfset 'attributes.TO_SHELF_NUMBER_TXT#k#' = Evaluate('SHELF_#k#')>
            </cfif>
       	</cfif>------>
        <cfset 'attributes.SPECIAL_CODE#k#' = ''>  
        <cfset 'attributes.SPECT_ID#k#' = Evaluate('SPECT_ID#k#')>  
        <cfset 'attributes.TAX_PRICE#k#' = ''>  
        <cfset 'attributes.UNIT_OTHER#k#' = ''>  
        <cfset 'attributes.WRK_ROW_RELATION_ID#k#' = ''>
        <cfset 'attributes.TAX#k#' = 0>
        <cfset 'attributes.SPECT_NAME#k#' = Evaluate('SPECT_NAME#k#')>
    	<cfset 'attributes.WRK_ROW_ID#k#' = 'EZG'&#DateFormat(Now(),'YYYYMMDD')# & #TimeFormat(Now(),'HHmmssL')#>
    </cfloop>
    POZİSYON=SERVİS İMPORT EDİLDİ
    <cfset svc = createObject("component", "AddOns.Partner.cfc.service_guaranty")>
    <cfloop list="#current_row_list#" index="k">
        <cfset WRK_ROW_ID_SER=evaluate('attributes.WRK_ROW_ID#k#')>
        <cfset STOCK_ID_SER=evaluate('attributes.STOCK_ID#k#') >
        <cfset SERI_NO_SER=evaluate('attributes.serino#k#') >
    
        
        <cfset GIRIS_RAF_ID=Evaluate('SHELF_CODE_IN__#k#')>
        <cfset CIKIS_RAF_ID=Evaluate('SHELF_CODE_OUT__#k#')>
        
        <cfdump var="GIRIS_RAF_ID=#GIRIS_RAF_ID# ----- CIKIS_RAF_ID=#CIKIS_RAF_ID#">
        
        <cfquery name="GETSER" datasource="#DSN3#">
            SELECT * FROM w3qa_1.SERVICE_GUARANTY_NEW WHERE SERIAL_NO='#SERI_NO_SER#'
        </cfquery>
        <cfif isdefined('attributes.change_shelf_fis')>
        
        <cfset data = {STOCK_ID = STOCK_ID_SER,SERIAL_NO = "#SERI_NO_SER#",LOT_NO = "#GETSER.LOT_NO#",IN_OUT = 0,PROCESS_CAT = 113,PROCESS_ID = 0,PROCESS_NO = "",PERIOD_ID = #session.ep.period_id#,DEPARTMENT_ID = attributes.DEPARTMENT_OUT,LOCATION_ID = attributes.LOCATION_OUT,IS_SARF = 0,IS_SERI_SONU = 0,WRK_ID = "#WRK_ROW_ID_SER#-#createUUID()#",WRK_ROW_ID = "#WRK_ROW_ID_SER#",UNIT_ROW_QUANTITY = 1,SHELF_NUMBER = "#CIKIS_RAF_ID#"}>
            <cfdump var="#data#">
        <cfset data2 = {STOCK_ID = STOCK_ID_SER,SERIAL_NO = "#SERI_NO_SER#",LOT_NO = "#GETSER.LOT_NO#",IN_OUT = 1,PROCESS_CAT = 113,PROCESS_ID = 0,PROCESS_NO = "",PERIOD_ID = session.ep.period_id,DEPARTMENT_ID = attributes.DEPARTMENT_IN,LOCATION_ID = attributes.LOCATION_IN,IS_SARF = 0,IS_SERI_SONU = 0,WRK_ID = "#WRK_ROW_ID_SER#-#createUUID()#",WRK_ROW_ID = "#WRK_ROW_ID_SER#",UNIT_ROW_QUANTITY = 1,SHELF_NUMBER = "#GIRIS_RAF_ID#"}>
        <cfdump var="#data2#">
    <cfelse>
      
      <cfif isdefined('attributes.tersfis')>
        <cfset data = {STOCK_ID = STOCK_ID_SER,SERIAL_NO = "#SERI_NO_SER#",LOT_NO = "#GETSER.LOT_NO#",IN_OUT = 0,PROCESS_CAT = 113,PROCESS_ID = 0,PROCESS_NO = "",PERIOD_ID = #session.ep.period_id#,DEPARTMENT_ID = attributes.DEPARTMENT_OUT,LOCATION_ID = attributes.LOCATION_OUT,IS_SARF = 0,IS_SERI_SONU = 0,WRK_ID = "#WRK_ROW_ID_SER#-#createUUID()#",WRK_ROW_ID = "#WRK_ROW_ID_SER#",UNIT_ROW_QUANTITY = 1,SHELF_NUMBER = "#CIKIS_RAF_ID#"}>
        <cfset data2 = {STOCK_ID = STOCK_ID_SER,SERIAL_NO = "#SERI_NO_SER#",LOT_NO = "#GETSER.LOT_NO#",IN_OUT = 1,PROCESS_CAT = 113,PROCESS_ID = 0,PROCESS_NO = "",PERIOD_ID = session.ep.period_id,DEPARTMENT_ID = attributes.DEPARTMENT_IN,LOCATION_ID = attributes.LOCATION_IN,IS_SARF = 0,IS_SERI_SONU = 0,WRK_ID = "#WRK_ROW_ID_SER#-#createUUID()#",WRK_ROW_ID = "#WRK_ROW_ID_SER#",UNIT_ROW_QUANTITY = 1,SHELF_NUMBER = ""}>
      <cfelse>      
        <cfset data = {STOCK_ID = STOCK_ID_SER,SERIAL_NO = "#SERI_NO_SER#",LOT_NO = "#GETSER.LOT_NO#",IN_OUT = 0,PROCESS_CAT = 113,PROCESS_ID = 0,PROCESS_NO = "",PERIOD_ID = #session.ep.period_id#,DEPARTMENT_ID = attributes.DEPARTMENT_OUT,LOCATION_ID = attributes.LOCATION_OUT,IS_SARF = 0,IS_SERI_SONU = 0,WRK_ID = "#WRK_ROW_ID_SER#-#createUUID()#",WRK_ROW_ID = "#WRK_ROW_ID_SER#",UNIT_ROW_QUANTITY = 1,SHELF_NUMBER = ""}>
        <cfset data2 = {STOCK_ID = STOCK_ID_SER,SERIAL_NO = "#SERI_NO_SER#",LOT_NO = "#GETSER.LOT_NO#",IN_OUT = 1,PROCESS_CAT = 113,PROCESS_ID = 0,PROCESS_NO = "",PERIOD_ID = session.ep.period_id,DEPARTMENT_ID = attributes.DEPARTMENT_IN,LOCATION_ID = attributes.LOCATION_IN,IS_SARF = 0,IS_SERI_SONU = 0,WRK_ID = "#WRK_ROW_ID_SER#-#createUUID()#",WRK_ROW_ID = "#WRK_ROW_ID_SER#",UNIT_ROW_QUANTITY = 1,SHELF_NUMBER = "#GIRIS_RAF_ID#"}>
      </cfif>
    </cfif>
<!---------
    <cfset attributes.DEPARTMENT_OUT = Listgetat(attributes.dep_out,1,'-')>
    <cfset attributes.LOCATION_OUT = Listgetat(attributes.dep_out,2,'-')> 
    <cfset attributes.DEPARTMENT_IN = Listgetat(attributes.dep_in,1,'-')>
    <cfset attributes.LOCATION_IN = Listgetat(attributes.dep_in,2,'-')> 
    
    
    ----------->
<cfset recordEmp = session.ep.userid>


<cfset result = svc.saveServiceGuaranty(data, recordEmp)>
<cfset result2 = svc.saveServiceGuaranty(data2, recordEmp)><!-------->

<cfdump var="#result#">
<cfif result>
    <cfoutput>Kayıt başarılı!</cfoutput>
<cfelse>

    <cfoutput>Kayıt sırasında bir hata oluştu.</cfoutput>
</cfif>

    </cfloop>

    FSDFSDF


<cfinclude template="/v16/stock/query/add_ship_fis_pbs.cfm">
<cfquery name="UP" datasource="#DSN3#">
    UPDATE SERVICE_GUARANTY_NEW SET PROCESS_NO='#PBS_FIS_NO#',PROCESS_ID=#PBS_FIS_ID# WHERE PROCESS_ID=0;
</cfquery>

<cfabort>
	<cflocation url="#request.self#?fuseaction=pda.form_add_ambar_fis" addtoken="No">

</cfif>
