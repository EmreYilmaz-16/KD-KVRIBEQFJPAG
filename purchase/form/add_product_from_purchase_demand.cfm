<cfparam name="main_unit_id" default="0">
<cfparam name="tax_purchase" default="20">
<cfparam name="tax_s" default="20">
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
<cfquery name="GET_KDV" datasource="#DSN2#">
    SELECT TAX_ID, TAX FROM SETUP_TAX ORDER BY TAX
</cfquery>
<cfif isDefined("attributes.is_submit") and attributes.is_submit eq 1>
    <cfdump var="#attributes#">
    <cfset attributes.product_name = attributes.product_name>
    <cfif isDefined("attributes.alternatif")>
    <cfset attributes.alternatif = attributes.alternatif>
    <cfelse>
    <cfset attributes.alternatif = "">
</cfif>
    <cfset attributes.oem_no = []>
    <cfset oem_satir = attributes.oem_satir>

    <cfloop from="1" to="#oem_satir#" index="i">
        <cfset arrayAppend(attributes.oem_no, attributes["oem_" & i])>
    </cfloop>


    <cfinclude template="../query/add_product_from_purchase_result.cfm">
 
    
    <cfscript>
        /*
          <cfargument name="PRODUCT_NAME">
    <cfargument name="PRODUCT_CATID">
    <cfargument name="BRAND_ID">
    <cfargument name="SHORT_CODE_ID">
    <cfargument name="SHORT_CODE">
    <cfargument name="BIRIM">
    <cfargument name="ALTERNATIVES"> 
        
        writeDump(var=attributes, format="html", label="attributes", abort=true);
        */
        ProductInserResult=CreateProduct(attributes.product_name,279, attributes.brand_id, attributes.short_code_id,"#attributes.short_code_name#", attributes.unit_id, attributes.oem_no, attributes.alternatif,attributes.tax_purchase,attributes.tax,attributes.wrkRowId,1);
        ProductInserResult=deserializeJSON(ProductInserResult);
       

    </cfscript>
    <script>
        if (window.opener) {
            window.opener.location.reload(true);
            window.close();
        } else {
            console.error("No opener window found.");
        }
    </script>
    <cfabort>
