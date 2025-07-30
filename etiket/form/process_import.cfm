<!--- Excel Import Processing Page --->
<cfparam name="form.clearTable" default="false">
<cfparam name="form.validateData" default="false">

<!--- Upload Path Configuration --->
<cfset uploadPath = "c:\temp\excel_imports\">
<cfset maxFileSize = 10 * 1024 * 1024> <!--- 10MB --->

<!--- Create upload directory if it doesn't exist --->
<cfif not directoryExists(uploadPath)>
    <cfdirectory action="create" directory="#uploadPath#">
</cfif>

<!--- Initialize Variables --->
<cfset importResult = {
    success = false,
    message = "",
    totalRecords = 0,
    successRecords = 0,
    errorRecords = 0,
    errors = [],
    importId = 0,
    fileName = ""
}>

<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Excel İmport İşlemi</title>
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
    </style>
</head>
<body>
    <div class="container mt-4">
        <div class="row justify-content-center">
            <div class="col-md-10">
                <div class="card shadow">
                    <div class="card-header bg-primary text-white">
                        <h4 class="mb-0">
                            <i class="fas fa-cogs me-2"></i>
                            Excel Import İşlemi
                        </h4>
                    </div>
                    <div class="card-body">
                        <!-- Adım Göstergesi -->
                        <div class="step-indicator">
                            <span class="step completed">1</span>
                            <span>Dosya Yükle</span>
                            <i class="fas fa-arrow-right mx-3 text-muted"></i>
                            <span class="step active">2</span>
                            <span>Veri İşle</span>
                            <i class="fas fa-arrow-right mx-3 text-muted"></i>
                            <span class="step">3</span>
                            <span>Etiket Yazdır</span>
                        </div>

                        <cfif structKeyExists(form, "excelFile") and len(trim(form.excelFile))>
                            <cftry>
                                <!--- File Upload --->
                                <cffile action="upload" 
                                        filefield="excelFile" 
                                        destination="#uploadPath#" 
                                        nameconflict="makeunique"
                                        accept="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,application/vnd.ms-excel">
                                
                                <cfset uploadedFile = cffile.serverFile>
                                <cfset importResult.fileName = cffile.clientFile>
                                
                                <!--- Validate File Size --->
                                <cfif cffile.fileSize gt maxFileSize>
                                    <cfthrow message="Dosya boyutu çok büyük. Maksimum 10MB olmalıdır.">
                                </cfif>

                                <!--- Create Import Log Entry --->
                                <cfquery name="createImportLog" datasource="w3Qa" result="logResult">
                                    INSERT INTO etiket_import_log (
                                        import_date,
                                        file_name,
                                        file_size,
                                        status
                                    ) VALUES (
                                        GETDATE(),
                                        <cfqueryparam value="#importResult.fileName#" cfsqltype="cf_sql_varchar">,
                                        <cfqueryparam value="#cffile.fileSize#" cfsqltype="cf_sql_integer">,
                                        'PROCESSING'
                                    )
                                </cfquery>
                                
                                <cfset importResult.importId = logResult.generatedKey>

                                <!--- Clear existing temp data if requested --->
                                <cfif form.clearTable eq "true">
                                    <cfquery name="clearTempTable" datasource="w3Qa">
                                        DELETE FROM etiket_temp_data WHERE import_id = <cfqueryparam value="#importResult.importId#" cfsqltype="cf_sql_integer">
                                    </cfquery>
                                </cfif>

                                <!--- Read Excel File using Apache POI (Java) --->
                                <cfset excelFilePath = uploadPath & uploadedFile>
                                
                                <!--- Create Excel reader using Java --->
                                <cfscript>
                                    // Java imports
                                    FileInputStream = createObject("java", "java.io.FileInputStream");
                                    XSSFWorkbook = createObject("java", "org.apache.poi.xssf.usermodel.XSSFWorkbook");
                                    HSSFWorkbook = createObject("java", "org.apache.poi.hssf.usermodel.HSSFWorkbook");
                                    DateUtil = createObject("java", "org.apache.poi.ss.usermodel.DateUtil");
                                    
                                    // Open file
                                    fileStream = FileInputStream.init(excelFilePath);
                                    
                                    // Determine workbook type
                                    if (findNoCase(".xlsx", uploadedFile)) {
                                        workbook = XSSFWorkbook.init(fileStream);
                                    } else {
                                        workbook = HSSFWorkbook.init(fileStream);
                                    }
                                    
                                    // Get first sheet
                                    sheet = workbook.getSheetAt(0);
                                    
                                    // Get header row
                                    headerRow = sheet.getRow(0);
                                    if (isNull(headerRow)) {
                                        throw("Excel dosyasında başlık satırı bulunamadı.");
                                    }
                                    
                                    // Map column indices
                                    columnMap = {};
                                    requiredColumns = ["EtaKodu", "SeriNo", "Üretim Tarihi", "Paket Tarihi", "Barkod", "Miktar", "Marka"];
                                    
                                    for (i = 0; i < headerRow.getLastCellNum(); i++) {
                                        cell = headerRow.getCell(i);
                                        if (!isNull(cell)) {
                                            cellValue = trim(cell.toString());
                                            columnMap[cellValue] = i;
                                        }
                                    }
                                    
                                    // Validate required columns exist
                                    missingColumns = [];
                                    for (col in requiredColumns) {
                                        if (!structKeyExists(columnMap, col)) {
                                            arrayAppend(missingColumns, col);
                                        }
                                    }
                                    
                                    if (arrayLen(missingColumns) > 0) {
                                        throw("Gerekli sütunlar bulunamadı: " & arrayToList(missingColumns, ", "));
                                    }
                                </cfscript>

                                <!--- Process Data Rows --->
                                <div class="processing">
                                    <div class="spinner-border text-primary mb-3" role="status">
                                        <span class="visually-hidden">İşleniyor...</span>
                                    </div>
                                    <h5>Excel verisi işleniyor...</h5>
                                    <p class="text-muted">Lütfen bekleyiniz...</p>
                                </div>

                                <cfflush>

                                <cfscript>
                                    // Process each data row
                                    totalRows = sheet.getLastRowNum();
                                    processedRows = 0;
                                    errorRows = 0;
                                    errorMessages = [];
                                    
                                    for (rowIndex = 1; rowIndex <= totalRows; rowIndex++) {
                                        try {
                                            row = sheet.getRow(rowIndex);
                                            if (isNull(row)) continue;
                                            
                                            // Extract data from each column
                                            etaKodu = "";
                                            seriNo = "";
                                            uretimTarihi = "";
                                            paketTarihi = "";
                                            barkod = "";
                                            miktar = 0;
                                            marka = "";
                                            
                                            // EtaKodu
                                            if (structKeyExists(columnMap, "EtaKodu")) {
                                                cell = row.getCell(columnMap["EtaKodu"]);
                                                if (!isNull(cell)) {
                                                    etaKodu = trim(cell.toString());
                                                }
                                            }
                                            
                                            // SeriNo
                                            if (structKeyExists(columnMap, "SeriNo")) {
                                                cell = row.getCell(columnMap["SeriNo"]);
                                                if (!isNull(cell)) {
                                                    seriNo = trim(cell.toString());
                                                }
                                            }
                                            
                                            // Üretim Tarihi
                                            if (structKeyExists(columnMap, "Üretim Tarihi")) {
                                                cell = row.getCell(columnMap["Üretim Tarihi"]);
                                                if (!isNull(cell)) {
                                                    if (DateUtil.isCellDateFormatted(cell)) {
                                                        uretimTarihi = dateFormat(cell.getDateCellValue(), "yyyy-mm-dd");
                                                    } else {
                                                        uretimTarihi = trim(cell.toString());
                                                    }
                                                }
                                            }
                                            
                                            // Paket Tarihi
                                            if (structKeyExists(columnMap, "Paket Tarihi")) {
                                                cell = row.getCell(columnMap["Paket Tarihi"]);
                                                if (!isNull(cell)) {
                                                    if (DateUtil.isCellDateFormatted(cell)) {
                                                        paketTarihi = dateFormat(cell.getDateCellValue(), "yyyy-mm-dd");
                                                    } else {
                                                        paketTarihi = trim(cell.toString());
                                                    }
                                                }
                                            }
                                            
                                            // Barkod
                                            if (structKeyExists(columnMap, "Barkod")) {
                                                cell = row.getCell(columnMap["Barkod"]);
                                                if (!isNull(cell)) {
                                                    barkod = trim(cell.toString());
                                                }
                                            }
                                            
                                            // Miktar
                                            if (structKeyExists(columnMap, "Miktar")) {
                                                cell = row.getCell(columnMap["Miktar"]);
                                                if (!isNull(cell)) {
                                                    miktar = val(cell.toString());
                                                }
                                            }
                                            
                                            // Marka
                                            if (structKeyExists(columnMap, "Marka")) {
                                                cell = row.getCell(columnMap["Marka"]);
                                                if (!isNull(cell)) {
                                                    marka = trim(cell.toString());
                                                }
                                            }
                                            
                                            // Validate data if requested
                                            if (form.validateData eq "true") {
                                                if (len(etaKodu) == 0) {
                                                    throw("Satır " & (rowIndex + 1) & ": EtaKodu boş olamaz");
                                                }
                                                if (len(seriNo) == 0) {
                                                    throw("Satır " & (rowIndex + 1) & ": SeriNo boş olamaz");
                                                }
                                                if (miktar <= 0) {
                                                    throw("Satır " & (rowIndex + 1) & ": Miktar 0'dan büyük olmalıdır");
                                                }
                                            }
                                            
                                            // Insert into temp table (use cfquery within cfscript)
                                        } catch (any e) {
                                            errorRows++;
                                            arrayAppend(errorMessages, e.message);
                                            continue;
                                        }
                                    }
                                    
                                    // Close workbook and stream
                                    workbook.close();
                                    fileStream.close();
                                </cfscript>

                                <!--- Now insert valid records using cfquery --->
                                <cfscript>
                                    // Re-process to insert data (since cfquery can't be used inside cfscript loop easily)
                                    FileInputStream2 = createObject("java", "java.io.FileInputStream");
                                    fileStream2 = FileInputStream2.init(excelFilePath);
                                    
                                    if (findNoCase(".xlsx", uploadedFile)) {
                                        workbook2 = XSSFWorkbook.init(fileStream2);
                                    } else {
                                        workbook2 = HSSFWorkbook.init(fileStream2);
                                    }
                                    
                                    sheet2 = workbook2.getSheetAt(0);
                                    successCount = 0;
                                </cfscript>

                                <cfloop from="1" to="#sheet2.getLastRowNum()#" index="rowIndex">
                                    <cftry>
                                        <cfset row = sheet2.getRow(rowIndex)>
                                        <cfif not isNull(row)>
                                            <!--- Extract data --->
                                            <cfset etaKodu = "">
                                            <cfset seriNo = "">
                                            <cfset uretimTarihi = "">
                                            <cfset paketTarihi = "">
                                            <cfset barkod = "">
                                            <cfset miktar = 0>
                                            <cfset marka = "">
                                            
                                            <!--- EtaKodu --->
                                            <cfset cell = row.getCell(columnMap["EtaKodu"])>
                                            <cfif not isNull(cell)>
                                                <cfset etaKodu = trim(cell.toString())>
                                            </cfif>
                                            
                                            <!--- SeriNo --->
                                            <cfset cell = row.getCell(columnMap["SeriNo"])>
                                            <cfif not isNull(cell)>
                                                <cfset seriNo = trim(cell.toString())>
                                            </cfif>
                                            
                                            <!--- Üretim Tarihi --->
                                            <cfset cell = row.getCell(columnMap["Üretim Tarihi"])>
                                            <cfif not isNull(cell)>
                                                <cfif DateUtil.isCellDateFormatted(cell)>
                                                    <cfset uretimTarihi = cell.getDateCellValue()>
                                                <cfelse>
                                                    <cfset uretimTarihi = trim(cell.toString())>
                                                    <cfif isDate(uretimTarihi)>
                                                        <cfset uretimTarihi = parseDateTime(uretimTarihi)>
                                                    <cfelse>
                                                        <cfset uretimTarihi = "">
                                                    </cfif>
                                                </cfif>
                                            </cfif>
                                            
                                            <!--- Paket Tarihi --->
                                            <cfset cell = row.getCell(columnMap["Paket Tarihi"])>
                                            <cfif not isNull(cell)>
                                                <cfif DateUtil.isCellDateFormatted(cell)>
                                                    <cfset paketTarihi = cell.getDateCellValue()>
                                                <cfelse>
                                                    <cfset paketTarihi = trim(cell.toString())>
                                                    <cfif isDate(paketTarihi)>
                                                        <cfset paketTarihi = parseDateTime(paketTarihi)>
                                                    <cfelse>
                                                        <cfset paketTarihi = "">
                                                    </cfif>
                                                </cfif>
                                            </cfif>
                                            
                                            <!--- Barkod --->
                                            <cfset cell = row.getCell(columnMap["Barkod"])>
                                            <cfif not isNull(cell)>
                                                <cfset barkod = trim(cell.toString())>
                                            </cfif>
                                            
                                            <!--- Miktar --->
                                            <cfset cell = row.getCell(columnMap["Miktar"])>
                                            <cfif not isNull(cell)>
                                                <cfset miktar = val(cell.toString())>
                                            </cfif>
                                            
                                            <!--- Marka --->
                                            <cfset cell = row.getCell(columnMap["Marka"])>
                                            <cfif not isNull(cell)>
                                                <cfset marka = trim(cell.toString())>
                                            </cfif>
                                            
                                            <!--- Validate and Insert --->
                                            <cfif (form.validateData eq "false") OR 
                                                  (len(etaKodu) gt 0 AND len(seriNo) gt 0 AND miktar gt 0)>
                                                
                                                <cfquery name="insertTempData" datasource="w3Qa">
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
                                                        <cfif isDate(uretimTarihi)>
                                                            <cfqueryparam value="#uretimTarihi#" cfsqltype="cf_sql_timestamp">
                                                        <cfelse>
                                                            NULL
                                                        </cfif>,
                                                        <cfif isDate(paketTarihi)>
                                                            <cfqueryparam value="#paketTarihi#" cfsqltype="cf_sql_timestamp">
                                                        <cfelse>
                                                            NULL
                                                        </cfif>,
                                                        <cfqueryparam value="#barkod#" cfsqltype="cf_sql_varchar">,
                                                        <cfqueryparam value="#miktar#" cfsqltype="cf_sql_decimal">,
                                                        <cfqueryparam value="#marka#" cfsqltype="cf_sql_varchar">,
                                                        <cfqueryparam value="#rowIndex + 1#" cfsqltype="cf_sql_integer">,
                                                        GETDATE()
                                                    )
                                                </cfquery>
                                                
                                                <cfset successCount = successCount + 1>
                                            </cfif>
                                        </cfif>
                                        
                                        <cfcatch type="any">
                                            <cfset errorRows = errorRows + 1>
                                            <cfset arrayAppend(importResult.errors, "Satır #rowIndex + 1#: #cfcatch.message#")>
                                        </cfcatch>
                                    </cftry>
                                </cfloop>

                                <cfscript>
                                    workbook2.close();
                                    fileStream2.close();
                                    
                                    // Update results
                                    importResult.totalRecords = sheet2.getLastRowNum();
                                    importResult.successRecords = successCount;
                                    importResult.errorRecords = errorRows;
                                    importResult.success = true;
                                    importResult.message = "Excel dosyası başarıyla işlendi.";
                                </cfscript>

                                <!--- Update Import Log --->
                                <cfquery name="updateImportLog" datasource="w3Qa">
                                    UPDATE etiket_import_log SET
                                        total_records = <cfqueryparam value="#importResult.totalRecords#" cfsqltype="cf_sql_integer">,
                                        success_records = <cfqueryparam value="#importResult.successRecords#" cfsqltype="cf_sql_integer">,
                                        error_records = <cfqueryparam value="#importResult.errorRecords#" cfsqltype="cf_sql_integer">,
                                        status = 'COMPLETED',
                                        completed_date = GETDATE()
                                    WHERE import_id = <cfqueryparam value="#importResult.importId#" cfsqltype="cf_sql_integer">
                                </cfquery>

                                <!--- Clean up uploaded file --->
                                <cffile action="delete" file="#excelFilePath#">

                                <cfcatch type="any">
                                    <cfset importResult.success = false>
                                    <cfset importResult.message = "Hata: " & cfcatch.message>
                                    
                                    <!--- Update log with error --->
                                    <cfif importResult.importId gt 0>
                                        <cfquery name="updateErrorLog" datasource="w3Qa">
                                            UPDATE etiket_import_log SET
                                                status = 'ERROR',
                                                error_message = <cfqueryparam value="#cfcatch.message#" cfsqltype="cf_sql_varchar">,
                                                completed_date = GETDATE()
                                            WHERE import_id = <cfqueryparam value="#importResult.importId#" cfsqltype="cf_sql_integer">
                                        </cfquery>
                                    </cfif>
                                </cfcatch>
                            </cftry>

                            <!--- Display Results --->
                            <div class="row">
                                <div class="col-md-8">
                                    <cfif importResult.success>
                                        <div class="alert alert-success">
                                            <h5><i class="fas fa-check-circle me-2"></i>İşlem Başarılı!</h5>
                                            <p>#importResult.message#</p>
                                            <hr>
                                            <div class="row text-center">
                                                <div class="col-md-4">
                                                    <h3 class="text-primary">#importResult.totalRecords#</h3>
                                                    <small>Toplam Satır</small>
                                                </div>
                                                <div class="col-md-4">
                                                    <h3 class="text-success">#importResult.successRecords#</h3>
                                                    <small>Başarılı</small>
                                                </div>
                                                <div class="col-md-4">
                                                    <h3 class="text-danger">#importResult.errorRecords#</h3>
                                                    <small>Hatalı</small>
                                                </div>
                                            </div>
                                        </div>
                                        
                                        <div class="d-grid gap-2">
                                            <a href="view_labels.cfm?import_id=#importResult.importId#" class="btn btn-success btn-lg">
                                                <i class="fas fa-print me-2"></i>
                                                Etiketleri Görüntüle ve Yazdır
                                            </a>
                                            <a href="import_etiket.cfm" class="btn btn-outline-primary">
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
                                            <a href="import_etiket.cfm" class="btn btn-primary">
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
                                            <cfloop array="#importResult.errors#" index="error">
                                                <div class="text-danger small">#error#</div>
                                            </cfloop>
                                        </div>
                                    </cfif>
                                </div>
                            </div>

                        <cfelse>
                            <div class="alert alert-warning">
                                <h5><i class="fas fa-exclamation-triangle me-2"></i>Dosya Seçilmedi!</h5>
                                <p>Lütfen bir Excel dosyası seçin.</p>
                            </div>
                            
                            <div class="d-grid">
                                <a href="import_etiket.cfm" class="btn btn-primary">
                                    <i class="fas fa-arrow-left me-2"></i>
                                    Geri Dön
                                </a>
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
