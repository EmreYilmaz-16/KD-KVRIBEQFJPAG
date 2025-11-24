<cfquery name="GETPERIODS" datasource="#DSN#">
    SELECT TOP 2 PERIOD_ID,OUR_COMPANY_ID FROM SETUP_PERIOD ORDER BY PERIOD_ID DESC
</cfquery>
<cfparam name="attributes.pallet_id" default="0">

<cfset successMessage = "">
<cfset errorMessage = "">

<cfset currentPalletId = Val(attributes.pallet_id)>
<cfset hasPalletIdColumn = false>
<cftry>
    <cfdbinfo type="columns" datasource="#dsn3#" table="#dsn3#.SHIPPING_PALLET_ROWS_PBS" name="palletRowColumns">
    <cfloop query="palletRowColumns">
        <cfif CompareNoCase(palletRowColumns.COLUMN_NAME, "PALLET_ID") EQ 0>
            <cfset hasPalletIdColumn = true>
            <cfbreak>
        </cfif>
    </cfloop>
<cfcatch type="any">
    <cfset hasPalletIdColumn = false>
</cfcatch>
</cftry>

<cfif StructKeyExists(attributes, "submitAddProducts") AND attributes.submitAddProducts EQ "1">
    <cfset insertedRowCount = 0>
    <cfset duplicateSerialList = "">

    <cfset rawSelectedProducts = "">
    <cfif StructKeyExists(attributes, "selected_products")>
        <cfset rawSelectedProducts = Trim(attributes.selected_products)>
    </cfif>

    <cfif Len(rawSelectedProducts)>
        <cftry>
            <cfset selectedProductArray = deserializeJSON(rawSelectedProducts)>
            <cfif NOT IsArray(selectedProductArray)>
                <cfset selectedProductArray = []>
            </cfif>

            <cfif ArrayLen(selectedProductArray)>
                <cftransaction>
                    <cfloop array="#selectedProductArray#" index="productItem">
                        <cfif NOT StructKeyExists(productItem, "serial") OR NOT IsArray(productItem.serial)>
                            <cfcontinue>
                        </cfif>

                        <cfset currentProductId = 0>
                        <cfif StructKeyExists(productItem, "productid")>
                            <cfset currentProductId = Val(productItem.productid)>
                        </cfif>

                        <cfset currentStockId = 0>
                        <cfif StructKeyExists(productItem, "stockid")>
                            <cfset currentStockId = Val(productItem.stockid)>
                        </cfif>

                        <cfloop array="#productItem.serial#" index="serialNo">
                            <cfset trimmedSerial = Trim(serialNo & "")>
                            <cfif NOT Len(trimmedSerial)>
                                <cfcontinue>
                            </cfif>

                            <cfif hasPalletIdColumn>
                                <cfquery name="checkExistingSerial" datasource="#dsn3#">
                                    SELECT COUNT(1) AS CNT
                                    FROM #dsn3#.SHIPPING_PALLET_ROWS_PBS
                                    WHERE SERIAL_NUMBER = <cfqueryparam value="#trimmedSerial#" cfsqltype="cf_sql_varchar">
                                      AND PALLET_ID = <cfqueryparam value="#currentPalletId#" cfsqltype="cf_sql_integer">
                                </cfquery>
                            <cfelse>
                                <cfquery name="checkExistingSerial" datasource="#dsn3#">
                                    SELECT COUNT(1) AS CNT
                                    FROM #dsn3#.SHIPPING_PALLET_ROWS_PBS
                                    WHERE SERIAL_NUMBER = <cfqueryparam value="#trimmedSerial#" cfsqltype="cf_sql_varchar">
                                </cfquery>
                            </cfif>

                            <cfif checkExistingSerial.CNT GT 0>
                                <cfif NOT ListFindNoCase(duplicateSerialList, trimmedSerial)>
                                    <cfset duplicateSerialList = ListAppend(duplicateSerialList, trimmedSerial)>
                                </cfif>
                                <cfcontinue>
                            </cfif>

                            <cfif hasPalletIdColumn>
                                <cfquery name="insertSerialRow" datasource="#dsn3#">
                                    INSERT INTO #dsn3#.SHIPPING_PALLET_ROWS_PBS
                                        (PALLET_ID, SERIAL_NUMBER, PRODUCT_ID, STOCK_ID, RECORD_DATE, RECORD_EMP)
                                    VALUES
                                        (
                                            <cfqueryparam value="#currentPalletId#" cfsqltype="cf_sql_integer">,
                                            <cfqueryparam value="#trimmedSerial#" cfsqltype="cf_sql_varchar">,
                                            <cfqueryparam value="#currentProductId#" cfsqltype="cf_sql_integer">,
                                            <cfqueryparam value="#currentStockId#" cfsqltype="cf_sql_integer">,
                                            <cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">,
                                            <cfqueryparam value="#session.ep.userid#" cfsqltype="cf_sql_integer">
                                        )
                                </cfquery>
                            <cfelse>
                                <cfquery name="insertSerialRow" datasource="#dsn3#">
                                    INSERT INTO #dsn3#.SHIPPING_PALLET_ROWS_PBS
                                        (SERIAL_NUMBER, PRODUCT_ID, STOCK_ID, RECORD_DATE, RECORD_EMP)
                                    VALUES
                                        (
                                            <cfqueryparam value="#trimmedSerial#" cfsqltype="cf_sql_varchar">,
                                            <cfqueryparam value="#currentProductId#" cfsqltype="cf_sql_integer">,
                                            <cfqueryparam value="#currentStockId#" cfsqltype="cf_sql_integer">,
                                            <cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">,
                                            <cfqueryparam value="#session.ep.userid#" cfsqltype="cf_sql_integer">
                                        )
                                </cfquery>
                            </cfif>

                            <cfset insertedRowCount = insertedRowCount + 1>
                        </cfloop>
                    </cfloop>
                </cftransaction>

                <cfif insertedRowCount GT 0>
                    <cfset successMessage = insertedRowCount & " adet seri kaydedildi.">
                </cfif>

                <cfif Len(duplicateSerialList)>
                    <cfif Len(errorMessage)>
                        <cfset errorMessage = errorMessage & " ">
                    </cfif>
                    <cfset errorMessage = errorMessage & "Listeye alinmayan seri numaralari: " & duplicateSerialList>
                </cfif>
            <cfelse>
                <cfset errorMessage = "Gonderilen urun listesi bos gorundu.">
            </cfif>
        <cfcatch type="any">
            <cfset errorMessage = "Gonderilen veriler islenirken hata olustu.">
        </cfcatch>
        </cftry>
    <cfelse>
        <cfset errorMessage = "Kaydedilecek seri verisi bulunamadi.">
    </cfif>
