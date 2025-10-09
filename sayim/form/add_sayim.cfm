<!-------------- Aşağıdaki Tablo için CRUD Operasyonları yapılacaktır. 
#	COLUMN_NAME	    DATA_TYPE	TABLE_NAME
1	SAYIM_ID	    int	        PBS_SERIAL_SAYIM
2	PAPER_NUMBER	nvarchar	PBS_SERIAL_SAYIM
3	DEPARTMENT_ID	int	        PBS_SERIAL_SAYIM
4	LOCATION_ID	    int	        PBS_SERIAL_SAYIM
5	SAYIM_DATE	    datetime	PBS_SERIAL_SAYIM
6	RECORD_DATE	    datetime	PBS_SERIAL_SAYIM
7	RECORD_EMP	    int         PBS_SERIAL_SAYIM
    --------------->

<!--- Form işlemi kontrol --->
<cfquery name="GETPAPER" datasource="w3Qa_1">
            select SAYIM_NO,SAYIM_NUMBER from w3Qa_1.PBS_PAPER_NUMBERS
        </cfquery>
        <cfset zero_Count=0>
        <cfif len(GETPAPER.SAYIM_NUMBER) eq 1>
            <cfset zero_Count=3>
        <cfelseif len(GETPAPER.SAYIM_NUMBER) eq 2>
            <cfset zero_Count=2>
        <cfelseif len(GETPAPER.SAYIM_NUMBER) eq 3>
            <cfset zero_Count=1>   
        </cfif>
            <cfset Spaper_number=REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(GETPAPER.SAYIM_NUMBER,'0',''),'1',''),'2',''),'3',''),'4',''),'5',''),'6',''),'7',''),'8',''),'9','')>
            <cfset Spaper_number=GETPAPER.SAYIM_NO & REPEATSTRING('0',zero_Count) & (GETPAPER.SAYIM_NUMBER+1)>

<cfif isDefined("form.submit")>
    <cftry>
        <!--- Kayıt tarihini şu anki tarih olarak ayarla --->
        <cfset recordDate = now()>
        <!--- DEPO değerini ayır (DEPARTMENT_ID-LOCATION_ID formatında) --->
        <cfset depoValues = listToArray(form.depo_location, "-")>
        <cfset departmentId = depoValues[1]>
        <cfset locationId = depoValues[2]>
        
        <!--- Veritabanına kayıt ekleme --->
        <cfquery datasource="w3Qa_1" result="insertResult">
            INSERT INTO PBS_SERIAL_SAYIM (
                PAPER_NUMBER,
                DEPARTMENT_ID,
                LOCATION_ID,
                SAYIM_DATE,
                RECORD_DATE,
                RECORD_EMP
            ) VALUES (
                <cfqueryparam value="#form.paper_number#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#departmentId#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#locationId#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#form.sayim_date#" cfsqltype="cf_sql_timestamp">,
                <cfqueryparam value="#recordDate#" cfsqltype="cf_sql_timestamp">,
                <cfqueryparam value="#session.ep.userid#" cfsqltype="cf_sql_integer">
            )
        </cfquery>
        <cfquery name="updatepaper" datasource="w3Qa_1">
                update PBS_PAPER_NUMBERS set SAYIM_NUMBER=SAYIM_NUMBER+1
            </cfquery>
        <cfset successMessage = "Sayım kaydı başarıyla eklendi. Kayıt ID: #insertResult.generatedkey#">
        
        <cfcatch type="any">
            <cfset errorMessage = "Hata oluştu: #cfcatch.message# - Detail: #cfcatch.detail#">
        </cfcatch>
    </cftry>
</cfif>

<!--- Depo/Lokasyon listesi için sorgu --->
<cftry>
    <cfquery name="getLocations" datasource="w3Qa">
        SELECT CAST(DEPARTMENT_ID AS VARCHAR)+'-'+CAST(LOCATION_ID AS VARCHAR) AS DEPO, COMMENT 
        FROM STOCKS_LOCATION AS SL 
        ORDER BY COMMENT
    </cfquery>
    <cfcatch>
        <!--- Lokasyon tablosu yoksa boş query oluştur --->
        <cfset getLocations = queryNew("DEPO,COMMENT", "varchar,varchar")>
    </cfcatch>
</cftry>





