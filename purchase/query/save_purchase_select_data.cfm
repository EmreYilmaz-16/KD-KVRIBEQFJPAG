<cftry>
<cfset _OfferData=getHTTPRequestData().content>
<cfset OfferData=deserializeJSON(_OfferData)>
<cfloop array="#OfferData#" item="it">
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
            ('#wrkRowId#',#netPrice#)
        </cfquery>
    </cfloop>
</cfloop>
<cfset Result.res="success">
<cfcatch>
    <cfset Result.res="error">    
</cfcatch>

</cftry>
<cfoutput>
#replace(serializeJSON(Result),"//","")#
</cfoutput>