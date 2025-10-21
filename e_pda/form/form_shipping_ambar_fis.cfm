<cfsetting showdebugoutput="no">
<style>
.header{
	display:none;
}
</style>
<cfquery name="get_shelf" datasource="#dsn3#">
	SELECT TOP (10) SHELF_CODE FROM PRODUCT_PLACE WHERE STORE_ID = #ListGetAt(attributes.department_out_id,1,'-')# AND LOCATION_ID = #ListGetAt(attributes.department_out_id,2,'-')#
</cfquery>
<cfquery name="get_shelf_all" datasource="#dsn3#">
	SELECT  SHELF_CODE FROM PRODUCT_PLACE WHERE STORE_ID = #ListGetAt(attributes.department_out_id,1,'-')# AND LOCATION_ID = #ListGetAt(attributes.department_out_id,2,'-')#
</cfquery>
<cfset shelf_code_list = ValueList(get_shelf_all.SHELF_CODE)>
<cfquery name="get_spool" datasource="#dsn3#">
 	SELECT STOCK_ID FROM EZGI_PDA_PRINT_SPOOL WHERE SHIP_ID = #attributes.ship_id# AND IS_TYPE = #attributes.is_type# AND RECORD_EMP = #session.ep.userid#
</cfquery>
<cfset spollist = ValueList(get_spool.STOCK_ID)>
<cfif attributes.is_type eq 1>
    <cfquery name="GET_SHIP_PACKAGE_LIST" datasource="#dsn3#">
        SELECT     
        	PAKET_SAYISI AS PAKETSAYISI, 
            PAKET_ID AS STOCK_ID, 
            BARCOD, 
            STOCK_CODE, 
            PRODUCT_CODE_2,
            PRODUCT_NAME,
         	ISNULL((
            SELECT        
            	SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
			FROM            
             	#dsn2_alias#.STOCK_FIS AS SF INNER JOIN
            	#dsn2_alias#.STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID
			WHERE        
              	SF.FIS_TYPE = 113 AND 
              	SF.REF_NO = '#attributes.DELIVER_PAPER_NO#' AND 
            	SFR.STOCK_ID = TBL.PAKET_ID
        	),0) AS CONTROL_AMOUNT
            <cfif get_shelf.recordcount>
            	,SHELF_CODE
            </cfif>
		FROM         
        	(
            SELECT
            	SUM(PAKET_SAYISI) AS PAKET_SAYISI,
                PAKET_ID, 
                BARCOD, 
                STOCK_CODE, 
                PRODUCT_NAME, 
				PRODUCT_CODE_2,
                PRODUCT_TREE_AMOUNT, 
                SHIP_RESULT_ID
                <cfif get_shelf.recordcount>
                	, 
                    	(
                    	SELECT        
                        	TOP (1) PP.SHELF_CODE
						FROM            
                        	PRODUCT_PLACE AS PP INNER JOIN
                         	PRODUCT_PLACE_ROWS AS PPR ON PP.PRODUCT_PLACE_ID = PPR.PRODUCT_PLACE_ID LEFT OUTER JOIN
                         	#dsn2_alias#.GET_STOCK_LAST_SHELF AS GS ON PPR.STOCK_ID = GS.STOCK_ID AND PPR.PRODUCT_PLACE_ID = GS.SHELF_NUMBER
						WHERE 
                        	--GS.REAL_STOCK > 0 AND 
                            PPR.STOCK_ID = TBL1.PAKET_ID AND  
                            PP.PLACE_STATUS = 1 AND     
                        	PP.STORE_ID = #ListGetAt(attributes.department_out_id,1,'-')# AND 
                            PP.LOCATION_ID = #ListGetAt(attributes.department_out_id,2,'-')#  
						ORDER BY 
                        	PP.SHELF_CODE
                    	) AS SHELF_CODE
                </cfif>
           	FROM
            	(     
                SELECT     
                    CASE 
                        WHEN 
                            S.PRODUCT_TREE_AMOUNT IS NOT NULL 
                        THEN 
                            S.PRODUCT_TREE_AMOUNT 
                        ELSE 
                            SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) 
                    END 
                        AS PAKET_SAYISI, 
                    EPS.PAKET_ID, 
                    S.BARCOD, 
                    S.STOCK_CODE, 
                    S.PRODUCT_NAME, 
					S.PRODUCT_CODE_2,
                    S.PRODUCT_TREE_AMOUNT, 
                    ESR.SHIP_RESULT_ID,
                    ESRR.ORDER_ROW_ID
                FROM          
                    EZGI_SHIP_RESULT AS ESR INNER JOIN
                    EZGI_SHIP_RESULT_ROW AS ESRR ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                    ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                    EZGI_PAKET_SAYISI AS EPS ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
                    STOCKS AS S ON EPS.PAKET_ID = S.STOCK_ID
                WHERE      
                    ESR.SHIP_RESULT_ID = #attributes.ship_id#
                GROUP BY 
                    EPS.PAKET_ID, 
                    S.BARCOD, 
                    S.STOCK_CODE, 
                    S.PRODUCT_NAME, 
					S.PRODUCT_CODE_2,
                    S.PRODUCT_TREE_AMOUNT, 
                    ESR.SHIP_RESULT_ID,
                    ESRR.ORDER_ROW_ID
             	) AS TBL1
          	GROUP BY
            	PAKET_ID, 
                BARCOD, 
                STOCK_CODE, 
				PRODUCT_CODE_2,
                PRODUCT_NAME, 
                PRODUCT_TREE_AMOUNT, 



                SHIP_RESULT_ID
        	) AS TBL
       	ORDER BY
		   CONTROL_AMOUNT,
     		<cfif get_shelf.recordcount>
            	SHELF_CODE,
                STOCK_CODE
            <cfelse>
            	STOCK_CODE
            </cfif>
			,PAKET_SAYISI
			
  	</cfquery>