<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sayım Kaydı Ekle</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .form-container {
            max-width: 800px;
            margin: 20px auto;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
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
            padding: 10px 30px;
            border-radius: 5px;
        }
        .btn-custom:hover {
            background: linear-gradient(45deg, #2980b9, #1f618d);
            color: white;
        }
    </style>
</head>
<body class="bg-light">

<div class="container">
    <div class="form-container bg-white">
        <h2 class="header-title">
            <i class="fas fa-clipboard-list"></i> Yeni Sayım Kaydı Ekle
        </h2>

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

        <form method="post" action="" novalidate>
            <div class="row">
                <div class="col-md-6">
                    <div class="mb-3">
                        <label for="paper_number" class="form-label">
                            <i class="fas fa-file-alt"></i> Evrak Numarası *
                        </label>
                        <input type="text" 
                               class="form-control" 
                               id="paper_number" 
                               name="paper_number" 
                               required
                               maxlength="50"
                               value="<cfoutput>#isDefined('form.paper_number') ? form.paper_number : '#Spaper_number#'#</cfoutput>">
                        <div class="form-text">Sayım evrak numarasını giriniz</div>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="mb-3">
                        <label for="sayim_date" class="form-label">
                            <i class="fas fa-calendar"></i> Sayım Tarihi *
                        </label>
                        <input type="datetime-local" 
                               class="form-control" 
                               id="sayim_date" 
                               name="sayim_date" 
                               required
                               value="<cfoutput>#isDefined('form.sayim_date') ? form.sayim_date : dateFormat(now(), 'yyyy-mm-dd') & 'T' & timeFormat(now(), 'HH:mm')#</cfoutput>">
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-6">
                    <div class="mb-3">
                        <label for="depo_location" class="form-label">
                            <i class="fas fa-warehouse"></i> Depo/Lokasyon *
                        </label>
                        <select class="form-select" id="depo_location" name="depo_location" required>
                            <option value="">Depo/Lokasyon Seçiniz</option>
                            <cfoutput query="getLocations">
                                <option value="#DEPO#" 
                                    <cfif isDefined('form.depo_location') and form.depo_location eq DEPO>selected</cfif>>
                                    #COMMENT#
                                </option>
                            </cfoutput>
                        </select>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="mb-3">
                        <label class="form-label">
                            <i class="fas fa-clock"></i> Kayıt Tarihi
                        </label>
                        <input type="text" 
                               class="form-control" 
                               value="<cfoutput>#dateFormat(now(), 'dd/mm/yyyy')# #timeFormat(now(), 'HH:mm:ss')#</cfoutput>" 
                               readonly>
                        <div class="form-text">Otomatik olarak bugünün tarihi atanacaktır</div>
                    </div>
                </div>
            </div>

            <div class="row mt-4">
                <div class="col-12">
                    <div class="d-flex gap-2">
                        <button type="submit" name="submit" class="btn btn-custom">
                            <i class="fas fa-save"></i> Kaydet
                        </button>
                        <button type="reset" class="btn btn-outline-secondary">
                            <i class="fas fa-undo"></i> Temizle
                        </button>
                        <a href="/index.cfm?fuseaction=stock.emptypopup_list_sayim_pbs" class="btn btn-outline-primary">
                            <i class="fas fa-list"></i> Sayım Listesi
                        </a>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
// Form validasyonu
(function() {
    'use strict';
    window.addEventListener('load', function() {
        var forms = document.getElementsByClassName('needs-validation');
        var validation = Array.prototype.filter.call(forms, function(form) {
            form.addEventListener('submit', function(event) {
                if (form.checkValidity() === false) {
                    event.preventDefault();
                    event.stopPropagation();
                }
                form.classList.add('was-validated');
            }, false);
        });
    }, false);
})();

// Sayım tarihi için bugünkü tarihi varsayılan olarak ayarla
document.addEventListener('DOMContentLoaded', function() {
    const sayimDateInput = document.getElementById('sayim_date');
    if (!sayimDateInput.value) {
        const now = new Date();
        const year = now.getFullYear();
        const month = String(now.getMonth() + 1).padStart(2, '0');
        const day = String(now.getDate()).padStart(2, '0');
        const hours = String(now.getHours()).padStart(2, '0');
        const minutes = String(now.getMinutes()).padStart(2, '0');
        
        sayimDateInput.value = `${year}-${month}-${day}T${hours}:${minutes}`;
    }
});
</script>

</body>
</html>