<!--- Database Import Processing Page --->
<cfparam name="form.clearTable" default="false">
<cfparam name="form.validateData" default="false">
<cfparam name="form.confirmImport" default="false">

<!--- Resolve datasource configuration dynamically --->
<cffile action="read" file="#ExpandPath('/pbs_dsn.txt')#" variable="configContent">
<cfset variables.dsn = trim(configContent)>
<cfquery name="getParams" datasource="#variables.dsn#">
    SELECT PBS_MODUL_COMPANY_ID FROM PBS_PARAMETERS
</cfquery>
<cfset variables.companyId = trim(getParams.PBS_MODUL_COMPANY_ID)>
<cfset variables.dsnCompany = variables.dsn & '_' & variables.companyId>
<cfset variables.dsn3 = variables.dsnCompany>
<cfset variables.dsnShip = variables.dsn & '_#year(now())#_' & variables.companyId>

<!--- Serial Number Generator Function (same as Excel import) --->
<cffunction name="generateSerialNumbers" returntype="array" access="public">
    <cfargument name="etaKodu" type="string" required="true">
    <cfargument name="miktar" type="numeric" required="true">
    <cfargument name="importId" type="numeric" required="true">
    
    <cfset var serialNumbers = []>
    <cfset var prefix = left(etaKodu, 3) & dateFormat(now(), "yymmdd")>
    <cfset var baseSerial = "">
    <cfset var counter = 1>
    
    <!--- Debug: Log function call --->
    <cflog file="etiket_import" text="generateSerialNumbers called: etaKodu=#etaKodu#, miktar=#miktar#, prefix=#prefix#">
    
    <!--- Get last serial number for this eta kodu and date --->
    <cfquery name="getLastSerial" datasource="#variables.dsn#">
        SELECT TOP 1 seri_no 
        FROM etiket_temp_data 
        WHERE eta_kodu = <cfqueryparam value="#etaKodu#" cfsqltype="cf_sql_varchar">
        AND seri_no LIKE <cfqueryparam value="#prefix#%" cfsqltype="cf_sql_varchar">
        ORDER BY seri_no DESC
    </cfquery> <!----ok---->
    
    <cfif getLastSerial.recordCount gt 0>
        <!--- Extract counter from last serial --->
        <cfset lastSerial = getLastSerial.seri_no>
        <cfset counterPart = right(lastSerial, 4)>
        <cfif isNumeric(counterPart)>
            <cfset counter = val(counterPart) + 1>
        </cfif>
        <cflog file="etiket_import" text="Found last serial: #lastSerial#, counter will start from: #counter#">
    <cfelse>
        <cflog file="etiket_import" text="No previous serial found, starting from: #counter#">
    </cfif>
    
    <!--- Generate serial numbers --->
    <cfloop from="1" to="#miktar#" index="i">
        <cfset serialNumber = prefix & numberFormat(counter, "0000")>
        <cfset arrayAppend(serialNumbers, serialNumber)>
        <cfset counter = counter + 1>
    </cfloop>
    
    <cflog file="etiket_import" text="Generated #arrayLen(serialNumbers)# serial numbers: #arrayToList(serialNumbers)#">
    
    <cfreturn serialNumbers>
</cffunction>

<!--- Initialize Variables --->
<cfset importResult = {
    success = false,
    message = "",
    totalRecords = 0,
    successRecords = 0,
    errorRecords = 0,
    errors = [],
    importId = 0,
    fileName = "Database Import"
}>

