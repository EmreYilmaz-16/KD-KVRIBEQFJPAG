<cf_box title="Satış Raporu" >
<cfparam name="attributes.brand_id" default="6">


        


<cfform name="reportForm" method="post" action="#request.self#?fuseaction=#attributes.fuseaction#">
    <div style="display:none" class="form-group" id="item-brand_id">
                        <label>Marka </label>
 <select name="brand_id" class="form-control">
    <option value="">Tümü</option>
    <cfquery name="brandQuery" datasource="#dsn3#">
        SELECT DISTINCT BRAND_ID, BRAND_NAME
        FROM w3Qa_product.PRODUCT_BRANDS
        </cfquery>
    <cfoutput query="brandQuery">
        <option value="#BRAND_ID#">#BRAND_NAME#</option>
    </cfoutput>
</select>

                    </div>
                    <div class="form-group">
                        <label>Sadece Satışı Olanlar Gelsin</label>
                        <input type="checkbox" name="only_sales" id="only_sales" value="1">
                    </div>
                    <table>
                        <tr>
                            <td>

                    
<div class="form-group">
    <label>Yıl Seçimi</label>
    <select name="selected_year" class="form-control">
        <cfloop from="#year(now())#" to="#year(now())+5#" index="i">
            <cfoutput>
                <option value="#i#">#i#</option>
            </cfoutput>
        </cfloop>
    </select>
</div>
        </td>
        <td>

        
<div class="form-group">
    <label>Ay Seçimi</label>
    <select name="selected_month" class="form-control">
        <cfloop from="1" to="12" index="j">
            <cfoutput>
                <option value="#j#">#j# - #MonthAsString(j)#</option>
            </cfoutput>
        </cfloop>
    </select>
</div>
</td>
<td>
    <button type="button" class="btn btn-primary mt-4" onclick="saveRows(1)">Satın Alma Miktarlarını Kaydet</button>
    <button type="button" class="btn btn-secondary mt-4" onclick="saveOrder()">Sipariş Oluştur</button>
</td>
                        </tr>
                    </table>

                    <input type="submit" value="Raporu Göster">
