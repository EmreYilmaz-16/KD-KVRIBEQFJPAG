<cfquery name="getSayim" datasource="#dsn3#">
    SELECT *,DISTINCT CAST(DEPARTMENT_ID AS varchar)+'-'+CAST(LOCATION_ID AS varchar) AS DEPO FROM PBS_SERIAL_SAYIM WHERE SAYIM_ID=#attributes.sayim_id#
</cfquery>

   <cfset depoValues = listToArray(getSayim.DEPO, "-")>
        <cfset departmentId = depoValues[1]>
        <cfset locationId = depoValues[2]>
<cfdump var="#depoValues#">