<cfelse>
   	<cfquery name="GET_SHIP_PACKAGE_LIST" datasource="#dsn3#">
        SELECT     
        	PAKET_SAYISI AS PAKETSAYISI, 
            PAKET_ID AS STOCK_ID, 
            BARCOD, 
            STOCK_CODE, 
            PRODUCT_NAME,
            ISNULL((
            SELECT        
            	SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
			FROM            
             	#dsn2_alias#.STOCK_FIS AS SF INNER JOIN
            	#dsn2_alias#.STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID
			WHERE        
              	SF.FIS_TYPE = 113 AND 
              	SF.REF_NO = '#attributes.DELIVER_PAPER_NO#' AND 
            	SFR.STOCK_ID = TBL.PAKET_ID
          	),0) AS CONTROL_AMOUNT, 
            SHIP_RESULT_ID
            <cfif get_shelf.recordcount>
            	,SHELF_CODE
            </cfif>
		FROM         
        	(
            SELECT     
            	SUM(PAKET_SAYISI) AS PAKET_SAYISI, 
                PAKET_ID, 
                BARCOD, 
                STOCK_CODE, 
                PRODUCT_NAME, 
                PRODUCT_TREE_AMOUNT, 
                SHIP_RESULT_ID
                <cfif get_shelf.recordcount>
                	, 
                    	(
                    	SELECT        
                        	TOP (1) PP.SHELF_CODE
						FROM            
                        	PRODUCT_PLACE AS PP INNER JOIN
                         	PRODUCT_PLACE_ROWS AS PPR ON PP.PRODUCT_PLACE_ID = PPR.PRODUCT_PLACE_ID LEFT OUTER JOIN
                         	#dsn2_alias#.GET_STOCK_LAST_SHELF AS GS ON PPR.STOCK_ID = GS.STOCK_ID AND PPR.PRODUCT_PLACE_ID = GS.SHELF_NUMBER
						WHERE 
                        	--GS.REAL_STOCK > 0 AND 
                            PPR.STOCK_ID = TBL1.PAKET_ID AND  
                            PP.PLACE_STATUS = 1 AND     
                        	PP.STORE_ID = #ListGetAt(attributes.department_out_id,1,'-')# AND 
                            PP.LOCATION_ID = #ListGetAt(attributes.department_out_id,2,'-')#  
						ORDER BY 
                        	PP.SHELF_CODE
                    	) AS SHELF_CODE
                </cfif>
       		FROM          
            	(
                SELECT     
                	CASE 
                    	WHEN 
                        	S.PRODUCT_TREE_AMOUNT IS NOT NULL 
                      	THEN 
                        	S.PRODUCT_TREE_AMOUNT 
                      	ELSE 
                        	SUM(SIR.AMOUNT * EPS.PAKET_SAYISI) 
              		END 
                    	AS PAKET_SAYISI, 
                 	EPS.PAKET_ID, 
                    S.BARCOD, 
                    S.STOCK_CODE, 
                    S.PRODUCT_NAME, 
                    S.PRODUCT_TREE_AMOUNT, 
                    SIR.SHIP_ROW_ID, 
                    SI.DISPATCH_SHIP_ID AS SHIP_RESULT_ID
         		FROM          
                	STOCKS AS S INNER JOIN
                    EZGI_PAKET_SAYISI AS EPS ON S.STOCK_ID = EPS.PAKET_ID INNER JOIN
                    #dsn2_alias#.SHIP_INTERNAL_ROW AS SIR INNER JOIN
                    #dsn2_alias#.SHIP_INTERNAL AS SI ON SIR.DISPATCH_SHIP_ID = SI.DISPATCH_SHIP_ID ON EPS.MODUL_ID = SIR.STOCK_ID
           		WHERE      
                	SI.DISPATCH_SHIP_ID = #attributes.ship_id#
             	GROUP BY 
                	EPS.PAKET_ID, 
                    S.BARCOD, 
                    S.STOCK_CODE, 
                    S.PRODUCT_NAME, 
                    S.PRODUCT_TREE_AMOUNT, 
                    SIR.SHIP_ROW_ID, 
                    SI.DISPATCH_SHIP_ID
           		) AS TBL1
         	GROUP BY 
            	PAKET_ID, 
                BARCOD, 
                STOCK_CODE, 
                PRODUCT_NAME, 
                PRODUCT_TREE_AMOUNT, 
                SHIP_RESULT_ID
       		) AS TBL
     	ORDER BY
		 CONTROL_AMOUNT,
     		<cfif get_shelf.recordcount>

            	SHELF_CODE,
                STOCK_CODE
            <cfelse>
            	STOCK_CODE
            </cfif>
			
    </cfquery>
	
