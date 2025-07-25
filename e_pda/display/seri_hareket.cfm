<cf_box title="Seri Hareket Bilgileri">
<cfparam name="attributes.seri_no" default="">
<cfform method="post" action="#request.self#?fuseaction=#attributes.fuseaction#">
   <cfoutput> <input type="text" name="seri_no" value="#attributes.seri_no#"></cfoutput>
   <input type="submit" name="submit" value="Gönder">
</cfform>

<cfif len(attributes.seri_no)>
    <cfset attributes.seri_no = trim(attributes.seri_no)>
    <cfset attributes.seri_no = ucase(attributes.seri_no)>

    <cfquery name="getSeriHareket" datasource="#dsn3#">
 SELECT SERIAL_NO,CASE WHEN IN_OUT=1 THEN 'GIRIS' ELSE 'CIKIS' END GS,PROCESS_CAT,DEPARTMENT_ID,LOCATION_ID,SHELF_NUMBER 
 FROM w3Qa_1.SERVICE_GUARANTY_NEW WHERE SERIAL_NO='#attributes.seri_no#' 
    </cfquery>
<cfquery name="seriSB" datasource="#dsn3#">
SELECT SHELF_NUMBER,SERIAL_NO,DEPARTMENT_ID,LOCATION_ID,SUM(CASE WHEN IN_OUT =1 THEN 1 ELSE -1 END) AS V FROM w3Qa_1.SERVICE_GUARANTY_NEW
WHERE SERIAL_NO=<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.seri_no#">
GROUP BY SHELF_NUMBER,SERIAL_NO,DEPARTMENT_ID,LOCATION_ID
</cfquery>

<cfquery name="depodakiseri" datasource="#dsn3#">
SELECT 
    T.DEPARTMENT_ID,
    T.LOCATION_ID,
    T.SERIAL_NO,
    T.V,
    ISNULL(D.DEPARTMENT_HEAD, 'Bilinmeyen Departman') AS DEPARTMENT_NAME,
    ISNULL(SL.COMMENT, 'Bilinmeyen Lokasyon') AS LOCATION_NAME
