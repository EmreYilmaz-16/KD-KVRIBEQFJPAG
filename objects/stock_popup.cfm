<cfquery name="getDepoBakiye" datasource="#dsn2#">
    SELECT SUM(STOCK_IN - STOCK_OUT) AS BAKIYE FROM STOCKS_ROW WHERE STOCK_ID = #attributes.sid#
</cfquery>

<cfquery name="getRezerv" datasource="#dsn3#">
    SELECT SUM(VERILEN_SIPARIS_REZERVI) AS COLUMN1, SUM(ALINAN_SIPARIS_REZERVI) AS COLUMN2
    FROM (
        SELECT
            RESERVE_STOCK_IN - STOCK_IN AS VERILEN_SIPARIS_REZERVI,
            RESERVE_STOCK_OUT - STOCK_OUT AS ALINAN_SIPARIS_REZERVI,
            (
                SELECT SPECIAL_DEFINITION_PBS
                FROM ORDERS
                WHERE ORDER_ID = GOR.ORDER_ID
            ) AS OZEL_DURUM
        FROM GET_ORDER_ROW_RESERVED_ALL GOR
        WHERE STOCK_ID = #attributes.sid#
        AND (RESERVE_STOCK_IN - STOCK_IN) >= 0
        AND (RESERVE_STOCK_OUT - STOCK_OUT) >= 0
    ) AS T
    WHERE ISNULL(OZEL_DURUM, 0) <> 1
</cfquery>
<cfquery name="getRezerv1" datasource="#dsn3#">
    SELECT SUM(VERILEN_SIPARIS_REZERVI) AS COLUMN1, SUM(ALINAN_SIPARIS_REZERVI) AS COLUMN2
    FROM (
        SELECT
            RESERVE_STOCK_IN - STOCK_IN AS VERILEN_SIPARIS_REZERVI,
            RESERVE_STOCK_OUT - STOCK_OUT AS ALINAN_SIPARIS_REZERVI,
            (
                SELECT SPECIAL_DEFINITION_PBS
                FROM ORDERS
                WHERE ORDER_ID = GOR.ORDER_ID
            ) AS OZEL_DURUM
        FROM GET_ORDER_ROW_RESERVED_ALL GOR
        WHERE STOCK_ID = #attributes.sid#
        AND (RESERVE_STOCK_IN - STOCK_IN) >= 0
        AND (RESERVE_STOCK_OUT - STOCK_OUT) >= 0
    ) AS T
    WHERE ISNULL(OZEL_DURUM, 0) = 1
</cfquery>

<cfset depoBakiye = Val(getDepoBakiye.BAKIYE)>
<cfset verilenRezerv = Val(getRezerv.COLUMN1)>
<cfset alinanRezerv = Val(getRezerv.COLUMN2)>
<cfset ozel_siparis=Val(getRezerv1.COLUMN2)>
<cfset kullanilabilirBakiye = depoBakiye - alinanRezerv>
<cfif kullanilabilirBakiye GTE 0>
    <cfset usableStateClass = "positive">
<cfelse>
    <cfset usableStateClass = "negative">
</cfif>
<cfset formul_1=verilenRezerv-ozel_siparis> <!---alinan sipariş rezervi---->
<cfset formul_2=alinanRezerv-verilenRezerv>

<cfif formul_1 GTE 0>
    <cfset formul1Class = "positive">
<cfelse>
    <cfset formul1Class = "negative">
</cfif>

<cfif formul_2 GTE 0>
    <cfset formul2Class = "positive">
<cfelse>
    <cfset formul2Class = "negative">
</cfif>


<cfset depoBakiyeFormatted = tlformat(depoBakiye)>
<cfset verilenRezervFormatted = tlformat(verilenRezerv)>
<cfset alinanRezervFormatted = tlformat(alinanRezerv)>
<cfset kullanilabilirBakiyeFormatted = tlformat(kullanilabilirBakiye)>
<cfset formul1Formatted = tlformat(formul_1)>
<cfset formul2Formatted = tlformat(formul_2)>
<cfset ozel_siparisFormatted = tlformat(ozel_siparis)>


