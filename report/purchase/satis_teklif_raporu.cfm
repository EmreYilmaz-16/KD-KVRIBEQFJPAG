<!DOCTYPE html>

  <title>Talep Bazlı Teklif ve Sipariş İlişkisi</title>
  
  <style>
    .table-custom {
      font-size: 0.9rem;
    }
    .offer-block {
      background-color: #f8f9fa;
      border-radius: 8px;
      padding: 1rem;
      margin-bottom: 1rem;
      box-shadow: 0 1px 4px rgba(0,0,0,0.1);
    }
    .sub-section {
      margin-left: 1.5rem;
      margin-top: 0.5rem;
    }
    .section-title {
      font-weight: bold;
      color: #0056b3;
    }
  </style>
<cfquery name="getData" datasource="#dsn3#">
  SELECT (
SELECT 
    SATIS_TEKLIFI.OFFER_NUMBER AS SATIS_TEKLIF_NO, 
    SATIS_TEKLIFI.OFFER_ID AS SATIS_TEKLIF_ID, 
    SATIS_TEKLIFI.OFFER_DATE AS SATIS_TEKLIF_TARIHI,
    ALIS_TEKLIFI.OFFER_NUMBER AS ALIS_TEKLIF_NO, 
    ALIS_TEKLIFI.OFFER_ID AS ALIS_TEKLIF_ID,
    ALIS_TEKLIFI.OFFER_DATE AS ALIS_TEKLIFI_TARIHI,
    SATIS_SIPARISI.ORDER_NUMBER AS SATIS_SIPARIS_NO,
    SATIS_SIPARISI.ORDER_ID AS SATIS_SIPARIS_ID,
    SATIS_SIPARISI.ORDER_DATE AS SATIS_SIPARISI_TARIHI,
    ALIS_SIPARIS.ORDER_ID AS ALIS_SIPARIS_ID,
    ALIS_SIPARIS.ORDER_NUMBER AS ALIS_SIPARIS_NO,
    ALIS_SIPARIS.ORDER_DATE AS ALIS_SIPARIS_TARIHI,
    IDD.INTERNAL_ID,
    IDD.INTERNAL_NUMBER,
    IDD.TARGET_DATE AS INTERNAL_DATE,
    C.NICKNAME,
    EP.EMPLOYEE_NAME+' '+EP.EMPLOYEE_SURNAME AS KIME
FROM w3Qa_1.OFFER_ROW AS SATIS_TEKLIFI_SATIRLARI
    INNER JOIN w3Qa_1.OFFER AS SATIS_TEKLIFI ON SATIS_TEKLIFI.OFFER_ID = SATIS_TEKLIFI_SATIRLARI.OFFER_ID
    LEFT JOIN w3Qa_1.OFFER_ROW AS ALIS_TEKLIFI_SATIRLARI ON ALIS_TEKLIFI_SATIRLARI.WRK_ROW_ID = SATIS_TEKLIFI_SATIRLARI.WRK_ROW_RELATION_ID
    INNER JOIN w3Qa_1.OFFER AS ALIS_TEKLIFI ON ALIS_TEKLIFI.OFFER_ID = ALIS_TEKLIFI_SATIRLARI.OFFER_ID
    LEFT JOIN w3Qa_1.ORDER_ROW AS SATIS_SIPARISI_SATIRLARI ON SATIS_SIPARISI_SATIRLARI.WRK_ROW_RELATION_ID = SATIS_TEKLIFI_SATIRLARI.WRK_ROW_ID
    LEFT JOIN w3Qa_1.ORDERS AS SATIS_SIPARISI ON SATIS_SIPARISI.ORDER_ID = SATIS_SIPARISI_SATIRLARI.ORDER_ID
    LEFT JOIN w3Qa_1.ORDER_ROW AS ALIS_SIPARIS_SATIRLARI 
        ON ALIS_SIPARIS_SATIRLARI.WRK_ROW_RELATION_ID = CAST(SATIS_TEKLIFI_SATIRLARI.WRK_ROW_ID AS VARCHAR) + '_XX'
    LEFT JOIN w3Qa_1.ORDERS AS ALIS_SIPARIS ON ALIS_SIPARIS.ORDER_ID = ALIS_SIPARIS_SATIRLARI.ORDER_ID
    LEFT JOIN w3Qa_1.OFFER AS OA ON OA.OFFER_ID = ALIS_TEKLIFI.FOR_OFFER_ID
    LEFT JOIN w3Qa_1.INTERNALDEMAND AS IDD ON IDD.INTERNAL_ID = OA.INTERNALDEMAND_ID
    LEFT JOIN w3Qa.COMPANY AS C ON C.COMPANY_ID=IDD.FROM_COMPANY_ID
    LEFT JOIN w3Qa.EMPLOYEE_POSITIONS AS EP ON EP.POSITION_CODE=IDD.TO_POSITION_CODE
WHERE SATIS_TEKLIFI_SATIRLARI.OFFER_ID = SATIS_TEKLIFI_SATIRLARI.OFFER_ID FOR JSON PATH
) datam



