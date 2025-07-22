<cfset default_process_type = 113> <!---Dikkat Firmaya Göre Değişebilir--->
<cfparam name="attributes.department_in_id" default="">
<cfparam name="attributes.department_out_id" default="">
<cfquery name="get_process_cat" datasource="#DSN3#">
	SELECT TOP (1)    
    	SPC.PROCESS_CAT_ID
	FROM         
    	SETUP_PROCESS_CAT AS SPC INNER JOIN
      	SETUP_PROCESS_CAT_FUSENAME AS SPCF ON SPC.PROCESS_CAT_ID = SPCF.PROCESS_CAT_ID INNER JOIN
    	SETUP_PROCESS_CAT_ROWS AS SPCR ON SPC.PROCESS_CAT_ID = SPCR.PROCESS_CAT_ID
	WHERE     
    	SPC.PROCESS_TYPE = #default_process_type# AND 
        SPCF.FUSE_NAME = 'pda.form_shipping_ambar_stock' 
  	ORDER BY
    	SPC.PROCESS_CAT_ID DESC      
</cfquery>
<cfif not get_process_cat.recordcount>
	<script type="text/javascript">
		alert("İşlem Kategorisi Tanımlayınız!");
		history.back();	
	</script>
</cfif>
<cfquery name="get_stock_info" datasource="#dsn3#">
	SELECT        
    	SB.STOCK_ID, 
        SB.BARCODE, 
        S.PRODUCT_NAME, 
        S.STOCK_CODE, 
        S.STOCK_CODE_2
	FROM            
    	STOCKS_BARCODES AS SB INNER JOIN
       	STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID
	WHERE        
    	SB.STOCK_ID = #f_stock_id#
</cfquery>
<cfquery name="get_store_type" datasource="#dsn3#">
	SELECT        
    	COUNT(*) AS RAF
	FROM            
    	PRODUCT_PLACE
	WHERE        
    	LOCATION_ID = #ListGetAt(attributes.department_out_id,2,"-")#  AND 
        STORE_ID = #ListGetAt(attributes.department_in_id,1,"-")# AND 
        PLACE_STATUS = 1
</cfquery>
<cfif get_store_type.raf gt 0>
    <cfquery name="get_ambar_fis" datasource="#dsn2#">
        SELECT        
            SUM(SFR.AMOUNT) AS AMOUNT, 
            PP.SHELF_CODE, 
            S.STOCK_CODE, 
            S.PRODUCT_ID, 
            S.PROPERTY, 
            S.BARCOD, 
            S.PRODUCT_NAME,
            SFR.STOCK_ID
        FROM            
            STOCK_FIS AS SF INNER JOIN
            STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
            #dsn3_alias#.PRODUCT_PLACE AS PP ON SFR.SHELF_NUMBER = PP.PRODUCT_PLACE_ID INNER JOIN
            #dsn3_alias#.STOCKS AS S ON SFR.STOCK_ID = S.STOCK_ID
        WHERE        
            SF.REF_NO = '#attributes.deliver_paper_no#' AND 
            SFR.STOCK_ID = #f_stock_id#
        GROUP BY 
            PP.SHELF_CODE, 
            S.STOCK_CODE, 
            S.PRODUCT_ID, 
            S.PROPERTY, 
            S.BARCOD, 
            S.PRODUCT_NAME,
            SFR.STOCK_ID
    </cfquery>
    <cfquery name="get_shelf_stock" datasource="#dsn2#">
        SELECT        
            PP.SHELF_CODE, 
            PPR.AMOUNT, 
            PP.PRODUCT_PLACE_ID, 
            ISNULL((
                    SELECT        
                        REAL_STOCK
                    FROM            
                        GET_STOCK_LAST_SHELF
                    WHERE        
                        SHELF_NUMBER = PP.PRODUCT_PLACE_ID AND 
                        STOCK_ID = PPR.STOCK_ID
            ), 0) AS REAL_STOCK
        FROM            
            #dsn3_alias#.PRODUCT_PLACE AS PP LEFT OUTER JOIN
            #dsn3_alias#.PRODUCT_PLACE_ROWS AS PPR ON PP.PRODUCT_PLACE_ID = PPR.PRODUCT_PLACE_ID
        WHERE        
            PPR.STOCK_ID = #f_stock_id#
        ORDER BY
            PP.SHELF_CODE ASC
    </cfquery>
<cfelse>

	<cfquery name="get_ambar_fis" datasource="#dsn2#">
		SELECT        
        	SUM(SFR.AMOUNT) AS AMOUNT, 
            S.STOCK_CODE, 
            S.PRODUCT_ID, 
            S.PROPERTY, 
            S.BARCOD, 
            S.PRODUCT_NAME, 
            SFR.STOCK_ID
		FROM            
        	STOCK_FIS AS SF INNER JOIN
         	STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
          	#dsn3_alias#.STOCKS AS S ON SFR.STOCK_ID = S.STOCK_ID
		WHERE 
        	SF.REF_NO = '#attributes.deliver_paper_no#' AND 
            SFR.STOCK_ID = #f_stock_id# AND 
            SF.DEPARTMENT_OUT = #ListGetAt(attributes.department_out_id,1,"-")#  AND 
            SF.LOCATION_OUT = #ListGetAt(attributes.department_out_id,2,"-")# 
		GROUP BY 
        	S.STOCK_CODE, 
            S.PRODUCT_ID, 
            S.PROPERTY, 
            S.BARCOD, 
            S.PRODUCT_NAME, 
            SFR.STOCK_ID
   	</cfquery>
    <cfquery name="get_depo_stok" datasource="#dsn2#">
    	SELECT 
        	PRODUCT_STOCK 
       	FROM 
        	EZGI_GET_STOCK_LOCATION_TOTAL 
       	WHERE  
        	DEPO = '#attributes.department_out_id#' AND 
            STOCK_ID =#f_stock_id#
    </cfquery>
    
