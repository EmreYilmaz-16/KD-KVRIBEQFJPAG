<cfquery name="getSayim" datasource="#dsn3#">
    SELECT *,CAST(DEPARTMENT_ID AS varchar)+'-'+CAST(LOCATION_ID AS varchar) AS DEPO FROM PBS_SERIAL_SAYIM WHERE SAYIM_ID=#attributes.sayim_id#
</cfquery>

   <cfset depoValues = listToArray(getSayim.DEPO, "-")>
        <cfset departmentId = depoValues[1]>
        <cfset locationId = depoValues[2]>
        <cfset attributes.dep_in=arrayToList(depoValues)>
        <cfdump var="#attributes#">
<cfdump var="#depoValues#">
<cfquery name="getRows1" datasource="#dsn3#">
select PRODUCT_ID,STOCK_ID,SHELF_NUMBER,COUNT(*) AS QUANTITY from w3Qa_1.PBS_SERIAL_SAYIM_ROW GROUP BY PRODUCT_ID,STOCK_ID,SHELF_NUMBER
</cfquery>

