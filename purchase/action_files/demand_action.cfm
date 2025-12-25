
<cfquery name="up" datasource="#caller.dsn#">

    EXEC dbo.usp_Sync_SelectInfoExtra_FromDemand_ToOffers @I_ID = #attributes.ACTION_ID#;
</cfquery>