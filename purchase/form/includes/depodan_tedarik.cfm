<cfquery name="HAZIRLIK1" datasource="#dsn#">
   IF OBJECT_ID('CMP_PRICE_ALL', 'U') IS NOT NULL
    DROP TABLE CMP_PRICE_ALL;

    SELECT  CAST(PRICE_OTHER AS DECIMAL(18,2)) AS PRICE,INVOICE_DATE,STOCK_ID,COMPANY_ID INTO CMP_PRICE_ALL FROM (
SELECT PRICE_OTHER,INVOICE_ROW.OTHER_MONEY,INVOICE.INVOICE_DATE,STOCK_ID,COMPANY_ID FROM w3Qa_2025_1.INVOICE_ROW 
INNER JOIN w3Qa_2025_1.INVOICE ON INVOICE.INVOICE_ID=INVOICE_ROW.INVOICE_ID
WHERE INVOICE.PURCHASE_SALES=1-- AND STOCK_ID=75 AND COMPANY_ID=9
UNION ALL
SELECT PRICE_OTHER,INVOICE_ROW.OTHER_MONEY,INVOICE.INVOICE_DATE,STOCK_ID,COMPANY_ID FROM w3Qa_2024_1.INVOICE_ROW 
INNER JOIN w3Qa_2024_1.INVOICE ON INVOICE.INVOICE_ID=INVOICE_ROW.INVOICE_ID
WHERE INVOICE.PURCHASE_SALES=1 --AND STOCK_ID=75 AND COMPANY_ID=9
) AS T


</cfquery>

<cfquery name="GETDEMAND_MONEY" datasource="#dsn3#">
  SELECT OTHER_MONEY,FROM_COMPANY_ID FROM w3Qa_1.INTERNALDEMAND WHERE INTERNAL_ID=#attributes.internal_id#
</cfquery>

