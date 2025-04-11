<cfdump var="#attributes#">
<cfquery name="getOfferRows" datasource="#dsn3#">
    SELECT * FROM OFFER_ROW WHERE OFFER_ID=#attributes.OFFER_ID#
</cfquery>

<div class="row">
    <div class="col">
<cf_box title="Yeni Ürün">
    
        <cfform method="post" action="">
            <cfoutput>
            <div class="form-group">
                <label for="product_name">Ürün Adı</label>
                <input type="text" class="form-control" id="product_name" name="product_name" value="#attributes.productName#">
            </div>
            
            </cfoutput>
        </cfform>

    
</cf_box>
</div>
<div class="col">
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