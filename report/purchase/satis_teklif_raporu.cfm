<cfquery name="hazirlik1" datasource="#dsn3#">
  IF OBJECT_ID('SATIS_TEKLIF_ALIS_TEKLIF', 'U') IS NOT NULL
    DROP TABLE SATIS_TEKLIF_ALIS_TEKLIF;

SELECT DISTINCT 
    SATIS_TEKLIFI.OFFER_NUMBER AS SATIS_TEKLIF_NO, 
    SATIS_TEKLIFI.OFFER_ID AS SATIS_TEKLIF_ID, 
    SATIS_TEKLIFI.OFFER_DATE AS SATIS_TEKLIF_TARIHI,
    ALIS_TEKLIFI.OFFER_ID AS ALIS_TEKLIF_ID
INTO SATIS_TEKLIF_ALIS_TEKLIF
FROM w3Qa_1.INTERNALDEMAND_ROW AS IRR
LEFT JOIN w3Qa_1.INTERNALDEMAND AS IDD 
    ON IDD.INTERNAL_ID = IRR.I_ID
LEFT JOIN w3Qa_1.OFFER_ROW AS ALIS_TEKLIFI_SATIRLARI_MAIN 
    ON ALIS_TEKLIFI_SATIRLARI_MAIN.WRK_ROW_RELATION_ID = IRR.WRK_ROW_ID
LEFT JOIN w3Qa_1.OFFER_ROW AS ALIS_TEKLIFI_SATIRLARI 
    ON ALIS_TEKLIFI_SATIRLARI.WRK_ROW_RELATION_ID = ALIS_TEKLIFI_SATIRLARI_MAIN.WRK_ROW_ID
LEFT JOIN w3Qa_1.OFFER AS ALIS_TEKLIFI 
    ON ALIS_TEKLIFI.OFFER_ID = ALIS_TEKLIFI_SATIRLARI.OFFER_ID
LEFT JOIN w3Qa_1.OFFER_ROW AS SATIS_TEKLIFI_SATIRLARI 
    ON SATIS_TEKLIFI_SATIRLARI.WRK_ROW_RELATION_ID = ALIS_TEKLIFI_SATIRLARI.WRK_ROW_ID
LEFT JOIN w3Qa_1.OFFER AS SATIS_TEKLIFI 
    ON SATIS_TEKLIFI.OFFER_ID = SATIS_TEKLIFI_SATIRLARI.OFFER_ID
WHERE SATIS_TEKLIFI.OFFER_NUMBER IS NOT NULL;

</cfquery>

<cfquery name="hazirlik2" datasource="#dsn3#">
IF OBJECT_ID('SATIS_SIPARIS_ALIS_TEKLIF', 'U') IS NOT NULL
    DROP TABLE SATIS_SIPARIS_ALIS_TEKLIF;

SELECT DISTINCT 
    ALIS_TEKLIFI.OFFER_ID AS ALIS_TEKLIF_ID,
    SATIS_SIPARISI.ORDER_ID AS SATIS_SIPARIS_ID,
    SATIS_SIPARISI.ORDER_NUMBER AS SATIS_SIPARIS_NO,
    SATIS_SIPARISI.ORDER_DATE AS SATIS_SIPARISI_TARIHI
INTO SATIS_SIPARIS_ALIS_TEKLIF
FROM w3Qa_1.INTERNALDEMAND_ROW AS IRR
LEFT JOIN w3Qa_1.OFFER_ROW AS ALIS_TEKLIFI_SATIRLARI_MAIN 
    ON ALIS_TEKLIFI_SATIRLARI_MAIN.WRK_ROW_RELATION_ID = IRR.WRK_ROW_ID
LEFT JOIN w3Qa_1.OFFER_ROW AS ALIS_TEKLIFI_SATIRLARI 
    ON ALIS_TEKLIFI_SATIRLARI.WRK_ROW_RELATION_ID = ALIS_TEKLIFI_SATIRLARI_MAIN.WRK_ROW_ID
LEFT JOIN w3Qa_1.OFFER AS ALIS_TEKLIFI 
    ON ALIS_TEKLIFI.OFFER_ID = ALIS_TEKLIFI_SATIRLARI.OFFER_ID
LEFT JOIN w3Qa_1.OFFER_ROW AS SATIS_TEKLIFI_SATIRLARI 
    ON SATIS_TEKLIFI_SATIRLARI.WRK_ROW_RELATION_ID = ALIS_TEKLIFI_SATIRLARI.WRK_ROW_ID
LEFT JOIN w3Qa_1.ORDER_ROW AS SATIS_SIPARISI_SATIRLARI 
    ON SATIS_SIPARISI_SATIRLARI.WRK_ROW_RELATION_ID = SATIS_TEKLIFI_SATIRLARI.WRK_ROW_ID
