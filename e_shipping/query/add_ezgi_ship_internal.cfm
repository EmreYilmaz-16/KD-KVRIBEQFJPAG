<cf_get_lang_set module_name="stock">
<cfif ListLen(session.ep.USER_LOCATION,'-') neq 3>
	<script type="text/javascript">
		alert("<cfoutput>#getLang('main',3141)#</cfoutput>!");
		window.close()
	</script>
	<cfabort>
<cfelse>
	<cfset attributes.dept_out = ListgetAt(session.ep.USER_LOCATION,1,'-')>
	<cfset attributes.loc_out = ListgetAt(session.ep.USER_LOCATION,3,'-')>
</cfif>
<cfset attributes.process_stage = 52><!---Firmaya Göre değişir--->

<cfquery name="get_order_det" datasource="#dsn3#">
	SELECT
    	CASE
       		WHEN O.COMPANY_ID IS NOT NULL THEN
                   (
                    SELECT     
                      	NICKNAME
					FROM         
                    	#dsn_alias#.COMPANY
					WHERE     
                   		COMPANY_ID = O.COMPANY_ID
                  	)
        	WHEN O.CONSUMER_ID IS NOT NULL THEN      
                   	(	
                  	SELECT     
                     	CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
					FROM         
                      	#dsn_alias#.CONSUMER
					WHERE     
                		CONSUMER_ID = O.CONSUMER_ID
               		)
         	WHEN O.EMPLOYEE_ID IS NOT NULL THEN
                  	(
                   	SELECT     
                    	EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS ISIM
					FROM         
                  		#dsn_alias#.EMPLOYEES
					WHERE     
                     	EMPLOYEE_ID = O.EMPLOYEE_ID
                 	)
      	END AS ADI,     
    	O.ORDER_ID, 
        ORR.ORDER_ROW_ID, 
        O.ORDER_NUMBER, 
        O.PROJECT_ID, 
        O.DELIVER_DEPT_ID, 
        O.LOCATION_ID, 
        O.DELIVERDATE,
		O.ORDER_DETAIL, 
        ORR.STOCK_ID, 
        ORR.PRODUCT_ID, 
        ORR.PRODUCT_NAME, 
        ORR.UNIT, 
        ORR.UNIT_ID, 
        ORR.TAX, 
        ORR.DELIVER_DATE, 
        ORR.SPECT_VAR_ID, 
        ORR.SPECT_VAR_NAME, 
        ORR.WRK_ROW_ID, 
        ORR.DELIVER_DEPT, 
        ORR.DELIVER_LOCATION, 
        ORR.QUANTITY, 
        ORR.LOT_NO, 
        ORR.PRODUCT_NAME2
	FROM         
    	ORDERS AS O INNER JOIN
        ORDER_ROW AS ORR ON O.ORDER_ID = ORR.ORDER_ID 
	WHERE     
    	O.ORDER_ID = #attributes.order_id# AND 
        ORR.ORDER_ROW_ID IN (#attributes.order_row_id_list#)
</cfquery>
<cfset attributes.deliverdate = Dateformat(get_order_det.deliverdate,'dd/mm/yyyy')>
<cf_date tarih = 'attributes.deliverdate' > 
<cflock name="#CreateUUID()#" timeout="60">
  <cftransaction>
	<cfquery name="ADD_SALE" datasource="#DSN2#" result="MAX_ID">
		INSERT INTO
			SHIP_INTERNAL
		(
			SHIP_DATE,
			DELIVER_DATE,
            DELIVER_EMP,
			PROCESS_STAGE,
			DEPARTMENT_OUT,
			LOCATION_OUT,
			DEPARTMENT_IN,
			LOCATION_IN,
			DETAIL,
			RECORD_DATE,
			RECORD_EMP
		)
		VALUES
		(
        	#now()#,
            #attributes.deliverdate#,
            #session.ep.userid#,
			#attributes.process_stage#,
			#attributes.dept_out#,
			#attributes.loc_out#,
			#get_order_det.DELIVER_DEPT_ID#,
			#get_order_det.LOCATION_ID#,
			'#get_order_det.ORDER_NUMBER# #get_order_det.ADI# #get_order_det.ORDER_DETAIL#' ,
			#now()#,
			#session.ep.userid#
		)
	</cfquery>
	<cfloop query="get_order_det">
    	<cfset attributes.deliver_date = get_order_det.deliver_date>
    	<cf_date tarih = 'attributes.deliver_date' > 
	 	<cfquery name="ADD_SHIP_ROW" datasource="#DSN2#">
			INSERT INTO
				SHIP_INTERNAL_ROW
			(
				NAME_PRODUCT,
				DISPATCH_SHIP_ID,
				STOCK_ID,
				PRODUCT_ID,
				AMOUNT,
				UNIT,
				UNIT_ID,
				TAX,
				DELIVER_DATE,
				DELIVER_DEPT,
				DELIVER_LOC,
				SPECT_VAR_ID,
				SPECT_VAR_NAME,
				LOT_NO,
				PRODUCT_NAME2,
                PRICE,
                PRICE_OTHER,
                OTHER_MONEY_VALUE,
                OTHER_MONEY,
                ROW_ORDER_ID,
				BASKET_EXTRA_INFO_ID
			)
			VALUES
			(
				'#left(PRODUCT_NAME,250)#',
				#MAX_ID.IDENTITYCOL#,
				#STOCK_ID#,
				#product_id#,
				#QUANTITY#,
				'#UNIT#',
				#UNIT_ID#,
				#tax#,
                #attributes.deliver_date#,
				#DELIVER_DEPT#,
				#DELIVER_LOCATION#,
				<cfif len(SPECT_VAR_ID)>#SPECT_VAR_ID#<cfelse>NULL</cfif>,
				'#SPECT_VAR_NAME#',
				'#LOT_NO#',
				'#PRODUCT_NAME2#',
                0,
                0,
                0,
                'TL',
                #ORDER_ROW_ID#,
                -1
			)
		</cfquery>
	</cfloop>
	<cfquery name="add_order_ship_internal" datasource="#dsn2#">
    	INSERT INTO 
        	#dsn3_alias#.EZGI_ORDERS_SHIP_INTERNAL
     		(
            ORDER_ID, 
            SHIP_INTERNAL_ID, 
            PERIOD_ID
            )
		VALUES     
        	(
            #attributes.order_id#,
            #MAX_ID.IDENTITYCOL#,
            #session.ep.period_id#
            )
    </cfquery>
	<cf_workcube_process
		is_upd='1' 
		data_source='#dsn2#' 
		old_process_line='0'
		process_stage='#attributes.process_stage#' 
		record_member='#session.ep.userid#' 
		record_date='#now()#' 
		action_table='SHIP_INTERNAL'
		action_column='DISPATCH_SHIP_ID'
		action_id='#MAX_ID.IDENTITYCOL#'
		action_page='index.cfm?fuseaction=stock.upd_dispatch_internaldemand&ship_id=#MAX_ID.IDENTITYCOL#' 
		warning_description='#getLang("stock",348)# : #MAX_ID.IDENTITYCOL#'>
  </cftransaction>
</cflock>
<cflocation url="#request.self#?fuseaction=stock.add_dispatch_internaldemand&event=upd&ship_id=#MAX_ID.IDENTITYCOL#" addtoken="no">
<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#"><!--- sayfanin en ustunde acilisi var --->