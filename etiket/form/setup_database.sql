-- Excel Etiket Import Sistemi Veritabanı Tabloları
-- Microsoft SQL Server uyumlu

-- 1. Import log tablosu - Import işlemlerinin kayıtlarını tutar
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='etiket_import_log' AND xtype='U')
BEGIN
    CREATE TABLE etiket_import_log (
        import_id INT IDENTITY(1,1) PRIMARY KEY,
        import_date DATETIME NOT NULL DEFAULT GETDATE(),
        file_name NVARCHAR(255) NOT NULL,
        file_size BIGINT NULL,
        total_records INT DEFAULT 0,
        success_records INT DEFAULT 0,
        error_records INT DEFAULT 0,
        status NVARCHAR(20) DEFAULT 'PROCESSING', -- PROCESSING, COMPLETED, ERROR
        error_message NVARCHAR(MAX) NULL,
        completed_date DATETIME NULL,
        created_by NVARCHAR(100) DEFAULT 'system',
        created_date DATETIME DEFAULT GETDATE()
    )
    
    -- Index'ler
    CREATE INDEX IX_etiket_import_log_date ON etiket_import_log(import_date DESC)
    CREATE INDEX IX_etiket_import_log_status ON etiket_import_log(status)
    
    PRINT 'etiket_import_log tablosu oluşturuldu.'
END
ELSE
BEGIN
    PRINT 'etiket_import_log tablosu zaten mevcut.'
END

-- 2. Geçici veri tablosu - Import edilen verileri tutar
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='etiket_temp_data' AND xtype='U')
BEGIN
    CREATE TABLE etiket_temp_data (
        temp_id INT IDENTITY(1,1) PRIMARY KEY,
        import_id INT NOT NULL,
        eta_kodu NVARCHAR(50) NOT NULL,
        seri_no NVARCHAR(50) NOT NULL,
        uretim_tarihi DATETIME NULL,
        paket_tarihi DATETIME NULL,
        barkod NVARCHAR(100) NULL,
        miktar DECIMAL(18,2) DEFAULT 0,
        marka NVARCHAR(100) NULL,
        row_number INT NOT NULL, -- Excel'deki satır numarası
        is_processed BIT DEFAULT 0, -- Etiket yazdırıldı mı?
        processed_date DATETIME NULL,
        notes NVARCHAR(MAX) NULL, -- Ek notlar
        created_date DATETIME DEFAULT GETDATE()
    )
    
    -- Foreign Key
    ALTER TABLE etiket_temp_data 
    ADD CONSTRAINT FK_etiket_temp_data_import_id 
    FOREIGN KEY (import_id) REFERENCES etiket_import_log(import_id)
    ON DELETE CASCADE
    
    -- Index'ler
    CREATE INDEX IX_etiket_temp_data_import_id ON etiket_temp_data(import_id)
    CREATE INDEX IX_etiket_temp_data_eta_kodu ON etiket_temp_data(eta_kodu)
    CREATE INDEX IX_etiket_temp_data_seri_no ON etiket_temp_data(seri_no)
    CREATE INDEX IX_etiket_temp_data_barkod ON etiket_temp_data(barkod)
    CREATE INDEX IX_etiket_temp_data_row_number ON etiket_temp_data(import_id, row_number)
    
    PRINT 'etiket_temp_data tablosu oluşturuldu.'
END
ELSE
BEGIN
    PRINT 'etiket_temp_data tablosu zaten mevcut.'
END