FROM (
    SELECT DEPARTMENT_ID,LOCATION_ID,SERIAL_NO,SUM(CASE WHEN IN_OUT =1 THEN 1 ELSE -1 END) AS V 
    FROM w3Qa_1.SERVICE_GUARANTY_NEW 
    GROUP BY SERIAL_NO,DEPARTMENT_ID,LOCATION_ID
) AS T 
LEFT JOIN w3Qa.DEPARTMENT AS D ON D.DEPARTMENT_ID = T.DEPARTMENT_ID
LEFT JOIN w3Qa.STOCKS_LOCATION AS SL ON SL.DEPARTMENT_ID = T.DEPARTMENT_ID AND SL.LOCATION_ID = T.LOCATION_ID
WHERE T.V > 0
ORDER BY T.DEPARTMENT_ID, T.LOCATION_ID, T.SERIAL_NO
</cfquery>
<cfoutput>
    <h3>Seri Hareket Bilgileri - #attributes.seri_no#</h3>
    <cfif getSeriHareket.recordCount gt 0>
        <table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse; margin-bottom: 20px;">
            <tr style="background-color: ##f0f0f0;">
                <th>Seri No</th>
                <th>Giriş/Çıkış</th>
                <th>İşlem Kategorisi</th>
                <th>Departman ID</th>
                <th>Lokasyon ID</th>
                <th>Raf Numarası</th>
            </tr>
            <cfloop query="getSeriHareket">
                <tr>
                    <td>#SERIAL_NO#</td>
                    <td>#GS#</td>
                    <td>#PROCESS_CAT#</td>
                    <td>#DEPARTMENT_ID#</td>
                    <td>#LOCATION_ID#</td>
                    <td>#SHELF_NUMBER#</td>
                </tr>
            </cfloop>
        </table>
    <cfelse>
        <p>Bu seri numarası için hareket kaydı bulunamadı.</p>
    </cfif>

    <h3>Raf Bazında Stok Durumu</h3>
    <cfif seriSB.recordCount gt 0>
        <table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse;">
            <tr style="background-color: ##f0f0f0;">
                <th>Raf Numarası</th>
                <th>Seri No</th>
                <th>Departman ID</th>
                <th>Lokasyon ID</th>
                <th>Stok Miktarı</th>
            </tr>
            <cfloop query="seriSB">
                <tr>
                    <td>#SHELF_NUMBER#</td>
                    <td>#SERIAL_NO#</td>
                    <td>#DEPARTMENT_ID#</td>
                    <td>#LOCATION_ID#</td>
                    <td style="text-align: center; <cfif V gt 0>color: green;<cfelseif V lt 0>color: red;<cfelse>color: orange;</cfif>">#V#</td>
                </tr>
            </cfloop>
        </table>
    <cfelse>
        <p>Bu seri numarası için raf bilgisi bulunamadı.</p>
    </cfif>

    <h3>Tüm Departman ve Lokasyonlardaki Seriler</h3>
    <cfif depodakiseri.recordCount gt 0>
        <style>
            .department-container {
                display: flex;
                flex-wrap: wrap;
                gap: 15px;
                margin: 10px 0;
            }
            .department-group {
                border: 2px solid ##e6f3ff;
                border-radius: 8px;
                padding: 10px;
                min-width: 350px;
                max-width: 450px;
                background-color: ##f9f9f9;
            }
            .department-header {
                background-color: ##e6f3ff;
                padding: 8px;
                margin: -10px -10px 10px -10px;
                border-radius: 6px 6px 0 0;
                font-weight: bold;
                text-align: center;
                font-size: 13px;
            }
            .department-table {
                width: 100%;
                border-collapse: collapse;
                margin-bottom: 10px;
            }
            .department-count {
                text-align: center;
                font-weight: bold;
                color: ##666;
                font-size: 12px;
            }
        </style>
        
        <div class="department-container">
            <cfset currentDept = "">
            <cfset currentLoc = "">
            <cfset deptCount = 0>
            <cfset groupContent = "">
            
            <cfloop query="depodakiseri">
                <cfif DEPARTMENT_ID NEQ currentDept OR LOCATION_ID NEQ currentLoc>
                    <cfif deptCount gt 0>
                        <cfset groupContent = groupContent & "</table><div class='department-count'>Toplam: #deptCount# seri</div></div>">
                        <cfoutput>#groupContent#</cfoutput>
                    </cfif>
                    <cfset currentDept = DEPARTMENT_ID>
                    <cfset currentLoc = LOCATION_ID>
                    <cfset deptCount = 0>
                    <cfset groupContent = "<div class='department-group'>">
                    <cfset groupContent = groupContent & "<div class='department-header'>#DEPARTMENT_NAME# (#DEPARTMENT_ID#) - #LOCATION_NAME# (#LOCATION_ID#)</div>">
                    <cfset groupContent = groupContent & "<table class='department-table' border='1' cellpadding='3' cellspacing='0'>">
                    <cfset groupContent = groupContent & "<tr style='background-color: ##f0f0f0; font-size: 12px;'><th>Seri No</th><th>Miktar</th></tr>">
                </cfif>
                <cfset groupContent = groupContent & "<tr style='font-size: 11px;'><td>#SERIAL_NO#</td><td style='text-align: center; color: green;'>#V#</td></tr>">
                <cfset deptCount = deptCount + 1>
            </cfloop>
            
            <cfif deptCount gt 0>
                <cfset groupContent = groupContent & "</table><div class='department-count'>Toplam: #deptCount# seri</div></div>">
                <cfoutput>#groupContent#</cfoutput>
            </cfif>
        </div>
        
        <div style="text-align: center; margin-top: 20px; padding: 10px; background-color: ##e6ffe6; border-radius: 5px;">
            <strong>Genel Toplam Seri Sayısı: #depodakiseri.recordCount#</strong>
        </div>
    <cfelse>
        <p>Hiç seri bulunamadı.</p>
    </cfif>
</cfoutput>

</cfif>
</cf_box>