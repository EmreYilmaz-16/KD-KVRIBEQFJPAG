<cfquery name="DEL_ROW" datasource="#DSN2#">
 	DELETE FROM 
    	SHIP_INTERNAL_ROW
	WHERE     
    	DISPATCH_SHIP_ID = #attributes.ship_id#  AND 
        SHIP_ROW_ID = #attributes.ship_row_id#
</cfquery>
<script language="javascript">
   window.close();
   wrk_opener_reload();
</script>