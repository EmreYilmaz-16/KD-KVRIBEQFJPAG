<!-----
/**
 * PurchaseService Component
 * Handles purchase-related operations.
 *
 * Functions:
 * 1. savePurchaseOfferSelector
 *    - Saves selected purchase offers.
 *    - Access: Remote
 *    - Return Type: Struct (JSON)
 *    - HTTP Method: POST
 *    - Parameters:
 *        - payload: JSON payload containing purchase offer data.
 *    - Returns: A response struct with success or error details.
 *
 * 2. savePurchaseOfferSelectorOnly
 *    - Saves selected purchase offers without additional processing.
 *    - Access: Remote
 *    - Return Type: Struct (JSON)
 *    - HTTP Method: POST
 *    - Parameters:
 *        - payload: JSON payload containing purchase offer data.
 *    - Returns: A response struct with success or error details.
 *
 * 3. getByProductId
 *    - Retrieves alternative product IDs for a given product ID.
 *    - Access: Remote
 *    - Return Type: Array (JSON)
 *    - HTTP Method: POST
 *    - Parameters:
 *        - product_id: String (Required) - The ID of the product.
 *    - Returns: An array of alternative product IDs.
 *
 * 4. savePurchaseOffer
 *    - Saves purchase offers based on provided payload.
 *    - Access: Remote
 *    - Return Type: Struct (JSON)
 *    - HTTP Method: POST
 *    - Parameters:
 *        - payload: JSON payload containing purchase offer data.
 *    - Returns: A response struct with success or error details.
 *
 * Notes:
 * - The component uses multiple database queries to process and save purchase offers.
 * - Error handling is implemented using <cftry> and <cfcatch>.
 * - Logs are written to the "purchaseService" log file for debugging and error tracking.
 */
