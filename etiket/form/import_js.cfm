<!--- JavaScript Tabanlı Excel Import (Apache POI alternatifi) --->
<cfparam name="form.jsonData" default="">

<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Excel Import - JavaScript Versiyonu</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .upload-area {
            border: 2px dashed #ddd;
            border-radius: 10px;
            padding: 40px;
            text-align: center;
            background-color: #f8f9fa;
            transition: all 0.3s ease;
        }
        .upload-area:hover {
            border-color: #007bff;
            background-color: #e7f3ff;
        }
        .upload-area.dragover {
            border-color: #007bff;
            background-color: #e7f3ff;
        }
        .preview-table {
            max-height: 400px;
            overflow-y: auto;
        }
        .data-row.error {
            background-color: #f8d7da;
        }
        .data-row.warning {
            background-color: #fff3cd;
        }
    </style>
</head>
<body>
    <div class="container mt-4">
        <div class="row justify-content-center">
            <div class="col-md-10">
                <div class="card shadow">
                    <div class="card-header bg-success text-white">
                        <h4 class="mb-0">
                            <i class="fas fa-upload me-2"></i>
                            Excel Import - JavaScript Versiyonu
                        </h4>
                        <small>Apache POI gerektirmez - Tamamen browser tabanlı</small>
                    </div>
                    <div class="card-body">
                        
                        <cfif len(form.jsonData) gt 0>
                            <!--- JSON verilerini işle --->
                            <cftry>
                                <cfset excelData = deserializeJSON(form.jsonData)>
                                
                                <!--- Import log oluştur --->
                                <cfquery name="createImportLog" datasource="w3Qa" result="logResult">
                                    INSERT INTO etiket_import_log (
                                        import_date,
                                        file_name,
                                        file_size,
                                        status
                                    ) VALUES (
                                        GETDATE(),
                                        <cfqueryparam value="#excelData.fileName#" cfsqltype="cf_sql_varchar">,
                                        <cfqueryparam value="#excelData.fileSize#" cfsqltype="cf_sql_integer">,
                                        'PROCESSING'
                                    )
                                </cfquery>
                                
                                <cfset importId = logResult.generatedKey>
                                <cfset successCount = 0>
                                <cfset errorCount = 0>
                                <cfset errors = []>
                                
                                <!--- Verileri işle --->
                                <cfloop array="#excelData.data#" index="row" item="rowData">
                                    <cftry>
                                        <cfif structKeyExists(rowData, "EtaKodu") AND len(trim(rowData.EtaKodu)) gt 0>
                                            <cfquery name="insertData" datasource="w3Qa">
                                                INSERT INTO etiket_temp_data (
                                                    import_id,
                                                    eta_kodu,
                                                    seri_no,
                                                    uretim_tarihi,
                                                    paket_tarihi,
                                                    barkod,
                                                    miktar,
                                                    marka,
                                                    row_number,
                                                    created_date
                                                ) VALUES (
                                                    <cfqueryparam value="#importId#" cfsqltype="cf_sql_integer">,
                                                    <cfqueryparam value="#trim(rowData.EtaKodu)#" cfsqltype="cf_sql_varchar">,
                                                    <cfqueryparam value="#trim(rowData.SeriNo ?: '')#" cfsqltype="cf_sql_varchar">,
                                                    <cfif structKeyExists(rowData, "UretimTarihi") AND isDate(rowData.UretimTarihi)>
                                                        <cfqueryparam value="#parseDateTime(rowData.UretimTarihi)#" cfsqltype="cf_sql_timestamp">
                                                    <cfelse>
                                                        NULL
                                                    </cfif>,
                                                    <cfif structKeyExists(rowData, "PaketTarihi") AND isDate(rowData.PaketTarihi)>
                                                        <cfqueryparam value="#parseDateTime(rowData.PaketTarihi)#" cfsqltype="cf_sql_timestamp">
                                                    <cfelse>
                                                        NULL
                                                    </cfif>,
                                                    <cfqueryparam value="#trim(rowData.Barkod ?: '')#" cfsqltype="cf_sql_varchar">,
                                                    <cfqueryparam value="#val(rowData.Miktar ?: 0)#" cfsqltype="cf_sql_decimal">,
                                                    <cfqueryparam value="#trim(rowData.Marka ?: '')#" cfsqltype="cf_sql_varchar">,
                                                    <cfqueryparam value="#row#" cfsqltype="cf_sql_integer">,
                                                    GETDATE()
                                                )
                                            </cfquery>
                                            <cfset successCount++>
                                        <cfelse>
                                            <cfset errorCount++>
                                            <cfset arrayAppend(errors, "Satır #row#: EtaKodu boş")>
                                        </cfif>
                                        
                                        <cfcatch>
                                            <cfset errorCount++>
                                            <cfset arrayAppend(errors, "Satır #row#: #cfcatch.message#")>
                                        </cfcatch>
                                    </cftry>
                                </cfloop>
                                
                                <!--- Import log güncelle --->
                                <cfquery name="updateImportLog" datasource="w3Qa">
                                    UPDATE etiket_import_log SET
                                        total_records = <cfqueryparam value="#arrayLen(excelData.data)#" cfsqltype="cf_sql_integer">,
                                        success_records = <cfqueryparam value="#successCount#" cfsqltype="cf_sql_integer">,
                                        error_records = <cfqueryparam value="#errorCount#" cfsqltype="cf_sql_integer">,
                                        status = 'COMPLETED',
                                        completed_date = GETDATE()
                                    WHERE import_id = <cfqueryparam value="#importId#" cfsqltype="cf_sql_integer">
                                </cfquery>
                                
                                <!--- Sonuçları göster --->
                                <div class="alert alert-success">
                                    <h5><i class="fas fa-check-circle me-2"></i>Import Başarılı!</h5>
                                    <div class="row text-center">
                                        <div class="col-md-4">
                                            <h3 class="text-primary">#arrayLen(excelData.data)#</h3>
                                            <small>Toplam Satır</small>
                                        </div>
                                        <div class="col-md-4">
                                            <h3 class="text-success">#successCount#</h3>
                                            <small>Başarılı</small>
                                        </div>
                                        <div class="col-md-4">
                                            <h3 class="text-danger">#errorCount#</h3>
                                            <small>Hatalı</small>
                                        </div>
                                    </div>
                                </div>
                                
                                <cfif arrayLen(errors) gt 0>
                                    <div class="alert alert-warning">
                                        <h6>Hatalar:</h6>
                                        <ul class="mb-0">
                                            <cfloop array="#errors#" index="error">
                                                <li>#error#</li>
                                            </cfloop>
                                        </ul>
                                    </div>
                                </cfif>
                                
                                <div class="d-grid gap-2">
                                    <a href="view_labels.cfm?import_id=#importId#" class="btn btn-success btn-lg">
                                        <i class="fas fa-print me-2"></i>
                                        Etiketleri Görüntüle ve Yazdır
                                    </a>
                                    <a href="import_js.cfm" class="btn btn-outline-primary">
                                        <i class="fas fa-upload me-2"></i>
                                        Yeni Import
                                    </a>
                                </div>
                                
                                <cfcatch>
                                    <div class="alert alert-danger">
                                        <h5><i class="fas fa-exclamation-triangle me-2"></i>Hata!</h5>
                                        <p><cfoutput>#cfcatch.message#</cfoutput></p>
                                    </div>
                                </cfcatch>
                            </cftry>
                        <cfelse>
                            <!--- Upload formu --->
                            <div class="alert alert-info">
                                <h6><i class="fas fa-info-circle me-2"></i>JavaScript Versiyonu</h6>
                                <p>Bu versiyon tamamen browser tabanlı çalışır ve Apache POI gerektirmez. Excel dosyası client-side'da işlenir ve JSON olarak server'a gönderilir.</p>
                            </div>

                            <!-- Örnek Excel İndirme -->
                            <div class="mb-4">
                                <div class="card border-info">
                                    <div class="card-header bg-info text-white">
                                        <h6 class="mb-0">
                                            <i class="fas fa-download me-2"></i>Örnek Excel Dosyası İndir
                                        </h6>
                                    </div>
                                    <div class="card-body">
                                        <p class="mb-3">Test etmek için örnek Excel dosyası indirin:</p>
                                        <div class="row">
                                            <div class="col-md-6">
                                                <a href="create_sample_excel.cfm?action=create&recordCount=10" class="btn btn-outline-info w-100 mb-2">
                                                    <i class="fas fa-file-csv me-2"></i>
                                                    CSV Format (10 Kayıt)
                                                </a>
                                            </div>
                                            <div class="col-md-6">
                                                <a href="create_excel_advanced.cfm?action=create_xlsx&recordCount=10" class="btn btn-info w-100 mb-2">
                                                    <i class="fas fa-file-excel me-2"></i>
                                                    XLSX Format (10 Kayıt)
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="upload-area" id="uploadArea">
                                <i class="fas fa-cloud-upload-alt fa-3x text-muted mb-3"></i>
                                <h5>Excel Dosyasını Buraya Sürükleyin</h5>
                                <p class="text-muted">veya dosya seçmek için tıklayın</p>
                                <input type="file" id="excelFile" accept=".xlsx,.xls" class="d-none">
                                <button type="button" class="btn btn-outline-primary" onclick="document.getElementById('excelFile').click()">
                                    <i class="fas fa-file-excel me-2"></i>Dosya Seç
                                </button>
                            </div>

                            <div id="fileInfo" class="mt-3 d-none">
                                <div class="card">
                                    <div class="card-header">
                                        <h6 class="mb-0">Dosya Bilgileri</h6>
                                    </div>
                                    <div class="card-body">
                                        <div class="row">
                                            <div class="col-md-6">
                                                <strong>Dosya Adı:</strong> <span id="fileName"></span><br>
                                                <strong>Boyut:</strong> <span id="fileSize"></span><br>
                                                <strong>Tip:</strong> <span id="fileType"></span>
                                            </div>
                                            <div class="col-md-6">
                                                <strong>Toplam Satır:</strong> <span id="totalRows">0</span><br>
                                                <strong>Geçerli Satır:</strong> <span id="validRows">0</span><br>
                                                <strong>Hatalı Satır:</strong> <span id="errorRows">0</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div id="previewSection" class="mt-3 d-none">
                                <h6>Veri Önizleme:</h6>
                                <div class="preview-table">
                                    <table class="table table-sm table-striped" id="previewTable">
                                        <thead class="table-dark">
                                            <tr>
                                                <th>Satır</th>
                                                <th>EtaKodu</th>
                                                <th>SeriNo</th>
                                                <th>Üretim Tarihi</th>
                                                <th>Paket Tarihi</th>
                                                <th>Barkod</th>
                                                <th>Miktar</th>
                                                <th>Marka</th>
                                                <th>Durum</th>
                                            </tr>
                                        </thead>
                                        <tbody id="previewTableBody">
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                            <div id="actionButtons" class="mt-3 d-none">
                                <form method="post" id="importForm">
                                    <input type="hidden" name="jsonData" id="jsonDataInput">
                                    <div class="d-grid gap-2">
                                        <button type="submit" class="btn btn-success btn-lg" id="importBtn">
                                            <i class="fas fa-database me-2"></i>
                                            Verileri Veritabanına Kaydet
                                        </button>
                                        <button type="button" class="btn btn-outline-secondary" onclick="resetForm()">
                                            <i class="fas fa-redo me-2"></i>
                                            Yeniden Başla
                                        </button>
                                    </div>
                                </form>
                            </div>

                            <div id="processingIndicator" class="text-center mt-3 d-none">
                                <div class="spinner-border text-primary" role="status">
                                    <span class="visually-hidden">İşleniyor...</span>
                                </div>
                                <p class="mt-2">Excel dosyası işleniyor...</p>
                            </div>
                        </cfif>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
    <script>
        let excelData = null;
        let processedData = [];

        // Upload area event listeners
        const uploadArea = document.getElementById('uploadArea');
        const fileInput = document.getElementById('excelFile');

        ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
            uploadArea.addEventListener(eventName, preventDefaults, false);
            document.body.addEventListener(eventName, preventDefaults, false);
        });

        ['dragenter', 'dragover'].forEach(eventName => {
            uploadArea.addEventListener(eventName, highlight, false);
        });

        ['dragleave', 'drop'].forEach(eventName => {
            uploadArea.addEventListener(eventName, unhighlight, false);
        });

        uploadArea.addEventListener('drop', handleDrop, false);
        fileInput.addEventListener('change', handleFileSelect, false);

        function preventDefaults(e) {
            e.preventDefault();
            e.stopPropagation();
        }

        function highlight(e) {
            uploadArea.classList.add('dragover');
        }

        function unhighlight(e) {
            uploadArea.classList.remove('dragover');
        }

        function handleDrop(e) {
            const dt = e.dataTransfer;
            const files = dt.files;
            handleFiles(files);
        }

        function handleFileSelect() {
            const files = fileInput.files;
            handleFiles(files);
        }

        function handleFiles(files) {
            if (files.length > 0) {
                const file = files[0];
                
                // Validate file type
                const allowedTypes = ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 
                                    'application/vnd.ms-excel'];
                if (!allowedTypes.includes(file.type) && !file.name.match(/\.(xlsx|xls)$/i)) {
                    alert('Lütfen sadece Excel dosyası (.xlsx, .xls) seçin.');
                    return;
                }

                // Validate file size (max 10MB)
                if (file.size > 10 * 1024 * 1024) {
                    alert('Dosya boyutu 10MB\'dan büyük olamaz.');
                    return;
                }

                processExcelFile(file);
            }
        }

        function processExcelFile(file) {
            document.getElementById('processingIndicator').classList.remove('d-none');
            
            const reader = new FileReader();
            reader.onload = function(e) {
                try {
                    const data = new Uint8Array(e.target.result);
                    const workbook = XLSX.read(data, { type: 'array' });
                    
                    // İlk sheet'i al
                    const sheetName = workbook.SheetNames[0];
                    const worksheet = workbook.Sheets[sheetName];
                    
                    // JSON'a çevir
                    const jsonData = XLSX.utils.sheet_to_json(worksheet, { header: 1 });
                    
                    if (jsonData.length < 2) {
                        alert('Excel dosyasında en az bir başlık ve bir veri satırı olmalıdır.');
                        return;
                    }

                    // Başlık satırını al
                    const headers = jsonData[0];
                    const requiredColumns = ['EtaKodu', 'SeriNo', 'Üretim Tarihi', 'Paket Tarihi', 'Barkod', 'Miktar', 'Marka'];
                    
                    // Sütun mapping
                    const columnMap = {};
                    headers.forEach((header, index) => {
                        const cleanHeader = String(header).trim();
                        columnMap[cleanHeader] = index;
                    });

                    // Gerekli sütunları kontrol et
                    const missingColumns = requiredColumns.filter(col => !columnMap.hasOwnProperty(col));
                    if (missingColumns.length > 0) {
                        alert('Gerekli sütunlar bulunamadı: ' + missingColumns.join(', '));
                        return;
                    }

                    // Veri satırlarını işle
                    processedData = [];
                    let validRows = 0;
                    let errorRows = 0;

                    for (let i = 1; i < jsonData.length; i++) {
                        const row = jsonData[i];
                        const rowData = {};
                        let hasError = false;
                        let errorMessage = '';

                        try {
                            // EtaKodu
                            rowData.EtaKodu = row[columnMap['EtaKodu']] ? String(row[columnMap['EtaKodu']]).trim() : '';
                            
                            // SeriNo
                            rowData.SeriNo = row[columnMap['SeriNo']] ? String(row[columnMap['SeriNo']]).trim() : '';
                            
                            // Üretim Tarihi
                            const uretimTarihiRaw = row[columnMap['Üretim Tarihi']];
                            if (uretimTarihiRaw) {
                                if (typeof uretimTarihiRaw === 'number') {
                                    // Excel date number to JS date
                                    const jsDate = XLSX.SSF.parse_date_code(uretimTarihiRaw);
                                    rowData.UretimTarihi = `${jsDate.y}-${String(jsDate.m).padStart(2, '0')}-${String(jsDate.d).padStart(2, '0')}`;
                                } else {
                                    rowData.UretimTarihi = String(uretimTarihiRaw).trim();
                                }
                            } else {
                                rowData.UretimTarihi = '';
                            }
                            
                            // Paket Tarihi
                            const paketTarihiRaw = row[columnMap['Paket Tarihi']];
                            if (paketTarihiRaw) {
                                if (typeof paketTarihiRaw === 'number') {
                                    const jsDate = XLSX.SSF.parse_date_code(paketTarihiRaw);
                                    rowData.PaketTarihi = `${jsDate.y}-${String(jsDate.m).padStart(2, '0')}-${String(jsDate.d).padStart(2, '0')}`;
                                } else {
                                    rowData.PaketTarihi = String(paketTarihiRaw).trim();
                                }
                            } else {
                                rowData.PaketTarihi = '';
                            }
                            
                            // Barkod
                            rowData.Barkod = row[columnMap['Barkod']] ? String(row[columnMap['Barkod']]).trim() : '';
                            
                            // Miktar
                            rowData.Miktar = row[columnMap['Miktar']] ? parseFloat(row[columnMap['Miktar']]) || 0 : 0;
                            
                            // Marka
                            rowData.Marka = row[columnMap['Marka']] ? String(row[columnMap['Marka']]).trim() : '';

                            // Validation
                            if (!rowData.EtaKodu) {
                                hasError = true;
                                errorMessage = 'EtaKodu boş';
                            } else if (!rowData.SeriNo) {
                                hasError = true;
                                errorMessage = 'SeriNo boş';
                            } else if (rowData.Miktar <= 0) {
                                hasError = true;
                                errorMessage = 'Miktar 0\'dan büyük olmalı';
                            }

                            if (hasError) {
                                errorRows++;
                            } else {
                                validRows++;
                            }

                            rowData.RowNumber = i;
                            rowData.HasError = hasError;
                            rowData.ErrorMessage = errorMessage;
                            
                            processedData.push(rowData);

                        } catch (e) {
                            hasError = true;
                            errorMessage = 'Veri işleme hatası: ' + e.message;
                            errorRows++;
                            
                            rowData.HasError = hasError;
                            rowData.ErrorMessage = errorMessage;
                            processedData.push(rowData);
                        }
                    }

                    // UI'yi güncelle
                    updateUI(file, validRows, errorRows);
                    displayPreview();

                } catch (error) {
                    alert('Excel dosyası okunamadı: ' + error.message);
                } finally {
                    document.getElementById('processingIndicator').classList.add('d-none');
                }
            };

            reader.readAsArrayBuffer(file);
        }

        function updateUI(file, validRows, errorRows) {
            document.getElementById('fileName').textContent = file.name;
            document.getElementById('fileSize').textContent = formatFileSize(file.size);
            document.getElementById('fileType').textContent = file.type;
            document.getElementById('totalRows').textContent = processedData.length;
            document.getElementById('validRows').textContent = validRows;
            document.getElementById('errorRows').textContent = errorRows;

            document.getElementById('fileInfo').classList.remove('d-none');
            document.getElementById('previewSection').classList.remove('d-none');
            document.getElementById('actionButtons').classList.remove('d-none');
        }

        function displayPreview() {
            const tbody = document.getElementById('previewTableBody');
            tbody.innerHTML = '';

            // İlk 10 satırı göster
            const previewData = processedData.slice(0, 10);
            
            previewData.forEach(row => {
                const tr = document.createElement('tr');
                tr.className = row.HasError ? 'data-row error' : 'data-row';
                
                tr.innerHTML = `
                    <td>${row.RowNumber}</td>
                    <td>${row.EtaKodu || ''}</td>
                    <td>${row.SeriNo || ''}</td>
                    <td>${row.UretimTarihi || ''}</td>
                    <td>${row.PaketTarihi || ''}</td>
                    <td>${row.Barkod || ''}</td>
                    <td>${row.Miktar || ''}</td>
                    <td>${row.Marka || ''}</td>
                    <td>
                        ${row.HasError ? 
                            `<span class="badge bg-danger">${row.ErrorMessage}</span>` : 
                            `<span class="badge bg-success">OK</span>`
                        }
                    </td>
                `;
                
                tbody.appendChild(tr);
            });

            if (processedData.length > 10) {
                const tr = document.createElement('tr');
                tr.innerHTML = `<td colspan="9" class="text-center text-muted">... ve ${processedData.length - 10} satır daha</td>`;
                tbody.appendChild(tr);
            }
        }

        function formatFileSize(bytes) {
            if (bytes === 0) return '0 Bytes';
            const k = 1024;
            const sizes = ['Bytes', 'KB', 'MB', 'GB'];
            const i = Math.floor(Math.log(bytes) / Math.log(k));
            return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
        }

        function resetForm() {
            location.reload();
        }

        // Form submission
        document.getElementById('importForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const validData = processedData.filter(row => !row.HasError);
            
            if (validData.length === 0) {
                alert('İmport edilecek geçerli veri bulunamadı.');
                return;
            }

            const exportData = {
                fileName: document.getElementById('fileName').textContent,
                fileSize: document.querySelector('#fileInfo strong + span').textContent,
                data: validData
            };

            document.getElementById('jsonDataInput').value = JSON.stringify(exportData);
            
            document.getElementById('importBtn').innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Kaydediliyor...';
            document.getElementById('importBtn').disabled = true;
            
            this.submit();
        });
    </script>
</body>
</html>
