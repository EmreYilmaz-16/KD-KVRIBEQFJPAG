<cf_box title="Yeni Ürün Ekle">
    <div style="height:100vh">
        <cfquery name="getOfferRows" datasource="#dsn3#">
            SELECT * FROM OFFER_ROW WHERE OFFER_ID=#attributes.OFFER_ID# AND WRK_ROW_ID<>'#attributes.wrkRowId#'
        </cfquery>
        <cfform method="post" action="">
            <div class="row">
                <div class="col col-4">
                    <cf_box title="Yeni Ürün">
                        <cfoutput>
                            <div class="form-group">
                                <label for="product_name">Ürün Adı</label>
                                <input type="text" class="form-control" id="product_name" name="product_name" value="#attributes.productName#">
                            </div>            
                        </cfoutput>
                    </cf_box>
                </div>
                <div class="col col-4">
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
                <div class="col col-4">
                    <input type="hidden" name="oem_satir" value="0">
                    
                    <cf_box title="Oem No"  add_href="javascript:OemSatirEkle()">
                        <cf_big_list >
                            <tbody id="oemgrid"></tbody>
                        </cf_big_list>   
                    </cf_box> 
                </table>
                </div>
            </div>
        </cfform>
    </div>
</cf_box>

<script>
    function  OemSatirEkle() {
     var ix=document.getElementsByName("oem_satir")[0].value
    ix=parseInt(ix)+1;
    document.getElementsByName("oem_satir")[0].value=ix;
    var input=document.createElement("input");    
    input.id="oem_"+ix;
    input.name="oem_"+ix;
    var div=document.createElement("div");
    div.className="form-group";
    div.appendChild(input);
    var tr=document.createElement("tr");
    tr.id="oemtr_"+ix;
    tr.className="oemtr";
    tr.appendChild(div);

    document.getElementById("oemgrid").appendChild(tr)


    
    console.log(ix)
    
}
    function OemSatirSil() {
        var ix = document.getElementsByName("oem_satir")[0].value;
        ix = parseInt(ix) - 1;
        document.getElementsByName("oem_satir")[0].value = ix;
        var tr = document.getElementById("oemtr_" + (ix + 1));
        tr.parentNode.removeChild(tr);

        // Reassign IDs and names for remaining rows
        var rows = document.querySelectorAll("#oemgrid .oemtr");
        for (var i = 0; i < rows.length; i++) {
            var input = rows[i].querySelector("input");
            input.id = "oem_" + (i + 1);
            input.name = "oem_" + (i + 1);
            rows[i].id = "oemtr_" + (i + 1);
        }
    }
</script>