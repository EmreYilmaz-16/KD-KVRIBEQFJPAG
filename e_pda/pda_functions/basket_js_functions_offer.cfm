<script type="text/javascript">
function get_product_div(search_param)
{
	if(document.add_offer.offer_type_id[add_offer.offer_type_id.selectedIndex].value==0 && document.add_offer.offer_date.value == '')
	{
		alert("Lütfen Listelemek İçin Teklif Tarihini Giriniz!");
		return false;
	}
	else
	{
		goster(product_div);
		AjaxPageLoad(<cfoutput>'#request.self#</cfoutput>?fuseaction=pda.emptypopup_get_product_div&keyword='+encodeURI(document.add_offer.search_product.value)+'&offer_type_id='+document.add_offer.offer_type_id[add_offer.offer_type_id.selectedIndex].value+'&price_date='+encodeURI(document.add_offer.offer_date.value),'product_div');		
		
	}
}
function add_product(no,stock_id,product_id,product,price,other_money,unit,unit_id,tax,manufact_code,product_code_2,property1)
{
	goster(mydiv);
	price_other = price;
	price_kdv  = wrk_round(price * (1+(tax/100)),2);
	var moneyArraylen=moneyArray.length;
	for(var mon_i=0; mon_i<moneyArraylen; mon_i++)
	{
		if(moneyArray[mon_i]==other_money)
		{
			price  = wrk_round(price*rate2Array[mon_i]/rate1Array[mon_i],2); 
			price_kdv  = wrk_round(price_kdv*rate2Array[mon_i]/rate1Array[mon_i],2); 
		}
		if(moneyArray[mon_i]=='USD')
		{
			price_other_usd  = wrk_round((price/rate2Array[mon_i])*rate1Array[mon_i],2); 
		}
	}
	no++;
	var satir ='<div id="n_my_div' + no +'"><input  type="hidden" value="1" name="row_kontrol'+no+'" id="row_kontrol" ><a href="javascript://" onclick="sil('+no+');"><img  src="images/delete_list.gif" border="0"></a><input type="hidden" name="stock_id' + no +'" value="'+stock_id+'"><input type="hidden" name="unit' + no +'" value="'+unit+'"><input type="hidden" name="unit_id' + no +'" value="'+unit_id+'"><input type="hidden" name="tax' + no +'" value="'+tax+'"><input type="hidden" name="product_id' + no +'" value="'+product_id+'"><input type="text" style="width:150px;" name="product_name' + no +'" value="'+product+'"><input style="width:30px;" type="text" name="amount' + no +'" value="1" class="moneybox" onChange="FormatCurrency(this);toplam_hesapla();" onKeyUp="FormatCurrency(this);toplam_hesapla();"><input type="hidden" name="price' + no +'" value="'+commaSplit(price)+'"><input type="hidden" name="price_kdv' + no +'" value="'+commaSplit(price_kdv)+'"><input type="text" name="price_other' + no +'" value="'+commaSplit(price_other)+'" readonly="yes" style="width:50px;"><input type="hidden" name="price_other_usd' + no +'" value="'+commaSplit(price_other_usd)+'"><input type="text" style="width:30px;" readonly="yes"  name="other_money_' + no +'" value="'+other_money+'"><input type="hidden" name="other_money_value_' + no +'" value="'+commaSplit(price_other)+'" style="width:50px;" readonly="yes"><input type="hidden" style="width:50px;" name="row_last_total' + no +'" value="'+commaSplit(price)+'" readonly><input type="hidden" style="width:50px;" name="row_last_total_usd' + no +'" value="'+commaSplit(price_other_usd)+'" readonly><input type="hidden" name="manufact_code' + no +'" value="'+manufact_code+'"><input type="hidden" name="iskonto_tutar' + no +'"><input type="hidden" name="product_code_2_' + no +'" value="'+product_code_2+'"><input type="hidden" name="property1_' + no +'" value="'+property1+'"></div>';
	document.getElementById('mydiv').innerHTML = document.getElementById('mydiv').innerHTML+satir;
	document.getElementById('row_count').value = parseInt(document.getElementById('row_count').value) + 1;
	change_offer_type_head();
	goster(show_buttons);
}
function change_offer_type_head()
{
	if(document.add_offer.offer_type_id[add_offer.offer_type_id.selectedIndex].value==0)	
	{
		document.getElementById('offer_type_head1').innerHTML = 'Abonelik Bedeli';
		document.getElementById('offer_type_head2').innerHTML = 'İndirimli Abonelik Bedeli';
	}
	else if(document.add_offer.offer_type_id[add_offer.offer_type_id.selectedIndex].value==1)	
	{
		document.getElementById('offer_type_head1').innerHTML = 'Satış Bedeli';
		document.getElementById('offer_type_head2').innerHTML = 'İndirimli Satış Bedeli';
	}
}

