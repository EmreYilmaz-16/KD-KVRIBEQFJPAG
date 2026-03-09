
<cfif isDefined("attributes.is_submit") AND attributes.is_submit EQ "1">
    <cfset company = attributes.company>
    <cfset product = attributes.product>
    <cfset date = attributes.date>
    
    <!-- Burada formdan gelen verileri işleyebilir ve kaydedebilirsiniz -->
    <cfoutput>
        <p><strong>Company:</strong> #company#</p>
        <p><strong>Product:</strong> #product#</p>
        <p><strong>Date:</strong> #date#</p>
    </cfoutput>
    
    <cfquery name="del" datasource="#dsn3#">
        DELETE FROM #dsn3#.SATINALMA_PLANLAMA_PBS 
        WHERE COMPANY_ID = #company#
    </cfquery>
    
    <!-- Attributes içindeki tüm field'ları dolaşıp hazir_, termin_, verilmeyen_ ile başlayanları bul -->
    <cfoutput>
        <p style="display:none;">Form işleme başladı: Company=#company#</p>
    </cfoutput>
    
    <cfloop collection="#attributes#" item="fieldName">
        <cfif Left(fieldName, 6) EQ "hazir_">
            <cfoutput>
                <p style="display:none;">Field bulundu: #fieldName# = #attributes[fieldName]#</p>
            </cfoutput>
            <!--- Field name formatı: hazir_{ORDER_ID}_{STOCK_ID} --->
            <cfset parts = ListToArray(fieldName, "_")>
            <cfif ArrayLen(parts) EQ 3>
                <cfset current_order_id = parts[2]>
                <cfset current_stock_id = parts[3]>
                
                <cfoutput>
                    <p style="display:none;">Parse edildi: ORDER_ID=#current_order_id#, STOCK_ID=#current_stock_id#</p>
                </cfoutput>
                
                <!--- Aynı ORDER_ID ve STOCK_ID için PRODUCT_ID'yi bul --->
                <cfquery name="getProductId" datasource="#dsn3#" maxrows="1">
                    SELECT PRODUCT_ID FROM #dsn3#.STOCKS WHERE STOCK_ID = #current_stock_id#
                </cfquery>
                
                <cfif getProductId.recordCount GT 0>
                    <cfset current_product_id = getProductId.PRODUCT_ID>
                    
                    <cfset hazir_field_name = "hazir_" & current_order_id & "_" & current_stock_id>
                    <cfset termin_field_name = "termin_" & current_order_id & "_" & current_stock_id>
                    <cfset verilmeyen_field_name = "verilmeyen_" & current_order_id & "_" & current_stock_id>
                    
                    <cfset hazir_value = isDefined("attributes.#hazir_field_name#") ? attributes[hazir_field_name] : 0>
                    <cfset termin_value = isDefined("attributes.#termin_field_name#") ? attributes[termin_field_name] : 0>
                    <cfset verilmeyen_value = isDefined("attributes.#verilmeyen_field_name#") ? attributes[verilmeyen_field_name] : 0>
                    
                    <!--- ORDER_ID'nin numeric olduğundan emin ol --->
                    <cfset numeric_order_id = IsNumeric(current_order_id) ? Val(current_order_id) : 0>
                    
                    <cfif (IsNumeric(hazir_value) OR IsNumeric(termin_value) OR IsNumeric(verilmeyen_value)) AND numeric_order_id GT 0>
                        <cfquery datasource="#dsn3#">
                            INSERT INTO #dsn3#.SATINALMA_PLANLAMA_PBS 
                            (COMPANY_ID, PRODUCT_ID, ORDER_ID, HAZIR, TERMIN, VERILMEYEN)
                            VALUES (
                                #company#,
                                #current_product_id#,
                                #numeric_order_id#,
                                #IsNumeric(hazir_value) ? hazir_value : 0#,
                                #IsNumeric(termin_value) ? termin_value : 0#,
                                #IsNumeric(verilmeyen_value) ? verilmeyen_value : 0#
                            )
                        </cfquery>
                        <!--- Debug için --->
                        <cfoutput>
                            <p style="display:none;">Kayıt yapıldı: ORDER_ID=#numeric_order_id#, PRODUCT_ID=#current_product_id#, HAZIR=#hazir_value#, TERMIN=#termin_value#, VERILMEYEN=#verilmeyen_value#</p>
                        </cfoutput>
                    </cfif>
                </cfif>
            </cfif>
        </cfif>
    </cfloop>
    
    <div class="alert alert-success mt-3" role="alert">
        <i class="bi bi-check-circle"></i> Veriler başarıyla kaydedildi!
    </div>