<cf_box title="Stok Depo Bilgileri" closable="1" draggable="1">
    
        <style>
            .stock-summary-wrap {
                font-family: "Segoe UI", Tahoma, Arial, sans-serif;
                color: #1f2933;
                background: linear-gradient(135deg, #f7fafc, #edf2f7);
                border-radius: 14px;
                padding: 24px;
                box-shadow: 0 12px 30px rgba(15, 23, 42, 0.08);
                margin: 10px 0;
                border: 1px solid #d8e2ef;
            }

            .stock-summary-header {
                display: flex;
                align-items: center;
                justify-content: space-between;
                margin-bottom: 18px;
            }

            .stock-summary-header h2 {
                font-size: 20px;
                margin: 0;
                font-weight: 600;
                letter-spacing: 0.02em;
            }

            .stock-summary-header span {
                font-size: 12px;
                text-transform: uppercase;
                letter-spacing: 0.15em;
                color: #64748b;
            }

            .stock-summary-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
                gap: 16px;
            }

            .stock-card {
                background: #ffffff;
                border-radius: 12px;
                padding: 18px;
                border: 1px solid #e2e8f0;
                transition: transform 0.2s ease, box-shadow 0.2s ease;
                display: flex;
                flex-direction: column;
                gap: 8px;
            }

            .stock-card:hover {
                transform: translateY(-4px);
                box-shadow: 0 10px 24px rgba(15, 23, 42, 0.12);
            }

            .stock-card .label {
                font-size: 13px;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 0.08em;
                color: #475569;
            }

            .stock-card .value {
                font-size: 28px;
                font-weight: 700;
                color: #0f172a;
            }

            .stock-card .hint {
                font-size: 12px;
                color: #7c8fac;
            }

            .stock-card.positive .value {
                color: #0f9357;
            }

            .stock-card.negative .value {
                color: #c53030;
            }

            .stock-card.reserve-out .value {
                color: #f97316;
            }

            .stock-card.reserve-in .value {
                color: #2563eb;
            }

            @media (max-width: 600px) {
                .stock-summary-wrap {
                    padding: 18px;
                }

                .stock-summary-grid {
                    grid-template-columns: 1fr;
                }
            }
        </style>
<cfoutput>
        <div class="stock-summary-wrap">
            <div class="stock-summary-header">
                <h2>Stok Durum Özeti</h2>
                <span>#DateTimeFormat(Now(), "dd mmm yyyy HH:nn")#</span>
            </div>

            <div class="stock-summary-grid">
                <div class="stock-card balance">
                    <div class="label">Depo Bakiyesi</div>
                    <div class="value">#depoBakiyeFormatted#</div>
                    <div class="hint">Stoktaki toplam kullanılabilir miktar.</div>
                </div>

                <div class="stock-card reserve-out">
                    <div class="label">Alınan Sipariş Rezervi</div>
                    <div class="value">#alinanRezervFormatted#</div>
                    <div class="hint">Çıkış bekleyen siparişler için ayrılan stok.</div>
                </div>
                <div class="stock-card #usableStateClass#">
                    <div class="label">Kullanılabilir Bakiye</div>
                    <div class="value">#kullanilabilirBakiyeFormatted#</div>
                    <div class="hint">Rezervler dikkate alındığında kalan stok.</div>
                </div>

                <div class="stock-card reserve-in">
                    <div class="label">Verilen Sipariş Rezervi</div>
                    <div class="value">#verilenRezervFormatted#</div>
                    <div class="hint">Giriş bekleyen siparişlerden gelecek stok.</div>
                </div>
                <div class="stock-card ozel-siparis">
                    <div class="label">Özel Sipariş Rezervi</div>
                    <div class="value">#ozel_siparisFormatted#</div>
                    <div class="hint">Özel siparişler için ayrılan stok.</div>
                </div>

                <div class="stock-card #formul1Class#">
                    <div class="label">Rezerv Sonrası Depo</div>
                    <div class="value">#formul1Formatted#</div>
                    <div class="hint">Depo bakiyesinden verilen rezerv çıkarıldığında kalan miktar.</div>
                </div>
<!---
                <div class="stock-card #formul2Class#">
                    <div class="label">Rezerv Net Değişim</div>
                    <div class="value">#formul2Formatted#</div>
                    <div class="hint">Alınan ve verilen rezervler arasındaki fark.</div>
                </div>---->
            </div>
        </div>
    </cfoutput>
</cf_box>