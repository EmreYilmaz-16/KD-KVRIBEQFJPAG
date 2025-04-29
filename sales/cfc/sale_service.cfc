<cfcomponent displayname="PurchaseService" output="false" hint="Handles purchase-related operations">
    <cfset dsn3="w3Qa_1">
    <cfset dsn="w3Qa">


    <cffunction name="SaveSaleMarjToOffer" access="remote" returntype="struct" output="false" hint="Saves selected purchase offers" returnFormat="json" httpMethod="POST">
        <cfset arguments.payload = getHTTPRequestData().content>        
        <cfset arguments.payload = deserializeJSON(arguments.payload)>
        
        <cfsavecontent variable="test1">
            <cfdump var="#arguments.payload#">
          </cfsavecontent>
          <cffile action="write" file = "C:\w3Dosya\w3Qa\AddOns\Partner\ServisLogs\SaveSaleMarjToOffer.html" output="#test1#"></cffile>
        
        <cfloop array="#arguments.payload.MarjArray#" item="it"></cfloop>
        <cfreturn arguments.payload>
    </cffunction>
</cfcomponent>