function toplam_hesapla()
{
	var paper_total = 0;
	var paper_total_kdv = 0;
	var paper_total_w_sa_disc = 0;
	var paper_total_kdv_w_sa_disc = 0;
	var sa_discount = 0;

	var paper_total_usd = 0;
	var row_last_total_usd = 0;
	var paper_total_usd_w_sa_disc = 0;
	var xx = parseInt(document.all.row_count.value);
	for(var i=1; i<=xx; i++)
	{
		if(eval('document.all.row_kontrol'+i).value == 1 && eval('document.all.product_id'+i).value != 855)
		{			
			if(eval('document.all.price'+i).value == '')eval('document.all.price'+i).value = 0;
			if(eval('document.all.price_kdv'+i).value == '')eval('document.all.price_kdv'+i).value = 0;
			if(eval('document.all.amount'+i).value == '')eval('document.all.amount'+i).value = 1;
			eval('document.all.row_last_total'+i).value = commaSplit(filterNum(eval('document.all.price'+i).value,2)*filterNum(eval('document.all.amount'+i).value),2);
			eval('document.all.other_money_value_'+i).value = commaSplit(filterNum(eval('document.all.price_other'+i).value,2)*filterNum(eval('document.all.amount'+i).value),2);
			paper_total = paper_total + filterNum(eval('document.all.row_last_total'+i).value,2);
			paper_total_kdv = paper_total_kdv + (filterNum(eval('document.all.price_kdv'+i).value,2)*filterNum(eval('document.all.amount'+i).value));
			eval('document.all.row_last_total_usd'+i).value = commaSplit(filterNum(eval('document.all.price_other_usd'+i).value,2)*filterNum(eval('document.all.amount'+i).value),2);
			paper_total_usd = paper_total_usd + filterNum(eval('document.all.row_last_total_usd'+i).value,2);
		}
	}
	//fatura altı indirim varsa
	if(document.getElementById('sa_discount').value != 0 && document.getElementById('sa_discount').value != '')
	{
		sa_discount = filterNum(document.getElementById('sa_discount').value,2);
		if(sa_discount <= paper_total)
		{
			for(var i=1; i<=xx; i++)
			{
				//fatura altı indirim Montaj ürününe etki etmez
				if(eval('document.all.row_kontrol'+i).value == 1 && eval('document.all.product_id'+i).value != 855)
				{	
					row_last_total = filterNum(eval('document.all.row_last_total'+i).value,2);
					row_last_total_w_sa_disc = wrk_round(row_last_total - ((row_last_total*sa_discount)/paper_total),2);
					paper_total_w_sa_disc = wrk_round(paper_total_w_sa_disc + row_last_total_w_sa_disc,2);
					paper_total_kdv_w_sa_disc = wrk_round(paper_total_kdv_w_sa_disc + (row_last_total_w_sa_disc * (1 + (eval('document.all.tax'+i).value/100))),2);
				}
			}
			paper_total = paper_total_w_sa_disc;
			paper_total_kdv = paper_total_kdv_w_sa_disc;
		}
		else
		{
			alert('Fatura altı indirim Toplamdan büyük olamaz!');
			document.getElementById('sa_discount').value = commaSplit(0);
		}
	}
	//Montaj ürünü Toplama en son eklenir
	for(var i=1; i<=xx; i++)
	{
		if(eval('document.all.row_kontrol'+i).value == 1 && eval('document.all.product_id'+i).value == 855)
		{	
			//Montaj mutlaka 1 adet olmalı
			eval('document.all.amount'+i).value	= 1;

			var moneyArraylen=moneyArray.length;

			//Yeni ürün eklenince Montaj bedeli yeniden hesaplanır
			montage_price = calc_montage_price();
			document.all.montage_price.value = commaSplit(montage_price,2);
			for(var mon_i=0; mon_i<moneyArraylen; mon_i++)
			if(moneyArray[mon_i]=='USD')
			{
				montage_price = wrk_round(montage_price*rate2Array[mon_i]/rate1Array[mon_i],2);
			}
			eval('document.all.price'+i).value = commaSplit(montage_price,2);
			//Montaj satır toplamı düzgün gösterilir
			eval('document.all.row_last_total'+i).value  = commaSplit(montage_price,2);
			montage_discount = filterNum(document.getElementById('montage_discount').value,2);
			if(isNaN(montage_discount)) {montage_discount = 0; document.getElementById('montage_discount').value= 0;}
			document.all.montage_discount.value = commaSplit(montage_discount,2);
			document.all.montage_price_w_discount.value = commaSplit(filterNum(document.all.montage_price.value,2)-montage_discount,2);
			//Satırlardaki montaj ürünü için price_other düzeltilir
			eval('document.all.price_other'+i).value = document.all.montage_price.value
			//Satırlardaki other_money_value düzeltilir
			eval('document.all.other_money_value_'+i).value = document.all.montage_price_w_discount.value;

			//Montaj indirimi YTL olarak hesaplanıyor
			for(var mon_i=0; mon_i<moneyArraylen; mon_i++)
				if(moneyArray[mon_i]=='USD')
				{
					montage_discount = filterNum(document.getElementById('montage_discount').value,2);
					if(isNaN(montage_discount)) {montage_discount = 0; document.getElementById('montage_discount').value= 0;}
					//Montaj indirim db ye kayıt ederken kullanılacak alana aktarılıyor
					eval('document.all.iskonto_tutar'+i).value = wrk_round(montage_discount,2);					
					montage_discount  = wrk_round(montage_discount*rate2Array[mon_i]/rate1Array[mon_i],2); 
				}
			//Montaj indirimi montaj bedelinden çıkarılarak Teklif toplam bedeli hesaplanıyor
			if(montage_discount <= filterNum(eval('document.all.row_last_total'+i).value),2)	
			{
				row_last_total = wrk_round(filterNum(eval('document.all.row_last_total'+i).value,2) - montage_discount,2);
				paper_total = wrk_round(paper_total + row_last_total,2);
				paper_total_kdv = wrk_round(paper_total_kdv + (row_last_total * (1 + (eval('document.all.tax'+i).value/100))),2);						
			}						
			else
			{
				alert('Montaj indirim montaj tutarından büyük olamaz!');
				document.getElementById('montage_discount').value = 0;
			}
		}
	}

	document.getElementById('nettotal').value = commaSplit(paper_total,2);
	document.getElementById('basket_net_total').value = commaSplit(paper_total_kdv,2);

	document.getElementById('nettotal_usd').value = commaSplit(paper_total_usd,2);
	document.getElementById('basket_net_total_usd').value = commaSplit(paper_total_usd - sa_discount,2);
}
function sil(sy)
{
	document.getElementById('n_my_div'+sy).style.display = 'none';
	document.getElementById('row_kontrol'+sy).value = 0;///alanın silindiğini tutuyoruz. toplam hesaplamada ve kayıt ederken kullanılıyor
	toplam_hesapla();
	if(eval('document.all.product_id'+sy).value == 855)
		gizle(montage_discount_div);
}
function control_inputs()
{
	if(document.getElementById('member_id').value == '')
	{
		alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='246.Üye'>");
		return false;
	}
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

	var product_exists_montage = 0;
	for(var i=1; i<=xx; i++)
	{
		if(eval('document.all.row_kontrol'+i).value == 1)
		{
			if(eval('document.all.product_id'+i).value == 855)
				product_exists_montage = 1;
		}
	}
	if(product_exists_montage == 0)
	{		
		if(add_montage_product(xx) == true)
		{
			toplam_hesapla();	
			alert("Montaj Bedel Ürünü eklenmiştir! Kontrol edip tekrar Kaydet/Güncelle düğmesine basınız!");
			return false;
		}
		else
			return false;
	}

	/*
	if(document.getElementById('process_type_info').value == '')
	{
		alert("Lütfen İşlem Seçiniz");
		return false;
	}
	else
	{
		if(document.getElementById('process_type') != undefined && document.getElementById('process_type').value == '')
		{
			alert('Lütfen İşlem Kategorilerinizi Tanımlayınız!');
			return false;
		}
		if(document.getElementById('process_stage') != undefined && document.getElementById('process_stage').value == '')
		{
			alert('Lütfen Süreçlerinizi Tanımlayınız!');
			return false;
		}
	}
	*/
	
	for(i=1;i<=parseInt(document.all.row_count.value);i++)
	{
		eval("document.all.price"+i).value = filterNum(eval("document.all.price"+i).value,2);
		eval("document.all.price_kdv"+i).value = filterNum(eval("document.all.price_kdv"+i).value,2);
		eval("document.all.row_last_total"+i).value = filterNum(eval("document.all.row_last_total"+i).value,2);
		eval("document.all.row_last_total_usd"+i).value = filterNum(eval("document.all.row_last_total_usd"+i).value,2);
		eval("document.all.price_other"+i).value = filterNum(eval("document.all.price_other"+i).value,2);
		eval("document.all.price_other_usd"+i).value = filterNum(eval("document.all.price_other_usd"+i).value,2);
		eval("document.all.other_money_value_"+i).value = filterNum(eval("document.all.other_money_value_"+i).value,2);
		eval("document.all.amount"+i).value = filterNum(eval("document.all.amount"+i).value,2);
	}
	document.all.nettotal.value = filterNum(document.all.nettotal.value,2);
	document.getElementById('basket_net_total').value = filterNum(document.getElementById('basket_net_total').value,2);

	document.all.sa_discount.value = filterNum(document.all.sa_discount.value,2);

	document.all.montage_price.value = filterNum(document.all.montage_price.value,2);
	document.all.montage_discount.value = filterNum(document.all.montage_discount.value,2);
	
	document.getElementById('nettotal_usd').value = filterNum(document.getElementById('nettotal_usd').value,2);
	document.getElementById('basket_net_total_usd').value = filterNum(document.getElementById('basket_net_total_usd').value,2);
	return true;
}
function add_montage_product(no)
{
	montage_price = calc_montage_price();
	//add_product(no,stock_id,product_id,product,price,other_money,unit,unit_id,tax);
	if(montage_price > 0)	
	{
		add_product(no,855,855,'Alarm Sistemi Montaj Bedeli',montage_price,'USD','Adet',856,18); 
		document.all.montage_price.value = commaSplit(montage_price,2);
		document.all.montage_discount.value = commaSplit(0,2);
		document.all.montage_price_w_discount.value = commaSplit(montage_price,2);
		goster(montage_discount_div);
	}
	else
	{
		alert('Lütfen paket içeriğinin tam olarak eklendiğinden emin olup yeniden kaydetmeyi deneyiniz!');
		return false;
	}
}
function calc_montage_price()
{
	var xx = parseInt(document.all.row_count.value);
	var montage_total = 0;

	//SIRA NUMARASINI GÖRMEK İÇİN ALTTAKİ SATIR KALSIN * buradakiler liste numarası, Array numarası her birinin 1 eksiği olacak
	//var montage_type_array = "Akü@1,Alarm Paneli@2,Dahili Siren@3,Harici Siren@4,Şifre Paneli@5,Trafo@6,Dedektör@7,Ek Bölge Kartı@8,Ek Modül@9,Kablosuz ilave modül@10,Kır-Bas Butonu@11,Kumanda@12,Panik Butonu@13,Receiver@14,Boş harici Siren@15";	

	montage_type_list = "Akü,Alarm Paneli,Dahili Siren,Harici Siren,Şifre Paneli,Trafo,Dedektör,Ek Bölge Kartı,Ek Modül,Kablosuz ilave modül,Kır-Bas Butonu,Kumanda,Panik Butonu,Receiver,Boş harici Siren";	
	montage_type_array = new Array();
	montage_type_array = "Akü,Alarm Paneli,Dahili Siren,Harici Siren,Şifre Paneli,Trafo,Dedektör,Ek Bölge Kartı,Ek Modül,Kablosuz ilave modül,Kır-Bas Butonu,Kumanda,Panik Butonu,Receiver,Boş harici Siren";	

	var montage_type_array=montage_type_array.split(',');
	for (var i=0; i<montage_type_array.length; i++)
	{
		montage_type_array[i]=new Array();
		montage_type_array[i][0]=0;// 0 kablolu miktarı(K)  
		montage_type_array[i][1]=0;// 1 kablosuz miktarı (W)
		montage_type_array[i][2]=0;// K ve W tanımlı değilse, boş ise yani
	}
	for(var i=1; i<=xx; i++)
	{
		if(eval('document.all.row_kontrol'+i).value == 1 && eval('document.all.product_id'+i).value != 855)
		{			
			var montage_list_item_no = list_find(montage_type_list,eval('document.all.product_code_2_'+i).value,',');
			//alert(montage_list_item_no);
			//Eklenen ürün bizimkilerden biri ise ve ücretsizlerden biri değilse kablolu kablosuz miktarları belirlenir
			if(montage_list_item_no > 0 && list_find('10,12,15',montage_list_item_no) == 0)
			{
				if(eval('document.all.property1_'+i).value  == 'K')
					montage_type_array[montage_list_item_no-1][0] = montage_type_array[montage_list_item_no-1][0] + filterNum(eval('document.all.amount'+i).value);
				else if(eval('document.all.property1_'+i).value  == 'W')
					montage_type_array[montage_list_item_no-1][1] = montage_type_array[montage_list_item_no-1][1] + filterNum(eval('document.all.amount'+i).value);
				else if(eval('document.all.property1_'+i).value  == '')
					montage_type_array[montage_list_item_no-1][2] = montage_type_array[montage_list_item_no-1][2] + filterNum(eval('document.all.amount'+i).value);
			}			
		}		
	}
	//TEMEL PAKET KABLOLU VE HER BİRİNDEN BELLİ MİKTARDA OLMALI, BUNA GÖRE EK MODÜL ÜCRETLERİ İLE TOPLAM BEDEL BULUNUR
	var montage_multiplier_K_10 = 0;//sepetteki toplam kablolu sayısı
	var montage_multiplier_W_5 = 0;//sepetteki toplam kablosuz sayısı
	//Temel paket içeriği kontrol ediliyor
	/*
	if
	(	
		((montage_type_array[0][0]+montage_type_array[0][1]+montage_type_array[0][2]) >= 1) && 
		((montage_type_array[1][0]+montage_type_array[1][1]+montage_type_array[1][2]) >= 1) && 
		((montage_type_array[2][0]+montage_type_array[2][1]+montage_type_array[2][2]) >= 1) && 
		((montage_type_array[3][0]+montage_type_array[3][1]+montage_type_array[3][2]) >= 1) && 
		((montage_type_array[4][0]+montage_type_array[4][1]+montage_type_array[4][2]) >= 1) && 
		((montage_type_array[5][0]+montage_type_array[5][1]+montage_type_array[5][2]) >= 1) && 
		((montage_type_array[6][0]+montage_type_array[6][1]+montage_type_array[6][2]) >= 2)
	)	
	{
	*/
		montage_total = 85;		
		for (var i=0; i<montage_type_array.length; i++)
		{
			if(i != 6) main_pack_amount = 1; else main_pack_amount = 2; //temel pakettekileri kablolulardan çıkarıyoruz
			if(montage_type_array[i][0] > 0) 
				montage_multiplier_K_10 = montage_multiplier_K_10 + (montage_type_array[i][0] - main_pack_amount); //temel pakettekileri kablolulardan çıkarıyoruz;			
			if(montage_type_array[i][1] > 0)
			{
				montage_multiplier_W_5 = montage_multiplier_W_5 + montage_type_array[i][1];
				if(montage_type_array[i][0] = 0) //temel pakettekileri kablolulardan çıkarıyoruz ama kablolu yoksa kablosuzdan çıkarıyoruz;	
					montage_multiplier_W_5 = montage_multiplier_W_5 - main_pack_amount;
			}
		}
		montage_total = montage_total + ((montage_multiplier_K_10 * 10) + (montage_multiplier_W_5 * 5));
		//Sıva Altı Kablolama yapılacak Uç Birim Sayısı 
		var montage_end_unit_no = parseInt(document.all.montage_end_unit_no.value); if(isNaN(montage_end_unit_no)) montage_end_unit_no=0;
		if(montage_end_unit_no > 0)
			montage_total = montage_total + (montage_end_unit_no * 10);
		//Kablolama müşteri tarafından mı yapılacak 
		var montage_cable_by_client = document.all.montage_cable_by_client[document.all.montage_cable_by_client.selectedIndex].value;
		if(montage_cable_by_client == 1)
		{
			montage_total = montage_total + 50;
		}
	/*
	}
	else
	{
		alert('Temel paket içeriği tamamlanmadığı için montaj bedeli hesaplanamadı!');
		montage_total = 0;
	}
	*/
	//alert(montage_type_array);
	montage_price = montage_total;
	return montage_price;
}

