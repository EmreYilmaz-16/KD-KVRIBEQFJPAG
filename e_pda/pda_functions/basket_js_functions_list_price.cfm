<script type="text/javascript"> 
function get_paymethod_div()
{
	goster(paymethod_div);
	AjaxPageLoad(<cfoutput>'#request.self#</cfoutput>?fuseaction=pda.emptypopup_get_paymethod_div&keyword='+encodeURI(add_order.paymethod.value),'paymethod_div');		
}
function add_paymethod_st(id,name,int_due,due_day,paymethod_vehicle,due_date_rate,due_month)
{ //standart odeme yontemi bilgilerini gonderir ve tanımlıysa kredi kartı odeme yontemi inputlarını bosaltır 
	document.add_order.paymethod_id.value=id;
	document.add_order.paymethod.value=name;
	//document.add_order.basket_due_value.value = due_day;
	document.add_order.paymethod_vehicle.value = paymethod_vehicle;
	document.add_order.card_paymethod_id.value='';
	document.add_order.commission_rate.value = '';
	gizle(paymethod_div);
}
function add_paymethod_cc(id,name,stock_id,product_id,rate)
{ //kredi kartı odeme yontemi bilgilerini gonderir ve tanımlıysa standart odeme yontemi inputlarını bosaltır
	document.add_order.card_paymethod_id.value=id;
	document.add_order.paymethod.value=name;
	document.add_order.commission_rate.value = rate;
	document.add_order.paymethod_id.value='';
	//document.add_order.basket_due_value.value = '';
	document.add_order.paymethod_vehicle.value = '';
	gizle(paymethod_div);
}

function get_stores_locations_div_1()
{
	goster(stores_locations_div_cikis);//&ref_member_name='+ encodeURI(add_order.member_name.value)
	AjaxPageLoad(<cfoutput>'#request.self#</cfoutput>?fuseaction=pda.emptypopup_get_stores_locations_div_1&form_name=form_basket&field_name=department_in_txt&field_id=department_in_id&field_location_id=location_in_id&div_name=stores_locations_div_cikis' + '&is_my=1' + '&form_id=add_order','stores_locations_div_cikis');		
	return false;
}
function get_stores_locations_div_2()
{
	goster(stores_locations_div_giris);//&ref_member_name='+ encodeURI(add_order.member_name.value)
	AjaxPageLoad(<cfoutput>'#request.self#</cfoutput>?fuseaction=pda.emptypopup_get_stores_locations_div_2&form_name=form_basket&field_name=department_in_txt&field_id=department_in_id&field_location_id=location_in_id&div_name=stores_locations_div_giris' + '&is_my=1' + '&form_id=add_order','stores_locations_div_giris');		
	return false;
}
function add_stores_locations_div_1(department_id,location_id,txt_departman_)
{
	document.add_order.department_id.value = department_id;
	document.add_order.location_id.value = location_id;
	document.add_order.txt_departman_.value = txt_departman_;
	gizle(stores_locations_div_cikis);
}
function add_stores_locations_div_2(department_id,location_id,txt_departman_)
{
	document.add_order.department_in_id.value = department_id;
	document.add_order.location_in_id.value = location_id;
	document.add_order.department_in_txt.value = txt_departman_;
	gizle(stores_locations_div_giris);
}

function add_company_div(company_id,member_name,partner_id,member_type)
{
	document.add_order.company_id.value = company_id;
	document.add_order.member_name.value = member_name;
	document.add_order.partner_id.value = partner_id;
	document.add_order.member_type.value = member_type;
	gizle(company_all_div);
}
function clear_barcode()
{
	gizle(show_buttons);
	document.add_order.search_product.value="";
	document.add_order.search_product.focus();	
}
function stock_reserve(no)
{
	gizle(show_buttons);
	//Miktar değiştirildiyse önceden eklenen rezerveler silinir
	if(eval('document.add_order.sid'+no).value != '')	
		var del_stock_reserve_0 = workdata('del_order_reserve_from_row','<cfoutput>#CFTOKEN#</cfoutput>,'+eval('document.add_order.sid'+no).value);
		
	var listParam = "<cfoutput>#dsn2_alias#</cfoutput>" + "*" + eval('document.add_order.barcode'+no).value;
	var stock_control = wrk_safe_query("wpda_stock_control_2",'dsn3',0,listParam);
	if(eval('document.add_order.sid'+no).value == '')	
		eval('document.add_order.sid'+no).value = stock_control.STOCK_ID;
	if(stock_control.SALEABLE_STOCK > 0)
	{
		if(parseInt(eval('document.add_order.amount'+no).value) > parseInt(stock_control.SALEABLE_STOCK))
		{
			eval('document.add_order.amount'+no).value = parseInt(stock_control.SALEABLE_STOCK);
		}		
		var del_stock_reserve = workdata('del_order_reserve_from_row','<cfoutput>#CFTOKEN#</cfoutput>,'+stock_control.STOCK_ID);
		var listParam = stock_control.STOCK_ID + "*" + stock_control.PRODUCT_ID + "*" + "<cfoutput>#CFTOKEN#</cfoutput>" + "*" + eval('document.add_order.amount'+no).value;
		var stock_reserve = wrk_safe_query(new_sql_2,'dsn3',0,listParam);
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
					eval('document.add_order.amount'+i).select();
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
		eval('document.add_order.row_kontrol'+no).value = 1;
		eval('document.add_order.barcode'+no).value = barcode;
		eval('document.add_order.amount'+no).select();
		document.getElementById('row_count').value = parseInt(document.getElementById('row_count').value) + 1;
	}	
}

function calc_list_price(barcode)
{
	if(barcode == "")
	{
		alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='221.Barkod'>");
		return false;
	}
	else
	{
		var rate_list = "";
		var barcode_list = barcode;
		var barcode_amount_list = 1;
		document.getElementById('basket_products').value = barcode_list;
		document.getElementById('basket_products_amount').value = barcode_amount_list;
		<cfoutput query="get_money_bskt">
			rate_list = rate_list + '&rt1_#money_type#='+document.getElementById("txt_rate1_#money_type#").value + '&rt2_#money_type#='+document.getElementById("txt_rate2_#money_type#").value;
		</cfoutput>
		goster(calc_order_div);
	
		AjaxPageLoad('<cfoutput>#request.self#</cfoutput>?fuseaction=pda.emptypopup_calc_list_price&basket_products_amount=1'+rate_list+'&basket_products='+document.getElementById('basket_products').value+'&price_date='+encodeURI(document.getElementById("price_date").value)+'&price_list_id='+document.getElementById("price_list_id").value,'calc_order_div',1);		
	}
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
	var listParam = stock_id + "*" + product_id + "*" + "<cfoutput>#CFTOKEN#</cfoutput>" + "*" + quantity;  
	var stock_reserve = wrk_safe_query("wpda_stock_reserve_2",'dsn3',0,listParam);	
}
function control_inputs()
{
	if(document.getElementById('company_id').value == '')
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
	document.all.nettotal.value = 0;
	document.all.basket_net_total.value = 0;
	document.all.sa_discount.value = 0;
	document.all.nettotal_usd.value = 0;
	document.all.basket_net_total_usd.value = 0;
}
</script>