<cfelse>
    <cfscript>
        brand_name = ""
                    brand_id = ""
                    brand_code = ""
                    short_code = ""
                    short_code_name = ""
                    short_code_id = ""
    </cfscript>
    <cfquery name="GET_OUR_COMPANY_INFO" datasource="#DSN#">
        SELECT IS_BRAND_TO_CODE,IS_BARCOD_REQUIRED,IS_WATALOGY_INTEGRATED FROM OUR_COMPANY_INFO WHERE COMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
    </cfquery>
    <cfquery name="GET_UNIT" datasource="#DSN#">
        SELECT 
            CASE
                WHEN LEN(SLI.ITEM) > 0 THEN SLI.ITEM
                ELSE UNIT
            END AS UNIT,
            UNIT_ID 
        FROM 
            SETUP_UNIT
            LEFT JOIN SETUP_LANGUAGE_INFO SLI ON SLI.UNIQUE_COLUMN_ID = SETUP_UNIT.UNIT_ID
            AND SLI.COLUMN_NAME = <cfqueryparam cfsqltype="cf_sql_varchar" value="UNIT">
            AND SLI.TABLE_NAME = <cfqueryparam cfsqltype="cf_sql_varchar" value="SETUP_UNIT">
            AND SLI.LANGUAGE = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.ep.language#">
        ORDER BY UNIT  
    </cfquery>
    
    
    <cf_box title="Yeni Ürün Ekle">
        <cfdump var="#attributes#" format="html" label="attributes" abort="true">
        <div style="height:100vh">
            <cfquery name="getOfferRows" datasource="#dsn3#">
                SELECT * FROM INTERNALDEMAND_ROW WHERE I_ID=#attributes.OFFER_ID# AND WRK_ROW_ID<>'#attributes.wrkRowId#' and PRODUCT_ID<>1055
            </cfquery>
            <cfform method="post" action="#request.self#?fuseaction=#attributes.fuseaction#">
                <input type="hidden" name="wrkRowId" value="<CFOUTPUT>#attributes.wrkRowId#</CFOUTPUT>">
                <input type="hidden" name="is_submit" value="1">
                <div class="row">
                    <!-- Yeni Ürün -->
                    <div class="col col-8">
                        <cf_box title="Yeni Ürün">
                            <div style="height:40vh">
                                <div class="form-group">
                                    <label for="product_name">Ürün Adı</label>
                                    <input type="text" class="form-control" id="product_name" name="product_name" value="<cfoutput>#attributes.productName#</cfoutput>">
                                </div>
                                <div class="form-group" id="item-brand_name">
                                    <label class=""><cf_get_lang dictionary_id='58847.Marka'></label>
                                    <div class=""> 
                                        <cfinput type="hidden" name="brand_code" id="brand_code" value="#brand_code#">
                                        <cf_wrkProductBrand
                                        returnInputValue="brand_id,brand_name,brand_code"
                                        returnQueryValue="BRAND_ID,BRAND_NAME,BRAND_CODE"
                                        width="120"
                                        compenent_name="getProductBrand"               
                                        boxwidth="300"
                                        boxheight="150"
                                        is_internet="1"
                                        brand_code="1"
                                        brand_ID="#brand_id#">
                                    </div>
                                </div>					
                                <div class="form-group" id="item-short_code_name">
                                    <label ><cf_get_lang dictionary_id='58225.Model'><cfif get_our_company_info.is_brand_to_code> </cfif></label>
                                    <div > 
                                        
                                        <cf_wrkProductModel
                                            returnInputValue="short_code_id,short_code_name,short_code"
                                            returnQueryValue="MODEL_ID,MODEL_NAME,MODEL_CODE"
                                            width="120"
                                            fieldName="short_code_name"
                                            fieldid="short_code_id"
                                            fieldcode="short_code"
                                            control_field_id="brand_id"
                                            control_field_name="brand_name"
                                            compenent_name="getProductModel"               
                                            boxwidth="300"
                                            boxheight="150"  
                                            model_ID="#short_code_id#">
                                    </div>
                                </div>
                                <div class="form-group" id="item-unit_id">
                                    <label class=""><cf_get_lang dictionary_id='57636.Birim'>*</label>
                                    <div class=""> 
                                        <select name="unit_id" id="unit_id" required>

                                        <cfoutput query="get_unit">
                                            <option value="#unit_id#,#unit#"<cfif main_unit_id eq unit_id>selected</cfif>>#unit#</option>
                                        </cfoutput>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group" id="item-tax_purchase">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='37631.Alis KDV'>*</label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
                                        <select name="tax_purchase" id="tax_purchase">
                                            <cfoutput query="get_kdv">
                                                <option value="#tax#"<cfif tax_purchase eq tax>selected</cfif>>#tax#</option>
                                            </cfoutput>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group" id="item-tax">
                                    <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='37916.Satış KDV'>*</label>
                                    <div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
                                        <select name="tax" id="tax">
                                            <cfoutput query="get_kdv">
                                                <option value="#tax#"<cfif tax_s eq tax>selected</cfif>>#tax#</option>
                                            </cfoutput>
                                        </select>
                                    </div>
                                </div>	
                            </div>
                        </cf_box>
                    </div>
    
                    <!-- Alternatif Ürün Seç -->
                    <div class="col col-4" style="display:none;">
                        <cf_box title="Alternatif Ürün Seç" >
                            <div style="height:40vh">
                                <ul class="list-group">
                                    <cfoutput query="getOfferRows">
                                        <li class="list-group-item d-flex justify-content-between align-items-center">
                                            <span>#PRODUCT_NAME#</span>
                                            <input type="checkbox" name="alternatif" value="#WRK_ROW_ID#-#PRODUCT_ID#-#STOCK_ID#">
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
                <div class="col col-12" style="display: flex;justify-content: end;">
                    <input type="submit" class="btn btn-primary" value="Kaydet">
                </div>
                </div>
            </cfform>
            
        </div>
    </cf_box>
</cfif>



<script>
    $document.ready(function() {
        // Initialize the OEM rows if any exist
        <cfif isDefined("attributes.oem_no") and arrayLen(attributes.oem_no)>
            
        <cfoutput>OemSatirEkle("#attributes.oem_no#");</cfoutput>
        </cfif>
    });
    function OemSatirEkle(oem_numarasi="") {
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
        input.value = oem_numarasi;
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