<!--- Sayım kayıtlarını listeleme sayfası --->

<!--- Sayım listesi için sorgu --->
<cftry>
    <cfquery name="getSayimList" datasource="w3Qa_1">
        SELECT 
            s.SAYIM_ID,
            s.PAPER_NUMBER,
            s.DEPARTMENT_ID,
            s.LOCATION_ID,
            CAST(s.DEPARTMENT_ID AS VARCHAR)+'-'+CAST(s.LOCATION_ID AS VARCHAR) AS DEPO_CODE,
            sl.COMMENT AS DEPO_NAME,
            s.SAYIM_DATE,
            s.RECORD_DATE,
            s.RECORD_EMP
        FROM PBS_SERIAL_SAYIM s
        LEFT JOIN STOCKS_LOCATION sl ON (
            s.DEPARTMENT_ID = sl.DEPARTMENT_ID AND 
            s.LOCATION_ID = sl.LOCATION_ID
        )
        ORDER BY s.RECORD_DATE DESC, s.SAYIM_ID DESC
    </cfquery>
    <cfcatch>
        <cfset getSayimList = queryNew("SAYIM_ID,PAPER_NUMBER,DEPARTMENT_ID,LOCATION_ID,DEPO_CODE,DEPO_NAME,SAYIM_DATE,RECORD_DATE,RECORD_EMP", "integer,varchar,integer,integer,varchar,varchar,date,date,integer")>
        <cfset errorMessage = "Veritabanı hatası: #cfcatch.message#">
    </cfcatch>
</cftry>

<!--- Silme işlemi --->
<cfif isDefined("url.action") and url.action eq "delete" and isDefined("url.id")>
    <cftry>
        <cfquery datasource="w3Qa">
            DELETE FROM PBS_SERIAL_SAYIM 
            WHERE SAYIM_ID = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfset successMessage = "Sayım kaydı başarıyla silindi.">
        <cflocation url="list_sayim.cfm" addtoken="false">
        <cfcatch>
            <cfset errorMessage = "Silme işlemi sırasında hata oluştu: #cfcatch.message#">
        </cfcatch>
    </cftry>
</cfif>