</cfif> 

<cfset BASLIK="">
<cfif attributes.is_type eq 1>
	<cfset BASLIK="Sevk Plan No :">
<cfelse>
	<cfset BASLIK="Sevk Talep No :">
</cfif>
<cfset adres = "pda.list_shipping_ambar&date1=#date1#&date2=#date2#&department_in_id=#attributes.department_in_id#&department_out_id=#attributes.department_out_id#&keyword=#attributes.keyword#&is_form_submitted=1">
<cf_box title="#BASLIK# #attributes.DELIVER_PAPER_NO#">
<form name="add_fis" method="post" action="<cfoutput>#request.self#?fuseaction=#adres#</cfoutput>">
	<cf_grid_list>
	<thead>
		<tr>			
			<th>
<cfif get_shelf.recordcount>
                    Raf Kodu
                <cfelse>
                	Barkod
                </cfif>
			</th>
			<th>Stok Kodu</th>
			<th>Stok Adı</th>
			<th>Miktar</th>
			<th>OK</th>
			<th><input type="checkbox" alt="<cf_get_lang no ='546.Hepsini Seç'>" onClick="grupla(-1);"></th>
		</tr>
		</thead>

		<tbody>
			<cfoutput query="GET_SHIP_PACKAGE_LIST">
           	 	<tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row"
				<cfif get_shelf.recordcount and len(SHELF_CODE) neq 0>
					<cfif listFindNoCase(shelf_code_list,SHELF_CODE) eq 0> style="display:none;"  </cfif>

				</cfif>
				>
                	<td>
						<cfif get_shelf.recordcount>	
                            #SHELF_CODE#	
                        <cfelse>     
                            #BARCOD#
                        </cfif>
                    </td>
					<td>#PRODUCT_CODE_2#</td>
                    <td >
                        <cfif (get_shelf.recordcount and len(SHELF_CODE)) or (not get_shelf.recordcount and len(BARCOD))>
                            <a href="#request.self#?fuseaction=pda.form_shipping_ambar_stock&ship_id=#attributes.ship_id#&f_stock_id=#stock_id#&department_in_id=#attributes.department_in_id#&department_out_id=#attributes.department_out_id#&date1=#attributes.date1#&date2=#attributes.date2#&product_name=#PRODUCT_NAME#&is_type=#attributes.is_type#&deliver_paper_no=#attributes.DELIVER_PAPER_NO#&keyword=#attributes.keyword#&paket_sayisi=#PAKETSAYISI#" class="tableyazi">
                                #PRODUCT_NAME#
                            </a>
                    	<cfelse>
                    		#PRODUCT_NAME#
                    	</cfif>
               	 	</td>
                	<td style="text-align:right;color:FF0000;"><a href="#request.self#?fuseaction=pda.Stock_location_partner&isSubmit=1&barcode=#BARCOD#" class="tableyazi">#PAKETSAYISI#</a></td>
                	<td align="center">
						<cfif PAKETSAYISI eq 0>
                        	<img src="/images/plus_ques.gif" border="0" title="Barkod Yok.">
                    	<cfelseif PAKETSAYISI - CONTROL_AMOUNT eq 0>
                      		<a href="#request.self#?fuseaction=pda.emptypopup_ezgi_print_spool&ship_id=#attributes.ship_id#&stock_id_list=#stock_id#&department_in_id=#attributes.department_in_id#&department_out_id=#attributes.department_out_id#&date1=#attributes.date1#&date2=#attributes.date2#&product_name=#PRODUCT_NAME#&is_type=#attributes.is_type#&deliver_paper_no=#attributes.DELIVER_PAPER_NO#&keyword=#attributes.keyword#&paket_sayisi=#PAKETSAYISI#">
                                <img src="/images/c_ok.gif" border="0" title="Sevk Edildi">
                            </a>
                        <cfelseif CONTROL_AMOUNT eq 0>
                            <img src="/images/caution_small.gif" border="0" title="Sevk Edilmedi">
                        <cfelseif PAKETSAYISI gt CONTROL_AMOUNT>
                            <img src="/images/warning.gif" border="0" title="Eksik Sevkiyat">
                        <cfelseif PAKETSAYISI lt CONTROL_AMOUNT>
                            <img src="/images/control.gif" border="0" title="Fazla Sevkiyat">   
                        </cfif>
                	</td> 
                	<td align="center">
                		<input type="checkbox" name="select_production" value="#STOCK_ID#_#CONTROL_AMOUNT#" <cfif ListFind(spollist,STOCK_ID)>checked</cfif>>
                	</td>      
            	</tr>
        	</cfoutput>
		</tbody>
		<tfoot>
			<tr class="color-list" height="20">
				<td colspan="2"><input class=" ui-wrk-btn ui-wrk-btn-red" type="submit" value="Geri" name="1"></td>
				<td colspan="3" height="20px" align="right"><input type="button" class="ui-wrk-btn ui-wrk-btn-extra" value="Yazıcı Havuzuna Gönder" name="print_button" onclick="grupla(-2);" /></td>
			</tr>
	</cf_grid_list>
