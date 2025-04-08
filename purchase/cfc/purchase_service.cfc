<cfcomponent displayname="PurchaseService" output="false" hint="Handles purchase-related operations">
<CFSET dsn3="w3Qa_1">
    <cffunction name="savePurchaseOfferSelector" access="remote" returntype="struct" output="false" hint="Saves selected purchase offers" returnFormat="json" httpMethod="POST">

      
        <cfset var response = {}>
<cfset arguments.payload=getHTTPRequestData().content>

        <cftry>
            <!-- Deserialize JSON payload if it's a string -->
            <cfif isJSON(arguments.payload)>
                <cfset arguments.payload = deserializeJSON(arguments.payload)>
            </cfif>
            
            
            <!-- Check if payload is a valid struct -->
            <cfif NOT isStruct(arguments.PAYLOAD)>
                <cfthrow message="aaa Payload is invalid or missing." type="ValidationError">
            </cfif>
           
            <!-- Simulate saving the payload to a database -->
            <cfset var offers = arguments.payload>
            
            <!-- Example: Log the payload for debugging -->
            <cflog file="purchaseService" text="Received payload: #serializeJSON(offers)#" type="information">
            <cfloop array="#offers.payload#" item="it">
                <cfset rw=it.products>
                <cfloop array="#rw#" item="it2">
                    <cfquery name="DEL" datasource="#DSN3#">
                        DELETE FROM PBS_SELECTED_ROWS WHERE WRK_ROW_ID='#it2.wrkRowId#'
                    </cfquery>
                    <cfquery name="ins" datasource="#dsn3#">
                        INSERT INTO PBS_SELECTED_ROWS (
                            WRK_ROW_ID,
                            PRICE
                        )
                        values
                        ('#it2.wrkRowId#',#it2.netPrice#)
                    </cfquery>
                </cfloop>
            </cfloop>
            <!-- Simulate success -->
            <cfset response.res = "success">
            <cfcatch>
                <!-- Handle any errors -->
                <cfset response.res = "error">
                <cfset response.message = cfcatch.message>
                <cflog file="purchaseService" text="Error: #cfcatch.message#" type="error">
            </cfcatch>
            </cftry>

        <cfreturn response>
    </cffunction>

</cfcomponent>
