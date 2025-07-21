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
<style type="text/css">
.boxtext {
    background-color: #e6e6fe;
    border: none;
    margin: 0;
    padding: 0;
}

.tablo {
    border-top: 1px solid #aec7f0;
    border-bottom: 1px solid #aec7f0;
    margin: 0;
    padding: 0;
}

.header {
    display: none;
}
</style>
<script type="text/javascript">
// Global değişkenler
var AppConfig = {
    rowCount: <cfoutput>#get_ambar_fis.recordcount#</cfoutput>,
    isShelfEnabled: <cfoutput>#IIf(get_store_type.raf gt 0, 'true', 'false')#</cfoutput>,
    currentStock: {
        id: '',
        code: '',
        name: '',
        barcode: '',
        shelfCode: '',
        amount: 0
    },
    operationFlags: {
        canAdd: true,
        canRemove: true,
        buttonActive: false
    }
};
</script>

<cfform name="form_basket">
  <cfinput id="txt_department_out" name="txt_department_out" type="hidden" value="#attributes.department_out_id#">
  <cfinput id="txt_department_in" name="txt_department_in" type="hidden" value="#attributes.department_in_id#">
  <cfinput id="process_cat_id" type="hidden" name="process_cat_id" value="#get_process_cat.process_cat_id#">
  <cfinput id="fis_tipi" type="hidden" name="fis_tipi" value="#default_process_type#">
  <div style="width:290px">
  	<table cellpadding="2" cellspacing="1" align="left" class="color-border" width="99%">
    	<tr class="color-list" height="20px">
    		<td colspan="4"><strong><cfoutput>#get_stock_info.product_name#</cfoutput></strong></td>
    	</tr>
    	<tr class="color-list">
      		<td colspan="4">
            	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="color-border">
          			<tr class="color-list">
            			<td width="45px">Miktar</td>
            			<cfif get_store_type.raf gt 0><td width="75px">Raf</td></cfif>
            			<td width="95px">Barcode</td>
            			<td>Kontrol</td>
       	  			</tr>
          			<tr class="color-list">
            			<td>
                        	<input id="add_other_amount" name="add_other_amount" type="text" class="moneybox" onfocus="islemtipi=0;" style="width:40px; text-align:right" value="" />
                      	</td>
            			<cfif get_store_type.raf gt 0>
            				<td>
                            	<input id="add_other_shelf" name="add_other_shelf" type="text" class="moneybox" onfocus="islemtipi=0;" style="width:65px;" value="" />
                          	</td>
           				</cfif>
            			<td>
                        	<cfinput id="add_other_barcod" name="add_other_barcod" readonly="yes" type="text" value="#get_stock_info.BARCODE#" style="width:90px;" >
                       	</td>
            			<td nowrap="nowrap">
            				<cfinput type="text" value="#all_amount#" name="all_amount" id="all_amount" class="boxtext" style="text-align:right; font-weight:bold; width:30px">/
        					<cfinput type="text" value="#attributes.paket_sayisi#" name="paket_sayisi" id="paket_sayisi" class="boxtext" style="text-align:right;font-weight:bold;width:30px">
            			</td>
          			</tr>
        		</table>
         	</td>
    	</tr>
    	<tr class="color-list">
      		<td width="90" align="center">Barkod</td>
      		<td width="90" align="left">Ürün Adı</td>
      		<td width="40" align="right">Mikt.</td>
      		<cfif get_store_type.raf gt 0>
      			<td align="left">Raf</td>
      		</cfif>
    	</tr>
    	<tr class="color-list">
      		<td align="left" colspan="4">
        		<form name="product_row" id="product_row" method="post">
          			<table name="table1" id="table1" border="0" cellpadding="0" cellspacing="0" width="100%" class="tablo">
          				<cfoutput query="get_ambar_fis">
            				<cfinput type="hidden" value="#stock_id#" name="stockid#currentrow#" id="stockid#currentrow#" />
                			<cfinput type="hidden" value="" name="spectmainid#currentrow#" id="spectmainid#currentrow#" />
          	 				<tr id="row#currentrow#" height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
                				<td><cfinput type="text" value="#barcod#" name="barcod#currentrow#" id="barcod#currentrow#" size="13" class="boxtext" readonly="yes" /></td>
                    			<td><cfinput type="text" value="#PRODUCT_NAME#" name="stockcode#currentrow#" id="stockcode#currentrow#" size="11" class="boxtext" readonly="yes" /></td>
                    			<td><cfinput type="text" value="#amount#" name="amount#currentrow#" id="amount#currentrow#" size="4" class="boxtext" readonly="yes" style="text-align:right" /></td>
                    			<cfif get_store_type.raf gt 0>
                    				<td><cfinput type="text" value="#shelf_code#" name="shelf_code#currentrow#" id="shelf_code#currentrow#" size="8" class="boxtext" readonly="yes" style="text-align:right" /></td>
                    			</cfif>
                			</tr>
           				</cfoutput>
          			</table>
          			<cfinput type="hidden" id="row_count" name="row_count" value="#get_ambar_fis.recordcount#" />
        		</form>
          	</td>
    	</tr>
    	<tr class="color-list">
      		<td colspan="4" valign="middle" align="center">
				<cfif get_store_type.raf gt 0>
                    <select name="shelf_select" style="width:100px; text-align:center">
                        <cfoutput query="get_shelf_stock">
                            <option value="">#SHELF_CODE# - #REAL_STOCK#</option>
                        </cfoutput>
                    </select>
                <cfelse>
                    Depo Miktarı : <cfoutput>#AmountFormat(get_depo_stok.product_stock)#</cfoutput>
                </cfif>
                <input type="hidden" id="department_in" name="department_in" value="" />
                <input type="hidden" id="action_id" name="action_id" value="" />
                <input id="geri" name="geri" value="Vazgeç" type="button" onclick="history.go(-1);" />
                <input id="sil" name="sil" value="Sil" type="button" style="width:30px" onclick="kontrol_sil();" />
                <input id="onay" name="Onay" value="<cf_get_lang_main no="49.Kaydet">" type="button" disabled="disabled" onclick="kontrol_kayit();" />
   	  		</td>
    	</tr>
  	</table>
  </div>