</cfif>


<cfquery name="getData" datasource="#dsn3#">
    SELECT 
        SUM(SOUT) AS BS,
        S1,
        P1, 
        PRODUCT_CODE_2, 
        PRODUCT_NAME, 
        PRODUCT_CODE, 
        ORDER_ID, 
        ORDER_NUMBER,
        DELIVERY_DATE,
        ISNULL(PR.PRICE, 0) AS PRICE,
        ISNULL(PR.MONEY, 'TL') AS MONEY,
        PR.STARTDATE AS LISTE_BASLANGIC_TARIHI,
        (SELECT SUM(ISNULL(STOCK_IN,0)-ISNULL(STOCK_OUT,0)) FROM #dsn2#.STOCKS_ROW AS SR WHERE SR.STOCK_ID=T.P1) AS BK 
    FROM (
        SELECT  
            S.STOCK_ID S1,
            ORDR.ORDER_ROW_CURRENCY,
            S.PRODUCT_ID P1,
            S.PRODUCT_CODE_2,
            S.PRODUCT_NAME,
            S.PRODUCT_CODE,
            O.COMPANY_ID,
            O.ORDER_ID,
            CONVERT(DATE, O.DELIVERDATE) AS DELIVERY_DATE,
            O.ORDER_NUMBER,
            RESERVE_STOCK_IN-STOCK_IN AS SIN,
            RESERVE_STOCK_OUT-STOCK_OUT AS SOUT
        FROM #dsn3#.ORDER_ROW_RESERVED AS ORR
        LEFT JOIN #dsn3#.ORDER_ROW AS ORDR ON ORDR.WRK_ROW_ID=ORR.ORDER_WRK_ROW_ID
        LEFT JOIN #dsn3#.ORDERS AS O ON O.ORDER_ID=ORDR.ORDER_ID
        LEFT JOIN #dsn3#.STOCKS AS S ON S.STOCK_ID=ORDR.STOCK_ID
        WHERE O.PURCHASE_SALES=1 
            AND ORDR.ORDER_ROW_CURRENCY NOT IN (-9,-10,-3) 
            AND O.RESERVED=1
            AND O.COMPANY_ID=#attributes.company#  
            AND S.BRAND_ID=6
            AND O.SPECIAL_DEFINITION_PBS = 1
    ) AS T 
    OUTER APPLY (
        SELECT TOP 1 
            PR.PRICE, 
            PR.MONEY, 
            PR.STARTDATE
        FROM #dsn3#.PRICE_HISTORY AS PR 
        WHERE PR.PRODUCT_ID = T.P1 
            AND PR.PRICE_CATID = 1
            AND T.DELIVERY_DATE >= PR.STARTDATE 
            AND (PR.FINISHDATE IS NULL OR T.DELIVERY_DATE <= PR.FINISHDATE)
        ORDER BY PR.STARTDATE DESC
    ) AS PR
    WHERE SOUT >0  --AND P1=5350
    GROUP BY S1,P1, PRODUCT_CODE_2, PRODUCT_NAME, PRODUCT_CODE,ORDER_ID,ORDER_NUMBER,DELIVERY_DATE,PR.PRICE,PR.MONEY,PR.STARTDATE
    ORDER BY ORDER_ID,P1
</cfquery>



<cfset pid_list=valueList(getData.P1)>

<cfquery name="getData2" datasource="#dsn3#">
    SELECT SUM(SIN) AS BS,S1,P1,PRODUCT_CODE_2,PRODUCT_NAME
 FROM (
SELECT  
ORDR.STOCK_ID S1,
ORDR.ORDER_ROW_CURRENCY,
S.PRODUCT_ID P1,
S.PRODUCT_CODE_2,
S.PRODUCT_NAME,
S.PRODUCT_CODE,
O.ORDER_NUMBER,O.PURCHASE_SALES,
O.ORDER_ID O1,
O.RESERVED,
  ORR.ORDER_ID,
RESERVE_STOCK_IN-STOCK_IN AS SIN,
RESERVE_STOCK_OUT-STOCK_OUT AS SOUT
FROM #dsn3#.ORDER_ROW_RESERVED AS ORR
LEFT JOIN #dsn3#.ORDER_ROW AS ORDR ON ORDR.WRK_ROW_ID=ORR.ORDER_WRK_ROW_ID
LEFT JOIN #dsn3#.ORDERS AS O ON O.ORDER_ID=ORDR.ORDER_ID
LEFT JOIN #dsn3#.STOCKS AS S ON S.STOCK_ID=ORDR.STOCK_ID
WHERE O.PURCHASE_SALES=0 AND ORDR.ORDER_ROW_CURRENCY NOT IN (-9,-10,-3) AND O.RESERVED=1
) AS T WHERE SIN >0  AND P1 IN (#pid_list#)
GROUP BY S1,P1,PRODUCT_CODE_2,PRODUCT_NAME,PRODUCT_CODE
ORDER BY P1
</cfquery>

<cfset BAKIYE_MAP = {}>
<cfset VERILEN_SIPARIS_MAP = {}>
<cfloop query="getData2">
    
    <cfif NOT structKeyExists(VERILEN_SIPARIS_MAP, "-#P1#")>
        <cfset VERILEN_SIPARIS_MAP["-#P1#"] = 0>
    </cfif>
    <cfset VERILEN_SIPARIS_MAP["-#P1#"] += BS>
</cfloop>
<cfquery name="GETRECORDED" datasource="#dsn3#">
SELECT PRODUCT_ID, HAZIR, TERMIN, VERILMEYEN,COMPANY_ID,ISNULL(ORDER_ID,0) AS ORDER_ID FROM #dsn3#.SATINALMA_PLANLAMA_PBS WHERE COMPANY_ID=#attributes.company#
</cfquery>
<cfset RECORDED_MAP = {}>
<cfloop query="GETRECORDED">
    <cfset recorded_product_id = PRODUCT_ID>
    <cfset recorded_order_id = ORDER_ID>
    <cfset recorded_hazir = HAZIR>
    <cfset recorded_termin = TERMIN>
    <cfset recorded_verilmeyen = VERILMEYEN>
    
    <!--- ORDER_ID ve PRODUCT_ID ile key oluştur --->
    <cfset RECORDED_MAP["#recorded_order_id#-#recorded_product_id#"] = {
        "hazir": recorded_hazir,
        "termin": recorded_termin,
        "verilmeyen": recorded_verilmeyen
    }>
</cfloop>
<cfquery name="GETALLRECORDED" datasource="#dsn3#">
SELECT SUM(HAZIR) AS TOTAL_HAZIR, SUM(TERMIN) AS TOTAL_TERMIN, SUM(VERILMEYEN) AS TOTAL_VERILMEYEN,PRODUCT_ID FROM #dsn3#.SATINALMA_PLANLAMA_PBS WHERE PRODUCT_ID IN (#pid_list#)  GROUP BY PRODUCT_ID
</cfquery>
<CFSET ALLRECORDED_MAP = {}>
<cfloop query="GETALLRECORDED">,
    <CFSET ALLRECORDED_MAP["-#PRODUCT_ID#"] = {
        "total_hazir": TOTAL_HAZIR,
        "total_termin": TOTAL_TERMIN,
        "total_verilmeyen": TOTAL_VERILMEYEN
    }>  
</cfloop>

    
    <!-- Kaydedilen verileri kullanarak istediğiniz işlemleri yapabilirsiniz -->
<!----

<cfdump var="#attributes#" label="URL Parameters">
<cfdump var="#getData2#" label="Get Data 2">
<cfdump var="#getData#" label="Get Data 1">
<cfdump var="#BAKIYE_MAP#" label="BAKIYE_MAP">
<cfdump var="#VERILEN_SIPARIS_MAP#" label="VERILEN_SIPARIS_MAP">
<cfdump var="#RECORDED_MAP#" label="RECORDED_MAP">
<cfdump var="#ALLRECORDED_MAP#" label="ALLRECORDED_MAP">
----->
<cf_box title="Termin Detay">
    
    <form id="sipform" action="<cfoutput>#request.self#?fuseaction=#attributes.fuseaction#</cfoutput>" method="post">
        <cfoutput>
        <input type="hidden" name="company" value="#attributes.company#">
        <input type="hidden" name="product" value="#attributes.product#">
        <input type="hidden" name="date" value="#DateFormat(Now(), 'yyyy-mm-dd')#">
        <input type="hidden" name="is_submit" value="1">
        </cfoutput>
        
        <cfloop query="getData" group="ORDER_ID">
            <div class="table-container mb-4">
             
               <cf_box title="Sipariş No: #ORDER_NUMBER#">
               
                
                <div class="table-responsive">
                    <cf_ajax_list class="table table-striped table-hover">
                        <thead class="table-dark">
                            <tr>
                                <th>KD Kodu</th>
                                <th>Ürün Adı</th>
                                <th>Teslim T.</th>
                                <th>Liste Başl.T.</th>
                                <th>Depo</th>
                                <th>Bekleyen Rezerv</th>
                                <th>Sip. Mik.</th>                                
                                <th>Hazır</th>
                                <th>Termin</th>
                                <th>Verilmeyen</th>
                            </tr>
                        </thead>
                        <tbody>
                        <cfloop>
                            <cfoutput>
                            <cfset bakiyeDegeri = BK>
                            <cfset verilenSiparisDegeri = structKeyExists(VERILEN_SIPARIS_MAP, "-#P1#") ? VERILEN_SIPARIS_MAP["-#P1#"] : 0>
                            <CFSET R_HAZIR= structKeyExists(ALLRECORDED_MAP, "-#P1#") ? ALLRECORDED_MAP["-#P1#"].total_hazir : 0>
                            <CFSET R_TERMIN= structKeyExists(ALLRECORDED_MAP, "-#P1#") ? ALLRECORDED_MAP["-#P1#"].total_termin : 0>
                            <CFSET R_VERILMEYEN= structKeyExists(ALLRECORDED_MAP, "-#P1#") ? ALLRECORDED_MAP["-#P1#"].total_verilmeyen : 0>
                            
                            <tr>
                                <td style="display:none">
                                    bakiyeDegeri = #bakiyeDegeri# <br>
                                    verilenSiparisDegeri = #verilenSiparisDegeri# <br>
                                    R_HAZIR = #R_HAZIR# <br>
                                    R_TERMIN = #R_TERMIN# <br>
                                    R_VERILMEYEN = #R_VERILMEYEN# <br>
                                </td>
                                <td><strong>#PRODUCT_CODE_2#</strong></td>
                                <td>#PRODUCT_NAME#</td>
                                <td>
                                    <cfif IsDate(DELIVERY_DATE)>
                                        <span class="badge bg-info">#DateFormat(DELIVERY_DATE, "dd/mm/yyyy")#</span>
                                    <cfelse>
                                        <span class="badge bg-danger">-</span>
                                    </cfif>
                                </td>
                                <td>
                                    <cfif IsDate(LISTE_BASLANGIC_TARIHI)>
                                        <span class="badge bg-secondary">#DateFormat(LISTE_BASLANGIC_TARIHI, "dd/mm/yyyy")#</span>
                                    <cfelse>
                                        <span class="badge bg-danger">Tarih Yok</span>
                                    </cfif>
                                </td>            
                                <td><span class="badge bg-warning">#bakiyeDegeri-R_HAZIR#</span></td>
                                <td><span class="badge bg-success">#verilenSiparisDegeri-R_TERMIN#</span></td>
                                <td><span class="badge bg-primary">#BS#</span></td>                            
                                
                                <td>
                                    <input type="text" class="form-control form-control-sm" name="hazir_#ORDER_ID#_#S1#" id="hazir_#ORDER_ID#_#S1#" placeholder="Hazır" value="#structKeyExists(RECORDED_MAP, "#ORDER_ID#-#P1#") ? RECORDED_MAP["#ORDER_ID#-#P1#"].hazir : ''#">
                                </td>
                                <td>
                                    <input type="text" class="form-control form-control-sm" name="termin_#ORDER_ID#_#S1#" id="termin_#ORDER_ID#_#S1#" placeholder="Termin" value="#structKeyExists(RECORDED_MAP, "#ORDER_ID#-#P1#") ? RECORDED_MAP["#ORDER_ID#-#P1#"].termin : ''#">
                                </td>
                                <td>
                                    <input type="text" class="form-control form-control-sm" name="verilmeyen_#ORDER_ID#_#S1#" id="verilmeyen_#ORDER_ID#_#S1#" placeholder="Verilmeyen" value="#structKeyExists(RECORDED_MAP, "#ORDER_ID#-#P1#") ? RECORDED_MAP["#ORDER_ID#-#P1#"].verilmeyen : ''#">
                                </td>
                            </tr>
                            </cfoutput>
                        </cfloop>
                        </tbody>
                    </cf_ajax_list>
                </div>
            </div>
            </cf_box>
        </cfloop>
        
        <div class="text-center mt-4">
            <button type="submit" class="btn btn-primary btn-lg">
                <i class="bi bi-save"></i> Verileri Kaydet
            </button>
        </div>
    </form>



<script>
    // Form datasını JSON objesine dönüştüren fonksiyon
    function formToJSON(formId) {
        var formData = $('#' + formId).serializeArray();
        var jsonObject = {};
        
        $.each(formData, function(index, field) {
            jsonObject[field.name] = field.value;
        });
        
        return jsonObject;
    }
    
    // Alternatif: Daha gelişmiş versiyon (array değerleri destekler)
    function formToJSONAdvanced(formId) {
        var formData = $('#' + formId).serializeArray();
        var jsonObject = {};
        
        $.each(formData, function(index, field) {
            // Eğer aynı isimde birden fazla alan varsa array yap
            if (jsonObject[field.name]) {
                if (!Array.isArray(jsonObject[field.name])) {
                    jsonObject[field.name] = [jsonObject[field.name]];
                }
                jsonObject[field.name].push(field.value);
            } else {
                jsonObject[field.name] = field.value;
            }
        });
        
        return jsonObject;
    }
    
    // Kullanım örneği
    $(document).ready(function() {
        // Form submit olduğunda - console'a JSON yazdır ama normal submit yapsın
        $('#sipform').on('submit', function(e) {
            var formJSON = formToJSON('sipform');
            console.log('Form JSON:', formJSON);
            console.log('Form JSON String:', JSON.stringify(formJSON, null, 2));
            
            // Normal form submit devam etsin (preventDefault yok)
        });
        
        // Butona tıklandığında JSON'u görmek için
        window.getFormJSON = function() {
            var formJSON = formToJSON('sipform');
            alert(JSON.stringify(formJSON, null, 2));
            return formJSON;
        };
    });
</script>

</body>
</html>