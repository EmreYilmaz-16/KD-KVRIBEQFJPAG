<cfdump var="#attributes#">
<cfabort>
<cfquery name="up" datasource="#caller.dsn#">

    EXEC w3Qa_1.usp_Sync_SelectInfoExtra_FromDemand_ToOffers @I_ID = 993;
</cfquery>