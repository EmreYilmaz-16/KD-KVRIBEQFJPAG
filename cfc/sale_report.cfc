<cfcomponent>
    <cffunction name="saveOrderData" access="remote" returnType="string" returnFormat="json">
        <cfset var result = {}>
        
        <cftry>
            <!--- JSON verisini al ve parse et --->
            <cfset var httpData = getHttpRequestData()>
            <cfset var requestData = deserializeJSON(httpData.content)>
            <cfdump var="#requestData#" label="Received Data">
            <cfdump var="#httpData#" label="HTTP Data">
            <!--- Her bir sipariş için kayıt oluştur --->
            <cfloop array="#requestData.orderData#" index="item">
                <cfif val(item.miktar) GT 0>
                    <cfset var orderID = createUUID()>
                    
                    <cfquery datasource="w3Qa_1" result="insertResult">
                        INSERT INTO w3Qa_1.orders_sepet_pbs (order_id, product_id, quantity, user_id, order_date)
                        VALUES (
                            '#orderID#',
                            #val(item.pid)#,
                            #val(item.miktar)#,
                            #val(requestData.user_id)#,
                            GETDATE()
                        )
                    </cfquery>
                    <cfdump var="#insertResult#" label="Insert Result for Product ID #item.pid#">
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