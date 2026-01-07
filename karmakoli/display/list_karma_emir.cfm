<cfquery name="list_karma_emir" datasource="#dsn3#">
    SELECT * FROM KARMA_EMIR_PBS
</cfquery>
<cfoutput>
    <table border="1">
        <tr>
            <th>EMIR_ID</th>
            <th>DESCRIPTION</th>
            <th>PRODUCT_NAME</th>
            <th>QUANTITY</th>
            <th>RECORD_DATE</th>
            <th>RECORD_EMPLOYEE_ID</th>
            <th>STATUS</th>
        </tr>
        <cfloop query="list_karma_emir">
            <tr>
                <td><a href="#request.self#?fuseaction=product.emptypopup_detail_karma_emir_pbs&EMIR_ID=#EMIR_ID#">#EMIR_ID#</a></td>
                <td>#DESCRIPTION#</td>
                <td>#PRODUCT_NAME#</td>
                <td>#QUANTITY#</td>
                <td>#DATEFORMAT(RECORD_DATE, 'yyyy-mm-dd')#</td>
                <td>#RECORD_EMPLOYEE_ID#</td>
                <td>#STATUS#</td><!--- TAMALANDI BEKLIYOR --->
            </tr>
        </cfloop>
    </table>
</cfoutput>