</cfif>
<cfquery name="get_ambar_fis_group" datasource="#dsn2#">
		SELECT        
        	SUM(SFR.AMOUNT) AS AMOUNT
		FROM            
        	STOCK_FIS AS SF INNER JOIN
         	STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID
		WHERE 
        	SF.REF_NO = '#attributes.deliver_paper_no#' AND 
            SFR.STOCK_ID = #f_stock_id#
</cfquery>
<cfif get_ambar_fis_group.recordcount>
	<cfset all_amount = get_ambar_fis_group.amount>
<cfelse>
	<cfset all_amount = 0>
</cfif>

<div class="row">
	<div class="col col-md-2 col-sm-12 col-xs-12">
		
<cfform name="form_basket">
  <cfinput id="txt_department_out" name="txt_department_out" type="hidden" value="#attributes.department_out_id#">
  <cfinput id="txt_department_in" name="txt_department_in" type="hidden" value="#attributes.department_in_id#">
  <cfinput id="process_cat_id" type="hidden" name="process_cat_id" value="#get_process_cat.process_cat_id#">
 <div style="display:flex">
  <div class="form-group">
	<label for="miktar">Miktar</label>
	<input type="text" class="moneybox" name="miktar" id="miktar" value="1" readonly>
  </div>
  <div class="form-group">
	<label for="txt_shelf_number">Raf Numarası</label>
	<input type="text" class="moneybox" name="txt_shelf_number" id="txt_shelf_number" value="" placeholder="Raf Numarası">
  </div>
  <div class="form-group">
	<label for="serial_number">Seri Numarası</label>
	<input type="text" name="serial_number" id="serial_number" class="moneybox" placeholder="Seri Numarası">
  </div>
  </div>
</cfform>
</div></div>
<script>
	$(document).ready(function(){
	$(".header").hide()
})
document.onkeydown = checkKeycode
	function checkKeycode(e) 
	{
		var keycode;
		if (window.event) keycode = window.event.keyCode;
		else if (e) keycode = e.which;
		if (keycode == 13)
		{
			console.log('Enter tuşuna basıldı');
			e.preventDefault(); // Enter tuşunun formu göndermesini engelle
		}
	}
</script>


<script>
    function wrk_query(str_query,data_source,maxrows)
{
	/*console.log(str_query);
	alert('Bu sayfada wrk_query kullanılmıştır. İlgili kontrolü ajax yapısına çeviriniz.');
	return false;
	*/
	/*
	by  Workcube
	Created 20060315
	Modified 20060324
	Usage:
		my_query = query('SELECT COL1,COL2 FROM TABLE1 WHERE COL2=1');
		veya
		my_query = query('SELECT COL1,COL2 FROM TABLE1 WHERE COL2=1','dsn2');
		veya
		my_query = query('SELECT COL1,COL2 FROM TABLE1 WHERE COL2=1 ORDER BY COL2 DESC','dsn2',1);
		ifadesi ile my_query degiskeni cfquery ile donen sonucun tamamen aynisi bir javascript query degeri alir
		data_source : optional , default olarak 'dsn' kullaniliyor
		maxrows : optional , default olarak 0 ataniyor, 0 olunca query sonucundaki tum kayitlar gelir
	*/
	
	var new_query=new Object();
	var req;
	if(!data_source) data_source='dsn';
	if(!maxrows) maxrows=0;
	function callpage(url) {
		req = false;
		if(window.XMLHttpRequest)
			try
				{req = new XMLHttpRequest();}
			catch(e)
				{req = false;}
		else if(window.ActiveXObject)
			try {
				req = new ActiveXObject("Msxml2.XMLHTTP");
				}
			catch(e)
				{
				try {req = new ActiveXObject("Microsoft.XMLHTTP");}
				catch(e)
					{req = false;}
				}
		if(req)
			{
				function return_function_()
				{

				if (req.readyState == 4 && req.status == 200)
					try
						{
							eval(req.responseText.replace(/\u200B/g,''));
							new_query = get_js_query; //alert('Cevap:\n\n'+req.responseText);//
						}
					catch(e)
						{new_query = false;}
				}
			req.open("post", url+'&xmlhttp=1', false);
			req.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
			req.setRequestHeader('pragma','nocache');
			if(encodeURI(str_query).indexOf('+') == -1) // + isareti encodeURI fonksiyonundan gecmedigi icin encodeURIComponent fonksiyonunu kullaniyoruz. EY 20120125
				req.send('str_sql='+encodeURI(str_query)+'&data_source='+data_source+'&maxrows='+maxrows);
			else
				req.send('str_sql='+encodeURIComponent(str_query)+'&data_source='+data_source+'&maxrows='+maxrows);
			return_function_();
			}
		
	}
	
	//TolgaS 20070124 objects yetkisi olmayan partnerlar var diye fuseaction objects2 yapildi
	callpage('/index.cfm?fuseaction=objects2.emptypopup_get_js_query&isAjax=1');
	//alert(new_query);
	
	return new_query;
}
</script>