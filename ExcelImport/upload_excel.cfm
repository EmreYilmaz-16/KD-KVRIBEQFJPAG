<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Excel Dosyası Yükle - PRODUCT_OEMS İçe Aktarım</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
        }
        
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
            padding: 40px;
        }
        
        .header {
            text-align: center;
            margin-bottom: 40px;
        }
        
        .header h1 {
            color: #333;
            margin-bottom: 10px;
            font-size: 2.5em;
        }
        
        .header p {
            color: #666;
            font-size: 1.1em;
        }
        
        .upload-section {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 30px;
            margin-bottom: 30px;
            border: 2px dashed #dee2e6;
            transition: all 0.3s ease;
        }
        
        .upload-section:hover {
            border-color: #667eea;
            background: #f0f2ff;
        }
        
        .form-group {
            margin-bottom: 25px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #333;
            font-size: 1.1em;
        }
        
        .file-input-wrapper {
            position: relative;
            display: inline-block;
            width: 100%;
        }
        
        .file-input {
            width: 100%;
            padding: 12px;
            border: 2px solid #ddd;
            border-radius: 8px;
            font-size: 16px;
            transition: border-color 0.3s ease;
        }
        
        .file-input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        .submit-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px 40px;
            border: none;
            border-radius: 8px;
            font-size: 1.1em;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            width: 100%;
        }
        
        .submit-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
        }
        
        .submit-btn:active {
            transform: translateY(0);
        }
        
        .info-box {
            background: #e3f2fd;
            border-left: 4px solid #2196f3;
            padding: 20px;
            margin-bottom: 30px;
            border-radius: 5px;
        }
        
        .info-box h3 {
            margin-top: 0;
            color: #1976d2;
        }
        
        .info-box ul {
            margin: 10px 0;
            padding-left: 20px;
        }
        
        .info-box li {
            margin-bottom: 5px;
            color: #333;
        }
        
        .warning-box {
            background: #fff3cd;
            border-left: 4px solid #ffc107;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 5px;
        }
        
        .warning-box strong {
            color: #856404;
        }
        
        .table-structure {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 20px;
            margin-top: 20px;
        }
        
        .table-structure h4 {
            margin-top: 0;
            color: #333;
        }
        
        .columns-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
            gap: 10px;
            margin-top: 15px;
        }
        
        .column-item {
            background: white;
            padding: 8px 12px;
            border-radius: 5px;
            border: 1px solid #ddd;
            text-align: center;
            font-family: monospace;
            font-size: 0.9em;
        }
        
        .column-item.primary {
            background: #e3f2fd;
            border-color: #2196f3;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 Excel Dosyası Yükleme</h1>
            <p>PRODUCT_OEMS tablosuna veri aktarımı için Excel dosyanızı yükleyin</p>
        </div>
        
        <div class="info-box">
            <h3>📋 Gereksinimler</h3>
            <ul>
                <li><strong>Dosya Formatı:</strong> .xlsx (Excel 2007 ve üzeri)</li>
                <li><strong>İlk Satır:</strong> Kolon başlıkları olmalı</li>
                <li><strong>Maksimum Dosya Boyutu:</strong> 10MB</li>
                <li><strong>Zorunlu Kolon:</strong> ETA_KODU (A kolonu)</li>
            </ul>
            <div style="text-align: center; margin-top: 15px;">
                <a href="download_template.cfm" style="background: #28a745; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block;">
                    📥 Örnek Excel Şablonu İndir
                </a>
            </div>
        </div>
        
        <div class="warning-box">
            <strong>⚠️ Uyarı:</strong> Yükleme işlemi mevcut PRODUCT_OEMS tablosuna yeni kayıtlar ekleyecektir. 
            Duplicate kayıtlar için kontrol yapılmayacaktır.
        </div>
        
        <form action="import_excel_preview.cfm" method="post" enctype="multipart/form-data" onsubmit="return validateForm()">
            <div class="upload-section">
                <div class="form-group">
                    <label for="excelFile">Excel Dosyası Seçin:</label>
                    <input type="file" 
                           id="excelFile" 
                           name="excelFile" 
                           class="file-input" 
                           accept=".xlsx,.xls"
                           required>
                </div>
                
                <div class="form-group">
                    <button type="submit" class="submit-btn">
                        🚀 Dosyayı Yükle ve İşle
                    </button>
                </div>
            </div>
        </form>
        
        <div class="table-structure">
            <h4>🗂️ PRODUCT_OEMS Tablo Yapısı (51 Kolon)</h4>
            <p>Excel dosyanızın aşağıdaki kolon yapısına uygun olması gerekmektedir:</p>
            
            <div class="columns-grid">
                <div class="column-item primary">ETA_KODU</div>
                <div class="column-item">OEM_1</div>
                <div class="column-item">OEM_2</div>
                <div class="column-item">OEM_3</div>
                <div class="column-item">OEM_4</div>
                <div class="column-item">OEM_5</div>
                <div class="column-item">...</div>
                <div class="column-item">OEM_48</div>
                <div class="column-item">OEM_49</div>
                <div class="column-item">OEM_50</div>
            </div>
            
            <p style="margin-top: 15px; font-size: 0.9em; color: #666;">
                <strong>Not:</strong> ETA_KODU zorunlu, OEM_1 - OEM_50 kolonları isteğe bağlıdır.
            </p>
        </div>
    </div>
    
    <script>
        function validateForm() {
            const fileInput = document.getElementById('excelFile');
            const file = fileInput.files[0];
            
            if (!file) {
                alert('Lütfen bir Excel dosyası seçin.');
                return false;
            }
            
            // Dosya boyutu kontrolü (10MB)
            if (file.size > 10 * 1024 * 1024) {
                alert('Dosya boyutu 10MB\'dan büyük olamaz.');
                return false;
            }
            
            // Dosya uzantısı kontrolü
            const fileName = file.name.toLowerCase();
            if (!fileName.endsWith('.xlsx') && !fileName.endsWith('.xls')) {
                alert('Lütfen sadece .xlsx veya .xls formatında dosya yükleyin.');
                return false;
            }
            
            // Kullanıcıya onay mesajı
            const confirmation = confirm(
                'Dosya yüklenecek ve PRODUCT_OEMS tablosuna aktarılacak.\n\n' +
                'Bu işlem geri alınamaz. Devam etmek istediğinizden emin misiniz?'
            );
            
            if (confirmation) {
                // Submit butonu disable et
                const submitBtn = document.querySelector('.submit-btn');
                submitBtn.innerHTML = '⏳ İşlem devam ediyor...';
                submitBtn.disabled = true;
                return true;
            }
            
            return false;
        }
        
        // Dosya seçildiğinde bilgi göster
        document.getElementById('excelFile').addEventListener('change', function(e) {
            const file = e.target.files[0];
            if (file) {
                const fileSize = (file.size / 1024 / 1024).toFixed(2);
                console.log(`Seçilen dosya: ${file.name} (${fileSize} MB)`);
            }
        });
    </script>
</body>
</html>
