<script type="text/javascript"> 
	function get_paymethod_div()
	{
		goster(paymethod_div);
		AjaxPageLoad(<cfoutput>'#request.self#</cfoutput>?fuseaction=pda.emptypopup_get_paymethod_div&keyword='+encodeURI(document.getElementById('paymethod').value),'paymethod_div');		
	}
	
	function add_paymethod_st(id,name,int_due,due_day,paymethod_vehicle,due_date_rate,due_month)
	{ 	//standart odeme yontemi bilgilerini gonderir ve tanımlıysa kredi kartı odeme yontemi inputlarını bosaltır 
		document.getElementById('paymethod_id').value=id;
		document.getElementById('paymethod').value=name;
		document.getElementById('paymethod_vehicle').value = paymethod_vehicle;
		document.getElementById('card_paymethod_id').value='';
		document.getElementById('commission_rate').value = '';
		gizle(paymethod_div);
	}

	
	function add_paymethod_cc(id,name,stock_id,product_id,rate)
	{ 	//kredi kartı odeme yontemi bilgilerini gonderir ve tanımlıysa standart odeme yontemi inputlarını bosaltır
		document.getElementById('card_paymethod_id').value=id;
		document.getElementById('paymethod').value=name;
		document.getElementById('commission_rate').value = rate;
		document.getElementById('paymethod_id').value='';
		document.getElementById('paymethod_vehicle').value = '';
		gizle(paymethod_div);
	}
	
	function get_company_all_div()
	{
		if(div_name == undefined) var div_name = "company_all_div"; // Bu Sekilde Kullanildigi Yerler Var Hepsi Duzenlendiginde Kullanilmiyorsa Kaldirilacak
		if(document.getElementById('member_name').value.length <= 2)
		{
			alert("Lütfen listelemek için en az 3 karakter giriniz !");
			return false;
		}
		goster(document.getElementById(div_name));
		AjaxPageLoad(<cfoutput>'#request.self#</cfoutput>?fuseaction=stock.get_comp_prtotm&ref_member_name='+ encodeURI(document.getElementById('member_name').value) +'&div_name='+div_name+'&is_my=1' + '&form_id=add_order',div_name);		
		return false;
	}
	function add_company_div(div_name,company_id,member_name,partner_name,partner_id,member_type,price_cat)
	{
		document.getElementById('company_id').value = company_id;
		document.getElementById('member_name').value = member_name;
		document.getElementById('partner_id').value = partner_id;
		document.getElementById('member_type').value = member_type;
		document.getElementById('price_cat_id').value = price_cat;
		gizle(document.getElementById(div_name));
	}
	function clear_barcode()
	{
		gizle(show_buttons);
		document.getElementById('search_product').value="";
		document.getElementById('search_product').focus();	
	}
	function stock_reserve(no)
	{
		gizle(show_buttons);
		//Miktar değiştirildiyse önceden eklenen rezerveler silinir
		if(eval('document.getElementById("sid'+no+'")').value != '')	
			var del_stock_reserve_0 = workdata('del_order_reserve_from_row','<cfoutput>#CFTOKEN#</cfoutput>,'+eval('document.getElementById("sid'+no+'")').value);
		var listParam = "<cfoutput>#dsn2_alias#</cfoutput>" + "*" + eval('document.getElementById("barcode'+no+'")').value;
		var stock_control = wrk_safe_query("wpda_stock_control_2",'dsn3',0,listParam);
		if(eval('document.getElementById("sid'+no+'")').value == '')	
			eval('document.getElementById("sid'+no+'")').value = stock_control.STOCK_ID;
		if(stock_control.SALEABLE_STOCK > 0)
		{
			if(parseInt(eval('document.getElementById("amount'+no+'")').value) > parseInt(stock_control.SALEABLE_STOCK))
			{
				eval('document.getElementById("amount'+no+'")').value = parseInt(stock_control.SALEABLE_STOCK);
			}		
			var del_stock_reserve = workdata('del_order_reserve_from_row','<cfoutput>#CFTOKEN#</cfoutput>,'+stock_control.STOCK_ID);
			var listParam = stock_control.STOCK_ID + "*" + stock_control.PRODUCT_ID + "*" + "<cfoutput>#CFTOKEN#</cfoutput>" + "*" + eval('document.getElementById("amount'+no+'")').value; 
			var stock_reserve = wrk_safe_query("wpda_stock_reserve",'dsn3',0,listParam);
			alert('Satılabilir ' + stock_control.SALEABLE_STOCK + ' adet stoktan ' + eval('document.getElementById("amount'+no+'")').value + ' adet rezerve edildi!');
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
		gizle(show_buttons);
		//Miktar değiştirildiyse önceden eklenen rezerveler silinir
		if(eval('document.add_order.sid'+no).value != '')	
			var del_stock_reserve_0 = workdata('del_order_reserve_from_row','<cfoutput>#CFTOKEN#</cfoutput>,'+stock_id);
		if(eval('document.add_order.sid'+no).value == '')	
			eval('document.add_order.sid'+no).value = stock_id;
		
		var stock_control = wrk_safe_query('wpda_stock_control','dsn2',0,stock_id);
		var stock_total = parseInt(quantity) + parseInt(stock_control.SALEABLE_STOCK);
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
	function add_barcode2(no,barcode)
	{
		barcode_found = 0;
		var xx = parseInt(document.getElementById('row_count').value);
		if(xx > 0)
		{	
			for(var i=1; i<=xx; i++)
			{
				if(eval('document.getElementById("row_kontrol'+i+'")').value == 1)
				{
					if(barcode == eval('document.getElementById("barcode'+i+'")').value)
					{
						eval('document.getElementById("amount'+i+'")').select();
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
			eval('document.getElementById("row_kontrol'+no+'")').value = 1;
			eval('document.getElementById("barcode'+no+'")').value = barcode;
			eval('document.getElementById("amount'+no+'")').select();
			document.getElementById('row_count').value = parseInt(document.getElementById('row_count').value) + 1;
		}	
	}
	function add_stock_code2(no,stock_code_2)
	{
		barcode_found_ = 0;
		var get_stock = wrk_safe_query('wpd_barcode_stock_code_2','dsn3',0,stock_code_2);
		var xx = parseInt(document.getElementById('row_count').value);
		if(xx > 0)
		{	
			for(var i=1; i<=xx; i++)
			{
				if(eval('document.getElementById("row_kontrol'+i+'")').value == 1)
				{
					if(get_stock.BARCOD == eval('document.getElementById("barcode'+i+'")').value)
					{
						eval('document.getElementById("amount'+i+'")').select();
						barcode_found = 1;
						break;
					}	
				}	
			}	
		}			
		if(barcode_found_ == 0)
		{
			no++;
			goster(eval('n_my_div' + no));
			eval('document.getElementById("row_kontrol'+no+'")').value = 1;
			eval('document.getElementById("barcode'+no+'")').value = get_stock.BARCOD;
			eval('document.getElementById("amount'+no+'")').select();
			document.getElementById('row_count').value = parseInt(document.getElementById('row_count').value) + 1;
		}	
	}
	function calc_order()
	{
		if(document.getElementById('company_id').value == '' && document.getElementById('member_name').value == '')
		{
			alert("Lütfen Müşteri (Cari Hesap) Seçiniz!");
			return false;
		}
	
		var xx = parseInt(document.getElementById('row_count').value);		
		var product_exists = 0;
		for(var i=1; i<=xx; i++)
		{
			if(eval('document.getElementById("row_kontrol'+i+'")').value == 1)
			{
				product_exists = product_exists + 1;
			}
		}
		if(product_exists == 0 || document.getElementById('row_count').value == 0)
		{
			alert("Eksik Veri : Ürün");
			return false;
		}
		var rate_list = "";
		var rate_list_2 = "";
		var barcode_list = '';
		var barcode_amount_list = '';
		var barcode_free_product_list = '';
		for(var i=1; i<=xx; i++)
		{	
			if(eval('document.getElementById("row_kontrol'+i+'")').value == 1)
			{	
				if(eval('document.getElementById("barcode'+i+'")') && eval('document.getElementById("barcode'+i+'")').value != '' && eval('document.getElementById("amount'+i+'")').value != '')
					if(barcode_list.length > 0)
					{
						barcode_list = barcode_list + ',' + eval('document.getElementById("barcode'+i+'")').value;
						barcode_amount_list = barcode_amount_list + ',' + eval('document.getElementById("amount'+i+'")').value;
						if(eval('document.getElementById("is_free_product'+i+'")'))
							barcode_free_product_list = barcode_free_product_list + ',' + eval('document.getElementById("is_free_product'+i+'")').value;
					}
					else
					{
						barcode_list = barcode_list + eval('document.getElementById("barcode'+i+'")').value;
						barcode_amount_list = barcode_amount_list + eval('document.getElementById("amount'+i+'")').value;
						if(eval('document.getElementById("is_free_product'+i+'")'))
							barcode_free_product_list = barcode_free_product_list + eval('document.getElementById("is_free_product'+i+'")').value;
					}
			}
		}	
		document.getElementById('price_list_id').value = document.getElementById('price_cat_id')[document.getElementById('price_cat_id').selectedIndex].value;
		document.getElementById('price_date').value = document.getElementById('order_date').value;
		document.getElementById('basket_products').value = barcode_list;
		document.getElementById('basket_products_amount').value = barcode_amount_list;	
		document.getElementById('basket_free_products').value = barcode_free_product_list;			
		document.form_calc_order.company_id.value = document.add_order.company_id.value;
	
		<cfoutput query="get_money_bskt">
			rate_list = rate_list + '&rt1_#money_type#='+document.form_calc_order.txt_rate1_#money_type#.value + '&rt2_#money_type#='+document.form_calc_order.txt_rate2_#money_type#.value;
		</cfoutput>
		//AjaxPageLoad(<cfoutput>'#request.self#</cfoutput>?fuseaction=pda.emptypopup_calc_order_div&'+rate_list+'&basket_money=USD&basket_products_amount='+document.form_calc_order.basket_products.value+'&basket_products='+document.form_calc_order.basket_products.value+'&company_id='+document.form_calc_order.company_id.value+'&price_list_id='+document.getElementById('price_list_id').value+'&price_date='+encodeURI(document.add_order.order_date.value),'calc_order_div');		
		AjaxFormSubmit('form_calc_order','calc_order_div',1,'Hesaplanıyor...','Hesaplandı!','','',1);
		goster(show_buttons);
	}
	function sil(sy)
	{
		document.getElementById('n_my_div'+sy).style.display = 'none';
		document.getElementById('row_kontrol'+sy).value = 0;///alanın silindiğini tutuyoruz. toplam hesaplamada ve kayıt ederken kullanılıyor
		gizle(show_buttons);
	}
	function sil_rezerv(no)
	{
		var get_stock_id = wrk_safe_query('wpda_get_stock_id_2','dsn3',0,eval('document.add_order.barcode'+no).value);
		var del_stock_reserve = workdata('del_order_reserve_from_row','<cfoutput>#CFTOKEN#</cfoutput>,'+get_stock_id.STOCK_ID);
	}
	function sil_rezerv_upd(no,quantity,stock_id,product_id)
	{
		//var get_stock_id = wrk_safe_query('wpda_get_stock_id','dsn3',0,eval('document.add_order.barcode'+no).value); 	
		var del_stock_reserve = workdata('del_order_reserve_from_row','<cfoutput>#CFTOKEN#</cfoutput>,'+stock_id);
		var listParam = stock_id + "*" + product_id + "*" + "<cfoutput>#CFTOKEN#</cfoutput>" + "*" + quantity;
		//var stock_reserve = wrk_safe_query(new_sql_2,'dsn3',0,listParam);	
		var stock_reserve = wrk_safe_query(del_stock_reserve,'dsn3',0,listParam);	
	}
	function control_inputs()
	{
		if(document.getElementById('company_id').value == '')
		{
			alert("Eksik Veri : Üye");
			return false;
		}
		if(document.getElementById('row_count').value == 0)
		{
			alert("Eksik Veri : Ürün");
			return false;
		}
	
		var xx = parseInt(document.getElementById('row_count').value);
	
		var product_exists = 0;
		for(var i=1; i<=xx; i++)
		{
			if(eval('document.getElementById("row_kontrol'+i+'")').value == 1)
			{
				product_exists = product_exists + 1;
			}
		}
		if(product_exists == 0)
		{
			alert("Eksik Veri : Ürün");
			return false;
		}
		document.getElementById('nettotal_usd').value = filterNum(document.getElementById('nettotal_usd').value,2);
		document.add_order.submit();;
	}
	function kontrol_prerecord()
	{
		goster(kontrol_prerecord_div);
		AjaxPageLoad(<cfoutput>'#request.self#</cfoutput>?fuseaction=pda.emptypopup_get_company_div&field_id=add_order.ref_company_id&field_name=add_order.ref_member_name&field_type=add_order.ref_member_type&field_partner_id=add_order.ref_partner_id&ref_member_name='+ encodeURI(add_order.ref_member_name.value) +'&div_name='+'kontrol_prerecord_div' +'&form_id=' + 'add_order','kontrol_prerecord_div');		
		return false;
	}
	
	function sil_bastan()
	{
		gizle(show_buttons);	
		document.getElementById('nettotal').value = 0;
		document.getElementById('basket_net_total').value = 0;
		document.getElementById('sa_discount').value = 0;
		document.getElementById('nettotal_usd').value = 0;
		document.getElementById('basket_net_total_usd').value = 0;
	}
</script>