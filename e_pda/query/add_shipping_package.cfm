<cfdump var="#attributes#">
<cfset SERIAL_NUMBERS=deserializeJSON(attributes.SERIALS)>
<cfdump var="#SERIAL_NUMBERS#">




<cfsetting showdebugoutput="yes">
<cfif listlen(attributes.stock_id_list)>
	<cfquery name="DELETE_PACKAGE_LIST" datasource="#DSN3#">
		DELETE EZGI_SHIPPING_PACKAGE_LIST WHERE SHIPPING_ID = #attributes.SHIP_ID# AND TYPE = #attributes.is_type#
	</cfquery>
	<cfloop list="#attributes.stock_id_list#" index="sid">
		<cfquery name="ADD_PACKAGE_LIST" datasource="#dsn3#">
			INSERT INTO 
                EZGI_SHIPPING_PACKAGE_LIST
                (
                    SHIPPING_ID,
                    STOCK_ID,
                    AMOUNT,
                    CONTROL_AMOUNT,
                    CONTROL_STATUS,
                    TYPE,
                    RECORD_DATE,
                    RECORD_EMP
                )
         	VALUES
                (
                    #attributes.SHIP_ID#,
                    #sid#,
                    #Evaluate('attributes.amount#sid#')#,
                    <cfif len(Evaluate('attributes.control_amount#sid#'))>#Evaluate('attributes.control_amount#sid#')#<cfelse>0</cfif>,
                    #kontrol_status#,
                    #attributes.is_type#,
                    #now()#,
                    #session.ep.userid#
                )
		</cfquery>
	</cfloop>

    <!--- SERIAL_NUMBERS struct yapısını işle --->
<cfloop collection="#SERIAL_NUMBERS#" item="stock_id">
    <cfset serial_array = SERIAL_NUMBERS[stock_id]>
    
    
    <!--- Her bir seri numarası için işlem yap --->
    <cfloop array="#serial_array#" index="serial_item">
       <cfif serial_item.IS_READ eq 1>
        <cfquery name="delete_serial" datasource="#dsn3#">
            DELETE FROM PBS_SHIPPING_PACKAGE_LIST_SERIALS
            WHERE SHIPPING_ID = #attributes.SHIP_ID# AND STOCK_ID = #stock_id# AND SERIAL_NUMBER = '#serial_item.SERIAL_NO#'
        </cfquery>
        <cfquery name="ADD_SERIAL_LIST" datasource="#dsn3#">
            INSERT INTO 
                PBS_SHIPPING_PACKAGE_LIST_SERIALS
                (
                    SHIPPING_ID,
                    STOCK_ID,
                    SERIAL_NUMBER,                    
                    RECORD_DATE,
                    RECORD_EMP
                )
            VALUES
                (
                    #attributes.SHIP_ID#,
                    #stock_id#,
                    '#serial_item.SERIAL_NO#',                    
                    #now()#,
                    #session.ep.userid#
                )
        </cfquery>
       </cfif>
        <!--- serial_item.SERIAL_NO, serial_item.STOCK_ID, serial_item.IS_READ değerlerine erişebilirsiniz --->

    </cfloop>
</cfloop>

</cfif>
    
<cfif isdefined('session.ep')>
	<cflocation url="#request.self#?fuseaction=pda.list_shipping&department_id=#department_id#&date1=#date1#&date2=#date2#&page=#page#&is_form_submitted=1&kontrol_status=#kontrol_status#" addtoken="no">  
</cfif>