<cfparam name="attributes.show_type" default="0">
<script>
    var ShowType='<cfoutput>#attributes.show_type#</cfoutput>';
</script>
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
    .col-6 {
    width: 48.9% !important;
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
    C2.NICKNAME AS ALIS_TEKLIFI_COMPANY,
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
    EP.EMPLOYEE_NAME+' '+EP.EMPLOYEE_SURNAME AS KIME,
     INVOICE.INVOICE_NUMBER AS SATIS_FATURA_NO,
    INVOICE.INVOICE_ID AS SATIS_FATURA_ID,
    INVOICE.INVOICE_DATE AS SATIS_FATURA_TARIHI,
    INVOICE.PERIOD_ID AS SATIS_FATURA_PERIOD
    

FROM #dsn3#.OFFER_ROW AS SATIS_TEKLIFI_SATIRLARI
    INNER JOIN #dsn3#.OFFER AS SATIS_TEKLIFI ON SATIS_TEKLIFI.OFFER_ID = SATIS_TEKLIFI_SATIRLARI.OFFER_ID
    LEFT JOIN #dsn3#.OFFER_ROW AS ALIS_TEKLIFI_SATIRLARI ON ALIS_TEKLIFI_SATIRLARI.WRK_ROW_ID = SATIS_TEKLIFI_SATIRLARI.WRK_ROW_RELATION_ID
    INNER JOIN #dsn3#.OFFER AS ALIS_TEKLIFI ON ALIS_TEKLIFI.OFFER_ID = ALIS_TEKLIFI_SATIRLARI.OFFER_ID
    LEFT JOIN #dsn3#.ORDER_ROW AS SATIS_SIPARISI_SATIRLARI ON SATIS_SIPARISI_SATIRLARI.WRK_ROW_RELATION_ID = SATIS_TEKLIFI_SATIRLARI.WRK_ROW_ID
    LEFT JOIN #dsn3#.ORDERS AS SATIS_SIPARISI ON SATIS_SIPARISI.ORDER_ID = SATIS_SIPARISI_SATIRLARI.ORDER_ID
    LEFT JOIN #dsn3#.ORDER_ROW AS ALIS_SIPARIS_SATIRLARI 
        ON ALIS_SIPARIS_SATIRLARI.WRK_ROW_RELATION_ID = CAST(SATIS_TEKLIFI_SATIRLARI.WRK_ROW_ID AS VARCHAR) + '_XX'
    LEFT JOIN #dsn3#.ORDERS AS ALIS_SIPARIS ON ALIS_SIPARIS.ORDER_ID = ALIS_SIPARIS_SATIRLARI.ORDER_ID
    LEFT JOIN #dsn3#.OFFER AS OA ON OA.OFFER_ID = ALIS_TEKLIFI.FOR_OFFER_ID
    LEFT JOIN #dsn3#.INTERNALDEMAND AS IDD ON IDD.INTERNAL_ID = OA.INTERNALDEMAND_ID
    LEFT JOIN #dsn#.COMPANY AS C ON C.COMPANY_ID=IDD.FROM_COMPANY_ID
    LEFT JOIN #dsn#.EMPLOYEE_POSITIONS AS EP ON EP.POSITION_CODE=IDD.TO_POSITION_CODE
        LEFT JOIN #dsn3#.ORDERS_INVOICE AS OI ON OI.ORDER_ID=SATIS_SIPARISI.ORDER_ID
    LEFT JOIN (
        SELECT INVOICE_NUMBER,INVOICE_DATE,INVOICE_ID,1 AS PERIOD_ID FROM #dsn#_#year(now())-1#_#session.ep.company_id#.INVOICE
        UNION ALL
        SELECT INVOICE_NUMBER,INVOICE_DATE,INVOICE_ID,2 AS PERIOD_ID FROM #dsn2#.INVOICE
    ) AS INVOICE ON INVOICE.INVOICE_ID=OI.INVOICE_ID AND INVOICE.PERIOD_ID=OI.PERIOD_ID    
    LEFT JOIN #dsn#.COMPANY AS C2 ON C2.COMPANY_ID=TRY_CAST(REPLACE(ALIS_TEKLIFI.OFFER_TO, ',', '') AS INT)
WHERE SATIS_TEKLIFI_SATIRLARI.OFFER_ID = SATIS_TEKLIFI_SATIRLARI.OFFER_ID FOR JSON PATH
) datam



</cfquery>
<cfdump var="#getData#" label="getData" format="html" display="false">

