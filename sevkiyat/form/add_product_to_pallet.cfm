<cfif isDefined("attributes.submitAddProducts")>
    <cfdump var="#attributes#">
    <CFSET FD=deserializeJSON(attributes.selected_products)>
    <cfdump var="#FD#">
    <cfloop array="#FD#" index="item">
        <cfset productCode = item.product_code>
        <cfset quantity = item.quantity>
        <cfset serials = item.serial>

        <cfdump var="#productCode#">
        <cfdump var="#quantity#">
        <cfdump var="#serials#">
        </cfloop>
</cfif>
<cfquery name="getPaperSerials" datasource="#dsn3#">
    SELECT (
        SELECT DISTINCT
            SG.SERIAL_NO
        FROM w3Qa_1.SHIPPING_PALLET_SVK_PBS SP
        LEFT JOIN w3Qa_1.EZGI_SHIP_RESULT ESR ON ESR.SHIP_RESULT_ID = SP.ORDER_ID
        LEFT JOIN (
            SELECT FIS_ID, REF_NO, 2 AS PERIODID FROM w3Qa_2025_1.STOCK_FIS
            UNION ALL
            SELECT FIS_ID, REF_NO, 1 AS PERIODID FROM w3Qa_2024_1.STOCK_FIS
        ) SF ON SF.REF_NO = ESR.DELIVER_PAPER_NO
        LEFT JOIN w3Qa_1.SERVICE_GUARANTY_NEW SG ON SG.PROCESS_ID = SF.FIS_ID AND SG.PERIOD_ID = SF.PERIODID
        WHERE SP.PALLET_ID=<cfqueryparam value="#Val(attributes.pallet_id)#" cfsqltype="cf_sql_integer">
        FOR JSON PATH
    ) AS T
</cfquery>

<cfset paperSerialJson = Trim(getPaperSerials.T)>
<cfif NOT Len(paperSerialJson)>
    <cfset paperSerialJson = "[]">
</cfif>

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

    var validSerialSet = new Set(paperSerials.map(function (item) {
        return item.SERIAL_NO;
    }));

    var productArray = [];
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
                quantity: 1
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