<!---
    Excel Template Generator
    PRODUCT_OEMS için örnek Excel dosyası oluşturur
--->

<cftry>
    <!--- Basit CSV template oluştur (her ColdFusion sürümünde çalışır) --->
    <cfset csvContent = "ETA_KODU">
    <cfloop from="1" to="50" index="i">
        <cfset csvContent = csvContent & ",OEM #i#">
    </cfloop>
    <cfset csvContent = csvContent & chr(13) & chr(10)>
    
    <!--- Örnek satırlar ekle --->
    <cfset csvContent = csvContent & "SAMPLE001,BOSCH001,SIEMENS001,BEKO001,ARCELIK001,VESTEL001">
    <cfloop from="6" to="50" index="i">
        <cfset csvContent = csvContent & ",">
    </cfloop>
    <cfset csvContent = csvContent & chr(13) & chr(10)>
    
    <cfset csvContent = csvContent & "SAMPLE002,BOSCH002,SIEMENS002,BEKO002,ARCELIK002,VESTEL002">
    <cfloop from="6" to="50" index="i">
        <cfset csvContent = csvContent & ",">
    </cfloop>
    <cfset csvContent = csvContent & chr(13) & chr(10)>
    
    <cfset csvContent = csvContent & "SAMPLE003,BOSCH003,SIEMENS003,BEKO003,ARCELIK003,VESTEL003">
    <cfloop from="6" to="50" index="i">
        <cfset csvContent = csvContent & ",">
    </cfloop>
    <cfset csvContent = csvContent & chr(13) & chr(10)>
    
    <!--- Excel formatında indirmek için dosya uzantısını .xls yap --->
    <cfheader name="Content-Disposition" value="attachment; filename=PRODUCT_OEMS_Template.xls">
    <cfheader name="Content-Type" value="application/vnd.ms-excel">
    <cfheader name="Content-Length" value="#len(csvContent)#">
    
    <!--- CSV içeriğini Excel olarak gönder --->
    <cfcontent type="application/vnd.ms-excel" reset="true">#csvContent#</cfcontent>
    
    <cfcatch type="any">
        <!--- En basit hali: düz metin --->
        <cfheader name="Content-Disposition" value="attachment; filename=PRODUCT_OEMS_Template.csv">
        <cfheader name="Content-Type" value="text/csv">
        
        <cfoutput>#csvContent#</cfoutput>
    </cfcatch>
</cftry>