</cfquery>


<div class="container">
  <h3 class="mb-4">Talep Bazlı Teklif & Sipariş İlişkileri</h3>
  <div id="output"></div>
</div>

<script>
const data = <cfoutput>#getData.datam#</cfoutput>;

// Grupla
const grouped = {};
data.forEach(row => {
  const demandId = row.INTERNAL_ID;
  if (!grouped[demandId]) {
    grouped[demandId] = {
      INTERNAL_NUMBER: row.INTERNAL_NUMBER,
      NICKNAME: row.NICKNAME,
      KIME: row.KIME,
        INTERNAL_ID: row.INTERNAL_ID,
      SATIS: {}
    };
  }

  const satisId = row.SATIS_TEKLIF_ID;
  if (!grouped[demandId].SATIS[satisId]) {
    grouped[demandId].SATIS[satisId] = {
      NO: row.SATIS_TEKLIF_NO,
      TARIH: row.SATIS_TEKLIF_TARIHI,
      SIPARIS_NO: row.SATIS_SIPARIS_NO,
      SIPARIS_TARIHI: row.SATIS_SIPARISI_TARIHI,
      ID: satisId,
      ALISLAR: []
    };
  }

  grouped[demandId].SATIS[satisId].ALISLAR.push({
    NO: row.ALIS_TEKLIF_NO,
    TARIH: row.ALIS_TEKLIFI_TARIHI,
    SIPARIS_NO: row.ALIS_SIPARIS_NO,
    SIPARIS_TARIH: row.ALIS_SIPARIS_TARIHI,
    ID: row.ALIS_TEKLIF_ID
  });
});

// HTML Oluştur
let html = "";
Object.values(grouped).forEach(demand => {
 if(demand.INTERNAL_NUMBER){
    html += `<div class="offer-block">`;
  html += `<div class="mb-2"><span  class="section-title">Talep:</span><a href="javascript://"  onclick='window.location.href="/index.cfm?fuseaction=purchase.list_purchasedemand&event=upd&id=${demand.INTERNAL_ID}"'>${demand.INTERNAL_NUMBER} – ${demand.KIME} (${demand.NICKNAME})</a> </div>`;

  Object.values(demand.SATIS).forEach(satis => {
    html += `<div class="sub-section"><span class="text-primary">Satış Teklifi:</span> <a href="javascript://" onclick='window.location.href="/index.cfm?fuseaction=sales.list_offer&event=upd&offer_id=${satis.ID}"'> ${satis.NO} <small class="text-muted">(${new Date(satis.TARIH).toLocaleDateString()})</small></a>`;

    html += `<div class="sub-section">`;
    satis.ALISLAR.forEach(alis => {
      html += `<div>➤ Alış Teklifi: <a href="javascript://" onclick='window.location.href="/index.cfm?fuseaction=purchase.list_offer&event=upd&offer_id=${alis.ID}"'> ${alis.NO} <small class="text-muted">(${new Date(alis.TARIH).toLocaleDateString()})</small></a>`;
      if (alis.SIPARIS_NO) {
        html += ` → <span class="text-success">Sipariş: ${alis.SIPARIS_NO}</span> <small class="text-muted">(${new Date(alis.SIPARIS_TARIH).toLocaleDateString()})</small>`;
      }
      html += `</div>`;
    });
    html += `</div>`;

    if(satis.SIPARIS_NO) {
      html += `<div class="mt-2">➤ <span class="text-success">Satış Siparişi:</span> ${satis.SIPARIS_NO} <small class="text-muted">(${new Date(satis.SIPARIS_TARIHI).toLocaleDateString()})</small></div>`;
    }else {
      html += `<div class="mt-2">➤ <span class="text-danger">Satış Siparişi Yok</span></div>`;
    }
    //html += `<div class="mt-2">📝 Satış Siparişi: <strong>${satis.SIPARIS_NO}</strong> <small class="text-muted">(${new Date(satis.SIPARIS_TARIHI).toLocaleDateString()})</small></div>`;
    html += `</div>`;
  });

  html += `</div>`;
}
});

document.getElementById("output").innerHTML = html;
</script>