-- 3. Etiket yazdırma geçmişi tablosu (opsiyonel)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='etiket_print_history' AND xtype='U')
BEGIN
    CREATE TABLE etiket_print_history (
        print_id INT IDENTITY(1,1) PRIMARY KEY,
        import_id INT NOT NULL,
        temp_id INT NOT NULL,
        print_date DATETIME DEFAULT GETDATE(),
        print_user NVARCHAR(100) DEFAULT 'system',
        print_count INT DEFAULT 1,
        notes NVARCHAR(MAX) NULL
    )
    
    -- Foreign Keys
    ALTER TABLE etiket_print_history 
    ADD CONSTRAINT FK_etiket_print_history_import_id 
    FOREIGN KEY (import_id) REFERENCES etiket_import_log(import_id)
    
    ALTER TABLE etiket_print_history 
    ADD CONSTRAINT FK_etiket_print_history_temp_id 
    FOREIGN KEY (temp_id) REFERENCES etiket_temp_data(temp_id)
    
    -- Index'ler
    CREATE INDEX IX_etiket_print_history_import_id ON etiket_print_history(import_id)
    CREATE INDEX IX_etiket_print_history_date ON etiket_print_history(print_date DESC)
    
    PRINT 'etiket_print_history tablosu oluşturuldu.'
END
ELSE
BEGIN
    PRINT 'etiket_print_history tablosu zaten mevcut.'
END

-- 4. Etiket template ayarları tablosu (opsiyonel)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='etiket_templates' AND xtype='U')
BEGIN
    CREATE TABLE etiket_templates (
        template_id INT IDENTITY(1,1) PRIMARY KEY,
        template_name NVARCHAR(100) NOT NULL,
        template_description NVARCHAR(255) NULL,
        template_html NVARCHAR(MAX) NOT NULL,
        template_css NVARCHAR(MAX) NULL,
        is_active BIT DEFAULT 1,
        is_default BIT DEFAULT 0,
        created_date DATETIME DEFAULT GETDATE(),
        updated_date DATETIME DEFAULT GETDATE()
    )
    
    -- Index'ler
    CREATE INDEX IX_etiket_templates_name ON etiket_templates(template_name)
    CREATE INDEX IX_etiket_templates_active ON etiket_templates(is_active)
    
    -- Varsayılan template ekle
    INSERT INTO etiket_templates (template_name, template_description, template_html, is_default)
    VALUES (
        'Standart Etiket', 
        'Varsayılan etiket formatı',
        '<div class="label-item">
            <div class="label-header">{{marka}} - ÜRÜN ETİKETİ</div>
            <div class="label-content">
                <div class="label-field"><strong>ETA Kodu:</strong> <span>{{eta_kodu}}</span></div>
                <div class="label-field"><strong>Seri No:</strong> <span>{{seri_no}}</span></div>
                <div class="label-field"><strong>Üretim:</strong> <span>{{uretim_tarihi}}</span></div>
                <div class="label-field"><strong>Paket:</strong> <span>{{paket_tarihi}}</span></div>
                <div class="label-field"><strong>Miktar:</strong> <span>{{miktar}}</span></div>
                <div class="barcode-section">
                    <div class="barcode-display">*{{barkod}}*</div>
                </div>
            </div>
        </div>',
        1
    )
    
    PRINT 'etiket_templates tablosu oluşturuldu ve varsayılan template eklendi.'
END
ELSE
BEGIN
    PRINT 'etiket_templates tablosu zaten mevcut.'
END

-- Örnek veri ekleme (Test için)
/*
-- Test import kaydı
INSERT INTO etiket_import_log (file_name, total_records, success_records, error_records, status, completed_date)
VALUES ('test_urunler.xlsx', 5, 5, 0, 'COMPLETED', GETDATE())

DECLARE @test_import_id INT = SCOPE_IDENTITY()

-- Test etiket verileri
INSERT INTO etiket_temp_data (import_id, eta_kodu, seri_no, uretim_tarihi, paket_tarihi, barkod, miktar, marka, row_number)
VALUES 
    (@test_import_id, 'ETA001', 'SN001', '2025-01-15', '2025-01-20', '1234567890123', 10.50, 'ABC Marka', 2),
    (@test_import_id, 'ETA002', 'SN002', '2025-01-16', '2025-01-21', '1234567890124', 25.00, 'XYZ Marka', 3),
    (@test_import_id, 'ETA003', 'SN003', '2025-01-17', '2025-01-22', '1234567890125', 15.75, 'DEF Marka', 4),
    (@test_import_id, 'ETA004', 'SN004', '2025-01-18', '2025-01-23', '1234567890126', 30.00, 'GHI Marka', 5),
    (@test_import_id, 'ETA005', 'SN005', '2025-01-19', '2025-01-24', '1234567890127', 8.25, 'JKL Marka', 6)
*/