</cfif>
<cfquery name="getPaperSerials" datasource="#dsn3#">
    SELECT (
        SELECT DISTINCT
            SG.SERIAL_NO,SG.STOCK_ID
        FROM #dsn3#.SHIPPING_PALLET_SVK_PBS SP
        LEFT JOIN #dsn3#.EZGI_SHIP_RESULT ESR ON ESR.SHIP_RESULT_ID = SP.ORDER_ID
        LEFT JOIN (
            <cfloop query="GETPERIODS">
                <cfif GETPERIODS.currentRow GT 1>
                    UNION ALL
                </cfif>
                SELECT FIS_ID, REF_NO, #GETPERIODS.PERIOD_ID# AS PERIODID FROM #dsn#_#GETPERIODS.PERIOD_ID#_#GETPERIODS.OUR_COMPANY_ID#.STOCK_FIS
                
            </cfloop>
         <!----   SELECT FIS_ID, REF_NO, 2 AS PERIODID FROM #dsn2#.STOCK_FIS
            UNION ALL
            SELECT FIS_ID, REF_NO, 1 AS PERIODID FROM #dsn#_#year(now())-1#_#session.ep.company_id#.STOCK_FIS---->
        ) SF ON SF.REF_NO = ESR.DELIVER_PAPER_NO
        LEFT JOIN #dsn3#.SERVICE_GUARANTY_NEW SG ON SG.PROCESS_ID = SF.FIS_ID AND SG.PERIOD_ID = SF.PERIODID
        WHERE SP.PALLET_ID=<cfqueryparam value="#Val(attributes.pallet_id)#" cfsqltype="cf_sql_integer">
        FOR JSON PATH
    ) AS T
