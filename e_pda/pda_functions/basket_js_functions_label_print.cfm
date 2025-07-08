<script type="text/javascript"> 
function clear_barcode()
{
	//gizle(show_buttons);
	document.add_barcode_file.search_product.value="";
	document.add_barcode_file.search_product.focus();	
}
function add_barcode2(no,barcode)
{
	barcode_found = 0;
	var xx = parseInt(document.all.row_count.value);
	if(xx > 0)
	{	
		for(var i=1; i<=xx; i++)
		{
			if(eval('document.all.row_kontrol'+i).value == 1)
			{
				if(barcode == eval('document.all.barcode'+i).value)
				{
					eval('document.add_barcode_file.amount'+i).select();
					barcode_found = 1;
					break;
				}	
			}	
		}	
	}			
	if(barcode_found == 0)
	{
		no++;
		goster(eval('n_my_div' + no));
		eval('document.add_barcode_file.row_kontrol'+no).value = 1;
		eval('document.add_barcode_file.barcode'+no).value = barcode;
		eval('document.add_barcode_file.amount'+no).select();
		document.getElementById('row_count').value = parseInt(document.getElementById('row_count').value) + 1;
	}	
}

function sil(sy)
{
	document.getElementById('n_my_div'+sy).style.display = 'none';
	document.getElementById('row_kontrol'+sy).value = 0;///alanın silindiğini tutuyoruz. toplam hesaplamada ve kayıt ederken kullanılıyor
	//gizle(show_buttons);
	//document.getElementById('n_my_div'+sy).parentNode.removeChild(document.getElementById('n_my_div'+sy));
}
function control_inputs()
{
	if(document.getElementById('row_count').value == 0)
	{
		alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='245.Ürün'>");
		return false;
	}

	var xx = parseInt(document.all.row_count.value);

	var product_exists = 0;
	for(var i=1; i<=xx; i++)
	{
		if(eval('document.all.row_kontrol'+i).value == 1)
		{
			product_exists = product_exists + 1;
		}
	}
	if(product_exists == 0)
	{
		alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='245.Ürün'>");
		return false;
	}
	//document.getElementById('nettotal_usd').value = filterNum(document.getElementById('nettotal_usd').value,2);
	//document.getElementById('basket_net_total_usd').value = filterNum(document.getElementById('basket_net_total_usd').value,2);
	document.add_barcode_file.submit();;
}
</script>
