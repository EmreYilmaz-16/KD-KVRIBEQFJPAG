<cf_get_lang_set module_name="stock">
<cfscript>session_basket_kur_ekle(process_type:0);</cfscript>
<cfset default_process_type = 113>
<cfquery name="get_process_cat" datasource="#DSN3#">
	SELECT TOP (1)    
    	SPC.PROCESS_CAT_ID
	FROM         
    	SETUP_PROCESS_CAT AS SPC INNER JOIN
      	SETUP_PROCESS_CAT_FUSENAME AS SPCF ON SPC.PROCESS_CAT_ID = SPCF.PROCESS_CAT_ID INNER JOIN
    	SETUP_PROCESS_CAT_ROWS AS SPCR ON SPC.PROCESS_CAT_ID = SPCR.PROCESS_CAT_ID
	WHERE     
    	SPC.PROCESS_TYPE = #default_process_type# AND 
        SPCF.FUSE_NAME = 'pda.add_ezgi_live_sale' 
  	ORDER BY
    	SPC.PROCESS_CAT_ID DESC      
</cfquery>
<cfif not get_process_cat.recordcount>
	<script type="text/javascript">
		alert("Ambar Fişi İşlem Kategorisi Tanımlayınız!");
		history.back();	
	</script>
</cfif>
<cfquery name="get_ProcessType" datasource="#dsn#">
	SELECT
    	TOP (1)
		PT.PROCESS_ID,
		PT.PROCESS_NAME,
		PT.IS_STAGE_BACK,
		PT.MAIN_FILE,
		PT.IS_MAIN_FILE,
		PT.MAIN_ACTION_FILE,
		PT.IS_MAIN_ACTION_FILE
	FROM
		PROCESS_TYPE PT,
		PROCESS_TYPE_OUR_COMPANY PTOC
	WHERE
      	PT.IS_ACTIVE = 1 AND
		PT.PROCESS_ID = PTOC.PROCESS_ID AND
		CAST(PT.FACTION AS NVARCHAR(2500))+',' LIKE '%pda.add_ezgi_live_sale%' 
	ORDER BY
		PTOC.OUR_COMPANY_ID,
		PT.PROCESS_ID
</cfquery>
<cfif not get_ProcessType.recordcount>
	<script type="text/javascript">
		alert("Satış Siparişi Süreci Tanımlayınız!");
		history.back();	
	</script>
<cfelse>
	<cfset process_stage = get_ProcessType.PROCESS_ID>
</cfif>
<cfquery name="get_ProcessTypeEshipping" datasource="#dsn#">
	SELECT
    	TOP (1)
		PT.PROCESS_ID,
		PT.PROCESS_NAME,
		PT.IS_STAGE_BACK,
		PT.MAIN_FILE,
		PT.IS_MAIN_FILE,
		PT.MAIN_ACTION_FILE,
		PT.IS_MAIN_ACTION_FILE
	FROM
		PROCESS_TYPE PT,
		PROCESS_TYPE_OUR_COMPANY PTOC
	WHERE
      	PT.IS_ACTIVE = 1 AND
		PT.PROCESS_ID = PTOC.PROCESS_ID AND
		CAST(PT.FACTION AS NVARCHAR(2500))+',' LIKE '%sales.popup_add_ezgi_shipping%' 
	ORDER BY
		PTOC.OUR_COMPANY_ID,
		PT.PROCESS_ID
</cfquery>
<cfif not get_ProcessTypeEshipping.recordcount>
	<script type="text/javascript">
		alert("E-Shipping Süreci Tanımlayınız!");
		history.back();	
	</script>
<cfelse>
	<cfset process_stage_eshipping = get_ProcessTypeEshipping.PROCESS_ID>
</cfif>
<cfif isdefined('attributes.cpid')>
	<cfquery name="GET_COMPANY" datasource="#DSN#">
		SELECT
			C.MANAGER_PARTNER_ID,
			C.FULLNAME
		FROM
			COMPANY C,
			WORKGROUP_EMP_PAR WEP 
		WHERE
			C.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.cpid#"> AND
			C.COMPANY_ID=WEP.COMPANY_ID
			<cfif session.ep.admin eq 0 and session.ep.power_user eq 0>
				AND WEP.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.COMPANY_ID#">		
				AND WEP.POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#">  
			</cfif>
	</cfquery>
	<cfif get_company.recordcount>
		<cfquery name="GET_PARTNER" datasource="#DSN#">
			SELECT 
				PARTNER_ID,
				COMPANY_PARTNER_NAME,
				COMPANY_PARTNER_SURNAME
			FROM 
				COMPANY_PARTNER
			WHERE 
				PARTNER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_company.manager_partner_id#">
		</cfquery>
	</cfif>