------>
<cfcomponent displayname="PurchaseService" output="false" hint="Handles purchase-related operations">
    <cfset dsn3="w3Qa_1">
    <cfset dsn="w3Qa">
    <cfset wrk_eval = application.functions.wrk_eval>

    <cffunction name="savePurchaseOfferSelector" access="remote" returntype="struct" output="false" hint="Saves selected purchase offers" returnFormat="json" httpMethod="POST">
        <cfset var response = {}>
        <cfset arguments.payload = getHTTPRequestData().content>

        <cftry>
            <!-- Deserialize JSON payload if it's a string -->
            <cfif isJSON(arguments.payload)>
                <cfset arguments.payload = deserializeJSON(arguments.payload)>
            </cfif>

            <!-- Validate payload -->
            <cfif NOT isStruct(arguments.payload)>
                <cfthrow message="Payload is invalid or missing." type="ValidationError">
            </cfif>

            <!-- Extract offers from payload -->
            <cfset var offers = arguments.payload>
            <cfset session=offers.session_variables>
            <!-- Log the payload for debugging -->
            <cflog file="purchaseService" text="Received payload: #serializeJSON(offers)#" type="information">

            
            <!-- Process each offer -->
            <cfset ix=0>
            <cfloop array="#offers.payload#" item="offer">
                <cfset var products = offer.products>

                <!-- Process each product -->
                <cfloop array="#products#" item="product">
                    <!-- Delete existing rows for the product -->
                    <cfquery name="DEL" datasource="#dsn3#">
                        DELETE FROM PBS_SELECTED_ROWS WHERE WRK_ROW_ID = '#product.wrkRowId#'
                    </cfquery>

                    <!-- Insert new rows for the product -->
                    <cfquery name="INS" datasource="#dsn3#">
                        INSERT INTO PBS_SELECTED_ROWS (
                            WRK_ROW_ID,
                            PRICE,
                            OFFER_ID,
                            PRODUCT_MARJ,
                            SALE_PRICE
                        )
                        VALUES (
                            '#product.wrkRowId#',
                            #product.netPrice#,
                            #offers.offer_id#,
                            #product.productMarj#,
                            #product.salePrice#
                        )
                    </cfquery>
                    <cfquery name="getStockInfo" datasource="#dsn3#">
                        SELECT * FROM STOCKS WHERE STOCK_ID=#product.stockId#
                    </cfquery>
                      <cfquery name="getUnit" datasource="#dsn3#">
                        select PRODUCT_UNIT_ID,MAIN_UNIT from #dsn3#.PRODUCT_UNIT where PRODUCT_ID=#product.productId#
                    </cfquery>
                    <cfscript>
                        ix=ix+1;
                        attributes["price#ix#"] = product.salePrice;
                        attributes["price_other#ix#"] = product.convertedsalePriceOther;
                        attributes["tax#ix#"] = product.tax;
                        attributes["amount#ix#"] = product.quantity;
                        attributes["indirim1#ix#"] = product.discount1;
                        attributes["other_money_#ix#"] = product.otherMoney;
                        attributes["product_id#ix#"] = product.productId;
                        attributes["stock_id#ix#"] = product.stockId;
                        attributes["unit#ix#"] = getUnit.MAIN_UNIT;
                        attributes["unit_id#ix#"] = getUnit.PRODUCT_UNIT_ID;
                        attributes["product_name#ix#"] = product.productName;
                        attributes["other_money_value_#ix#"] = (product.convertedsalePriceOther * product.quantity) - ((product.convertedsalePriceOther * product.quantity) * product.discount1) / 100;
                        attributes["description#ix#"] = "";
                        attributes["wrk_row_id#ix#"] = "PBS#session.ep.userid##dateFormat(now(), 'yyyymmdd')##timeFormat(now(), 'hhmmnnl')#";
                        attributes["wrk_row_relation_id#ix#"] = product.wrkRowId;
                        attributes["is_virtual#ix#"] = 0;
                        attributes["SHELF_CODE#ix#"] = "";
                        attributes["OFFER_ROW_CURRENCY#ix#"] = "";
                        
                    </cfscript>
                </cfloop>
            </cfloop>
            <cfset attributes.rows_=ix>
            <!-- Retrieve related internal demand data -->
            <cfquery name="GETIDEMAND" datasource="#dsn3#">
                SELECT FROM_COMPANY_ID,FROM_PARTNER_ID,
                (select MONEY_TYPE, CAST(RATE2 AS DECIMAL(18,2)) AS RATE2,CAST(RATE1 AS DECIMAL(18,2)) AS RATE1 FROM w3Qa_1.INTERNALDEMAND_MONEY  WHERE ACTION_ID=INTERNAL_ID AND IS_SELECTED=1 FOR JSON PATH) AS PARA
                FROM w3Qa_1.INTERNALDEMAND
                WHERE INTERNAL_ID =#offers.offer_id#
            </cfquery>
            <cfset IDEMAND.PARA=deserializeJSON(GETIDEMAND.PARA)>


            <cfset FORM.ACTIVE_COMPANY=session.ep.company_id>
            <cfset ATTRIBUTES.ACTIVE_COMPANY=session.ep.company_id>
            <cfset MONEYARRRR=arrayNew(1)>
            <cfquery name="getMoneyext" datasource="#dsn3#">
                SELECT 
             (SELECT RATE1 FROM #dsn#.MONEY_HISTORY WHERE MONEY_HISTORY_ID=(
             SELECT MAX(MONEY_HISTORY_ID) FROM #dsn#.MONEY_HISTORY WHERE MONEY=SM.MONEY) )AS RATE1,
             (SELECT EFFECTIVE_SALE RATE2 FROM #dsn#.MONEY_HISTORY WHERE MONEY_HISTORY_ID=(
             SELECT MAX(MONEY_HISTORY_ID) FROM #dsn#.MONEY_HISTORY WHERE MONEY=SM.MONEY) )AS RATE2,
             SM.MONEY
             FROM #dsn#.SETUP_MONEY AS SM WHERE SM.PERIOD_ID=#session.ep.period_id#
             </cfquery>
             <cfset ibnm=1>
    <cfloop query="getMoneyext">
        <cfset "attributes._hidden_rd_money_#ibnm#"=MONEY>


        <cfset "attributes.hidden_rd_money_#ibnm#"=MONEY>
        <cfset "attributes._txt_rate1_#ibnm#"=RATE1>
        <cfset "attributes._txt_rate2_#ibnm#"=RATE2>
        <cfset "attributes.txt_rate1_#ibnm#"=RATE1>
        <cfset "attributes.txt_rate2_#ibnm#"=RATE2>
          
        <cfscript>
            arrayAppend(MONEYARRRR,{MONEY=MONEY,RATE1=RATE1,RATE2=RATE2})
        </cfscript>
        <cfset ibnm=ibnm+1>
    </cfloop>
    <cfset attributes.KUR_SAY=arrayLen(MONEYARRRR)>

<cfset attributes.offer_date=now()>
<cfset attributes.deliverdate=now()>
<cfset attributes.ship_date=now()>
<cfset attributes.finishdate=now()>
<cfset attributes.member_name=GETIDEMAND.FROM_COMPANY_ID>
<cfset attributes.OFFER_DESCRIPTION="">
<cfset attributes.company_id=GETIDEMAND.FROM_COMPANY_ID>
<cfset attributes.partner_id=GETIDEMAND.FROM_PARTNER_ID>
<cfset FactPBS="purchase.purchase_offer_selector">
<cfset attributes.company_id=GETIDEMAND.FROM_COMPANY_ID>
<cfset attributes.member_id=GETIDEMAND.FROM_PARTNER_ID>
<cfset attributes.price_catid="">
<cfset attributes.sales_emp_id=session.ep.userid>
<cfset attributes.sales_emp="#session.ep.NAME# #session.ep.SURNAME#">
<cfset attributes.project_head="">
<cfset attributes.project_id="">
<cfset attributes.process_stage="20">
<cfquery name="getcc" datasource="#dsn#">
    select SHIP_METHOD_ID,REVMETHOD_ID,MONEY from w3Qa.COMPANY_CREDIT where COMPANY_ID=#GETIDEMAND.FROM_COMPANY_ID# and OUR_COMPANY_ID=#session.ep.company_id#    
</cfquery>
<cfquery name="GETCOMPANY" datasource="#dsn#">
  select CASE WHEN LEN(COMPANY_ADDRESS)=0 THEN '-'ELSE ISNULL(COMPANY_ADDRESS,'-') END AS COMPANY_ADDRESS,CITY,COUNTY from w3Qa.COMPANY WHERE COMPANY_ID=#GETIDEMAND.FROM_COMPANY_ID#
</cfquery>
<cfset attributes.paymethod_id=getcc.REVMETHOD_ID>
<cfset attributes.PAYMETHOD=getcc.REVMETHOD_ID>
<cfset attributes.ship_method_id=getcc.SHIP_METHOD_ID>
<cfset attributes.ship_method=getcc.SHIP_METHOD_ID>
<cfset attributes.pay_method=getcc.REVMETHOD_ID>
<cfset attributes.card_paymethod_id="">

<cfset attributes.ship_address=GETCOMPANY.COMPANY_ADDRESS>
<cfset attributes.ship_address_id=-1>
<cfset attributes.city_id=GETCOMPANY.CITY>
<cfset attributes.county_id=GETCOMPANY.COUNTY>

<CFSET attributes.ship_address_city_id=GETCOMPANY.CITY>
<CFSET attributes.ship_address_county_id=GETCOMPANY.COUNTY>

<cfset attributes.commission_rate="">

<cfset attributes.sales_add_option="">
<cfset attributes.offer_head="Teklifimiz">
<cfset attributes.offer_detail="">
<cfset attributes.offer_detail="">
<cfset attributes.basket_money=getcc.MONEY>
<cfset attributes.basket_rate1=IDEMAND.PARA[1].RATE1>
<cfset attributes.basket_rate2=IDEMAND.PARA[1].RATE2>
<cfset attributes.ref_member_type ="">
<cfset attributes.consumer_id="">
<cfset attributes.reserved=1>


<cfscript>
    DISCOUNT_TOTAL=0;
    GROSS_TOTAL=0;
    SUBNETTOTAL=0;
    SUBTAXTOTAL=0;
    SUBTOTAL=0;
    TAX_TOTAL=0;
    TOTAL_WITHOUT_KDV=0;
    TOTAL_WITH_KDV=0;
    BASKET_NET_TOTAL=0;
    BASKET_NET_TOTAL_=0;
    BASKET_TAX_TOTAL=0;
    BASKET_TAX_TOTAL_=0;
</cfscript>
<CFLOOP from="1" to="#attributes.rows_#" index="ix">
    <cfset PRICE=evaluate("attributes.price#ix#")>
    <cfset PRICE_OTHER=evaluate("attributes.price_other#ix#")>
    <cfset TAX=evaluate("attributes.tax#ix#")>
    <CFSET AMOUNT=evaluate("attributes.amount#ix#")>
    <CFSET DISCOUNT=evaluate("attributes.indirim1#ix#")>
    <CFSET OTHER_MONEY=evaluate("attributes.other_money_#ix#")>
    <cfscript>
     SATIR_KUR= arrayFilter(MONEYARRRR, function(item) {
            return item.MONEY == OTHER_MONEY;
        })[1];
    OLD_SATIR_KUR= SATIR_KUR;
    </cfscript>

    <CFSET PR_HESAP=PRICE_OTHER*SATIR_KUR.RATE2>
    <cfset ox=structNew()>
    <cfset ox.PRICE=PRICE>
    <cfset ox.PRICE_=PR_HESAP>
    <cfscript>
        dp=PRICE-(PRICE*DISCOUNT)/100;  
        dp_=PR_HESAP-(PR_HESAP*DISCOUNT)/100;                    

        TUTAR=dp*AMOUNT;
        TUTAR_=dp_*AMOUNT;

        TX=(TUTAR*TAX)/100
        TX_=(TUTAR_*TAX)/100
        ox.DP=dp;
        ox.DP_=dp_;
        ox.TUTAR=TUTAR;
        ox.TUTAR_=TUTAR_;
        OX.OTM_V=TUTAR/OLD_SATIR_KUR.RATE2;
        OX.OTM_V_=TUTAR_/SATIR_KUR.RATE2;
        ox.TX=TX;
        ox.TX_=TX_;
        BASKET_TAX_TOTAL=BASKET_TAX_TOTAL+TX;
        BASKET_TAX_TOTAL_=BASKET_TAX_TOTAL_+TX_;
        BASKET_NET_TOTAL=BASKET_NET_TOTAL+(TUTAR+TX);
        BASKET_NET_TOTAL_=BASKET_NET_TOTAL_+(TUTAR_+TX_);

        "attributes.other_money_value_#ix#"=ox.OTM_V_;
        "attributes.price#ix#"=ox.PRICE_;
    </cfscript>
    


    



</CFLOOP>


<cfquery name="get_offer_number" datasource="#dsn3#">
    EXEC GET_PAPER_NUMBER 1
</cfquery>
<cfset paper_fulbs=get_offer_number.PAPER_NO>
<cfset attributes.BASKET_TAX_TOTAL=BASKET_TAX_TOTAL_>
<cfset attributes.BASKET_NET_TOTAL=BASKET_NET_TOTAL_>
<cfset attributes.PRICE=BASKET_NET_TOTAL_>
<cfset workcube_mode=0>
<cfinclude template="../query/add_offer.cfm">

<cfquery name="DELREL" datasource="#dsn3#">
DELETE FROM w3Qa_1.PURCHAE_OFFER_SALE_OFFER_RELATION_PBS WHERE  PURCHASE_OFFER_ID=#offers.offer_id#
</cfquery>

<cfquery name="INSREL" datasource="#dsn3#">
INSERT INTO w3Qa_1.PURCHAE_OFFER_SALE_OFFER_RELATION_PBS(
    SALE_OFFER_ID,
   PURCHASE_OFFER_ID
)
VALUES(    
    #get_max_offer.max_id#,
    #offers.offer_id#
)
</cfquery>

            <!-- Set success response -->
            <cfset response.res = "success">
            <cfset response.message = "Purchase offers saved successfully.">
            <cfset response.data = attributes>
        <cfcatch>
            <!-- Handle errors -->
            <cfset response.res = "error">
            <cfset response.message = cfcatch>
            <cflog file="purchaseService" text="Error: #cfcatch.message#" type="error">
        </cfcatch>
        </cftry>

        <cfreturn response>
    </cffunction>

    <cffunction name="savePurchaseOfferSelectorOnly" access="remote" returntype="struct" output="false" hint="Saves selected purchase offers" returnFormat="json" httpMethod="POST">
        <cfset var response = {}>
        <cfset arguments.payload = getHTTPRequestData().content>

        <cftry>
            <!-- Deserialize JSON payload if it's a string -->
            <cfif isJSON(arguments.payload)>
                <cfset arguments.payload = deserializeJSON(arguments.payload)>
            </cfif>

            <!-- Validate payload -->
            <cfif NOT isStruct(arguments.payload)>
                <cfthrow message="Payload is invalid or missing." type="ValidationError">
            </cfif>

            <!-- Extract offers from payload -->
            <cfset var offers = arguments.payload>
            <cfset session=offers.session_variables>
            <!-- Log the payload for debugging -->
            <cflog file="purchaseService" text="Received payload: #serializeJSON(offers)#" type="information">

            
            <!-- Process each offer -->
            <cfset ix=0>
            <cfloop array="#offers.payload#" item="offer">
                <cfset var products = offer.products>

                <!-- Process each product -->
                <cfloop array="#products#" item="product">
                    <!-- Delete existing rows for the product -->
                    <cfquery name="DEL" datasource="#dsn3#">
                        DELETE FROM PBS_SELECTED_ROWS WHERE WRK_ROW_ID = '#product.wrkRowId#'
                    </cfquery>

                    <!-- Insert new rows for the product -->
                    <cfquery name="INS" datasource="#dsn3#">
                        INSERT INTO PBS_SELECTED_ROWS (
                            WRK_ROW_ID,
                            PRICE,
                            OFFER_ID,
                            PRODUCT_MARJ,
                            SALE_PRICE
                        )
                        VALUES (
                            '#product.wrkRowId#',
                            #product.netPrice#,
                            #offers.offer_id#,
                            #product.productMarj#,
                            #product.salePrice#
                        )
                    </cfquery>
                    <cfquery name="getStockInfo" datasource="#dsn3#">
                        SELECT * FROM STOCKS WHERE STOCK_ID=#product.stockId#
                    </cfquery>
                      <cfquery name="getUnit" datasource="#dsn3#">
                        select PRODUCT_UNIT_ID,MAIN_UNIT from #dsn3#.PRODUCT_UNIT where PRODUCT_ID=#product.productId#
                    </cfquery>
                    <cfscript>
                        ix=ix+1;
                        attributes["price#ix#"] = product.salePrice;
                        attributes["price_other#ix#"] = product.convertedsalePriceOther;
                        attributes["tax#ix#"] = product.tax;
                        attributes["amount#ix#"] = product.quantity;
                        attributes["indirim1#ix#"] = product.discount1;
                        attributes["other_money_#ix#"] = product.otherMoney;
                        attributes["product_id#ix#"] = product.productId;
                        attributes["stock_id#ix#"] = product.stockId;
                        attributes["unit#ix#"] = getUnit.MAIN_UNIT;
                        attributes["unit_id#ix#"] = getUnit.PRODUCT_UNIT_ID;
                        attributes["product_name#ix#"] = product.productName;
                        attributes["other_money_value_#ix#"] = (product.convertedsalePriceOther * product.quantity) - ((product.convertedsalePriceOther * product.quantity) * product.discount1) / 100;
                        attributes["description#ix#"] = "";
                        attributes["wrk_row_id#ix#"] = "PBS#session.ep.userid##dateFormat(now(), 'yyyymmdd')##timeFormat(now(), 'hhmmnnl')#";
                        attributes["wrk_row_relation_id#ix#"] = product.wrkRowId;
                        attributes["is_virtual#ix#"] = 0;
                        attributes["SHELF_CODE#ix#"] = "";
                        attributes["OFFER_ROW_CURRENCY#ix#"] = "";
                        
                    </cfscript>
                </cfloop>
            </cfloop>
        


    






            <!-- Set success response -->
            <cfset response.res = "success">
            <cfset response.message = "Purchase offers saved successfully.">
            <cfset response.data = attributes>
        <cfcatch>
            <!-- Handle errors -->
            <cfset response.res = "error">
            <cfset response.message = cfcatch>
            <cflog file="purchaseService" text="Error: #cfcatch.message#" type="error">
        </cfcatch>
        </cftry>

        <cfreturn response>
    </cffunction>



    <cffunction name="getByProductId" access="remote" returntype="array" output="false" httpMethod="POST" returnFormat="json">

        <cfargument name="product_id" type="string" required="true">

        <cfset var result = []>

        <cfquery name="qAlt" datasource="#dsn3#">
            SELECT ALTERNATIVE_PRODUCT_ID as ALTERNATIF_PRODUCT_ID
            FROM w3Qa_1.ALTERNATIVE_PRODUCTS
            WHERE PRODUCT_ID = <cfqueryparam value="#arguments.product_id#" cfsqltype="cf_sql_varchar">
        </cfquery>

        <cfloop query="qAlt">
            <cfset arrayAppend(result, qAlt.ALTERNATIF_PRODUCT_ID)>
        </cfloop>

        <cfreturn result>
    </cffunction>

    <cffunction name="savePurchaseOffer" access="remote" returntype="struct" output="false" hint="Saves selected purchase offers" returnFormat="json" httpMethod="POST">

        <cfset var response = {}>
        <cfset arguments.payload = getHTTPRequestData().content>
        <cfdump var="#arguments.payload#">
        <cfset arguments.payload = deserializeJSON(arguments.payload)>
        
        <cfset session=arguments.payload.payload.session>
        <cfset var products = arguments.payload.payload.products>
        <cfset var company_id = arguments.payload.payload.company_ids>
        <cfquery name="getOffer" datasource="#dsn3#" result="RES">
            SELECT * FROM OFFER_ROW
            LEFT JOIN  #dsn3#.PRODUCT_UNIT AS PU ON PU.PRODUCT_ID=OFFER_ROW.PRODUCT_ID AND IS_MAIN=1
            LEFT JOIN #dsn3#.STOCKS AS P ON P.PRODUCT_ID=OFFER_ROW.PRODUCT_ID
             WHERE OFFER_ID=#arguments.payload.payload.for_offer_id#
        </cfquery>

        <cfloop  query="getOffer">
            <CFSET "PID_#getOffer.WRK_ROW_ID#"=getOffer.PRODUCT_ID>
            <CFSET "SID_#getOffer.WRK_ROW_ID#"=getOffer.STOCK_ID>
            <cfset "PRODUCT_NAME_#getOffer.WRK_ROW_ID#"=getOffer.PRODUCT_NAME>
            <cfset "PRODUCT_UNIT_#getOffer.WRK_ROW_ID#"=getOffer.PRODUCT_UNIT>
            <cfset "PRODUCT_UNIT_ID_#getOffer.WRK_ROW_ID#"=getOffer.PRODUCT_UNIT_ID>
            <CFSET "TAX_PURCHASE_#getOffer.WRK_ROW_ID#"=getOffer.TAX_PURCHASE>
            <cfset "QUANTITY_#getOffer.WRK_ROW_ID#"=getOffer.QUANTITY>
            <CFSET "OTHER_MONEY_#getOffer.WRK_ROW_ID#"=getOffer.OTHER_MONEY>
        </cfloop>
        <cfset ix=0>
        <cfloop array="#products#" item="product">
            <cfset wrkRowId=product>
            <cfscript>
                ix=ix+1;
                attributes["product_id#ix#"] = evaluate("PID_#wrkRowId#");
                attributes["stock_id#ix#"] = evaluate("SID_#wrkRowId#");
                attributes["product_name#ix#"] = evaluate("PRODUCT_NAME_#wrkRowId#");
                attributes["unit#ix#"] = evaluate("PRODUCT_UNIT_#wrkRowId#");
                attributes["unit_id#ix#"] = evaluate("PRODUCT_UNIT_ID_#wrkRowId#");
                attributes["price#ix#"] = 0;
                attributes["price_other#ix#"] = 0;
                attributes["tax#ix#"] = evaluate("TAX_PURCHASE_#wrkRowId#");
                attributes["amount#ix#"] = evaluate("QUANTITY_#wrkRowId#");
                attributes["indirim1#ix#"] = 0;
                attributes["other_money_#ix#"] = evaluate("OTHER_MONEY_#wrkRowId#");
                attributes["other_money_value_#ix#"] = 0;
                attributes["description#ix#"] = "";
                attributes["wrk_row_id#ix#"] = "PBS#session.ep.userid##dateFormat(now(), 'yyyymmdd')##timeFormat(now(), 'hhmmnnl')#";
                attributes["wrk_row_relation_id#ix#"] = product;
                attributes["is_virtual#ix#"] = 0;
                attributes["SHELF_CODE#ix#"] = "";
                attributes["OFFER_ROW_CURRENCY#ix#"] = "";


            </cfscript>
            

        </cfloop>
        <cfset attributes.rows_=ix>
        <cfquery name="GETCOMPANY" datasource="#dsn#">
            select CASE WHEN LEN(COMPANY_ADDRESS)=0 THEN '-'ELSE ISNULL(COMPANY_ADDRESS,'-') END AS COMPANY_ADDRESS,CITY,COUNTY from w3Qa.COMPANY WHERE COMPANY_ID=#company_id#
        </cfquery>

<cfset attributes.offer_date=now()>
<cfset attributes.deliverdate=now()>
<cfset attributes.ship_date=now()>
<cfset attributes.finishdate=now()>
<cfset company_ids=",#arguments.payload.payload.company_ids#,">
<cfscript>
    DISCOUNT_TOTAL=0;
    GROSS_TOTAL=0;
    SUBNETTOTAL=0;
    SUBTAXTOTAL=0;
    SUBTOTAL=0;
    TAX_TOTAL=0;
    TOTAL_WITHOUT_KDV=0;
    TOTAL_WITH_KDV=0;
    BASKET_NET_TOTAL=0;
    BASKET_NET_TOTAL_=0;
    BASKET_TAX_TOTAL=0;
    BASKET_TAX_TOTAL_=0;
</cfscript>
<CFLOOP from="1" to="#attributes.rows_#" index="ix">
    <cfset PRICE=evaluate("attributes.price#ix#")>
    <cfset PRICE_OTHER=evaluate("attributes.price_other#ix#")>
    <cfset TAX=evaluate("attributes.tax#ix#")>
    <CFSET AMOUNT=evaluate("attributes.amount#ix#")>
    <CFSET DISCOUNT=evaluate("attributes.indirim1#ix#")>
    <CFSET OTHER_MONEY=evaluate("attributes.other_money_#ix#")>
    <cfscript>
     SATIR_KUR= arrayFilter(MONEYARRRR, function(item) {
            return item.MONEY == OTHER_MONEY;
        })[1];
    OLD_SATIR_KUR= SATIR_KUR;
    </cfscript>

    <CFSET PR_HESAP=PRICE_OTHER*SATIR_KUR.RATE2>
    <cfset ox=structNew()>
    <cfset ox.PRICE=PRICE>
    <cfset ox.PRICE_=PR_HESAP>
    <cfscript>
        dp=PRICE-(PRICE*DISCOUNT)/100;  
        dp_=PR_HESAP-(PR_HESAP*DISCOUNT)/100;                    

        TUTAR=dp*AMOUNT;
        TUTAR_=dp_*AMOUNT;

        TX=(TUTAR*TAX)/100
        TX_=(TUTAR_*TAX)/100
        ox.DP=dp;
        ox.DP_=dp_;
        ox.TUTAR=TUTAR;
        ox.TUTAR_=TUTAR_;
        OX.OTM_V=TUTAR/OLD_SATIR_KUR.RATE2;
        OX.OTM_V_=TUTAR_/SATIR_KUR.RATE2;
        ox.TX=TX;
        ox.TX_=TX_;
        BASKET_TAX_TOTAL=BASKET_TAX_TOTAL+TX;
        BASKET_TAX_TOTAL_=BASKET_TAX_TOTAL_+TX_;
        BASKET_NET_TOTAL=BASKET_NET_TOTAL+(TUTAR+TX);
        BASKET_NET_TOTAL_=BASKET_NET_TOTAL_+(TUTAR_+TX_);

        "attributes.other_money_value_#ix#"=ox.OTM_V_;
        "attributes.price#ix#"=ox.PRICE_;
    </cfscript>
    


    



</CFLOOP>



        


        <cfreturn RES>




    </cffunction>

<cffunction name="SAVEORDER" access="remote">
    <cfargument name="internal_id" type="numeric" required="true">
<cfquery name="getSelectedRows" datasource="#dsn3#">

SELECT 
	
	TRY_CAST(REPLACE(O_ALIS_TEKLIFI.OFFER_TO, ',', '') AS INT) COMPANY_ID
	,ORR_SATIS_TEKLIFI.PRODUCT_ID
	,ORR_SATIS_TEKLIFI.STOCK_ID
	,ORR_SATIS_TEKLIFI.PRODUCT_NAME
	,ORR_SATIS_TEKLIFI.PRODUCT_NAME2
	,ORR_SATIS_TEKLIFI.PRICE
	,ORR_SATIS_TEKLIFI.QUANTITY
	,ORR_SATIS_TEKLIFI.WRK_ROW_ID
	,ORR_SATIS_TEKLIFI.WRK_ROW_RELATION_ID
	,ORR_SATIS_TEKLIFI.OTHER_MONEY
	,ORR_SATIS_TEKLIFI.PRICE_OTHER
	,ORR_SATIS_TEKLIFI.MARJ_ORAN_PBS
	,ORR_SATIS_TEKLIFI.PRICE_PBS
	,ORR_SATIS_TEKLIFI.OLD_PRICE
    ,ORR_SATIS_TEKLIFI.UNIT
    ,ORR_SATIS_TEKLIFI.UNIT_ID
    ,ORR_SATIS_TEKLIFI.TAX
    ,ORR_SATIS_TEKLIFI.OTHER_MONEY_VALUE

FROM w3Qa_1.OFFER_ROW AS ORR_SATIS_TEKLIFI
LEFT JOIN w3Qa_1.OFFER_ROW AS ORR_ALIS_TEKLIFI ON ORR_ALIS_TEKLIFI.WRK_ROW_ID=ORR_SATIS_TEKLIFI.WRK_ROW_RELATION_ID
LEFT JOIN w3Qa_1.OFFER AS O_ALIS_TEKLIFI ON O_ALIS_TEKLIFI.OFFER_ID=ORR_ALIS_TEKLIFI.OFFER_ID
WHERE ORR_SATIS_TEKLIFI.WRK_ROW_RELATION_ID IN (
SELECT WRK_ROW_ID FROM w3Qa_1.PBS_SELECTED_ROWS WHERE OFFER_ID=#arguments.internal_id#)
	
        ORDER BY COMPANY_ID
</cfquery>
<cfset MONEYARRRR=arrayNew(1)>
            <cfquery name="getMoneyext" datasource="#dsn3#">
                SELECT 
             (SELECT RATE1 FROM #dsn#.MONEY_HISTORY WHERE MONEY_HISTORY_ID=(
             SELECT MAX(MONEY_HISTORY_ID) FROM #dsn#.MONEY_HISTORY WHERE MONEY=SM.MONEY) )AS RATE1,
             (SELECT EFFECTIVE_SALE RATE2 FROM #dsn#.MONEY_HISTORY WHERE MONEY_HISTORY_ID=(
             SELECT MAX(MONEY_HISTORY_ID) FROM #dsn#.MONEY_HISTORY WHERE MONEY=SM.MONEY) )AS RATE2,
             SM.MONEY
             FROM #dsn#.SETUP_MONEY AS SM WHERE SM.PERIOD_ID=#session.ep.period_id#
             </cfquery>
             <cfset ibnm=1>
    <cfloop query="getMoneyext">
        <cfset "attributes._hidden_rd_money_#ibnm#"=MONEY>


        <cfset "attributes.hidden_rd_money_#ibnm#"=MONEY>
        <cfset "attributes._txt_rate1_#ibnm#"=RATE1>
        <cfset "attributes._txt_rate2_#ibnm#"=RATE2>
        <cfset "attributes.txt_rate1_#ibnm#"=RATE1>
        <cfset "attributes.txt_rate2_#ibnm#"=RATE2>
          
        <cfscript>
            arrayAppend(MONEYARRRR,{MONEY=MONEY,RATE1=RATE1,RATE2=RATE2})
        </cfscript>
        <cfset ibnm=ibnm+1>
    </cfloop>
    <cfset attributes.KUR_SAY=arrayLen(MONEYARRRR)>
<cfloop query="getSelectedRows" group="COMPANY_ID">
<cfdump var="#getSelectedRows.COMPANY_ID#">
<cfset ix=0>
<cfloop>
    <cfscript>
        ix=ix+1;
        attributes["product_id#ix#"] = PRODUCT_ID;
        attributes["stock_id#ix#"] = STOCK_ID;
        attributes["product_name#ix#"] = PRODUCT_NAME;
        attributes["unit#ix#"] = UNIT;
        attributes["unit_id#ix#"] = UNIT_ID;
        attributes["price#ix#"] = PRICE;
        attributes["price_other#ix#"] = PRICE_OTHER;
        attributes["tax#ix#"] = TAX;
        attributes["amount#ix#"] = QUANTITY;
        attributes["indirim1#ix#"] = 0;
        attributes["other_money_#ix#"] = OTHER_MONEY;
        attributes["other_money_value_#ix#"] = OTHER_MONEY_VALUE;
        attributes["description#ix#"] = "";
        attributes["wrk_row_id#ix#"] = "PBS#session.ep.userid##dateFormat(now(), 'yyyymmdd')##timeFormat(now(), 'hhmmnnl')#";
        attributes["wrk_row_relation_id#ix#"] = WRK_ROW_ID;
        attributes["is_virtual#ix#"] = 0;
        attributes["SHELF_CODE#ix#"] = "";
        attributes["OFFER_ROW_CURRENCY#ix#"] = "";


    </cfscript>
    
</cfloop>
<cfset attributes.rows_=ix>
        <cfquery name="GETCOMPANY" datasource="#dsn#">
            select CASE WHEN LEN(COMPANY_ADDRESS)=0 THEN '-'ELSE ISNULL(COMPANY_ADDRESS,'-') END AS COMPANY_ADDRESS,CITY,COUNTY from w3Qa.COMPANY WHERE COMPANY_ID=#COMPANY_ID#
        </cfquery>
<cfdump var="#GETCOMPANY#">
<cfset attributes.order_date=now()>
<cfset attributes.deliverdate=now()>
<cfscript>
    DISCOUNT_TOTAL=0;
    GROSS_TOTAL=0;
    SUBNETTOTAL=0;
    SUBTAXTOTAL=0;
    SUBTOTAL=0;
    TAX_TOTAL=0;
    TOTAL_WITHOUT_KDV=0;
    TOTAL_WITH_KDV=0;
    BASKET_NET_TOTAL=0;
    BASKET_NET_TOTAL_=0;
    BASKET_TAX_TOTAL=0;
    BASKET_TAX_TOTAL_=0;
</cfscript>

<CFLOOP from="1" to="#attributes.rows_#" index="ix">
    <cfset PRICE=evaluate("attributes.price#ix#")>
    <cfset PRICE_OTHER=evaluate("attributes.price_other#ix#")>
    <cfset TAX=evaluate("attributes.tax#ix#")>
    <CFSET AMOUNT=evaluate("attributes.amount#ix#")>
    <CFSET DISCOUNT=evaluate("attributes.indirim1#ix#")>
    <CFSET OTHER_MONEY=evaluate("attributes.other_money_#ix#")>
    <cfscript>
     SATIR_KUR= arrayFilter(MONEYARRRR, function(item) {
            return item.MONEY == OTHER_MONEY;
        })[1];
    OLD_SATIR_KUR= SATIR_KUR;
    </cfscript>

    <CFSET PR_HESAP=PRICE_OTHER*SATIR_KUR.RATE2>
    <cfset ox=structNew()>
    <cfset ox.PRICE=PRICE>
    <cfset ox.PRICE_=PR_HESAP>
    <cfscript>
        dp=PRICE-(PRICE*DISCOUNT)/100;  
        dp_=PR_HESAP-(PR_HESAP*DISCOUNT)/100;                    

        TUTAR=dp*AMOUNT;
        TUTAR_=dp_*AMOUNT;

        TX=(TUTAR*TAX)/100
        TX_=(TUTAR_*TAX)/100
        ox.DP=dp;
        ox.DP_=dp_;
        ox.TUTAR=TUTAR;
        ox.TUTAR_=TUTAR_;
        OX.OTM_V=TUTAR/OLD_SATIR_KUR.RATE2;
        OX.OTM_V_=TUTAR_/SATIR_KUR.RATE2;
        ox.TX=TX;
        ox.TX_=TX_;
        BASKET_TAX_TOTAL=BASKET_TAX_TOTAL+TX;
        BASKET_TAX_TOTAL_=BASKET_TAX_TOTAL_+TX_;
        BASKET_NET_TOTAL=BASKET_NET_TOTAL+(TUTAR+TX);
        BASKET_NET_TOTAL_=BASKET_NET_TOTAL_+(TUTAR_+TX_);

        "attributes.other_money_value_#ix#"=ox.OTM_V_;
        "attributes.price#ix#"=ox.PRICE_;
    </cfscript>
</cfloop>

<cfdump var="#attributes#">
<cfscript>
    structClear(attributes);
</cfscript>

</cfloop>


<!--------------------
<cfloop query="getSelectedRows" group="COMPANY_ID">

    <cfset ix=0>
    <cfloop >
        <cfset wrkRowId=product>
        
        <cfset attributes.rows_=ix>
        <cfquery name="GETCOMPANY" datasource="#dsn#">
            select CASE WHEN LEN(COMPANY_ADDRESS)=0 THEN '-'ELSE ISNULL(COMPANY_ADDRESS,'-') END AS COMPANY_ADDRESS,CITY,COUNTY from w3Qa.COMPANY WHERE COMPANY_ID=#COMPANY_ID#
        </cfquery>
    
    <cfset attributes.order_date=now()>
    <cfset attributes.deliverdate=now()>
    
    

<cfdump var="#attributes#">

</cfloop>


------------------>


</cffunction>


</cfcomponent>
