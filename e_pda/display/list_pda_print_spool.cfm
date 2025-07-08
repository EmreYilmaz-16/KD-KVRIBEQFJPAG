<cfsetting showdebugoutput="yes">
<style>
    .header{
        display:none;
    }
</style>
<cfquery name="get_spool" datasource="#dsn3#">
	SELECT        
    	S.BARCOD, 
        ESR.DELIVER_PAPER_NO, 
        S.PRODUCT_NAME, 
        E.EZGI_PRINT_ID, 
        E.STOCK_ID, 
        ISNULL(SUM(E.AMOUNT),0) AS AMOUNT
	FROM            
    	EZGI_PDA_PRINT_SPOOL AS E INNER JOIN
    	STOCKS AS S ON E.STOCK_ID = S.STOCK_ID INNER JOIN
    	EZGI_SHIP_RESULT AS ESR ON E.SHIP_ID = ESR.SHIP_RESULT_ID INNER JOIN
     	EZGI_SHIP_RESULT_ROW ON ESR.SHIP_RESULT_ID = EZGI_SHIP_RESULT_ROW.SHIP_RESULT_ID INNER JOIN
     	ORDER_ROW AS ORR ON EZGI_SHIP_RESULT_ROW.ORDER_ROW_ID = ORR.ORDER_ROW_ID AND E.STOCK_ID = ORR.STOCK_ID
	WHERE        
    	E.RECORD_EMP = #session.ep.userid# AND 
        E.STATUS = 0 AND 
        E.IS_TYPE = 1
	GROUP BY 
    	S.BARCOD, 
        ESR.DELIVER_PAPER_NO, 
        S.PRODUCT_NAME, 
        E.EZGI_PRINT_ID, 
        E.STOCK_ID
  	UNION ALL
    SELECT        
    	S.BARCOD, 
        CAST(SI.DISPATCH_SHIP_ID AS NVARCHAR(10)) AS DELIVER_PAPER_NO, 
        S.PRODUCT_NAME,
        EPS.EZGI_PRINT_ID,  
        S.STOCK_ID, 
        ISNULL(SUM(EPS.AMOUNT),0) AS AMOUNT
	FROM            
    	STOCKS AS S INNER JOIN
   		EZGI_PDA_PRINT_SPOOL AS EPS ON S.STOCK_ID = EPS.STOCK_ID INNER JOIN
      	#dsn2_alias#.SHIP_INTERNAL_ROW AS SIR INNER JOIN
      	#dsn2_alias#.SHIP_INTERNAL AS SI ON SIR.DISPATCH_SHIP_ID = SI.DISPATCH_SHIP_ID ON EPS.STOCK_ID = SIR.STOCK_ID AND EPS.SHIP_ID = SIR.DISPATCH_SHIP_ID
  	WHERE        
    	EPS.RECORD_EMP = #session.ep.userid# AND 
        EPS.STATUS = 0 AND 
        EPS.IS_TYPE = 2
	GROUP BY 
    	S.BARCOD, 
        SI.DISPATCH_SHIP_ID, 
        EPS.EZGI_PRINT_ID, 
        S.PRODUCT_NAME, 
        S.STOCK_ID
</cfquery>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default=20>
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows)+1>
<cfparam name="attributes.totalrecords" default='#get_spool.recordcount#'>

<cfform name="frm_search" method="post" action="#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_pda_print_spool">
  <input type="hidden" name="is_form_submitted" value="1">
<div style="width:290px">
<table width="100%">
    <tr>
      <td class="headbold" height="20"><b>Etiket Havuzu</b></td>
    </tr>
</table>
</cfform>
<table style="width:100%;">
  <tr class="color-header" height="20">
    <td width="35" class="form-title">S.No</td>
    <td width="50" class="form-title">Barkod</td>
    <td class="form-title">Ürün Adı</td>
    <td width="15" class="form-title">
    	<input type="checkbox" style="text-align:center;" alt="Hepsini Seç" onClick="grupla(-1);">
    </td>
  </tr>
  <cfif get_spool.recordcount>
    <cfoutput query="get_spool" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
      <tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
 			<td style="text-align:left">#DELIVER_PAPER_NO#</td>
            <td style="text-align:center">#barcod#</td>
            <td style="text-align:left">#Left(product_name,17)#</td>
            <td style="text-align:center">
            	<input type="checkbox" name="select_production" value="#EZGI_PRINT_ID#_#amount#">
            </td>
      </tr>
    </cfoutput>
     <tr class="color-row">
            <td colspan="4" height="20">
            	<input type="button" value="Yazdır" onClick="grupla(-2);">
                <input type="button" value="Sil" onClick="grupla(-3);">
         	</td>
     	</tr>
    <cfelse>
        <tr class="color-row">
            <td colspan="4" height="20">
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
<cfif attributes.totalrecords gt attributes.maxrows>
  <table width="100%" cellpadding="0" cellspacing="0" border="0" align="center" height="20">
    <tr align="left">
      <td width="60" nowrap="nowrap">
	  		<cfset adres="#listgetat(attributes.fuseaction,1,'.')#.list_pda_print_spool">
            <cf_pages page="#attributes.page#" 
						  maxrows="#attributes.maxrows#" 
						  totalrecords="#attributes.totalrecords#" 
						  startrow="#attributes.startrow#" 
						  adres="#adres#&is_form_submitted=1">
      	</td>
      	<td>
			<cfoutput>
          		<cf_get_lang_main no='80.toplam'> : #attributes.totalrecords#&nbsp;-&nbsp;<cf_get_lang_main no='169.sayfa'> : #attributes.page#/#lastpage#
		  	</cfoutput>
   		</td>
    </tr>
  </table>
</cfif>
</table>
</div>
<script language="javascript">
	$(document).ready(function(){
$(".header").hide()
})
	function grupla(type)
		{//type sadece -1 olarak gelir,-1 geliyorsa hepsini seç demektir.
			order_row_id_list = '';
			chck_leng = document.getElementsByName('select_production').length;
			for(ci=0;ci<chck_leng;ci++)
			{
				var my_objets = document.all.select_production[ci];
				if(chck_leng == 1)
					var my_objets =document.all.select_production;
				if(type == -1)
				{//hepsini seç denilmişse	
					if(my_objets.checked == true)
						my_objets.checked = false;
					else
						my_objets.checked = true;
				}
				else
				{
					if(my_objets.checked == true)
						order_row_id_list +=my_objets.value+',';
				}
			}
			order_row_id_list = order_row_id_list.substr(0,order_row_id_list.length-1);//sondaki virgülden kurtarıyoruz.
			if(order_row_id_list!='')
			{
				if(type == -2)
				window.location.href='<cfoutput>#request.self#</cfoutput>?fuseaction=pda.popup_ezgi_print_files&print_type=79&action_id='+order_row_id_list;
				if(type == -3)
				window.open('<cfoutput>#request.self#</cfoutput>?fuseaction=pda.emptypopup_del_ezgi_pda_print_spool&action_id='+order_row_id_list);
			}
		}
</script>