</cfif>
<cfquery name="get_default_departments" datasource="#dsn#">
	SELECT 
    	DEFAULT_SALE_TYPE,       
    	DEFAULT_RF_TO_SV_DEP, 
        DEFAULT_RF_TO_SV_LOC
	FROM            
    	EZGI_PDA_DEPARTMENT_DEFAULTS
	WHERE        
    	EPLOYEE_ID = #session.ep.userid#
</cfquery>
<cfif not get_default_departments.recordcount>
	<script type="text/javascript">
		alert("Default Depo Ayarları Yapılmamış! Sistem Yöneticinizle Görüşün");
		history.back();	
	</script>
</cfif>
<cfset default_departments = '#get_default_departments.DEFAULT_RF_TO_SV_DEP#'> <!---Depo seçiminde select satırına gelecek Lokasyonların depatmanları tanımlanır--->

<cfparam name="attributes.department_in_id" default="#ListGetAt(get_default_departments.DEFAULT_RF_TO_SV_DEP,1)#-#ListGetAt(get_default_departments.DEFAULT_RF_TO_SV_LOC,1)#">
<cfparam name="attributes.department_out_id" default="#ListGetAt(get_default_departments.DEFAULT_RF_TO_SV_DEP,2)#-#ListGetAt(get_default_departments.DEFAULT_RF_TO_SV_LOC,2)#">
<cfparam name="attributes.sales_type" default="#get_default_departments.DEFAULT_SALE_TYPE#">
<cfquery name="get_store_type" datasource="#dsn3#">
	SELECT        
    	COUNT(*) AS RAF
	FROM            
    	PRODUCT_PLACE
	WHERE        
    	LOCATION_ID = #ListGetAt(attributes.department_in_id,2,"-")#  AND 
        STORE_ID = #ListGetAt(attributes.department_in_id,1,"-")# AND 
        PLACE_STATUS = 1
</cfquery>

