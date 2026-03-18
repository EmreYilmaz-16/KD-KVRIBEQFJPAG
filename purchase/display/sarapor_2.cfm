<cf_box title="Dönmez Toplu Ürün Takip Modülü" >
<cfparam name="attributes.brand_id" default="6">


        


<cfform name="reportForm" method="post" action="#request.self#?fuseaction=#attributes.fuseaction#">
    <input type="hidden" name="is_submit" value="1">
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
                    <table>
                        <tr>
                            <td>
                                <div class="form-group">
                                    <label>Satış Rezervi Olanlar</label>
                                    <input type="checkbox" name="only_sales" <cfif isDefined("attributes.only_sales") AND attributes.only_sales EQ "1">checked</cfif> id="only_sales" value="1">
                                </div>
                            </td>
                            <td>
                                <div class="form-group">
                                    <label>Satınalma Rezervi Olanlar</label>
                                    <input type="checkbox" name="only_purchase" <cfif isDefined("attributes.only_purchase") AND attributes.only_purchase EQ "1">checked</cfif> id="only_purchase" value="1">
                                </div>
                            </td>
                            <td>
                        <button type="submit" class="btn btn-success mt-4" onclick="hesapyap()">Hesapla</button>
                            </td>
                        </tr>
                    </table>
                 
                      
                    <table>
                        <tr>
                            <td>

                    
<div class="form-group" style="display:none">
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

        
<div class="form-group" style="display:none">
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
    <button type="button" class="btn btn-primary mt-4" onclick="saveRows(<CFOUTPUT>#session.ep.userid#</CFOUTPUT>)">Satın Alma Miktarlarını Kaydet</button>
    <button type="button" class="btn btn-secondary mt-4" onclick="saveOrder()">Sipariş Oluştur</button>
    <button type="button" class="btn btn-warning mt-4" onclick="hesapyap()">Hesapla</button>
</td>
                        </tr>
                    </table>

                    
</cfform>
<div class="form-group">
    <div class="input-group">
        <span class="input-group-addon">
            <i class="fa fa-search"></i>
        </span>
        <input type="text" id="searchInput" class="form-control" placeholder="Ara..." onkeyup="filterTable(this, event)">
    </div>
