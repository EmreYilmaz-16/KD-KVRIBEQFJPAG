<cfcomponent>
    <cffunction name="saveOrderData" access="remote" returnType="string" returnFormat="json">
        <cfset var result = {}>
        
        <cftry>
            <!--- JSON verisini al ve parse et --->
            <cfset var httpData = getHttpRequestData()>
            <cfset var requestData = deserializeJSON(httpData.content)>
            <cfquery name="delp" datasource="w3Qa_1">
                DELETE FROM w3Qa_1.orders_sepet_pbs WHERE user_id = #val(requestData.user_id)# and is_converted = 0
            </cfquery>
            <!--- Her bir sipariş için kayıt oluştur --->
            <cfloop array="#requestData.orderData#" index="item">
                <cfif val(item.miktar) GT 0>
                    <cfset var orderID = createUUID()>
                    
                    <cfquery datasource="w3Qa_1" result="insertResult">
                        INSERT INTO w3Qa_1.orders_sepet_pbs (order_id, product_id, quantity, user_id, order_date,is_converted)
                        VALUES (
                            '#orderID#',
                            #val(item.pid)#,
                            #val(item.miktar)#,
                            #val(requestData.user_id)#,
                            GETDATE(),
                            0
                        )
                    </cfquery>
                    
                </cfif>
            </cfloop>
            
            <cfset result.success = true>
            <cfset result.message = "Sipariş miktarları başarıyla kaydedildi">
            
            <cfcatch type="any">
                <cfset result.success = false>
                <cfset result.message = "Hata oluştu: " & cfcatch.message>
                <cfset result.detail = cfcatch.detail>
            </cfcatch>
        </cftry>
        
        <cfreturn serializeJSON(result)>
    </cffunction>
</cfcomponent>