<cfquery name="GET_ALL_LOCATION" datasource="#DSN#">
	SELECT        
    	D.DEPARTMENT_HEAD, 
        SL.DEPARTMENT_ID, 
        SL.LOCATION_ID, 
        SL.STATUS, 
        SL.COMMENT
	FROM            
    	STOCKS_LOCATION AS SL INNER JOIN
    	DEPARTMENT AS D ON SL.DEPARTMENT_ID = D.DEPARTMENT_ID 
	WHERE        
    	D.DEPARTMENT_ID IN (#default_departments#) AND 
        D.BRANCH_ID IN 
        				(
        					SELECT        
                            	BRANCH_ID
							FROM            
                            	BRANCH
							WHERE        
                            	COMPANY_ID = #session.ep.COMPANY_ID# AND 
                                BRANCH_STATUS = 1
        				) AND 
        SL.STATUS = 1 
</cfquery>

<cfquery name="GET_PRICE_CAT" datasource="#DSN3#">
	SELECT PRICE_CATID, PRICE_CAT FROM PRICE_CAT WHERE IS_SALES = 1
</cfquery>
<cfset Temp = QueryAddRow(GET_PRICE_CAT)>
<cfset Temp = QuerySetCell(GET_PRICE_CAT, "PRICE_CATID", 0)>
<cfset Temp = QuerySetCell(GET_PRICE_CAT, "PRICE_CAT", 'Standart Satış')>
<cfquery name="GET_PRICE_CAT" dbtype="query">
	SELECT PRICE_CATID, PRICE_CAT FROM GET_PRICE_CAT ORDER BY PRICE_CATID
</cfquery>
<script language="javascript" type="text/javascript">
  <!---var row_count = <cfoutput>#get_ambar_fis.recordcount#</cfoutput>;--->
  var row_count = 0;
  var barcod = '';
  var stockid = '';
  var spectmainid = '';
  var stockcode = '';
  var amount = '';
  var ekle = 0;
  var cikar = 0;
  var islemtipi = 0;//0-ekle 1-çıkar
  var buton = 0;// <1-buton pasif, >0-buton aktif
</script>
<table border="0" cellpadding="0" cellspacing="0" align="center" style="width:98%">
	<tr style="height:20px;">
		<td class="headbold">Sipariş Al</td>
	</tr>
</table>
<table cellpadding="0" cellspacing="0" border="1" class="color-light" align="center" style="width:98%">
	<tr class="color-header">
   		<td class="headbold" style="width:50%; height:20px; text-align:center"><a href="javascript://" style=" cursor:pointer" onClick="main_page();">
        	<div style="width:100%">Başlık</div>
        </a></td>
       	<td class="headbold" style="width:50%; text-align:center"><a href="javascript://" style=" cursor:pointer" onClick="row_page();">
        	<div style="width:100%">Satırlar</div>
        </a></td>
       	<!---<td class="headbold" style="width:40%; text-align:center"><a href="javascript://" style=" cursor:pointer" onClick="total_page();">Toplam</a></td>--->
    </tr>
</table>
<cfform name="add_order" id="add_order" method="post" action="" enctype="multipart/form-data">  
    <table id="main_page" cellpadding="2" cellspacing="1" border="0" class="color-border" align="center" style="width:98%">	
        <tr>
            <td class="" colspan="3">
                <table align="center" style="width:99%">
					<input type="hidden" name="kur_say" id="kur_say" value="<cfoutput>#get_money_bskt.recordcount#</cfoutput>">
					<input type="hidden" name="row_count" id="row_count" value="">
                    <input type="hidden" id="action_id" name="action_id" value="" />
                    <cfinput type="hidden" name="price_cat_id" id="price_cat_id" value="">
                    <cfinput type="hidden" name="raf_durum" id="raf_durum" value="#get_store_type.raf#">
                    <cfinput id="process_cat_id" type="hidden" name="process_cat_id" value="#get_process_cat.process_cat_id#">
                    <cfinput id="process_stage" type="hidden" name="process_stage" value="#get_ProcessType.PROCESS_ID#">
                    <cfinput id="process_stage_eshipping" type="hidden" name="process_stage_eshipping" value="#get_ProcessTypeEshipping.PROCESS_ID#">
  					<cfinput id="fis_tipi" type="hidden" name="fis_tipi" value="#default_process_type#">
					<cfoutput query="get_money_bskt">
						<input type="hidden" name="hidden_rd_money_#currentrow#" id="hidden_rd_money_#currentrow#" value="#money_type#">
						<input type="hidden" name="txt_rate1_#currentrow#" id="txt_rate1_#currentrow#" value="#rate1#">
						<input type="hidden" name="txt_rate2_#currentrow#" id="txt_rate2_#currentrow#" value="#rate2#">
						<cfif money_type is 'USD'>
							<input type="hidden" name="basket_money" id="basket_money" value="USD">
							<input type="hidden" name="basket_rate1" id="basket_rate1" value="#rate1#">
							<input type="hidden" name="basket_rate2" id="basket_rate2" value="#rate2#">
						</cfif>
					</cfoutput>
					<tr>
						<td class="infotag">Müşteri *</td>
						<td nowrap="nowrap">
							<input type="hidden" name="company_id" id="company_id" value="">
							<input type="hidden" name="partner_id" id="partner_id" value="">
							<input type="hidden" name="member_type" id="member_type" value="">
							<input type="text" name="member_name" id="member_name" value=""  style="width:130px;">

							<a href="javascript://" onClick="get_company_all_div();"><img src="/images/plus_list.gif" border="0" align="absmiddle" class="form_icon"></a>						
						</td>
					</tr>
					<tr><td></td><td><div id="turkish_letters_div"></div></td></tr>
					<tr><td colspan="2"><div id="company_all_div"></div></td></tr>
                    <tr>
						<td class="infotag">Sevk Depo</td>
						<td>
							<select name="txt_department_out" id="txt_department_out" style="width:150px">
                				<cfoutput query="get_all_location" group="department_id">
                  					<option disabled="disabled" value="#department_id#"<cfif attributes.department_out_id eq department_id>selected</cfif>>#department_head#</option>
                  					<cfoutput>
                    					<option <cfif not status>style="color:FF0000"</cfif> value="#department_id#-#location_id#" <cfif attributes.department_out_id eq '#department_id#-#location_id#'>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#<cfif not status>-Pasif</cfif>
                    					</option>
                  					</cfoutput> 
								</cfoutput>
              				</select>					
						</td>
					</tr>
					<tr>
						<td class="infotag">Fiyat Listesi</td>
						<td>
							<select name="price_id" id="price_id" style="width:150px;">
								<cfoutput query="get_price_cat">
									<option value="#price_catid#">#price_cat#</option>
								</cfoutput>
							</select>					
						</td>
					</tr>				
					<input type="hidden" name="order_date" id="order_date" value="<cfoutput>#dateformat(now(),'dd/mm/yyyy')#</cfoutput>" maxlength="10">
					<tr>
						<td class="infotag">Sevk Tarihi</td>
						<td>
							<cfinput type="text" name="ship_date" id="ship_date" value="#dateformat(date_add('d',1,now()),'dd/mm/yyyy')#"  validate="eurodate" maxlength="10" style="width:65px;">
							<cf_wrk_date_image date_field="ship_date">
						</td>
					</tr>
					<tr><td colspan="2"><div id="paymethod_div"></div></td></tr>
					<tr>
						<td class="infotag">Açıklama</td>
						<td>
							<textarea name="detail" id="detail" style="width:150px;height:25px;"></textarea>						
						</td>
					</tr>
                </table>
            </td>
        </tr>
        <tr class="color-header">
            <td style="width:33%; height:8px; text-align:left">
            	<input type="radio" name="sales_type" id="sales_type" value="1" readonly style=" vertical-align: bottom" <cfif attributes.sales_type eq 1>checked="checked"</cfif>/> Sipariş
            </td>
            <td style="width:33%; text-align:left">
            	<input type="radio" name="sales_type" id="sales_type" value="2" readonly style=" vertical-align: bottom" <cfif attributes.sales_type eq 2>checked="checked"</cfif>/> Sevkiyat
            </td>
            <td style="width:34%; text-align:left">
            	<input type="radio" name="sales_type" id="sales_type" value="3" readonly style=" vertical-align: bottom" <cfif attributes.sales_type eq 3>checked="checked"</cfif>/> Hazırlama
            </td>
        </tr>
    </table>
    <table id="row_page" cellpadding="2" cellspacing="1" border="0" class="color-border" align="center" style="width:98%; display:none">	
    	<tr class="color-list">
         	<td align="center" width="100%" colspan="3">Çıkış Depo 
            	<select name="txt_department_in" id="txt_department_in" style="width:100px" onchange="change_store(this.value)">
                	<cfoutput query="get_all_location" group="department_id">
                  		<option disabled="disabled" value="#department_id#"<cfif attributes.department_in_id eq department_id>selected</cfif>>#department_head#</option>
                  		<cfoutput>
                    		<option 
								<cfif not status>style="color:FF0000"</cfif> 
                           		value="#department_id#-#location_id#" 
								<cfif attributes.department_in_id eq '#department_id#-#location_id#'>selected</cfif>>
                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#
									<cfif not status>-Pasif</cfif>
                    		</option>
                  		</cfoutput> 
					</cfoutput>
           		</select>
            </td>
     	</tr>
    	<tr class="color-list">
         	<td align="center" width="15%">&nbsp;
            	<input id="add_other_amount" name="add_other_amount" type="text" style="width:15px; text-align:right" value="1" />
          	</td>
            <td align="center" width="50%">&nbsp;
           		<input id="add_other_barcod" name="add_other_barcod" type="text" value="" style="width:85px;" >
            </td>
            <td align="center" width="35%">&nbsp;
            	<cfif attributes.sales_type eq 3> <!---Stok Hareketi Yapılacaksa Stok Kontrolü--->
                    <span id="barcode_durum" style="text-align:center; <cfif get_store_type.raf gt 0 and attributes.sales_type eq 3>display:<cfelse>display:none</cfif>">
                        <!---Lokasyon Raflı ise ve İşlem Hazırlama yapacak ise--->
                        <input id="add_other_shelf" name="add_other_shelf" type="text" style="width:60px;" value="" />
                    </span>
                </cfif>
            </td>
     	</tr>
        <tr>
            <td colspan="3" class="color-list">
            	<table name="table1" id="table1"  cellpadding="2" cellspacing="1" border="0" class="color-border" align="center" style="width:100%">
            		<tr class="color-list">
                        <td style="width:20px; height:15px; text-align:center">S.N</td>
                        <td style="width:60px; text-align:center">Barkod</td>
                        <td style="text-align:center">Raf</td>
                        <td style="width:30px; text-align:center">Mikt.</td>
    				</tr>
            	</table>
            </td>
        </tr>
    </table>
    <table id="total_page" cellpadding="2" cellspacing="1" border="0" class="color-border" align="center" style="width:98%; display:none">	
        <tr>
            <td class="color-row">Toplam</td>
        </tr>
    </table>
    <table cellpadding="0" cellspacing="1" border="0" class="color-light" align="center" style="width:98%">
        <tr class="color-list">
        	<td></td>
        	<td style="background-color:PowderBlue; color:black; text-align:center; vertical-align:middle; width:60px; height:25px">
            	<a style="cursor:pointer" onclick="add_control();">
                	Kaydet
            	</a>
          	</td>
            <td style="background-color:PowderBlue; color:black; text-align:center; vertical-align:middle; width:60px">
            	<a style="cursor:pointer" onclick="history.go(-1);">
                	Vazgeç
            	</a>
          	</td>
       	</tr>
    </table>
</cfform>
<div id="calc_order_div" style="display:none"></div>
<cfinclude template="../pda_functions/basket_js_functions_order.cfm">
	
<script language="javascript" type="text/javascript">
	document.getElementById('add_other_barcod').focus();
	setTimeout("document.getElementById('add_other_barcode').select();",1000);
	document.onkeydown = checkKeycode
	sorun_var = 0;
	function checkKeycode(e) 
	{
		var keycode;
		if (window.event) keycode = window.event.keyCode;
		else if (e) keycode = e.which;
		if (keycode == 13)
		{
			if (document.getElementById('add_other_amount').value.length <=0) 
			{
				alert('Önce Miktar Giriniz !');
				document.getElementById('add_other_amount').focus();
			}
			else
			{
				if(document.getElementById('raf_durum').value > 0)<!---Seçilen Depoda Raf Varsa--->
				{
					if (document.getElementById('add_other_barcod').value.length >0) /*Barkod Bilgisi Gelmişse*/
					{
						sorun_var = 0;
						get_stock(document.getElementById('add_other_barcod').value);/*Barkod Kontrolü*/
						<cfif attributes.sales_type eq 3> <!---E-Shipping Hazırlama ve Kontrol İşlemi Yapılacaksa--->
							if(sorun_var == 0)
							{
								document.getElementById('add_other_shelf').focus();
								if (document.getElementById('add_other_shelf').value.length >0) /*Raf Bilgisi Gelmişse */
								{
									if(sorun_var == 0)
									{
										search_shelf();/*Raf Kontrolü*/
										if(sorun_var == 0)
										{
											stock_shelf_control(document.getElementById('add_other_shelf').value); /*Raf Stok Kontrolü*/
											if(sorun_var == 0)
											{
												add_row(); /*Satır Ekle*/
												document.getElementById('add_other_shelf').value = '';
												document.getElementById('add_other_barcod').value = '';
												document.getElementById('add_other_amount').value = 1;
												document.getElementById('add_other_barcod').focus();
											}
										}
									}
								}
							}
						<cfelse> <!---Sipariş ve Sadece E-Shippingİşlemi Yapılacaksa Depo Raflı Dahi Olsa Raf Sormasın--->
							if(sorun_var == 0)
							{
								add_row(); /*Satır Ekle*/
								document.getElementById('add_other_barcod').value = '';
								document.getElementById('add_other_amount').value = 1;
								document.getElementById('add_other_barcod').focus();
							}
						</cfif>
					}
					else
					{
						alert('Önce Ürün Barkodu Okutunuz');
						document.getElementById('add_other_shelf').value = '';
						document.getElementById('add_other_barcode').focus();	
					}
				}
				else
				{
					if (document.getElementById('add_other_barcod').value.length >0) /*Barkod Bilgisi Gelmişse*/
					{
						sorun_var = 0;
						get_stock(document.getElementById('add_other_barcod').value);/*Barkod Kontrolü*/
						<cfif attributes.sales_type eq 3> <!---E-Shipping İşlemi Yapılacaksa--->
							if(sorun_var == 0)
							{
								stock_store_control();
								if(sorun_var == 0)
								{
									add_row(); /*Satır Ekle*/
									document.getElementById('add_other_barcod').value = '';
									document.getElementById('add_other_amount').value = 1;
									document.getElementById('add_other_barcod').focus();
								}
							}
						</cfif>
					}
				}
			}
		}
	}
	
	function get_stock(barcode)
    {
	 	stockid = ''; stockcode = ''; spectmainid = ''; //ilk önce sıfırlıyoruz
	 	var new_sql = "SELECT SB.STOCK_ID,SB.BARCODE,PU.MAIN_UNIT,PU.MULTIPLIER,S.PRODUCT_NAME FROM STOCKS_BARCODES AS SB INNER JOIN PRODUCT_UNIT AS PU ON SB.UNIT_ID = PU.PRODUCT_UNIT_ID INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID WHERE SB.BARCODE= '"+barcode+"'";
		var get_product = wrk_query(new_sql,'dsn3');
		if (get_product.STOCK_ID == undefined)
		{
			sorun_var = 1;
			document.getElementById('add_other_shelf').value = '';
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_other_amount').value = 1;
			document.getElementById('add_other_barcod').focus();
		}
		else
		{	
			stockid = get_product.STOCK_ID;
			stockcode = get_product.PRODUCT_NAME;
			barcode = get_product.BARCODE;
			shelf_code = '';
		}
	}
	function search_shelf() /*Raf Kontrol*/
	{
		var new_sql = "SELECT SB.STOCK_ID, SB.BARCODE, S.PRODUCT_NAME, PP.SHELF_CODE FROM STOCKS_BARCODES AS SB INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID INNER JOIN PRODUCT_PLACE_ROWS AS PPR ON S.PRODUCT_ID = PPR.PRODUCT_ID INNER JOIN PRODUCT_PLACE AS PP ON PPR.PRODUCT_PLACE_ID = PP.PRODUCT_PLACE_ID WHERE SB.BARCODE = '"+document.getElementById('add_other_barcod').value+"' AND PP.SHELF_CODE ='"+document.getElementById('add_other_shelf').value+"'";
		var get_product = wrk_query(new_sql,'dsn3');
		
		if (get_product.STOCK_ID == undefined)
		{
			sorun_var = 1;
			alert(document.getElementById('add_other_shelf').value+' Rafında Ürün Tanımlı Değil');
			document.getElementById('add_other_shelf').value = '';
			document.getElementById('add_other_shelf').focus();
		}
		else
		{
			stockid = get_product.STOCK_ID;
			stockcode = get_product.PRODUCT_NAME;
			barcode = get_product.BARCODE;
			shelf_code = get_product.SHELF_CODE;
		}
	}
	function stock_shelf_control(shelf_8) /*Raf Stok Kontrol*/
	{
		var stock_sql = "SELECT ISNULL(S.REAL_STOCK, 0) AS REAL_STOCK FROM GET_STOCK_LAST_SHELF AS S INNER JOIN <cfoutput>#dsn3_alias#</cfoutput>.PRODUCT_PLACE AS P ON S.SHELF_NUMBER = P.PRODUCT_PLACE_ID WHERE P.SHELF_CODE = '"+shelf_8+"' AND S.STOCK_ID ="+stockid;
		var get_real_stock = wrk_query(stock_sql,'dsn2');
		if(get_real_stock.REAL_STOCK==undefined)
			get_real_stock.REAL_STOCK = 0;
		if((get_real_stock.REAL_STOCK*1) < document.getElementById('add_other_amount').value * 1)
		{
			sorun_var = 1;
			alert("Yetersiz Stok. Çıkış Rafındaki Stok Miktarı : "+get_real_stock.REAL_STOCK);
			document.getElementById('add_other_amount').focus();
		}
		else
		{
			real_amount = get_real_stock.REAL_STOCK
			
		}
	}
	function stock_store_control() /*Depo Stok Kontrol*/
	{
		var stock_sql_1 = "SELECT ISNULL(PRODUCT_STOCK,0) AS REAL_STOCK FROM EZGI_GET_STOCK_LOCATION_TOTAL WHERE  DEPO = '"+document.getElementById('txt_department_in').value+"' AND STOCK_ID ="+stockid;
		var get_real_stock = wrk_query(stock_sql_1,'dsn2');
		if(get_real_stock.REAL_STOCK==undefined)
			get_real_stock.REAL_STOCK = 0;
		if((get_real_stock.REAL_STOCK*1) < document.getElementById('add_other_amount').value * 1)
		{
			sorun_var = 1;
			alert("Yetersiz Stok. Çıkış Lokasyonundaki Stok Miktarı : "+get_real_stock.REAL_STOCK);
			document.getElementById('add_other_amount').focus();
			return false;
		}
		else
		{
			real_amount = get_real_stock.REAL_STOCK
		}
	}
	function add_row()
	{
		amount = document.getElementById('add_other_amount').value;
		barcode = document.getElementById('add_other_barcod').value;
		add_amount();
		if (ekle == 0)
		{
			row_count++;
			document.getElementById('row_count').value = row_count;
			var newRow;
			var newCell;	
			newRow = document.getElementById("table1").insertRow(document.getElementById("table1").rows.length);
			newRow.className = 'color-list';
			newRow.setAttribute("name","frm_row" + row_count);
			newRow.setAttribute("id","frm_row" + row_count);		
			newRow.setAttribute("NAME","frm_row" + row_count);
			newRow.setAttribute("ID","frm_row" + row_count);		
			
			<!---newCell = newRow.insertCell(newRow.cells.length);
			newCell.setAttribute('nowrap','nowrap');
			newCell.innerHTML = '<a style="cursor:pointer" onclick="sil(' + row_count + ');" ><img src="/images/delete_list.gif" alt="<cf_get_lang_main no='51.Sil'>" border="0"></a>';--->
			
			newCell = newRow.insertCell(newRow.cells.length);
			newCell.setAttribute('nowrap','nowrap');
			newCell.innerHTML = '<a style="cursor:pointer" onclick="fiyat_gor(' + row_count + ');" ><img src="/images/promo.gif" alt="Fiyat" border="0"></a>';	
			
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input type="hidden" value="1" name="row_kontrol'+row_count+'"><input type="hidden" value="'+stockid+'" name="stockid'+row_count+'" id="stockid'+row_count+'" /><input type="text" value="'+barcode+'" name="barcod'+row_count+'" id="barcod'+row_count+'" size="13" class="boxtext" readonly="yes" />';
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input type="text" value="'+shelf_code+'" name="shelf_code'+row_count+'" id="shelf_code'+row_count+'" size="14" class="boxtext" readonly="yes" />';
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input type="text" style="text-align:right" value="'+amount+'" name="amount'+row_count+'" id="amount'+row_count+'" size="5" class="boxtext" readonly="yes" />';
				
		}
		else
		{
			ekle = 0;
		}
	}
	function add_amount()
	{
		if(row_count >0) /*ilk Satırdan sonrası*/
	  	{
		  	for(i=1;i<=row_count;i++)
		  	{
			  	if(document.getElementById('raf_durum').value > 0)<!---Seçilen Depoda Raf Varsa--->
			  	{
				  	if(document.getElementById('stockid'+i).value == stockid && document.getElementById('shelf_code'+i).value == shelf_code) /*Eğer Satırlarda Aynı Ürün Aynı Rafta İse Üstüne Eklenecek*/
				  	{
						<cfif attributes.sales_type eq 3> <!---Stok Hareketi Yapılacaksa Stok Kontrolü--->
							var stock_sql = "SELECT ISNULL(S.REAL_STOCK, 0) AS REAL_STOCK FROM GET_STOCK_LAST_SHELF AS S INNER JOIN <cfoutput>#dsn3_alias#</cfoutput>.PRODUCT_PLACE AS P ON S.SHELF_NUMBER = P.PRODUCT_PLACE_ID WHERE P.SHELF_CODE = '"+shelf_code+"' AND S.STOCK_ID ="+stockid;
							var get_real_stock = wrk_query(stock_sql,'dsn2');
							if(get_real_stock.REAL_STOCK==undefined)
								get_real_stock.REAL_STOCK = 0;
							if((get_real_stock.REAL_STOCK*1) < document.getElementById('amount'+i).value - (-1 * amount))
							{
								ekle=1;
								alert("Yetersiz Stok. Çıkış Lokasyonundaki Stok Miktarı : "+get_real_stock.REAL_STOCK);
								document.getElementById('add_other_amount').focus();
							}
							else
							{
								document.getElementById('amount'+i).value = document.getElementById('amount'+i).value - (-1 * amount);
								ekle=1;
							}
						<cfelse>
							document.getElementById('amount'+i).value = document.getElementById('amount'+i).value - (-1 * amount);
							ekle=1;
						</cfif>
				  	}
			  	}
			  	else
			  	{
					if(document.getElementById('stockid'+i).value == stockid)
				  	{
						<cfif attributes.sales_type eq 3> <!---Stok Hareketi Yapılacaksa Stok Kontrolü--->
							var stock_sql = "SELECT PRODUCT_STOCK FROM EZGI_GET_STOCK_LOCATION_TOTAL WHERE  DEPO = '"+document.getElementById('txt_department_in').value+"' AND STOCK_ID ="+stockid;
							var get_real_stock = wrk_query(stock_sql,'dsn2');
							if(get_real_stock.PRODUCT_STOCK==undefined)
							get_real_stock.PRODUCT_STOCK = 0;
							if((get_real_stock.PRODUCT_STOCK*1) < document.getElementById('amount'+i).value - (-1 * amount))
							{
								ekle=1;
								alert("Yetersiz Stok. Çıkış Lokasyonundaki Stok Miktarı : "+get_real_stock.PRODUCT_STOCK);
								document.getElementById('all_amount').value = document.getElementById('all_amount').value - (document.getElementById('add_other_amount').value*1);
								document.getElementById('add_other_amount').focus();
							}
							else
							{
								document.getElementById('amount'+i).value = document.getElementById('amount'+i).value - (-1 * amount);
								ekle=1;
							}
						<cfelse>
							document.getElementById('amount'+i).value = document.getElementById('amount'+i).value - (-1 * amount);
							ekle=1;
						</cfif>
				  	}
			  	}
		  	}
		}
		else
		{
			<cfif attributes.sales_type eq 3> <!---Stok Hareketi Yapılacaksa Stok Kontrolü--->
				if(document.getElementById('raf_durum').value > 0)<!---Seçilen Depoda Raf Varsa--->
				{
					var stock_sql_1 = "SELECT ISNULL(S.REAL_STOCK, 0) AS REAL_STOCK FROM GET_STOCK_LAST_SHELF AS S INNER JOIN <cfoutput>#dsn3_alias#</cfoutput>.PRODUCT_PLACE AS P ON S.SHELF_NUMBER = P.PRODUCT_PLACE_ID WHERE P.SHELF_CODE = '"+shelf_code+"' AND S.STOCK_ID ="+stockid;
					
					var get_real_stock_1 = wrk_query(stock_sql_1,'dsn2');
					if(get_real_stock_1.REAL_STOCK==undefined)
					get_real_stock_1.REAL_STOCK = 0;
					if((get_real_stock_1.REAL_STOCK*1) < (1*amount))
					{
						ekle=1;
						alert("Yetersiz Stok. Çıkış Lokasyonundaki Stok Miktarı : "+get_real_stock_1.REAL_STOCK);
						document.getElementById('add_other_amount').focus();
					}
				}
				else
				{
					var stock_sql_1 = "SELECT PRODUCT_STOCK FROM EZGI_GET_STOCK_LOCATION_TOTAL WHERE  DEPO = '"+document.getElementById('txt_department_in').value+"' AND STOCK_ID ="+stockid;
					var get_real_stock_1 = wrk_query(stock_sql_1,'dsn2');
					if(get_real_stock_1.PRODUCT_STOCK==undefined)
					get_real_stock_1.PRODUCT_STOCK = 0;
					if((get_real_stock_1.PRODUCT_STOCK*1) < (1*amount))
					{
						ekle=1;
						alert("Yetersiz Stok. Çıkış Lokasyonundaki Stok Miktarı : "+get_real_stock_1.PRODUCT_STOCK);
						document.getElementById('add_other_amount').focus();
					}
				}
			</cfif>
		}
	}
	function change_store(out_store)
	{
		if(document.getElementById('row_count').value >0)
		{
			alert('Satır Oluştuktan Sonra Depo Değişmez!');	
			return false;
		}
		else
		{
			department_ = list_getat(out_store,1,'-');
			location_ = list_getat(out_store,2,'-');
			<cfif attributes.sales_type eq 3> <!---Stok Hareketi Yapılacaksa Stok Kontrolü--->
				var get_store_type = "SELECT COUNT(*) AS RAF FROM PRODUCT_PLACE WHERE PLACE_STATUS = 1 AND LOCATION_ID ="+location_+" AND STORE_ID = "+department_;
				var get_raf = wrk_query(get_store_type,'dsn3');
				raf_durum = get_raf.RAF;
				if(raf_durum == 0)
				{
					document.getElementById('raf_durum').value = raf_durum;
					document.getElementById('barcode_durum').style.display='none';
				}
				else
				{
					document.getElementById('raf_durum').value = raf_durum;
					document.getElementById('barcode_durum').style.display='';
				}
			</cfif>
		}
	}
	function sil(sy)
	{
		var element=eval("add_order.row_kontrol"+sy);
		element.value=0;
		var element=eval("frm_row"+sy); 
		element.style.display="none";	
		document.getElementById('amount'+sy).value = 0;
		document.getElementById('stockid'+sy).value = '';
		document.getElementById('shelf_code'+sy).value ='';
	} 
	function fiyat_gor(sy)
	{
		fiyat_stockid = document.getElementById('stockid'+sy).value;
		fiyat_cat = document.getElementById('price_id').value;
		if(fiyat_cat == 0)
			var fiyat_sql = "SELECT DISTINCT PRICE_STANDART.PRICE, PRICE_STANDART.MONEY, PU.MAIN_UNIT FROM STOCKS AS S INNER JOIN PRODUCT_UNIT AS PU ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID AND S.PRODUCT_ID = PU.PRODUCT_ID INNER JOIN PRICE_STANDART ON S.PRODUCT_ID = PRICE_STANDART.PRODUCT_ID WHERE S.PRODUCT_STATUS = 1 AND S.STOCK_STATUS = 1 AND PU.MAIN_UNIT = PU.ADD_UNIT AND PRICE_STANDART.PURCHASESALES = 1 AND PRICE_STANDART.PRICESTANDART_STATUS = 1 AND S.STOCK_ID ="+fiyat_stockid;
		else
			var fiyat_sql = "SELECT DISTINCT PRICE.PRICE, PRICE.MONEY, PU.MAIN_UNIT FROM STOCKS AS S INNER JOIN PRODUCT_UNIT AS PU ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID AND S.PRODUCT_ID = PU.PRODUCT_ID INNER JOIN PRICE ON S.PRODUCT_ID = PRICE.PRODUCT_ID WHERE S.PRODUCT_STATUS = 1 AND S.STOCK_STATUS = 1 AND PU.MAIN_UNIT = PU.ADD_UNIT AND S.STOCK_ID = "+fiyat_stockid+" AND PRICE.PRICE_CATID = "+fiyat_cat+" AND PRICE.FINISHDATE IS NULL";
		var fiyat_gor = wrk_query(fiyat_sql,'dsn3');
		if(fiyat_gor.PRICE==undefined)
		{
			alert('Fiyat Bulunamadı!');
			return false;
		}
		fiyat = fiyat_gor.PRICE;
		alert(fiyat_gor.MAIN_UNIT+' Fiyatı : '+fiyat_gor.PRICE+' '+fiyat_gor.MONEY);
	}
	function main_page()
    {
    	document.getElementById('main_page').style.display='';
		document.getElementById('row_page').style.display='none';
		document.getElementById('total_page').style.display='none';
   	}
    function row_page()
    {
		if(document.getElementById('company_id').value == '')
		{
			alert('Müşteri Seçiniz!');	
			return false;
		}
		if(document.getElementById('price_id').value == '')
		{
			alert('Fiyat Listesi Seçiniz!');	
			return false;
		}
		document.getElementById('row_page').style.display='';
		document.getElementById('main_page').style.display='none';
		document.getElementById('total_page').style.display='none';
		
   	}
    function total_page()
    {
    	document.getElementById('total_page').style.display='';
		document.getElementById('main_page').style.display='none';
		document.getElementById('row_page').style.display='none';
   	}
	function add_control()
	{
		if(document.getElementById('row_count').value == '')
		{
			alert('Kaydedilecek Bilgi Bulunamadı!');
			return false;
		}
		if(add_order.txt_department_in.value == "")
		{
				alert('Çıkış Depo Seçmelisiniz.');
				return false;
		}
		if(add_order.txt_department_in.value.indexOf('-') == -1)
		{
			alert('Sevk Depo Seçmelisiniz.');
			return false;
		}
		sor=confirm('Fişteki Bilgileri Kayıt Ediyorsunuz');
		if(sor==true)
		{
			document.getElementById("add_order").action = "<cfoutput>#request.self#</cfoutput>?fuseaction=pda.emptypopup_add_ezgi_live_sale";
			document.getElementById("add_order").submit();

		}
		else
		return false;
	}
</script>