function kontrol_prerecord()
{
	goster(kontrol_prerecord_div);
	AjaxPageLoad(<cfoutput>'#request.self#</cfoutput>?fuseaction=pda.emptypopup_get_company_div&field_id=add_offer.ref_company_id&field_name=add_offer.ref_member_name&field_type=add_offer.ref_member_type&field_partner_id=add_offer.ref_partner_id&ref_member_name='+ encodeURI(add_offer.ref_member_name.value) +'&div_name='+'kontrol_prerecord_div' +'&form_id=' + 'add_offer','kontrol_prerecord_div');		
	return false;
}

function sil_bastan()
{
	gizle(product_div);
	gizle(mydiv);
	gizle(montage_discount_div);
	gizle(show_buttons);	
	document.all.montage_price.value = commaSplit(0,2);
	document.all.montage_discount.value = commaSplit(0,2);
	document.all.nettotal.value = commaSplit(0,2);
	document.all.basket_net_total.value = commaSplit(0,2);
	document.all.sa_discount.value = commaSplit(0,2);
	var xx = parseInt(document.all.row_count.value);
	for(var i=1; i<=xx; i++)
	{
		document.getElementById('n_my_div'+i).style.display = 'none';
		document.getElementById('row_kontrol'+i).value = 0;
	}
}
</script>
