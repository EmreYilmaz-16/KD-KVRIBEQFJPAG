<cftry>
    <cfquery name="getSayimList" datasource="w3Qa_1">
        SELECT 
            s.SAYIM_ID,
            s.PAPER_NUMBER,
            s.DEPARTMENT_ID,
            s.LOCATION_ID,
            CAST(s.DEPARTMENT_ID AS VARCHAR)+'-'+CAST(s.LOCATION_ID AS VARCHAR) AS DEPO_CODE,
            sl.COMMENT AS DEPO_NAME,
            s.SAYIM_DATE,
            s.RECORD_DATE,
            s.RECORD_EMP
        FROM PBS_SERIAL_SAYIM s
        LEFT JOIN w3Qa.STOCKS_LOCATION sl ON (
            s.DEPARTMENT_ID = sl.DEPARTMENT_ID AND 
            s.LOCATION_ID = sl.LOCATION_ID
        )
        ORDER BY s.RECORD_DATE DESC, s.SAYIM_ID DESC
    </cfquery>
    <cfcatch>
        <cfset getSayimList = queryNew("SAYIM_ID,PAPER_NUMBER,DEPARTMENT_ID,LOCATION_ID,DEPO_CODE,DEPO_NAME,SAYIM_DATE,RECORD_DATE,RECORD_EMP", "integer,varchar,integer,integer,varchar,varchar,date,date,integer")>
        <cfset errorMessage = "Veritabanı hatası: #cfcatch.message#">
    </cfcatch>
</cftry>

<cf_grid_list>
<cfoutput query="getSayimList">
    <tr></tr>
        <td><a href="detail_sayim_pda.cfm?sayim_id=#SAYIM_ID#" class="button">Detay</a></td>
        <td>#SAYIM_ID#</td>
        <td>#PAPER_NUMBER#</td>
        <td>#DEPO_CODE# - #DEPO_NAME#</td>
        <td>#DateFormat(SAYIM_DATE, "dd.mm.yyyy")#</td>
        <td>#DateFormat(RECORD_DATE, "dd.mm.yyyy")#</td>
        <td>#RECORD_EMP#</td>
</cfoutput>    
</cf_grid_list>