<cfquery name="getMainPurchaseOffer" datasource="#DSN3#">
SELECT ( SELECT * FROM (
SELECT C.FULLNAME, C.COMPANY_ID, OFFER_ID,
(
    
SELECT OFFER_ROW.PRODUCT_NAME
,CAST(PRICE AS DECIMAL(18, 2)) AS PRICE
	, CAST(PRICE_OTHER AS DECIMAL(18, 2)) AS PRICE_OTHER
	, OTHER_MONEY
	, OFFER_ROW.PRODUCT_ID
	, OFFER_ROW.STOCK_ID
  ,OFFER_ROW.DETAIL_INFO_EXTRA  AS OEM_NO 
  ,(SELECT TOP 1 PRICE FROM #DSN#.CMP_PRICE_ALL WHERE STOCK_ID=OFFER_ROW.STOCK_ID AND COMPANY_ID=#GETDEMAND_MONEY.FROM_COMPANY_ID# AND PRICE>0 ORDER BY INVOICE_DATE DESC) AS LAST_PRICE
	, WRK_ROW_ID
  ,w3Qa_1.fnGetSelectInfoExtra(WRK_ROW_ID) AS SELECT_INFO_EXTRA
  ,ISNULL((SELECT BASKET_INFO_TYPE FROM w3Qa_1.SETUP_BASKET_INFO_TYPES WHERE BASKET_INFO_TYPE_ID=(w3Qa_1.fnGetSelectInfoExtra(WRK_ROW_ID))),'') AS BASKET_INFO_TYPE
  ,ISNULL(S.PRODUCT_CODE_2,'')PRODUCT_CODE_2
	, CAST(DISCOUNT_1 AS DECIMAL(18, 2)) AS DISCOUNT_1
	, CAST(OFFER_ROW.TAX AS DECIMAL(18, 2)) AS TAX
	, CAST(QUANTITY AS DECIMAL(18, 2)) AS QUANTITY
	, CAST(PRICE - (PRICE * DISCOUNT_1 / 100) AS DECIMAL(18, 2)) AS NET_PRICE
  ,CASE WHEN (SELECT (SELECT COUNT(*) FROM w3Qa_1.ORDER_ROW WHERE WRK_ROW_RELATION_ID=OFR2.WRK_ROW_ID+'_XX') FROM w3Qa_1.OFFER_ROW OFR2 WHERE WRK_ROW_RELATION_ID=OFFER_ROW.WRK_ROW_ID) >0	THEN 1 ELSE 0 END AS SNT_S
	, CASE 
		WHEN (
				SELECT COUNT(*)
    FROM w3Qa_1.PBS_SELECTED_ROWS
    WHERE WRK_ROW_ID = OFFER_ROW.WRK_ROW_ID
				) > 0
			THEN 1
		ELSE 0
		END AS IS_SELECTED
    ,ISNULL((SELECT IS_OS FROM PBS_SELECTED_ROWS WHERE WRK_ROW_ID = OFFER_ROW.WRK_ROW_ID),1) AS IS_OS
, ISNULL((CASE 
						WHEN (
								SELECT COUNT(*)
    FROM w3Qa_1.OFFER_ROW AS TTTTTTT
    WHERE WRK_ROW_RELATION_ID = OFFER_ROW.WRK_ROW_ID
								) > 0
							THEN 1
						ELSE 0
						END),0) AS IS_SATINALMA
, ISNULL((
							SELECT CAST(PRODUCT_MARJ AS DECIMAL(18, 2)) AS PRODUCT_MARJ
								, CAST(SALE_PRICE AS DECIMAL(18, 2)) AS SALE_PRICE
                , CAST(ISNULL(DSC1,0) AS DECIMAL(18, 2)) AS DSC1
                , CAST(ISNULL(DSC2,0) AS DECIMAL(18, 2)) AS DSC2
                , CAST(ISNULL(DSC3,0) AS DECIMAL(18, 2)) AS DSC3
    FROM w3Qa_1.PBS_SELECTED_ROWS
    WHERE WRK_ROW_ID = OFFER_ROW.WRK_ROW_ID
    FOR JSON AUTO
							), '[]') AS SLP
					, ISNULL((
							SELECT *
    FROM (
								            SELECT PRODUCT_ID
            FROM w3Qa_1.ALTERNATIVE_PRODUCTS
            WHERE PRODUCT_ID = OFFER_ROW.PRODUCT_ID
                OR ALTERNATIVE_PRODUCT_ID = OFFER_ROW.PRODUCT_ID

        UNION ALL

            SELECT ALTERNATIVE_PRODUCT_ID PRODUCT_ID
            FROM w3Qa_1.ALTERNATIVE_PRODUCTS
            WHERE PRODUCT_ID = OFFER_ROW.PRODUCT_ID
                OR ALTERNATIVE_PRODUCT_ID = OFFER_ROW.PRODUCT_ID
								) AS TABLO
    FOR JSON PATH
							), '[]') AS ALTERNATIFLER
             
FROM w3Qa_1.OFFER_ROW
LEFT JOIN w3Qa_1.STOCKS AS S ON S.STOCK_ID=OFFER_ROW.STOCK_ID
WHERE OFFER_ID = O.OFFER_ID AND ISNULL(OFFER_ROW.SELECT_INFO_EXTRA,0) =3
FOR JSON PATH
) AS URUNLER
FROM w3Qa_1.OFFER AS O
    LEFT JOIN w3Qa.COMPANY AS C ON C.COMPANY_ID = TRY_CAST(REPLACE(O.OFFER_TO, ',', '') AS INT)

WHERE FOR_OFFER_ID IN (
    SELECT OFFER_ID
FROM w3Qa_1.OFFER
WHERE INTERNALDEMAND_ID=#attributes.internal_id#
)
) AS T  
WHERE LEN(URUNLER)>0
FOR JSON PATH

)AS QRESULT


  </cfquery>


<cfif len(getMainPurchaseOffer.QRESULT) EQ 0>
    <div class="alert alert-warning">Bu Talep İçin Depodan Teslim Edilecek Ürün Bulunmamaktadır</div><cfabort>
</cfif>
  <style>
    td.selectable {
      cursor: pointer;
      transition: background-color 0.2s;
      position: relative;
    }
    td.no-data {
      background-color: #f8f9fa !important;
      color: #adb5bd;
    }
    .product-name {
      background-color: #f1f3f5;
      font-weight: bold;
      position: sticky;
      left: 0;
      z-index: 1;
    }
    th.sticky-header {
      position: sticky;
      top: 0;
      z-index: 2;
    }
    pre {
      background-color: #fff3cd;
      border: 1px solid #ffeeba;
      padding: 1rem;
      border-radius: 0.5rem;
    }
    .price-original {
      color: red;
      text-decoration: line-through;
    }
    .net-price {
      color: green;
      font-weight: bold;
    }
    .check-icon {
      position: absolute;
      top: 5px;
      right: 5px;
      font-size: 1.2rem;
      animation: fadeIn 0.4s ease-in-out;
    }
    .tooltip {
      position: relative;
      display: inline-block;
    }
    .tooltip .tooltiptext {
      visibility: hidden;
      width: max-content;
      background-color: #343a40;
      color: #fff;
      text-align: center;
      border-radius: 4px;
      padding: 5px;
      position: absolute;
      z-index: 10;
      bottom: 125%;
      left: 50%;
      transform: translateX(-50%);
      opacity: 0;
      transition: opacity 0.3s;
      font-size: 0.75rem;
    }
    .tooltip:hover .tooltiptext {
      visibility: visible;
      opacity: 1;
    }
    .flex-list .small, .ui-table-list .small {
    width: auto;
}
   /* .net-price.low { color: green; font-weight: bold; }
    .net-price.medium { color: orange; font-weight: bold; }
    .net-price.high { color: red; font-weight: bold; }*/
  </style>
</head>
<CFSET OFFER_STAGE="0">
 

<body class="bg-light">
  <div class="">
    <div class="">
      <div class="card-body">
        
        <div class="table-responsive">
          <cf_grid_list  class="table table-bordered align-middle text-center" id="price-table"></cf_grid_list>
        </div>
        <div class="mt-4 text-end">
            <button class="ui-wrk-btn ui-wrk-btn-success" id="send-btn3">Kaydet</button>
            
         <cfquery name="getOfferStage" datasource="#DSN3#">
SELECT OFFER_ID,OFFER_STAGE,SUM(SS) SS FROM (
SELECT 
	DISTINCT
	ORR_SATIS_TEKLIFI.OFFER_ID,
	O_SATIS_TEKLIFI.OFFER_STAGE,
	(SELECT COUNT(*) FROM w3Qa_1.ORDER_ROW WHERE WRK_ROW_RELATION_ID=ORR_SATIS_TEKLIFI.WRK_ROW_ID)	AS SS
FROM w3Qa_1.OFFER_ROW AS ORR_SATIS_TEKLIFI
LEFT JOIN w3Qa_1.OFFER_ROW AS ORR_ALIS_TEKLIFI ON ORR_ALIS_TEKLIFI.WRK_ROW_ID=ORR_SATIS_TEKLIFI.WRK_ROW_RELATION_ID
LEFT JOIN w3Qa_1.OFFER AS O_ALIS_TEKLIFI ON O_ALIS_TEKLIFI.OFFER_ID=ORR_ALIS_TEKLIFI.OFFER_ID
LEFT JOIN w3Qa_1.OFFER AS O_SATIS_TEKLIFI ON O_SATIS_TEKLIFI.OFFER_ID=ORR_SATIS_TEKLIFI.OFFER_ID
WHERE ORR_SATIS_TEKLIFI.WRK_ROW_RELATION_ID IN (
SELECT WRK_ROW_ID FROM w3Qa_1.PBS_SELECTED_ROWS WHERE OFFER_ID=#attributes.internal_id#)
) AS T GROUP BY OFFER_ID,OFFER_STAGE

</cfquery>

<script>
  var DEMAND_MONEY = '<cfoutput>#GETDEMAND_MONEY.OTHER_MONEY#</cfoutput>';
</script>

<cfif getOfferStage.recordCount>
<cfelse>
  <cfquery name="upos" datasource="#dsn3#">
    UPDATE w3Qa_1.PBS_SELECTED_ROWS SET IS_OS=1 WHERE OFFER_ID=#attributes.internal_id#
  </cfquery>
</cfif>
            <CFIF getOfferStage.OFFER_STAGE EQ 256 and getOfferStage.SS EQ 0>
            <button class="btn btn-success" onclick="SatinalmaSiparis(<CFOUTPUT>#attributes.internal_id#</CFOUTPUT>)" id="send-btn2">Satınalma Siparişlerini Oluştur</button>
          
          </CFIF>
          
        </div>


    <div class="card mt-4 shadow-sm">
    <div class="card-body">
      <h5 class="card-title">En İyi Fiyatı Veren Tedarikçi</h5>
      <p id="best-supplier" class="fw-bold text-primary">Henüz belirlenmedi.</p>
    </div>
  </div>

  <div class="card mt-4 shadow-sm">
      <div class="card-body">
        <h5 class="card-title">Seçilen Veriler (JSON)</h5>
        <pre id="output">[]</pre>
      </div>
    </div>

   
  </div>
  </div>
  </div>
  

  
  
  <input type="hidden" id="offer_id" name="offer_id" value="<cfoutput>#attributes.internal_id#</cfoutput>">

  <cfset MONEYARRRR=arrayNew(1)>
            <cfquery name="getMoneyext" datasource="#dsn3#">
                SELECT 
             (SELECT RATE1 FROM #dsn#.MONEY_HISTORY WHERE MONEY_HISTORY_ID=(
             SELECT MAX(MONEY_HISTORY_ID) FROM #dsn#.MONEY_HISTORY WHERE MONEY=SM.MONEY) )AS RATE1,
             (SELECT EFFECTIVE_SALE RATE2 FROM #dsn#.MONEY_HISTORY WHERE MONEY_HISTORY_ID=(
             SELECT MAX(MONEY_HISTORY_ID) FROM #dsn#.MONEY_HISTORY WHERE MONEY=SM.MONEY) )AS RATE2,
             SM.MONEY
             FROM #dsn#.SETUP_MONEY AS SM WHERE SM.PERIOD_ID=#session.ep.period_id#
             </cfquery>
        
    <cfloop query="getMoneyext">
        <cfscript>
            arrayAppend(MONEYARRRR,{MONEY=MONEY,RATE1=RATE1,RATE2=RATE2})
        </cfscript>
        
    </cfloop>
<script>
  var session_variables=<cfoutput>#replace(serializeJSON(session),"//","")#</cfoutput>
  var data = <cfoutput>#getMainPurchaseOffer.QRESULT#</cfoutput>
  var MONEYARRRR=<cfoutput>#replace(serializeJSON(MONEYARRRR),"//","")#</cfoutput>
</script>
<script>
  <cfinclude template="depodan_teslim.min.js">
</script>


