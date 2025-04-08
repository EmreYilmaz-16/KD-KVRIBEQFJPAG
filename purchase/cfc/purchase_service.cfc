<cfcomponent displayname="PurchaseService" output="false" hint="Handles purchase-related operations">
    <cfset dsn3="w3Qa_1">

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
                SELECT FROM_COMPANY_ID
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
