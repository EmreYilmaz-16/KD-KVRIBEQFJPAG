<style>
    .list-group {
        padding: 0;
        margin: 0;
        list-style: none;
    }

    .list-group-item {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 10px 15px;
        margin-bottom: 5px;
        background-color: #f8f9fa;
        border: 1px solid #ddd;
        border-radius: 4px;
    }

    .list-group-item:hover {
        background-color: #e9ecef;
    }

    .d-flex {
        display: flex !important;
    }

    .justify-content-between {
        justify-content: space-between !important;
    }

    .align-items-center {
        align-items: center !important;
    }
</style>

<cf_box title="Yeni Ürün Ekle">
    <div style="height:100vh">
        <cfquery name="getOfferRows" datasource="#dsn3#">
            SELECT * FROM OFFER_ROW WHERE OFFER_ID=#attributes.OFFER_ID# AND WRK_ROW_ID<>'#attributes.wrkRowId#'
        </cfquery>
        <cfform method="post" action="">
            <div class="row">
                <!-- Yeni Ürün -->
                <div class="col col-4">
                    <cf_box title="Yeni Ürün">
                        <div style="height:40vh">
                            <div class="form-group">
                                <label for="product_name">Ürün Adı</label>
                                <input type="text" class="form-control" id="product_name" name="product_name" value="<cfoutput>#attributes.productName#</cfoutput>">
                            </div>
                        </div>
                    </cf_box>
                </div>

                <!-- Alternatif Ürün Seç -->
                <div class="col col-4">
                    <cf_box title="Alternatif Ürün Seç">
                        <div style="height:40vh">
                            <ul class="list-group">
                                <cfoutput query="getOfferRows">
                                    <li class="list-group-item d-flex justify-content-between align-items-center">
                                        <span>#PRODUCT_NAME#</span>
                                        <input type="checkbox" name="alternatif" value="#WRK_ROW_ID#">
                                    </li>
                                </cfoutput>
                            </ul>
                        </div>
                    </cf_box>
                </div>

                <!-- OEM No -->
                <div class="col col-4">
                    <input type="hidden" name="oem_satir" value="0">
                    <cf_box title="Oem No" add_href="javascript:OemSatirEkle()">
                        <div style="height:40vh">
                            <cf_big_list>
                                <tbody id="oemgrid"></tbody>
                            </cf_big_list>
                        </div>
                    </cf_box>
                </div>
            </div>
            <div class="row">
            <div class="col col-12">
                <input type="submit" class="btn btn-primary" value="Kaydet">
            </div>
            </div>
        </cfform>
        
    </div>
</cf_box>

<script>
    function OemSatirEkle() {
        const oemCounter = document.getElementsByName("oem_satir")[0];
        let ix = parseInt(oemCounter.value) + 1;
        oemCounter.value = ix;

        const formGroup = document.createElement("div");
        formGroup.className = "form-group";

        const inputGroup = document.createElement("div");
        inputGroup.className = "input-group mb-3";

        const input = document.createElement("input");
        input.type = "text";
        input.className = "form-control";
        input.id = `oem_${ix}`;
        input.name = `oem_${ix}`;
        input.placeholder = `OEM No ${ix}`;

        const inputGroupAddon = document.createElement("div");
        inputGroupAddon.className = "input-group-addon";

        const deleteButton = document.createElement("span");
        deleteButton.innerHTML = '<i class="fa fa-trash"></i>';
        deleteButton.onclick = () => OemSatirSilRow(ix);

        inputGroupAddon.appendChild(deleteButton);
        inputGroup.appendChild(input);
        inputGroup.appendChild(inputGroupAddon);
        formGroup.appendChild(inputGroup);

        const tr = document.createElement("tr");
        tr.id = `oemtr_${ix}`;
        tr.className = "oemtr";
        tr.appendChild(formGroup);

        document.getElementById("oemgrid").appendChild(tr);
    }

    function OemSatirSilRow(rowId) {
        const tr = document.getElementById(`oemtr_${rowId}`);
        tr.parentNode.removeChild(tr);

        reassignRows();
    }

    function reassignRows() {
        const rows = document.querySelectorAll("#oemgrid .oemtr");
        rows.forEach((row, index) => {
            const input = row.querySelector("input");
            input.id = `oem_${index + 1}`;
            input.name = `oem_${index + 1}`;
            row.id = `oemtr_${index + 1}`;
        });

        document.getElementsByName("oem_satir")[0].value = rows.length;
    }
</script>