</cfquery>

<cfset paperSerialJson = Trim(getPaperSerials.T)>
<cfif NOT Len(paperSerialJson)>
    <cfset paperSerialJson = "[]">
</cfif>

<cfset paperSerialArray = []>
<cfset validSerialStruct = StructNew()>
<cftry>
    <cfset paperSerialArray = deserializeJSON(paperSerialJson)>
    <cfif NOT IsArray(paperSerialArray)>
        <cfset paperSerialArray = []>
    </cfif>
<cfcatch type="any">
    <cfset paperSerialArray = []>
</cfcatch>
</cftry>

<cfif ArrayLen(paperSerialArray)>
    <cfloop array="#paperSerialArray#" index="serialItem">
        <cfif StructKeyExists(serialItem, "SERIAL_NO")>
            <cfset validSerialStruct[serialItem.SERIAL_NO] = serialItem>
        </cfif>
    </cfloop>
</cfif>

<cfset getSavedPalletRows = QueryNew("SERIAL_NUMBER,PRODUCT_ID,STOCK_ID,PRODUCT_CODE_2")>
<cftry>
    <cfquery name="getSavedPalletRows" datasource="#dsn3#">
        SELECT SPR.SERIAL_NUMBER,
               SPR.PRODUCT_ID,
               SPR.STOCK_ID,
               P.PRODUCT_CODE_2
        FROM #dsn3#.SHIPPING_PALLET_ROWS_PBS SPR
        INNER JOIN #dsn1#.PRODUCT P ON P.PRODUCT_ID = SPR.PRODUCT_ID
        WHERE SPR.PALLET_ID = <cfqueryparam value="#Val(attributes.pallet_id)#" cfsqltype="cf_sql_integer">
    </cfquery>
<cfcatch type="any">
    <cfquery name="getSavedPalletRows" datasource="#dsn3#">
        SELECT SPR.SERIAL_NUMBER,
               SPR.PRODUCT_ID,
               SPR.STOCK_ID,
               P.PRODUCT_CODE_2
        FROM #dsn3#.SHIPPING_PALLET_ROWS_PBS SPR
        INNER JOIN #dsn1#.PRODUCT P ON P.PRODUCT_ID = SPR.PRODUCT_ID
    </cfquery>
</cfcatch>
</cftry>

<cfset existingProductsMap = StructNew()>
<cfif getSavedPalletRows.RecordCount GT 0>
    <cfloop query="getSavedPalletRows">
        <cfset savedSerial = Trim(getSavedPalletRows.SERIAL_NUMBER & "")>
        <cfif NOT Len(savedSerial)>
            <cfcontinue>
        </cfif>
        <cfif ArrayLen(paperSerialArray) AND NOT StructKeyExists(validSerialStruct, savedSerial)>
            <cfcontinue>
        </cfif>

        <cfset productKey = getSavedPalletRows.PRODUCT_CODE_2 & "|" & getSavedPalletRows.PRODUCT_ID & "|" & getSavedPalletRows.STOCK_ID>

        <cfif NOT StructKeyExists(existingProductsMap, productKey)>
            <cfset existingProductsMap[productKey] = {
                product_code = getSavedPalletRows.PRODUCT_CODE_2,
                serial = [],
                quantity = 0,
                productid = Val(getSavedPalletRows.PRODUCT_ID),
                stockid = Val(getSavedPalletRows.STOCK_ID)
            }>
        </cfif>

        <cfset ArrayAppend(existingProductsMap[productKey].serial, savedSerial)>
        <cfset existingProductsMap[productKey].quantity = existingProductsMap[productKey].quantity + 1>
    </cfloop>
</cfif>

<cfset existingProductsArray = []>
<cfif StructCount(existingProductsMap)>
    <cfloop collection="#existingProductsMap#" item="productKey">
        <cfset ArrayAppend(existingProductsArray, existingProductsMap[productKey])>
    </cfloop>
