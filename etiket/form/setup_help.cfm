<!---
Excel Import Sistemi - Kurulum ve Yardım Dokümantasyonu
Bu dosya sistemin nasıl kurulacağı ve kullanılacağı hakkında bilgiler içerir.
--->

<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Excel Import Sistemi - Kurulum ve Yardım</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/prism/1.24.1/themes/prism.min.css" rel="stylesheet">
    <style>
        .toc {
            background: #f8f9fa;
            border-left: 4px solid #007bff;
            padding: 20px;
            margin-bottom: 30px;
        }
        .step-card {
            border-left: 4px solid #28a745;
            margin-bottom: 20px;
        }
        .code-block {
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 5px;
            padding: 15px;
            margin: 10px 0;
        }
        .warning {
            background: #fff3cd;
            border: 1px solid #ffeaa7;
            border-radius: 5px;
            padding: 15px;
            margin: 10px 0;
        }
        .info {
            background: #d1ecf1;
            border: 1px solid #bee5eb;
            border-radius: 5px;
            padding: 15px;
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <div class="container mt-4">
        <div class="row">
            <div class="col-md-12">
                <h1 class="mb-4">
                    <i class="fas fa-cogs text-primary me-2"></i>
                    Excel Import Sistemi - Kurulum ve Yardım
                </h1>

                <!-- İçindekiler -->
                <div class="toc">
                    <h5><i class="fas fa-list me-2"></i>İçindekiler</h5>
                    <ul>
                        <li><a href="#overview">Sistem Genel Bakış</a></li>
                        <li><a href="#requirements">Sistem Gereksinimleri</a></li>
                        <li><a href="#installation">Kurulum Adımları</a></li>
                        <li><a href="#database">Veritabanı Kurulumu</a></li>
                        <li><a href="#poi-setup">Apache POI Kurulumu</a></li>
                        <li><a href="#usage">Kullanım Kılavuzu</a></li>
                        <li><a href="#troubleshooting">Sorun Giderme</a></li>
                        <li><a href="#files">Dosya Yapısı</a></li>
                    </ul>
                </div>

                <!-- Sistem Genel Bakış -->
                <section id="overview" class="mb-5">
                    <h2>📋 Sistem Genel Bakış</h2>
                    <p>Bu sistem, Excel dosyalarından etiket verileri import edip, bu verileri etiket formatında yazdırmanızı sağlar.</p>
                    
                    <h4>Özellikler:</h4>
                    <ul>
                        <li>Excel (.xlsx, .xls) dosya formatı desteği</li>
                        <li>Drag & Drop dosya yükleme</li>
                        <li>Veri doğrulama ve hata kontrolü</li>
                        <li>Etiket yazdırma ve görüntüleme</li>
                        <li>QR kod ve barkod desteği</li>
                        <li>Sayfalama ve arama</li>
                        <li>Import geçmişi</li>
                    </ul>

                    <h4>Desteklenen Excel Sütunları:</h4>
                    <div class="row">
                        <div class="col-md-6">
                            <ul>
                                <li><strong>EtaKodu</strong> - Ürün ETA kodu</li>
                                <li><strong>SeriNo</strong> - Seri numarası</li>
                                <li><strong>Üretim Tarihi</strong> - Üretim tarihi</li>
                                <li><strong>Paket Tarihi</strong> - Paketleme tarihi</li>
                            </ul>
                        </div>
                        <div class="col-md-6">
                            <ul>
                                <li><strong>Barkod</strong> - Ürün barkodu</li>
                                <li><strong>Miktar</strong> - Ürün miktarı</li>
                                <li><strong>Marka</strong> - Ürün markası</li>
                            </ul>
                        </div>
                    </div>
                </section>

                <!-- Sistem Gereksinimleri -->
                <section id="requirements" class="mb-5">
                    <h2>⚙️ Sistem Gereksinimleri</h2>
                    <div class="card step-card">
                        <div class="card-body">
                            <ul>
                                <li><strong>ColdFusion:</strong> Adobe ColdFusion 2016+ veya Lucee 5+</li>
                                <li><strong>Veritabanı:</strong> Microsoft SQL Server 2012+</li>
                                <li><strong>Java:</strong> Java 8+ (ColdFusion ile birlikte)</li>
                                <li><strong>Apache POI:</strong> 5.0+ (Excel dosya işleme için)</li>
                                <li><strong>Web Sunucu:</strong> IIS veya Apache</li>
                                <li><strong>Tarayıcı:</strong> Chrome, Firefox, Edge (modern tarayıcılar)</li>
                            </ul>
                        </div>
                    </div>
                </section>

                <!-- Kurulum Adımları -->
                <section id="installation" class="mb-5">
                    <h2>📦 Kurulum Adımları</h2>
                    
                    <div class="card step-card">
                        <div class="card-header">
                            <h5>Adım 1: Dosyaları Kopyalama</h5>
                        </div>
                        <div class="card-body">
                            <p>Tüm dosyaları ColdFusion web root dizininize kopyalayın:</p>
                            <div class="code-block">
                                <pre><code>c:\inetpub\wwwroot\kd\etiket\form\
├── import_etiket.cfm       (Ana import sayfası)
├── process_import.cfm      (Excel işleme sayfası)
├── view_labels.cfm         (Etiket görüntüleme)
├── setup_database.sql      (Veritabanı kurulum scripti)
└── setup_help.cfm          (Bu yardım dosyası)</code></pre>
                            </div>
                        </div>
                    </div>

                    <div class="card step-card">
                        <div class="card-header">
                            <h5>Adım 2: Temp Klasörü Oluşturma</h5>
                        </div>
                        <div class="card-body">
                            <p>Excel dosyaları için geçici klasör oluşturun:</p>
                            <div class="code-block">
                                <pre><code>mkdir c:\temp\excel_imports</code></pre>
                            </div>
                            <div class="warning">
                                <i class="fas fa-exclamation-triangle me-2"></i>
                                Bu klasöre ColdFusion'ın yazma izni olduğundan emin olun.
                            </div>
                        </div>
                    </div>
                </section>

                <!-- Veritabanı Kurulumu -->
                <section id="database" class="mb-5">
                    <h2>🗄️ Veritabanı Kurulumu</h2>
                    
                    <div class="card step-card">
                        <div class="card-header">
                            <h5>Veritabanı Tablolarını Oluşturma</h5>
                        </div>
                        <div class="card-body">
                            <p>SQL Server Management Studio'da aşağıdaki komutu çalıştırın:</p>
                            <div class="code-block">
                                <pre><code>-- setup_database.sql dosyasını çalıştırın
-- Veya aşağıdaki bağlantıyı kullanarak doğrudan çalıştırabilirsiniz</code></pre>
                            </div>
                            
                            <a href="setup_database.sql" class="btn btn-primary" target="_blank">
                                <i class="fas fa-download me-2"></i>
                                SQL Script'i İndir
                            </a>

                            <h6 class="mt-3">Oluşturulacak Tablolar:</h6>
                            <ul>
                                <li><code>etiket_import_log</code> - Import işlem kayıtları</li>
                                <li><code>etiket_temp_data</code> - Import edilen veriler</li>
                                <li><code>etiket_print_history</code> - Yazdırma geçmişi</li>
                                <li><code>etiket_templates</code> - Etiket şablonları</li>
                            </ul>
                        </div>
                    </div>

                    <div class="card step-card">
                        <div class="card-header">
                            <h5>ColdFusion Datasource Ayarları</h5>
                        </div>
                        <div class="card-body">
                            <p>ColdFusion Administrator'da "KD" adında bir datasource oluşturun:</p>
                            <ul>
                                <li><strong>Driver:</strong> Microsoft SQL Server</li>
                                <li><strong>Server:</strong> localhost veya SQL Server adresi</li>
                                <li><strong>Database:</strong> KD</li>
                                <li><strong>Username/Password:</strong> Uygun kullanıcı bilgileri</li>
                            </ul>
                        </div>
                    </div>
                </section>

                <!-- Apache POI Kurulumu -->
                <section id="poi-setup" class="mb-5">
                    <h2>📚 Apache POI Kurulumu</h2>
                    
                    <div class="warning">
                        <i class="fas fa-exclamation-triangle me-2"></i>
                        <strong>Önemli:</strong> Excel dosyalarını okuyabilmek için Apache POI kütüphanesi gereklidir.
                    </div>

                    <div class="card step-card">
                        <div class="card-header">
                            <h5>POI JAR Dosyalarını İndirme</h5>
                        </div>
                        <div class="card-body">
                            <p>Apache POI sitesinden gerekli JAR dosyalarını indirin:</p>
                            <div class="info">
                                <p><strong>İndirme Adresi:</strong> <a href="https://poi.apache.org/download.html" target="_blank">https://poi.apache.org/download.html</a></p>
                            </div>
                            
                            <h6>Gerekli JAR Dosyaları:</h6>
                            <ul>
                                <li>poi-5.2.3.jar</li>
                                <li>poi-ooxml-5.2.3.jar</li>
                                <li>poi-scratchpad-5.2.3.jar</li>
                                <li>xmlbeans-5.1.1.jar</li>
                                <li>commons-compress-1.21.jar</li>
                                <li>commons-collections4-4.4.jar</li>
                            </ul>
                        </div>
                    </div>

                    <div class="card step-card">
                        <div class="card-header">
                            <h5>JAR Dosyalarını ColdFusion'a Ekleme</h5>
                        </div>
                        <div class="card-body">
                            <p>İndirilen JAR dosyalarını ColdFusion lib klasörüne kopyalayın:</p>
                            <div class="code-block">
                                <pre><code>C:\ColdFusion2021\cfusion\lib\
veya
C:\lucee\lib\</code></pre>
                            </div>
                            <div class="warning">
                                <i class="fas fa-exclamation-triangle me-2"></i>
                                JAR dosyalarını ekledikten sonra ColdFusion servisini yeniden başlatın.
                            </div>
                        </div>
                    </div>

                    <div class="card step-card">
                        <div class="card-header">
                            <h5>Test Etme</h5>
                        </div>
                        <div class="card-body">
                            <p>POI kurulumunu test etmek için:</p>
                            <div class="code-block">
                                <pre><code>&lt;cfscript&gt;
try {
    XSSFWorkbook = createObject("java", "org.apache.poi.xssf.usermodel.XSSFWorkbook");
    writeOutput("Apache POI başarıyla yüklendi!");
} catch (any e) {
    writeOutput("Hata: " & e.message);
}
&lt;/cfscript&gt;</code></pre>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- Kullanım Kılavuzu -->
                <section id="usage" class="mb-5">
                    <h2>👤 Kullanım Kılavuzu</h2>
                    
                    <div class="card step-card">
                        <div class="card-header">
                            <h5>1. Excel Dosyası Hazırlama</h5>
                        </div>
                        <div class="card-body">
                            <p>Excel dosyanızın ilk satırında şu başlıklar olmalıdır:</p>
                            <div class="table-responsive">
                                <table class="table table-sm table-bordered">
                                    <thead class="table-dark">
                                        <tr>
                                            <th>EtaKodu</th>
                                            <th>SeriNo</th>
                                            <th>Üretim Tarihi</th>
                                            <th>Paket Tarihi</th>
                                            <th>Barkod</th>
                                            <th>Miktar</th>
                                            <th>Marka</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>ETA001</td>
                                            <td>SN001</td>
                                            <td>15.01.2025</td>
                                            <td>20.01.2025</td>
                                            <td>1234567890123</td>
                                            <td>10.5</td>
                                            <td>ABC Marka</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <div class="card step-card">
                        <div class="card-header">
                            <h5>2. Import İşlemi</h5>
                        </div>
                        <div class="card-body">
                            <ol>
                                <li><code>import_etiket.cfm</code> sayfasını açın</li>
                                <li>Excel dosyasını sürükleyip bırakın veya "Dosya Seç" butonuna tıklayın</li>
                                <li>İşlem seçeneklerini belirleyin</li>
                                <li>"Excel Dosyasını İşle" butonuna tıklayın</li>
                            </ol>
                        </div>
                    </div>

                    <div class="card step-card">
                        <div class="card-header">
                            <h5>3. Etiket Yazdırma</h5>
                        </div>
                        <div class="card-body">
                            <ol>
                                <li>Import işlemi tamamlandıktan sonra "Etiketleri Görüntüle" butonuna tıklayın</li>
                                <li>Etiket boyutunu seçin (Küçük/Orta/Büyük)</li>
                                <li>"Yazdır" butonuna tıklayarak yazdırma önizlemesi açın</li>
                                <li>Yazıcı ayarlarını yapıp yazdırın</li>
                            </ol>
                        </div>
                    </div>
                </section>

                <!-- Sorun Giderme -->
                <section id="troubleshooting" class="mb-5">
                    <h2>🔧 Sorun Giderme</h2>
                    
                    <div class="accordion" id="troubleshootingAccordion">
                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#error1">
                                    "Apache POI sınıfı bulunamadı" hatası
                                </button>
                            </h2>
                            <div id="error1" class="accordion-collapse collapse">
                                <div class="accordion-body">
                                    <p><strong>Çözüm:</strong></p>
                                    <ul>
                                        <li>Apache POI JAR dosyalarının ColdFusion lib klasöründe olduğundan emin olun</li>
                                        <li>ColdFusion servisini yeniden başlatın</li>
                                        <li>JAR dosyalarının uyumlu versiyonlarını kullandığınızdan emin olun</li>
                                    </ul>
                                </div>
                            </div>
                        </div>

                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#error2">
                                    "Dosya yüklenemedi" hatası
                                </button>
                            </h2>
                            <div id="error2" class="accordion-collapse collapse">
                                <div class="accordion-body">
                                    <p><strong>Çözüm:</strong></p>
                                    <ul>
                                        <li>c:\temp\excel_imports\ klasörünün var olduğundan emin olun</li>
                                        <li>ColdFusion'ın bu klasöre yazma izninin olduğundan emin olun</li>
                                        <li>Dosya boyutunun 10MB'dan küçük olduğundan emin olun</li>
                                    </ul>
                                </div>
                            </div>
                        </div>

                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#error3">
                                    "Veritabanı bağlantı hatası"
                                </button>
                            </h2>
                            <div id="error3" class="accordion-collapse collapse">
                                <div class="accordion-body">
                                    <p><strong>Çözüm:</strong></p>
                                    <ul>
                                        <li>ColdFusion Administrator'da "KD" datasource'unun doğru yapılandırıldığından emin olun</li>
                                        <li>SQL Server'ın çalıştığından emin olun</li>
                                        <li>Veritabanı tablolarının oluşturulduğundan emin olun</li>
                                    </ul>
                                </div>
                            </div>
                        </div>

                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#error4">
                                    "Excel sütunları bulunamadı" hatası
                                </button>
                            </h2>
                            <div id="error4" class="accordion-collapse collapse">
                                <div class="accordion-body">
                                    <p><strong>Çözüm:</strong></p>
                                    <ul>
                                        <li>Excel dosyasının ilk satırında başlık sütunlarının olduğundan emin olun</li>
                                        <li>Sütun adlarının tam olarak şu şekilde olduğundan emin olun: EtaKodu, SeriNo, Üretim Tarihi, Paket Tarihi, Barkod, Miktar, Marka</li>
                                        <li>Başlık satırında boş hücre olmadığından emin olun</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- Dosya Yapısı -->
                <section id="files" class="mb-5">
                    <h2>📁 Dosya Yapısı</h2>
                    
                    <div class="code-block">
                        <pre><code>kd/etiket/form/
├── import_etiket.cfm          # Ana import sayfası
├── process_import.cfm         # Excel işleme ve veri kaydetme
├── view_labels.cfm            # Etiket görüntüleme ve yazdırma
├── setup_database.sql         # Veritabanı kurulum scripti
└── setup_help.cfm             # Bu yardım dosyası

Gerekli Klasörler:
├── c:\temp\excel_imports\     # Excel dosyaları için geçici klasör

Veritabanı Tabloları:
├── etiket_import_log          # Import işlem kayıtları
├── etiket_temp_data           # Import edilen veriler
├── etiket_print_history       # Yazdırma geçmişi
└── etiket_templates           # Etiket şablonları</code></pre>
                    </div>
                </section>

                <!-- Sistem Testi -->
                <section id="test" class="mb-5">
                    <h2>🧪 Sistem Testi</h2>
                    
                    <div class="card">
                        <div class="card-header">
                            <h5>Hızlı Test</h5>
                        </div>
                        <div class="card-body">
                            <p>Sisteminizin doğru çalışıp çalışmadığını test etmek için:</p>
                            
                            <div class="row">
                                <div class="col-md-6">
                                    <h6>1. Veritabanı Bağlantısı</h6>
                                    <cfquery name="testDB" datasource="KD">
                                        SELECT COUNT(*) as table_count 
                                        FROM information_schema.tables 
                                        WHERE table_name IN ('etiket_import_log', 'etiket_temp_data')
                                    </cfquery>
                                    
                                    <cfif testDB.table_count eq 2>
                                        <div class="alert alert-success">
                                            <i class="fas fa-check me-2"></i>Veritabanı tabloları OK
                                        </div>
                                    <cfelse>
                                        <div class="alert alert-danger">
                                            <i class="fas fa-times me-2"></i>Veritabanı tabloları eksik
                                        </div>
                                    </cfif>
                                </div>
                                
                                <div class="col-md-6">
                                    <h6>2. Apache POI Test</h6>
                                    <cftry>
                                        <cfset XSSFWorkbook = createObject("java", "org.apache.poi.xssf.usermodel.XSSFWorkbook")>
                                        <div class="alert alert-success">
                                            <i class="fas fa-check me-2"></i>Apache POI OK
                                        </div>
                                        <cfcatch>
                                            <div class="alert alert-danger">
                                                <i class="fas fa-times me-2"></i>Apache POI yüklenemedi
                                            </div>
                                        </cfcatch>
                                    </cftry>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6">
                                    <h6>3. Temp Klasör</h6>
                                    <cfif directoryExists("c:\temp\excel_imports\")>
                                        <div class="alert alert-success">
                                            <i class="fas fa-check me-2"></i>Temp klasör OK
                                        </div>
                                    <cfelse>
                                        <div class="alert alert-danger">
                                            <i class="fas fa-times me-2"></i>Temp klasör bulunamadı
                                        </div>
                                    </cfif>
                                </div>
                                
                                <div class="col-md-6">
                                    <h6>4. Sistem Dosyaları</h6>
                                    <cfset filesExist = true>
                                    <cfif not fileExists(expandPath("import_etiket.cfm"))>
                                        <cfset filesExist = false>
                                    </cfif>
                                    <cfif not fileExists(expandPath("process_import.cfm"))>
                                        <cfset filesExist = false>
                                    </cfif>
                                    <cfif not fileExists(expandPath("view_labels.cfm"))>
                                        <cfset filesExist = false>
                                    </cfif>
                                    
                                    <cfif filesExist>
                                        <div class="alert alert-success">
                                            <i class="fas fa-check me-2"></i>Sistem dosyaları OK
                                        </div>
                                    <cfelse>
                                        <div class="alert alert-danger">
                                            <i class="fas fa-times me-2"></i>Sistem dosyaları eksik
                                        </div>
                                    </cfif>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- Destek -->
                <section id="support" class="mb-5">
                    <div class="card border-primary">
                        <div class="card-header bg-primary text-white">
                            <h5 class="mb-0"><i class="fas fa-life-ring me-2"></i>Destek ve İletişim</h5>
                        </div>
                        <div class="card-body">
                            <p>Herhangi bir sorun yaşadığınızda veya ek özellik talepleriniz için:</p>
                            <ul>
                                <li>Sistem loglarını kontrol edin</li>
                                <li>ColdFusion error loglarını inceleyin</li>
                                <li>Bu dokümantasyondaki sorun giderme bölümüne bakın</li>
                            </ul>
                        </div>
                    </div>
                </section>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.24.1/components/prism-core.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.24.1/plugins/autoloader/prism-autoloader.min.js"></script>
</body>
</html>
