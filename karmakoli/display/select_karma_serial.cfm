<cf_box title="Karma Seri No Seçimi" modal_id="#attributes.modal_id#" width="600" height="400">
     
    <cfdump var="#attributes#" label="Attributes">
    <cfif attributes.IS_SERIAL_NO eq 1>
        <cfquery name="getSerials" datasource="#dsn3#">
            SELECT TT.*,P.PRODUCT_NAME,P.PRODUCT_CODE_2,P.PRODUCT_CODE FROM (
SELECT STOCK_ID,SUM(CASE WHEN IN_OUT =1 THEN 1 ELSE -1 END) AS BKY,DEPARTMENT_ID,LOCATION_ID,SERIAL_NO  
FROM SERVICE_GUARANTY_NEW WHERE STOCK_ID=(SELECT STOCK_ID FROM STOCKS WHERE PRODUCT_ID=#attributes.PRODUCT_ID#)
GROUP BY STOCK_ID,DEPARTMENT_ID,LOCATION_ID,SERIAL_NO
HAVING DEPARTMENT_ID=#listFirst(attributes.PACKAGING_STORE,"-")# AND LOCATION_ID=#listLast(attributes.PACKAGING_STORE,"-")# 
) AS TT LEFT JOIN #DSN1#.STOCKS AS S ON S.STOCK_ID=TT.STOCK_ID 
LEFT JOIN #DSN1#.PRODUCT AS P ON P.PRODUCT_ID=S.PRODUCT_ID
WHERE TT.BKY>0
        </cfquery>
<cf_grid_list>
    <thead>
        <tr>            
            <th>Seri No</th>
            <th>Eta Kodu</th>
            <th>Ürün Kodu</th>
            <th>Ürün</th>
        </tr>
    </thead>
    <tbody><!------(MAIN_PRODUCT_ID,PRODUCT_ID,QUANTITY,SERIAL_NO)------>
        <cfoutput query="getSerials">
            <tr >
                <td><a onclick="selectProducts('#attributes.MAIN_PRODUCT_ID#','#attributes.PRODUCT_ID#','#attributes.QUANTITY#','#SERIAL_NO#',this,'#attributes.modal_id#')">#SERIAL_NO#</a></td>
                <td>#PRODUCT_CODE_2#</td>
                <td>#PRODUCT_CODE#</td>
                <td>#PRODUCT_NAME#</td>
            </tr>
        </cfoutput>
    </tbody>

</cf_grid_list>    
<cfelse>
    <cfquery name="GETsTOCKS" datasource="#DSN2#">
        SELECT SUM(STOCK_IN-STOCK_OUT) AS BKY ,SR.STORE,SR.STORE_LOCATION,P.PRODUCT_NAME,P.PRODUCT_CODE_2,P.PRODUCT_CODE FROM STOCKS_ROW SR 
LEFT JOIN #DSN1#.STOCKS AS S ON S.STOCK_ID=SR.STOCK_ID
LEFT JOIN #DSN1#.PRODUCT AS P ON P.PRODUCT_ID=S.PRODUCT_ID
WHERE P.PRODUCT_ID=#attributes.PRODUCT_ID#
GROUP BY SR.STORE,SR.STORE_LOCATION,P.PRODUCT_NAME,P.PRODUCT_CODE_2,P.PRODUCT_CODE
HAVING STORE=#listFirst(attributes.PACKAGING_STORE,"-")# AND STORE_LOCATION=#listLast(attributes.PACKAGING_STORE,"-")#
    </cfquery>
<cf_grid_list>
    <thead>
        <tr>
            <th>Eta Kodu</th>
            <th>Ürün Kodu</th>
            <th>Ürün</th>
            <th>Stok Miktarı</th>
            <th>Eklenebilir</th>
        </tr>
    </thead>
    <tbody><!------(MAIN_PRODUCT_ID,PRODUCT_ID,QUANTITY,SERIAL_NO)------>
        <cfoutput query="GETsTOCKS">
            
            <tr >
                     <td>#PRODUCT_CODE_2#</td>
                <td>#PRODUCT_CODE#</td>
                <td>#PRODUCT_NAME#</td>
                <td>#BKY#</td>
                <td>
                    <cfif BKY gt attributes.REQUIRED_TOTAL>
                        <a onclick="selectProducts('#attributes.MAIN_PRODUCT_ID#','#attributes.PRODUCT_ID#','#attributes.REQUIRED_TOTAL#','',this,'#attributes.modal_id#')">#attributes.REQUIRED_TOTAL#</a>
                    <cfelseif BKY lte attributes.REQUIRED_TOTAL and BKY gt 0>
                        <a onclick="selectProducts('#attributes.MAIN_PRODUCT_ID#','#attributes.PRODUCT_ID#','#BKY#','',this,'#attributes.modal_id#')">#BKY#</a>
                    <cfelse>
                        0
                    </cfif>

                </td>
            </tr>
        </cfoutput>
    </tbody>
</cf_grid_list>

</cfif>
<script>
    $(document).ready(function(){
        console.table(SelecttedArr);
    });
</script>





    <button class="btn btn-danger" onclick="closeBoxDraggable(<cfoutput>#attributes.modal_id#</cfoutput>)">Kapat</button>
</cf_box>