<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sayım Listesi</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.datatables.net/1.11.5/css/dataTables.bootstrap5.min.css" rel="stylesheet">
    <style>
        .table-container {
            margin: 20px;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            background: white;
        }
        .header-title {
            color: #2c3e50;
            border-bottom: 2px solid #3498db;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }
        .btn-custom {
            background: linear-gradient(45deg, #3498db, #2980b9);
            border: none;
            color: white;
            padding: 8px 16px;
            border-radius: 5px;
            text-decoration: none;
        }
        .btn-custom:hover {
            background: linear-gradient(45deg, #2980b9, #1f618d);
            color: white;
            text-decoration: none;
        }
        .action-buttons {
            white-space: nowrap;
        }
        .badge-depo {
            background: linear-gradient(45deg, #e74c3c, #c0392b);
            color: white;
            padding: 5px 10px;
            border-radius: 15px;
            font-size: 0.8em;
        }
        .status-active {
            color: #27ae60;
            font-weight: bold;
        }
        .table th {
            background-color: #f8f9fa;
            border-top: none;
        }
        .search-section {
            margin-bottom: 20px;
            padding: 15px;
            background-color: #f8f9fa;
            border-radius: 8px;
        }
    </style>
</head>
<body class="bg-light">

<div class="container-fluid">
    <div class="table-container">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="header-title mb-0">
                <i class="fas fa-clipboard-list"></i> Sayım Listesi
            </h2>
            <div>
                <a href="../form/add_sayim.cfm" class="btn btn-custom">
                    <i class="fas fa-plus"></i> Yeni Sayım Ekle
                </a>
                <button class="btn btn-outline-success" onclick="exportToExcel()">
                    <i class="fas fa-file-excel"></i> Excel'e Aktar
                </button>
            </div>
        </div>

        <!--- Başarı mesajı --->
        <cfif isDefined("successMessage")>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle"></i> <cfoutput>#successMessage#</cfoutput>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </cfif>

        <!--- Hata mesajı --->
        <cfif isDefined("errorMessage")>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-triangle"></i> <cfoutput>#errorMessage#</cfoutput>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </cfif>

        <!--- Arama ve Filtreleme --->
        <div class="search-section">
            <div class="row">
                <div class="col-md-3">
                    <label class="form-label">Evrak Numarası</label>
                    <input type="text" id="searchPaper" class="form-control" placeholder="Evrak numarası ara...">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Depo</label>
                    <select id="searchDepo" class="form-select">
                        <option value="">Tüm Depolar</option>
                        <cfoutput query="getSayimList" group="DEPO_NAME">
                            <cfif len(trim(DEPO_NAME))>
                                <option value="#DEPO_NAME#">#DEPO_NAME#</option>
                            </cfif>
                        </cfoutput>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Başlangıç Tarihi</label>
                    <input type="date" id="searchDateStart" class="form-control">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Bitiş Tarihi</label>
                    <input type="date" id="searchDateEnd" class="form-control">
                </div>
            </div>
        </div>

        <!--- Sayım Tablosu --->
        <div class="table-responsive">
            <table id="sayimTable" class="table table-striped table-hover">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Evrak No</th>
                        <th>Depo</th>
                        <th>Depo Kodu</th>
                        <th>Sayım Tarihi</th>
                        <th>Kayıt Tarihi</th>
                        <th>Kayıt Eden</th>
                        <th class="text-center">İşlemler</th>
                    </tr>
                </thead>
                <tbody>
                    <cfoutput query="getSayimList">
                        <tr>
                            <td><strong>## #SAYIM_ID#</strong></td>
                            <td>
                                <span class="badge bg-primary">#PAPER_NUMBER#</span>
                            </td>
                            <td>
                                <cfif len(trim(DEPO_NAME))>
                                    #DEPO_NAME#
                                <cfelse>
                                    <span class="text-muted">Tanımsız Depo</span>
                                </cfif>
                            </td>
                            <td>
                                <span class="badge-depo">#DEPO_CODE#</span>
                            </td>
                            <td>
                                <i class="fas fa-calendar-alt text-primary"></i>
                                #dateFormat(SAYIM_DATE, "dd/mm/yyyy")#<br>
                                <small class="text-muted">#timeFormat(SAYIM_DATE, "HH:mm")#</small>
                            </td>
                            <td>
                                <i class="fas fa-clock text-success"></i>
                                #dateFormat(RECORD_DATE, "dd/mm/yyyy")#<br>
                                <small class="text-muted">#timeFormat(RECORD_DATE, "HH:mm:ss")#</small>
                            </td>
                            <td>
                                <i class="fas fa-user text-info"></i> #RECORD_EMP#
                            </td>
                            <td class="text-center action-buttons">
                                <div class="btn-group btn-group-sm" role="group">
                                    <a href="../form/edit_sayim.cfm?id=#SAYIM_ID#" 
                                       class="btn btn-outline-primary" 
                                       title="Düzenle">
                                        <i class="fas fa-edit"></i>
                                    </a>
                                    <button type="button" 
                                            class="btn btn-outline-info" 
                                            onclick="viewDetails(#SAYIM_ID#)"
                                            title="Detay">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                    <button type="button" 
                                            class="btn btn-outline-danger" 
                                            onclick="confirmDelete(#SAYIM_ID#, '#PAPER_NUMBER#')"
                                            title="Sil">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                    </cfoutput>
                </tbody>
            </table>
        </div>

        <!--- Tablo boşsa mesaj göster --->
        <cfif getSayimList.recordCount eq 0>
            <div class="text-center py-5">
                <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                <h5 class="text-muted">Henüz sayım kaydı bulunmamaktadır</h5>
                <p class="text-muted">Yeni sayım kaydı eklemek için yukarıdaki butonu kullanabilirsiniz.</p>
            </div>
        </cfif>

        <!--- Sayım İstatistikleri --->
        <cfif getSayimList.recordCount gt 0>
            <div class="row mt-4">
                <div class="col-md-3">
                    <div class="card text-center">
                        <div class="card-body">
                            <h5 class="card-title text-primary">
                                <i class="fas fa-clipboard-list"></i>
                            </h5>
                            <h3 class="text-primary"><cfoutput>#getSayimList.recordCount#</cfoutput></h3>
                            <p class="card-text">Toplam Sayım</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-center">
                        <div class="card-body">
                            <h5 class="card-title text-success">
                                <i class="fas fa-calendar-day"></i>
                            </h5>
                            <h3 class="text-success">
                                <cfquery name="todayCount" dbtype="query">
                                    SELECT COUNT(*) as TODAY_COUNT 
                                    FROM getSayimList 
                                    WHERE CAST(RECORD_DATE AS DATE) = CAST(GETDATE() AS DATE)
                                </cfquery>
                                <cfoutput>#todayCount.TODAY_COUNT#</cfoutput>
                            </h3>
                            <p class="card-text">Bugünkü Sayım</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-center">
                        <div class="card-body">
                            <h5 class="card-title text-warning">
                                <i class="fas fa-warehouse"></i>
                            </h5>
                            <h3 class="text-warning">
                                <cfquery name="depoCount" dbtype="query">
                                    SELECT COUNT(DISTINCT DEPO_CODE) as DEPO_COUNT FROM getSayimList
                                </cfquery>
                                <cfoutput>#depoCount.DEPO_COUNT#</cfoutput>
                            </h3>
                            <p class="card-text">Farklı Depo</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-center">
                        <div class="card-body">
                            <h5 class="card-title text-info">
                                <i class="fas fa-users"></i>
                            </h5>
                            <h3 class="text-info">
                                <cfquery name="userCount" dbtype="query">
                                    SELECT COUNT(DISTINCT RECORD_EMP) as USER_COUNT FROM getSayimList
                                </cfquery>
                                <cfoutput>#userCount.USER_COUNT#</cfoutput>
                            </h3>
                            <p class="card-text">Kayıt Eden</p>
                        </div>
                    </div>
                </div>
            </div>
        </cfif>
    </div>
</div>

<!-- Modal for Details -->
<div class="modal fade" id="detailModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Sayım Detayları</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" id="modalContent">
                <!-- İçerik AJAX ile yüklenecek -->
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.11.5/js/dataTables.bootstrap5.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<script>
$(document).ready(function() {
    // DataTable başlatma
    var table = $('#sayimTable').DataTable({
        "language": {
            "url": "//cdn.datatables.net/plug-ins/1.11.5/i18n/tr.json"
        },
        "pageLength": 25,
        "order": [[0, "desc"]],
        "columnDefs": [
            { "orderable": false, "targets": [7] }
        ]
    });

    // Arama filtreleri
    $('#searchPaper').on('keyup', function() {
        table.column(1).search(this.value).draw();
    });

    $('#searchDepo').on('change', function() {
        table.column(2).search(this.value).draw();
    });

    // Tarih filtreleri
    $('#searchDateStart, #searchDateEnd').on('change', function() {
        var startDate = $('#searchDateStart').val();
        var endDate = $('#searchDateEnd').val();
        
        if (startDate || endDate) {
            $.fn.dataTable.ext.search.push(
                function(settings, data, dataIndex) {
                    var dateStr = data[5]; // Kayıt tarihi sütunu
                    var recordDate = new Date(dateStr.split('/').reverse().join('-'));
                    var start = startDate ? new Date(startDate) : null;
                    var end = endDate ? new Date(endDate) : null;

                    if (!start && !end) return true;
                    if (!start && recordDate <= end) return true;
                    if (!end && recordDate >= start) return true;
                    if (recordDate >= start && recordDate <= end) return true;
                    return false;
                }
            );
        } else {
            $.fn.dataTable.ext.search.pop();
        }
        table.draw();
    });
});

// Silme onayı
function confirmDelete(id, paperNumber) {
    Swal.fire({
        title: 'Emin misiniz?',
        text: paperNumber + " numaralı sayım kaydını silmek istediğinizden emin misiniz?",
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#3085d6',
        confirmButtonText: 'Evet, Sil!',
        cancelButtonText: 'İptal'
    }).then((result) => {
        if (result.isConfirmed) {
            window.location.href = 'list_sayim.cfm?action=delete&id=' + id;
        }
    });
}

// Detay görüntüleme
function viewDetails(id) {
    $('#modalContent').html('<div class="text-center"><i class="fas fa-spinner fa-spin"></i> Yükleniyor...</div>');
    $('#detailModal').modal('show');
    
    // AJAX ile detay bilgilerini yükle
    // Bu kısım detail_sayim.cfm sayfası oluşturulduktan sonra aktif edilebilir
    /*
    $.get('detail_sayim.cfm?id=' + id, function(data) {
        $('#modalContent').html(data);
    });
    */
    
    // Şimdilik basit bilgi göster
    $('#modalContent').html(`
        <div class="alert alert-info">
            <h6>Sayım ID: ${id}</h6>
            <p>Detay sayfası henüz oluşturulmadı. detail_sayim.cfm sayfası oluşturulduktan sonra bu alan aktif olacaktır.</p>
        </div>
    `);
}

// Excel'e aktarma
function exportToExcel() {
    // Bu fonksiyon Excel export için kullanılacak
    // DataTables Buttons extension kullanılabilir
    alert('Excel export özelliği yakında eklenecektir.');
}
</script>

</body>
</html>
