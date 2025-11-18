<cfquery name="geto" datasource="#attributes.datasource#">
   select o.RECORD_EMP,EMPLOYEE_EMAIL,OFFER_HISTORY_ID from w3Qa_1.OFFER_HISTORY AS O 
   INNER JOIN w3Qa.EMPLOYEES AS E ON E.EMPLOYEE_ID=O.RECORD_EMP 
   WHERE OFFER_ID=#caller.offer_id# ORDER BY  OFFER_HISTORY_ID DESC 
</cfquery>



<cfmail
from="erp@kdteknik.com.tr"
to="#geto.EMPLOYEE_EMAIL#"
subject="Teklif Onay Verildi"
type="HTML">
<div>
<table>
    <tr>
        <td style="font-weight:bold">
            Teklif No:
        </td>
        <td>
            #OFFER_NUMBER#
        </td>
    </tr>
    <tr>
        <td colspan="2">
            Numaralı Teklif İçin Yanıtı Kayıt Edilmiştir<br>
            İlişkili Teklfie Ulaşmak İçin <a href="http://qa.kdteknik.com.tr/index.cfm?fuseaction=sales.list_offer&event=upd&offer_id=#caller.offer_id#">Tıklayınız !</a>

        </td>
    </tr>
</table>
</div>
</cfmail>