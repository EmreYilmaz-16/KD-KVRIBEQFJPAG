<cfdump var="#attributes#">
<cfabort>
<cfquery name="getrows" datasource="#dsn3#">
select SAYIM_ID,SERIAL_NUMBER,PRODUCT_ID,STOCK_ID,SHELF_NUMBER,PRODUCT_CODE_2 from  w3Qa_1.PBS_SERIAL_SAYIM_ROW WHERE SAYIM_ID IN (#ATTsayimId#)
</cfquery>

<cfset yeni_tablo=queryNew("SAYIM_ID,SERIAL_NUMBER,PRODUCT_ID,STOCK_ID,SHELF_NUMBER,PRODUCT_CODE_2","integer,varchar,integer,integer,varchar,varchar")>
<cfloop query="getrows">
    <cfif not listfind(valueList( yeni_tablo.SERIAL_NUMBER),getrows.SERIAL_NUMBER)>
        <cfset temp=queryAddRow(yeni_tablo)>
        <cfset temp=querySetCell(yeni_tablo,"SAYIM_ID",getrows.SAYIM_ID)>
        <cfset temp=querySetCell(yeni_tablo,"SERIAL_NUMBER",getrows.SERIAL_NUMBER)>
        <cfset temp=querySetCell(yeni_tablo,"PRODUCT_ID",getrows.PRODUCT_ID)>
        <cfset temp=querySetCell(yeni_tablo,"STOCK_ID",getrows.STOCK_ID)>
        <cfset temp=querySetCell(yeni_tablo,"SHELF_NUMBER",getrows.SHELF_NUMBER)>
        <cfset temp=querySetCell(yeni_tablo,"PRODUCT_CODE_2",getrows.PRODUCT_CODE_2)>
    </cfif>
</cfloop>
<cfdump var="#yeni_tablo#">


<cfquery name="del_mains" datasource="#dsn3#">
    DELETE FROM PBS_SERIAL_SAYIM_ROW WHERE SAYIM_ID
</cfquery>