</div>
<script>
    function filterTable(input, event) {
        var filterText = input.value.toLowerCase().trim();
        var rows = document.querySelectorAll('tbody tr[data-pid]');
        
        rows.forEach(function(row) {
            var productCode = row.cells[0].textContent.toLowerCase(); // Ürün Kodu
            var productName = row.cells[1].textContent.toLowerCase(); // Ürün Adı
            
            if (productCode.includes(filterText) || productName.includes(filterText)) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    }
</script>
<cfif not isDefined("attributes.is_submit")>
    <p>Filtreleme seçeneklerini belirleyip "Göster" butonuna tıklayınız.</p>
<cfabort>
</cfif>
<cfquery name="RAPOR_SQL" datasource="#dsn3#">
   SELECT * FROM (
    SELECT
    PR.PRODUCT_NAME,
    PR.PRODUCT_CODE,
    PR.PRODUCT_CODE_2,
    PR.PRODUCT_ID,
    PR.BRAND_ID,
    ISNULL(PRICE.PRICE,0) AS PRICE ,
    ISNULL(PRICE.MONEY,'TL') AS MONEY,
    (SELECT SUM(ISNULL(STOCK_IN,0)-ISNULL(STOCK_OUT,0)) FROM #dsn2#.STOCKS_ROW AS SR WHERE SR.STOCK_ID=PR.PRODUCT_ID) AS BK,
    JSON_QUERY(VSIP.GT)   AS VSIP,
    JSON_QUERY(RPR.RPR) AS RPR,
    JSON_QUERY(ASIP.ASIP) AS ASIP
FROM #dsn3#.STOCKS AS PR
  OUTER APPLY (
        SELECT TOP 1 
            PRICE.PRICE, 
            PRICE.MONEY, 
            PRICE.STARTDATE
        FROM #dsn3#.PRICE_HISTORY AS PRICE 
        WHERE PRICE.PRODUCT_ID = PR.PRODUCT_ID
            AND PRICE.PRICE_CATID = 1
            AND PRICE.STARTDATE <= GETDATE()
            AND (PRICE.FINISHDATE IS NULL OR GETDATE() <= PRICE.FINISHDATE)
        ORDER BY PRICE.STARTDATE DESC
    ) AS PRICE

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
                YEAR(O.DELIVERDATE)  AS ODY,
                MONTH(O.DELIVERDATE) AS ODM,
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
                SELECT PRODUCT_ID, HAZIR, TERMIN, VERILMEYEN,COMPANY_ID,ORDER_ID FROM #dsn3#.SATINALMA_PLANLAMA_PBS 
            ) AS SPB ON SPB.PRODUCT_ID = ORDR.PRODUCT_ID AND SPB.COMPANY_ID = O.COMPANY_ID AND SPB.ORDER_ID = O.ORDER_ID
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
WHERE 1=1  
    AND PR.BRAND_ID=6

<cfif structKeyExists(attributes, "only_sales") AND attributes.only_sales EQ "1">
    AND ASIP IS NOT NULL
</cfif>
<cfif structKeyExists(attributes, "only_purchase") AND attributes.only_purchase EQ "1">
    AND VSIP IS NOT NULL
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
<cfset totalColspanCount=3>

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
            <!--- SBP_MAP için key yoksa oluştur, varsa topla --->
            <cfset sbpKey = "#item.COMPANY_ID#-#item.P3#">
            <cfif NOT structKeyExists(SBP_MAP, sbpKey)>
                <cfset SBP_MAP[sbpKey] = {
                    HAZIR: 0,
                    TERMIN: 0,
                    VERILMEYEN: 0
                }>
            </cfif>
            <cfset SBP_MAP[sbpKey].HAZIR += (structKeyExists(item, "HAZIR") ? item.HAZIR : 0)>
            <cfset SBP_MAP[sbpKey].TERMIN += (structKeyExists(item, "TERMIN") ? item.TERMIN : 0)>
            <cfset SBP_MAP[sbpKey].VERILMEYEN += (structKeyExists(item, "VERILMEYEN") ? item.VERILMEYEN : 0)>
            
            <cfif structKeyExists(item, "COMPANY_ID")>
                <!--- Initialize key if it doesn't exist --->
                <cfif NOT structKeyExists(ASIP_MAP, "#item.COMPANY_ID#-#PRODUCT_ID#")>
                    <cfset ASIP_MAP["#item.COMPANY_ID#-#PRODUCT_ID#"] = 0>
                </cfif>
                <cfset ASIP_MAP["#item.COMPANY_ID#-#PRODUCT_ID#"] = ASIP_MAP["#item.COMPANY_ID#-#PRODUCT_ID#"] + item.BS>
                
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
<script>
    var jsSession=<cfoutput>#serializeJSON(session)#</cfoutput>;
    var dataSources={
     <cfoutput>   dsn: "#dsn#",
        dsn2: "#dsn2#",
        dsn3: "#dsn3#",
        dsn1: "#dsn1#"
    </cfoutput>
    };
</script>

<cfquery name="getSaved" datasource="w3Qa_1">
SELECT product_id, quantity, yurtdisi_miktar,IS_FOREIGN FROM w3Qa_1.orders_sepet_pbs WHERE user_id = #session.ep.userid# and is_converted = 0
</cfquery>
<cfset SAVED_MAP = {}>
<cfset YDISISAVED_MAP = {}>
<cfloop query="getSaved">
   
    <CFIF IS_FOREIGN EQ 1>
        <cfset YDISISAVED_MAP[product_id] = quantity>
    <cfelse>
         <cfset SAVED_MAP[product_id] = quantity>
    </CFIF>
</cfloop>


<cfset ArraySort(yearList, "numeric")>
<cfset ArraySort(yearMonthList, "text")>
<cfset ArraySort(companyList, "numeric")>
<!--- TODO: SUTUN EKLEMEK İÇİN BUTON OLACAK  
    SÜTÜN EKLEDİKTEN SONRA YÖNETİCİ SATINALMA MİKTARLARINI GİREBİLECEK 
    SUTUN BAŞLIĞI*----->

<cf_grid_list >
    <thead class="table-dark">
    <tr>
        <th rowspan="2">KD Kodu</th>
        <th rowspan="2">Ürün Adı</th>
        <th rowspan="2">Bakiye</th>
        <cfoutput>
        <cfloop array="#yearList#" index="year">
            <cfset totalColspanCount = totalColspanCount + 2>
            <th rowspan="2">#year# Toplam</th>
            <th rowspan="2">#year# Aylık</th>
        </cfloop>
        <cfloop array="#yearList#" index="year">
            
            <cfloop array="#yearMonthList#" index="yearMonth">
                <cfif ListFirst(yearMonth, "-") EQ year>
                    <cfset totalColspanCount = totalColspanCount + 2>
                    <th colspan="2">#yearMonth#</th>
                </cfif>
            </cfloop>
        </cfloop>
        <th colspan="2">Yurt İçi</th>
        
        <th colspan="2">Yurt Dışı</th>
        
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
        <th>Miktar</th>
        <th>Tutar</th>
        <th>Miktar</th>
        <th>Tutar</th>
    </tr>
    </thead>
    <tbody>
    <cfoutput query="RAPOR_SQL">
    <tr data-pid="#PRODUCT_ID#" data-price="#PRICE#" data-money="#MONEY#">
        <td>#PRODUCT_CODE_2#</td>
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
            <input type="number" id="samiktar_#PRODUCT_ID#" onfocus="this.select()" data-pid="#PRODUCT_ID#" data-money="#MONEY#" data-price="#PRICE#" onchange="hesapla(this,#PRODUCT_ID#,1,'#MONEY#')"  name="siparis_miktari" class="form-control form-control-sm purchase-quantity" value="#structKeyExists(SAVED_MAP, PRODUCT_ID) ? SAVED_MAP[PRODUCT_ID] : 0#">
        </td>
        <td id="calc_result1_#PRODUCT_ID#"></td>
          <td>
            <input type="number" id="syamiktar_#PRODUCT_ID#" onfocus="this.select()" data-pid="#PRODUCT_ID#" data-money="#MONEY#" data-price="#PRICE#" onchange="hesapla(this,#PRODUCT_ID#,2,'#MONEY#')"  name="siparis_miktari_ydisi" class="form-control form-control-sm purchase-quantity" value="#structKeyExists(YDISISAVED_MAP, PRODUCT_ID) ? YDISISAVED_MAP[PRODUCT_ID] : 0#">
        </td>
        <td id="calc_result2_#PRODUCT_ID#"></td>
        <cfloop array="#companyList#" index="company">
            <td class="company-order fw-bold">
                <cfif StructKeyExists(ASIP_MAP, "#company#-#PRODUCT_ID#")>
                    <a href="javascript:void(0)" onclick="window.open('#request.self#?fuseaction=purchase.emptypopup_termin_detay_pbs&company=#company#&product=#PRODUCT_ID#', '_blank')">#NumberFormat(ASIP_MAP["#company#-#PRODUCT_ID#"], "9,999.99")#</a><br>
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
    <tfoot>
        <tr>
            <td colspan="<cfoutput>#totalColspanCount#</cfoutput>">Toplam:</td>
            <td></td>
           <td colspan="">
             <span id="sub_total_yurtici">0</span>
           </td>
           <td></td>
             <td colspan="">
             <span id="sub_total_yurtdisi">0</span>
           </td>
                
                    <td colspan="<cfoutput>#arrayLen(companyList)#</cfoutput>">
                       
                    </td>
                
            
        </tr>
    </tfoot>
</cf_grid_list>

    <script>
   function hesapyap(){
    tumunuHesapla();
        calculateSubTotals();
   }
    function hesapla(el,pid,type,money){
        var price=parseFloat(document.querySelector('tr[data-pid="'+pid+'"]').getAttribute("data-price"));
        var money=document.querySelector('tr[data-pid="'+pid+'"]').getAttribute("data-money");
        var miktar=parseFloat(el.value);
        var sonuc=miktar*price;
        if(type==1){
            document.getElementById("calc_result1_"+pid).textContent=!isNaN(sonuc) ? sonuc.toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2}) + " " + money : "";
        } else {
            document.getElementById("calc_result2_"+pid).textContent=!isNaN(sonuc) ? sonuc.toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2}) + " " + money : "";
        }
        calculateSubTotals();
    }
    function tumunuHesapla(){
        var elems=document.getElementsByName("siparis_miktari");
        for (let index = 0; index < elems.length; index++) {
            var el=elems[index];
            var pid=el.getAttribute("data-pid");
            var money=el.getAttribute("data-money");
            hesapla(el,pid,1,money);
        }
        var elems2=document.getElementsByName("siparis_miktari_ydisi");
        for (let index = 0; index < elems2.length; index++) {
            var el=elems2[index];
            var pid=el.getAttribute("data-pid");
            var money=el.getAttribute("data-money");
            hesapla(el,pid,2,money);
        }
    }
    function calculateSubTotals() {
        var totals1 = {};
        var totals2 = {};

        var elems = document.getElementsByName('siparis_miktari');
        for (var i = 0; i < elems.length; i++) {
            var el = elems[i];
            var pid = el.getAttribute('data-pid');
            var price = parseFloat(document.querySelector('tr[data-pid="'+pid+'"]').getAttribute('data-price')) || 0;
            var money = document.querySelector('tr[data-pid="'+pid+'"]').getAttribute('data-money') || '';
            var miktar = parseFloat(el.value) || 0;
            totals1[money] = (totals1[money] || 0) + miktar * price;
        }

        var elems2 = document.getElementsByName('siparis_miktari_ydisi');
        for (var j = 0; j < elems2.length; j++) {
            var el2 = elems2[j];
            var pid2 = el2.getAttribute('data-pid');
            var price2 = parseFloat(document.querySelector('tr[data-pid="'+pid2+'"]').getAttribute('data-price')) || 0;
            var money2 = document.querySelector('tr[data-pid="'+pid2+'"]').getAttribute('data-money') || '';
            var miktar2 = parseFloat(el2.value) || 0;
            totals2[money2] = (totals2[money2] || 0) + miktar2 * price2;
        }

        document.getElementById('sub_total_yurtici').innerHTML = Object.keys(totals1).map(function(cur) {
            return totals1[cur].toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2}) + ' ' + cur;
        }).join('<br>');

        document.getElementById('sub_total_yurtdisi').innerHTML = Object.keys(totals2).map(function(cur) {
            return totals2[cur].toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2}) + ' ' + cur;
        }).join('<br>');
    }

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
            var user_id = <cfoutput>#session.ep.userid#</cfoutput>; // Kullanıcı ID'sini buradan alın
            
            // Önce miktarları kaydet
            saveRows(user_id, function(success) {
                if(success) {
                    // Miktarlar başarıyla kaydedildiyse, siparişi oluştur
                    $.ajax({
                        url: "/addOns/Partner/cfc/sale_report.cfc?method=createOrder",
                        method: "POST",
                        dataType: "json",
                        contentType: "application/json",
                        data: JSON.stringify({user_id: user_id,session: jsSession,dataSources: dataSources}),
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