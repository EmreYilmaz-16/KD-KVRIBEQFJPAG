<cfif attributes.type eq 1>
	<cfquery name="get_info" datasource="#dsn3#">
    	SELECT     
        	FINISH_DATE
		FROM         
        	PRODUCTION_ORDERS
		WHERE     
        	P_ORDER_ID = #attributes.p_order_id#
    </cfquery>
    <cfquery name="get_p_order_id" datasource="#dsn3#">
    	SELECT     
        	P_ORDER_ID
		FROM         
        	PRODUCTION_ORDERS
		WHERE     
        	LOT_NO = (
            			SELECT     
                        	LOT_NO
                       	FROM          
                        	PRODUCTION_ORDERS AS PRODUCTION_ORDERS_1
                    	WHERE      
                        	P_ORDER_ID = #attributes.p_order_id#
                  	)
    </cfquery>
    <cfset p_order_id_list = Valuelist(get_p_order_id.P_ORDER_ID)>
    <cfloop list="#p_order_id_list#" index="i">
        <cfquery name="ADD_ROW" datasource="#DSN3#">
            INSERT INTO
                PRODUCTION_ORDERS_ROW
                (
                PRODUCTION_ORDER_ID,
                ORDER_ID,
                ORDER_ROW_ID,
                TYPE 
                )
            VALUES
                (
                #i#,
                #attributes.order_id#,
                #attributes.order_row_id#,
                2
                )
        </cfquery>
   	</cfloop>
<cfelse>
	<cfquery name="get_info" datasource="#dsn3#">
    	SELECT     
        	ORDER_ID,
            QUANTITY,
           	DELIVER_DATE FINISH_DATE
		FROM         
        	ORDER_ROW
		WHERE     
        	ORDER_ROW_ID = #attributes.P_ORDER_ID#
    </cfquery>
    <cfquery name="GET_S_ROW_INFO" datasource="#DSN3#">
    	SELECT     
        	QUANTITY, 
            WRK_ROW_ID
		FROM         
        	ORDER_ROW
		WHERE     
        	ORDER_ROW_ID = #attributes.order_row_id#
    </cfquery>
    <cfif get_info.QUANTITY eq GET_S_ROW_INFO.QUANTITY>
    	<cfquery name="upd_p_order_row" datasource="#dsn3#">
        	UPDATE    
            	ORDER_ROW
			SET              
            	WRK_ROW_RELATION_ID = '#GET_S_ROW_INFO.WRK_ROW_ID#'
			WHERE     
            	ORDER_ROW_ID = #attributes.p_order_id# AND 
                QUANTITY = #GET_S_ROW_INFO.QUANTITY#
        </cfquery>
    <cfelse>
        <cfquery name="ADD_ROW" datasource="#DSN3#">
            INSERT INTO 
                EZGI_ORDERS_ORDERS_REL
                (
                P_ORDER_ID, 
                P_ORDER_ROW_ID, 
                S_ORDER_ROW_ID, 
                S_ORDER_ID, 
                RECORD_DATE, 
                RECORD_IP, 
                RECORD_EMP
                )
            VALUES
                (
                #get_info.ORDER_ID#,
                #attributes.p_order_id#,
                #attributes.order_row_id#,
                #attributes.order_id#,
                #now()#,
                '#CGI.REMOTE_ADDR#',
                #session.ep.userid#
                )
        </cfquery>
   	</cfif>
</cfif>

<cflocation url="#request.self#?fuseaction=sales.popup_list_order_production_rate&order_id=#attributes.order_id#" addtoken="no">