<cfdump var="#url#" label="URL Parameters">
<cfdump var="#attributes#" label="Form Parameters">
<!--- Sayım Detay İşlemi Sayfası --->
<cfoutput>
    #isDefined("attributes.sayim_id")#
</cfoutput>

<!--- URL'den sayım ID'sini al --->


<cfset sayimId = url.sayim_id>

<!--- Sayım bilgilerini getir --->
<cftry>
    <cfquery name="getSayimInfo" datasource="w3Qa">
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
        WHERE s.SAYIM_ID = <cfqueryparam value="#sayimId#" cfsqltype="cf_sql_integer">
    </cfquery>
    <cfdump var="#getSayimInfo#" label="Sayım Bilgileri">
    <cfabort>
    <cfif getSayimInfo.recordCount eq 0>
        <cflocation url="../display/list_sayim.cfm" addtoken="false">
    </cfif>
    
    <cfcatch>
        <cfdump var="#cfcatch#" label="Hata Detayları">
        <cfset errorMessage = "Sayım bilgileri alınamadı: #cfcatch.message#">
        <!---<cflocation url="../display/list_sayim.cfm" addtoken="false">---->
    </cfcatch>
</cftry>

<!--- Mevcut sayım detaylarını getir --->
<cftry>
    <cfquery name="getSayimDetails" datasource="w3Qa">
        SELECT 
            SAYIM_ROW_ID,
            SAYIM_ID,
            SERIAL_NUMBER,
            IN_OUT
        FROM PBS_SERIAL_SAYIM_DETAIL
        WHERE SAYIM_ID = <cfqueryparam value="#sayimId#" cfsqltype="cf_sql_integer">
        ORDER BY SAYIM_ROW_ID DESC
    </cfquery>
    <cfcatch>
        <cfset getSayimDetails = queryNew("SAYIM_ROW_ID,SAYIM_ID,SERIAL_NUMBER,IN_OUT", "integer,integer,varchar,bit")>
    </cfcatch>
</cftry>

<!--- Seri numarası ekleme işlemi --->
<cfif isDefined("form.action") and form.action eq "add_serial">
    <cfif isDefined("form.serial_number") and len(trim(form.serial_number))>
        <cftry>
            <!--- Aynı seri numarasının daha önce eklenip eklenmediğini kontrol et --->
            <cfquery name="checkSerial" datasource="w3Qa">
                SELECT COUNT(*) as SERIAL_COUNT
                FROM PBS_SERIAL_SAYIM_DETAIL
                WHERE SAYIM_ID = <cfqueryparam value="#sayimId#" cfsqltype="cf_sql_integer">
                AND SERIAL_NUMBER = <cfqueryparam value="#trim(form.serial_number)#" cfsqltype="cf_sql_varchar">
            </cfquery>
            
            <cfif checkSerial.SERIAL_COUNT eq 0>
                <!--- Yeni seri numarası ekle --->
                <cfquery datasource="w3Qa">
                    INSERT INTO PBS_SERIAL_SAYIM_DETAIL (
                        SAYIM_ID,
                        SERIAL_NUMBER,
                        IN_OUT
                    ) VALUES (
                        <cfqueryparam value="#sayimId#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#trim(form.serial_number)#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="1" cfsqltype="cf_sql_bit">
                    )
                </cfquery>
                <cfset successMessage = "Seri numarası başarıyla eklendi: #trim(form.serial_number)#">
            <cfelse>
                <cfset warningMessage = "Bu seri numarası zaten eklenmiş: #trim(form.serial_number)#">
            </cfif>
            
            <!--- Sayım detaylarını yeniden getir --->
            <cfquery name="getSayimDetails" datasource="w3Qa">
                SELECT 
                    SAYIM_ROW_ID,
                    SAYIM_ID,
                    SERIAL_NUMBER,
                    IN_OUT
                FROM PBS_SERIAL_SAYIM_DETAIL
                WHERE SAYIM_ID = <cfqueryparam value="#sayimId#" cfsqltype="cf_sql_integer">
                ORDER BY SAYIM_ROW_ID DESC
            </cfquery>
            
            <cfcatch>
                <cfset errorMessage = "Seri numarası eklenirken hata oluştu: #cfcatch.message#">
            </cfcatch>
        </cftry>
    <cfelse>
        <cfset errorMessage = "Lütfen geçerli bir seri numarası giriniz.">
    </cfif>
