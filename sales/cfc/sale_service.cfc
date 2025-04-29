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
        <cfargument name="wrk_row_id" type="string" required="true">
        <cfargument name="id" type="string" required="false" default="0">
        <cfif id eq 1>
            <cfquery name="getMessage" datasource="#dsn3#">
                SELECT MARJ_ORAN_PBS MSG FROM OFFER_ROW WHERE WRK_ROW_ID = '#arguments.wrk_row_id#'
            </cfquery>                
        <cfelse>
            <cfquery name="getMessage" datasource="#dsn3#">
                SELECT PRICE_PBS MSG FROM OFFER_ROW WHERE WRK_ROW_ID = '#arguments.wrk_row_id#'
            </cfquery>
        </cfif>
        <cfcontent type="text/plain; charset=utf-8">
        <cfoutput>#getMessage.MSG#</cfoutput>
    </cffunction>
    
    <cffunction name="getOfferMarjs" access="remote" returntype="struct" output="false" hint="Saves selected purchase offers" returnFormat="json" httpMethod="POST">
        <cfargument name="offerId" type="numeric" required="true" default="">

        <cfsavecontent variable="test1">
            <cfdump var="#arguments#">
            <cfdump var="#getHTTPRequestData()#">
          </cfsavecontent>
          <cffile action="write" file = "C:\w3Dosya\w3Qa\AddOns\Partner\ServisLogs\getOfferMarjsgetOfferMarjs.html" output="#test1#"></cffile>

        <cfquery name="getOfferMarjs" datasource="#dsn3#">
            select MARJ_ORAN_PBS,PRICE_PBS,WRK_ROW_ID from w3Qa_1.OFFER_ROW where OFFER_ID=#arguments.OFFERID#
        </cfquery>

        <cfset var result = []>
        <cfset var row = {}>
        <cfset var i = 1>
        <cfloop query="getOfferMarjs">
            <cfset row = {}>
            <cfset row.MARJ_ORAN_PBS = getOfferMarjs.MARJ_ORAN_PBS>
            <cfset row.PRICE_PBS = getOfferMarjs.PRICE_PBS>
            <cfset row.WRK_ROW_ID = getOfferMarjs.WRK_ROW_ID>
            <cfset arrayAppend(result, row)>
        </cfloop>
        <cfset var response = {}>
        <cfset response.status = "success">
        <cfset response.data = result>
        <cfset response.message = "Data retrieved successfully.">
    </cffunction>
</cfcomponent>