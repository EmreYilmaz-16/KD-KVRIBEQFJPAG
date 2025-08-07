<!---
    Excel Template Generator
    PRODUCT_OEMS için örnek Excel dosyası oluşturur
--->

<cftry>
    <!--- Geçici dosya yolu --->
    <cfset tempFilePath = getTempDirectory() & "PRODUCT_OEMS_Template_" & createUUID() & ".xlsx">
    
    <!--- Query kullanarak veri hazırla --->
    <cfset templateData = queryNew("ETA_KODU")>
    
    <!--- OEM kolonlarını ekle --->
    <cfloop from="1" to="50" index="i">
        <cfset queryAddColumn(templateData, "OEM_#i#", "varchar", [])>
    </cfloop>
    
    <!--- Örnek veri satırları ekle --->
    <cfset queryAddRow(templateData, {
        ETA_KODU = "SAMPLE001",
        OEM_1 = "BOSCH001",
        OEM_2 = "SIEMENS001", 
        OEM_3 = "BEKO001",
        OEM_4 = "ARCELIK001",
        OEM_5 = "VESTEL001"
    })>
    
    <cfset queryAddRow(templateData, {
        ETA_KODU = "SAMPLE002",
        OEM_1 = "BOSCH002",
        OEM_2 = "SIEMENS002",
        OEM_3 = "BEKO002", 
        OEM_4 = "ARCELIK002",
        OEM_5 = "VESTEL002"
    })>
    
    <cfset queryAddRow(templateData, {
        ETA_KODU = "SAMPLE003",
        OEM_1 = "BOSCH003",
        OEM_2 = "SIEMENS003",
        OEM_3 = "BEKO003",
        OEM_4 = "ARCELIK003", 
        OEM_5 = "VESTEL003"
    })>
    
    <!--- Excel dosyasını oluştur --->
    <cfspreadsheet action="write" 
                   query="templateData" 
                   filename="#tempFilePath#" 
                   overwrite="true"
                   format="xlsx">
    
    <!--- Dosyayı oku ve kullanıcıya gönder --->
    <cffile action="readbinary" file="#tempFilePath#" variable="excelFile">
    
    <!--- Headers ayarla --->
    <cfheader name="Content-Disposition" value="attachment; filename=PRODUCT_OEMS_Template.xlsx">
    <cfheader name="Content-Type" value="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet">
    <cfheader name="Content-Length" value="#arrayLen(excelFile)#">
    
    <!--- Dosyayı gönder --->
    <cfcontent type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" variable="#excelFile#">
    
    <!--- Geçici dosyayı sil --->
    <cffile action="delete" file="#tempFilePath#">
    
    <cfcatch type="any">
        <!--- Hata durumunda basit CSV oluştur --->
        <cfheader name="Content-Disposition" value="attachment; filename=PRODUCT_OEMS_Template.csv">
        <cfheader name="Content-Type" value="text/csv">
        
        <cfset csvContent = "ETA_KODU">
        <cfloop from="1" to="50" index="i">
            <cfset csvContent = csvContent & ",OEM_#i#">
        </cfloop>
        <cfset csvContent = csvContent & chr(13) & chr(10)>
        
        <!--- Örnek satırlar --->
        <cfset csvContent = csvContent & "SAMPLE001,BOSCH001,SIEMENS001,BEKO001,ARCELIK001,VESTEL001" & chr(13) & chr(10)>
        <cfset csvContent = csvContent & "SAMPLE002,BOSCH002,SIEMENS002,BEKO002,ARCELIK002,VESTEL002" & chr(13) & chr(10)>
        <cfset csvContent = csvContent & "SAMPLE003,BOSCH003,SIEMENS003,BEKO003,ARCELIK003,VESTEL003" & chr(13) & chr(10)>
        
        <cfcontent type="text/csv" variable="#toBinary(toBase64(csvContent))#">
    </cfcatch>
</cftry>
