-- SATINALMA_PLANLAMA_PBS tablosuna ORDER_ID kolonu ekleme

USE w3Qa_1;
GO

-- Eğer kolon yoksa ekle
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('w3Qa_1.SATINALMA_PLANLAMA_PBS') 
    AND name = 'ORDER_ID'
)
BEGIN
    ALTER TABLE w3Qa_1.SATINALMA_PLANLAMA_PBS
    ADD ORDER_ID INT NULL;
    
    PRINT 'ORDER_ID kolonu eklendi.';
END
ELSE
BEGIN
    PRINT 'ORDER_ID kolonu zaten mevcut.';
END
GO