</form>
</cf_box>
<script language="javascript">
$(document).ready(function(){
	$(".header").hide()
})
	function grupla(type)
	{//type sadece -1 olarak gelir,-1 geliyorsa hepsini seç demektir.
		stock_id_list = '';
		chck_leng = document.getElementsByName('select_production').length;
		for(ci=0;ci<chck_leng;ci++)
		{
			var my_objets = document.all.select_production[ci];
			if(chck_leng == 1)
				var my_objets =document.all.select_production;
			if(type == -1){//hepsini seç denilmişse	
				if(my_objets.checked == true)
					my_objets.checked = false;
				else
					my_objets.checked = true;
			}
			else
			{
				if(my_objets.checked == true)
					stock_id_list +=my_objets.value+',';
			}
		}
		stock_id_list = stock_id_list.substr(0,stock_id_list.length-1);//sondaki virgülden kurtarıyoruz.
		if(list_len(stock_id_list,','))
		{

			var answer1 = confirm("Seçtiğiniz Satırları Yazıcı Havuzuna Gönderiyorsunuz")
			if (answer1)
			{
			window.location ='<cfoutput>#request.self#?fuseaction=pda.emptypopup_ezgi_print_spool&ship_id=#attributes.ship_id#&department_in_id=#attributes.department_in_id#&department_out_id=#attributes.department_out_id#&date1=#attributes.date1#&date2=#attributes.date2#&is_type=#attributes.is_type#&deliver_paper_no=#attributes.DELIVER_PAPER_NO#&keyword=#attributes.keyword#</cfoutput>&stock_id_list='+stock_id_list;
			}
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
<cfabort>
<cfset adres = "pda.list_shipping_ambar&date1=#date1#&date2=#date2#&department_in_id=#attributes.department_in_id#&department_out_id=#attributes.department_out_id#&keyword=#attributes.keyword#&is_form_submitted=1">
<div style="width:290px">
	<table cellpadding="2" cellspacing="1" align="left" class="color-border" width="100%">
    	<form name="add_fis" method="post" action="<cfoutput>#request.self#?fuseaction=#adres#</cfoutput>">
        	<tr class="color-list">
            	<td colspan="5">
            		<table width="99%" height="29" cellpadding="0" cellspacing="0">
                		<tr>
                    		<td> <cfif attributes.is_type eq 1><b>Sevk Plan No :</b><cfelse><b>Sevk Talep No :</b></cfif><cfoutput>#attributes.DELIVER_PAPER_NO#</cfoutput></b></td>
                    		<td><input type="submit" value="Geri" name="1"></td>
                		</tr>
            		</table>
            	</td>
        	</tr>
        	<tr class="color-list" height="20">
				<cfif get_shelf.recordcount>
                    <td width="45"> Raf Kodu</td>
                <cfelse>
                	<td width="50">Barkod</td>
                </cfif>
            	<td>Stok Adı</td>
            	<td width="30">Miktar</td>
            	<td width="15">OK</td>     
            	<td width="15"><input type="checkbox" alt="<cf_get_lang no ='546.Hepsini Seç'>" onClick="grupla(-1);"></td>                              
        	</tr>
        	<cfoutput query="GET_SHIP_PACKAGE_LIST">
           	 	<tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
                	<td>
						<cfif get_shelf.recordcount>	
                            #SHELF_CODE#	
                        <cfelse>     
                            #BARCOD#
                        </cfif>
                    </td>
                    <td >
                        <cfif (get_shelf.recordcount and len(SHELF_CODE)) or (not get_shelf.recordcount and len(BARCOD))>
                            <a href="#request.self#?fuseaction=pda.form_shipping_ambar_stock&ship_id=#attributes.ship_id#&f_stock_id=#stock_id#&department_in_id=#attributes.department_in_id#&department_out_id=#attributes.department_out_id#&date1=#attributes.date1#&date2=#attributes.date2#&product_name=#PRODUCT_NAME#&is_type=#attributes.is_type#&deliver_paper_no=#attributes.DELIVER_PAPER_NO#&keyword=#attributes.keyword#&paket_sayisi=#PAKETSAYISI#" class="tableyazi">
                                #PRODUCT_NAME#
                            </a>
                    	<cfelse>
                    		#PRODUCT_NAME#
                    	</cfif>
               	 	</td>
                	<td style="text-align:right;color:FF0000;"><a href="#request.self#?fuseaction=pda.Stock_location_partner&isSubmit=1&barcode=#BARCOD#" class="tableyazi">#PAKETSAYISI#</a></td>
                	<td align="center">
						<cfif PAKETSAYISI eq 0>
                        	<img src="/images/plus_ques.gif" border="0" title="Barkod Yok.">
                    	<cfelseif PAKETSAYISI - CONTROL_AMOUNT eq 0>
                      		<a href="#request.self#?fuseaction=pda.emptypopup_ezgi_print_spool&ship_id=#attributes.ship_id#&stock_id_list=#stock_id#&department_in_id=#attributes.department_in_id#&department_out_id=#attributes.department_out_id#&date1=#attributes.date1#&date2=#attributes.date2#&product_name=#PRODUCT_NAME#&is_type=#attributes.is_type#&deliver_paper_no=#attributes.DELIVER_PAPER_NO#&keyword=#attributes.keyword#&paket_sayisi=#PAKETSAYISI#">
                                <img src="/images/c_ok.gif" border="0" title="Sevk Edildi">
                            </a>
                        <cfelseif CONTROL_AMOUNT eq 0>
                            <img src="/images/caution_small.gif" border="0" title="Sevk Edilmedi">
                        <cfelseif PAKETSAYISI gt CONTROL_AMOUNT>
                            <img src="/images/warning.gif" border="0" title="Eksik Sevkiyat">
                        <cfelseif PAKETSAYISI lt CONTROL_AMOUNT>
                            <img src="/images/control.gif" border="0" title="Fazla Sevkiyat">   
                        </cfif>
                	</td> 
                	<td align="center">
                		<input type="checkbox" name="select_production" value="#STOCK_ID#_#CONTROL_AMOUNT#" <cfif ListFind(spollist,STOCK_ID)>checked</cfif>>
                	</td>      
            	</tr>
        	</cfoutput>
        	<tr class="color-list" height="20">
        		<td colspan="5" height="20px" align="right"><input type="button" value="Yazıcı Havuzuna Gönder" name="print_button" onclick="grupla(-2);" /></td>
        	</tr>
    	</form>
	</table>
</div>
