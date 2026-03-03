<cfcomponent>
    <cffunction name="saveOrderData" access="remote" returnType="string" returnFormat="json">
        <cfargument name="orderData" type="struct" required="true">
        
        <cfset var result = {}>
        
        <cftry>
            <cfset var orderID = createUUID()>
            
            <cfquery datasource="w3Qa_1">
                INSERT INTO w3Qa_1.orders_sepet_pbs (order_id, product_id, quantity, order_date)
                VALUES (
                    '#orderID#',
                    #arguments.orderData.productID#,
                    #arguments.orderData.quantity#,
                    NOW()
                )
            </cfquery>
            
            <cfset result.success = true>
            <cfset result.message = "Kayıt başarıyla oluşturuldu">
            <cfset result.orderID = orderID>
            
            <cfcatch type="any">
                <cfset result.success = false>
                <cfset result.message = "Hata oluştu: " & cfcatch.message>
                <cfset result.detail = cfcatch.detail>
            </cfcatch>
        </cftry>
        
        <cfreturn serializeJSON(result)>
    </cffunction>
</cfcomponent>