LEFT JOIN w3Qa_1.ORDERS AS SATIS_SIPARISI 
    ON SATIS_SIPARISI.ORDER_ID = SATIS_SIPARISI_SATIRLARI.ORDER_ID
WHERE SATIS_SIPARISI.ORDER_NUMBER IS NOT NULL;

</cfquery>

<cfquery name="getData" datasource="#dsn3#">
SELECT (
SELECT DISTINCT 
    IDO.INTERNAL_ID AS TALEP_ID, 
    IDO.INTERNAL_NUMBER AS TALEP_NO, 
    IDO.TARGET_DATE AS TALEP_TARIHI,
    C.NICKNAME AS TALEP_EDEN,
    EP.EMPLOYEE_NAME + ' ' + EP.EMPLOYEE_SURNAME AS TALEP_EDEN_PERS,

    OFFER_MAIN.OFFER_NUMBER AS ANA_TEKLIF_NO, 
    OFFER_MAIN.OFFER_ID AS ANA_TEKLIF_ID, 

    OFFER_SUB.OFFER_NUMBER AS ALT_TEKLIF_NO, 
    OFFER_SUB.OFFER_ID AS ALT_TEKLIF_ID,
    OFFER_SUB.OFFER_DATE AS ALT_TEKLIF_TARIHI,
    C2.NICKNAME AS ALT_TEKLIF_FIRMA,
    O.ORDER_NUMBER AS ALT_TEKLIF_SIPARIS,
    SATIS_TEKLIF.*
    SATIS_SIPARIS.*
FROM w3Qa_1.INTERNALDEMAND AS IDO
    LEFT JOIN w3Qa_1.OFFER AS OFFER_MAIN 
        ON OFFER_MAIN.INTERNALDEMAND_ID = IDO.INTERNAL_ID
    LEFT JOIN w3Qa_1.OFFER AS OFFER_SUB 
        ON OFFER_SUB.FOR_OFFER_ID = OFFER_MAIN.OFFER_ID
    LEFT JOIN w3Qa.COMPANY AS C 
        ON C.COMPANY_ID = IDO.FROM_COMPANY_ID
    LEFT JOIN w3Qa.EMPLOYEE_POSITIONS AS EP 
        ON EP.POSITION_CODE = IDO.TO_POSITION_CODE
    LEFT JOIN w3Qa.COMPANY AS C2 
        ON C2.COMPANY_ID=TRY_CAST(REPLACE(OFFER_SUB.OFFER_TO, ',', '') AS INT)
        OUTER APPLY (
        SELECT ORDER_NUMBER,ORDER_ID FROM w3Qa_1.ORDERS WHERE ORDER_ID IN (
        SELECT ORDER_ID FROM w3Qa_1.ORDER_ROW AS ORR WHERE ORR.WRK_ROW_RELATION_ID IN(
            SELECT WRK_ROW_ID FROM w3Qa_1.OFFER_ROW WHERE OFFER_ID=OFFER_SUB.OFFER_ID
        ))
    ) AS O
    LEFT JOIN SATIS_TEKLIF_ALIS_TEKLIF AS SATIS_TEKLIF 
        ON SATIS_TEKLIF.ALIS_TEKLIF_ID = OFFER_SUB.OFFER_ID
    LEFT JOIN SATIS_SIPARIS_ALIS_TEKLIF AS SATIS_SIPARIS
        ON SATIS_SIPARIS.ALIS_TEKLIF_ID = OFFER_SUB.OFFER_ID
FOR JSON PATH
) AS DATA


</cfquery>


  <title>Talep Listesi</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      padding: 20px;
      background-color: #f2f2f2;
      font-size: 14px;
    }

    h2 {
      margin-bottom: 15px;
    }

    .search-input {
      width: 300px;
      padding: 6px 10px;
      font-size: 14px;
      margin-bottom: 20px;
      border: 1px solid #ccc;
      border-radius: 4px;
    }

    .talep-block {
      background: #fff;
      border-left: 4px solid #2a9df4;
      padding: 10px 15px;
      margin-bottom: 15px;
      border-radius: 6px;
      box-shadow: 0 1px 2px rgba(0,0,0,0.05);
    }

    .talep-header {
      font-weight: bold;
      color: #2a9df4;
      margin-bottom: 5px;
    }

    .text-company {
      color: #444;
      font-weight: 500;
      font-size: 13px;
    }

    .ana-teklif {
      margin-left: 15px;
      font-weight: bold;
      color: #198754;
      margin-top: 5px;
    }

    .alt-teklif {
      margin-left: 30px;
      margin-top: 3px;
    }

    .text-muted {
      color: #777;
      font-size: 13px;
      margin-left: 5px;
    }

    .label-red {
      color: #d62828;
      margin-left: 20px;
      font-weight: bold;
    }
  </style>

<h2>📋 İç Talepler</h2>

<input type="text" id="filterInput" class="search-input" placeholder="🔍 Talep No veya Talep Eden Firma...">