<div class="container">
  <h3 class="mb-4">Talep Bazlı Teklif & Sipariş İlişkileri</h3>
  <div id="output" <cfif attributes.show_type eq 2>style="display:flex;flex-wrap:wrap"</cfif>></div>
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
      SIPARIS_ID: row.SATIS_SIPARIS_ID,
      ID: satisId,
      ALISLAR: [],
      FATURALAR:[]
    };
  }

  grouped[demandId].SATIS[satisId].ALISLAR.push({
    NO: row.ALIS_TEKLIF_NO,
    TARIH: row.ALIS_TEKLIFI_TARIHI,
    SIPARIS_NO: row.ALIS_SIPARIS_NO,
    SIPARIS_TARIH: row.ALIS_SIPARIS_TARIHI,
    SIPARIS_ID: row.ALIS_SIPARIS_ID,
    FIRMA: row.ALIS_TEKLIF_COMPANY,
    ID: row.ALIS_TEKLIF_ID
  });

  if (
    row.SATIS_FATURA_NO &&
    !grouped[demandId].SATIS[satisId].FATURALAR.some(f => f.FATURA_NO === row.SATIS_FATURA_NO)
  ) {
  grouped[demandId].SATIS[satisId].FATURALAR.push({
    NO: row.SATIS_FATURA_NO,
    FATURA_TARIH: row.SATIS_FATURA_TARIHI,        
    SATIS_FATURA_ID: row.SATIS_FATURA_ID,
    SATIS_FATURA_PERIOD: row.SATIS_FATURA_PERIOD
    
  });
    }
    const unique = [
  ...new Map(grouped[demandId].SATIS[satisId].FATURALAR.map(item => [JSON.stringify(item), item])).values()
];
grouped[demandId].SATIS[satisId].FATURALAR=unique;
});