<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Veritabanı İmport İşlemi</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
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
        .processing {
            text-align: center;
            padding: 40px;
        }
        .log-container {
            max-height: 400px;
            overflow-y: auto;
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 5px;
            padding: 15px;
        }
        .data-preview {
            max-height: 300px;
            overflow-y: auto;
            font-size: 12px;
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
                            <i class="fas fa-database me-2"></i>
                            Veritabanı Import İşlemi
                        </h4>
                    </div>
                    <div class="card-body">
                        
                        <cfif not form.confirmImport>
                            <!--- Step 1: Show data preview and confirmation --->
                            <div class="step-indicator">
                                <span class="step active">1</span>
                                <span>Veri Önizleme</span>
                                <i class="fas fa-arrow-right mx-3 text-muted"></i>
                                <span class="step">2</span>
                                <span>Veri İşle</span>
                                <i class="fas fa-arrow-right mx-3 text-muted"></i>
                                <span class="step">3</span>
                                <span>Etiket Yazdır</span>
                            </div>

                            <cftry>
                                <!--- Get data from database --->
                                <cfquery name="shipRowData" datasource="#variables.dsn#">
                                    SELECT 
                                        S.PRODUCT_CODE_2 as ETA_KODU,
                                        '' AS SERI_NO,
                                        GETDATE() AS URETIM_TARIHI,
                                        GETDATE() AS PAKET_TARIHI,
                                        S.BARCOD,
                                        SR.AMOUNT AS MIKTAR,
                                        '' AS MARKA,
                                        S.PRODUCT_NAME,
                                        SR.SHIP_ROW_ID
                                    FROM #variables.dsnShip#.SHIP_ROW AS SR 
                                    INNER JOIN #variables.dsnCompany#.STOCKS AS S ON S.STOCK_ID = SR.STOCK_ID
                                    WHERE SR.AMOUNT > 0
                                    AND S.PRODUCT_CODE_2 IS NOT NULL 
                                    AND S.PRODUCT_CODE_2 != ''
                                    AND SR.SHIP_ID=#attributes.SHIP_ID#
                                    ORDER BY S.PRODUCT_CODE_2
                                </cfquery><!----ok---->

                                <cfif shipRowData.recordCount gt 0>
                                    <div class="alert alert-info">
                                        <h5><i class="fas fa-info-circle me-2"></i>Veri Önizleme</h5>
                                        <p>Veritabanından <strong><cfoutput>#shipRowData.recordCount#</cfoutput></strong> kayıt bulundu.</p>
                                    </div>

                                    <!--- Data preview table --->
                                    <div class="data-preview">
                                        <table class="table table-bordered table-striped table-sm">
                                            <thead class="table-dark">
                                                <tr>
                                                    <th>ETA Kodu</th>
                                                    <th>Ürün Adı</th>
                                                    <th>Miktar</th>
                                                    <th>Barkod</th>
                                                    <th>Üretim Tarihi</th>
                                                    <th>Paket Tarihi</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <cfoutput query="shipRowData" maxrows="10">
                                                    <tr>
                                                        <td>#ETA_KODU#</td>
                                                        <td>#PRODUCT_NAME#</td>
                                                        <td>#MIKTAR#</td>
                                                        <td>#BARCOD#</td>
                                                        <td>#dateFormat(URETIM_TARIHI, "dd/mm/yyyy")#</td>
                                                        <td>#dateFormat(PAKET_TARIHI, "dd/mm/yyyy")#</td>
                                                    </tr>
                                                </cfoutput>
                                                <cfif shipRowData.recordCount gt 10>
                                                    <tr>
                                                        <td colspan="6" class="text-center text-muted">
                                                            <i>... ve <cfoutput>#shipRowData.recordCount - 10#</cfoutput> kayıt daha</i>
                                                        </td>
                                                    </tr>
                                                </cfif>
                                            </tbody>
                                        </table>
                                    </div>

                                    <!--- Import options and confirmation form --->
                                    <form method="post" action="">
                                        <div class="mt-4">
                                            <h6>İmport Seçenekleri:</h6>
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" id="clearTable" name="clearTable" value="true">
                                                <label class="form-check-label" for="clearTable">
                                                    Önceki geçici verileri temizle
                                                </label>
                                            </div>
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" id="validateData" name="validateData" value="true" checked>
                                                <label class="form-check-label" for="validateData">
                                                    Veri doğrulaması yap
                                                </label>
                                            </div>
                                        </div>

                                        <div class="d-grid gap-2 mt-4">
                                            <input type="hidden" name="confirmImport" value="true">
                                            <cfoutput><input type="hidden" name="SHIP_ID" value="#attributes.SHIP_ID#"></cfoutput>
                                            <button type="submit" class="btn btn-success btn-lg">
                                                <i class="fas fa-play me-2"></i>
                                                İmport İşlemini Başlat
                                            </button>
                                            <a href="index.cfm?fuseaction=objects.emptypopup_import_write_label" class="btn btn-outline-secondary">
                                                <i class="fas fa-arrow-left me-2"></i>
                                                Geri Dön
                                            </a>
                                        </div>
                                    </form>
                                <cfelse>
                                    <div class="alert alert-warning">
                                        <h5><i class="fas fa-exclamation-triangle me-2"></i>Veri Bulunamadı!</h5>
                                        <p>SHIP_ROW ve STOCKS tablolarında import edilebilir veri bulunamadı.</p>
                                    </div>
                                    <div class="d-grid">
                                        <a href="index.cfm?fuseaction=objects.emptypopup_import_write_label" class="btn btn-primary">
                                            <i class="fas fa-arrow-left me-2"></i>
                                            Geri Dön
                                        </a>
                                    </div>
                                </cfif>
                                
                                <cfcatch type="any">
                                    <div class="alert alert-danger">
                                        <h5><i class="fas fa-exclamation-triangle me-2"></i>Veri Okuma Hatası!</h5>
                                        <p><cfoutput>#cfcatch.message#</cfoutput></p>
                                    </div>
                                    <div class="d-grid">
                                        <a href="index.cfm?fuseaction=objects.emptypopup_import_write_label" class="btn btn-primary">
                                            <i class="fas fa-arrow-left me-2"></i>
                                            Geri Dön
                                        </a>
                                    </div>
                                </cfcatch>
                            </cftry>

                        <cfelse>
                            <!--- Step 2: Process the import --->
                            <div class="step-indicator">
                                <span class="step completed">1</span>
                                <span>Veri Önizleme</span>
                                <i class="fas fa-arrow-right mx-3 text-muted"></i>
                                <span class="step active">2</span>
                                <span>Veri İşle</span>
                                <i class="fas fa-arrow-right mx-3 text-muted"></i>
                                <span class="step">3</span>
                                <span>Etiket Yazdır</span>
                            </div>

                            <cftry>
                                <!--- Create Import Log Entry --->
                                <cfquery name="createImportLog" datasource="#variables.dsn#" result="logResult">
                                    INSERT INTO etiket_import_log (
                                        import_date,
                                        file_name,
                                        file_size,
                                        status
                                    ) VALUES (
                                        GETDATE(),
                                        <cfqueryparam value="Database Import - SHIP_ROW/STOCKS" cfsqltype="cf_sql_varchar">,
                                        <cfqueryparam value="0" cfsqltype="cf_sql_integer">,
                                        'PROCESSING'
                                    )
                                </cfquery><!----ok---->
                                
                                <cfset importResult.importId = logResult.generatedKey>

                                <!--- Clear existing temp data if requested --->
                                <cfif form.clearTable eq "true">
                                    <cfquery name="clearTempTable" datasource="#variables.dsn#">
                                        DELETE FROM etiket_temp_data WHERE import_id = <cfqueryparam value="#importResult.importId#" cfsqltype="cf_sql_integer">
                                    </cfquery>
                                </cfif><!----ok---->

                                <!--- Get data from database again for processing --->
                                <cfquery name="processData" datasource="#variables.dsn#">
                                    SELECT 
                                        S.PRODUCT_CODE_2 as ETA_KODU,
                                        '' AS SERI_NO,
                                        GETDATE() AS URETIM_TARIHI,
                                        GETDATE() AS PAKET_TARIHI,
                                        S.BARCOD,
                                        SR.AMOUNT AS MIKTAR,
                                        '' AS MARKA,
                                        S.PRODUCT_NAME,
                                        SR.SHIP_ROW_ID
                                    FROM #variables.dsnShip#.SHIP_ROW AS SR 
                                    INNER JOIN #variables.dsnCompany#.STOCKS AS S ON S.STOCK_ID = SR.STOCK_ID
                                    WHERE SR.AMOUNT > 0
                                    AND S.PRODUCT_CODE_2 IS NOT NULL 
                                    AND S.PRODUCT_CODE_2 != ''
                                    AND SR.SHIP_ID=#attributes.SHIP_ID#
                                    ORDER BY S.PRODUCT_CODE_2
                                </cfquery><!----ok---->

                                <div class="processing">
                                    <div class="spinner-border text-success mb-3" role="status">
                                        <span class="visually-hidden">İşleniyor...</span>
                                    </div>
                                    <h5>Veritabanı verisi işleniyor...</h5>
                                    <p class="text-muted">Lütfen bekleyiniz...</p>
                                </div>

                                <cfflush>

                                <cfset successCount = 0>
                                <cfset errorCount = 0>
                                <cfset currentRow = 0>

                                <!--- Process each row --->
                                <cfloop query="processData">
                                    <cfset currentRow = currentRow + 1>
                                    <cftry>
                                        <cfset etaKodu = trim(processData.ETA_KODU)>
                                        <cfset seriNo = trim(processData.SERI_NO)>
                                        <cfset uretimTarihi = processData.URETIM_TARIHI>
                                        <cfset paketTarihi = processData.PAKET_TARIHI>
                                        <cfset barkod = trim(processData.BARCOD)>
                                        <cfset miktar = processData.MIKTAR>
                                        <cfset marka = trim(processData.MARKA)>

                                        <!--- Validate data if requested --->
                                        <cfif form.validateData eq "true">
                                            <cfif len(etaKodu) eq 0>
                                                <cfthrow message="Satır #currentRow#: EtaKodu boş olamaz">
                                            </cfif>
                                            <cfif miktar lte 0>
                                                <cfthrow message="Satır #currentRow#: Miktar 0'dan büyük olmalıdır">
                                            </cfif>
                                        </cfif>

                                        <!--- Generate serial numbers if empty --->
                                        <cfif len(trim(seriNo)) eq 0 AND miktar gt 0>
                                            <cflog file="etiket_import" text="Row #currentRow#: SeriNo is empty, generating #miktar# serials for etaKodu: #etaKodu#">
                                            <cfset generatedSerials = generateSerialNumbers(etaKodu, miktar, importResult.importId)>
                                            <cflog file="etiket_import" text="Row #currentRow#: Generated serials: #arrayToList(generatedSerials)#">
                                            
                                            <!--- Insert multiple records for generated serials --->
                                            <cfloop array="#generatedSerials#" index="generatedSerial">
                                                <cfquery name="insertTempData" datasource="#variables.dsn#">
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
                                                        <cfqueryparam value="#importResult.importId#" cfsqltype="cf_sql_integer">,
                                                        <cfqueryparam value="#etaKodu#" cfsqltype="cf_sql_varchar">,
                                                        <cfqueryparam value="#generatedSerial#" cfsqltype="cf_sql_varchar">,
                                                        <cfqueryparam value="#uretimTarihi#" cfsqltype="cf_sql_timestamp">,
                                                        <cfqueryparam value="#paketTarihi#" cfsqltype="cf_sql_timestamp">,
                                                        <cfqueryparam value="#barkod#" cfsqltype="cf_sql_varchar">,
                                                        <cfqueryparam value="1" cfsqltype="cf_sql_decimal">,
                                                        <cfqueryparam value="#marka#" cfsqltype="cf_sql_varchar">,
                                                        <cfqueryparam value="#currentRow#" cfsqltype="cf_sql_integer">,
                                                        GETDATE()
                                                    )
                                                </cfquery><!----ok---->
                                                <cfset successCount = successCount + 1>
                                                <cflog file="etiket_import" text="Inserted record with serial: #generatedSerial# for import_id: #importResult.importId#">
                                            </cfloop>
                                        <cfelse>
                                            <!--- Normal single record insert --->
                                            <cfquery name="insertTempData" datasource="#variables.dsn#">
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
                                                    <cfqueryparam value="#importResult.importId#" cfsqltype="cf_sql_integer">,
                                                    <cfqueryparam value="#etaKodu#" cfsqltype="cf_sql_varchar">,
                                                    <cfqueryparam value="#seriNo#" cfsqltype="cf_sql_varchar">,
                                                    <cfqueryparam value="#uretimTarihi#" cfsqltype="cf_sql_timestamp">,
                                                    <cfqueryparam value="#paketTarihi#" cfsqltype="cf_sql_timestamp">,
                                                    <cfqueryparam value="#barkod#" cfsqltype="cf_sql_varchar">,
                                                    <cfqueryparam value="#miktar#" cfsqltype="cf_sql_decimal">,
                                                    <cfqueryparam value="#marka#" cfsqltype="cf_sql_varchar">,
                                                    <cfqueryparam value="#currentRow#" cfsqltype="cf_sql_integer">,
                                                    GETDATE()
                                                )
                                            </cfquery>
                                            <!----ok---->
                                            <cfset successCount = successCount + 1>
                                        </cfif>

                                        <cfcatch type="any">
                                            <cfset errorCount = errorCount + 1>
                                            <cfset arrayAppend(importResult.errors, "Satır #currentRow#: #cfcatch.message#")>
                                            <cflog file="etiket_import" text="Error processing row #currentRow#: #cfcatch.message#">
                                        </cfcatch>
                                    </cftry>
                                </cfloop>

                                <!--- Update results --->
                                <cfset importResult.totalRecords = processData.recordCount>
                                <cfset importResult.successRecords = successCount>
                                <cfset importResult.errorRecords = errorCount>
                                <cfset importResult.success = true>
                                <cfset importResult.message = "Veritabanı verisi başarıyla işlendi.">

                                <!--- Verify actual records in database --->
                                <cfquery name="verifyRecords" datasource="#variables.dsn#">
                                    SELECT COUNT(*) as actual_count
                                    FROM etiket_temp_data 
                                    WHERE import_id = <cfqueryparam value="#importResult.importId#" cfsqltype="cf_sql_integer">
                                </cfquery><!----ok---->
                                <cflog file="etiket_import" text="Actual records in database for import_id #importResult.importId#: #verifyRecords.actual_count#">

                                <!--- Update Import Log --->
                                <cfquery name="updateImportLog" datasource="#variables.dsn#">
                                    UPDATE etiket_import_log SET
                                        total_records = <cfqueryparam value="#importResult.totalRecords#" cfsqltype="cf_sql_integer">,
                                        success_records = <cfqueryparam value="#importResult.successRecords#" cfsqltype="cf_sql_integer">,
                                        error_records = <cfqueryparam value="#importResult.errorRecords#" cfsqltype="cf_sql_integer">,
                                        status = 'COMPLETED',
                                        completed_date = GETDATE()
                                    WHERE import_id = <cfqueryparam value="#importResult.importId#" cfsqltype="cf_sql_integer">
                                </cfquery><!----ok---->

                                <cfcatch type="any">
                                    <cfset importResult.success = false>
                                    <cfset importResult.message = "Hata: " & cfcatch.message>
                                    
                                    <!--- Update log with error --->
                                    <cfif importResult.importId gt 0>
                                        <cfquery name="updateErrorLog" datasource="#variables.dsn#">
                                            UPDATE etiket_import_log SET
                                                status = 'ERROR',
                                                error_message = <cfqueryparam value="#cfcatch.message#" cfsqltype="cf_sql_varchar">,
                                                completed_date = GETDATE()
                                            WHERE import_id = <cfqueryparam value="#importResult.importId#" cfsqltype="cf_sql_integer">
                                        </cfquery><!----ok---->
                                    </cfif>
                                </cfcatch>
                            </cftry>

                            <!--- Display Results --->
                            <div class="row">
                                <div class="col-md-8">
                                    <cfif importResult.success>
                                       <cfoutput>
                                        <div class="alert alert-success">
                                            <h5><i class="fas fa-check-circle me-2"></i>İşlem Başarılı!</h5>
                                            <p>#importResult.message#</p>
                                            <hr>
                                            <div class="row text-center">
                                                <div class="col-md-3">
                                                    <h3 class="text-primary">#importResult.totalRecords#</h3>
                                                    <small>Toplam Satır</small>
                                                </div>
                                                <div class="col-md-3">
                                                    <h3 class="text-info">#verifyRecords.actual_count#</h3>
                                                    <small>Oluşturulan Etiket</small>
                                                </div>
                                                <div class="col-md-3">
                                                    <h3 class="text-success">#importResult.successRecords#</h3>
                                                    <small>Başarılı İşlem</small>
                                                </div>
                                                <div class="col-md-3">
                                                    <h3 class="text-danger">#importResult.errorRecords#</h3>
                                                    <small>Hatalı</small>
                                                </div>
                                            </div>
                                        </div></cfoutput>
                                        
                                        <div class="d-grid gap-2">
                                           <cfoutput> <a href="index.cfm?fuseaction=objects.emptypopup_view_labels&import_id=#importResult.importId#" class="btn btn-success btn-lg">
                                                <i class="fas fa-print me-2"></i>
                                                Etiketleri Görüntüle ve Yazdır
                                            </a>
                                            </cfoutput>
                                            <a href="index.cfm?fuseaction=objects.emptypopup_import_write_label" class="btn btn-outline-primary">
                                                <i class="fas fa-upload me-2"></i>
                                                Yeni Import
                                            </a>
                                        </div>
                                    <cfelse>
                                        <div class="alert alert-danger">
                                            <h5><i class="fas fa-exclamation-triangle me-2"></i>İşlem Başarısız!</h5>
                                            <p><cfoutput>#importResult.message#</cfoutput></p>
                                        </div>
                                        
                                        <div class="d-grid">
                                            <a href="index.cfm?fuseaction=objects.emptypopup_import_write_label" class="btn btn-primary">
                                                <i class="fas fa-arrow-left me-2"></i>
                                                Geri Dön
                                            </a>
                                        </div>
                                    </cfif>
                                </div>
                                
                                <div class="col-md-4">
                                    <cfif arrayLen(importResult.errors) gt 0>
                                        <h6>Hatalar:</h6>
                                        <div class="log-container">
                                            <cfoutput><cfloop array="#importResult.errors#" index="error">
                                                <div class="text-danger small">#error#</div>
                                            </cfloop></cfoutput>
                                        </div>
                                    </cfif>
                                </div>
                            </div>
                        </cfif>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>