<!DOCTYPE html>
<html>
<head>
    <title>KD Admin Panel</title>
    <meta charset="utf-8">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="#">
                <i class="bi bi-gear-fill"></i> KD Admin Panel
            </a>
            <div class="navbar-nav ms-auto">
                <a class="nav-link" href="sql_manager.cfm">
                    <i class="bi bi-database"></i> SQL Yöneticisi
                </a>
                <a class="nav-link" href="VtSorgu.cfm">
                    <i class="bi bi-terminal"></i> Eski SQL
                </a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <div class="row">
            <div class="col-md-12">
                <h1><i class="bi bi-house"></i> Admin Panel Ana Sayfa</h1>
                <p class="lead">Veritabanı yönetim araçlarına buradan erişebilirsiniz.</p>
            </div>
        </div>

        <div class="row mt-4">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title">
                            <i class="bi bi-database text-primary"></i> SQL Sorgu Yöneticisi
                        </h5>
                        <p class="card-text">
                            Gelişmiş SQL sorgu arayüzü. Özellikler:
                        </p>
                        <ul>
                            <li>Syntax highlighting</li>
                            <li>Tablo bilgileri ve kolon listesi</li>
                            <li>Sorgu geçmişi ve favoriler</li>
                            <li>Excel/CSV/JSON export</li>
                            <li>Hazır sorgular</li>
                        </ul>
                        <a href="sql_manager.cfm" class="btn btn-primary">
                            <i class="bi bi-arrow-right"></i> SQL Yöneticisini Aç
                        </a>
                    </div>
                </div>
            </div>

            <div class="col-md-6">
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title">
                            <i class="bi bi-terminal text-success"></i> Klasik SQL Arayüzü
                        </h5>
                        <p class="card-text">
                            Mevcut SQL sorgu arayüzü. Temel özellikler:
                        </p>
                        <ul>
                            <li>Basit SQL editörü</li>
                            <li>Tablo listesi</li>
                            <li>Kolon bilgileri</li>
                            <li>Sonuç görüntüleme</li>
                        </ul>
                        <a href="VtSorgu.cfm" class="btn btn-success">
                            <i class="bi bi-arrow-right"></i> Klasik Arayüzü Aç
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <div class="row mt-4">
            <div class="col-md-12">
                <div class="card">
                    <div class="card-header">
                        <h5><i class="bi bi-info-circle"></i> Kullanım Bilgileri</h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <h6>Klavye Kısayolları:</h6>
                                <ul>
                                    <li><kbd>Ctrl + Enter</kbd>: Sorguyu çalıştır</li>
                                    <li><kbd>Ctrl + S</kbd>: Sorguyu kaydet</li>
                                    <li><kbd>Ctrl + Space</kbd>: Otomatik tamamlama</li>
                                </ul>
                            </div>
                            <div class="col-md-6">
                                <h6>Güvenlik Notları:</h6>
                                <ul>
                                    <li>Bu panel sadece admin kullanıcılar içindir</li>
                                    <li>Dikkatli SQL sorguları yazın</li>
                                    <li>Büyük veri setlerinde LIMIT kullanın</li>
                                    <li>UPDATE/DELETE işlemlerinde WHERE kullanmayı unutmayın</li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <footer class="bg-light mt-5 py-3">
        <div class="container">
            <div class="text-center text-muted">
                <small>KD Admin Panel - SQL Yönetim Sistemi</small>
            </div>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
