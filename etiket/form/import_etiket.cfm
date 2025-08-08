<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Etiket Import Sistemi</title>
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
        .file-info {
            background: #e9ecef;
            padding: 15px;
            border-radius: 8px;
            margin-top: 15px;
        }
        .step-indicator {
            margin-bottom: 30px;
        }
        .step {
            display: inline-block;
            width: 30px;
            height: 30px;
            border-radius: 50%;
            background: #dee2e6;
            color: #6c757d;
            text-align: center;
            line-height: 30px;
            margin-right: 10px;
            font-weight: bold;
        }
        .step.active {
            background: #007bff;
            color: white;
        }
        .step.completed {
            background: #28a745;
            color: white;
        }
    </style>
</head>
<body>
    <div class="container mt-4">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card shadow">
                    <div class="card-header bg-primary text-white">
                        <h4 class="mb-0">
                            <i class="fas fa-upload me-2"></i>
                            Excel Etiket Import Sistemi
                        </h4>
                    </div>
                    <div class="card-body">
                        <!-- Adım Göstergesi -->
                        <div class="step-indicator">
                            <span class="step active">1</span>
                            <span>Dosya Yükle</span>
                            <i class="fas fa-arrow-right mx-3 text-muted"></i>
                            <span class="step">2</span>
                            <span>Veri İşle</span>
                            <i class="fas fa-arrow-right mx-3 text-muted"></i>
                            <span class="step">3</span>
                            <span>Etiket Yazdır</span>
                        </div>

                        <!-- Excel Format Bilgisi -->
                        <div class="alert alert-info">
                            <h6><i class="fas fa-info-circle me-2"></i>Excel Dosyası Format Bilgisi:</h6>
                            <div class="row">
                                <div class="col-md-6">
                                    <ul class="mb-0">
                                        <li><strong>EtaKodu</strong> - Ürün ETA kodu (Metin)</li>
                                        <li><strong>SeriNo</strong> - Seri numarası (Metin)</li>
                                        <li><strong>Üretim Tarihi</strong> - Üretim tarihi (Tarih)</li>
                                        <li><strong>Paket Tarihi</strong> - Paketleme tarihi (Tarih)</li>
                                    </ul>
                                </div>
                                <div class="col-md-6">
                                    <ul class="mb-0">
                                        <li><strong>Barkod</strong> - Ürün barkodu (Metin/Sayı)</li>
                                        <li><strong>Miktar</strong> - Ürün miktarı (Sayı)</li>
                                        <li><strong>Marka</strong> - Ürün markası (Metin)</li>
                                    </ul>
                                </div>
                            </div>
                            <hr>
                            <div class="alert alert-warning mb-0">
                                <small>
                                    <i class="fas fa-exclamation-triangle me-1"></i>
                                    <strong>Önemli:</strong> İlk satır başlık satırı olmalıdır. 
                                    Miktar alanı sayısal değer içermeli (örn: 25.50). 
                                    Barkod alanı büyük sayılar içeriyorsa metin formatında olmalıdır.
                                    Desteklenen formatlar: .xlsx, .xls
                                </small>
                            </div>
                        </div>

                        <!-- Örnek Excel İndirme -->
                        <div class="mb-4">
                            <div class="card border-success">
                                <div class="card-header bg-success text-white">
                                    <h6 class="mb-0">
                                        <i class="fas fa-download me-2"></i>Örnek Excel Dosyası İndir
                                    </h6>
                                </div>
                                <div class="card-body">
                                    <p class="mb-3">Test etmek için örnek verilerle dolu Excel dosyası indirin:</p>
                                    <div class="row">
                                        <div class="col-md-6">
                                            <a href="create_sample_excel.cfm?action=create&recordCount=10" class="btn btn-outline-success w-100 mb-2">
                                                <i class="fas fa-file-csv me-2"></i>
                                                CSV Format (10 Kayıt)
                                            </a>
                                            <small class="text-muted">Excel'de açılabilir, POI gerektirmez</small>
                                        </div>
                                        <div class="col-md-6">
                                            <a href="create_excel_advanced.cfm?action=create_xlsx&recordCount=10" class="btn btn-success w-100 mb-2">
                                                <i class="fas fa-file-excel me-2"></i>
                                                XLSX Format (10 Kayıt)
                                            </a>
                                            <small class="text-muted">Gerçek Excel, formatlamalar dahil</small>
                                        </div>
                                    </div>
                                    <hr>
                                    <div class="text-center">
                                        <a href="create_sample_excel.cfm" class="btn btn-sm btn-outline-primary me-2">
                                            <i class="fas fa-cog me-1"></i>Daha Fazla Seçenek
                                        </a>
                                        <a href="create_excel_advanced.cfm" class="btn btn-sm btn-outline-success">
                                            <i class="fas fa-magic me-1"></i>Gelişmiş Excel
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Upload Form -->
                        <form action="process_import.cfm" method="post" enctype="multipart/form-data" id="uploadForm">
                            <div class="upload-area" id="uploadArea">
                                <i class="fas fa-cloud-upload-alt fa-3x text-muted mb-3"></i>
                                <h5>Excel Dosyasını Buraya Sürükleyin</h5>
                                <p class="text-muted">veya dosya seçmek için tıklayın</p>
                                <input type="file" name="excelFile" id="excelFile" accept=".xlsx,.xls" class="d-none" required>
                                <button type="button" class="btn btn-outline-primary" onclick="document.getElementById('excelFile').click()">
                                    <i class="fas fa-file-excel me-2"></i>Dosya Seç
                                </button>
                            </div>

                            <div id="fileInfo" class="file-info d-none">
                                <div class="row align-items-center">
                                    <div class="col">
                                        <h6 class="mb-1">Seçilen Dosya:</h6>
                                        <span id="fileName"></span>
                                        <small class="text-muted d-block">Boyut: <span id="fileSize"></span></small>
                                    </div>
                                    <div class="col-auto">
                                        <button type="button" class="btn btn-sm btn-outline-danger" onclick="clearFile()">
                                            <i class="fas fa-times"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <!-- İşlem Seçenekleri -->
                            <div class="mt-4">
                                <h6>İşlem Seçenekleri:</h6>
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" id="clearTable" name="clearTable" checked>
                                    <label class="form-check-label" for="clearTable">
                                        Mevcut verileri temizle (önceki import verilerini sil)
                                    </label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" id="validateData" name="validateData" checked>
                                    <label class="form-check-label" for="validateData">
                                        Veri doğrulaması yap
                                    </label>
                                </div>
                            </div>

                            <div class="d-grid gap-2 mt-4">
                                <button type="submit" class="btn btn-primary btn-lg" id="submitBtn" disabled>
                                    <i class="fas fa-upload me-2"></i>
                                    Excel Dosyasını İşle
                                </button>
                            </div>
                        </form>

                        <!-- Geçmiş İmportlar -->
                        <div class="mt-4">
                            <h6>Son İmportlar:</h6>
                            <cfquery name="getRecentImports" datasource="w3Qa">
                                SELECT TOP 5 
                                    import_id,
                                    import_date,
                                    total_records,
                                    success_records,
                                    error_records,
                                    file_name
                                FROM etiket_import_log 
                                ORDER BY import_date DESC
                            </cfquery>
                            
                            <cfif getRecentImports.recordCount GT 0>
                                <div class="table-responsive">
                                    <table class="table table-sm">
                                        <thead>
                                            <tr>
                                                <th>Tarih</th>
                                                <th>Dosya</th>
                                                <th>Toplam</th>
                                                <th>Başarılı</th>
                                                <th>Hatalı</th>
                                                <th>İşlem</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <cfoutput>
                                            <cfloop query="getRecentImports">
                                                <tr>
                                                    <td><small>#DateFormat(import_date, "dd/mm/yyyy")# #TimeFormat(import_date, "HH:mm")#</small></td>
                                                    <td><small>#file_name#</small></td>
                                                    <td><span class="badge bg-secondary">#total_records#</span></td>
                                                    <td><span class="badge bg-success">#success_records#</span></td>
                                                    <td><span class="badge bg-danger">#error_records#</span></td>
                                                    <td>
                                                        <a href="#request.self#?fuseaction=objects.emptypopup_view_labels?import_id=#import_id#" class="btn btn-sm btn-outline-primary">
                                                            <i class="fas fa-print"></i>
                                                        </a>
                                                    </td>
                                                </tr>
                                            </cfloop>
                                            </cfoutput>
                                        </tbody>
                                    </table>
                                </div>
                            <cfelse>
                                <p class="text-muted"><em>Henüz import işlemi yapılmamış.</em></p>
                            </cfif>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Drag & Drop functionality
        const uploadArea = document.getElementById('uploadArea');
        const fileInput = document.getElementById('excelFile');
        const fileInfo = document.getElementById('fileInfo');
        const submitBtn = document.getElementById('submitBtn');

        // Prevent default drag behaviors
        ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
            uploadArea.addEventListener(eventName, preventDefaults, false);
            document.body.addEventListener(eventName, preventDefaults, false);
        });

        // Highlight drop area when item is dragged over it
        ['dragenter', 'dragover'].forEach(eventName => {
            uploadArea.addEventListener(eventName, highlight, false);
        });

        ['dragleave', 'drop'].forEach(eventName => {
            uploadArea.addEventListener(eventName, unhighlight, false);
        });

        // Handle dropped files
        uploadArea.addEventListener('drop', handleDrop, false);

        // Handle file input change
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
            fileInput.files = files;
            handleFileSelect();
        }

        function handleFileSelect() {
            const file = fileInput.files[0];
            if (file) {
                // Validate file type
                const allowedTypes = ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 
                                    'application/vnd.ms-excel'];
                if (!allowedTypes.includes(file.type)) {
                    alert('Lütfen sadece Excel dosyası (.xlsx, .xls) seçin.');
                    clearFile();
                    return;
                }

                // Validate file size (max 10MB)
                if (file.size > 10 * 1024 * 1024) {
                    alert('Dosya boyutu 10MB\'dan büyük olamaz.');
                    clearFile();
                    return;
                }

                // Show file info
                document.getElementById('fileName').textContent = file.name;
                document.getElementById('fileSize').textContent = formatFileSize(file.size);
                fileInfo.classList.remove('d-none');
                submitBtn.disabled = false;
            } else {
                clearFile();
            }
        }

        function clearFile() {
            fileInput.value = '';
            fileInfo.classList.add('d-none');
            submitBtn.disabled = true;
        }

        function formatFileSize(bytes) {
            if (bytes === 0) return '0 Bytes';
            const k = 1024;
            const sizes = ['Bytes', 'KB', 'MB', 'GB'];
            const i = Math.floor(Math.log(bytes) / Math.log(k));
            return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
        }

        // Form submission
        document.getElementById('uploadForm').addEventListener('submit', function(e) {
            if (!fileInput.files[0]) {
                e.preventDefault();
                alert('Lütfen bir Excel dosyası seçin.');
                return;
            }
            
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>İşleniyor...';
            submitBtn.disabled = true;
        });
    </script>
</body>
</html>
