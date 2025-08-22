-- Etiket Şablonları Tablosu Oluşturma
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='etiket_templates_s' AND xtype='U')
BEGIN
    CREATE TABLE etiket_templates_s (
        template_id INT IDENTITY(1,1) PRIMARY KEY,
        template_name NVARCHAR(100) NOT NULL,
        template_description NVARCHAR(255),
        label_width INT DEFAULT 300,
        label_height INT DEFAULT 200,
        qr_size INT DEFAULT 100,
        font_size INT DEFAULT 12,
        show_qr BIT DEFAULT 1,
        show_barcode BIT DEFAULT 0,
        fields_layout NVARCHAR(50) DEFAULT 'standard',
        created_date DATETIME DEFAULT GETDATE(),
        updated_date DATETIME DEFAULT GETDATE()
    )
    
    -- Varsayılan şablonları ekle
    INSERT INTO etiket_templates_s (template_name, template_description, label_width, label_height, qr_size, font_size, show_qr, show_barcode, fields_layout)
    VALUES 
    ('Standart Etiket', 'Temel etiket şablonu - QR kod ile', 300, 200, 100, 12, 1, 0, 'standard'),
    ('Küçük Etiket', 'Kompakt etiket tasarımı', 250, 150, 80, 10, 1, 0, 'compact'),
    ('Büyük Etiket', 'Detaylı büyük etiket', 400, 300, 120, 14, 1, 1, 'detailed'),
    ('Barkod Odaklı', 'Geleneksel barkod etiket', 300, 150, 60, 11, 0, 1, 'barcode_focus'),
    ('QR Odaklı', 'Büyük QR kod etiket', 200, 200, 150, 10, 1, 0, 'qr_focus')
    
    PRINT 'etiket_templates tablosu oluşturuldu ve varsayılan şablonlar eklendi.'
END
ELSE
BEGIN
    PRINT 'etiket_templates tablosu zaten mevcut.'
END