</cfform>
<cfquery name="RAPOR_SQL" datasource="#dsn3#">
   SELECT * FROM (
    SELECT
    PR.PRODUCT_NAME,
    PR.PRODUCT_CODE,
    PR.PRODUCT_ID,
    PR.BRAND_ID,
    (SELECT SUM(ISNULL(STOCK_IN,0)-ISNULL(STOCK_OUT,0)) FROM #dsn2#.STOCKS_ROW AS SR WHERE SR.STOCK_ID=PR.PRODUCT_ID) AS BK,
    JSON_QUERY(VSIP.GT)   AS VSIP,
    JSON_QUERY(RPR.RPR) AS RPR,
    JSON_QUERY(ASIP.ASIP) AS ASIP
FROM #dsn3#.STOCKS AS PR

OUTER APPLY (
    SELECT (
        SELECT
            CAST(SUM(T.SIN) AS DECIMAL(18,2)) AS BS,
            T.S1,
            T.P1,
            T.ODM,
            T.ODY,
            T.IS_FOREIGN
        FROM (
            SELECT
                ORDR.STOCK_ID AS S1,
                ORDR.PRODUCT_ID AS P1,
                YEAR(O.ORDER_DATE)  AS ODY,
                MONTH(O.ORDER_DATE) AS ODM,
                O.IS_FOREIGN,
                (RESERVE_STOCK_IN - STOCK_IN) AS SIN
            FROM #dsn3#.ORDER_ROW_RESERVED AS ORR
            LEFT JOIN #dsn3#.ORDER_ROW AS ORDR ON ORDR.WRK_ROW_ID = ORR.ORDER_WRK_ROW_ID
            LEFT JOIN #dsn3#.ORDERS   AS O    ON O.ORDER_ID = ORDR.ORDER_ID
            WHERE
                O.PURCHASE_SALES = 0
                AND O.RESERVED = 1
                AND ORDR.ORDER_ROW_CURRENCY NOT IN (-9,-10,-3)
        ) AS T
        WHERE T.SIN > 0
          AND T.P1 = PR.PRODUCT_ID
        GROUP BY T.S1, T.P1, T.ODM, T.ODY, T.IS_FOREIGN
        FOR JSON PATH
    ) AS GT
) AS VSIP

OUTER APPLY (
    SELECT (
        SELECT
            CAST(SUM(ORR.QUANTITY) AS DECIMAL(18,2)) AS TOTAL_SALE,
            CASE
                WHEN YEAR(O.ORDER_DATE) = YEAR(GETDATE())
                    THEN CAST(SUM(ORR.QUANTITY) * 1.0 / NULLIF(MONTH(GETDATE()),0) AS DECIMAL(18,2))
                ELSE CAST(SUM(ORR.QUANTITY) * 1.0 / 12 AS DECIMAL(18,2))
            END AS AVG_SALE,
            YEAR(O.ORDER_DATE) AS [YEAR],
            ORR.STOCK_ID AS S2,
            ORR.PRODUCT_ID AS P2
        FROM #dsn3#.ORDER_ROW AS ORR
        INNER JOIN #dsn3#.ORDERS AS O ON O.ORDER_ID = ORR.ORDER_ID
        WHERE
            O.PURCHASE_SALES = 1
            AND ORR.PRODUCT_ID = PR.PRODUCT_ID
        GROUP BY YEAR(O.ORDER_DATE), ORR.STOCK_ID, ORR.PRODUCT_ID
        FOR JSON PATH
    ) AS RPR
) AS RPR

OUTER APPLY (
    SELECT (
        SELECT
            CONVERT(DECIMAL(18,2), SUM(T.SOUT)) AS BS,
            T.S3,
            T.P3,
            T.COMPANY_ID,
            T.NICKNAME,
            T.HAZIR,
            T.TERMIN,
            T.VERILMEYEN
        FROM (
            SELECT
                ORDR.STOCK_ID AS S3,
                ORDR.PRODUCT_ID AS P3,
                O.COMPANY_ID,
                C.NICKNAME,
                (RESERVE_STOCK_OUT - STOCK_OUT) AS SOUT,
                CAST (SPB.HAZIR AS DECIMAL(18,2)) AS HAZIR,
                CAST (SPB.TERMIN AS DECIMAL(18,2)) AS TERMIN,
                CAST (SPB.VERILMEYEN AS DECIMAL(18,2)) AS VERILMEYEN
            FROM #dsn3#.ORDER_ROW_RESERVED AS ORR
            LEFT JOIN #dsn3#.ORDER_ROW AS ORDR ON ORDR.WRK_ROW_ID = ORR.ORDER_WRK_ROW_ID
            LEFT JOIN #dsn3#.ORDERS   AS O    ON O.ORDER_ID = ORDR.ORDER_ID
            LEFT JOIN #dsn#.COMPANY AS C ON C.COMPANY_ID = O.COMPANY_ID
            LEFT JOIN (
                SELECT PRODUCT_ID, HAZIR, TERMIN, VERILMEYEN,COMPANY_ID FROM #dsn3#.SATINALMA_PLANLAMA_PBS 
            ) AS SPB ON SPB.PRODUCT_ID = ORDR.PRODUCT_ID AND SPB.COMPANY_ID = O.COMPANY_ID
            WHERE
                O.PURCHASE_SALES = 1
                AND O.RESERVED = 1
                AND ORDR.ORDER_ROW_CURRENCY NOT IN (-9,-10,-3)
                AND O.SPECIAL_DEFINITION_PBS = 1
        ) AS T
        WHERE T.SOUT > 0
          AND T.P3 = PR.PRODUCT_ID
        GROUP BY T.S3, T.P3, T.COMPANY_ID,T.NICKNAME,T.HAZIR,T.TERMIN,T.VERILMEYEN
        FOR JSON PATH
    ) AS ASIP
) AS ASIP
   ) AS PR
--WHERE PR.PRODUCT_ID = 5350
WHERE 1=1  <cfif structKeyExists(attributes, "brand_id") AND len(trim(attributes.brand_id))>
    AND PR.BRAND_ID=#attributes.brand_id#
</cfif>
<cfif structKeyExists(attributes, "only_sales") AND attributes.only_sales EQ "1">
    AND ASIP IS NOT NULL
</cfif>
ORDER BY PR.PRODUCT_ID
</cfquery>


<!--- Parse JSON verileri ve map oluştur --->
<cfset VSIP_YURTICI_MAP = {}>
<cfset VSIP_YURTDISI_MAP = {}>
<cfset RPR_MAP = {}>
<cfset AVG_MAP = {}>
<cfset ASIP_MAP = {}>
<cfset SBP_MAP = {}>
<cfset yearList = []>
<cfset yearMonthList = []>
<cfset companyList = []>
<cfset companyNames = {}>

<cfloop query="RAPOR_SQL">
    <!--- VSIP Parse (Alış Siparişi Rezerv) --->
    <cfif len(trim(VSIP)) AND VSIP NEQ "null" AND VSIP NEQ "[]">
        <cfset vsipData = deserializeJSON(VSIP)>
        <cfloop array="#vsipData#" index="item">
            <cfif structKeyExists(item, "ODY") AND structKeyExists(item, "ODM")>
                <cfset yearMonth = "#item.ODY#-#item.ODM#">
                <cfset isForeign = structKeyExists(item, "IS_FOREIGN") AND item.IS_FOREIGN EQ 1>
                
                <!--- Yurtiçi veya Yurtdışı MAP'e kaydet --->
                <cfif isForeign>
                    <cfif NOT structKeyExists(VSIP_YURTDISI_MAP, "#PRODUCT_ID#-#yearMonth#")>
                        <cfset VSIP_YURTDISI_MAP["#PRODUCT_ID#-#yearMonth#"] = 0>
                    </cfif>
                    <cfset VSIP_YURTDISI_MAP["#PRODUCT_ID#-#yearMonth#"] = VSIP_YURTDISI_MAP["#PRODUCT_ID#-#yearMonth#"] + item.BS>
                <cfelse>
                    <cfif NOT structKeyExists(VSIP_YURTICI_MAP, "#PRODUCT_ID#-#yearMonth#")>
                        <cfset VSIP_YURTICI_MAP["#PRODUCT_ID#-#yearMonth#"] = 0>
                    </cfif>
                    <cfset VSIP_YURTICI_MAP["#PRODUCT_ID#-#yearMonth#"] = VSIP_YURTICI_MAP["#PRODUCT_ID#-#yearMonth#"] + item.BS>
                </cfif>
                
                <!--- Yıl listesi --->
                <cfif NOT ArrayFind(yearList, item.ODY)>
                    <cfset ArrayAppend(yearList, item.ODY)>
                </cfif>
                
                <!--- Yıl-Ay listesi --->
                <cfif NOT ArrayFind(yearMonthList, yearMonth)>
                    <cfset ArrayAppend(yearMonthList, yearMonth)>
                </cfif>
            </cfif>
        </cfloop>
    </cfif>
    
    <!--- RPR Parse (Satış İstatistikleri) --->
    <cfif len(trim(RPR)) AND RPR NEQ "null" AND RPR NEQ "[]">
        <cfset rprData = deserializeJSON(RPR)>
        <cfloop array="#rprData#" index="item">
            <cfif structKeyExists(item, "YEAR")>
                <cfif structKeyExists(item, "TOTAL_SALE")>
                    <cfset RPR_MAP["#item.YEAR#-#PRODUCT_ID#"] = item.TOTAL_SALE>
                </cfif>
                <cfif structKeyExists(item, "AVG_SALE")>
                    <cfset AVG_MAP["#item.YEAR#-#PRODUCT_ID#"] = item.AVG_SALE>
                </cfif>
                
                <!--- Yıl listesi --->
                <cfif NOT ArrayFind(yearList, item.YEAR)>
                    <cfset ArrayAppend(yearList, item.YEAR)>
                </cfif>
            </cfif>
        </cfloop>
    </cfif>
    
    <!--- ASIP Parse (Satış Siparişi Rezerv) --->
    <cfif len(trim(ASIP)) AND ASIP NEQ "null" AND ASIP NEQ "[]">
        <cfset asipData = deserializeJSON(ASIP)>
        <cfloop array="#asipData#" index="item">
            <CFSET SBP_MAP["#item.COMPANY_ID#-#item.P3#"] = {
                HAZIR: structKeyExists(item, "HAZIR") ? item.HAZIR : 0, 
                TERMIN: structKeyExists(item, "TERMIN") ? item.TERMIN : 0, 
                VERILMEYEN: structKeyExists(item, "VERILMEYEN") ? item.VERILMEYEN : 0
            }>
            <cfif structKeyExists(item, "COMPANY_ID")>
                <cfset ASIP_MAP["#item.COMPANY_ID#-#PRODUCT_ID#"] = item.BS>
                
                <!--- Firma listesi --->
                <cfif NOT ArrayFind(companyList, item.COMPANY_ID)>
                    <cfset ArrayAppend(companyList, item.COMPANY_ID)>
                    <!--- Firma adını kaydet --->
                    <cfif structKeyExists(item, "NICKNAME") AND len(trim(item.NICKNAME))>
                        <cfset companyNames[item.COMPANY_ID] = item.NICKNAME>
                    <cfelse>
                        <cfset companyNames[item.COMPANY_ID] = "Firma #item.COMPANY_ID#">
                    </cfif>
                </cfif>
            </cfif>
        </cfloop>
    </cfif>
</cfloop>

<cfquery name="getSaved" datasource="w3Qa_1">
SELECT product_id, quantity, yurtdisi_miktar FROM w3Qa_1.orders_sepet_pbs WHERE user_id = 1 and is_converted = 0
</cfquery>
<cfset SAVED_MAP = {}>
<cfset YDISISAVED_MAP = {}>
<cfloop query="getSaved">
    <cfset SAVED_MAP[product_id] = quantity>
    <cfset YDISISAVED_MAP[product_id] = yurtdisi_miktar>
</cfloop>


<cfset ArraySort(yearList, "numeric")>
<cfset ArraySort(yearMonthList, "text")>
<cfset ArraySort(companyList, "numeric")>
<!--- TODO: SUTUN EKLEMEK İÇİN BUTON OLACAK  
    SÜTÜN EKLEDİKTEN SONRA YÖNETİCİ SATINALMA MİKTARLARINI GİREBİLECEK 
    SUTUN BAŞLIĞI*----->

<cf_big_list >
    <thead class="table-dark">
    <tr>
        <th rowspan="2">Ürün Kodu</th>
        <th rowspan="2">Ürün Adı</th>
        <th rowspan="2">Bakiye</th>
        <cfoutput>
        <cfloop array="#yearList#" index="year">
            <th rowspan="2">#year# Toplam</th>
            <th rowspan="2">#year# Aylık</th>
        </cfloop>
        <cfloop array="#yearList#" index="year">
            <cfloop array="#yearMonthList#" index="yearMonth">
                <cfif ListFirst(yearMonth, "-") EQ year>
                    <th colspan="2">#yearMonth#</th>
                </cfif>
            </cfloop>
        </cfloop>
        <th rowspan="2">Yurt İçi</th>
        <th rowspan="2">Yurt Dışı</th>
        <cfloop array="#companyList#" index="company">
            <th rowspan="2">
                <cfif structKeyExists(companyNames, company)>
                    #companyNames[company]#
                <cfelse>
                    #company#
                </cfif>
            </th>
        </cfloop>
        </cfoutput>
    </tr>
    <tr>
        <cfoutput>
        <cfloop array="#yearList#" index="year">
            <cfloop array="#yearMonthList#" index="yearMonth">
                <cfif ListFirst(yearMonth, "-") EQ year>
                    <th>Yurtiçi</th>
                    <th>Yurtdışı</th>
                </cfif>
            </cfloop>
        </cfloop>
        </cfoutput>
    </tr>
    </thead>
    <tbody>
    <cfoutput query="RAPOR_SQL">
    <tr data-pid="#PRODUCT_ID#">
        <td>#PRODUCT_CODE#</td>
        <td>#PRODUCT_NAME#</td>
        <td><cfif isNumeric(BK)>#NumberFormat(BK, "9,999.99")#<cfelse>0</cfif></td>
         <cfloop array="#yearList#" index="year">
            <td class="year-total fw-bold">
                <cfif StructKeyExists(RPR_MAP, "#year#-#PRODUCT_ID#")>
                    #NumberFormat(RPR_MAP["#year#-#PRODUCT_ID#"], "9,999.99")#
                <cfelse>
                    
                </cfif>
            </td>
            <td class="year-avg fw-bold">
                <cfif StructKeyExists(AVG_MAP, "#year#-#PRODUCT_ID#")>
                    #NumberFormat(AVG_MAP["#year#-#PRODUCT_ID#"], "9,999.99")#
                <cfelse>
                    
                </cfif>
            </td>
        </cfloop>
            <cfloop array="#yearList#" index="year">
            <cfloop array="#yearMonthList#" index="yearMonth">
                <cfif ListFirst(yearMonth, "-") EQ year>
                    <td>
                        <cfif StructKeyExists(VSIP_YURTICI_MAP, "#PRODUCT_ID#-#yearMonth#")>
                            #NumberFormat(VSIP_YURTICI_MAP["#PRODUCT_ID#-#yearMonth#"], "9,999.99")#
                        <cfelse>
                            0
                        </cfif>
                    </td>
                    <td>
                        <cfif StructKeyExists(VSIP_YURTDISI_MAP, "#PRODUCT_ID#-#yearMonth#")>
                            #NumberFormat(VSIP_YURTDISI_MAP["#PRODUCT_ID#-#yearMonth#"], "9,999.99")#
                        <cfelse>
                            0
                        </cfif>
                    </td>
                </cfif>
            </cfloop>
        </cfloop>
       
        <td>
            <input type="number" id="samiktar_#PRODUCT_ID#" onfocus="this.select()" data-pid="#PRODUCT_ID#"  name="siparis_miktari" class="form-control form-control-sm purchase-quantity" value="#structKeyExists(SAVED_MAP, PRODUCT_ID) ? SAVED_MAP[PRODUCT_ID] : 0#">
        </td>
          <td>
            <input type="number" id="syamiktar_#PRODUCT_ID#" onfocus="this.select()" data-pid="#PRODUCT_ID#"  name="siparis_miktari_ydisi" class="form-control form-control-sm purchase-quantity" value="#structKeyExists(YDISISAVED_MAP, PRODUCT_ID) ? YDISISAVED_MAP[PRODUCT_ID] : 0#">
        </td>
        <cfloop array="#companyList#" index="company">
            <td class="company-order fw-bold">
                <cfif StructKeyExists(ASIP_MAP, "#company#-#PRODUCT_ID#")>
                    <a href="javascript:void(0)" onclick="window.open('sarapor_details.cfm?company=#company#&product=#PRODUCT_ID#', '_blank')">#NumberFormat(ASIP_MAP["#company#-#PRODUCT_ID#"], "9,999.99")#</a><br>
                    <cfif StructKeyExists(SBP_MAP, "#company#-#PRODUCT_ID#")>
                        <small>
                            H: #SBP_MAP["#company#-#PRODUCT_ID#"].HAZIR#, 
                            T: #SBP_MAP["#company#-#PRODUCT_ID#"].TERMIN#, 
                            V: #SBP_MAP["#company#-#PRODUCT_ID#"].VERILMEYEN#
                        </small>
                    </cfif>
                <cfelse>
                    #NumberFormat(0, "9,999.99")#
                </cfif>
            </td>
        </cfloop>
    </tr>
    </cfoutput>
    </tbody>
</cf_big_list>

    <script>
        function saveRows(user_id, callback) {
            var elems=document.getElementsByName("siparis_miktari")
            var SavedData=[];
            for (let index = 0; index < elems.length; index++) {
                var el=elems[index];
                var miktar=el.value;
                var ymiktar=document.getElementById("syamiktar_"+el.getAttribute("data-pid")).value;
                var pid=el.getAttribute("data-pid")
                var O={miktar, ymiktar, pid};
                console.log(O)
                SavedData.push(O)
    
            };
            var jsondata={orderData:SavedData,user_id:user_id};
            $.ajax({
                url:"/addOns/Partner/cfc/sale_report.cfc?method=saveOrderData",
                method:"POST",
                dataType:"json",
                contentType: "application/json",
                data: JSON.stringify(jsondata),
                success:function(response){
                    console.log(response);
                    if(response.SUCCESS){
                        alert(response.MESSAGE);
                        if(callback) callback(true);
                    } else {
                        alert("Hata: " + response.MESSAGE);
                        if(callback) callback(false);
                    }
                },
                error:function(xhr, status, error){
                    console.error("AJAX Error:", error);
                    alert("Kaydetme sırasında hata oluştu: " + error);
                    if(callback) callback(false);
                }
            });
        }

        function saveOrder() {
            var user_id = 1; // Kullanıcı ID'sini buradan alın
            
            // Önce miktarları kaydet
            saveRows(user_id, function(success) {
                if(success) {
                    // Miktarlar başarıyla kaydedildiyse, siparişi oluştur
                    $.ajax({
                        url: "/addOns/Partner/cfc/sale_report.cfc?method=createOrder",
                        method: "POST",
                        dataType: "json",
                        contentType: "application/json",
                        data: JSON.stringify({user_id: user_id}),
                        success: function(response) {
                            console.log(response);
                            if(response.SUCCESS) {
                                alert(response.MESSAGE);
                                location.reload(); // Sayfayı yenile
                            } else {
                                alert("Sipariş oluşturma hatası: " + response.MESSAGE);
                            }
                        },
                        error: function(xhr, status, error) {
                            console.error("Sipariş oluşturma hatası:", error);
                            alert("Sipariş oluşturulurken hata oluştu: " + error);
                        }
                    });
                } else {
                    alert("Miktarlar kaydedilemedi, sipariş oluşturulamadı.");
                }
            });
        }
    </script>
    
    
</cf_box>