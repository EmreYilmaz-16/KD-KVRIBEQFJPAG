<!--- Apache POI ile Gerçek Excel Dosyası Oluşturucu --->
<cfparam name="url.action" default="">
<cfparam name="url.recordCount" default="10">
<cfparam name="url.includeFormulas" default="false">
<cfparam name="url.includeCharts" default="false">

<!--- Excel dosyası oluştur (Apache POI ile) --->
<cfif url.action eq "create_xlsx">
    <cftry>
        <!--- Apache POI kullanarak Excel dosyası oluştur --->
        <cfscript>
            // Java imports
            XSSFWorkbook = createObject("java", "org.apache.poi.xssf.usermodel.XSSFWorkbook");
            XSSFSheet = createObject("java", "org.apache.poi.xssf.usermodel.XSSFSheet");
            XSSFRow = createObject("java", "org.apache.poi.xssf.usermodel.XSSFRow");
            XSSFCell = createObject("java", "org.apache.poi.xssf.usermodel.XSSFCell");
            XSSFCellStyle = createObject("java", "org.apache.poi.xssf.usermodel.XSSFCellStyle");
            XSSFFont = createObject("java", "org.apache.poi.xssf.usermodel.XSSFFont");
            IndexedColors = createObject("java", "org.apache.poi.ss.usermodel.IndexedColors");
            CellType = createObject("java", "org.apache.poi.ss.usermodel.CellType");
            FillPatternType = createObject("java", "org.apache.poi.ss.usermodel.FillPatternType");
            BorderStyle = createObject("java", "org.apache.poi.ss.usermodel.BorderStyle");
            
            // Workbook oluştur
            workbook = XSSFWorkbook.init();
            sheet = workbook.createSheet("Etiket Verileri");
            
            // Başlık için stil oluştur
            headerStyle = workbook.createCellStyle();
            headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerFont.setFontHeightInPoints(12);
            headerFont.setColor(IndexedColors.WHITE.getIndex());
            headerStyle.setFont(headerFont);
            headerStyle.setFillForegroundColor(IndexedColors.DARK_BLUE.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setBorderBottom(BorderStyle.THIN);
            headerStyle.setBorderTop(BorderStyle.THIN);
            headerStyle.setBorderRight(BorderStyle.THIN);
            headerStyle.setBorderLeft(BorderStyle.THIN);
            
            // Veri için stil oluştur
            dataStyle = workbook.createCellStyle();
            dataStyle.setBorderBottom(BorderStyle.THIN);
            dataStyle.setBorderTop(BorderStyle.THIN);
            dataStyle.setBorderRight(BorderStyle.THIN);
            dataStyle.setBorderLeft(BorderStyle.THIN);
            
            // Tarih için stil oluştur
            dateStyle = workbook.createCellStyle();
            dateStyle.setBorderBottom(BorderStyle.THIN);
            dateStyle.setBorderTop(BorderStyle.THIN);
            dateStyle.setBorderRight(BorderStyle.THIN);
            dateStyle.setBorderLeft(BorderStyle.THIN);
            
            // Sayı için stil oluştur
            numberStyle = workbook.createCellStyle();
            numberStyle.setBorderBottom(BorderStyle.THIN);
            numberStyle.setBorderTop(BorderStyle.THIN);
            numberStyle.setBorderRight(BorderStyle.THIN);
            numberStyle.setBorderLeft(BorderStyle.THIN);
            
            // Başlık satırı oluştur
            headerRow = sheet.createRow(0);
            headers = ["EtaKodu", "SeriNo", "Üretim Tarihi", "Paket Tarihi", "Barkod", "Miktar", "Marka"];
            
            for (i = 0; i < arrayLen(headers); i++) {
                cell = headerRow.createCell(i);
                cell.setCellValue(headers[i + 1]);
                cell.setCellStyle(headerStyle);
            }
            
            // Örnek veriler
            markalar = ["ABC Elektronik", "XYZ Teknoloji", "DEF Endüstri", "GHI Makine", "JKL Otomotiv", "MNO Plastik", "PQR Tekstil", "STU Gıda", "VWX Kimya", "YZA Metal"];
            etiketPrefixes = ["ETA", "PRD", "ITM", "SKU", "REF"];
            
            // Veri satırları oluştur
            for (rowNum = 1; rowNum <= url.recordCount; rowNum++) {
                row = sheet.createRow(rowNum);
                
                randomMarka = markalar[randRange(1, arrayLen(markalar))];
                randomPrefix = etiketPrefixes[randRange(1, arrayLen(etiketPrefixes))];
                
                // EtaKodu
                cell = row.createCell(0);
                cell.setCellValue(randomPrefix & numberFormat(rowNum, "000"));
                cell.setCellStyle(dataStyle);
                
                // SeriNo
                cell = row.createCell(1);
                cell.setCellValue("SN" & dateFormat(now(), "yyyy") & numberFormat(rowNum, "00000"));
                cell.setCellStyle(dataStyle);
                
                // Üretim Tarihi
                cell = row.createCell(2);
                uretimTarihi = dateAdd("d", -randRange(1, 90), now());
                cell.setCellValue(dateFormat(uretimTarihi, "dd.mm.yyyy"));
                cell.setCellStyle(dateStyle);
                
                // Paket Tarihi
                cell = row.createCell(3);
                paketTarihi = dateAdd("d", randRange(1, 10), uretimTarihi);
                cell.setCellValue(dateFormat(paketTarihi, "dd.mm.yyyy"));
                cell.setCellStyle(dateStyle);
                
                // Barkod
                cell = row.createCell(4);
                cell.setCellValue("86" & randRange(10000, 99999) & randRange(10000, 99999));
                cell.setCellStyle(dataStyle);
                
                // Miktar
                cell = row.createCell(5);
                miktar = randRange(1, 1000) + (randRange(0, 99) / 100);
                cell.setCellValue(miktar);
                cell.setCellStyle(numberStyle);
                
                // Marka
                cell = row.createCell(6);
                cell.setCellValue(randomMarka);
                cell.setCellStyle(dataStyle);
            }
            
            // Sütun genişliklerini ayarla
            for (i = 0; i < arrayLen(headers); i++) {
                sheet.autoSizeColumn(i);
                // Minimum genişlik ayarla
                currentWidth = sheet.getColumnWidth(i);
                if (currentWidth < 3000) {
                    sheet.setColumnWidth(i, 3000);
                }
            }
            
            // Eğer formül eklemek isteniyorsa
            if (url.includeFormulas eq "true") {
                // Toplam satırı ekle
                totalRow = sheet.createRow(url.recordCount + 2);
                
                // "TOPLAM" etiketi
                cell = totalRow.createCell(4);
                cell.setCellValue("TOPLAM:");
                cell.setCellStyle(headerStyle);
                
                // Toplam miktar formülü
                cell = totalRow.createCell(5);
                cell.setCellFormula("SUM(F2:F" & (url.recordCount + 1) & ")");
                cell.setCellStyle(numberStyle);
            }
            
            // Freeze panes (başlık satırını sabitle)
            sheet.createFreezePane(0, 1);
            
            // Dosya adı oluştur
            fileName = "etiket_ornek_" & dateFormat(now(), "yyyymmdd") & "_" & timeFormat(now(), "HHmmss") & ".xlsx";
            
            // Temp dosya yolu
            tempDir = "c:\temp\excel_exports\";
            if (!directoryExists(tempDir)) {
                directoryCreate(tempDir);
            }
            
            tempFilePath = tempDir & fileName;
            
            // Dosyayı kaydet
            FileOutputStream = createObject("java", "java.io.FileOutputStream");
            fos = FileOutputStream.init(tempFilePath);
            workbook.write(fos);
            fos.close();
            workbook.close();
        </cfscript>
        
        <!--- Dosyayı kullanıcıya gönder --->
        <cfheader name="Content-Disposition" value="attachment; filename=#fileName#">
        <cfheader name="Content-Type" value="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet">
        <cfcontent type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" file="#tempFilePath#" deletefile="true">
        
        <cfcatch>
            <cfset errorMessage = "Excel dosyası oluşturulamadı: " & cfcatch.message>
            <cfset showErrorOnPage = true>
        </cfcatch>
    </cftry>
</cfif>

<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gelişmiş Excel Oluşturucu</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .excel-preview {
            border: 2px solid #28a745;
            border-radius: 10px;
            padding: 20px;
            background: linear-gradient(135deg, #d4edda 0%, #c3e6cb 100%);
        }
        .feature-card {
            transition: all 0.3s ease;
        }
        .feature-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
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
                            <i class="fas fa-file-excel me-2"></i>
                            Gelişmiş Excel Dosya Oluşturucu
                        </h4>
                        <small>Apache POI ile profesyonel Excel dosyaları</small>
                    </div>
                    <div class="card-body">
                        
                        <!--- Hata mesajı --->
                        <cfif structKeyExists(variables, "showErrorOnPage") AND showErrorOnPage>
                            <div class="alert alert-danger">
                                <h6><i class="fas fa-exclamation-triangle me-2"></i>Hata!</h6>
                                <p>#errorMessage#</p>
                                <small>Apache POI kütüphanelerinin yüklü olduğundan emin olun.</small>
                            </div>
                        </cfif>

                        <!--- Navigasyon --->
                        <div class="mb-4">
                            <a href="index.cfm?fuseaction=objects.emptypopup_create_sample_excel_etiket" class="btn btn-outline-success me-2">
                                <i class="fas fa-file-csv me-2"></i>Basit CSV
                            </a>
                            <a href="index.cfm?fuseaction=objects.emptypopup_import_write_label" class="btn btn-outline-primary me-2">
                                <i class="fas fa-upload me-2"></i>Excel Import
                            </a>
                          
                        </div>

                        <!--- Ana Excel oluşturma formu --->
                        <div class="excel-preview">
                            <h5 class="text-success mb-3">
                                <i class="fas fa-magic me-2"></i>
                                Profesyonel Excel Dosyası Oluştur
                            </h5>

                            <cfform action="#request.self#?fuseaction=#attributes.fuseaction#&action=create_xlsx" class="row g-3">
                                <input type="hidden" name="action" value="create_xlsx">
                                
                                <div class="col-md-3">
                                    <label for="recordCount" class="form-label">Kayıt Sayısı:</label>
                                    <select name="recordCount" id="recordCount" class="form-select">
                                        <option value="5">5 Kayıt</option>
                                        <option value="10" selected>10 Kayıt</option>
                                        <option value="25">25 Kayıt</option>
                                        <option value="50">50 Kayıt</option>
                                        <option value="100">100 Kayıt</option>
                                        <option value="250">250 Kayıt</option>
                                        <option value="500">500 Kayıt</option>
                                        <option value="1000">1000 Kayıt</option>
                                    </select>
                                </div>
                                
                                <div class="col-md-3">
                                    <label class="form-label">Özellikler:</label>
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox" name="includeFormulas" value="true" id="formulas">
                                        <label class="form-check-label" for="formulas">
                                            Formüller ekle
                                        </label>
                                    </div>
                                </div>
                                
                                <div class="col-md-6 d-flex align-items-end">
                                    <button type="submit" class="btn btn-success btn-lg w-100">
                                        <i class="fas fa-download me-2"></i>
                                        XLSX Dosyası Oluştur ve İndir
                                    </button>
                                </div>
                            </cfform>
                            
                            <div class="mt-3">
                                <small class="text-success">
                                    <i class="fas fa-check me-1"></i>
                                    Bu versiyon gerçek Excel (.xlsx) dosyası oluşturur ve formatlamalar içerir.
                                </small>
                            </div>
                        </div>

                        <!--- Özellikler --->
                        <div class="mt-5">
                            <h6>Excel Dosyası Özellikleri:</h6>
                            <div class="row">
                                <div class="col-md-4">
                                    <div class="card feature-card h-100">
                                        <div class="card-body text-center">
                                            <i class="fas fa-palette fa-2x text-primary mb-3"></i>
                                            <h6>Profesyonel Formatlar</h6>
                                            <p class="small text-muted">Renkli başlıklar, kenarlıklar ve hücre formatları</p>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="col-md-4">
                                    <div class="card feature-card h-100">
                                        <div class="card-body text-center">
                                            <i class="fas fa-calculator fa-2x text-success mb-3"></i>
                                            <h6>Formüller</h6>
                                            <p class="small text-muted">Otomatik toplam ve hesaplamalar</p>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="col-md-4">
                                    <div class="card feature-card h-100">
                                        <div class="card-body text-center">
                                            <i class="fas fa-lock fa-2x text-warning mb-3"></i>
                                            <h6>Sabitleme</h6>
                                            <p class="small text-muted">Başlık satırı sabitlenir</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!--- Excel POI Test --->
                        <div class="mt-4">
                            <div class="card border-info">
                                <div class="card-header bg-info text-white">
                                    <h6 class="mb-0">
                                        <i class="fas fa-vial me-2"></i>
                                        Apache POI Test
                                    </h6>
                                </div>
                                <div class="card-body">
                                    <cftry>
                                        <cfset XSSFWorkbook = createObject("java", "org.apache.poi.xssf.usermodel.XSSFWorkbook")>
                                        <div class="alert alert-success mb-0">
                                            <i class="fas fa-check-circle me-2"></i>
                                            <strong>Apache POI başarıyla yüklendi!</strong>
                                            <br><small>Gerçek Excel dosyaları oluşturabilirsiniz.</small>
                                        </div>
                                        <cfcatch>
                                            <div class="alert alert-warning mb-0">
                                                <i class="fas fa-exclamation-triangle me-2"></i>
                                                <strong>Apache POI yüklü değil!</strong>
                                                <br><small>Lütfen kurulum kılavuzunu takip edin: <a href="setup_help.cfm">Kurulum Yardımı</a></small>
                                                <br><small>Alternatif olarak <a href="create_sample_excel.cfm">CSV versiyonunu</a> kullanabilirsiniz.</small>
                                            </div>
                                        </cfcatch>
                                    </cftry>
                                </div>
                            </div>
                        </div>

                        <!--- Karşılaştırma tablosu --->
                        <div class="mt-4">
                            <h6>Dosya Format Karşılaştırması:</h6>
                            <div class="table-responsive">
                                <table class="table table-sm">
                                    <thead class="table-dark">
                                        <tr>
                                            <th>Özellik</th>
                                            <th>CSV (Basit)</th>
                                            <th>XLSX (Gelişmiş)</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>Kurulum Gereksinimi</td>
                                            <td><span class="badge bg-success">Yok</span></td>
                                            <td><span class="badge bg-warning">Apache POI</span></td>
                                        </tr>
                                        <tr>
                                            <td>Dosya Formatı</td>
                                            <td>CSV (Excel'de açılır)</td>
                                            <td>Gerçek Excel dosyası</td>
                                        </tr>
                                        <tr>
                                            <td>Formatlamalar</td>
                                            <td><i class="fas fa-times text-danger"></i></td>
                                            <td><i class="fas fa-check text-success"></i></td>
                                        </tr>
                                        <tr>
                                            <td>Formüller</td>
                                            <td><i class="fas fa-times text-danger"></i></td>
                                            <td><i class="fas fa-check text-success"></i></td>
                                        </tr>
                                        <tr>
                                            <td>Hücre Tipleri</td>
                                            <td>Sadece metin</td>
                                            <td>Metin, sayı, tarih</td>
                                        </tr>
                                        <tr>
                                            <td>Dosya Boyutu</td>
                                            <td>Küçük</td>
                                            <td>Orta</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!--- Örnek veri önizlemesi --->
                        <div class="mt-4">
                            <h6>Oluşturulacak Veri Örneği:</h6>
                            <div class="table-responsive">
                                <table class="table table-sm table-striped">
                                    <thead class="table-primary">
                                        <tr style="background-color: #1e3a8a; color: white;">
                                            <th style="border: 1px solid #333;">EtaKodu</th>
                                            <th style="border: 1px solid #333;">SeriNo</th>
                                            <th style="border: 1px solid #333;">Üretim Tarihi</th>
                                            <th style="border: 1px solid #333;">Paket Tarihi</th>
                                            <th style="border: 1px solid #333;">Barkod</th>
                                            <th style="border: 1px solid #333;">Miktar</th>
                                            <th style="border: 1px solid #333;">Marka</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td style="border: 1px solid #ddd;">ETA001</td>
                                            <td style="border: 1px solid #ddd;">SN202500001</td>
                                            <td style="border: 1px solid #ddd;">15.01.2025</td>
                                            <td style="border: 1px solid #ddd;">25.01.2025</td>
                                            <td style="border: 1px solid #ddd;">8612345678901</td>
                                            <td style="border: 1px solid #ddd; text-align: right;">25.50</td>
                                            <td style="border: 1px solid #ddd;">ABC Elektronik</td>
                                        </tr>
                                        <tr>
                                            <td style="border: 1px solid #ddd;">PRD002</td>
                                            <td style="border: 1px solid #ddd;">SN202500002</td>
                                            <td style="border: 1px solid #ddd;">20.01.2025</td>
                                            <td style="border: 1px solid #ddd;">30.01.2025</td>
                                            <td style="border: 1px solid #ddd;">8687654321098</td>
                                            <td style="border: 1px solid #ddd; text-align: right;">150.00</td>
                                            <td style="border: 1px solid #ddd;">XYZ Teknoloji</td>
                                        </tr>
                                        <tr>
                                            <td style="border: 1px solid #ddd;">ITM003</td>
                                            <td style="border: 1px solid #ddd;">SN202500003</td>
                                            <td style="border: 1px solid #ddd;">25.01.2025</td>
                                            <td style="border: 1px solid #ddd;">05.02.2025</td>
                                            <td style="border: 1px solid #ddd;">8611223344556</td>
                                            <td style="border: 1px solid #ddd; text-align: right;">75.25</td>
                                            <td style="border: 1px solid #ddd;">DEF Endüstri</td>
                                        </tr>
                                        <cfif url.includeFormulas eq "true">
                                            <tr style="background-color: #1e3a8a; color: white; font-weight: bold;">
                                                <td style="border: 1px solid #333;" colspan="4"></td>
                                                <td style="border: 1px solid #333;">TOPLAM:</td>
                                                <td style="border: 1px solid #333; text-align: right;">SUM(F2:F...)</td>
                                                <td style="border: 1px solid #333;"></td>
                                            </tr>
                                        </cfif>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