</cfif>

<!--- Seri numarası silme işlemi --->
<cfif isDefined("url.action") and url.action eq "delete_serial" and isDefined("url.row_id")>
    <cftry>
        <cfquery datasource="w3Qa">
            DELETE FROM PBS_SERIAL_SAYIM_DETAIL
            WHERE SAYIM_ROW_ID = <cfqueryparam value="#url.row_id#" cfsqltype="cf_sql_integer">
            AND SAYIM_ID = <cfqueryparam value="#sayimId#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfset successMessage = "Seri numarası başarıyla silindi.">
        <cflocation url="sayim_detail.cfm?sayim_id=#sayimId#" addtoken="false">
        <cfcatch>
            <cfset errorMessage = "Seri numarası silinirken hata oluştu: #cfcatch.message#">
        </cfcatch>
    </cftry>
</cfif>

<!--- Sayımı tamamlama işlemi --->
<cfif isDefined("form.action") and form.action eq "complete_sayim">
    <cfif getSayimDetails.recordCount gt 0>
        <cfset successMessage = "Sayım tamamlandı! Toplam #getSayimDetails.recordCount# adet seri numarası kaydedildi.">
        <!--- Burada isteğe bağlı olarak sayım durumu güncellenebilir --->
    <cfelse>
        <cfset warningMessage = "Sayımı tamamlamak için en az bir seri numarası eklemelisiniz.">
    </cfif>
</cfif>

