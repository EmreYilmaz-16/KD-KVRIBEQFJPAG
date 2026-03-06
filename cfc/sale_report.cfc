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
                        INSERT INTO w3Qa_1.orders_sepet_pbs (order_id, product_id, quantity, yurtdisi_miktar, user_id, order_date,is_converted)
                        VALUES (
                            '#orderID#',
                            #val(item.pid)#,
                            #val(item.miktar)#,
                            #val(item.ymiktar)#,
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

    <cffunction name="createOrder" access="remote" returnType="string" returnFormat="json">
        <cfset var result = {}>
        
        <cftry>
            <!--- JSON verisini al ve parse et --->
            <cfset var httpData = getHttpRequestData()>
            <cfset var requestData = deserializeJSON(httpData.content)>
            <CFSET session=requestData.session>
            <CFSET dsn3=requestData.dataSources.dsn3>
             <cfquery name="getMoneyext" datasource="#dsn3#">
            SELECT 
                SM.MONEY,
                (SELECT TOP 1 RATE1 FROM #dsn#.MONEY_HISTORY WHERE MONEY = SM.MONEY ORDER BY MONEY_HISTORY_ID DESC) AS RATE1,
                (SELECT TOP 1 EFFECTIVE_SALE FROM #dsn#.MONEY_HISTORY WHERE MONEY = SM.MONEY ORDER BY MONEY_HISTORY_ID DESC) AS RATE2
            FROM #dsn#.SETUP_MONEY AS SM
            WHERE SM.PERIOD_ID = <cfqueryparam value="#session.ep.period_id#" cfsqltype="cf_sql_integer">
        </cfquery>
    


            <!--- Sepetteki ürünleri al --->
            <cfquery name="getCartItems" datasource="w3Qa_1">
                SELECT product_id, quantity, yurtdisi_miktar
                FROM w3Qa_1.orders_sepet_pbs 
                WHERE user_id = #val(requestData.user_id)# 
                AND is_converted = 0
                AND quantity > 0
            </cfquery>
            
            <cfif getCartItems.recordCount GT 0>
                <!--- Ana sipariş kaydı oluştur (ORDERS tablosuna) --->
                <cfset var mainOrderID = createUUID()>
                
                <!--- TODO: Burada asıl sipariş sisteminize uygun tabloya kayıt yapın --->
                <!--- Örnek: w3Qa_1.ORDERS tablosuna --->
                
                <!--- Sepetteki kayıtları converted olarak işaretle --->
                <cfquery datasource="w3Qa_1">
                    UPDATE w3Qa_1.orders_sepet_pbs 
                    SET is_converted = 1,
                        converted_date = GETDATE(),
                        converted_order_id = '#mainOrderID#'
                    WHERE user_id = #val(requestData.user_id)# 
                    AND is_converted = 0
                </cfquery>
                
                <cfset result.success = true>
                <cfset result.message = "Sipariş başarıyla oluşturuldu (#getCartItems.recordCount# ürün)">
                <cfset result.orderID = mainOrderID>
            <cfelse>
                <cfset result.success = false>
                <cfset result.message = "Sepette ürün bulunamadı">
            </cfif>
            
            <cfcatch type="any">
                <cfset result.success = false>
                <cfset result.message = "Hata oluştu: " & cfcatch.message>
                <cfset result.detail = cfcatch.detail>
            </cfcatch>
        </cftry>
        
        <cfreturn serializeJSON(result)>
    </cffunction>
</cfcomponent>