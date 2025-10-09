<cfdump var="#attributes#">

<cfquery name="depo_kontrol" datasource="#dsn3#">
    select DISTINCT CAST(DEPARTMENT_ID AS varchar)+'-'+CAST(LOCATION_ID AS varchar) AS DEPO  from  w3Qa_1.PBS_SERIAL_SAYIM WHERE SAYIM_ID IN(#attributes.SAYIM_IDS#)
</cfquery>
<cfif depo_kontrol.recordcount gt 1>
    <cfset attributes.error="true">
    <cfset attributes.error_message="Seçilen sayımlar farklı depolara ait. Lütfen aynı depoya ait sayımları seçiniz.">
    <cfset attributes.error_code=2>
    <cfabort>
</cfif>

<cfquery name="getrows" datasource="#dsn3#">
select SAYIM_ID,SERIAL_NUMBER,PRODUCT_ID,STOCK_ID,SHELF_NUMBER,PRODUCT_CODE_2 from  w3Qa_1.PBS_SERIAL_SAYIM_ROW WHERE SAYIM_ID IN (#attributes.SAYIM_IDS#)
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
    DELETE FROM PBS_SERIAL_SAYIM WHERE SAYIM_ID in(#attributes.SAYIM_IDS#)
</cfquery>
<cfquery name="del_rows" datasource="#dsn3#">
    DELETE FROM PBS_SERIAL_SAYIM_ROW WHERE SAYIM_ID in(#attributes.SAYIM_IDS#)
</cfquery>

   <cfset recordDate = now()>
   <cfset sayim_date = now()>
        <!--- DEPO değerini ayır (DEPARTMENT_ID-LOCATION_ID formatında) --->
        <cfset depoValues = listToArray(depo_kontrol.DEPO, "-")>
        <cfset departmentId = depoValues[1]>
        <cfset locationId = depoValues[2]>
        
        <cfquery name="GETPAPER" datasource="w3Qa_1">
            select SAYIM_NO,SAYIM_NUMBER from w3Qa_1.PBS_PAPER_NUMBERS
        </cfquery>
        <cfset zero_Count=0>
        <cfif len(GETPAPER.SAYIM_NUMBER) eq 1>
            <cfset zero_Count=3>
        <cfelseif len(GETPAPER.SAYIM_NUMBER) eq 2>
            <cfset zero_Count=2>
        <cfelseif len(GETPAPER.SAYIM_NUMBER) eq 3>
            <cfset zero_Count=1>   
        </cfif>
            <cfset paper_number=REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(GETPAPER.SAYIM_NUMBER,'0',''),'1',''),'2',''),'3',''),'4',''),'5',''),'6',''),'7',''),'8',''),'9','')>
            <cfset paper_number=GETPAPER.SAYIM_NO & REPEATSTRING('0',zero_Count) & (GETPAPER.SAYIM_NUMBER+1)>
            
            <cfquery name="updatepaper" datasource="w3Qa_1">
                update PBS_PAPER_NUMBERS set SAYIM_NUMBER=SAYIM_NUMBER+1
            </cfquery>

        
        <!--- Veritabanına kayıt ekleme --->
        <cfquery datasource="w3Qa_1" result="insertResult">
            INSERT INTO PBS_SERIAL_SAYIM (
                PAPER_NUMBER,
                DEPARTMENT_ID,
                LOCATION_ID,
                SAYIM_DATE,
                RECORD_DATE,
                RECORD_EMP
            ) VALUES (
                <cfqueryparam value="#paper_number#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#departmentId#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#locationId#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#sayim_date#" cfsqltype="cf_sql_timestamp">,
                <cfqueryparam value="#recordDate#" cfsqltype="cf_sql_timestamp">,
                <cfqueryparam value="#session.ep.userid#" cfsqltype="cf_sql_integer">
            )
        </cfquery> 

        <cfset newSayimId = insertResult.generatedKey>
        <cfset rowCount = yeni_tablo.recordCount>
        <cfloop query="yeni_tablo">
            <cfquery datasource="w3Qa_1">
                        INSERT INTO PBS_SERIAL_SAYIM_ROW (
                            SAYIM_ID,
                            SERIAL_NUMBER,
                            SHELF_NUMBER,
                            PRODUCT_CODE_2,
                            IN_OUT,
                            PRODUCT_ID,                            
                            STOCK_ID
                        ) VALUES (
                            <cfqueryparam value="#newSayimId#" cfsqltype="cf_sql_integer">,
                            <cfqueryparam value="#trim(SERIAL_NUMBER)#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#trim(SHELF_NUMBER)#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#trim(PRODUCT_CODE_2)#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="1" cfsqltype="cf_sql_bit">,
                            <cfqueryparam value="#PRODUCT_ID#" cfsqltype="cf_sql_integer">,
                            <cfqueryparam value="#STOCK_ID#" cfsqltype="cf_sql_integer">
                        )
                    </cfquery>
        </cfloop>