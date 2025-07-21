<cf_date tarih = 'attributes.delivery_date' > 
<cfquery name="del_delivery_date" datasource="#dsn2#">
  	UPDATE 
  		SHIP_INTERNAL 
	SET 
    	DELIVER_DATE = #attributes.delivery_date#,
       	DEPARTMENT_OUT = #ListGetAt(attributes.out_departments,1,'-')#, 
       	LOCATION_OUT = #ListGetAt(attributes.out_departments,2,'-')#, 
       	DEPARTMENT_IN = #ListGetAt(attributes.in_departments,1,'-')#, 
       	LOCATION_IN = #ListGetAt(attributes.in_departments,2,'-')#
   	WHERE 
    	DISPATCH_SHIP_ID = #attributes.ship_id#
</cfquery>
<script type="text/javascript">
	wrk_opener_reload();
  	window.close();
</script>
