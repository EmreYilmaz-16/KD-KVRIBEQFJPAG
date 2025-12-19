<cfparam name="brand_code" default="">    
<cfparam name="brand_id" default="">    
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
                    <form id="createAccessForm">
                      <div class="form-group" id="item-sales_emp">
						<label class="col col-12">Satış Yapan </label>
						<div class="col col-12">
							<div class="input-group">
								<input type="hidden" name="sales_emp_id" id="sales_emp_id" value="35">
								<input name="sales_emp" type="text" id="sales_emp" onfocus="AutoComplete_Create('sales_emp','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','sales_emp_id','','3','120');" value="Emre Yılmaz" autocomplete="off" style=""><div id="sales_emp_div_2" name="sales_emp_div_2" class="completeListbox" autocomplete="on" style="width: 401px; max-height: 150px; overflow: auto; position: absolute; left: 441.364px; top: 211.364px; z-index: 159; display: none;"></div>
								<span class="input-group-text btnPointer icon-ellipsis" onclick="openBoxDraggable('index.cfm?fuseaction=objects.popup_list_positions&field_emp_id=list_offer.sales_emp_id&field_name=list_offer.sales_emp&select_list=1');"></span>
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
                        <div class="form-group" id="item-brand_name">
                                    <label class=""><cf_get_lang dictionary_id='58847.Marka'></label>
                                    <div class=""> 
                                        <input type="hidden" name="brand_code" id="brand_code" value="<cfoutput>#brand_code#</cfoutput>">
                                        <cf_wrkProductBrand
                                        returnInputValue="brand_id,brand_name,brand_code"
                                        returnQueryValue="BRAND_ID,BRAND_NAME,BRAND_CODE"
                                        width="120"
                                        compenent_name="getProductBrand"               
                                        boxwidth="300"
                                        boxheight="150"
                                        is_internet="1"
                                        brand_code="1"
                                        brand_ID="#brand_id#">
                                    </div>
                                </div>	
                        <div class="form-group">
                            <label>Şirketler:</label>
                            <div class="checkbox-group" id="companyCheckboxes">
                                <div class="checkbox-item">
                                    <input type="checkbox" name="companyIds" value="1" id="company1">
                                    <label for="company1">Şirket 1</label>
                                </div>
                                <div class="checkbox-item">
                                    <input type="checkbox" name="companyIds" value="2" id="company2">
                                    <label for="company2">Şirket 2</label>
                                </div>
                                <div class="checkbox-item">
                                    <input type="checkbox" name="companyIds" value="3" id="company3">
                                    <label for="company3">Şirket 3</label>
                                </div>
                                <div class="checkbox-item">
                                    <input type="checkbox" name="companyIds" value="4" id="company4">
                                    <label for="company4">Şirket 4</label>
                                </div>
                            </div>
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
                        <input type="number" id="updateAccessId">
                    </div>
                    <div class="form-group">
                        <label for="updateUserId">Yeni Kullanıcı ID:</label>
                        <input type="number" id="updateUserId">
                    </div>
                    <div class="form-group">
                        <label for="updateAccessType">Yeni Erişim Tipi:</label>
                        <select id="updateAccessType">
                            <option value="">Seçiniz...</option>
                            <option value="purchase">Satın Alma (Purchase)</option>
                            <option value="sales">Satış (Sales)</option>
                            <option value="inventory">Envanter (Inventory)</option>
                            <option value="reporting">Raporlama (Reporting)</option>
                            <option value="admin">Yönetici (Admin)</option>
                        </select>
                    </div>
                    <button class="btn btn-primary" onclick="updateUserAccess()">Güncelle</button>
                    <button class="btn btn-danger" onclick="deleteUserAccess()">Sil</button>
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
        
        <!--- Erişim Listesi --->
        <div class="card">
            <h2>📊 Erişim Listesi</h2>
            <div id="accessListContainer">
                <table id="accessTable">
                    <thead>
                        <tr>
                            <th>Access ID</th>
                            <th>User ID</th>
                            <th>Erişim Tipi</th>
                            <th>Markalar</th>
                            <th>Şirketler</th>
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
        const API_URL = 'user_access_api.cfm';
        
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
                const result = await response.json();
                return result;
            } catch (error) {
                return { success: false, message: 'Bağlantı hatası: ' + error.message };
            }
        }
        
        // Checkbox değerlerini al
        function getCheckedValues(name) {
            const checkboxes = document.querySelectorAll(`input[name="${name}"]:checked`);
            return Array.from(checkboxes).map(cb => cb.value).join(',');
        }
        
        // Yeni erişim oluştur
        document.getElementById('createAccessForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const userId = document.getElementById('userId').value;
            const accessType = document.getElementById('accessType').value;
            const brandIds = getCheckedValues('brandIds');
            const companyIds = getCheckedValues('companyIds');
            
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
            const result = await apiCall('getAllUserAccess');
            showResult(result);
            
            if (result.success && result.data) {
                renderAccessTable(result.data);
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
            const userId = document.getElementById('updateUserId').value;
            const accessType = document.getElementById('updateAccessType').value;
            
            if (!accessId || !userId || !accessType) {
                showAlert('Lütfen tüm alanları doldurun', false);
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
                getAllUserAccess();
            }
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
                    <td>${item.USER_ID}</td>
                    <td>${item.ACCESS_TYPE}</td>
                    <td><button class="btn btn-primary" onclick="loadBrands(${item.ACCESS_ID})">Göster</button></td>
                    <td><button class="btn btn-primary" onclick="loadCompanies(${item.ACCESS_ID})">Göster</button></td>
                    <td>
                        <button class="btn btn-warning" onclick="editAccess(${item.ACCESS_ID}, ${item.USER_ID}, '${item.ACCESS_TYPE}')">Düzenle</button>
                        <button class="btn btn-danger" onclick="quickDelete(${item.ACCESS_ID})">Sil</button>
                    </td>
                </tr>
            `).join('');
        }
        
        // Düzenleme formunu doldur
        function editAccess(accessId, userId, accessType) {
            document.getElementById('updateAccessId').value = accessId;
            document.getElementById('updateUserId').value = userId;
            document.getElementById('updateAccessType').value = accessType;
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
        
        // Markaları yükle
        async function loadBrands(accessId) {
            const result = await apiCall('getBrandsByAccessId', { accessId: accessId });
            showResult({ accessId: accessId, brands: result.data });
        }
        
        // Şirketleri yükle
        async function loadCompanies(accessId) {
            const result = await apiCall('getCompaniesByAccessId', { accessId: accessId });
            showResult({ accessId: accessId, companies: result.data });
        }
        
        // Sayfa yüklendiğinde tüm erişimleri getir
        // document.addEventListener('DOMContentLoaded', getAllUserAccess);
    </script>