-- Temizlik prosedürü (eski verileri temizlemek için)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='sp_CleanOldImportData' AND xtype='P')
BEGIN
    EXEC('
    CREATE PROCEDURE sp_CleanOldImportData
        @DaysOld INT = 30
    AS
    BEGIN
        SET NOCOUNT ON
        
        DECLARE @CutoffDate DATETIME = DATEADD(DAY, -@DaysOld, GETDATE())
        
        -- Yazdırma geçmişini temizle
        DELETE FROM etiket_print_history 
        WHERE import_id IN (
            SELECT import_id FROM etiket_import_log 
            WHERE import_date < @CutoffDate
        )
        
        -- Geçici verileri temizle
        DELETE FROM etiket_temp_data 
        WHERE import_id IN (
            SELECT import_id FROM etiket_import_log 
            WHERE import_date < @CutoffDate
        )
        
        -- Import loglarını temizle
        DELETE FROM etiket_import_log 
        WHERE import_date < @CutoffDate
        
        PRINT ''Eski import verileri temizlendi.''
    END
    ')
    
    PRINT 'sp_CleanOldImportData prosedürü oluşturuldu.'
END

-- Yedekleme prosedürü
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='sp_BackupImportData' AND xtype='P')
BEGIN
    EXEC('
    CREATE PROCEDURE sp_BackupImportData
        @ImportId INT = NULL
    AS
    BEGIN
        SET NOCOUNT ON
        
        -- Archive tabloları oluştur (eğer yoksa)
        IF NOT EXISTS (SELECT * FROM sysobjects WHERE name=''etiket_import_log_archive'' AND xtype=''U'')
        BEGIN
            SELECT * INTO etiket_import_log_archive FROM etiket_import_log WHERE 1=0
        END
        
        IF NOT EXISTS (SELECT * FROM sysobjects WHERE name=''etiket_temp_data_archive'' AND xtype=''U'')
        BEGIN
            SELECT * INTO etiket_temp_data_archive FROM etiket_temp_data WHERE 1=0
        END
        
        -- Veri yedekle
        IF @ImportId IS NULL
        BEGIN
            -- Tüm verileri yedekle
            INSERT INTO etiket_import_log_archive SELECT * FROM etiket_import_log
            INSERT INTO etiket_temp_data_archive SELECT * FROM etiket_temp_data
        END
        ELSE
        BEGIN
            -- Belirli import''u yedekle
            INSERT INTO etiket_import_log_archive 
            SELECT * FROM etiket_import_log WHERE import_id = @ImportId
            
            INSERT INTO etiket_temp_data_archive 
            SELECT * FROM etiket_temp_data WHERE import_id = @ImportId
        END
        
        PRINT ''Import verileri yedeklendi.''
    END
    ')
    
    PRINT 'sp_BackupImportData prosedürü oluşturuldu.'
END

PRINT ''
PRINT '======================================'
PRINT 'Excel Etiket Import Sistemi Kurulumu Tamamlandı!'
PRINT '======================================'
PRINT ''
PRINT 'Oluşturulan Tablolar:'
PRINT '1. etiket_import_log - Import işlem kayıtları'
PRINT '2. etiket_temp_data - Import edilen veriler'
PRINT '3. etiket_print_history - Yazdırma geçmişi'
PRINT '4. etiket_templates - Etiket şablonları'
PRINT ''
PRINT 'Oluşturulan Prosedürler:'
PRINT '1. sp_CleanOldImportData - Eski verileri temizleme'
PRINT '2. sp_BackupImportData - Veri yedekleme'
PRINT ''
PRINT 'Sistemin çalışması için Apache POI kütüphanesi gereklidir.'
PRINT 'ColdFusion lib klasörüne poi-*.jar dosyalarını ekleyin.'
