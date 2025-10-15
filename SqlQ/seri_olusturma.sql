SELECT
    *,
    CASE
        WHEN BRAND_ID IN (2, 13) THEN CONCAT (
            PRODUCT_CODE_2,
            '_',
            SERI_NO,
            '_',
            FORMAT (GETDATE (), 'MM.yy'),
            '_',
            FORMAT (GETDATE (), 'MM/yy'),
            '_',
            '0000000000000',
            '_',
            '1.00'
        )
        ELSE CONCAT (
            PRODUCT_CODE_2,
            ' ',
            '0016',
            '-',
            '1-3-',
            FORMAT (GETDATE (), 'dd.MM.yyyy'),
            '-',
            SERI_NO
        )
    END AS FULL_BARCODE
FROM
    (
        SELECT
            S.PRODUCT_CODE_2,
            S.BRAND_ID,
            PP.SHELF_CODE,
            dbo.GenerateSerial16_FromGuid (NEWID ()) as SERI_NO
        FROM
            w3Qa_1.PRODUCT_PLACE_ROWS PPR
            LEFT JOIN w3Qa_1.STOCKS AS S ON S.STOCK_ID = PPR.STOCK_ID
            LEFT JOIN w3Qa_1.PRODUCT_PLACE AS PP ON PP.PRODUCT_PLACE_ID = PPR.PRODUCT_PLACE_ID
        WHERE
            PP.STORE_ID = 2
            AND PP.LOCATION_ID > 3 --ORDER BY BRAND_ID
    ) AS T
ORDER BY
    BRAND_ID,
    SHELF_CODE