<cfcomponent displayname="PurchaseService" output="false" hint="Handles purchase-related operations">
    <cfset dsn3="w3Qa_1">
    <cfset dsn="w3Qa">


    <cffunction name="SaveSaleMarjToOffer" access="remote" returntype="struct" output="false" hint="Saves selected purchase offers" returnFormat="json" httpMethod="POST">
        <cfset arguments.payload = getHTTPRequestData().content>        
        <cfset arguments.payload = deserializeJSON(arguments.payload)>
        <cfreturn type="struct" value="#arguments.payload#">
    </cffunction>
</cfcomponent>