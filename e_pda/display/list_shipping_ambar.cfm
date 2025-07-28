DASDAS<style>
    .header{
        display:none;
    }
</style>
<cfsetting showdebugoutput="no">
<cfset default_process_type = 113> <!---Dikkat Firmaya Göre Değişebilir--->
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.kontrol_status" default="1">
<cfparam name="attributes.DELIVER_PAPER_NO" default="">
<cfparam name="attributes.IS_TYPE" default="">
<cfquery name="get_default_departments" datasource="#dsn#">
	SELECT        
    	DEFAULT_RF_TO_SV_DEP, 
        DEFAULT_RF_TO_SV_LOC
	FROM            
    	EZGI_PDA_DEPARTMENT_DEFAULTS
	WHERE        
    	EPLOYEE_ID = #session.ep.userid#
</cfquery>
<cfset default_departments = '#get_default_departments.DEFAULT_RF_TO_SV_DEP#'> 
<cfparam name="attributes.department_in_id" default="#ListGetAt(get_default_departments.DEFAULT_RF_TO_SV_DEP,2)#-#ListGetAt(get_default_departments.DEFAULT_RF_TO_SV_LOC,2)#">
<cfparam name="attributes.department_out_id" default="#ListGetAt(get_default_departments.DEFAULT_RF_TO_SV_DEP,1)#-#ListGetAt(get_default_departments.DEFAULT_RF_TO_SV_LOC,1)#">
<cfquery name="GET_ALL_LOCATION" datasource="#DSN#">
	SELECT 
		D.DEPARTMENT_HEAD,
		SL.DEPARTMENT_ID,
		SL.LOCATION_ID,
		SL.STATUS,
		SL.COMMENT
	FROM 
		STOCKS_LOCATION SL,
		DEPARTMENT D,
		BRANCH B
	WHERE
		D.DEPARTMENT_ID IN (#default_departments#) AND
		SL.DEPARTMENT_ID = D.DEPARTMENT_ID AND
		SL.STATUS = 1 AND
		D.BRANCH_ID = B.BRANCH_ID
</cfquery>
<cfquery name="get_process_cat" datasource="#DSN3#">
	SELECT TOP (1)    
    	SPC.PROCESS_CAT_ID
	FROM         
    	SETUP_PROCESS_CAT AS SPC INNER JOIN
      	SETUP_PROCESS_CAT_FUSENAME AS SPCF ON SPC.PROCESS_CAT_ID = SPCF.PROCESS_CAT_ID INNER JOIN
    	SETUP_PROCESS_CAT_ROWS AS SPCR ON SPC.PROCESS_CAT_ID = SPCR.PROCESS_CAT_ID
	WHERE     
    	SPC.PROCESS_TYPE = #default_process_type# AND 
        SPCF.FUSE_NAME = 'pda.form_add_ambar_fis' 
  	ORDER BY
    	SPC.PROCESS_CAT_ID DESC      
</cfquery>
<cfif not get_process_cat.recordcount>
	<script type="text/javascript">
		alert("İşlem Kategorisi Tanımlayınız!");
		history.back();	
	</script>
</cfif>

<cfif isdefined("attributes.date2") and isdate(attributes.date2)>
  <cf_date tarih="attributes.date2">
  <cfelse>
  <cfset attributes.date2 = wrk_get_today()>
</cfif>
<cfif isdefined("attributes.date1") and isdate(attributes.date1)>
  <cf_date tarih="attributes.date1">
  <cfelse>
  <cfset attributes.date1 = wrk_get_today()>
</cfif>

<cfif isdefined("attributes.is_form_submitted")>
  <cfinclude template="../query/get_shipping_ambar.cfm">
  <cfelse>
  <cfset get_sevk_fis.recordcount = 0>
</cfif>

<cf_box title="Sevkiyat Listesi">
<cfform name="frm_search" method="post" action="#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_shipping_ambar">
  <input type="hidden" name="is_form_submitted" value="1">
  <table class="table">
    <tr>
        <td>
            <div class="form-group">
                <input type="text" name="keyword" style="width:70px" id="keyword" value="<cfoutput>#attributes.keyword#</cfoutput>">
            </div>
        </td>
        <td>
            <div class="form-group">
                
                    <cfsavecontent variable="message">Tarih girmelisiniz</cfsavecontent>
                        <cfinput type="text" maxlength="10" name="date1" value="#dateformat(attributes.date1,'dd/mm/yyyy')#" validate="eurodate" message="#message#" style="width:70px;">
                
            </div>
        </td>
        <td>
            <div class="form-group">
                <cfsavecontent variable="message">Tarih girmelisiniz</cfsavecontent>
                        <cfinput type="text" maxlength="10" name="date2" value="#dateformat(attributes.date2,'dd/mm/yyyy')#" validate="eurodate" message="#message#" style="width:70px;">
            </div>
        </td>
    </tr>
    <tr>
        <td>
            Çıkış Depo
        </td>
        <td>
            Giriş Depo
        </td>
        <td rowspan="2">
                <input class=" ui-wrk-btn ui-wrk-btn-success" type="submit" style="width:40px" value="Ara" />
            </td>
    </tr>
    <tr>
        <td>
            <div class="form-group">
                <select name="department_out_id" style="width:110px; height:20px">
         	 	<cfoutput query="get_all_location" group="department_id">
            		<option disabled="disabled" value="#department_id#">#department_head#</option>
					<cfoutput>
                    <option value="#department_id#-#location_id#" <cfif department_id is #ListFirst(attributes.department_out_id,'-')# and location_id is #ListLast(attributes.department_out_id,'-')#>selected="selected"</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#</option>
                    </cfoutput> 
				</cfoutput>
        	</select>
            </div>
        </td>
        <td>
            <div class="form-group">
                <select name="department_in_id" style="width:110px; height:20px">
         	 	<cfoutput query="get_all_location" group="department_id">
            		<option disabled="disabled" value="#department_id#">#department_head#</option>
					<cfoutput>
                    <option value="#department_id#-#location_id#" <cfif department_id is #ListFirst(attributes.department_in_id,'-')# and location_id is #ListLast(attributes.department_in_id,'-')#>selected="selected"</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#</option>
                    </cfoutput> 
				</cfoutput>
        	</select>
            </div>
        </td>
        
    </tr>
  </table>
</cfform>
</cf_box>



<div style="width:290px">
<cfform name="frm_search" method="post" action="#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_shipping_ambar">
  <input type="hidden" name="is_form_submitted" value="1">
  <table width="100%">
    <tr>
      <td colspan="3" class="headbold" height="20"><b>Sevkiyat Listesi</b></td>
    </tr>
    <tr>
    	<td colspan="3">
        	<table width="100%">
            	<tr height="20px">
                    <td align="80px">
                        
                    </td>
                    <td width="40px">Tarih</td>
                    <td>
                        <cfsavecontent variable="message">Tarih girmelisiniz</cfsavecontent>
                        <cfinput type="text" maxlength="10" name="date1" value="#dateformat(attributes.date1,'dd/mm/yyyy')#" validate="eurodate" message="#message#" style="width:70px;">
                    </td>
                    <td>
                        <cfsavecontent variable="message">Tarih girmelisiniz</cfsavecontent>
                        <cfinput type="text" maxlength="10" name="date2" value="#dateformat(attributes.date2,'dd/mm/yyyy')#" validate="eurodate" message="#message#" style="width:70px;">
                    </td>
               	</tr>
          	</table>
        </td>
    </tr>
    <tr class="color-header" height="15px">
    	<td class="form-title">Çıkış Depo</td>
        <td class="form-title">Giriş Depo</td>
        <td class="form-title">&nbsp;</td>
   	</tr>
    <tr height="20px">
    	<td>
        	<select name="department_out_id" style="width:110px; height:20px">
         	 	<cfoutput query="get_all_location" group="department_id">
            		<option disabled="disabled" value="#department_id#">#department_head#</option>
					<cfoutput>
                    <option value="#department_id#-#location_id#" <cfif department_id is #ListFirst(attributes.department_out_id,'-')# and location_id is #ListLast(attributes.department_out_id,'-')#>selected="selected"</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#</option>
                    </cfoutput> 
				</cfoutput>
        	</select>
    	</td>
      	<td>
        	<select name="department_in_id" style="width:110px; height:20px">
         	 	<cfoutput query="get_all_location" group="department_id">
            		<option disabled="disabled" value="#department_id#">#department_head#</option>
					<cfoutput>
                    <option value="#department_id#-#location_id#" <cfif department_id is #ListFirst(attributes.department_in_id,'-')# and location_id is #ListLast(attributes.department_in_id,'-')#>selected="selected"</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#</option>
                    </cfoutput> 
				</cfoutput>
        	</select>
    	</td>
        <td>
        	<input type="submit" style="width:40px" value="Ara" />
        </td>
  	</tr>
</table>
</cfform>
<table style="width:100%;">
  <tr class="color-header" height="20">
    <td style="width:40px;" class="form-title">No</td>
    <td class="form-title">Müşteri</td>
    <td style="width:100px;" class="form-title">Hazırlayan</td>
    <td width="20px" class="form-title">&nbsp;</td>
  </tr>
  
  <cfif get_sevk_fis.recordcount>
  
    <cfoutput query="get_sevk_fis">
      <tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
      	<cfquery name="get_url" datasource="#dsn#">
            SELECT     
                E.EMPLOYEE_NAME + ' ' + E.EMPLOYEE_SURNAME AS ADI,
                E.EMPLOYEE_ID
            FROM         
                WRK_SESSION AS W INNER JOIN
                EMPLOYEES AS E ON W.USERID = E.EMPLOYEE_ID
            WHERE   
            	W.PERIOD_ID = #session.ep.period_id# AND
                W.ACTION_PAGE LIKE '#fuseaction#%' AND 
                W.ACTION_PAGE LIKE N'%ship_id=#SHIP_RESULT_ID#%'
        </cfquery>
        <cfif get_url.recordcount>
            <td>#DELIVER_PAPER_NO#</td>
            <td>
                <cfif IS_TYPE eq 1> 
                    #left(unvan,15)#<cfif len(unvan) gt 15>...</cfif>
                <cfelse>
                    #DEPARTMENT_HEAD#
                </cfif>      
            </td>
            <td> <font color="red">#left(get_url.ADI,15)#<cfif len(get_url.ADI) gt 15>...</cfif></font></td>
        <cfelse>
        	<td>
                <cfset url_param = "#request.self#?fuseaction=pda.form_shipping_ambar_fis&department_in_id=#attributes.department_in_id#&department_out_id=#attributes.department_out_id#&keyword=#attributes.keyword#&date1=#dateformat(attributes.date1,'dd/mm/yyyy')#&date2=#dateformat(attributes.date2,'dd/mm/yyyy')#&DELIVER_PAPER_NO=#DELIVER_PAPER_NO#&is_type=#IS_TYPE#&ship_id=#SHIP_RESULT_ID#">
                <a href="#url_param#"class="tableyazi">
                    #DELIVER_PAPER_NO#
                </a>
            </td>
            <td>
                <cfif IS_TYPE eq 1> 
                    #left(unvan,15)#<cfif len(unvan) gt 15>...</cfif>
                <cfelse>
                    #DEPARTMENT_HEAD#
                </cfif>      
            </td>
            <td></td>
        </cfif>
   		<cfif IS_TYPE eq 1>    
            <cfquery name="PACKEGE_CONTROL" datasource="#DSN3#">
            	SELECT     
                	ISNULL(SUM(PAKETSAYISI), 0) AS PAKET_SAYISI, 
                    ISNULL(SUM(CONTROL_AMOUNT), 0) AS CONTROL_AMOUNT
				FROM         
                	(
            		SELECT     
                        PAKET_SAYISI AS PAKETSAYISI, 
                        PAKET_ID AS STOCK_ID, 
                        BARCOD, 
                        STOCK_CODE, 
                        PRODUCT_NAME,
                        (
                        SELECT        
                        	SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
						FROM            
                        	#dsn2_alias#.STOCK_FIS AS SF INNER JOIN
                         	#dsn2_alias#.STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID
						WHERE        
                        	SF.FIS_TYPE = 113 AND 
                            SF.REF_NO = '#DELIVER_PAPER_NO#' AND 
                            SFR.STOCK_ID = TBL.PAKET_ID
                        ) AS CONTROL_AMOUNT
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
                        FROM
                            (     
                            SELECT     
                                CASE 
                                    WHEN 
                                        S.PRODUCT_TREE_AMOUNT IS NOT NULL 
                                    THEN 
                                        S.PRODUCT_TREE_AMOUNT 
                                    ELSE 
                                        round(SUM(ORR.QUANTITY * EPS.PAKET_SAYISI),0) 
                                END 
                                    AS PAKET_SAYISI, 
                                EPS.PAKET_ID, 
                                S.BARCOD, 
                                S.STOCK_CODE, 
                                S.PRODUCT_NAME, 
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
                                ESR.SHIP_RESULT_ID = #SHIP_RESULT_ID#
                            GROUP BY 
                                EPS.PAKET_ID, 
                                S.BARCOD, 
                                S.STOCK_CODE, 
                                S.PRODUCT_NAME, 
                                S.PRODUCT_TREE_AMOUNT, 
                                ESR.SHIP_RESULT_ID,
                                ESRR.ORDER_ROW_ID
                            ) AS TBL1
                        GROUP BY
                            PAKET_ID, 
                            BARCOD, 
                            STOCK_CODE, 
                            PRODUCT_NAME, 
                            PRODUCT_TREE_AMOUNT, 
                            SHIP_RESULT_ID
                        ) AS TBL
            		) AS TBL2
          	</cfquery>
        <cfelse>
        	<cfquery name="PACKEGE_CONTROL" datasource="#DSN3#">
            	SELECT     
                	ISNULL(SUM(PAKETSAYISI), 0) AS PAKET_SAYISI, 
                    ISNULL(SUM(CONTROL_AMOUNT), 0) AS CONTROL_AMOUNT
				FROM         
                	(		
                    SELECT     
                        PAKET_SAYISI AS PAKETSAYISI, 
                        PAKET_ID AS STOCK_ID, 
                        BARCOD, 
                        STOCK_CODE, 
                        PRODUCT_NAME,
                        (
                        SELECT        
                        	SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
						FROM            
                        	#dsn2_alias#.STOCK_FIS AS SF INNER JOIN
                         	#dsn2_alias#.STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID
						WHERE        
                        	SF.FIS_TYPE = 113 AND 
                            SF.REF_NO = '#DELIVER_PAPER_NO#' AND 
                            SFR.STOCK_ID = TBL.PAKET_ID
                        ) AS CONTROL_AMOUNT, SHIP_RESULT_ID
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
                        FROM          
                            (
                            SELECT     
                                CASE 
                                    WHEN 
                                        S.PRODUCT_TREE_AMOUNT IS NOT NULL 
                                    THEN 
                                        S.PRODUCT_TREE_AMOUNT 
                                    ELSE 
                                        round(SUM(SIR.AMOUNT * EPS.PAKET_SAYISI) ,0)
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
                                SI.DISPATCH_SHIP_ID = #SHIP_RESULT_ID#
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
            		) AS TBL2
          	</cfquery>
            
        </cfif> 
	  <td align="center">
		 <cfif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.PAKET_SAYISI eq 0 and PACKEGE_CONTROL.CONTROL_AMOUNT eq 0>
            <img src="/images/plus_ques.gif" border="0" title="Barkod Yok.">
		 <cfelseif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.PAKET_SAYISI - PACKEGE_CONTROL.CONTROL_AMOUNT eq 0>
            <img src="/images/c_ok.gif" border="0" title="Sevk Edildi.">
         <cfelseif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.CONTROL_AMOUNT eq 0>
            <img src="/images/caution_small.gif" border="0" title="Sevk Edilmedi.">
         <cfelseif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.PAKET_SAYISI gt PACKEGE_CONTROL.CONTROL_AMOUNT>
          	<img src="/images/warning.gif" border="0" title="Eksik Sevkiyat.">
      	 <cfelseif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.PAKET_SAYISI lt PACKEGE_CONTROL.CONTROL_AMOUNT>
          	<img src="/images/control.gif" border="0" title="Fazla Sevkiyat">  
         </cfif></td>
      </tr>
    </cfoutput>
    <cfelse>
        <tr class="color-row">
            <td colspan="3" height="20">
            	<cfif not isdefined("attributes.is_form_submitted")>
              		Filtre Ediniz
              	<cfelse>
              		Kayıt Yok
            	</cfif>
            	!
         	</td>
     	</tr>
  	</cfif>
</table>
</div>
<script language="javascript">
$(document).ready(function(){
$(".header").hide()
document.getElementById('keyword').focus();
})

	
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