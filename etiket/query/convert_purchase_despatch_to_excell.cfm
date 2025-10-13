<cfquery name="getRows" datasource="#dsn2#">
    SELECT * FROM SHIP_ROW WHERE SHIP_ID=#attributes.SHIP_ID#
</cfquery>