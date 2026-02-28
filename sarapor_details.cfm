<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Şara Rapor Detayları</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    
    <style>
        body {
            background-color: #f8f9fa;
        }
        .container {
            margin-top: 30px;
        }
        .table-container {
            background-color: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
<cfif isDefined("attributes.is_submit") AND attributes.is_submit EQ "1">
    <cfset company = attributes.company>
    <cfset product = attributes.product>
    <cfset date = attributes.date>
    <cfset stock_id_list = ListToArray(attributes.stock_id_list)>
    <cfset product_id_list = ListToArray(attributes.product_id_list)>
    
    <!-- Burada formdan gelen verileri işleyebilir ve kaydedebilirsiniz -->
    <cfoutput>
        <p><strong>Company:</strong> #company#</p>
        <p><strong>Product:</strong> #product#</p>
        <p><strong>Date:</strong> #date#</p>
        <p><strong>Stock ID List:</strong> #attributes.stock_id_list#</p>
        <p><strong>Product ID List:</strong> #attributes.product_id_list#</p>
    </cfoutput>
       <cfquery name="del" datasource="w3Qa_1">
                DELETE FROM w3Qa_1.SATINALMA_PLANLAMA_PBS 
                WHERE COMPANY_ID = #company#
            </cfquery>
    <!-- Verileri kaydetmek için gerekli sorguları ekleyebilirsiniz -->
    <cfloop from="1" to="#ArrayLen(stock_id_list)#" index="i">
        <cfset current_stock_id = stock_id_list[i]>
        <cfset current_product_id = product_id_list[i]>
        
        <cfset hazir_field_name = "hazir_" & current_stock_id>
        <cfset termin_field_name = "termin_" & current_stock_id>
        <cfset verilmeyen_field_name = "verilmeyen_" & current_stock_id>
        
        <cfset hazir_value = isDefined("attributes.#hazir_field_name#") ? attributes[hazir_field_name] : 0>
        <cfset termin_value = isDefined("attributes.#termin_field_name#") ? attributes[termin_field_name] : 0>
        <cfset verilmeyen_value = isDefined("attributes.#verilmeyen_field_name#") ? attributes[verilmeyen_field_name] : 0>
        
        <cfif IsNumeric(hazir_value) OR IsNumeric(termin_value) OR IsNumeric(verilmeyen_value)>
         
            <cfquery datasource="w3Qa_1">
                INSERT INTO w3Qa_1.SATINALMA_PLANLAMA_PBS 
                (COMPANY_ID, PRODUCT_ID, HAZIR, TERMIN, VERILMEYEN)
                VALUES (
                    #company#,
                    #current_product_id#,
                    #IsNumeric(hazir_value) ? hazir_value : 0#,
                    #IsNumeric(termin_value) ? termin_value : 0#,
                    #IsNumeric(verilmeyen_value) ? verilmeyen_value : 0#
                )
            </cfquery>
        </cfif>
    </cfloop>
    
    <div class="alert alert-success mt-3" role="alert">
        <i class="bi bi-check-circle"></i> Veriler başarıyla kaydedildi!
    </div>

</cfif>


<cfquery name="getData" datasource="w3Qa_1">
    SELECT SUM(SOUT) AS BS,S1,P1, PRODUCT_CODE_2, PRODUCT_NAME, PRODUCT_CODE,(SELECT SUM(ISNULL(STOCK_IN,0)-ISNULL(STOCK_OUT,0)) FROM w3Qa_2026_1.STOCKS_ROW AS SR WHERE SR.STOCK_ID=T.P1) AS BK FROM (
SELECT  
S.STOCK_ID S1,
ORDR.ORDER_ROW_CURRENCY,
S.PRODUCT_ID P1,
S.PRODUCT_CODE_2,
S.PRODUCT_NAME,
S.PRODUCT_CODE,
O.COMPANY_ID,
RESERVE_STOCK_IN-STOCK_IN AS SIN,
RESERVE_STOCK_OUT-STOCK_OUT AS SOUT
FROM w3Qa_1.ORDER_ROW_RESERVED AS ORR
LEFT JOIN w3Qa_1.ORDER_ROW AS ORDR ON ORDR.WRK_ROW_ID=ORR.ORDER_WRK_ROW_ID
LEFT JOIN w3Qa_1.ORDERS AS O ON O.ORDER_ID=ORDR.ORDER_ID
LEFT JOIN w3Qa_1.STOCKS AS S ON S.STOCK_ID=ORDR.STOCK_ID
WHERE O.PURCHASE_SALES=1 AND ORDR.ORDER_ROW_CURRENCY NOT IN (-9,-10,-3) AND O.RESERVED=1
AND O.COMPANY_ID=#attributes.company#  AND S.BRAND_ID=6
) AS T WHERE SOUT >0  --AND P1=5350
GROUP BY S1,P1, PRODUCT_CODE_2, PRODUCT_NAME, PRODUCT_CODE
</cfquery>
<cfset pid_list=valueList(getData.P1)>

<cfquery name="getData2" datasource="w3Qa_1">
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
FROM w3Qa_1.ORDER_ROW_RESERVED AS ORR
LEFT JOIN w3Qa_1.ORDER_ROW AS ORDR ON ORDR.WRK_ROW_ID=ORR.ORDER_WRK_ROW_ID
LEFT JOIN w3Qa_1.ORDERS AS O ON O.ORDER_ID=ORDR.ORDER_ID
LEFT JOIN w3Qa_1.STOCKS AS S ON S.STOCK_ID=ORDR.STOCK_ID
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
<cfquery name="GETRECORDED" datasource="w3Qa_1">
SELECT * FROM w3Qa_1.SATINALMA_PLANLAMA_PBS WHERE COMPANY_ID=#attributes.company#
</cfquery>
<cfset RECORDED_MAP = {}>
<cfloop query="GETRECORDED">
    <cfset recorded_product_id = PRODUCT_ID>
    <cfset recorded_hazir = HAZIR>
    <cfset recorded_termin = TERMIN>
    <cfset recorded_verilmeyen = VERILMEYEN>
    <cfset RECORDED_MAP["-#recorded_product_id#"] = {
        "hazir": recorded_hazir,
        "termin": recorded_termin,
        "verilmeyen": recorded_verilmeyen
    }>
</cfloop>
<cfquery name="GETALLRECORDED" datasource="w3Qa_1">
SELECT SUM(HAZIR) AS TOTAL_HAZIR, SUM(TERMIN) AS TOTAL_TERMIN, SUM(VERILMEYEN) AS TOTAL_VERILMEYEN,PRODUCT_ID FROM w3Qa_1.SATINALMA_PLANLAMA_PBS WHERE PRODUCT_ID IN (#pid_list#)  GROUP BY PRODUCT_ID
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
<div class="container">
    <div class="table-container">
        <h2 class="mb-4"><i class="bi bi-table"></i> Şara Rapor Detayları</h2>
        
        <form id="sipform" action="sarapor_details.cfm" method="post">
            <cfoutput>
            <input type="hidden" name="company" value="#attributes.company#">
            <input type="hidden" name="product" value="#attributes.product#">
            <input type="hidden" name="date" value="#DateFormat(Now(), 'yyyy-mm-dd')#">
            <input type="hidden" name="stock_id_list" value="#valueList(getData.S1)#">
            <input type="hidden" name="product_id_list" value="#valueList(getData.P1)#">
            <input type="hidden" name="is_submit" value="1">
            </cfoutput>
            
            <div class="table-responsive">
                <table class="table table-striped table-hover">
                    <thead class="table-dark">
                        <tr>
                            
                            <th>KD KODU</th>
                            <th>ÜRÜN ADI</th>
                            <th>STOKTAKİ MİKTAR</th>
                            <th>ALINAN SİPARİŞ REZERV</th>
                            <th>Sipariş Miktarı</th>                                
                            <th>HAZIR</th>
                            <th>TERMIN</th>
                            <th>VERİLMEYEN</th>
                        </tr>
                    </thead>
                    <tbody>
                    <cfloop query="getData">
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
                            <td><span class="badge bg-warning">#bakiyeDegeri-R_HAZIR#</span></td>
                            <td><span class="badge bg-success">#verilenSiparisDegeri-R_TERMIN#</span></td>
                            <td><span class="badge bg-primary">#BS#</span></td>                            
                            
                            <td>
                                <input type="text" class="form-control form-control-sm" name="hazir_#S1#" id="hazir_#S1#" placeholder="HAZIR değeri" value="#structKeyExists(RECORDED_MAP, "-#P1#") ? RECORDED_MAP["-#P1#"].hazir : ''#">
                            </td>
                            <td>
                                <input type="text" class="form-control form-control-sm" name="termin_#S1#" id="termin_#S1#" placeholder="TERMIN değeri" value="#structKeyExists(RECORDED_MAP, "-#P1#") ? RECORDED_MAP["-#P1#"].termin : ''#">
                            </td>
                            <td>
                                <input type="text" class="form-control form-control-sm" name="verilmeyen_#S1#" id="verilmeyen_#S1#" placeholder="Verilmeyen değeri" value="#structKeyExists(RECORDED_MAP, "-#P1#") ? RECORDED_MAP["-#P1#"].verilmeyen : ''#">
                            </td>
                        </tr>
                        </cfoutput>
                    </cfloop>
                </tbody>
            </table>
        </div>
        
        <div class="text-center mt-4">
            <button type="submit" class="btn btn-primary btn-lg">
                <i class="bi bi-save"></i> Verileri Kaydet
            </button>
        </div>
        </form>
    </div>
</div>

<!-- jQuery -->
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<!-- Bootstrap 5 JS Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

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