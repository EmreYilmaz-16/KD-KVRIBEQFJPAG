<cf_box title="Paketleme Emiri Oluştur">
<cfquery name="getKarmaProducts" datasource="#dsn1#">
    SELECT PRODUCT_ID,PRODUCT_NAME,PRODUCT_STATUS,PRODUCT_CODE_2,PRODUCT_CODE
    FROM PRODUCT
    WHERE PRODUCT_STATUS = 1 AND ISNULL(IS_PACKAGE_PRODUCT,0) = 1
    ORDER BY PRODUCT_NAME
</cfquery>

<input type="text" name="kw" id="kw" class="form-control mb-3" placeholder="Arama..." onkeyup="filterTable(this, 'karmaEmirTable')">
<cf_grid_list >
    <thead>
        <tr>
            <th>#</th>
            <th>Ürün Kodu</th>
            <th>Eta Kodu</th>
            <th>Ürün</th>            
        </tr>
    </thead>
    <tbody id="karmaEmirTable">
        <cfoutput query="getKarmaProducts">
            <tr>
                <td>#currentRow#</td>
                <td><a href="javascript://" onclick="CreateKarmaEmir(#PRODUCT_ID#)">#PRODUCT_CODE#</a></td>
                <td>#PRODUCT_CODE_2#</td>
                <td>#PRODUCT_NAME#</td>                
            </tr>
        </cfoutput>    
    </tbody>
</cf_grid_list>
<script>
    function filterTable(input, tableId) {
        var filter = input.value.toUpperCase();
        var table = document.getElementById(tableId);
        var tr = table.getElementsByTagName("tr");
        for (var i = 0; i < tr.length; i++) {
            var tdArray = tr[i].getElementsByTagName("td");
            var rowContainsFilter = false;
            for (var j = 0; j < tdArray.length; j++) {
                var td = tdArray[j];
                if (td) {
                    if (td.innerText.toUpperCase().indexOf(filter) > -1) {
                        rowContainsFilter = true;
                        break;
                    }
                }
            }
            tr[i].style.display = rowContainsFilter ? "" : "none";
        }
    }
    function CreateKarmaEmir(product_id) {
        var miktar=prompt("Miktar Giriniz", "1");
        if(miktar!=null && miktar!="" && !isNaN(miktar)){
           fetch('/index.cfm?fuseaction=product.emptypopup_add_paket_emir&PRODUCT_ID=' + product_id + "&AMOUNT=" + miktar + "&ajax=1&ajax_box_page=1&isAjax=1")
		.then(response => response.json())
		.then(data => {
			if (data.success) {
				alert('Paketleme emri başarıyla oluşturuldu. Emir No: ' + data.emirNo);
				// Sayfayı yenile
				window.opener.location.reload();
                window.close();
			} else {
				alert('Hata!\n\n' + data.message);
				
			}
		})
		.catch(error => {
			alert('İstek sırasında hata oluştu!\n\n' + error.message);
			
		});


        }else{
            alert("Lütfen geçerli bir miktar giriniz.");
        }
            
        
    }
</script>

</cf_box>