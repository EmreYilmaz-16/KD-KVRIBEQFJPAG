<cfquery name="getSayim" datasource="#dsn3#">
    SELECT *,CAST(DEPARTMENT_ID AS varchar)+'-'+CAST(LOCATION_ID AS varchar) AS DEPO FROM PBS_SERIAL_SAYIM WHERE SAYIM_ID=#attributes.sayim_id#
</cfquery>

   <cfset depoValues = listToArray(getSayim.DEPO, "-")>
        <cfset departmentId = depoValues[1]>
        <cfset locationId = depoValues[2]>
        <cfset attributes.dep_in=arrayToList(depoValues)>
        <cfset attributes.dep_out=arrayToList(depoValues)>
        <cfdump var="#depoValues#">
        <cfdump var="#attributes#">

        <cfset attributes.process_cat = 93>
    <cfset attributes.action_id = ''>
    <cfset attributes.is_mobile = 1>
    <cfset attributes.tersfis = 1>
    
<cfquery name="getRows1" datasource="#dsn3#">
select PRODUCT_ID,STOCK_ID,SHELF_NUMBER,COUNT(*) AS QUANTITY from w3Qa_1.PBS_SERIAL_SAYIM_ROW GROUP BY PRODUCT_ID,STOCK_ID,SHELF_NUMBER
</cfquery>

<cfset i=0>
<cfloop query="getRows1">
    <cfset i=i+1>
    <cfset "attributes.SHELF_CODE#i#"=getRows1.SHELF_NUMBER>
    <cfset "attributes.STOCK_ID#i#"=getRows1.STOCK_ID>
    <cfset "attributes.STOCKID#i#"=getRows1.STOCK_ID>
    <cfset "attributes.AMOUNT#i#"=getRows1.QUANTITY>
    <cfset "attributes.PRODUCT_ID#i#"=getRows1.PRODUCT_ID>
</cfloop>
<cfset attributes.row_count=getRows1.recordcount>

<cfinclude template="add_ambar_fis.cfm">