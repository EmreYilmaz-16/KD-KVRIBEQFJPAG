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
SELECT SHELF_NUMBER,SERIAL_NO,SUM(CASE WHEN IN_OUT =1 THEN 1 ELSE -1 END) AS V FROM w3Qa_1.SERVICE_GUARANTY_NEW
WHERE SERIAL_NO=<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.seri_no#">
GROUP BY SHELF_NUMBER,SERIAL_NO
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
                <th>Stok Miktarı</th>
            </tr>
            <cfloop query="seriSB">
                <tr>
                    <td>#SHELF_NUMBER#</td>
                    <td>#SERIAL_NO#</td>
                    <td style="text-align: center; <cfif V gt 0>color: green;<cfelseif V lt 0>color: red;<cfelse>color: orange;</cfif>">#V#</td>
                </tr>
            </cfloop>
        </table>
    <cfelse>
        <p>Bu seri numarası için raf bilgisi bulunamadı.</p>
    </cfif>
</cfoutput>

</cfif>