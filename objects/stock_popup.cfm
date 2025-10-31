<cfquery name="getDepoBakiye" datasource="#dsn2#">
    SELECT SUM(STOCK_IN - STOCK_OUT) AS BAKIYE FROM STOCKS_ROW WHERE STOCK_ID = #attributes.sid#
</cfquery>

<cfquery name="getRezerv" datasource="#dsn3#">
    SELECT SUM(VERILEN_SIPARIS_REZERVI), SUM(ALINAN_SIPARIS_REZERVI)
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

<cfset depoBakiye = Val(getDepoBakiye.BAKIYE)>
<cfset verilenRezerv = Val(getRezerv.COLUMN1)>
<cfset alinanRezerv = Val(getRezerv.COLUMN2)>
<cfset kullanilabilirBakiye = depoBakiye - verilenRezerv + alinanRezerv>
<cfset usableStateClass = IIf(kullanilabilirBakiye GTE 0, "positive", "negative")>

<cfset depoBakiyeFormatted = LSNumberFormat(depoBakiye, "#,##0.##")>
<cfset verilenRezervFormatted = LSNumberFormat(verilenRezerv, "#,##0.##")>
<cfset alinanRezervFormatted = LSNumberFormat(alinanRezerv, "#,##0.##")>
<cfset kullanilabilirBakiyeFormatted = LSNumberFormat(kullanilabilirBakiye, "#,##0.##")>

<cf_box title="Stok Depo Bilgileri" closable="1" draggable="1">
    <cfoutput>
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
                    <div class="label">Verilen Sipariş Rezervi</div>
                    <div class="value">#verilenRezervFormatted#</div>
                    <div class="hint">Çıkış bekleyen siparişler için ayrılan stok.</div>
                </div>

                <div class="stock-card reserve-in">
                    <div class="label">Alınan Sipariş Rezervi</div>
                    <div class="value">#alinanRezervFormatted#</div>
                    <div class="hint">Giriş bekleyen siparişlerden gelecek stok.</div>
                </div>

                <div class="stock-card #usableStateClass#">
                    <div class="label">Kullanılabilir Bakiye</div>
                    <div class="value">#kullanilabilirBakiyeFormatted#</div>
                    <div class="hint">Rezervler dikkate alındığında kalan stok.</div>
                </div>
            </div>
        </div>
    </cfoutput>
</cf_box>