</cfform>
<script type="text/javascript">
document.getElementById('add_other_amount').focus();
setTimeout(function() {
    document.getElementById('add_other_amount').select();
}, 1000);

// Utility fonksiyonlar
var Utils = {
    getElement: function(id) {
        return document.getElementById(id);
    },
    
    showAlert: function(message) {
        alert(message);
    },
    
    resetCurrentStock: function() {
        AppConfig.currentStock = {
            id: '',
            code: '',
            name: '',
            barcode: '',
            shelfCode: '',
            amount: 0
        };
    }
};

// Ana iş mantığı fonksiyonları
var StockManager = {
    generateActionId: function() {
        var actionId = '';
        var validRowCount = 0;
        
        for (var i = 1; i <= AppConfig.rowCount; i++) {
            var amountElement = Utils.getElement('amount' + i);
            if (amountElement && parseFloat(amountElement.value) > 0) {
                if (validRowCount > 0) actionId += ',';
                
                actionId += i + '-';
                actionId += Utils.getElement('stockid' + i).value + '-';
                actionId += amountElement.value + '-';
                
                if (AppConfig.isShelfEnabled) {
                    actionId += Utils.getElement('shelf_code' + i).value;
                }
                validRowCount++;
            }
        }
        
        Utils.getElement('action_id').value = actionId;
        Utils.getElement('row_count').value = validRowCount;
    },

    toggleSaveButton: function() {
        var saveButton = Utils.getElement('onay');
        saveButton.disabled = !AppConfig.operationFlags.buttonActive;
    },

    updateButtonState: function() {
        AppConfig.operationFlags.buttonActive = !AppConfig.operationFlags.buttonActive;
        this.toggleSaveButton();
    }
};
// Stok sorgulama ve doğrulama
var StockValidator = {
    getStockByBarcode: function(barcode) {
        if (!barcode) return null;
        
        Utils.resetCurrentStock();
        
        var sql = "SELECT SB.STOCK_ID, SB.BARCODE, PU.MAIN_UNIT, PU.MULTIPLIER, S.PRODUCT_NAME " +
                 "FROM STOCKS_BARCODES AS SB " +
                 "INNER JOIN PRODUCT_UNIT AS PU ON SB.UNIT_ID = PU.PRODUCT_UNIT_ID " +
                 "INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID " +
                 "WHERE SB.BARCODE = '" + barcode + "'";
        
        var result = wrk_query(sql, 'dsn3');
        
        if (!result.STOCK_ID) {
            Utils.showAlert('Ürün Bulunamadı');
            AppConfig.operationFlags.canAdd = false;
            return null;
        }
        
        return this.validateStockAmount(result);
    },
    
    validateStockAmount: function(stockData) {
        var currentAmount = parseFloat(Utils.getElement('all_amount').value);
        var inputAmount = parseFloat(Utils.getElement('add_other_amount').value);
        var maxAmount = parseFloat(Utils.getElement('paket_sayisi').value);
        
        var newAmount = currentAmount + inputAmount;
        
        if (newAmount > maxAmount) {
            Utils.showAlert('Sevk Emrinden Fazla Çıkış Yaptınız !');
            Utils.getElement('all_amount').value = currentAmount - inputAmount;
            Utils.getElement('add_other_amount').focus();
            AppConfig.operationFlags.canAdd = false;
            return null;
        }
        
        Utils.getElement('all_amount').value = newAmount;
        
        AppConfig.currentStock = {
            id: stockData.STOCK_ID,
            name: stockData.PRODUCT_NAME,
            barcode: stockData.BARCODE,
            amount: inputAmount
        };
        
        StockManager.updateButtonState();
        return AppConfig.currentStock;
    }
};
// Stok kontrolü ve ekleme işlemleri
var StockOperations = {
    checkStockAvailability: function() {
        var stockSql, realStock;
        
        if (AppConfig.isShelfEnabled) {
            stockSql = "SELECT ISNULL(S.REAL_STOCK, 0) AS REAL_STOCK " +
                      "FROM GET_STOCK_LAST_SHELF AS S " +
                      "INNER JOIN <cfoutput>#dsn3_alias#</cfoutput>.PRODUCT_PLACE AS P ON S.SHELF_NUMBER = P.PRODUCT_PLACE_ID " +
                      "WHERE P.SHELF_CODE = '" + AppConfig.currentStock.shelfCode + "' " +
                      "AND S.STOCK_ID = " + AppConfig.currentStock.id;
            
            var result = wrk_query(stockSql, 'dsn2');
            realStock = result.REAL_STOCK || 0;
        } else {
            stockSql = "SELECT PRODUCT_STOCK " +
                      "FROM EZGI_GET_STOCK_LOCATION_TOTAL " +
                      "WHERE DEPO = '" + document.form_basket.txt_department_out.value + "' " +
                      "AND STOCK_ID = " + AppConfig.currentStock.id;
            
            var result = wrk_query(stockSql, 'dsn2');
            realStock = result.PRODUCT_STOCK || 0;
        }
        
        return parseFloat(realStock);
    },
    
    updateExistingRow: function() {
        if (AppConfig.rowCount <= 0) return false;
        
        for (var i = 1; i <= AppConfig.rowCount; i++) {
            var stockIdElement = Utils.getElement('stockid' + i);
            var amountElement = Utils.getElement('amount' + i);
            
            if (!stockIdElement || !amountElement) continue;
            
            var shouldUpdate = (stockIdElement.value == AppConfig.currentStock.id);
            
            if (AppConfig.isShelfEnabled) {
                var shelfElement = Utils.getElement('shelf_code' + i);
                shouldUpdate = shouldUpdate && (shelfElement && shelfElement.value == AppConfig.currentStock.shelfCode);
            }
            
            if (shouldUpdate) {
                var currentAmount = parseFloat(amountElement.value);
                var newAmount = currentAmount + AppConfig.currentStock.amount;
                var availableStock = this.checkStockAvailability();
                
                if (availableStock < newAmount) {
                    Utils.showAlert("Yetersiz Stok. Çıkış Lokasyonundaki Stok Miktarı: " + availableStock);
                    if (!AppConfig.isShelfEnabled) {
                        var currentTotalElement = Utils.getElement('all_amount');
                        currentTotalElement.value = parseFloat(currentTotalElement.value) - AppConfig.currentStock.amount;
                    }
                    Utils.getElement('add_other_amount').focus();
                    AppConfig.operationFlags.canAdd = false;
                    return true;
                }
                
                amountElement.value = newAmount;
                AppConfig.operationFlags.canAdd = false;
                return true;
            }
        }
        return false;
    },
    
    validateNewRowStock: function() {
        if (AppConfig.rowCount > 0) return true;
        
        var availableStock = this.checkStockAvailability();
        
        if (availableStock < AppConfig.currentStock.amount) {
            Utils.showAlert("Yetersiz Stok. Çıkış Lokasyonundaki Stok Miktarı: " + availableStock);
            if (!AppConfig.isShelfEnabled) {
                var currentTotalElement = Utils.getElement('all_amount');
                currentTotalElement.value = parseFloat(currentTotalElement.value) - AppConfig.currentStock.amount;
            }
            Utils.getElement('add_other_amount').focus();
            AppConfig.operationFlags.canAdd = false;
            return false;
        }
        
        return true;
    }
};
// Satır ekleme işlemleri
var RowManager = {
    addNewRow: function(barcode) {
        if (!AppConfig.isShelfEnabled) {
            var stockData = StockValidator.getStockByBarcode(barcode);
            if (!stockData) return;
        }
        
        AppConfig.currentStock.amount = parseFloat(Utils.getElement('add_other_amount').value);
        
        // Mevcut satır güncellemeyi kontrol et
        if (StockOperations.updateExistingRow()) {
            this.resetInputs();
            return;
        }
        
        // Yeni satır için stok doğrulaması
        if (!StockOperations.validateNewRowStock()) {
            return;
        }
        
        this.createNewRow();
        this.resetInputs();
    },
    
    createNewRow: function() {
        AppConfig.rowCount++;
        Utils.getElement('row_count').value = AppConfig.rowCount;
        
        var table = Utils.getElement("table1");
        var newRow = table.insertRow(table.rows.length);
        
        // Satır özelliklerini ayarla
        newRow.setAttribute("name", "frm_row" + AppConfig.rowCount);
        newRow.setAttribute("id", "frm_row" + AppConfig.rowCount);
        
        // Hücreleri oluştur
        this.createRowCells(newRow);
    },
    
    createRowCells: function(row) {
        // Barcode hücresi
        var barcodeCell = row.insertCell();
        barcodeCell.innerHTML = this.createHiddenInputs() + this.createBarcodeInput();
        
        // Ürün adı hücresi
        var nameCell = row.insertCell();
        nameCell.innerHTML = this.createProductNameInput();
        
        // Miktar hücresi
        var amountCell = row.insertCell();
        amountCell.innerHTML = this.createAmountInput();
        
        // Raf hücresi (sadece raf modunda)
        if (AppConfig.isShelfEnabled) {
            var shelfCell = row.insertCell();
            shelfCell.innerHTML = this.createShelfInput();
        }
    },
    
    createHiddenInputs: function() {
        return '<input type="hidden" value="' + AppConfig.currentStock.id + '" ' +
               'name="stockid' + AppConfig.rowCount + '" id="stockid' + AppConfig.rowCount + '" />' +
               '<input type="hidden" value="" ' +
               'name="spectmainid' + AppConfig.rowCount + '" id="spectmainid' + AppConfig.rowCount + '" />';
    },
    
    createBarcodeInput: function() {
        return '<input type="text" value="' + AppConfig.currentStock.barcode + '" ' +
               'name="barcod' + AppConfig.rowCount + '" id="barcod' + AppConfig.rowCount + '" ' +
               'size="13" class="boxtext" readonly="yes" />';
    },
    
    createProductNameInput: function() {
        return '<input type="text" value="' + AppConfig.currentStock.name + '" ' +
               'name="stockcode' + AppConfig.rowCount + '" id="stockcode' + AppConfig.rowCount + '" ' +
               'size="13" class="boxtext" readonly="yes" />';
    },
    
    createAmountInput: function() {
        return '<input type="text" style="text-align:center" value="' + AppConfig.currentStock.amount + '" ' +
               'name="amount' + AppConfig.rowCount + '" id="amount' + AppConfig.rowCount + '" ' +
               'size="5" class="boxtext" readonly="yes" />';
    },
    
    createShelfInput: function() {
        return '<input type="text" value="' + AppConfig.currentStock.shelfCode + '" ' +
               'name="shelf_code' + AppConfig.rowCount + '" id="shelf_code' + AppConfig.rowCount + '" ' +
               'size="8" class="boxtext" readonly="yes" style="text-align:right" />';
    },
    
    resetInputs: function() {
        AppConfig.operationFlags.canAdd = true;
        Utils.getElement('add_other_amount').value = '';
        if (AppConfig.isShelfEnabled) {
            Utils.getElement('add_other_shelf').value = '';
        }
        Utils.getElement('add_other_amount').focus();
    }
};
</script>
// Event handlers ve keyboard işlemleri
var EventHandlers = {
    init: function() {
        this.setupKeyboardEvents();
        this.hideHeaders();
    },
    
    setupKeyboardEvents: function() {
        document.onkeydown = this.handleKeyPress;
    },
    
    hideHeaders: function() {
        $(document).ready(function() {
            $(".header").hide();
        });
    },
    
    handleKeyPress: function(e) {
        var keycode = e.which || e.keyCode || (window.event && window.event.keyCode);
        
        if (keycode === 13) { // Enter tuşu
            if (AppConfig.isShelfEnabled) {
                EventHandlers.handleShelfEntry();
            } else {
                EventHandlers.handleBarcodeEntry();
            }
        }
    },
    
    handleShelfEntry: function() {
        var shelfInput = Utils.getElement('add_other_shelf');
        var shelfValue = shelfInput.value.trim();
        
        if (shelfValue.length > 0) {
            ShelfManager.searchShelf(shelfValue);
        } else {
            Utils.showAlert('Raf Barkodu Hatalı');
            shelfInput.value = '';
            shelfInput.focus();
        }
    },
    
    handleBarcodeEntry: function() {
        var barcodeInput = Utils.getElement('add_other_barcod');
        var barcodeValue = barcodeInput.value.trim();
        
        if (barcodeValue.length > 0) {
            RowManager.addNewRow(barcodeValue);
        } else {
            Utils.showAlert('Barkod Hatalı');
            barcodeInput.value = '';
            barcodeInput.focus();
        }
    }
};
// Raf yönetimi işlemleri
var ShelfManager = {
    searchShelf: function(shelfCode) {
        var departmentOut = Utils.getElement('txt_department_out').value;
        
        var shelfSql = "SELECT PRODUCT_PLACE_ID, STORE_ID, LOCATION_ID " +
                      "FROM PRODUCT_PLACE " +
                      "WHERE PLACE_STATUS = 1 AND SHELF_CODE = '" + shelfCode + "'";
        
        var shelfResult = wrk_query(shelfSql, 'dsn3');
        
        if (!shelfResult.recordcount) {
            Utils.showAlert('Seçtiğiniz Raf Bulunamadı!');
            this.resetShelfInput();
            return;
        }
        
        if (!this.validateShelfLocation(shelfResult, departmentOut)) {
            return;
        }
        
        this.processShelfBarcode(shelfCode);
    },
    
    validateShelfLocation: function(shelfResult, departmentOut) {
        var shelfLocation = shelfResult.STORE_ID.toString() + '-' + shelfResult.LOCATION_ID.toString();
        
        if (departmentOut !== shelfLocation) {
            Utils.showAlert('Seçtiğiniz Raf Giriş Lokasyonunda Değildir!');
            this.resetShelfInput();
            return false;
        }
        
        return true;
    },
    
    processShelfBarcode: function(shelfCode) {
        var barcodeInput = Utils.getElement('add_other_barcod');
        var barcodeValue = barcodeInput.value.trim();
        
        if (barcodeValue.length === 0) {
            barcodeInput.focus();
            return;
        }
        
        var productResult = this.getProductByShelfAndBarcode(barcodeValue, shelfCode);
        
        if (!productResult) {
            Utils.showAlert('Ürün Bulunamadı');
            this.resetShelfInput();
            return;
        }
        
        this.validateAndAddProduct(productResult);
    },
    
    getProductByShelfAndBarcode: function(barcode, shelfCode) {
        var sql = "SELECT SB.STOCK_ID, SB.BARCODE, S.PRODUCT_NAME, PP.SHELF_CODE " +
                 "FROM STOCKS_BARCODES AS SB " +
                 "INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID " +
                 "INNER JOIN PRODUCT_PLACE_ROWS AS PPR ON S.PRODUCT_ID = PPR.PRODUCT_ID " +
                 "INNER JOIN PRODUCT_PLACE AS PP ON PPR.PRODUCT_PLACE_ID = PP.PRODUCT_PLACE_ID " +
                 "WHERE SB.BARCODE = '" + barcode + "' AND PP.SHELF_CODE = '" + shelfCode + "'";
        
        var result = wrk_query(sql, 'dsn3');
        
        return result.STOCK_ID ? result : null;
    },
    
    validateAndAddProduct: function(productResult) {
        var currentAmount = parseFloat(Utils.getElement('all_amount').value);
        var inputAmount = parseFloat(Utils.getElement('add_other_amount').value);
        var maxAmount = parseFloat(Utils.getElement('paket_sayisi').value);
        
        var newAmount = currentAmount + inputAmount;
        
        if (newAmount > maxAmount) {
            Utils.showAlert('Sevk Emrinden Fazla Çıkış Yaptınız!');
            Utils.getElement('all_amount').value = currentAmount - inputAmount;
            this.resetShelfInput();
            return;
        }
        
        Utils.getElement('all_amount').value = newAmount;
        
        // Global değişkenleri güncelle
        AppConfig.currentStock = {
            id: productResult.STOCK_ID,
            name: productResult.PRODUCT_NAME,
            barcode: productResult.BARCODE,
            shelfCode: productResult.SHELF_CODE,
            amount: inputAmount
        };
        
        StockManager.updateButtonState();
        RowManager.addNewRow(productResult.BARCODE);
    },
    
    resetShelfInput: function() {
        var shelfInput = Utils.getElement('add_other_shelf');
        shelfInput.value = '';
        shelfInput.focus();
    }
};
</script>
// Form kontrol ve submit işlemleri
var FormController = {
    validateAndSave: function() {
        var departmentOut = document.form_basket.txt_department_out.value;
        
        if (!departmentOut) {
            Utils.showAlert('Depo Seçmelisiniz.');
            return false;
        }
        
        if (departmentOut.indexOf('-') === -1) {
            Utils.showAlert('Lütfen giriş için doğru depo seçiniz.');
            return false;
        }
        
        StockManager.generateActionId();
        this.navigateToSavePage();
    },
    
    navigateToSavePage: function() {
        var baseUrl = '<cfoutput>#request.self#?fuseaction=pda.emptypopup_add_shipping_ambar_stock</cfoutput>';
        var params = this.buildUrlParams();
        window.location.href = baseUrl + '&' + params;
    },
    
    buildUrlParams: function() {
        var params = [
            'shelf_type=<cfoutput>#get_store_type.raf#</cfoutput>',
            'date1=<cfoutput>#attributes.date1#</cfoutput>',
            'date2=<cfoutput>#attributes.date2#</cfoutput>',
            'is_type=<cfoutput>#attributes.is_type#</cfoutput>',
            'keyword=<cfoutput>#attributes.keyword#</cfoutput>',
            'dep_in=<cfoutput>#attributes.department_in_id#</cfoutput>',
            'dep_out=<cfoutput>#attributes.department_out_id#</cfoutput>',
            'ref_no=<cfoutput>#attributes.deliver_paper_no#</cfoutput>',
            'ship_id=<cfoutput>#attributes.ship_id#</cfoutput>',
            'f_stock_id=<cfoutput>#f_stock_id#</cfoutput>',
            'action_id=' + Utils.getElement('action_id').value,
            'fis_tipi=' + document.form_basket.fis_tipi.value,
            'process_cat=' + document.form_basket.process_cat_id.value
        ];
        
        return params.join('&');
    },
    
    confirmAndDelete: function() {
        if (!confirm('Ambar Fişini Silmek İster misiniz?')) {
            return;
        }
        
        var baseUrl = '<cfoutput>#request.self#?fuseaction=pda.emptypopup_del_shipping_ambar_stock</cfoutput>';
        var params = this.buildDeleteParams();
        window.location.href = baseUrl + '&' + params;
    },
    
    buildDeleteParams: function() {
        var params = [
            'shelf_type=<cfoutput>#get_store_type.raf#</cfoutput>',
            'date1=<cfoutput>#attributes.date1#</cfoutput>',
            'date2=<cfoutput>#attributes.date2#</cfoutput>',
            'is_type=<cfoutput>#attributes.is_type#</cfoutput>',
            'keyword=<cfoutput>#attributes.keyword#</cfoutput>',
            'dep_in=<cfoutput>#attributes.department_in_id#</cfoutput>',
            'dep_out=<cfoutput>#attributes.department_out_id#</cfoutput>',
            'ref_no=<cfoutput>#attributes.deliver_paper_no#</cfoutput>',
            'ship_id=<cfoutput>#attributes.ship_id#</cfoutput>',
            'f_stock_id=<cfoutput>#f_stock_id#</cfoutput>',
            'type=1'
        ];
        
        return params.join('&');
    }
};

