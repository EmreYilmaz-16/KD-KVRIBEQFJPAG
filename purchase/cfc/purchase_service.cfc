<cfcomponent displayname="PurchaseService" output="false" hint="Handles purchase-related operations">
    <cfset dsn3="w3Qa_1">
    <cfset dsn="w3Qa">

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

            <!-- Log the payload for debugging -->
            <cflog file="purchaseService" text="Received payload: #serializeJSON(offers)#" type="information">

            
            <!-- Process each offer -->
            <cfloop array="#offers.payload#" item="offer">
                <cfset var products = offer.products>

                <!-- Process each product -->
                <cfloop array="#products#" item="product" index="ix">
                    <!-- Delete existing rows for the product -->
                    <cfquery name="DEL" datasource="#dsn3#">
                        DELETE FROM PBS_SELECTED_ROWS WHERE WRK_ROW_ID = '#product.wrkRowId#'
                    </cfquery>

                    <!-- Insert new rows for the product -->
                    <cfquery name="INS" datasource="#dsn3#">
                        INSERT INTO PBS_SELECTED_ROWS (
                            WRK_ROW_ID,
                            PRICE,
                            OFFER_ID
                        )
                        VALUES (
                            '#product.wrkRowId#',
                            #product.netPrice#,
                            #offers.offer_id#
                        )
                    </cfquery>
                </cfloop>
            </cfloop>

            <!-- Retrieve related internal demand data -->
            <cfquery name="GETIDEMAND" datasource="#dsn3#">
                SELECT FROM_COMPANY_ID,FROM_PARTNER_ID
                FROM w3Qa_1.INTERNALDEMAND
                WHERE INTERNAL_ID IN (
                    SELECT I_ID
                    FROM w3Qa_1.INTERNALDEMAND_ROW
                    WHERE WRK_ROW_ID IN (
                        SELECT WRK_ROW_RELATION_ID
                        FROM w3Qa_1.OFFER_ROW
                        WHERE WRK_ROW_ID IN (
                            SELECT WRK_ROW_RELATION_ID
                            FROM w3Qa_1.OFFER_ROW
                            WHERE WRK_ROW_ID IN (
                                SELECT WRK_ROW_ID
                                FROM w3Qa_1.PBS_SELECTED_ROWS
                                WHERE OFFER_ID = #offers.offer_id#
                            )
                        )
                    )
                )
            </cfquery>
<cfset session=offers.session_variables>

            <cfset FORM.ACTIVE_COMPANY=session.ep.company_id>
            <cfset ATTRIBUTES.ACTIVE_COMPANY=session.ep.company_id>
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
        <cfset "attributes._txt_rate1_#ibnm#"=RATE1>
        <cfset "attributes._txt_rate2_#ibnm#"=RATE2>
        <cfset "attributes.txt_rate1_#ibnm#"=RATE1>
        <cfset "attributes.txt_rate2_#ibnm#"=RATE2>
        <cfset ibnm=ibnm+1>
    </cfloop>
    <cfset attributes.KUR_SAY=ibnm>

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


            <!-- Set success response -->
            <cfset response.res = "success">
        <cfcatch>
            <!-- Handle errors -->
            <cfset response.res = "error">
            <cfset response.message = cfcatch.message>
            <cflog file="purchaseService" text="Error: #cfcatch.message#" type="error">
        </cfcatch>
        </cftry>

        <cfreturn response>
    </cffunction>
</cfcomponent>
