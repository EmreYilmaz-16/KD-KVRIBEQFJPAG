<cfquery name="getSayim" datasource="#dsn3#">
    SELECT *,CAST(DEPARTMENT_ID AS varchar)+'-'+CAST(LOCATION_ID AS varchar) AS DEPO FROM PBS_SERIAL_SAYIM WHERE SAYIM_ID=#attributes.sayim_id#
</cfquery>

   <cfset depoValues = listToArray(getSayim.DEPO, "-")>
        <cfset departmentId = depoValues[1]>
        <cfset locationId = depoValues[2]>
        <cfset attributes.dep_in=getSayim.DEPO>
        <cfset attributes.dep_out=getSayim.DEPO>
        <cfdump var="#depoValues#">
        <cfdump var="#attributes#">

        <cfset attributes.process_cat = 93>
    <cfset attributes.action_id = ''>
    <cfset attributes.is_mobile = 1>
    <cfset attributes.tersfis = 1>
    
<cfquery name="getRows1" datasource="#dsn3#">
select PRODUCT_ID,STOCK_ID,SHELF_NUMBER,COUNT(*) AS QUANTITY,PRODUCT_CODE_2 from w3Qa_1.PBS_SERIAL_SAYIM_ROW GROUP BY PRODUCT_ID,STOCK_ID,SHELF_NUMBER,PRODUCT_CODE_2
</cfquery>

<cfset i=0>
<CFSET WS=structNew()>
<cfloop query="getRows1">
    <cfset i=i+1>
    <cfset "attributes.SHELF_CODE#i#"=getRows1.SHELF_NUMBER>
    <cfset "attributes.STOCK_ID#i#"=getRows1.STOCK_ID>
    <cfset "attributes.STOCKID#i#"=getRows1.STOCK_ID>
    <cfset "attributes.AMOUNT#i#"=getRows1.QUANTITY>
    <cfset "attributes.PRODUCT_ID#i#"=getRows1.PRODUCT_ID>
    <cfset 'attributes.WRK_ROW_ID#i#' = 'EZG'&#DateFormat(Now(),'YYYYMMDD')# & #TimeFormat(Now(),'HHmmssL')#>
    <CFSET "WS.SID#getRows1.STOCK_ID#_#getRows1.SHELF_NUMBER#.WRK_ROW_ID"=evaluate('attributes.WRK_ROW_ID#i#')>
</cfloop>
<cfset attributes.row_count=getRows1.recordcount>
<!---
<cfinclude template="add_ambar_fis.cfm">
---->
<cfset svc = createObject("component", "AddOns.Partner.cfc.service_guaranty")>

<cfquery name="getrows" datasource="#dsn3#">
SELECT SERIAL_NUMBER,STOCK_ID,SHELF_NUMBER FROM w3Qa_1.PBS_SERIAL_SAYIM_ROW
WHERE SAYIM_ID=#attributes.sayim_id#
</cfquery>
<cfdump var="#WS#">

<cfset data2 = {
    STOCK_ID = STOCK_ID_SER,
    SERIAL_NO = "#SERI_NO_SER#",
    LOT_NO = "#GETSER.LOT_NO#",
    IN_OUT = 1,
    PROCESS_CAT = 113,PROCESS_ID = 0,PROCESS_NO = "",PERIOD_ID = session.ep.period_id,DEPARTMENT_ID = attributes.DEPARTMENT_IN,LOCATION_ID = attributes.LOCATION_IN,IS_SARF = 0,IS_SERI_SONU = 0,WRK_ID = "#WRK_ROW_ID_SER#-#createUUID()#",WRK_ROW_ID = "#WRK_ROW_ID_SER#",UNIT_ROW_QUANTITY = 1,SHELF_NUMBER = "#GIRIS_RAF_ID#"}>
    PROCESS_ID = 0,
    PROCESS_NO = "",
    PERIOD_ID = session.ep.period_id,
    DEPARTMENT_ID = attributes.DEPARTMENT_IN,
    LOCATION_ID = attributes.LOCATION_IN,
    IS_SARF = 0,
    IS_SERI_SONU = 0,
    WRK_ID = "#WRK_ROW_ID_SER#-#createUUID()#",
    WRK_ROW_ID = "#WRK_ROW_ID_SER#",
    UNIT_ROW_QUANTITY = 1,
    SHELF_NUMBER = "#GIRIS_RAF_ID#"
}>

