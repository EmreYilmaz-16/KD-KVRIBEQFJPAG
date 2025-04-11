
<cf_box title="Yeni Ürün Ekle">
    <div style="height:100vh">
<cfquery name="getOfferRows" datasource="#dsn3#">
    SELECT * FROM OFFER_ROW WHERE OFFER_ID=#attributes.OFFER_ID# AND WRK_ROW_ID<>'#attributes.wrkRowId#'
</cfquery>
<cfform method="post" action="">
<div class="row">
    <div class="col col-3">
<cf_box title="Yeni Ürün">
    
        
            <cfoutput>
            <div class="form-group">
                <label for="product_name">Ürün Adı</label>
                <input type="text" class="form-control" id="product_name" name="product_name" value="#attributes.productName#">
            </div>
            
            </cfoutput>
        

    
</cf_box>
</div>
<div class="col col-9">
    <cf_box title="Alternatif Ürün Seç">
        <ul>
        <cfoutput query="getOfferRows">
            <li>
               <input type="checkbox" name="alternatif" value="#WRK_ROW_ID#"> #PRODUCT_NAME#
            </li>
        </cfoutput>
    </ul>
    </cf_box> 
</div>
</div>
</cfform>
</div>
</cf_box>
