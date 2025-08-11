<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>GTIP Import Excel Şablonu Oluştur</title>
</head>
<body>
    <h2>Excel Şablonu Oluştur</h2>
    
    <cfset excelData = queryNew("ETA_KODU,GTIP_NUMARASI", "varchar,varchar")>
    
    <!--- Örnek veriler ekle --->
    <cfset queryAddRow(excelData)>
    <cfset querySetCell(excelData, "ETA_KODU", "ORNK001")>
    <cfset querySetCell(excelData, "GTIP_NUMARASI", "1234567890")>
    
    <cfset queryAddRow(excelData)>
    <cfset querySetCell(excelData, "ETA_KODU", "ORNK002")>
    <cfset querySetCell(excelData, "GTIP_NUMARASI", "0987654321")>
    
    <cfset queryAddRow(excelData)>
    <cfset querySetCell(excelData, "ETA_KODU", "ORNK003")>
    <cfset querySetCell(excelData, "GTIP_NUMARASI", "5555666677")>
    
    <cfset filePath = expandPath("./gtip_import_template.xlsx")>
    
    <cfspreadsheet action="write" 
                   query="excelData" 
                   filename="#filePath#" 
                   overwrite="true"
                   headerrow="1">
    
    <p>Excel şablonu oluşturuldu: <a href="gtip_import_template.xlsx" download>gtip_import_template.xlsx</a></p>
    <p><a href="gtip_import.cfm">GTIP Import Sayfasına Dön</a></p>
    
    <h3>Şablon İçeriği:</h3>
    <table border="1" cellpadding="5" cellspacing="0">
        <tr>
            <th>ETA_KODU</th>
            <th>GTIP_NUMARASI</th>
        </tr>
        <cfloop query="excelData">
            <tr>
                <td>#ETA_KODU#</td>
                <td>#GTIP_NUMARASI#</td>
            </tr>
        </cfloop>
    </table>
</body>
</html>