</cfif>

<cfset existingProductsJson = SerializeJSON(existingProductsArray)>

<cf_box title="Palete Urun Barkodu Ekle">
    <style>
        .pallet-product-wrap {
            font-family: "Segoe UI", Tahoma, Arial, sans-serif;
            color: #1f2933;
            background: linear-gradient(135deg, #f8fafc, #eef2f7);
            border-radius: 16px;
            padding: 28px;
            border: 1px solid #d8e2ef;
            box-shadow: 0 14px 30px rgba(15, 23, 42, 0.08);
        }

        .pallet-product-header {
            display: flex;
            flex-direction: column;
            gap: 6px;
            margin-bottom: 20px;
        }

        .pallet-product-header h2 {
            margin: 0;
            font-size: 22px;
            font-weight: 600;
            letter-spacing: 0.02em;
        }

        .pallet-form-controls {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 16px;
            margin-bottom: 18px;
        }

        .pallet-alert {
            border-radius: 10px;
            padding: 12px 16px;
            font-size: 13px;
            margin-bottom: 16px;
            border: 1px solid transparent;
        }

        .pallet-alert-success {
            background: rgba(34, 197, 94, 0.12);
            color: #166534;
            border-color: rgba(34, 197, 94, 0.4);
        }

        .pallet-alert-error {
            background: rgba(248, 113, 113, 0.15);
            color: #b91c1c;
            border-color: rgba(248, 113, 113, 0.45);
        }

        .pallet-select,
        .pallet-input {
            width: 100%;
            border-radius: 12px;
            border: 1px solid #cbd5e1;
            padding: 12px 14px;
            font-size: 14px;
            background: #ffffff;
            transition: border 0.2s ease, box-shadow 0.2s ease;
        }

        .pallet-select:focus,
        .pallet-input:focus {
            border-color: #6366f1;
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.18);
            outline: none;
        }

        .pallet-table-wrapper {
            border-radius: 12px;
            border: 1px solid #cbd5e1;
            background: #ffffff;
            overflow: hidden;
        }

        table.pallet-table {
            width: 100%;
            border-collapse: collapse;
        }

        table.pallet-table thead {
            background: #e2e8f0;
        }

        table.pallet-table th,
        table.pallet-table td {
            padding: 14px 16px;
            font-size: 13px;
            text-align: left;
            border-top: 1px solid #e2e8f0;
        }

        table.pallet-table tbody tr:nth-child(even) {
            background: #f8fafc;
        }

        .table-empty {
            padding: 32px;
            text-align: center;
            color: #6b7280;
        }

        .pallet-action-button {
            border-radius: 8px;
            border: none;
            padding: 8px 14px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            margin-right: 8px;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .pallet-action-button:hover {
            transform: translateY(-1px);
            box-shadow: 0 8px 18px rgba(15, 23, 42, 0.15);
        }

        .action-remove {
            background: rgba(220, 38, 38, 0.15);
            color: #b91c1c;
        }

        .action-serials {
            background: rgba(37, 99, 235, 0.12);
            color: #1d4ed8;
        }

        .summary-bar {
            display: flex;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 12px;
            margin: 18px 0;
            font-size: 13px;
            color: #475569;
        }

        .summary-bar strong {
            color: #0f172a;
        }

        .submit-bar {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }

        .submit-bar button,
        .submit-bar input[type="submit"] {
            border-radius: 10px;
            border: none;
            padding: 12px 20px;
            font-size: 14px;
            font-weight: 600;
            letter-spacing: 0.04em;
            cursor: pointer;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .btn-secondary {
            background: #f1f5f9;
            color: #475569;
            border: 1px solid #cbd5e1;
        }

        .btn-secondary:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 24px rgba(148, 163, 184, 0.2);
        }

        .btn-primary {
            background: linear-gradient(135deg, #4f46e5, #1d4ed8);
            color: #ffffff;
            box-shadow: 0 10px 22px rgba(37, 99, 235, 0.3);
        }

        .btn-primary:disabled {
            background: #94a3b8;
            box-shadow: none;
            cursor: not-allowed;
        }

        .info-hint {
            font-size: 12px;
            color: #64748b;
        }

        @media (max-width: 640px) {
            .submit-bar {
                flex-direction: column;
                align-items: stretch;
            }

            .submit-bar button,
            .submit-bar input[type="submit"] {
                width: 100%;
            }
        }
    </style>

    <div class="pallet-product-wrap">
        <div class="pallet-product-header">
            <h2>Paketlenen Urunleri Tara</h2>
            <span class="info-hint">Gecerli barkodlar otomatik olarak palete eklenir.</span>
        </div>

        <cfif Len(successMessage)>
            <cfoutput>
                <div class="pallet-alert pallet-alert-success">#HTMLEditFormat(successMessage)#</div>
            </cfoutput>
        </cfif>

        <cfif Len(errorMessage)>
            <cfoutput>
                <div class="pallet-alert pallet-alert-error">#HTMLEditFormat(errorMessage)#</div>
            </cfoutput>
        </cfif>

        <div class="pallet-form-controls">
            <div>
                <label for="BarcodeParser" class="info-hint">Barkod Tipi</label>
                <select name="BarcodeParser" id="BarcodeParser" class="pallet-select">
                    <option value="">Barkod tipi seciniz</option>
                </select>
            </div>
            <div>
                <label for="barcode" class="info-hint">Barkod Okut</label>
                <input type="text" name="barcode" id="barcode" class="pallet-input" placeholder="Barkodlari okutun" autocomplete="off">
            </div>
        </div>

        <div class="summary-bar">
            <div><strong>Toplam Urun:</strong> <span id="summary-product-count">0</span></div>
            <div><strong>Toplam Seri:</strong> <span id="summary-serial-count">0</span></div>
        </div>

        <cfform method="post" action="#request.self#?fuseaction=#attributes.fuseaction#" id="palletProductForm">
            <div class="pallet-table-wrapper">
                <table class="pallet-table">
                    <thead>
                        <tr>
                            <th>Urun Kodu</th>
                            <th>Miktar</th>
                            <th>Islemler</th>
                        </tr>
                    </thead>
                    <tbody id="product-table-body">
                        <tr class="table-empty">
                            <td colspan="3">Henuz urun eklenmedi. Barkod okutmaya basin.</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div class="submit-bar" style="margin-top: 18px;">
                <button type="button" class="btn-secondary" id="clearAllButton" disabled>Listeyi Temizle</button>
                <input type="submit" class="btn-primary" id="submitButton" value="Palete Kaydet" disabled>
            </div>

            <input type="hidden" name="selected_products" id="selectedProducts">
            <cfoutput><input type="hidden" name="pallet_id" value="#HTMLEditFormat(attributes.pallet_id)#"></cfoutput>
            <input type="hidden" name="submitAddProducts" value="1">
        </cfform>
    </div>
</cf_box>

<script>
    var paperSerials = <cfoutput>#paperSerialJson#</cfoutput>;
    if (!Array.isArray(paperSerials)) {
        paperSerials = [];
    }

    var preloadedProducts = <cfoutput>#existingProductsJson#</cfoutput>;
    if (!Array.isArray(preloadedProducts)) {
        preloadedProducts = [];
    }

    var validSerialSet = new Set(paperSerials.map(function (item) {
        return item.SERIAL_NO;
    }));

    var productArray = preloadedProducts.slice();
    var barcodeManager = null;

    var parserSelect = document.getElementById('BarcodeParser');
    var barcodeInput = document.getElementById('barcode');
    var productTableBody = document.getElementById('product-table-body');
    var selectedProductsField = document.getElementById('selectedProducts');
    var summaryProductCount = document.getElementById('summary-product-count');
    var summarySerialCount = document.getElementById('summary-serial-count');
    var clearAllButton = document.getElementById('clearAllButton');
    var submitButton = document.getElementById('submitButton');

    document.addEventListener('DOMContentLoaded', function () {
        if (barcodeInput) {
            barcodeInput.focus();
        }

        if (typeof BarcodeManager !== 'undefined') {
            barcodeManager = new BarcodeManager();
            var parsers = barcodeManager.listParsers() || [];
            parsers.forEach(function (parser) {
                var option = document.createElement('option');
                option.value = parser.id;
                option.textContent = parser.name;
                parserSelect.appendChild(option);
            });
        }

        if (barcodeInput) {
            barcodeInput.addEventListener('keydown', handleBarcodeKeydown);
        }

        document.getElementById('palletProductForm').addEventListener('submit', function () {
            selectedProductsField.value = JSON.stringify(productArray);
        });

        clearAllButton.addEventListener('click', function () {
            productArray = [];
            renderProductRows();
            updateSummary();
        });

        renderProductRows();
        updateSummary();
    });

    function handleBarcodeKeydown(event) {
        if (event.key === 'Enter') {
            event.preventDefault();
            var barcodeValue = barcodeInput.value.trim();
            var parserId = parserSelect.value;

            if (!parserId) {
                alert('Lutfen once barkod tipini secin.');
                return;
            }

            if (!barcodeValue.length) {
                return;
            }

            if (!barcodeManager) {
                alert('Barkod yoneticisi yuklenemedi.');
                return;
            }

            var serialObject = barcodeManager.parseWith(barcodeValue, parseInt(parserId, 10));

            if (!serialObject || !serialObject.serial_no) {
                alert('Gecersiz barkod. Tekrar deneyin.');
                barcodeInput.value = '';
                return;
            }

            processSerial(serialObject);
            barcodeInput.value = '';
            barcodeInput.focus();
        }
    }

    function processSerial(serialObject) {
        var serialNo = serialObject.serial_no;
        var productCode = serialObject.product_code_2;

        if (!validSerialSet.has(serialNo)) {
            alert('Bu seri numarasi secili sevkiyatlar icin gecerli degil.');
            return;
        }

        var existingSerial = productArray.some(function (item) {
            return item.serial.indexOf(serialNo) !== -1;
        });
        var sql=`
        SELECT PRODUCT.PRODUCT_ID,STOCKS.STOCK_ID,PRODUCT_CODE_2,PRODUCT_NAME FROM #dsn1#.PRODUCT 
LEFT JOIN #dsn1#.STOCKS ON PRODUCT.PRODUCT_ID=STOCKS.PRODUCT_ID WHERE PRODUCT_CODE_2='${productCode}'`
var qr=wrk_query(sql,'dsn1');
console.log(qr);
        if(qr.recordcount==0){
            alert('Bu urun kodu sistemde bulunamadi.');
            return;
        }
        if (existingSerial) {
            alert('Bu seri numarasi zaten listede bulunuyor.');
            return;
        }

        var productIndex = productArray.findIndex(function (item) {
            return item.product_code === productCode;
        });

        if (productIndex !== -1) {
            productArray[productIndex].quantity += 1;
            productArray[productIndex].serial.push(serialNo);
        } else {
            productArray.push({
                product_code: productCode,
                serial: [serialNo],
                quantity: 1,
                productid: qr.PRODUCT_ID[0],
                stockid: qr.STOCK_ID[0]
            });
        }

        renderProductRows();
        updateSummary();
    }

    function renderProductRows() {
        productTableBody.innerHTML = '';

        if (!productArray.length) {
            var emptyRow = document.createElement('tr');
            emptyRow.className = 'table-empty';
            var emptyCell = document.createElement('td');
            emptyCell.colSpan = 3;
            emptyCell.textContent = 'Henuz urun eklenmedi. Barkod okutmaya basin.';
            emptyRow.appendChild(emptyCell);
            productTableBody.appendChild(emptyRow);
            updateFormState();
            return;
        }

        productArray.forEach(function (item) {
            var row = document.createElement('tr');

            var productCell = document.createElement('td');
            productCell.textContent = item.product_code;
            row.appendChild(productCell);

            var quantityCell = document.createElement('td');
            quantityCell.textContent = item.quantity;
            row.appendChild(quantityCell);

            var actionCell = document.createElement('td');
            var removeButton = document.createElement('button');
            removeButton.type = 'button';
            removeButton.className = 'pallet-action-button action-remove';
            removeButton.textContent = 'Kaldir';
            removeButton.addEventListener('click', function () {
                removeProduct(item.product_code);
            });

            var showButton = document.createElement('button');
            showButton.type = 'button';
            showButton.className = 'pallet-action-button action-serials';
            showButton.textContent = 'Seri Numaralari';
            showButton.addEventListener('click', function () {
                alert('Seri Numaralari:\n' + item.serial.join(', '));
            });

            actionCell.appendChild(removeButton);
            actionCell.appendChild(showButton);
            row.appendChild(actionCell);

            productTableBody.appendChild(row);
        });

        updateFormState();
    }

    function removeProduct(productCode) {
        productArray = productArray.filter(function (item) {
            return item.product_code !== productCode;
        });
        renderProductRows();
        updateSummary();
    }

    function updateSummary() {
        var totalProducts = productArray.length;
        var totalSerials = productArray.reduce(function (acc, item) {
            return acc + item.serial.length;
        }, 0);

        summaryProductCount.textContent = totalProducts;
        summarySerialCount.textContent = totalSerials;

        updateFormState();
    }

    function updateFormState() {
        var hasItems = productArray.length > 0;
        clearAllButton.disabled = !hasItems;
        submitButton.disabled = !hasItems;
    }
</script>

<script>
    function wrk_query(str_query,data_source,maxrows)
{
	/*console.log(str_query);
	alert('Bu sayfada wrk_query kullanılmıştır. İlgili kontrolü ajax yapısına çeviriniz.');
	return false;
	*/
	/*
	by  Workcube
	Created 20060315
	Modified 20060324
	Usage:
		my_query = query('SELECT COL1,COL2 FROM TABLE1 WHERE COL2=1');
		veya
		my_query = query('SELECT COL1,COL2 FROM TABLE1 WHERE COL2=1','dsn2');
		veya
		my_query = query('SELECT COL1,COL2 FROM TABLE1 WHERE COL2=1 ORDER BY COL2 DESC','dsn2',1);
		ifadesi ile my_query degiskeni cfquery ile donen sonucun tamamen aynisi bir javascript query degeri alir
		data_source : optional , default olarak 'dsn' kullaniliyor
		maxrows : optional , default olarak 0 ataniyor, 0 olunca query sonucundaki tum kayitlar gelir
	*/
	
	var new_query=new Object();
	var req;
	if(!data_source) data_source='dsn';
	if(!maxrows) maxrows=0;
	function callpage(url) {
		req = false;
		if(window.XMLHttpRequest)
			try
				{req = new XMLHttpRequest();}
			catch(e)
				{req = false;}
		else if(window.ActiveXObject)
			try {
				req = new ActiveXObject("Msxml2.XMLHTTP");
				}
			catch(e)
				{
				try {req = new ActiveXObject("Microsoft.XMLHTTP");}
				catch(e)
					{req = false;}
				}
		if(req)
			{
				function return_function_()
				{

				if (req.readyState == 4 && req.status == 200)
					try
						{
							eval(req.responseText.replace(/\u200B/g,''));
							new_query = get_js_query; //alert('Cevap:\n\n'+req.responseText);//
						}
					catch(e)
						{new_query = false;}
				}
			req.open("post", url+'&xmlhttp=1', false);
			req.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
			req.setRequestHeader('pragma','nocache');
			if(encodeURI(str_query).indexOf('+') == -1) // + isareti encodeURI fonksiyonundan gecmedigi icin encodeURIComponent fonksiyonunu kullaniyoruz. EY 20120125
				req.send('str_sql='+encodeURI(str_query)+'&data_source='+data_source+'&maxrows='+maxrows);
			else
				req.send('str_sql='+encodeURIComponent(str_query)+'&data_source='+data_source+'&maxrows='+maxrows);
			return_function_();
			}
		
	}
	
	//TolgaS 20070124 objects yetkisi olmayan partnerlar var diye fuseaction objects2 yapildi
	callpage('/index.cfm?fuseaction=objects2.emptypopup_get_js_query&isAjax=1');
	//alert(new_query);
	
	return new_query;
}
</script>