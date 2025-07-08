<script language="javascript" type="text/javascript">
	/*Ortak Kullanilan Fonksiyonlar*/
	function get_location_all_div(div_name,form_name,branch_id,department_id,location_id,department_location)
	{
		goster(document.getElementById(div_name));
		keyword = encodeURI(document.getElementById(department_location).value);
		AjaxPageLoad(<cfoutput>'#request.self#</cfoutput>?fuseaction=pda.emptypopup_location_div_purchase&div_name='+div_name+'&form_name='+form_name+'&location_id='+location_id+'&department_id='+department_id+'&department_location='+department_location+'&keyword='+keyword,div_name);
		return false;
	}
	
	function get_company_all_div(div_name)
	{
		if(div_name == "") div_name = "company_all_div"; // Bu Sekilde Kullanildigi Yerler Var Hepsi Duzenlendiginde Kullanilmiyorsa Kaldirilacak
		if(document.getElementById("comp_name").value.length <= 2)
		{
			alert("Lütfen Listelemek İçin En Az 3 Karakter Giriniz !");
			return false;
		}
		goster(document.getElementById(div_name));
		AjaxPageLoad(<cfoutput>'#request.self#</cfoutput>?fuseaction=pda.get_comp_prtotm&ref_member_name='+ encodeURI(document.getElementById("comp_name").value) +'&div_name='+div_name+'&form_id=add_purchase',div_name);		
		return false;
	}
	
	function add_company_div(div_name,company_id,comp_name,partner_name,partner_id,member_type)
	{
		document.getElementById("company_id").value = company_id;
		document.getElementById("comp_name").value = comp_name;
		document.getElementById("partner_id").value = partner_id;
		document.getElementById("partner_name").value = partner_name;
		document.getElementById("member_type").value = member_type;
		gizle(document.getElementById(div_name));
	}
	
	function get_order_div(div_name,div_row_name,purchase_sales,member_required)
	{
		if(member_required == 1 && ((document.getElementById("company_id").value == "" && document.getElementById("consumer_id").value == "") || document.getElementById("comp_name").value == ""))
		{
			alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='107.Cari Hesap'>");
			return false;
		}
		else
		{
			goster(document.getElementById(div_name));
			goster(document.getElementById(div_row_name));
			AjaxPageLoad(<cfoutput>'#request.self#</cfoutput>?fuseaction=pda.emptypopup_list_orders_for_ship_div&div_name='+div_name+'&purchase_sales='+purchase_sales+'&company_id='+document.getElementById('company_id').value,div_row_name);
			return false;
		}
	}
	
	function add_barcode_all(no,barcode)
	{
		//Burada Calisma Yapilacak, Su anda 200 luk Loop Donuyor, Add_Row da pdada calismiyor
	}
	
	function clear_barcode()
	{
		document.getElementById("search_product").value = "";
		document.getElementById("search_product").focus();	
	}
	
	function add_order_amount(barcode)
	{
		//var new_sql = "SELECT DISTINCT BARCODE FROM STOCKS_BARCODES WHERE STOCK_ID = (SELECT DISTINCT SB.STOCK_ID FROM STOCKS AS S,PRODUCT_UNIT AS PU,STOCKS_BARCODES SB WHERE SB.STOCK_ID = S.STOCK_ID AND S.PRODUCT_STATUS = 1 AND S.STOCK_STATUS = 1 AND S.PRODUCT_ID = PU.PRODUCT_ID AND SB.BARCODE = '" + barcode + "')";
		//var GET_BARCODE = wrk_query(new_sql,'dsn3');
		//alert(GET_BARCODE.BARCODE);
		var order_diff_ = 0;
		var xx = parseInt(document.all.row_count.value);
		for(var i=1; i<=xx; i++)
		{	
			if(eval('document.all.row_kontrol'+i).value == 1)
			{	
				if(barcode == document.getElementById("barcode"+i).value)
				{
					var order_diff_ = order_diff_ + (parseFloat(filterNum(document.getElementById("amount"+i).value,4)) - parseFloat(filterNum(document.getElementById("amount_diff"+i).value,4)));
				}
			}
		}
		if(order_diff_ > 0)
			document.getElementById('search_amount').value = commaSplit(order_diff_,4);
		else
			document.getElementById('search_amount').value = commaSplit(0,4);
		document.getElementById('search_amount').select();
	}
	
	function add_barcode2(no,barcode,type)
	{
		if(type == undefined) type = 1;
		if(type == 0)
		{
			<cfif fuseaction is 'pda.form_add_ship_dispatch'>
				document.getElementById("search_product").select();
			<cfelse>
				document.getElementById("search_lot_no").select();
			</cfif>		
		}
		else
		{
			barcode_found = 0;
			var xx = document.getElementById("row_count").value;
			if(xx > 0)
			{	
				for(var i=1; i<=xx; i++)
				{      
					if(eval('document.getElementById("row_kontrol'+i+'")').value ==1)
					{
						<cfif fuseaction is 'pda.form_add_ship_dispatch'>
							if(barcode == eval('document.getElementById("barcode'+i+'")').value && document.getElementById("search_lot_no").value == eval('document.getElementById("lot_no'+i+'")').value)
							{
								eval('document.getElementById("amount'+i+'")').value = commaSplit(parseFloat(filterNum(eval('document.getElementById("amount'+i+'")').value,4)) + parseFloat(filterNum(document.getElementById("search_amount").value,4)),4);
								document.getElementById('search_product').select();
								barcode_found = 1;
								break;
							}	
						<cfelse>
							if(barcode == eval('document.getElementById("barcode'+i+'")').value)
							{
								<cfif fuseaction is 'pda.form_add_stock_count_file'>
									eval('document.getElementById("amount'+i+'")').value ++;
								</cfif>
								eval('document.getElementById("amount'+i+'")').select();
								if(type != 2) // ayni stoga ait satirlarda sorun oluyordu, bunlari da siparis iliskilerini tutmasi icin ayri eklemeli
									barcode_found = 1;
								break;
							}
						</cfif>
					}	
				}
			}	
			if(barcode_found == 0)
			{
				var new_sql = "SELECT DISTINCT BARCODE FROM STOCKS_BARCODES WHERE STOCK_ID = (SELECT DISTINCT SB.STOCK_ID FROM STOCKS AS S,PRODUCT_UNIT AS PU,STOCKS_BARCODES SB WHERE SB.STOCK_ID = S.STOCK_ID AND S.PRODUCT_STATUS = 1 AND S.STOCK_STATUS = 1 AND S.PRODUCT_ID = PU.PRODUCT_ID AND SB.BARCODE = '" + barcode + "')";
				var get_barcode = wrk_query(new_sql,'dsn3');
				if(get_barcode.recordcount > 0)
				{
					no++;
					if(document.getElementById("ship_info") != undefined && document.getElementById("ship_info").style.display == 'none')
						goster(ship_info);
					if(document.getElementById("order_info") != undefined && document.getElementById("order_info").style.display == 'none') //Burasi Alis ve Satis Adina Kullaniliyor
						goster(order_info);
					goster(document.getElementById("n_my_div" + no));
	
					eval('document.getElementById("row_kontrol'+no+'")').value = 1;
					eval('document.getElementById("barcode'+no+'")').value = barcode;
					<cfif fuseaction is 'pda.form_add_ship_dispatch'>
						eval('document.getElementById("amount'+no+'")').value = document.getElementById("search_amount").value;
						eval('document.getElementById("lot_no'+no+'")').value = document.getElementById("search_lot_no").value;
					</cfif>
					var get_product_name = wrk_query("SELECT TOP 1 S.PRODUCT_NAME FROM STOCKS S, STOCKS_BARCODES SB WHERE S.STOCK_ID = SB.STOCK_ID AND SB.BARCODE ='"+barcode+"'","dsn3",1);
					if(get_product_name.recordcount > 0)
						document.getElementById("product_name"+no).value = get_product_name.PRODUCT_NAME;	
				}
				else
				{
					alert("Barkod Bulunamadı !");
					clear_barcode();
					return false;
				}
				document.getElementById('row_count').value = parseInt(document.getElementById('row_count').value) + 1;
			}
			<cfif fuseaction is 'pda.form_add_ship_dispatch' or fuseaction is 'pda.form_add_stock_count_file'>
				document.getElementById("search_product").select();
			<cfelse>
				document.getElementById("amount"+no).select();
			</cfif>
		}
	}
	
	function add_barcode3(no,barcode,type)
	{
		barcode_found = 0;
		var jj = parseInt(document.getElementById("row_count").value);
		var xx = parseInt(document.getElementById("ship_row_count").value);
		if(xx > 0)
		{	
			for(var i=1; i<=xx; i++)
			{
				if(eval('document.getElementById("ship_row_kontrol'+i+'")').value == 1)
				{   
					if(barcode ==eval('document.getElementById("ship_barcode'+i+'")').value && document.getElementById("search_lot_no").value == eval('document.getElementById("ship_lot_no'+i+'")').value)   
					{                                                                                 
						eval('document.getElementById("ship_amount'+i+'")').value = commaSplit(parseFloat(filterNum(eval('document.getElementById("ship_amount'+i+'")').value,4)) + parseFloat(filterNum(document.getElementById("search_amount").value,4)),4);
						document.getElementById('search_product').select();
						barcode_found = 1;
						break;
					}	
				}	
			}
		}		
		if(barcode_found == 0)
		{
			var new_sql = "SELECT DISTINCT BARCODE FROM STOCKS_BARCODES WHERE STOCK_ID = (SELECT DISTINCT SB.STOCK_ID FROM STOCKS AS S,PRODUCT_UNIT AS PU,STOCKS_BARCODES SB WHERE SB.STOCK_ID = S.STOCK_ID AND S.PRODUCT_STATUS = 1 AND S.STOCK_STATUS = 1 AND S.PRODUCT_ID = PU.PRODUCT_ID AND SB.BARCODE = '" + barcode + "')";
			var get_barcode = wrk_query(new_sql,'dsn3');
			//alert(GET_BARCODE.BARCODE);
			if(get_barcode.recordcount > 0)
			{
				no++;
				if(parseFloat(filterNum(document.getElementById("search_amount").value,4)) > 0)
				{
					//Irsaliye Bilgileri Tr si Bir Kez Acildiginda Daha Acilmaya Calismasin
					if(document.getElementById("ship_info") != undefined && document.getElementById("ship_info").style.display == 'none') goster(ship_info);
					goster(eval('document.getElementById("n_div_lot_control'+no+'")'));
					eval('document.getElementById("ship_row_kontrol'+no+'")').value = 1;   
					eval('document.getElementById("ship_barcode'+no+'")').value = barcode;   
					eval('document.getElementById("ship_lot_no'+no+'")').value = document.getElementById("search_lot_no").value;
					eval('document.getElementById("ship_amount'+no+'")').value = commaSplit(parseFloat(filterNum(document.getElementById("search_amount").value,4)),4);
					
					var get_product_name = wrk_query("SELECT TOP 1 S.PRODUCT_NAME FROM STOCKS S, STOCKS_BARCODES SB WHERE S.STOCK_ID = SB.STOCK_ID AND SB.BARCODE ='"+barcode+"'","dsn3",1);
					if(get_product_name.recordcount > 0)
						document.getElementById("ship_product_name"+no).value = get_product_name.PRODUCT_NAME;
				}
				else
				{
					alert(" Miktar 0 Dan Farklı Olmalıdır!");
					return false;
				}
			}
			else
			{
				alert("Barkod Bulunamadı !");
				clear_barcode();
				return false;
			}
			document.getElementById('search_product').select();
			document.getElementById('ship_row_count').value = parseFloat(document.getElementById('ship_row_count').value) + 1;
		}
		if(jj > 0)
		{	
			var used_ = 0;
			for(var j=1; j<=jj; j++)     eval('document.getElementById("amount_diff'+j+'")') 
			{
				//Burasi Biraz Karisik ; Ayni Urune Ait Birden Fazla Satir Varsa, Girilen Miktarda Ilk Secilene Tam Digerlerine Fazlasi Atilir
				if(eval('document.getElementById("row_kontrol'+j+'")').value == 1)
				{
					if(barcode == eval('document.getElementById("barcode'+j+'")').value && eval('document.getElementById("barcode'+parseInt(j+1)+'")') != undefined && barcode == eval('document.getElementById("barcode'+parseInt(j+1)+'")').value)
					{
						eval('document.getElementById("amount_diff'+j+'")').value = commaSplit(parseFloat(filterNum(eval('document.getElementById("amount'+j+'")').value,4)),4);
						used_ = eval('document.getElementById("amount_diff'+j+'")').value;
					}
					else if(barcode == eval('document.getElementById("barcode'+j+'")').value)
					{
						if(parseFloat(filterNum(eval('document.getElementById("amount_diff'+j+'")').value,4)) == 0)
							eval('document.getElementById("amount_diff'+j+'")').value = commaSplit(parseFloat(filterNum(eval('document.getElementById("amount_diff'+j+'")').value,4)) + parseFloat(filterNum(document.getElementById("search_amount").value,4)) - parseFloat(filterNum(used_,4)),4);
						else
							eval('document.getElementById("amount_diff'+j+'")').value = commaSplit(parseFloat(filterNum(eval('document.getElementById("amount_diff'+j+'")').value,4)) + parseFloat(filterNum(document.getElementById("search_amount").value,4)),4);
					}
				}
			}
		}
	}
	
	function sil(sy)
	{
		document.getElementById('n_my_div'+sy).style.display = 'none';
		document.getElementById('row_kontrol'+sy).value = 0;///alanın silindiğini tutuyoruz. toplam hesaplamada ve kayıt ederken kullanılıyor
	}
	function sil_lot(sy)
	{
		document.getElementById('n_div_lot_control'+sy).style.display = 'none';
		document.getElementById('ship_row_kontrol'+sy).value = 0;///alanın silindiğini tutuyoruz. toplam hesaplamada ve kayıt ederken kullanılıyor
		var jj = parseInt(document.getElementById("row_count").value);
		if(jj > 0)
		{	
			for(var j=1; j<=jj; j++)
			{
				if(document.getElementById("row_kontrol"+j).value ==1)
					if(document.getElementById("ship_barcode"+sy).value == document.getElementById("barcode"+j).value)
						document.getElementById("amount_diff"+j).value = commaSplit(parseFloat(filterNum(document.getElementById("amount_diff"+j).value,4)) - parseFloat(filterNum(document.getElementById("ship_amount"+sy).value,4)),4);
			}
		}
	}
	/* //Ortak Kullanilan Fonksiyonlar*/
	
	<cfif fuseaction is 'pda.form_add_purchase' or fuseaction is 'pda.form_add_purchase_control'>
		//basket_js_functions_purchase
		document.getElementById('comp_name').select(); 
		
		function add_order(id,name,due_day,paymethod_vehicle)
		{ 
			document.add_purchase.order_id.value=id;
			document.add_purchase.paymethod.value=name;
			document.add_purchase.basket_due_value.value = due_day;
			document.add_purchase.paymethod_vehicle.value = paymethod_vehicle;
			gizle(order_div);
		}
			
		function control_inputs()
		{
			if(document.getElementById('ship_number').value == '')
			{
				alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='726.İrsaliye No'>");
				return false;
			}
			if(document.getElementById("process_cat") != undefined && document.getElementById("process_cat").value == "")
			{
				alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='388.İşlem Tipi'>");
				return false;
			}
			if(document.getElementById('department_location').value == '' || document.getElementById('department_id').value == '')
			{
				alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='1351.Depo'>");
				return false;
			}
			if(document.getElementById('company_id').value == '')
			{
				alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='107.Cari Hesap'>");
				return false;
			}
			if(document.getElementById('ship_row_count').value == 0)
			{
				alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='245.Ürün'>");
				return false;
			}
		
			var cnt_ = 0;
			var product_exists = 0;
			var diff_amount_barcod_list = "";
			var xx = parseInt(document.all.row_count.value);
			var yy = parseInt(document.all.ship_row_count.value);
			
			for(var i=1; i<=xx; i++)
			{
				if(eval('document.all.row_kontrol'+i).value == 1)
				{
					
					if(parseFloat(filterNum(document.getElementById('amount'+i).value,4)) != parseFloat(filterNum(document.getElementById('amount_diff'+i).value,4)))
						diff_amount_barcod_list = diff_amount_barcod_list + "("+ document.getElementById('barcode'+i).value + ") "+ document.getElementById('product_name'+i).value + "\n";
				}
			}
			for(var i=1; i<=yy; i++)
			{
				if(eval('document.all.ship_row_kontrol'+i).value == 1)
				{
					cnt_ ++;
					product_exists = product_exists + 1;
					if(document.getElementById('ship_amount'+i) != undefined && parseFloat(filterNum(document.getElementById('ship_amount'+i).value,4)) <= 0)
					{
						alert(cnt_ + ". Satırda Girilen Miktar 0 Dan Farklı Olmalıdır!");
						return false;
					}
				}
			}
			
			if(product_exists == 0)
			{
				alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='245.Ürün'>");
				return false;
			}
			if(document.getElementById("order_id_listesi") != undefined && document.getElementById("order_id_listesi").value != "" && diff_amount_barcod_list != "")
			{
				if(confirm("Aşağıda Belirtilen Barkodlardaki Sipariş Miktarı ile İşlenen Miktarlar Eşit Değildir! \n"+diff_amount_barcod_list+"\nDevam Etmek İstiyor Musunuz?"))
				{	
					for(var i=1; i<=yy; i++)
					{
						document.getElementById('ship_amount'+i).value = filterNum(document.getElementById('ship_amount'+i).value,4);
					}
					document.getElementById("add_purchase").submit();
				}
				else
					return false;
			}
			else
			{
				for(var i=1; i<=yy; i++)
				{
					document.getElementById('ship_amount'+i).value = filterNum(document.getElementById('ship_amount'+i).value,4);
				}
				document.getElementById("add_purchase").submit();
			}
		}
		function kontrol_prerecord()
		{
			goster(kontrol_prerecord_div);
			AjaxPageLoad(<cfoutput>'#request.self#</cfoutput>?fuseaction=pda.emptypopup_get_company_div&field_id=add_purchase.ref_company_id&field_name=add_purchase.ref_member_name&field_type=add_purchase.ref_member_type&field_partner_id=add_purchase.ref_partner_id&ref_member_name='+ encodeURI(add_purchase.ref_member_name.value) +'&div_name='+'kontrol_prerecord_div' +'&form_id=' + 'add_purchase','kontrol_prerecord_div');		
			return false;
		}
		
		function sil_bastan()
		{
			gizle(show_buttons);	
			document.all.nettotal.value = 0;
			document.all.basket_net_total.value = 0;
			document.all.sa_discount.value = 0;
			document.all.nettotal_usd.value = 0;
			document.all.basket_net_total_usd.value = 0;
		}
	
	</cfif>
	<cfif 'pda.form_add_ship_dispatch' is fuseaction>
		//basket_js_functions_ship_dispatch
		function control_inputs()
		{
			if(document.getElementById("process_cat") != undefined && document.getElementById("process_cat").value == "")
			{
				alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='388.İşlem Tipi'>");
				return false;
			}
			if(document.getElementById('department_location').value == '' || document.getElementById('department_id').value == '')
			{
				alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='1631.Çıkış Depo'>");
				return false;
			}
			if(document.getElementById('department_location_in').value == '' || document.getElementById('department_id_in').value == '')
			{
				alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='142.Giriş'> <cf_get_lang_main no='1351.Depo'>");
				return false;
			}
			if(document.getElementById('row_count').value == 0)
			{
				alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='245.Ürün'>");
				return false;
			}
		
			var xx = parseInt(document.all.row_count.value);
			var cnt_ = 0;
			var product_exists = 0;
			for(var i=1; i<=xx; i++)
			{
				if(eval('document.all.row_kontrol'+i).value == 1)
				{
					cnt_++;
					product_exists = product_exists + 1;
					if(document.getElementById('amount'+i) != undefined && parseFloat(filterNum(document.getElementById('amount'+i).value,4)) <= 0)
					{
						alert(cnt_ + ". Satırda Girilen Miktar 0 Dan Farklı Olmalıdır!");
						return false;
					}
				}
			}
			if(product_exists == 0)
			{
				alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='245.Ürün'>");
				return false;
			}
			zero_stock_control();
			for(var i=1; i<=xx; i++)
			{
				if(eval('document.all.row_kontrol'+i).value == 1)
				{
					document.getElementById("amount"+i).value = filterNum(document.getElementById("amount"+i).value);
				}
			}
			document.getElementById("add_ship_dispatch").submit();
		}
		
		function stock_reserve(no)
		{
			//Miktar değiştirildiyse önceden eklenen rezerveler silinir
			if(eval('document.add_order.sid'+no).value != '')	
				var del_stock_reserve_0 = workdata('del_order_reserve_from_row','<cfoutput>#CFTOKEN#</cfoutput>,'+eval('document.add_order.sid'+no).value);
			var listParam = "<cfoutput>#dsn2_alias#</cfoutput>" + "*" + eval('document.add_order.barcode'+no).value;
			var stock_control = wrk_safe_query("wpda_stock_control_2",'dsn3',0,listParam);
			if(eval('document.add_order.sid'+no).value == '')	
				eval('document.add_order.sid'+no).value = stock_control.STOCK_ID;
			if(stock_control.SALEABLE_STOCK > 0)
			{
				if(parseFloat(eval('document.add_order.amount'+no).value) > parseFloat(stock_control.SALEABLE_STOCK))
				{
					eval('document.add_order.amount'+no).value = parseFloat(stock_control.SALEABLE_STOCK);
				}		
				var del_stock_reserve = workdata('del_order_reserve_from_row','<cfoutput>#CFTOKEN#</cfoutput>,'+stock_control.STOCK_ID);
				var listParam = stock_control.STOCK_ID + "*" + stock_control.PRODUCT_ID + "*" + "<cfoutput>#CFTOKEN#</cfoutput>" + "*" + eval('document.add_order.amount'+no).value;
				var stock_reserve = wrk_safe_query("wpda_stock_reserve",'dsn3',0,listParam);
				alert('Satılabilir ' + stock_control.SALEABLE_STOCK + ' adet stoktan ' + eval('document.add_order.amount'+no).value + ' adet rezerve edildi!');
			}
			else
			{
				alert("Bu üründen stoklarda yoktur !");
				sil(no);
				return false;
			}
		}
		function stock_reserve_upd(no,quantity,stock_id,product_id)
		{
			//Miktar değiştirildiyse önceden eklenen rezerveler silinir
			if(eval('document.add_order.sid'+no).value != '')	
				var del_stock_reserve_0 = workdata('del_order_reserve_from_row','<cfoutput>#CFTOKEN#</cfoutput>,'+stock_id);
			if(eval('document.add_order.sid'+no).value == '')	
				eval('document.add_order.sid'+no).value = stock_id;
			
			var stock_control = wrk_safe_query('wpda_stock_control','dsn2',0,stock_id);
			var stock_total = parseFloat(quantity) + parseFloat(stock_control.SALEABLE_STOCK);
			if(parseInt(stock_total) > 0)
			{
				if(parseInt(eval('document.add_order.amount'+no).value) > parseInt(stock_total))
				{
					eval('document.add_order.amount'+no).value = parseInt(stock_total);
				}	
				//	yeni rezerve edilecek miktar eksi de olsa artı da olsa pre-order-id ile rezerve edilir.. ki diğer bakanlar doğru stok görebilsinler
				var new_reservable_stock_amount = eval('document.add_order.amount'+no).value - quantity;
				if(new_reservable_stock_amount != 0)
				{
					//var del_stock_reserve = workdata('del_order_reserve_from_row','<cfoutput>#CFTOKEN#</cfoutput>,'+stock_id);
					if(parseInt(new_reservable_stock_amount) > 0)
						{
							var listParam = stock_id + "*" + product_id + "*" + "<cfoutput>#CFTOKEN#</cfoutput>" + "*" + new_reservable_stock_amount;
							var new_sql_2 = "wpda_stock_reserve";
						}
					else if(parseInt(new_reservable_stock_amount) < 0)
						{
							var listParam = stock_id + "*" + product_id + "*" + "<cfoutput>#CFTOKEN#</cfoutput>" + "*" + Math.abs(new_reservable_stock_amount);
							var new_sql_2 = "wpda_stock_reserve_2";				
						}				
					var stock_reserve = wrk_safe_query(new_sql_2,'dsn3',0,listParam);
				}
				alert('Satılabilir ' + stock_total + ' adet stoktan ' + eval('document.add_order.amount'+no).value + ' adet rezerve edildi!');
			}
			else
			{
				alert("Bu üründen stoklarda yoktur !");
				sil(no);
				return false;
			}
		}
	</cfif>
	<cfif fuseaction is 'pda.form_add_purchase_return' or fuseaction is 'pda.form_add_sale'>
		function control_inputs()
		{
			if(document.getElementById('ship_number').value == '')
			{
				alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='726.İrsaliye No'>");
				return false;
			}
			<cfif fuseaction is 'pda.form_add_sale'>
				var control_paper_no = wrk_safe_query("wpda_control_paper_no",'dsn2',0,document.getElementById('ship_number').value);
				if(control_paper_no.recordcount > 0)
				{
					alert("Bu Numara ile Kayıtlı İrsaliye Bulunmaktadır !");
					return false;
				}
			</cfif>
			if(document.getElementById("process_cat") != undefined && document.getElementById("process_cat").value == "")
			{
				alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='388.İşlem Tipi'>");
				return false;
			}
			if(document.getElementById('department_location').value == '' || document.getElementById('department_id').value == '')
			{
				alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='1351.Depo'>");
				return false;
			}
			if(document.getElementById('company_id').value == '')
			{
				alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='107.Cari Hesap'>");
				return false;
			}
			if(document.getElementById('ship_row_count').value == 0)
			{
				alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='245.Ürün'>");
				return false;
			}
		
			var cnt_ = 0;
			var product_exists = 0;
			var diff_amount_barcod_list = "";
			var xx = parseInt(document.all.row_count.value);
			var yy = parseInt(document.all.ship_row_count.value);
			
			for(var i=1; i<=xx; i++)
			{
				if(eval('document.all.row_kontrol'+i).value == 1)
				{
					if(parseFloat(document.getElementById('amount'+i).value) != parseFloat(document.getElementById('amount_diff'+i).value))
						diff_amount_barcod_list = diff_amount_barcod_list + "("+ document.getElementById('barcode'+i).value + ") "+ document.getElementById('product_name'+i).value + "\n";
				}
			}
			for(var i=1; i<=yy; i++)
			{
				if(eval('document.all.ship_row_kontrol'+i).value == 1)
				{
					cnt_ ++;
					product_exists = product_exists + 1;
					if(document.getElementById('ship_amount'+i) != undefined && parseFloat(filterNum(document.getElementById('ship_amount'+i).value,4)) <= 0)
					{
						alert(cnt_ + ". Satırda Girilen Miktar 0 Dan Farklı Olmalıdır!");
						cnt_ = 0;
						return false;
					}
				}
			}
			
			if(product_exists == 0)
			{
				alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='245.Ürün'>");
				return false;
			}
			if(document.getElementById("order_id_listesi") != undefined && document.getElementById("order_id_listesi").value != "" && diff_amount_barcod_list != "")
			{
				if(confirm("Aşağıda Belirtilen Barkodlardaki Sipariş Miktarı ile İşlenen Miktarlar Eşit Değildir! \n"+diff_amount_barcod_list+"\nDevam Etmek İstiyor Musunuz?"))
				{
					for(var y=1; y<=yy; y++)
					{
						document.getElementById('ship_amount'+y).value = filterNum(document.getElementById('ship_amount'+y).value);
					}
					document.getElementById("add_sale").submit();
				}
				else
					return false;
			}
			for(var y=1; y<=yy; y++)
			{
				document.getElementById('ship_amount'+y).value = filterNum(document.getElementById('ship_amount'+y).value);
			}
			document.getElementById("add_sale").submit();
		}
		function kontrol_prerecord()
		{
			goster(kontrol_prerecord_div);
			AjaxPageLoad(<cfoutput>'#request.self#</cfoutput>?fuseaction=pda.emptypopup_get_company_div&field_id=add_sale.ref_company_id&field_name=add_sale.ref_member_name&field_type=add_sale.ref_member_type&field_partner_id=add_sale.ref_partner_id&ref_member_name='+ encodeURI(add_sale.ref_member_name.value) +'&div_name='+'kontrol_prerecord_div' +'&form_id=' + 'add_sale','kontrol_prerecord_div');		
			return false;
		}
		
		function sil_bastan()
		{
			gizle(show_buttons);	
			document.all.nettotal.value = 0;
			document.all.basket_net_total.value = 0;
			document.all.sa_discount.value = 0;
			document.all.nettotal_usd.value = 0;
			document.all.basket_net_total_usd.value = 0;
		}
	</cfif>
	<cfif fuseaction is 'pda.form_add_stock_count_file'>
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
					product_exists = product_exists + 1;
			}
			if(product_exists == 0)
			{
				alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='245.Ürün'>");
				return false;
			}
			document.getElementById("add_ship_dispatch").submit();
		}
	</cfif>
	<cfif attributes.fuseaction contains 'pda.form_add_production_result' or attributes.fuseaction contains 'pda.form_upd_production_result'>
		<!--- Uretim Sonucu Sayfalarinda Duzenleniyor --->
	</cfif>
	function zero_stock_control()
	{
		var stock_id_list='0';
		var stock_amount_list='0';
		var hata='';
		var get_process = wrk_safe_query('prdp_get_process','dsn3',0,document.add_ship_dispatch.process_cat.value);
		var xx = parseInt(document.all.row_count.value);
		if(get_process.IS_ZERO_STOCK_CONTROL == 1)
		{
			for(var i=1;i <= xx;i++)
			{
				if(eval('document.add_ship_dispatch.row_kontrol'+i).value==1)
				{
					var get_stock_id = wrk_safe_query("wpda_get_stock_id_2",'dsn3',0,eval('document.add_ship_dispatch.barcode'+i).value);
					stock_id_ = get_stock_id.STOCK_ID;
					var yer=list_find(stock_id_list,stock_id_,',');
					if(yer)
					{
						top_stock_miktar=parseFloat(list_getat(stock_amount_list,yer,','))+parseFloat(filterNum(eval('document.add_ship_dispatch.amount'+i).value,3));
						stock_amount_list=list_setat(stock_amount_list,yer,top_stock_miktar,',');
					}
					else
					{
						stock_id_list=stock_id_list+','+stock_id_;
						stock_amount_list=stock_amount_list+','+filterNum(eval('document.add_ship_dispatch.amount'+i).value,3);
					}
				}	
			}
			if(list_len_(stock_id_list,',')>1)
			{
				var new_sql = 'SELECT SUM(SR.STOCK_IN - SR.STOCK_OUT) AS PRODUCT_TOTAL_STOCK,S.STOCK_ID,S.STOCK_CODE,S.PRODUCT_NAME AS PRODUCT_NAME FROM <cfoutput>#dsn3_alias#</cfoutput>.STOCKS S, STOCKS_ROW SR WHERE SR.STOCK_ID=S.STOCK_ID AND SR.STOCK_ID IN ('+stock_id_list+') AND S.IS_ZERO_STOCK=0 AND SR.STORE_LOCATION='+document.all.location_id.value+' AND SR.STORE ='+document.all.department_id.value +' GROUP BY S.STOCK_ID,S.STOCK_CODE,S.PRODUCT_NAME';
				var listParam = "<cfoutput>#dsn3_alias#</cfoutput>" + "*" + stock_id_list + "*" + document.all.location_id.value + "*" + document.all.department_id.value;
				var get_total_stock = wrk_safe_query("wpda_get_total_stock",'dsn2',0,listParam);
				if(get_total_stock.recordcount)
				{
					var query_stock_id_list='0';
					for(var cnt=0; cnt < get_total_stock.recordcount; cnt++)
					{
						query_stock_id_list=query_stock_id_list+','+get_total_stock.STOCK_ID[cnt];//queryden gelen kayıtları tutuyruz gelmeyenlerde stokta yoktur cunku
						var yer=list_find(stock_id_list,get_total_stock.STOCK_ID[cnt],',');
						if(parseFloat(get_total_stock.PRODUCT_TOTAL_STOCK[cnt]) < parseFloat(list_getat(stock_amount_list,yer,',')))
							hata = hata+ 'Ürün:'+get_total_stock.PRODUCT_NAME[cnt]+'(Stok Kodu:'+get_total_stock.STOCK_CODE[cnt]+')\n';
					}
				}
				var diff_stock_id='0';
				for(var lst_cnt=1;lst_cnt <= list_len_(stock_id_list);lst_cnt++)
				{
					var stk_id=list_getat(stock_id_list,lst_cnt,',')
					if(query_stock_id_list==undefined || query_stock_id_list=='0' || list_find(query_stock_id_list,stk_id,',') == '0')
						diff_stock_id=diff_stock_id+','+stk_id;//kayıt gelmeyen urunler
				}
				if(list_len_(diff_stock_id,',')>1)
				{//bu lokasyona hiç giriş veya çıkış olmadı ise kayıt gelemyecektir o yüzden yazıldı
					var get_stock = wrk_safe_query("obj_get_stock",'dsn3',0,diff_stock_id);
					for(var cnt=0; cnt < get_stock.recordcount; cnt++)
						hata = hata+ 'Ürün:'+get_stock.PRODUCT_NAME[cnt]+'(Stok Kodu:'+get_stock.STOCK_CODE[cnt]+')\n';
				}
				get_total_stock='';
			}
		}
		if(hata!='')
		{
			alert(hata+"\n\nYukarıdaki ürünlerde stok miktarı yeterli değildir Lütfen seçtiğiniz depo lokasyonundaki miktarları kontrol ediniz !");
			return false;
		}
		else
			return true;
	}
</script>