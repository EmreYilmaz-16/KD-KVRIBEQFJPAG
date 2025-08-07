<!---
    Excel Template Generator
    PRODUCT_OEMS için örnek Excel dosyası oluşturur
--->

<cfset dsn = "YOUR_DSN">

<!--- Excel dosyası oluştur --->
<cfspreadsheet action="new" name="templateSheet">

<!--- Başlık satırını oluştur --->
<cfset headerRow = "ETA_KODU">
<cfloop from="1" to="50" index="i">
    <cfset headerRow = headerRow & ",OEM_#i#">
</cfloop>

<!--- Başlık satırını ekle --->
<cfspreadsheet action="addRow" name="templateSheet" data="#headerRow#">

<!--- Örnek veri satırları ekle --->
<cfset sampleData = [
    "SAMPLE001,BOSCH001,SIEMENS001,BEKO001,ARCELIK001,VESTEL001",
    "SAMPLE002,BOSCH002,SIEMENS002,BEKO002,ARCELIK002,VESTEL002", 
    "SAMPLE003,BOSCH003,SIEMENS003,BEKO003,ARCELIK003,VESTEL003"
]>

<cfloop array="#sampleData#" index="rowData">
    <cfspreadsheet action="addRow" name="templateSheet" data="#rowData#">
</cfloop>

<!--- Başlık satırını formatla --->
<cfspreadsheet action="formatRow" name="templateSheet" row="1" 
               bold="true" 
               fgcolor="white" 
               bgcolor="blue"
               alignment="center">

<!--- Kolon genişliklerini ayarla --->
<cfspreadsheet action="formatColumn" name="templateSheet" column="1" width="15">
<cfloop from="2" to="51" index="i">
    <cfspreadsheet action="formatColumn" name="templateSheet" column="#i#" width="12">
</cfloop>

<!--- Dosyayı kullanıcıya gönder --->
<cfheader name="Content-Disposition" value="attachment; filename=PRODUCT_OEMS_Template.xlsx">
<cfheader name="Content-Type" value="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet">

<cfspreadsheet action="write" name="templateSheet" filename="" format="xlsx">