// Global fonksiyonlar (eski fonksiyon adlarıyla uyumluluk için)
function kontrol_kayit() {
    FormController.validateAndSave();
}

function kontrol_sil() {
    FormController.confirmAndDelete();
}

// Uygulama başlatma
EventHandlers.init();
</script>

// AJAX Query Utility (Legacy Workcube Function - Modernized)
function wrk_query(str_query, data_source, maxrows) {
    var newQuery = {};
    var xhr;
    
    // Default parameters
    data_source = data_source || 'dsn';
    maxrows = maxrows || 0;
    
    // Create XMLHttpRequest
    if (window.XMLHttpRequest) {
        try {
            xhr = new XMLHttpRequest();
        } catch (e) {
            xhr = false;
        }
    } else if (window.ActiveXObject) {
        try {
            xhr = new ActiveXObject("Msxml2.XMLHTTP");
        } catch (e) {
            try {
                xhr = new ActiveXObject("Microsoft.XMLHTTP");
            } catch (e) {
                xhr = false;
            }
        }
    }
    
    if (!xhr) return false;
    
    var url = '/index.cfm?fuseaction=objects2.emptypopup_get_js_query&isAjax=1&xmlhttp=1';
    
    xhr.open("POST", url, false);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.setRequestHeader('pragma', 'nocache');
    
    // Prepare query data
    var queryData = 'str_sql=' + (encodeURI(str_query).indexOf('+') === -1 ? 
                     encodeURI(str_query) : encodeURIComponent(str_query)) +
                    '&data_source=' + data_source +
                    '&maxrows=' + maxrows;
    
    xhr.send(queryData);
    
    if (xhr.readyState === 4 && xhr.status === 200) {
        try {
            eval(xhr.responseText.replace(/\u200B/g, ''));
            newQuery = get_js_query;
        } catch (e) {
            newQuery = false;
        }
    }
    
    return newQuery;
}