<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sayım Detay - <cfoutput>#getSayimInfo.PAPER_NUMBER#</cfoutput></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .main-container {
            margin: 20px;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            background: white;
        }
        .header-info {
            background: linear-gradient(45deg, #3498db, #2980b9);
            color: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
        }
        .serial-input-section {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            border-left: 4px solid #3498db;
        }
        .serial-basket {
            background: white;
            border: 2px dashed #3498db;
            border-radius: 10px;
            padding: 20px;
            min-height: 400px;
            max-height: 500px;
            overflow-y: auto;
        }
        .serial-item {
            background: linear-gradient(45deg, #e8f5e8, #d4f4dd);
            border: 1px solid #27ae60;
            border-radius: 8px;
            padding: 10px;
            margin-bottom: 8px;
            display: flex;
            justify-content: between;
            align-items: center;
        }
        .serial-item:hover {
            background: linear-gradient(45deg, #d4f4dd, #c8e6c9);
            transform: translateY(-1px);
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        .btn-custom {
            background: linear-gradient(45deg, #3498db, #2980b9);
            border: none;
            color: white;
            padding: 10px 20px;
            border-radius: 5px;
        }
        .btn-custom:hover {
            background: linear-gradient(45deg, #2980b9, #1f618d);
            color: white;
        }
        .serial-count {
            font-size: 1.2em;
            font-weight: bold;
            color: #27ae60;
        }
        .barcode-input {
            font-size: 1.1em;
            padding: 15px;
            border: 2px solid #3498db;
            border-radius: 8px;
        }
        .barcode-input:focus {
            border-color: #2980b9;
            box-shadow: 0 0 10px rgba(52, 152, 219, 0.3);
        }
    </style>
</head>
<body class="bg-light">

<div class="container-fluid">
    <div class="main-container">
        <!--- Sayım Bilgileri --->
        <div class="header-info">
            <div class="row">
                <div class="col-md-8">
                    <h3><i class="fas fa-clipboard-list"></i> Sayım Detay İşlemi</h3>
                    <cfoutput>
                        <p class="mb-1"><strong>Evrak No:</strong> #getSayimInfo.PAPER_NUMBER#</p>
                        <p class="mb-1"><strong>Depo:</strong> #getSayimInfo.DEPO_NAME# (#getSayimInfo.DEPO_CODE#)</p>
                        <p class="mb-0"><strong>Sayım Tarihi:</strong> #dateFormat(getSayimInfo.SAYIM_DATE, "dd/mm/yyyy")# #timeFormat(getSayimInfo.SAYIM_DATE, "HH:mm")#</p>
                    </cfoutput>
                </div>
                <div class="col-md-4 text-end">
                    <a href="../display/list_sayim.cfm" class="btn btn-light">
                        <i class="fas fa-arrow-left"></i> Geri Dön
                    </a>
                </div>
            </div>
        </div>

        <!--- Mesajlar --->
        <cfif isDefined("successMessage")>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle"></i> <cfoutput>#successMessage#</cfoutput>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </cfif>

        <cfif isDefined("warningMessage")>
            <div class="alert alert-warning alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-triangle"></i> <cfoutput>#warningMessage#</cfoutput>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </cfif>

        <cfif isDefined("errorMessage")>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-triangle"></i> <cfoutput>#errorMessage#</cfoutput>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </cfif>

        <div class="row">
            <!--- Seri Numarası Giriş Bölümü --->
            <div class="col-md-6">
                <div class="serial-input-section">
                    <h5><i class="fas fa-barcode"></i> Seri Numarası Okut</h5>
                    <form method="post" action="" id="serialForm">
                        <input type="hidden" name="action" value="add_serial">
                        <div class="input-group mb-3">
                            <input type="text" 
                                   name="serial_number" 
                                   id="serialInput"
                                   class="form-control barcode-input" 
                                   placeholder="Seri numarasını okutun veya yazın..."
                                   autocomplete="off"
                                   autofocus>
                            <button type="submit" class="btn btn-custom">
                                <i class="fas fa-plus"></i> Ekle
                            </button>
                        </div>
                    </form>
                    
                    <div class="d-flex justify-content-between align-items-center">
                        <span class="serial-count">
                            <i class="fas fa-list-ol"></i> 
                            Toplam: <cfoutput>#getSayimDetails.recordCount#</cfoutput> adet
                        </span>
                        
                        <cfif getSayimDetails.recordCount gt 0>
                            <form method="post" action="" class="d-inline">
                                <input type="hidden" name="action" value="complete_sayim">
                                <button type="submit" class="btn btn-success" onclick="return confirm('Sayımı tamamlamak istediğinizden emin misiniz?')">
                                    <i class="fas fa-check"></i> Sayımı Tamamla
                                </button>
                            </form>
                        </cfif>
                    </div>
                </div>
            </div>

            <!--- Seri Numarası Sepeti --->
            <div class="col-md-6">
                <h5><i class="fas fa-shopping-basket"></i> Sepet</h5>
                <div class="serial-basket">
                    <cfif getSayimDetails.recordCount eq 0>
                        <div class="text-center text-muted py-5">
                            <i class="fas fa-barcode fa-3x mb-3"></i>
                            <h6>Henüz seri numarası eklenmedi</h6>
                            <p>Seri numaralarını okutmaya başlayın</p>
                        </div>
                    <cfelse>
                        <cfoutput query="getSayimDetails">
                            <div class="serial-item">
                                <div class="flex-grow-1">
                                    <strong>#SERIAL_NUMBER#</strong>
                                    <br><small class="text-muted">ID: #SAYIM_ROW_ID#</small>
                                </div>
                                <div>
                                    <span class="badge bg-success me-2">
                                        <cfif IN_OUT>Dahil<cfelse>Hariç</cfif>
                                    </span>
                                    <button type="button" 
                                            class="btn btn-outline-danger btn-sm"
                                            onclick="removeSerial(#SAYIM_ROW_ID#, '#SERIAL_NUMBER#')"
                                            title="Sil">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            </div>
                        </cfoutput>
                    </cfif>
                </div>
            </div>
        </div>

        <!--- İstatistikler --->
        <cfif getSayimDetails.recordCount gt 0>
            <div class="row mt-4">
                <div class="col-md-12">
                    <div class="card">
                        <div class="card-header">
                            <h6><i class="fas fa-chart-bar"></i> Sayım İstatistikleri</h6>
                        </div>
                        <div class="card-body">
                            <div class="row text-center">
                                <div class="col-md-3">
                                    <h4 class="text-primary"><cfoutput>#getSayimDetails.recordCount#</cfoutput></h4>
                                    <p class="text-muted">Toplam Ürün</p>
                                </div>
                                <div class="col-md-3">
                                    <cfquery name="inCount" dbtype="query">
                                        SELECT COUNT(*) as IN_COUNT FROM getSayimDetails WHERE IN_OUT = 1
                                    </cfquery>
                                    <h4 class="text-success"><cfoutput>#inCount.IN_COUNT#</cfoutput></h4>
                                    <p class="text-muted">Dahil Edilen</p>
                                </div>
                                <div class="col-md-3">
                                    <cfquery name="outCount" dbtype="query">
                                        SELECT COUNT(*) as OUT_COUNT FROM getSayimDetails WHERE IN_OUT = 0
                                    </cfquery>
                                    <h4 class="text-warning"><cfoutput>#outCount.OUT_COUNT#</cfoutput></h4>
                                    <p class="text-muted">Hariç Tutulan</p>
                                </div>
                                <div class="col-md-3">
                                    <h4 class="text-info">
                                        <cfoutput>#dateFormat(now(), "dd/mm/yyyy")#</cfoutput>
                                    </h4>
                                    <p class="text-muted">Sayım Günü</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </cfif>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<script>
// Sayfa yüklendiğinde input'a fokus ver
document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('serialInput').focus();
});

// Form submit edildikten sonra input'u temizle ve fokus ver
document.getElementById('serialForm').addEventListener('submit', function(e) {
    setTimeout(function() {
        const input = document.getElementById('serialInput');
        input.value = '';
        input.focus();
    }, 100);
});

// Seri numarası silme onayı
function removeSerial(rowId, serialNumber) {
    Swal.fire({
        title: 'Seri Numarasını Sil?',
        text: serialNumber + " numaralı seri numarasını sepetten çıkarmak istediğinizden emin misiniz?",
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#3085d6',
        confirmButtonText: 'Evet, Sil!',
        cancelButtonText: 'İptal'
    }).then((result) => {
        if (result.isConfirmed) {
            window.location.href = 'sayim_detail.cfm?sayim_id=<cfoutput>#sayimId#</cfoutput>&action=delete_serial&row_id=' + rowId;
        }
    });
}

// Enter tuşu ile form submit
document.getElementById('serialInput').addEventListener('keypress', function(e) {
    if (e.key === 'Enter') {
        e.preventDefault();
        document.getElementById('serialForm').submit();
    }
});

// Barcode scanner için otomatik submit (isteğe bağlı)
let barcodeBuffer = '';
let barcodeTimeout;

document.getElementById('serialInput').addEventListener('input', function(e) {
    clearTimeout(barcodeTimeout);
    barcodeBuffer = e.target.value;
    
    // Barcode scanner genellikle hızlı input yapar ve enter ile bitirir
    // Bu kısım isteğe bağlı olarak açılabilir
    /*
    barcodeTimeout = setTimeout(function() {
        if (barcodeBuffer.length > 5) { // Minimum barcode uzunluğu
            document.getElementById('serialForm').submit();
        }
    }, 300);
    */
});

// Automatic refresh every 30 seconds (optional)
// setInterval(function() {
//     if (confirm('Sayfayı güncellemek istiyor musunuz?')) {
//         location.reload();
//     }
// }, 30000);
</script>

</body>
</html>
