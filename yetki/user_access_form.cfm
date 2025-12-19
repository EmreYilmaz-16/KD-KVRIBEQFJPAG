<cfparam name="brand_code" default="">    
<cfparam name="attributes.marks" default="">    
<cfquery name="get_mark_names" datasource="#dsn1#"><!--- Markalar --->
	SELECT
		PB.BRAND_ID,
        PB.BRAND_NAME
	FROM
		PRODUCT_BRANDS PB
		,PRODUCT_BRANDS_OUR_COMPANY PBO
	WHERE
		PB.BRAND_ID = PBO.BRAND_ID
		AND PBO.OUR_COMPANY_ID =  #session.ep.company_id# 
	ORDER BY BRAND_NAME
</cfquery>

<cfquery name="get_companies" datasource="#dsn#"><!--- Firmalar --->
	SELECT
		COMPANY_ID PAR_ID,
		NICKNAME PAR_NAME
	FROM
		COMPANY
	WHERE
		
		
	ORDER BY NICKNAME
</cfquery>

<title>Kullanıcı Erişim Yönetimi</title>
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f5f5;
            padding: 20px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        h1 {
            color: #333;
            margin-bottom: 20px;
            text-align: center;
        }
        .card {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            padding: 20px;
            margin-bottom: 20px;
        }
        .card h2 {
            color: #2196F3;
            margin-bottom: 15px;
            border-bottom: 2px solid #2196F3;
            padding-bottom: 10px;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            color: #555;
            font-weight: 500;
        }
        .form-group input, .form-group select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }
        .form-group input:focus, .form-group select:focus {
            border-color: #2196F3;
            outline: none;
        }
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            margin-right: 10px;
            margin-bottom: 10px;
        }
        .btn-primary {
            background-color: #2196F3;
            color: white;
        }
        .btn-success {
            background-color: #4CAF50;
            color: white;
        }
        .btn-danger {
            background-color: #f44336;
            color: white;
        }
        .btn-warning {
            background-color: #ff9800;
            color: white;
        }
        .btn:hover {
            opacity: 0.9;
        }
        .checkbox-group {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }
        .checkbox-item {
            display: flex;
            align-items: center;
            background: #f5f5f5;
            padding: 8px 12px;
            border-radius: 4px;
        }
        .checkbox-item input {
            width: auto;
            margin-right: 8px;
        }
        .result-box {
            background: #f5f5f5;
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 15px;
            margin-top: 15px;
            max-height: 300px;
            overflow-y: auto;
        }
        .result-box pre {
            white-space: pre-wrap;
            word-wrap: break-word;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        table th, table td {
            padding: 10px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        table th {
            background-color: #2196F3;
            color: white;
        }
        table tr:hover {
            background-color: #f5f5f5;
        }
        .alert {
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 15px;
        }
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .alert-error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .row {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
        }
        .col-6 {
            flex: 1;
            min-width: 300px;
        }
        .hidden {
            display: none;
        }
    </style>

    <div class="container">
        <h1>🔐 Kullanıcı Erişim Yönetimi</h1>
        
        <div id="alertBox" class="alert hidden"></div>
        
        <div class="row">
            <div class="col-6">
                <!--- Yeni Erişim Oluştur --->
                <div class="card">
                    <h2>➕ Yeni Erişim Oluştur</h2>
                    <form id="createAccessForm" name="createAccessForm">
                      <div class="form-group" id="item-sales_emp">
						<label class="col col-12">Satış Yapan </label>
						<div class="col col-12">
							<div class="input-group">
								<input type="hidden" name="sales_emp_id" id="sales_emp_id" value="35">
								<input name="sales_emp" type="text" id="sales_emp" onfocus="AutoComplete_Create('sales_emp','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','sales_emp_id','','3','120');" value="Emre Yılmaz" autocomplete="off" style=""><div id="sales_emp_div_2" name="sales_emp_div_2" class="completeListbox" autocomplete="on" style="width: 401px; max-height: 150px; overflow: auto; position: absolute; left: 441.364px; top: 211.364px; z-index: 159; display: none;"></div>
								<span class="input-group-text btnPointer icon-ellipsis" onclick="openBoxDraggable('index.cfm?fuseaction=objects.popup_list_positions&field_emp_id=createAccessForm.sales_emp_id&field_name=createAccessForm.sales_emp&select_list=1');"></span>
							</div>
						</div>
					</div>
                        <div class="form-group">
                            <label for="accessType">Erişim Tipi:</label>
                            <select id="accessType" name="accessType" required>
                                <option value="">Seçiniz...</option>
                                <option value="purchase">Satın Alma (Purchase)</option>
                                <option value="sales">Satış (Sales)</option>                          
                            </select>
                        </div>
                       <div class="form-group">
                                        <label class="col col-12 col-xs-12"><cf_get_lang dictionary_id='58847.Marka'></label>
                                        <div class="col col-12">
                                            <select name="marks" id="marks" multiple="multiple" style="width:170px;height:106px">
                                                <cfoutput query="get_mark_names">
                                                    <option value="#BRAND_ID#"<cfif listfind(attributes.marks,BRAND_ID)>selected</cfif>>#BRAND_NAME#</option>
                                                </cfoutput>
                                            </select>
                                        </div>	
                                    </div>
                       <div class="form-group" id="item-OFFER_ID">
                    <label style="display:none;">Teklif İstenenler </label>
                        
<input type="hidden" name="rows" id="rows" value="0">


        <div class="ui-scroll">
        	<table id="ajax_list_7522694" class="ajax_list ui-form tablesorter tablesorter-default tablesorter920aa3e92968f" sort="true" role="grid">
    
	<thead>
		
			<tr role="row" class="tablesorter-headerRow">
				<th width="20" data-column="0" class="tablesorter-header tablesorter-headerUnSorted" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="ajax_list_7522694" unselectable="on" aria-sort="none" aria-label=": No sort applied, activate to apply an ascending sort" style="user-select: none;"><div class="tablesorter-header-inner">
					<a href="javascript://" onclick="try{opener_control();}catch(e){};openBoxDraggable('index.cfm?fuseaction=objects.popup_list_pars_multiuser&field_emp_id=to_emp_ids&field_pos_id=to_pos_ids&field_pos_code=to_pos_codes&field_par_id=to_par_ids&field_company_id=to_comp_ids&field_cons_id=to_cons_ids&to_title=1&select_list=7,8&row_count=form_baskettbl_to_names_row_count&table_name=form_baskettbl_to_names&table_row_name=form_basketworkcube_to_row&field_grp_id=form_basketto_grp_ids&field_wgrp_id=form_basketto_wgrp_ids&function_row_name=form_basketworkcube_to_delRow&comp_id_list='+document.getElementById('comp_id_list').value);"><i class="fa fa-plus" title="Ekle " alt="Ekle "></i></a>
				</div></th>
				<th data-column="1" class="tablesorter-header tablesorter-headerUnSorted" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="ajax_list_7522694" unselectable="on" aria-sort="none" aria-label="Teklif İstenenler: No sort applied, activate to apply an ascending sort" style="user-select: none;"><div class="tablesorter-header-inner">Yetkili Olduğu Firmalar </div></th>
				<th data-column="2" class="tablesorter-header tablesorter-headerUnSorted" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="ajax_list_7522694" unselectable="on" aria-sort="none" aria-label=": No sort applied, activate to apply an ascending sort" style="user-select: none;"><div class="tablesorter-header-inner"></div></th>
				<th data-column="3" class="tablesorter-header tablesorter-headerUnSorted" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="ajax_list_7522694" unselectable="on" aria-sort="none" aria-label=": No sort applied, activate to apply an ascending sort" style="user-select: none;"><div class="tablesorter-header-inner"></div></th>
				<th data-column="4" class="tablesorter-header tablesorter-headerUnSorted" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="ajax_list_7522694" unselectable="on" aria-sort="none" aria-label=": No sort applied, activate to apply an ascending sort" style="user-select: none;"><div class="tablesorter-header-inner"></div></th>
				<input type="hidden" name="comp_id_list" id="comp_id_list" value="">
				<input type="hidden" name="form_baskettbl_to_names_row_count" id="form_baskettbl_to_names_row_count" value="0">
			</tr>
		
	</thead>
		
						
				<tbody id="form_baskettbl_to_names" width="100%" aria-live="polite" aria-relevant="all"></tbody>	
			 
        	</table>
        </div>
        
        <script>
            jQuery.moveColumn = function (table, from, to) {
                var rows = jQuery('tr', table);
                var cols;
                rows.each(function() {
                cols = jQuery(this).children('th, td');
                cols.eq(from).detach().insertBefore(cols.eq(to));
                });
            }
		
            if($('.controllerEvents').length){
                if($('.controllerEvents').attr("id") == "list"){
                    var th = $('table#ajax_list_7522694:not([is_child]) > thead tr th');
                        th.each(function(){
                            if($(this).attr("id") == undefined)
                            {
                                $(this).attr("id","th_"+$(this).index());
                            };
                    });
                }
            }

            	
        </script>
        
<script type="text/javascript">
	
		cus_tag_max_row_to=0;
		function form_basketworkcube_to_delRow(yer,int_row)
		{ 
			var ver = navigator.appVersion;
			
				flag_custag=document.all.to_par_ids.length;
			
			if(flag_custag > 0)
			{
				if (ver.indexOf("MSIE") != -1)
				{
					try{document.all.to_pos_ids[yer-1].value = '';}catch(e){}
					try{document.all.to_pos_codes[yer-1].value = '';}catch(e){}
					try{document.all.to_emp_ids[yer-1].value = '';}catch(e){}
					try{document.all.to_comp_ids[yer-1].value = '';}catch(e){}
					try{document.all.to_par_ids[yer-1].value = '';}catch(e){}
					try{document.all.to_cons_ids[yer-1].value = '';}catch(e){}
					try{document.all.form_basketto_wgrp_ids[yer-1].value = '';}catch(e){}
				}
				else
				{
					for(var i=0;i<document.all.to_emp_ids.lenght;i++)
					{
						if(document.all.to_emp_ids[i].value==int_row)
						{
							try{document.all.to_pos_ids[i].value = '';}catch(e){}
							try{document.all.to_pos_codes[i].value = '';}catch(e){}
							try{document.all.to_emp_ids[i].value = '';}catch(e){}
							try{document.all.to_comp_ids[i].value = '';}catch(e){}
							try{document.all.to_par_ids[i].value = '';}catch(e){}
							try{document.all.to_cons_ids[i].value = '';}catch(e){}
							try{document.all.form_basketto_wgrp_ids[i].value = '';}catch(e){}
							break;
						}	
					}
					try
					{
						for(var i=0;i<document.all.to_comp_ids.length;i++)
						{
							if(document.all.to_comp_ids[i].value==int_row)
							{
								try{document.all.to_comp_ids[i].value = '';}catch(e){}
								try{document.all.to_par_ids[i].value = '';}catch(e){}
								break;
							}
						}
					}catch(e){}
				}
			}
			else
			{
				try{document.all.to_pos_ids.value = '';}catch(e){}
				try{document.all.to_pos_codes.value = '';}catch(e){}
				try{document.all.to_emp_ids.value = '';}catch(e){}
				try{document.all.to_comp_ids.value = '';}catch(e){}
				try{document.all.to_par_ids.value = '';}catch(e){}
				try{document.all.to_cons_ids.value = '';}catch(e){}
				try{document.all.form_basketto_wgrp_ids.value = '';}catch(e){}
			}
			var my_element = document.getElementById('form_basketworkcube_to_row' + yer);
			my_element.parentNode.removeChild(my_element);
			document.getElementById('form_baskettbl_to_names_row_count').value = yer - 1;
		}

	
function control_related_offer(a,b)//cariden daha once teklif istenip istenmedigini kontrol eder
{
	
		if(a >= 1)
		{
			alert("Cariden Daha Önce Teklif İstenmiştir!");
			return false;
		}
		else
		{
			
		}
	
}
function hepsini_sil(option)
{
	if(option == 1)
	{
		for(i=1;i<=document.getElementById('form_baskettbl_to_names_row_count').value;i++)
		{
				var my_element = document.getElementById('form_basketworkcube_to_row' + i);
				my_element.parentNode.removeChild(my_element);
		}
		document.getElementById('hepsini_sil_id').style.display='none';
	}
	else if(option == 2)
	{
		for(i=0;i<=document.getElementById('tbl_cc_names_row_count').value;i++)
		{
				var my_element = document.getElementById('form_basketworkcube_cc_row' + i);
				my_element.parentNode.removeChild(my_element);
		}
		document.getElementById('hepsini_sil_id2').style.display='none';
	}
	else
	{
		for(i=0;i<=document.getElementById('tbl_cc2_names_row_count').value;i++)
		{
				var my_element = document.getElementById('form_basketworkcube_cc2_row' + i);
				my_element.parentNode.removeChild(my_element);
		}
		document.getElementById('hepsini_sil_id3').style.display='none';
	}
}
</script> 
                </div>
                        <button type="submit" class="btn btn-success">Erişim Oluştur</button>
                    </form>
                </div>
            </div>
            
            <div class="col-6">
                <!--- Kullanıcı Erişimlerini Sorgula --->
                <div class="card">
                    <h2>🔍 Erişim Sorgula</h2>
                    <div class="form-group">
                        <label for="searchUserId">Kullanıcı ID:</label>
                        <input type="number" id="searchUserId">
                    </div>
                    <button class="btn btn-primary" onclick="getUserAccessDetails()">Kullanıcı Erişimlerini Getir</button>
                    <button class="btn btn-warning" onclick="getAllUserAccess()">Tüm Erişimleri Getir</button>
                </div>
                
                <!--- Erişim Güncelle/Sil --->
                <div class="card">
                    <h2>✏️ Erişim Güncelle/Sil</h2>
                    <div class="form-group">
                        <label for="updateAccessId">Erişim ID:</label>
                        <input type="number" id="updateAccessId" readonly style="background-color: #eee;">
                    </div>
                    <div class="form-group">
                        <label>Kullanıcı:</label>
                        <div class="input-group">
                            <input type="hidden" name="update_emp_id" id="update_emp_id" value="">
                            <input name="update_emp" type="text" id="update_emp" onfocus="AutoComplete_Create('update_emp','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','update_emp_id','','3','120');" value="" autocomplete="off">
                            <span class="input-group-text btnPointer icon-ellipsis" onclick="openBoxDraggable('index.cfm?fuseaction=objects.popup_list_positions&field_emp_id=update_emp_id&field_name=update_emp&select_list=1');"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="updateAccessType">Yeni Erişim Tipi:</label>
                        <select id="updateAccessType">
                            <option value="">Seçiniz...</option>
                            <option value="purchase">Satın Alma (Purchase)</option>
                            <option value="sales">Satış (Sales)</option>
                        </select>
                    </div>
                    <button class="btn btn-primary" onclick="updateUserAccess()">Güncelle</button>
                    <button class="btn btn-danger" onclick="deleteUserAccess()">Sil</button>
                    <button class="btn btn-warning" onclick="clearUpdateForm()">Temizle</button>
                </div>
            </div>
        </div>
        
        <!--- Sonuçlar --->
        <div class="card">
            <h2>📋 Sonuçlar</h2>
            <div class="result-box">
                <div id="resultContainer">
                    <p style="color: #999; text-align: center;">Henüz sonuç yok</p>
                </div>
            </div>
        </div>
        
        <!--- Marka/Firma Ekleme Bölümü --->
        <div class="row">
            <div class="col-6">
                <div class="card" id="addBrandCard" style="display:none;">
                    <h2>➕ Marka Ekle (Erişim #<span id="brandAccessId"></span>)</h2>
                    <div class="form-group">
                        <label>Eklenecek Marka:</label>
                        <select id="newBrandSelect" style="width:100%; padding:10px;">
                            <option value="">Seçiniz...</option>
                            <cfoutput query="get_mark_names">
                                <option value="#BRAND_ID#">#BRAND_NAME#</option>
                            </cfoutput>
                        </select>
                    </div>
                    <button class="btn btn-success" onclick="addBrandToAccess()">Marka Ekle</button>
                    <button class="btn btn-warning" onclick="hideAddBrandForm()">İptal</button>
                </div>
            </div>
            <div class="col-6">
                <div class="card" id="addCompanyCard" style="display:none;">
                    <h2>➕ Firma Ekle (Erişim #<span id="companyAccessId"></span>)</h2>
                    <div class="form-group">
                        <label>Eklenecek Firma:</label>
                        <select id="newCompanySelect" style="width:100%; padding:10px;">
                            <option value="">Seçiniz...</option>
                            <cfoutput query="get_companies">
                                <option value="#PAR_ID#">#PAR_NAME#</option>
                            </cfoutput>
                        </select>
                    </div>
                    <button class="btn btn-success" onclick="addCompanyToAccess()">Firma Ekle</button>
                    <button class="btn btn-warning" onclick="hideAddCompanyForm()">İptal</button>
                </div>
            </div>
        </div>
        
        <!--- Erişim Listesi --->
        <div class="card">
            <h2>📊 Erişim Listesi</h2>
            <div id="accessListContainer">
                <table id="accessTable">
                    <thead>
                        <tr>
                            <th>Access ID</th>
                            <th>Kullanıcı</th>
                            <th>Erişim Tipi</th>
                            <th>Markalar</th>
                            <th>Firmalar</th>
                            <th>İşlemler</th>
                        </tr>
                    </thead>
                    <tbody id="accessTableBody">
                        <tr>
                            <td colspan="6" style="text-align: center; color: #999;">Veri yüklemek için "Tüm Erişimleri Getir" butonuna tıklayın</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        const API_URL = '/addOns/Partner/yetki/user_access_api.cfm';
        
        // Alert göster
        function showAlert(message, isSuccess) {
            const alertBox = document.getElementById('alertBox');
            alertBox.className = isSuccess ? 'alert alert-success' : 'alert alert-error';
            alertBox.textContent = message;
            alertBox.classList.remove('hidden');
            
            setTimeout(() => {
                alertBox.classList.add('hidden');
            }, 5000);
        }
        
        // Sonuç göster
        function showResult(data) {
            const container = document.getElementById('resultContainer');
            container.innerHTML = '<pre>' + JSON.stringify(data, null, 2) + '</pre>';
        }
        
        // API çağrısı yap
        async function apiCall(action, data = {}) {
            console.log('API Call:', action, data);
            const formData = new FormData();
            formData.append('action', action);
            
            for (const key in data) {
                formData.append(key, data[key]);
            }
            
            try {
                const response = await fetch(API_URL, {
                    method: 'POST',
                    body: formData
                });
                console.log('Response status:', response.status);
                const text = await response.text();
                console.log('Response text:', text);
                
                try {
                    const result = JSON.parse(text);
                    // ColdFusion büyük harfli key döndürüyor, küçük harfe çeviriyoruz
                    return {
                        success: result.SUCCESS,
                        message: result.MESSAGE,
                        data: result.DATA
                    };
                } catch (parseError) {
                    console.error('JSON Parse Error:', parseError);
                    return { success: false, message: 'JSON parse hatası: ' + text.substring(0, 200) };
                }
            } catch (error) {
                console.error('Fetch Error:', error);
                return { success: false, message: 'Bağlantı hatası: ' + error.message };
            }
        }
        
        // Seçili marka değerlerini al (multiple select için)
        function getSelectedMarks() {
            const select = document.getElementById('marks');
            const selectedOptions = Array.from(select.selectedOptions);
            return selectedOptions.map(option => option.value).join(',');
        }
        
        // Seçili şirket ID'lerini al (dinamik tablodan - PAR_ID kullanılıyor)
        function getSelectedCompanyIds() {
            const parInputs = document.querySelectorAll('input[name="to_par_ids"]');
            const companyIds = [];
            parInputs.forEach(input => {
                if (input.value && input.value.trim() !== '') {
                    companyIds.push(input.value);
                }
            });
            return companyIds.join(',');
        }
        
        // Yeni erişim oluştur
        document.getElementById('createAccessForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const userId = document.getElementById('sales_emp_id').value;
            const accessType = document.getElementById('accessType').value;
            const brandIds = getSelectedMarks();
            const companyIds = getSelectedCompanyIds();
            
            if (!userId || userId == '0') {
                showAlert('Lütfen bir kullanıcı seçin', false);
                return;
            }
            
            if (!accessType) {
                showAlert('Lütfen erişim tipi seçin', false);
                return;
            }
            
            const result = await apiCall('createUserAccess', {
                userId: userId,
                accessType: accessType,
                brandIds: brandIds,
                companyIds: companyIds
            });
            
            showAlert(result.message, result.success);
            showResult(result);
            
            if (result.success) {
                this.reset();
                getAllUserAccess();
            }
        });
        
        // Tüm erişimleri getir
        async function getAllUserAccess() {
            console.log('getAllUserAccess çağrıldı');
            showResult({ message: 'Yükleniyor...' });
            
            const result = await apiCall('getAllUserAccess');
            console.log('getAllUserAccess sonuç:', result);
            showResult(result);
            
            if (result.success && result.data) {
                renderAccessTable(result.data);
            } else {
                showAlert(result.message || 'Veri alınamadı', false);
            }
        }
        
        // Kullanıcı erişim detaylarını getir
        async function getUserAccessDetails() {
            const userId = document.getElementById('searchUserId').value;
            
            if (!userId) {
                showAlert('Lütfen kullanıcı ID girin', false);
                return;
            }
            
            const result = await apiCall('getUserAccessDetails', { userId: userId });
            showAlert(result.message, result.success);
            showResult(result);
        }
        
        // Erişimi güncelle
        async function updateUserAccess() {
            const accessId = document.getElementById('updateAccessId').value;
            const userId = document.getElementById('update_emp_id').value;
            const accessType = document.getElementById('updateAccessType').value;
            
            if (!accessId) {
                showAlert('Lütfen listeden bir erişim seçin', false);
                return;
            }
            
            if (!userId || userId == '0' || userId == '') {
                showAlert('Lütfen bir kullanıcı seçin', false);
                return;
            }
            
            if (!accessType) {
                showAlert('Lütfen erişim tipi seçin', false);
                return;
            }
            
            const result = await apiCall('updateUserAccess', {
                accessId: accessId,
                userId: userId,
                accessType: accessType
            });
            
            showAlert(result.message, result.success);
            showResult(result);
            
            if (result.success) {
                clearUpdateForm();
                getAllUserAccess();
            }
        }
        
        // Güncelleme formunu temizle
        function clearUpdateForm() {
            document.getElementById('updateAccessId').value = '';
            document.getElementById('update_emp_id').value = '';
            document.getElementById('update_emp').value = '';
            document.getElementById('updateAccessType').value = '';
        }
        
        // Erişimi sil
        async function deleteUserAccess() {
            const accessId = document.getElementById('updateAccessId').value;
            
            if (!accessId) {
                showAlert('Lütfen erişim ID girin', false);
                return;
            }
            
            if (!confirm('Bu erişimi silmek istediğinizden emin misiniz?')) {
                return;
            }
            
            const result = await apiCall('deleteUserAccess', { accessId: accessId });
            showAlert(result.message, result.success);
            showResult(result);
            
            if (result.success) {
                getAllUserAccess();
            }
        }
        
        // Erişim tablosunu render et
        function renderAccessTable(data) {
            const tbody = document.getElementById('accessTableBody');
            
            if (!data || data.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; color: #999;">Kayıt bulunamadı</td></tr>';
                return;
            }
            
            tbody.innerHTML = data.map(item => `
                <tr>
                    <td>${item.ACCESS_ID}</td>
                    <td>${item.USER_NAME || 'ID: ' + item.USER_ID}</td>
                    <td>${getAccessTypeLabel(item.ACCESS_TYPE)}</td>
                    <td><button class="btn btn-primary" onclick="loadBrands(${item.ACCESS_ID})">Göster</button></td>
                    <td><button class="btn btn-primary" onclick="loadCompanies(${item.ACCESS_ID})">Göster</button></td>
                    <td>
                        <button class="btn btn-warning" onclick="editAccess(${item.ACCESS_ID}, ${item.USER_ID}, '${item.ACCESS_TYPE}', '${(item.USER_NAME || '').replace(/'/g, "\\'")}')">Düzenle</button>
                        <button class="btn btn-danger" onclick="quickDelete(${item.ACCESS_ID})">Sil</button>
                    </td>
                </tr>
            `).join('');
        }
        
        // Erişim tipi etiketini getir
        function getAccessTypeLabel(type) {
            const labels = {
                'purchase': 'Satın Alma',
                'sales': 'Satış'
            };
            return labels[type] || type;
        }
        
        // Düzenleme formunu doldur
        function editAccess(accessId, userId, accessType, userName) {
            document.getElementById('updateAccessId').value = accessId;
            document.getElementById('update_emp_id').value = userId;
            document.getElementById('update_emp').value = userName || '';
            document.getElementById('updateAccessType').value = accessType;
            
            // Forma scroll yap
            document.getElementById('updateAccessId').scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
        
        // Hızlı silme
        async function quickDelete(accessId) {
            if (!confirm('Bu erişimi silmek istediğinizden emin misiniz?')) {
                return;
            }
            
            const result = await apiCall('deleteUserAccess', { accessId: accessId });
            showAlert(result.message, result.success);
            
            if (result.success) {
                getAllUserAccess();
            }
        }
        
        // Aktif erişim ID'sini sakla (marka/firma silme işlemleri için)
        let currentAccessId = null;
        
        // Markaları yükle ve göster (silme butonlarıyla)
        async function loadBrands(accessId) {
            currentAccessId = accessId;
            const result = await apiCall('getBrandsByAccessId', { accessId: accessId });
            
            let html = '<h4>Erişim #' + accessId + ' - Markalar <button class="btn btn-success" style="padding:5px 15px; font-size:12px; margin-left:10px;" onclick="showAddBrandForm(' + accessId + ')">+ Yeni Marka Ekle</button></h4>';
            
            if (result.success && result.data && result.data.length > 0) {
                html += '<table style="width:100%; margin-top:10px;">';
                html += '<tr><th>Marka ID</th><th>Marka Adı</th><th>İşlem</th></tr>';
                
                result.data.forEach(brand => {
                    html += '<tr>';
                    html += '<td>' + brand.BRAND_ID + '</td>';
                    html += '<td>' + (brand.BRAND_NAME || '-') + '</td>';
                    html += '<td><button class="btn btn-danger" style="padding:5px 10px; font-size:12px;" onclick="removeBrand(' + accessId + ', ' + brand.BRAND_ID + ')">Sil</button></td>';
                    html += '</tr>';
                });
                
                html += '</table>';
            } else {
                html += '<p style="color:#999; margin-top:10px;">Henüz marka eklenmemiş</p>';
            }
            
            document.getElementById('resultContainer').innerHTML = html;
        }
        
        // Şirketleri yükle ve göster (silme butonlarıyla)
        async function loadCompanies(accessId) {
            currentAccessId = accessId;
            const result = await apiCall('getCompaniesByAccessId', { accessId: accessId });
            
            let html = '<h4>Erişim #' + accessId + ' - Firmalar <button class="btn btn-success" style="padding:5px 15px; font-size:12px; margin-left:10px;" onclick="showAddCompanyForm(' + accessId + ')">+ Yeni Firma Ekle</button></h4>';
            
            if (result.success && result.data && result.data.length > 0) {
                html += '<table style="width:100%; margin-top:10px;">';
                html += '<tr><th>Firma ID</th><th>Firma Adı</th><th>İşlem</th></tr>';
                
                result.data.forEach(company => {
                    html += '<tr>';
                    html += '<td>' + company.COMPANY_ID + '</td>';
                    html += '<td>' + (company.COMPANY_NAME || '-') + '</td>';
                    html += '<td><button class="btn btn-danger" style="padding:5px 10px; font-size:12px;" onclick="removeCompany(' + accessId + ', ' + company.COMPANY_ID + ')">Sil</button></td>';
                    html += '</tr>';
                });
                
                html += '</table>';
            } else {
                html += '<p style="color:#999; margin-top:10px;">Henüz firma eklenmemiş</p>';
            }
            
            document.getElementById('resultContainer').innerHTML = html;
        }
        
        // Marka sil
        async function removeBrand(accessId, brandId) {
            if (!confirm('Bu markayı erişimden kaldırmak istediğinizden emin misiniz?')) {
                return;
            }
            
            const result = await apiCall('removeBrandFromAccess', { 
                accessId: accessId, 
                brandId: brandId 
            });
            
            showAlert(result.message, result.success);
            
            if (result.success) {
                // Marka listesini yenile
                loadBrands(accessId);
            }
        }
        
        // Firma sil
        async function removeCompany(accessId, companyId) {
            if (!confirm('Bu firmayı erişimden kaldırmak istediğinizden emin misiniz?')) {
                return;
            }
            
            const result = await apiCall('removeCompanyFromAccess', { 
                accessId: accessId, 
                companyId: companyId 
            });
            
            showAlert(result.message, result.success);
            
            if (result.success) {
                // Firma listesini yenile
                loadCompanies(accessId);
            }
        }
        
        // ==================== MARKA EKLEME ====================
        
        // Marka ekleme formunu göster
        function showAddBrandForm(accessId) {
            currentAccessId = accessId;
            document.getElementById('brandAccessId').textContent = accessId;
            document.getElementById('newBrandSelect').value = '';
            document.getElementById('addBrandCard').style.display = 'block';
            document.getElementById('addBrandCard').scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
        
        // Marka ekleme formunu gizle
        function hideAddBrandForm() {
            document.getElementById('addBrandCard').style.display = 'none';
        }
        
        // Erişime marka ekle
        async function addBrandToAccess() {
            const brandId = document.getElementById('newBrandSelect').value;
            
            if (!brandId) {
                showAlert('Lütfen bir marka seçin', false);
                return;
            }
            
            if (!currentAccessId) {
                showAlert('Erişim ID bulunamadı', false);
                return;
            }
            
            const result = await apiCall('addBrandToAccess', {
                accessId: currentAccessId,
                brandId: brandId
            });
            
            showAlert(result.message, result.success);
            
            if (result.success) {
                hideAddBrandForm();
                loadBrands(currentAccessId);
            }
        }
        
        // ==================== FİRMA EKLEME ====================
        
        // Firma ekleme formunu göster
        function showAddCompanyForm(accessId) {
            currentAccessId = accessId;
            document.getElementById('companyAccessId').textContent = accessId;
            document.getElementById('newCompanySelect').value = '';
            document.getElementById('addCompanyCard').style.display = 'block';
            document.getElementById('addCompanyCard').scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
        
        // Firma ekleme formunu gizle
        function hideAddCompanyForm() {
            document.getElementById('addCompanyCard').style.display = 'none';
        }
        
        // Erişime firma ekle
        async function addCompanyToAccess() {
            const companyId = document.getElementById('newCompanySelect').value;
            
            if (!companyId) {
                showAlert('Lütfen bir firma seçin', false);
                return;
            }
            
            if (!currentAccessId) {
                showAlert('Erişim ID bulunamadı', false);
                return;
            }
            
            const result = await apiCall('addCompanyToAccess', {
                accessId: currentAccessId,
                companyId: companyId
            });
            
            showAlert(result.message, result.success);
            
            if (result.success) {
                hideAddCompanyForm();
                loadCompanies(currentAccessId);
            }
        }
        
        // Sayfa yüklendiğinde tüm erişimleri getir
        document.addEventListener('DOMContentLoaded', function() {
            getAllUserAccess();
        });
    </script>

