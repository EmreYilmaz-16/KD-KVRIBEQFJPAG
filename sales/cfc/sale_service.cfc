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
        
        <cfloop array="#arguments.payload.MarjArray#" item="it">
            <cfquery name="Up" datasource="#dsn3#">
                UPDATE OFFER_ROW SET MARJ_ORAN_PBS =<cfif len(it.MARJ)>#it.MARJ#<cfelse>0</cfif>,PRICE_PBS=<cfif len(it.PRICE)>#it.PRICE#<cfelse>0</cfif>
                WHERE WRK_ROW_ID = '#it.WRK_ROW_ID#'
            </cfquery>
        </cfloop>
        <cfreturn arguments.payload>
    </cffunction>

    <cffunction name="saveMessage" access="remote" returntype="void" output="true" httpMethod="GET">
        <cfargument name="message" type="string" required="true">
        <cfcontent type="text/plain; charset=utf-8">            
        <cfoutput>Gelen mesaj: #arguments.message#</cfoutput>
    </cffunction>
    
</cfcomponent>