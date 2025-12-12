
<cfsetting showdebugoutput="no">

<style>
    .header{
        display:none;
    }
</style>
<cfquery name="get_url" datasource="#dsn#">
	SELECT     
    	E.EMPLOYEE_NAME + ' ' + E.EMPLOYEE_SURNAME AS ADI
	FROM         
    	WRK_SESSION AS W INNER JOIN
     	EMPLOYEES AS E ON W.USERID = E.EMPLOYEE_ID
	WHERE     
    	W.ACTION_PAGE LIKE '#fuseaction#%' AND 
        W.ACTION_PAGE LIKE N'%ship_id=#attributes.ship_id#%' AND 
        E.EMPLOYEE_ID <> #session.ep.userid#
</cfquery>
<cfif get_url.recordcount>
	<cfset kullanici = get_url.adi>
	<script language="javascript">
		alert('Girmek İstediğiniz Sayfa Kullanılmaktadır');
		history.back();
	</script>
</cfif>

<cfparam name="attributes.add_other_amount" default="1">
<cfparam name="attributes.del_other_amount" default="1">
<cfif attributes.is_type eq 1>
    <cfquery name="GET_SHIP_PACKAGE_LIST" datasource="#dsn3#">
        SELECT     
        	PAKET_SAYISI AS PAKETSAYISI, 
            PAKET_ID AS STOCK_ID, 
            BARCOD, 
            STOCK_CODE, 
            PRODUCT_NAME,
         	(
            SELECT     
            	SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
         	FROM          
            	EZGI_SHIPPING_PACKAGE_LIST
         	WHERE      
            	TYPE = 1 AND 
                STOCK_ID = TBL.PAKET_ID AND 
                SHIPPING_ID = TBL.SHIP_RESULT_ID
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
                            SUM(ORR.QUANTITY * EPS.PAKET_SAYISI)
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
                    ESR.SHIP_RESULT_ID = #attributes.ship_id#
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
  	</cfquery>
<cfelse>
   	<cfquery name="GET_SHIP_PACKAGE_LIST" datasource="#dsn3#">
        SELECT     
        	PAKET_SAYISI AS PAKETSAYISI, 
            PAKET_ID AS STOCK_ID, 
            BARCOD, 
            STOCK_CODE, 
            PRODUCT_NAME,
            (
            SELECT     
            	SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
           	FROM          
            	EZGI_SHIPPING_PACKAGE_LIST
        	WHERE      
            	TYPE = 2 AND 
                STOCK_ID = TBL.PAKET_ID AND 
                SHIPPING_ID = TBL.SHIP_RESULT_ID
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
    </cfquery>
</cfif> 
<!---<cfdump expand="yes" var="#GET_SHIP_PACKAGE_LIST#">
<cfabort>--->
<cfquery name="get_detail_package_list" dbtype="query">
	SELECT * FROM GET_SHIP_PACKAGE_LIST WHERE CONTROL_AMOUNT > 0
</cfquery>
<cfquery name="get_total_control" dbtype="query">
	SELECT sum(CONTROL_AMOUNT) as CONTROL_AMOUNT, sum(PAKETSAYISI) PAKETSAYISI FROM GET_SHIP_PACKAGE_LIST
</cfquery>
<cfif not len(get_total_control.CONTROL_AMOUNT)>
	<cfset get_total_control.CONTROL_AMOUNT = 0 >
</cfif>
<cfoutput query="get_detail_package_list">
	<cfset 'control_amount#STOCK_ID#' = CONTROL_AMOUNT>
</cfoutput>
<cfset stock_id_list = ValueList(GET_SHIP_PACKAGE_LIST.STOCK_ID,',')>
<cfset BASLIK="">
<cfif attributes.is_type eq 1>
	<cfset BASLIK = "Sevk No : #attributes.DELIVER_PAPER_NO#">
<cfelse>
	<cfset BASLIK = "Sevk Talep No : #attributes.DELIVER_PAPER_NO#">
</cfif>

<cf_box title="#BASLIK#">
	<form name="add_package" method="post" action="<cfoutput>#request.self#?fuseaction=pda.emptypopup_add_shipping_package&SHIP_ID=#attributes.ship_id#&department_id=#attributes.department_id#&date1=#attributes.date1#&date2=#attributes.date2#&page=#attributes.page#&kontrol_status=#attributes.kontrol_status#&is_type=#attributes.is_type#</cfoutput>">
		<input type="hidden" id="serials" name="serials" value="">
		<div>	
			<div style="display:flex;align-items: flex-end">
				<div class="form-group col col-2">
					<label for="add_other_amount">Miktar</label>
					<input name="add_other_amount" type="text" value="<cfoutput>#attributes.add_other_amount#</cfoutput>" class="moneybox" >
				</div>
				<div class="form-group col col-3">
					<label for="add_other_barcod">Ekle</label>
					<input name="add_other_barcod" id="add_other_barcod" type="text" value="" onKeyDown="if(event.keyCode == 13) {return add_product_to_barkod(this.value,add_other_amount.value,1);}" >
				</div>
				<cfoutput>
					<div class="form-group col col-2">
						<label for="total_control_amount">Ok:</label>
						<input type="text" name="total_control_amount" readonly="readonly" class="box"  style="text-align:right;color:FF0000; font-weight:bold" id="total_control_amount" value="#get_total_control.CONTROL_AMOUNT#" />
					</div>
					<div class="form-group col col-2">
						<label for="total_control_packages">Paket Sayısı:</label>
						<input type="text" name="total_control_packages" readonly="readonly" class="box"  style="text-align:right;color:FF0000; font-weight:bold" id="total_control_packages" value="#get_total_control.PAKETSAYISI#" />
					</div>
					<div class="form-group col col-2" style="margin-top: 24px; margin-left: 10px;">
			<select name="BarcodeParser" id="BarcodeParser">
				<option value="0">Barkod Tipi</option>

			</select>
		</div>
					<div class="form-group col col-1">
						<input class="ui-wrk-btn ui-wrk-btn-extra" type="button" value="<cfif not get_detail_package_list.recordcount>Kaydet<cfelse>Güncelle</cfif>" onClick="if(confirm('Kaydetmek İstediğinizden Eminmisiniz?')) kontrol(); else return false;">
					</div>
					
				<!----<div style="display:flex">
					<span style="font-weight:bold; color:##0000FF;">Ok:</span>
				
				<div class="form-group">
					<input type="text" name="total_control_amount" readonly="readonly" class="box"  style="text-align:right;color:##FF0000; font-weight:bold" id="total_control_amount" value="" />
				</div>
				<span style="font-weight:bold; color:##0000FF;">/#get_total_control.PAKETSAYISI#</span>
				</div>---->
				</cfoutput>	 		
			</div>
			<cfset COLORROW ="##f5ee73"> 
			<cfset product_barcode_list = ''>
			<input type="hidden" name="stock_id_list" value="<cfoutput>#stock_id_list#</cfoutput>">
			<cf_ajax_list>
				<thead>
					<tr  height="20px">
						<th>Kod</th>
						<th width="25px">Miktar</th>
						<th width="25px">Kontrol</th>
						<th width="25px">OK</th>
					</tr>
				</thead>
					
				<tbody>
					<cfoutput query="GET_SHIP_PACKAGE_LIST">
        <cfquery name="get_product_info" datasource="#dsn3#">
            SELECT  	PIP.PROPERTY7, 
                        PIP.PROPERTY13,
                        S.STOCK_CODE_2
            FROM       	STOCKS AS S LEFT OUTER JOIN
                        PRODUCT_INFO_PLUS AS PIP ON S.PRODUCT_ID = PIP.PRODUCT_ID
            WHERE     	(S.STOCK_ID = #STOCK_ID#)
        </cfquery>
        <tr id="row#STOCK_ID#" height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
           	<td>#product_name#</td>        
                <input type="hidden" id="PRODUCT_NAME#STOCK_ID#" name="PRODUCT_NAME#STOCK_ID#" value="#PRODUCT_NAME#" class="box" style="width:100;">
                <cfquery name="GET_BARCODE" datasource="#DSN3#">
                    SELECT TOP 1 BARCODE FROM  STOCKS_BARCODES WHERE STOCK_ID=#STOCK_ID#
                </cfquery>
                <cfset product_barcode_list = listdeleteduplicates(ListAppend(product_barcode_list,ValueList(GET_BARCODE.BARCODE),','))>	
            <td>
                <input type="text" name="amount#STOCK_ID#" id="amount#STOCK_ID#" value="#PAKETSAYISI#" readonly="yes" class="box" style="width:25px;text-align:right;">
            </td>
            <td>
                <input type="text" id="control_amount#STOCK_ID#" name="control_amount#STOCK_ID#" readonly="yes" value="<cfif isdefined('control_amount#STOCK_ID#')>#Evaluate('control_amount#STOCK_ID#')#</cfif>" class="box"  style="width:25px;text-align:right;color:FF0000;">
          	</td>
            <td align="center" valign="middle">      
                <img id="is_ok#STOCK_ID#" name="is_ok#STOCK_ID#"<cfif not isdefined('control_amount#STOCK_ID#') or (isdefined('control_amount#STOCK_ID#') and Evaluate('control_amount#STOCK_ID#') neq PAKETSAYISI)>style="display:none;"</cfif> align="center" src="images\c_ok.gif">
                <img id="warning_#STOCK_ID#" name="warning_#STOCK_ID#"<cfif not isdefined('control_amount#STOCK_ID#') or (isdefined('control_amount#STOCK_ID#') and Evaluate('control_amount#STOCK_ID#') eq PAKETSAYISI)>style="display:none;"</cfif> align="center" src="images\warning.gif">
                <img id="is_error#STOCK_ID#" name="is_error#STOCK_ID#"<cfif not isdefined('control_amount#STOCK_ID#') or (isdefined('control_amount#STOCK_ID#') and Evaluate('control_amount#STOCK_ID#') lte PAKETSAYISI)>style="display:none;"</cfif>align="center" src="images\closethin.gif">
            </td>
        </tr>
	</cfoutput>
				</tbody>
			</cf_ajax_list>
			
	</form>
</cf_box>

<!------------
<div style="width:290px">
<table cellpadding="1" cellspacing="1" align="left" class="color-border" width="100%">
<form name="add_package" method="post" action="<cfoutput>#request.self#?fuseaction=pda.emptypopup_add_shipping_package&SHIP_ID=#attributes.ship_id#&department_id=#attributes.department_id#&date1=#attributes.date1#&date2=#attributes.date2#&page=#attributes.page#&kontrol_status=#attributes.kontrol_status#&is_type=#attributes.is_type#</cfoutput>">
	<input type="hidden" id="serials" name="serials" value="">
		<tr class="color-list">
		<td colspan="4" style="width:100%">
		<table cellpadding="0" cellspacing="1" width="100%">
			<tr height="20px">
            	<td colspan="4">
					<cfif attributes.is_type eq 1><b>Sevk No :</b><cfelse><b>Sevk Talep No :</b></cfif><cfoutput><b>#attributes.DELIVER_PAPER_NO#</cfoutput></b>&nbsp;&nbsp;
                    <b>Ok: <cfoutput><input type="text" name="total_control_amount" readonly="readonly" class="box"  style="width:35px;text-align:right;color:FF0000; font-weight:bold" id="total_control_amount" value="" /> / #get_total_control.PAKETSAYISI#</b></cfoutput>
                </td>
           	</tr>
			<tr>
				<td>Miktar</td>
				<td><strong><input name="add_other_amount" type="text" value="<cfoutput>#attributes.add_other_amount#</cfoutput>" class="moneybox" style="width:40px;"></strong></td>
				<td nowrap="nowrap">Ekle</td>                     
				<td><input name="add_other_barcod" type="text" value="" onKeyDown="if(event.keyCode == 13) {return add_product_to_barkod(this.value,add_other_amount.value,1);}" style="width:120px;"></td>
			</tr>
		</table>
		</td>
	</tr>
   	<tr class="color-list" height="20px">
    	<td>Kod</td>
        <td width="25px">Miktar</td>
        <td width="25px">Kontrol</td>
        <td width="25px">OK</td>
    </tr>    
	<cfset COLORROW ="##f5ee73"> 
	<cfset product_barcode_list = ''>
	<input type="hidden" name="stock_id_list" value="<cfoutput>#stock_id_list#</cfoutput>">
	<cfoutput query="GET_SHIP_PACKAGE_LIST">
        <cfquery name="get_product_info" datasource="#dsn3#">
            SELECT  	PIP.PROPERTY7, 
                        PIP.PROPERTY13,
                        S.STOCK_CODE_2
            FROM       	STOCKS AS S LEFT OUTER JOIN
                        PRODUCT_INFO_PLUS AS PIP ON S.PRODUCT_ID = PIP.PRODUCT_ID
            WHERE     	(S.STOCK_ID = #STOCK_ID#)
        </cfquery>
        <tr id="row#STOCK_ID#" height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
           	<td>#product_name#</td>        
                <input type="hidden" id="PRODUCT_NAME#STOCK_ID#" name="PRODUCT_NAME#STOCK_ID#" value="#PRODUCT_NAME#" class="box" style="width:100;">
                <cfquery name="GET_BARCODE" datasource="#DSN3#">
                    SELECT TOP 1 BARCODE FROM  STOCKS_BARCODES WHERE STOCK_ID=#STOCK_ID#
                </cfquery>
                <cfset product_barcode_list = listdeleteduplicates(ListAppend(product_barcode_list,ValueList(GET_BARCODE.BARCODE),','))>	
            <td>
                <input type="text" name="amount#STOCK_ID#" id="amount#STOCK_ID#" value="#PAKETSAYISI#" readonly="yes" class="box" style="width:25px;text-align:right;">
            </td>
            <td>
                <input type="text" id="control_amount#STOCK_ID#" name="control_amount#STOCK_ID#" readonly="yes" value="<cfif isdefined('control_amount#STOCK_ID#')>#Evaluate('control_amount#STOCK_ID#')#</cfif>" class="box"  style="width:25px;text-align:right;color:FF0000;">
          	</td>
            <td align="center" valign="middle">      
                <img id="is_ok#STOCK_ID#" name="is_ok#STOCK_ID#"<cfif not isdefined('control_amount#STOCK_ID#') or (isdefined('control_amount#STOCK_ID#') and Evaluate('control_amount#STOCK_ID#') neq PAKETSAYISI)>style="display:none;"</cfif> align="center" src="images\c_ok.gif">
                <img id="warning_#STOCK_ID#" name="warning_#STOCK_ID#"<cfif not isdefined('control_amount#STOCK_ID#') or (isdefined('control_amount#STOCK_ID#') and Evaluate('control_amount#STOCK_ID#') eq PAKETSAYISI)>style="display:none;"</cfif> align="center" src="images\warning.gif">
                <img id="is_error#STOCK_ID#" name="is_error#STOCK_ID#"<cfif not isdefined('control_amount#STOCK_ID#') or (isdefined('control_amount#STOCK_ID#') and Evaluate('control_amount#STOCK_ID#') lte PAKETSAYISI)>style="display:none;"</cfif>align="center" src="images\closethin.gif">
            </td>
        </tr>
	</cfoutput>
	<input type="hidden" name="changed_stock_id" value=""><!--- Bu hidden alan kontrol yapıldıkça kontrol yapılan satırı renklendirmek için kullanılıyor. --->
	<tr class="color-list">
		<td colspan="4" align="right"><input type="button" value="<cfif not get_detail_package_list.recordcount>Kaydet<cfelse>Güncelle</cfif>" onClick="if(confirm('Kaydetmek İstediğinizden Eminmisiniz?')) kontrol(); else return false;"></td>
	</tr>
	</form>
</table>
</div>----------->
<cfquery name="getSerialNumbers" datasource="#dsn3#">
SELECT ISNULL( (
  SELECT SERIAL_NO,STOCK_ID,(SELECT COUNT(*) FROM #dsn3#.PBS_SHIPPING_PACKAGE_LIST_SERIALS where SERIAL_NUMBER=SGN.SERIAL_NO) as IS_READ FROM #dsn3#.SERVICE_GUARANTY_NEW SGN
  
  WHERE PROCESS_ID IN (
SELECT FIS_ID FROM #dsn2#.STOCK_FIS WHERE REF_NO='#attributes.DELIVER_PAPER_NO#')  AND PROCESS_CAT=113 AND IN_OUT=1
FOR JSON AUTO),'[]')  AS SERI_NUMARALI

<!----SELECT  (SELECT SERIAL_NO,STOCK_ID,0 as IS_READ FROM #dsn3#.SERVICE_GUARANTY_NEW WHERE PROCESS_ID IN (
SELECT FIS_ID FROM #dsn2#.STOCK_FIS WHERE REF_NO='#attributes.DELIVER_PAPER_NO#')  AND PROCESS_CAT=113 AND IN_OUT=1 FOR JSON AUTO)  AS SERI_NUMARALI----->
</cfquery>

<script>
	var serialNumbers = <cfoutput>#getSerialNumbers.SERI_NUMARALI#</cfoutput>;
	
</script>
<script>
var bm=null;
function groupByStockId(data) {
	var result = {};
	for (var i = 0; i < data.length; i++) {
		var item = data[i];
		var stockId = item.STOCK_ID;
		if (!result[stockId]) {
			result[stockId] = [];
		}
		result[stockId].push(item); // Tüm objeyi push ediyoruz, sadece serial_no'yu değil
	}
	return result;
}
var _groupedData = groupByStockId(serialNumbers);

function findStockIdBySerial(serial, groupedData) {
		var SerialObject = bm.parseWith(serial, parseInt(document.getElementById('BarcodeParser').value));
			console.log('Barcode parsed for serial number:', SerialObject);
			if(SerialObject && SerialObject.serial_no){
				serial = SerialObject.serial_no;
			}
			console.log('Searching for serial number:', serial);

	for (const stockId in groupedData) {
		const group = groupedData[stockId];
		for (let i = 0; i < group.length; i++) {
			if (group[i].SERIAL_NO === serial) {
				return parseInt(stockId);
			}
		}
	}
	return null; // Bulunamazsa
}

function findAndMarkSerial(serialNo, groupedData) {
	console.log('=== FIND AND MARK SERIAL START ===');
	var SerialObject = bm.parseWith(serialNo, parseInt(document.getElementById('BarcodeParser').value));
	console.log('Barcode parsed for serial number:', SerialObject);
	if(SerialObject && SerialObject.serial_no){
		serialNo = SerialObject.serial_no;
	}
	console.log('Aranan seri numarası:', serialNo);
	


	for (const stockId in groupedData) {
		const group = groupedData[stockId];
		console.log(`Stok ID: ${stockId}, Grup içindeki eleman sayısı: ${group.length}`);
		
		// Grupta her bir objeyi kontrol et
		for (let i = 0; i < group.length; i++) {
			const item = group[i];
			console.log(`  Kontrol edilen: ${item.SERIAL_NO} (IS_READ: ${item.IS_READ})`);
			
			if (item.SERIAL_NO === serialNo) {
				console.log(`✅ Seri numarası bulundu: ${serialNo} (STOCK_ID: ${stockId})`);
				
				if (item.IS_READ === 1) {
					console.warn(`⚠️ Seri numarası zaten okutulmuş: ${serialNo}`);
					return false;
				} else {
					item.IS_READ = 1;
					console.log(`✅ Seri numarası başarıyla işaretlendi: ${serialNo} (STOCK_ID: ${stockId})`);
					return true;
				}
			}
		}
	}

	console.error(`❌ Seri numarası hiçbir stokta bulunamadı: ${serialNo}`);
	return false;
}
</script>



<script language="javascript">

$(document).ready(function(){
	$(".header").hide()
	document.getElementById('add_other_barcod').focus();
	 bm=new BarcodeManager();
var parsers=bm.listParsers();
for(var i=0;i<parsers.length;i++){
	$("#BarcodeParser").append('<option value="'+parsers[i].id+'">'+parsers[i].name+'</option>');
}
})
setTimeout("document.getElementById('add_other_barcod').select();",1000);	
function add_product_to_barkod(barcode, amount, type) {	
	<cfoutput>
	var ship_id = #attributes.ship_id#;
	var is_type = #attributes.is_type#;
	</cfoutput>
	if(document.getElementById('BarcodeParser').value==4){
		add_product_to_barkod_lmn(barcode, amount, type);
		return false;
	}

	console.log('--- ADD PRODUCT TO BARKOD START ---');
	console.log('ship_id:', ship_id);
	console.log('is_type:', is_type);
	console.log('barcode:', barcode);
	console.log('amount:', amount);
	console.log('type:', type);
	var uzunluk = barcode.length;
	var amount = amount;
	console.log('barcode: ' + barcode);
	console.log('amount: ' + amount);
	console.log('type: ' + type);
	var SID = findStockIdBySerial(barcode, _groupedData);
	var isRead= findAndMarkSerial(barcode, _groupedData);
	if(isRead === false) {
		alert('Bu seri numarası zaten okutulmuş.');
		document.getElementById('add_other_barcod').value = '';
		document.getElementById('add_other_barcod').focus();
		return false;
	}
	console.log('SID: ' + SID);
	console.log('isRead: ' + isRead);
	if (SID != null) {
		eval('row' + SID).style.background = '<cfoutput>#colorrow#</cfoutput>';
			if (type == 1) { //ekleme ise
				if ((document.getElementById('control_amount' + SID).value * 1) - (amount * -1) > (document.getElementById('amount' + SID).value * 1))
					alert(document.getElementById('PRODUCT_NAME' + SID).value + ' Ürününde Fazla Çıkış Var');
				else {
					document.getElementById('control_amount' + SID).value = (document.getElementById('control_amount' + SID).value * 1) + (amount * 1);
					document.getElementById('total_control_amount').value = (document.getElementById('total_control_amount').value * 1) + (amount * 1);
				}
				if (document.getElementById('control_amount' + SID).value == document.getElementById('amount' + SID).value)
					document.getElementById('row' + SID).style.display = 'none';
			} else if (type == 0) { //silme ise	
				if (document.getElementById('control_amount' + SID).value == 0 || document.getElementById('control_amount' + SID).value < 0)
					alert('Çıkan Ürünlerin Sayısı 0 dan küçük olamaz');
				else
					document.getElementById('control_amount' + SID).value = (document.getElementById('control_amount' + SID).value * 1) - (amount * 1);
				if (document.getElementById('control_amount' + SID).value == document.getElementById('amount' + SID).value) {
					document.getElementById('is_ok' + SID).style.display = '';
					document.getElementById('is_error' + SID).style.display = 'none';
				}
				if (document.getElementById('control_amount' + SID).value > document.getElementById('amount' + SID).value) {
					document.getElementById('is_ok' + SID).style.display = 'none';
					document.getElementById('is_error' + SID).style.display = '';
				}
				if (document.getElementById('control_amount' + SID).value < document.getElementById('amount' + SID).value)
					document.getElementById('is_ok' + SID).style.display = 'none';
			}
			//document.getElementById("serials").value += barcode + ",";
			document.getElementById('add_other_barcod').value = '';
			/*document.getElementById('del_other_barcod').value='';*/
			var changedStockIdElem = document.getElementById('changed_stock_id');
			if (changedStockIdElem) {
				changedStockIdElem.value = SID;
			}
			eval('row' + SID).style.background = 'FFCCCC';

	} else if (uzunluk < 5 || uzunluk > 20) {
		alert('Barkod 5 ile 20 karakter arasında olmalıdır');
		document.getElementById('add_other_barcod').value = '';
		document.getElementById('add_other_barcod').focus();
		return false;
	}

	return false;
	if (list_find('<cfoutput>#product_barcode_list#</cfoutput>', barcode, ',')) {
		var new_sql = "SELECT TOP 1 STOCK_ID FROM STOCKS_BARCODES WHERE BARCODE = '" + barcode + "'";
		var get_product = wrk_query(new_sql, 'dsn1');
		if (document.getElementById('control_amount' + SID) == undefined)
			alert('Ürünün Barkodlarında Sorun Var.');
		else {
			var changedStockIdElem = document.getElementById('changed_stock_id');
			if (changedStockIdElem && changedStockIdElem.value != "") //daha önceden bir satır eklenmişse alan dolmuş demektir ve yeni eklenecek alan için satırı renklendiyoruz bir alt satırda
				eval('row' + changedStockIdElem.value).style.background = '<cfoutput>#colorrow#</cfoutput>';
			if (type == 1) { //ekleme ise
				if ((document.getElementById('control_amount' + SID).value * 1) - (amount * -1) > (document.getElementById('amount' + SID).value * 1))
					alert(document.getElementById('PRODUCT_NAME' + SID).value + ' Ürününde Fazla Çıkış Var');
				else {
					document.getElementById('control_amount' + SID).value = (document.getElementById('control_amount' + SID).value * 1) + (amount * 1);
					document.getElementById('total_control_amount').value = (document.getElementById('total_control_amount').value * 1) + (amount * 1);
				}
				if (document.getElementById('control_amount' + SID).value == document.getElementById('amount' + SID).value)
					document.getElementById('row' + SID).style.display = 'none';
			} else if (type == 0) { //silme ise	
				if (document.getElementById('control_amount' + SID).value == 0 || document.getElementById('control_amount' + SID).value < 0)
					alert('Çıkan Ürünlerin Sayısı 0 dan küçük olamaz');
				else
					document.getElementById('control_amount' + SID).value = (document.getElementById('control_amount' + SID).value * 1) - (amount * 1);
				if (document.getElementById('control_amount' + SID).value == document.getElementById('amount' + SID).value) {
					document.getElementById('is_ok' + SID).style.display = '';
					document.getElementById('is_error' + SID).style.display = 'none';
				}
				if (document.getElementById('control_amount' + SID).value > document.getElementById('amount' + SID).value) {
					document.getElementById('is_ok' + SID).style.display = 'none';
					document.getElementById('is_error' + SID).style.display = '';
				}
				if (document.getElementById('control_amount' + SID).value < document.getElementById('amount' + SID).value)
					document.getElementById('is_ok' + SID).style.display = 'none';
			}
			document.getElementById('add_other_barcod').value = '';
			/*document.getElementById('del_other_barcod').value='';*/
			if (changedStockIdElem) {
				changedStockIdElem.value = SID;
			}
			eval('row' + SID).style.background = 'FFCCCC';
		}
	} else
		alert('Kayıtlı Barkod Yok!');
}
function kontrol()
{
	document.getElementById("serials").value = JSON.stringify(_groupedData);
	for(i=1;i<=<cfoutput>#listlen(stock_id_list,',')#</cfoutput>;i++)
	{
		var stockId = list_getat("<cfoutput>#stock_id_list#</cfoutput>",i,",");
		var controlAmountElem = document.getElementById('control_amount' + stockId);
		if (controlAmountElem) {
			controlAmountElem.value = controlAmountElem.value;
		}
	}
	document.add_package.submit();
}

function add_product_to_barkod_lm(barcode,amount,type)
{	
	<cfoutput>
	var ship_id = #attributes.ship_id#;
	var is_type = #attributes.is_type#;
	</cfoutput>
	<CFSET colorrow="##ffff003b">
	var uzunluk = barcode.length;
	var amount = amount
	if(list_find('<cfoutput>#product_barcode_list#</cfoutput>',barcode,','))
	{
		var new_sql = "SELECT TOP 1 STOCK_ID FROM STOCKS_BARCODES WHERE BARCODE = '"+barcode+"'";
		var get_product = wrk_query(new_sql,'dsn1');
			if(document.getElementById('control_amount'+get_product.STOCK_ID)==undefined)
				alert('Ürünün Barkodlarında Sorun Var.')		
			else
			{
				if(document.all.changed_stock_id.value != "")//daha önceden bir satır eklenmişse alan dolmuş demektir ve yeni eklenecek alan için satırı renklendiyoruz bir alt satırda
					eval('row'+document.all.changed_stock_id.value).style.background='<cfoutput>#colorrow#</cfoutput>';
				if(type==1)//ekleme ise
				{		
					if((document.getElementById('control_amount'+get_product.STOCK_ID).value*1)-(amount*-1) > (document.getElementById('amount'+get_product.STOCK_ID).value*1))
						alert(document.getElementById('PRODUCT_NAME'+get_product.STOCK_ID).value+' Ürününde Fazla Çıkış Var');
					else
					{
						document.getElementById('control_amount'+get_product.STOCK_ID).value = (document.getElementById('control_amount'+get_product.STOCK_ID).value*1)+(amount*1);
						document.all.total_control_amount.value=(document.all.total_control_amount.value*1)+(amount*1);
					}
					if(document.getElementById('control_amount'+get_product.STOCK_ID).value == document.getElementById('amount'+get_product.STOCK_ID).value)
						document.getElementById('row'+get_product.STOCK_ID).style.display='none';
				}			
				else if(type==0)//silme ise	
					if(document.getElementById('control_amount'+get_product.STOCK_ID).value == 0 || document.getElementById('control_amount'+get_product.STOCK_ID).value < 0)
						alert('Çıkan Ürünlerin Sayısı 0 dan küçük olamaz');
					else		
						document.getElementById('control_amount'+get_product.STOCK_ID).value = (document.getElementById('control_amount'+get_product.STOCK_ID).value*1)-(amount*1);
							if(document.getElementById('control_amount'+get_product.STOCK_ID).value == document.getElementById('amount'+get_product.STOCK_ID).value)
							{eval('document.all.is_ok'+get_product.STOCK_ID).style.display='';
							eval('document.all.is_error'+get_product.STOCK_ID).style.display='none';}	
							if(document.getElementById('control_amount'+get_product.STOCK_ID).value > document.getElementById('amount'+get_product.STOCK_ID).value)
							{eval('document.all.is_ok'+get_product.STOCK_ID).style.display='none';
							eval('document.all.is_error'+get_product.STOCK_ID).style.display='';}
							if(document.getElementById('control_amount'+get_product.STOCK_ID).value < document.getElementById('amount'+get_product.STOCK_ID).value)
								eval('document.all.is_ok'+get_product.STOCK_ID).style.display='none';
			document.all.add_other_barcod.value='';
			/*document.all.del_other_barcod.value='';*/
			document.all.changed_stock_id.value = get_product.STOCK_ID;
			eval('row'+get_product.STOCK_ID).style.background='FFCCCC';
			}	
		}
	else
		alert('Kayıtlı Barkod Yok!')
}


</script>

<script>
	function wrk_query(str_query, data_source, maxrows) {
    if (!data_source) data_source = 'dsn';
    if (!maxrows) maxrows = 0;
    
    var new_query = new Object();
    var req = createXMLHttpRequest();
    
    if (req) {
        req.open("post", '/index.cfm?fuseaction=objects2.emptypopup_get_js_query&isAjax=1&xmlhttp=1', false);
        req.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setRequestHeader('pragma', 'nocache');
        
        var queryParam = encodeURI(str_query).indexOf('+') == -1 ? 
            'str_sql=' + encodeURI(str_query) : 
            'str_sql=' + encodeURIComponent(str_query);
            
        req.send(queryParam + '&data_source=' + data_source + '&maxrows=' + maxrows);
        
        if (req.readyState == 4 && req.status == 200) {
            try {
                eval(req.responseText.replace(/\u200B/g, ''));
                new_query = get_js_query;
            } catch(e) {
                new_query = false;
            }
        }
    }
    
    return new_query;
}
// XMLHttpRequest oluşturma fonksiyonu
function createXMLHttpRequest() {
    var req = false;
    
    if (window.XMLHttpRequest) {
        try {
            req = new XMLHttpRequest();
        } catch(e) {
            req = false;
        }
    } else if (window.ActiveXObject) {
        try {
            req = new ActiveXObject("Msxml2.XMLHTTP");
        } catch(e) {
            try {
                req = new ActiveXObject("Microsoft.XMLHTTP");
            } catch(e) {
                req = false;
            }
        }
    }
    
    return req;
}
</script>