<div id="talepListesi"></div>

<script>
const data = <cfoutput>#getData.DATA#</cfoutput>; // JSON verini buraya yapıştır
// Talepleri grupla
const grouped = {};
data.forEach(item => {
  const key = item.TALEP_NO;
  if (!grouped[key]) {
    grouped[key] = {
      talepId: item.TALEP_ID,
      talepNo: item.TALEP_NO,
      talepEden: item.TALEP_EDEN,
      talepEdenPers: item.TALEP_EDEN_PERS,
      talepTarihi: item.TALEP_TARIHI,
      teklifler: {}
    };
  }

  const anaTeklifKey = item.ANA_TEKLIF_NO || "YOK";
  if (!grouped[key].teklifler[anaTeklifKey]) {
    grouped[key].teklifler[anaTeklifKey] = {
      anaTeklifNo: item.ANA_TEKLIF_NO,
      anaTeklifId: item.ANA_TEKLIF_ID,
      altTeklifler: []
    };
  }

  if (item.ALT_TEKLIF_NO) {
    grouped[key].teklifler[anaTeklifKey].altTeklifler.push({
      altTeklifNo: item.ALT_TEKLIF_NO,
      altTeklifId: item.ALT_TEKLIF_ID,
      altTeklifTarihi: item.ALT_TEKLIF_TARIHI,
      altTeklifFirma: item.ALT_TEKLIF_FIRMA,
      altTeklifSiparis: item.ALT_TEKLIF_SIPARIS,      
      satisTeklifId: item.SATIS_TEKLIF_ID,
      satisTeklifNo: item.SATIS_TEKLIF_NO,
      satisTeklifTarihi: item.SATIS_TEKLIF_TARIHI,
      satisSiparisId: item.SATIS_SIPARIS_ID,
      satisSiparisNo: item.SATIS_SIPARIS_NO,
      satisSiparisTarihi: item.SATIS_SIPARIS_TARIHI


    });
  }
});

function renderList(filter = "") {
  const container = document.getElementById("talepListesi");
  container.innerHTML = "";

  Object.values(grouped).forEach(talep => {
    const searchText = `${talep.talepNo} ${talep.talepEden}`.toLowerCase();
    if (!searchText.includes(filter.toLowerCase())) return;

    const block = document.createElement("div");
    block.className = "talep-block";

    block.innerHTML = `
      <div class="talep-header">📦 Talep: <a href='/index.cfm?fuseaction=purchase.list_purchasedemand&event=upd&id=${talep.talepId}&is_hidden=1' target='_blank'> ${talep.talepNo}</a>
        <span class="text-company">👤 ${talep.talepEdenPers || "-"} (${talep.talepEden || "-"})</span>
      </div>
    `;

    const teklifKeys = Object.keys(talep.teklifler);
    if (teklifKeys.length > 0) {
      teklifKeys.forEach(key => {
        const ana = talep.teklifler[key];
        block.innerHTML += `
          <div class="ana-teklif">📄 Ana Teklif: <a href='/index.cfm?fuseaction=purchase.list_offer&event=det&offer_id=${ana.anaTeklifId}'>${ana.anaTeklifNo || "YOK"}</a></div>
        `;
        ana.altTeklifler.forEach(alt => {
          block.innerHTML += `
            <div class="alt-teklif">
              📥 <strong><a href='/index.cfm?fuseaction=purchase.list_offer&event=upd&offer_id=${alt.altTeklifId}'>${alt.altTeklifNo}</a></strong>
              ${alt.altTeklifTarihi ? `<span class="text-muted">📅 ${alt.altTeklifTarihi.slice(0,10)}</span>` : ""}
              ${alt.altTeklifFirma ? `<span class="firma">🏢 ${alt.altTeklifFirma}</span>` : ""}
              ${alt.altTeklifSiparis ? `<span class="siparis">📦 Alış Siparişi: ${alt.altTeklifSiparis}</span>` : ""}
              ${alt.satisTeklifNo ? `<span class="siparis">📦 Satış Teklifi: ${alt.satisTeklifNo}</span>` : ""}
              ${alt.satisTeklifTarihi ? `<span class="text-muted">📅 ${alt.satisTeklifTarihi.slice(0,10)}</span>` : ""}
               ${alt.satisSiparisNo ? `<span class="siparis">📦 Satış Siparişi: ${alt.satisSiparisNo}</span>` : ""}
              ${alt.satisSiparisTarihi ? `<span class="text-muted">📅 ${alt.satisSiparisTarihi.slice(0,10)}</span>` : ""}
            </div>
          `;
        });
      });
    } else {
      block.innerHTML += `<div class="label-red">🚫 Teklif Yok</div>`;
    }

    container.appendChild(block);
  });
}

document.getElementById("filterInput").addEventListener("input", e => {
  renderList(e.target.value);
});

renderList();
</script>