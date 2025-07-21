<cfsetting showdebugoutput="yes">
<cfif listlen(attributes.convert_stocks_id)>
	<cfquery name="DELETE_PACKAGE_LIST" datasource="#DSN3#">
		DELETE EZGI_SHIPPING_PACKAGE_LIST WHERE SHIPPING_ID = #attributes.SHIP_ID# AND TYPE = #attributes.is_type#
	</cfquery>
    <cfset row_i = listLen(attributes.convert_stocks_id)>
	<cfloop from="1" to="#row_i#" index="sid">
		<cfquery name="ADD_PACKAGE_LIST" datasource="#dsn3#">
			INSERT INTO 
			EZGI_SHIPPING_PACKAGE_LIST
			(
				SHIPPING_ID,
				STOCK_ID,
				CONTROL_AMOUNT,
                CONTROL_STATUS,
                TYPE,
                RECORD_DATE,
				RECORD_EMP
                <cfif attributes.kontrol_status eq 1>
                ,
                SHIPPING_ROW_ID,
                REF_STOCK_ID
                </cfif>
			)
			VALUES
			(
				#attributes.SHIP_ID#,
				#ListGetAt(attributes.convert_stocks_id,sid,',')#,
                #ListGetAt(attributes.convert_amount_stocks_id,sid,',')#,
                #attributes.kontrol_status#,
                #attributes.is_type#,
                #now()#,
				#session.ep.userid#
                <cfif attributes.kontrol_status eq 1>
                	,
                    #ListGetAt(attributes.convert_ship_id,sid,',')#,
                    #ListGetAt(attributes.convert_ref_stock_id,sid,',')#
                </cfif>
			)
		</cfquery>
	</cfloop>
</cfif>
<script type="text/javascript">
	wrk_opener_reload();
	window.close();
</script>
