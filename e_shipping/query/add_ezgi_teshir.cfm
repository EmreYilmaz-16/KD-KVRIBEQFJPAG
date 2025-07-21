<cfquery name="GET_ROW" datasource="#DSN3#">
	SELECT ORDER_ROW_ID FROM EZGI_ORDER_TESHIR WHERE ORDER_ROW_ID = #attributes.order_row_id#
</cfquery>
<cfif not GET_ROW.recordcount>
    <cfquery name="ADD_ROW" datasource="#DSN3#">
        INSERT INTO
            EZGI_ORDER_TESHIR
            (
                ORDER_ROW_ID
            )
        VALUES
            (
            #attributes.order_row_id#
            )
    </cfquery>
</cfif>
<cflocation url="#request.self#?fuseaction=sales.popup_list_order_internal_rate&order_id=#attributes.order_id#" addtoken="no">