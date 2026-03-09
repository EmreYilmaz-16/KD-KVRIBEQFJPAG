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
                        INSERT INTO w3Qa_1.orders_sepet_pbs (order_id, product_id, quantity,  user_id, order_date,is_converted,IS_FOREIGN)
                        VALUES (
                            '#orderID#',
                            #val(item.pid)#,
                            #val(item.miktar)#,                           
                            #val(requestData.user_id)#,
                            GETDATE(),
                            0,
                            0
                        )
                    </cfquery>
                    
                </cfif>
                 <cfif val(item.yurtdisi_miktar) GT 0>
                    <cfset var orderID = createUUID()>
                    
                    <cfquery datasource="w3Qa_1" result="insertResult">
                        INSERT INTO w3Qa_1.orders_sepet_pbs (order_id, product_id, quantity,  user_id, order_date,is_converted,IS_FOREIGN)
                        VALUES (
                            '#orderID#',
                            #val(item.pid)#,
                            #val(item.yurtdisi_miktar)#,                           
                            #val(requestData.user_id)#,
                            GETDATE(),
                            0,
                            1
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
                <CFSET dsn=requestData.dataSources.dsn>
                <CFSET dsn2=requestData.dataSources.dsn2>
<CFSET dsn1=requestData.dataSources.dsn1>
             <cfquery name="getMoneyext" datasource="#dsn3#">
            SELECT 
                SM.MONEY,
                (SELECT TOP 1 RATE1 FROM #dsn#.MONEY_HISTORY WHERE MONEY = SM.MONEY ORDER BY MONEY_HISTORY_ID DESC) AS RATE1,
                (SELECT TOP 1 EFFECTIVE_SALE FROM #dsn#.MONEY_HISTORY WHERE MONEY = SM.MONEY ORDER BY MONEY_HISTORY_ID DESC) AS RATE2
            FROM #dsn#.SETUP_MONEY AS SM
            WHERE SM.PERIOD_ID = <cfqueryparam value="#session.ep.period_id#" cfsqltype="cf_sql_integer">
        </cfquery>
       <cfset var kurMap = structNew()>
        <cfloop query="getMoneyext">
            <cfset kurMap[getMoneyext.MONEY] = {
                RATE1 = getMoneyext.RATE1,
                RATE2 = getMoneyext.RATE2
            }>
        </cfloop>
<cfquery name="getSelectedRows" datasource="#dsn3#">
    select *, 1053 COMPANY_ID,3475 AS PARTNER_ID,IS_FOREIGN from orders_sepet_pbs WHERE user_id = #val(requestData.user_id)# AND is_converted = 0
</cfquery>

        <cfloop query="getSelectedRows" group="IS_FOREIGN">
            <cfset var ix = 0>
            <cfset var rows_ = 0>
            <cfset var BASKET_NET_TOTAL = 0>
            <cfset var BASKET_NET_TOTAL_ = 0>
            <cfset var BASKET_TAX_TOTAL = 0>
            <cfset var BASKET_TAX_TOTAL_ = 0>
            <cfset var nowTS = now()>
    
            <!--- Ürünleri dön --->
            <cfloop >
                <cfquery name="getSid" datasource="w3Qa_1">
                    SELECT PR.PRICE,PR.MONEY,S.PRODUCT_ID,S.STOCK_ID,S.PRODUCT_NAME,S.TAX,PU.MAIN_UNIT AS UNIT,S.PRODUCT_UNIT_ID AS UNIT_ID  FROM w3Qa_1.STOCKS  AS S
                    LEFT JOIN w3Qa_1.PRODUCT_UNIT AS PU ON PU.PRODUCT_ID=S.PRODUCT_ID AND IS_MAIN=1
                    OUTER APPLY (
        SELECT TOP 1 
            PR.PRICE, 
            PR.MONEY, 
            PR.STARTDATE
        FROM w3Qa_1.PRICE AS PR 
        WHERE PR.PRODUCT_ID = S.PRODUCT_ID
            AND PR.PRICE_CATID = 7
            AND GETDATE() >= PR.STARTDATE 
            AND (PR.FINISHDATE IS NULL OR GETDATE() <= PR.FINISHDATE)
        ORDER BY PR.STARTDATE DESC
    ) AS PR
                    
                    WHERE S.PRODUCT_ID = #val(getSelectedRows.product_id)# 
                </cfquery>
               
                <cfif 1 eq 1>
                    <cfset ix++>
                    <cfset otherMoney = getSid.MONEY>
                    <cfset satirKur = structKeyExists(kurMap, otherMoney) ? kurMap[otherMoney] : {RATE1=1, RATE2=1}>
                    <cfif len(getSid.PRICE) EQ 0>
                        <cfset PRRICE = 0>
                    <cfelse>
                        <cfset PRRICE = getSid.PRICE>
                    </cfif>
    
                    <cfset PRICE_OTHER = PRRICE>
                    <cfset PRICE = PRRICE*satirKur.RATE2>
                    <cfset AMOUNT = getSelectedRows.quantity>
                    <cfset TAX = getSid.TAX>
                    <cfset DISCOUNT = 0>
                    <cfset PR_HESAP = PRICE_OTHER * satirKur.RATE2>
    
                    <cfset dp = PRICE - ((PRICE * DISCOUNT) / 100)>
                    <cfset dp_ = PR_HESAP - ((PR_HESAP * DISCOUNT) / 100)>
                    <cfset TUTAR = dp * AMOUNT>
                    <cfset TUTAR_ = dp_ * AMOUNT>
                    <cfset TX = (TUTAR * TAX) / 100>
                    <cfset TX_ = (TUTAR_ * TAX) / 100>
    
                    <!--- Toplamları güncelle --->
                    <cfset BASKET_TAX_TOTAL += TX>
                    <cfset BASKET_TAX_TOTAL_ += TX_>
                    <cfset BASKET_NET_TOTAL += TUTAR + TX>
                    <cfset BASKET_NET_TOTAL_ += TUTAR_ + TX_>
    
                    <!--- Attributes içine yerleştir --->
                    <cfset attributes["product_id#ix#"] = getSid.PRODUCT_ID>
                    <cfset attributes["stock_id#ix#"] = getSid.STOCK_ID>
                    <cfset attributes["product_name#ix#"] = getSid.PRODUCT_NAME>
                    <cfset attributes["unit#ix#"] = getSid.UNIT>
                    <cfset attributes["unit_id#ix#"] = getSid.UNIT_ID>
                    <cfset attributes["price#ix#"] = PR_HESAP>
                    <cfset attributes["price_other#ix#"] = PRICE_OTHER>
                    <cfset attributes["tax#ix#"] = TAX>
                    <cfset attributes["amount#ix#"] = AMOUNT>
                    <cfset attributes["indirim1#ix#"] = DISCOUNT>
                    <cfset attributes["other_money_#ix#"] = otherMoney>
                    <cfset attributes["other_money_value_#ix#"] = TUTAR_ / satirKur.RATE2>
                    <cfset attributes["description#ix#"] = "">
                    <cfset attributes["wrk_row_id#ix#"] = "PBS#session.ep.userid##dateFormat(nowTS, 'yyyymmdd')##timeFormat(nowTS, 'hhmmssL')#_#ix#">
                    <cfset attributes["wrk_row_relation_id#ix#"] = "#getSelectedRows.order_id#">
                    <CFSET attributes["row_nettotal#ix#"] = PR_HESAP*AMOUNT>
                </cfif>
            </cfloop>
            
    


            <!--- Sepetteki ürünleri al --->
            <cfquery name="getCartItems" datasource="w3Qa_1">
                SELECT product_id, quantity, yurtdisi_miktar
                FROM w3Qa_1.orders_sepet_pbs 
                WHERE user_id = #val(requestData.user_id)# 
                AND is_converted = 0
                AND quantity > 0
            </cfquery>
             <cfset attributes.rows_ = ix>
    
            <!--- Şirket Bilgilerini Ekle --->
            <cfquery name="GETCOMPANY" datasource="#dsn#">
                SELECT ISNULL(NULLIF(COMPANY_ADDRESS, ''), '-') AS COMPANY_ADDRESS, CITY, COUNTY
                FROM COMPANY
                WHERE COMPANY_ID = <cfqueryparam value="#getSelectedRows.COMPANY_ID#" cfsqltype="cf_sql_integer">
            </cfquery>
    
            <cfset attributes.company_id = getSelectedRows.COMPANY_ID>
            <cfset attributes.PARTNER_ID = getSelectedRows.PARTNER_ID>
            <cfset attributes.CONSUMER_ID ="">
<cfset attributes.CONSUMER_NAME ="">
            <cfset attributes.ORDER_HEAD = "Siparişimiz">
            <cfset attributes.ORDER_DESCRIPTION = "">
            <cfset attributes.ORDER_DETAIL = "">
            <cfset attributes.order_date = nowTS>
            <cfset attributes.deliverdate = dateAdd("m",2,nowTS)>
            <cfset attributes.PUBLISHDATE = nowTS>
            <cfset attributes.SHIP_METHOD_ID = 2>
            <cfset attributes.SHIP_METHOD = "kargo">
    
            <cfset attributes.BASKET_NET_TOTAL = BASKET_NET_TOTAL_>
            <cfset attributes.BASKET_TAX_TOTAL = BASKET_TAX_TOTAL_>
            <cfset attributes.BASKET_GROSS_TOTAL = BASKET_NET_TOTAL_ - BASKET_TAX_TOTAL_>
            <cfset attributes.BASKET_DISCOUNT_TOTAL = 0>
            <cfset attributes.PRICE = BASKET_NET_TOTAL_>
    
            <cfset attributes.ACTIVE_COMPANY = session.ep.company_id>
            <cfset attributes.DELIVER_DEPT_ID = 13>
            <cfset attributes.DELIVER_LOC_ID = 5>
            <cfset attributes.DELIVER_DEPT_NAME = "ASDASD2">
            <cfset attributes.BASKET_MONEY = "TL">
            <cfset attributes.BASKET_RATE1 = 1>
            <cfset attributes.BASKET_RATE2 = 1>
            <cfset attributes.kur_say = getMoneyext.recordCount>
            <!---<cfset attributes.internaldemand_id_list = "">--->
            <cfset attributes.process_stage = "259">
    
            <!--- Kur bilgilerini tekrar setle --->
            <cfset i=1>
            <cfloop query="getMoneyext" >
                <cfset attributes["txt_rate1_#i#"] = RATE1>
                <cfset attributes["txt_rate2_#i#"] = RATE2>
                <cfset attributes["hidden_rd_money_#i#"] = MONEY>
                <cfset attributes["_hidden_rd_money_#i#"] = MONEY>
                <cfset i=i+1>
            </cfloop>
    
            <!--- Kağıt numarası üret --->
            <cfquery name="get_offer_number" datasource="#dsn3#">
                EXEC GET_PAPER_NUMBER 1
            </cfquery>
            <cfset attributes.PAPER_NO = get_offer_number.PAPER_NO>
    
            <!--- Siparişi oluştur --->
            <cfinclude template="/AddOns/Partner/purchase/query/add_order_nd.cfm">
            
             
            
<!------
    <cfset ORDER_ID_PBS=000>
<cfdump var="#attributes#" label="ORDER ATTRIBUTES">
<cfdump var="#getCartItems#" label="SELECTED ROWS">----->



            <cfif getCartItems.recordCount GT 0>
                <!--- Ana sipariş kaydı oluştur (ORDERS tablosuna) --->
                <cfset var mainOrderID = createUUID()>
                
                <!--- TODO: Burada asıl sipariş sisteminize uygun tabloya kayıt yapın --->
                <!--- Örnek: w3Qa_1.ORDERS tablosuna --->
                
                <!--- Sepetteki kayıtları converted olarak işaretle --->
                <cfquery datasource="w3Qa_1" result="updateResult">
                    UPDATE w3Qa_1.orders_sepet_pbs 
                    SET is_converted = 1,
                        converted_date = GETDATE(),
                        converted_order_id = '#ORDER_ID_PBS#'
                    WHERE user_id = #val(requestData.user_id)# 
                    AND is_converted = 0
                    AND IS_FOREIGN = #getSelectedRows.IS_FOREIGN#
                </cfquery>
                
                
                <cfset result.success = true>
                <cfset result.message = "Sipariş başarıyla oluşturuldu (#getCartItems.recordCount# ürün)">
                <cfset result.orderID = ORDER_ID_PBS>
            <cfelse>
                <cfset result.success = false>
                <cfset result.message = "Sepette ürün bulunamadı">
            </cfif>
    <!--- Temizle --->
            <cfscript>
                structClear(attributes);
            </cfscript>

        </cfloop>
            
            <cfcatch type="any">
                <cfdump var="#cfcatch#">
                <cfset result.success = false>
                <cfset result.message = "Hata oluştu: " & cfcatch.message>
                <cfset result.detail = cfcatch.detail>
            </cfcatch>
        </cftry>
        
        <cfreturn serializeJSON(result)>
    </cffunction>
    <cffunction name="rezerveEklePartner">
   <cfargument name="process_db">
   <cfargument name="is_purchase_sales">
   <cfargument name="reserve_order_id">
   <cfquery name="ADD_ORDER_ROW_RESERVED" datasource="#arguments.process_db#" result="Res">
        DECLARE @RetryCounter INT
        SET @RetryCounter = 1
        RETRY:
        BEGIN TRY
            INSERT INTO
                #arguments.process_db#.ORDER_ROW_RESERVED
            (
                STOCK_ID,
                PRODUCT_ID,
                SPECT_VAR_ID,
                ORDER_ID,
                <cfif arguments.is_purchase_sales eq 1>
                    RESERVE_STOCK_OUT,
                <cfelse>
                    RESERVE_STOCK_IN,
                </cfif>
                SHELF_NUMBER,
                ORDER_WRK_ROW_ID,
                DEPARTMENT_ID,
                LOCATION_ID		
            )
            SELECT
                ORDER_ROW.STOCK_ID,
                ORDER_ROW.PRODUCT_ID,
                ORDER_ROW.SPECT_VAR_ID,
                ORDER_ROW.ORDER_ID,
                ORDER_ROW.QUANTITY,
                ORDER_ROW.SHELF_NUMBER,
                ORDER_ROW.WRK_ROW_ID,
                ISNULL(ORDER_ROW.DELIVER_DEPT,ORDERS.DELIVER_DEPT_ID),
                ISNULL(ORDER_ROW.DELIVER_LOCATION,ORDERS.LOCATION_ID)
            FROM 
                #arguments.process_db#.ORDER_ROW ORDER_ROW,
                #arguments.process_db#.ORDERS ORDERS
            WHERE
                ORDERS.ORDER_ID=ORDER_ROW.ORDER_ID
                AND ORDERS.ORDER_ID= #arguments.reserve_order_id#
        END TRY
        BEGIN CATCH
            DECLARE @DoRetry bit; 
            DECLARE @ErrorMessage varchar(500)
            SET @doRetry = 0;
            SET @ErrorMessage = ERROR_MESSAGE()
            IF ERROR_NUMBER() = 1205 
            BEGIN
                SET @doRetry = 1; 
            END
            IF @DoRetry = 1
            BEGIN
                SET @RetryCounter = @RetryCounter + 1
                IF (@RetryCounter > 3)
                BEGIN
                    RAISERROR(@ErrorMessage, 18, 1) -- Raise Error Message if 
                END
                ELSE
                BEGIN
                    WAITFOR DELAY '00:00:00.05' 
                    GOTO RETRY	
                END
            END
            ELSE
            BEGIN
                RAISERROR(@ErrorMessage, 18, 1)
            END
        END CATCH
    </cfquery>
    
</cffunction>
</cfcomponent>