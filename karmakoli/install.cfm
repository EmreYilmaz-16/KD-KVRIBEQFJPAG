


<cfquery name="createTable" datasource="#dsn#_product">
    IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='KARMA_PRODUCTS_PBS' AND xtype='U')
    CREATE TABLE KARMA_PRODUCTS_PBS (
        PRODUCT_ID INT NOT NULL,
        QUANTITY INT NOT NULL,
        MAIN_PRODUCT_ID INT NOT NULL,
        RECORD_DATE DATETIME NOT NULL,
        RECORD_EMPLOYEE_ID INT NULL
    )
</cfquery>
<cfquery name="createHistoryTable" datasource="#dsn#_product">
    IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='KARMA_PRODUCTS_PBS_HISTORY' AND xtype='U')
    CREATE TABLE KARMA_PRODUCTS_PBS_HISTORY (
        PRODUCT_ID INT NOT NULL,
        QUANTITY INT NOT NULL,
        MAIN_PRODUCT_ID INT NOT NULL,
        ADDED_DATE DATETIME NOT NULL,
        RECORD_EMPLOYEE_ID INT NULL,
        RECORD_DATE DATETIME NULL
    )
</cfquery>

