<cftry>

<cfquery name="up" datasource="#caller.dsn#">

    EXEC #caller.dsn3#.usp_Sync_SelectInfoExtra_FromDemand_ToOffers @I_ID = #attributes.ACTION_ID#;
</cfquery>

<cfcatch>
    <cfdump var="#cfcatch#">
    <cfabort>
</cfcatch>
</cftry>