// HTML Oluştur
let html = "";
Object.values(grouped).forEach(demand => {
 if(demand.INTERNAL_NUMBER){
    if(ShowType=="0"){
html += `<div class="offer-block ">`;
}
else if(ShowType=="1"){
    html += `<div class="offer-block ">`;
}
else if(ShowType=="2"){
    html += `<div class="offer-block col col-6" style="width: 100%;margin-left:5px">`;
}
else if(ShowType=="3"){
    html += `<div class="offer-block ">`;
}


    
  html += `<div class="mb-2"><span  class="section-title">📦 Talep:</span><a href="javascript://"  onclick='window.location.href="/index.cfm?fuseaction=purchase.list_purchasedemand&event=upd&id=${demand.INTERNAL_ID}"'>${demand.INTERNAL_NUMBER} –👤  ${demand.KIME} (${demand.NICKNAME})</a> </div>`;

  Object.values(demand.SATIS).forEach(satis => {
   if(ShowType!="3"){
    html += `<div class="sub-section"><span class="text-primary">📄 Satış Teklifi:</span> <a href="javascript://" onclick='window.location.href="/index.cfm?fuseaction=sales.list_offer&event=upd&offer_id=${satis.ID}"'> ${satis.NO} <small class="text-muted">📅 ${new Date(satis.TARIH).toLocaleDateString()}</small></a>`;
    }
if(ShowType=="0"){
    html += `<div class="sub-section">`;
    satis.ALISLAR.forEach(alis => {
      html += `<div>📥 Alış Teklifi: <a href="javascript://" onclick='window.location.href="/index.cfm?fuseaction=purchase.list_offer&event=upd&offer_id=${alis.ID}"'> ${alis.NO} - ${alis.FIRMA} <small class="text-muted">📅 ${new Date(alis.TARIH).toLocaleDateString()}</small></a>`;
      if (alis.SIPARIS_NO) {
        html += ` → <span class="text-success">📬 Sipariş: </span> <a href="javascript://" onclick='window.location.href="/index.cfm?fuseaction=purchase.list_order&event=upd&order_id=${alis.SIPARIS_ID}"'>${alis.SIPARIS_NO} <small class="text-muted">📅 ${new Date(alis.SIPARIS_TARIH).toLocaleDateString()}</small></a>`;
      }
      html += `</div>`;
    });
}
else if(ShowType=="1"){
     html += `<div class="sub-section" style="display:flex">`;
        satis.ALISLAR.forEach(alis => {
      html += `<div class="col col-3 card" style="display:flex !important;justify-content:space-evenly;text-align:center;padding:5px !important;padding-top:5px !important;flex-direction:column;margin-left:5px">📥 Alış Teklifi: <a href="javascript://" onclick='window.location.href="/index.cfm?fuseaction=purchase.list_offer&event=upd&offer_id=${alis.ID}"'> ${alis.NO} <small style="display:block" class="text-muted">📅 ${new Date(alis.TARIH).toLocaleDateString()}</small></a>`;
      if (alis.SIPARIS_NO) {
        html += ` <hr style="border: 0.1px solid #80808021;width: 100%;"> <span class="text-success">📬 Sipariş: </span> <a href="javascript://" onclick='window.location.href="/index.cfm?fuseaction=purchase.list_order&event=upd&order_id=${alis.SIPARIS_ID}"'>${alis.SIPARIS_NO} <small class="text-muted">📅 ${new Date(alis.SIPARIS_TARIH).toLocaleDateString()}</small></a>`;
      }
      html += `</div>`;
    });
}
else if(ShowType=="2"){
     html += `<div class="sub-section" style="display:flex;flex-wrap:wrap">`;
        satis.ALISLAR.forEach(alis => {
      html += `<div class="col col-3 card" style="display:flex !important;justify-content:space-evenly;text-align:center;padding:5px !important;padding-top:5px !important;flex-direction:column;margin-left:5px">📥 Alış Teklifi: <a href="javascript://" onclick='window.location.href="/index.cfm?fuseaction=purchase.list_offer&event=upd&offer_id=${alis.ID}"'> ${alis.NO} <small style="display:block" class="text-muted">📅 ${new Date(alis.TARIH).toLocaleDateString()}</small></a>`;
      if (alis.SIPARIS_NO) {
        html += ` <hr style="border: 0.1px solid #80808021;width: 100%;"> <span class="text-success">📬 Sipariş: </span> <a href="javascript://" onclick='window.location.href="/index.cfm?fuseaction=purchase.list_order&event=upd&order_id=${alis.SIPARIS_ID}"'>${alis.SIPARIS_NO} <small class="text-muted">📅 ${new Date(alis.SIPARIS_TARIH).toLocaleDateString()}</small></a>`;
      }
      html += `</div>`;
    });
}
else if(ShowType=="3"){
    html += `<div class="sub-section">`;
    if(satis){html+=`<span class="">📄 Satış Teklifi: ✅</span> |`}else{html+=`<span class="">📄 Satış Teklifi: ❌</span> |`}
    if(satis.ALISLAR){html+=`<span class="">📥 Alış Teklifi: ✅</span> |`}else{html+=`<span class="">📥 Alış Teklifi: ❌</span> |`}
    var ty=0;
    satis.ALISLAR.forEach(alis => {if (alis.SIPARIS_NO) {ty++;}    });
    if(ty>0){html+=`<span class="">📬 Alış Siparişi: ✅</span> |`}else{html+=`<span class="">📬 Alış Siparişi: ❌</span> |`}
    if(satis.SIPARIS_NO) {html+=`<span class="">📝 Satış Siparişi: ✅</span> |`}else{html+=`<span class="">📝 Satış  Siparişi: ❌</span> |`}
    var ty=0;
    satis.FATURALAR.forEach(alis => {if (alis.SATIS_FATURA_ID) {ty++;}    });
    if(ty>0){html+=`<span class="">🧾 Satış Faturası: ✅</span> |`}else{html+=`<span class="">🧾 Satış Faturası: ❌</span> |`}
}

    html += `</div>`;

    if(satis.SIPARIS_NO ) {
     if(ShowType!="3"){
        html += `<div class="mt-2"> <span class="text-success">📝 Satış Siparişi:</span><a href="javascript://" onclick='window.location.href="/index.cfm?fuseaction=sales.list_order&event=upd&order_id=${satis.SIPARIS_ID}"'> ${satis.SIPARIS_NO} <small class="text-muted">📅${new Date(satis.SIPARIS_TARIHI).toLocaleDateString()}</small></a></div>`;
      satis.FATURALAR.forEach(fatura => {
        html += `<div class="mt-2"> <span class="text-success">🧾 Fatura:</span><a href="javascript://" onclick='window.location.href="/index.cfm?fuseaction=invoice.form_add_bill&event=upd&iid=${fatura.SATIS_FATURA_ID}"'> ${fatura.NO} <small class="text-muted">📅${new Date(fatura.FATURA_TARIH).toLocaleDateString()} </small></a>`;
        if (fatura.SATIS_FATURA_PERIOD) {
          html += ` <small class="text-muted">(${fatura.SATIS_FATURA_PERIOD})</small>`;
        }
        html += `</div>`;
        
      });
    }
    }else {
         if(ShowType!="3"){
      html += `<div class="mt-2"> <span class="text-danger">📝 Satış Siparişi Yok</span></div>`;
         }
    }
    //html += `<div class="mt-2">📝 Satış Siparişi: <strong>${satis.SIPARIS_NO}</strong> <small class="text-muted">(${new Date(satis.SIPARIS_TARIHI).toLocaleDateString()})</small></div>`;
    html += `</div>`;
  });

  html += `</div>`;
}
});

document.getElementById("output").innerHTML = html;
</script>
