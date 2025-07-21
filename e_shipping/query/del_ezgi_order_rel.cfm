<cfif attributes.type eq 2 or attributes.type eq 1>
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
    <cfquery name="DEL_ROW" datasource="#DSN3#">
        DELETE
            PRODUCTION_ORDERS_ROW
        WHERE
            PRODUCTION_ORDER_ID IN (#p_order_id_list#) AND
            ORDER_ID = #attributes.order_id# AND
            ORDER_ROW_ID = #attributes.order_row_id# 
    </cfquery>
<cfelseif attributes.type eq 4>
	<cfquery name="DEL_ROW" datasource="#DSN3#">
        DELETE 
            EZGI_ORDERS_ORDERS_REL
        WHERE     
            S_ORDER_ID = #attributes.order_id# AND
            S_ORDER_ROW_ID = #attributes.order_row_id#
  	</cfquery>
<cfelseif attributes.type eq 3>
	<cfquery name="DEL_ROW" datasource="#DSN3#">
    	UPDATE    
        	ORDER_ROW
		SET              
        	WRK_ROW_RELATION_ID = NULL
		WHERE     
        	ORDER_ROW_ID =
                      	(
                        SELECT     
                        	ORDER_ROW_1.ORDER_ROW_ID
                       	FROM          
                        	ORDER_ROW AS ORDER_ROW_2 INNER JOIN
                         	ORDER_ROW AS ORDER_ROW_1 ON ORDER_ROW_2.WRK_ROW_ID = ORDER_ROW_1.WRK_ROW_RELATION_ID
                    	WHERE      
                        	ORDER_ROW_2.ORDER_ROW_ID = #attributes.order_row_id#
                      	)
  	</cfquery>    
</cfif>
<cflocation url="#request.self#?fuseaction=sales.popup_list_order_production_rate&order_id=#attributes.order_id#" addtoken="no">
