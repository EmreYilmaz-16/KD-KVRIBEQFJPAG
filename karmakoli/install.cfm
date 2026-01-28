<cffile action="read" file="#ExpandPath('/pbs_dsn.txt')#" variable="configContent">
        <cfset dsn = trim(configContent)>
        <cfquery name="getparams" datasource="#dsn#" maxrows="1">
            SELECT PBS_MODUL_COMPANY_ID FROM PBS_PARAMETERS
        </cfquery>
        <cfif getparams.recordCount EQ 0>
            <cfthrow type="DatasourceResolution" message="PBS_MODUL_COMPANY_ID could not be determined." />
        </cfif>
        <cfset dsn3 = "#dsn#_#getparams.PBS_MODUL_COMPANY_ID#" />


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

<cfquery name="addColumn" datasource="#dsn#_product">
    IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'PRODUCT' 
      AND COLUMN_NAME = 'IS_PACKAGE_PRODUCT'
)
BEGIN
    ALTER TABLE PRODUCT 
    ADD IS_PACKAGE_PRODUCT BIT NOT NULL DEFAULT(0);
END

</cfquery>
<!----KARMA_EMIR(PRODUCT_ID, AMOUNT, RECORD_DATE, RECORD_EMP, CURRENT_STATUS, EMIR_NO)---->
<cfquery name="addKarmaEmirTable" datasource="#dsn3#">
    IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='KARMA_EMIR' AND xtype='U')
    CREATE TABLE KARMA_EMIR (
        KARMA_EMIR_ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
        PRODUCT_ID INT NOT NULL,
        AMOUNT INT NOT NULL,
        RECORD_DATE DATETIME NOT NULL,
        RECORD_EMP INT NOT NULL,
        CURRENT_STATUS INT NOT NULL,
        EMIR_NO VARCHAR(50) NOT NULL
    )
</cfquery>

<cfquery name="createKarmaEmirRows" datasource="#dsn3#">
    IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='KARMA_EMIR_ROWS' AND xtype='U')
    CREATE TABLE KARMA_EMIR_ROWS (
        ROW_ID INT PRIMARY KEY IDENTITY (1,1),
        EMIR_ID INT,
        SERIAL_NO NVARCHAR(150),
        PRODUCT_ID INT,
        STOCK_ID INT,
        QUANTITY INT,
        FIS_ID INT,
        FIS_PERIOD_ID INT,
        RECORD_DATE DATETIME,
        RECORD_EMP INT,
        FIS_WRK_ROW_ID NVARCHAR(150),
        SCN_WRK_ID NVARCHAR(150)

    )
</cfquery>

<cfquery name="createKarmaEmirRows" datasource="#dsn3#">
    IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='KARMA_EMIR_ROWS_HISTORY' AND xtype='U')
    CREATE TABLE KARMA_EMIR_ROWS_HISTORY (
        HISTORY_ID INT PRIMARY KEY IDENTITY (1,1),
        ROW_ID INT ,
        EMIR_ID INT,
        SERIAL_NO NVARCHAR(150),
        PRODUCT_ID INT,
        STOCK_ID INT,
        QUANTITY INT,
        FIS_ID INT,
        FIS_PERIOD_ID INT,
        RECORD_DATE DATETIME,
        RECORD_EMP INT,
        FIS_WRK_ROW_ID NVARCHAR(150),
        SCN_WRK_ID NVARCHAR(150)

    )
</cfquery>


<cfquery name="addParams" datasource="#dsn#">
        IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'PBS_PARAMETERS' 
      AND COLUMN_NAME = 'PACKAGING_STORE_LIST'
)
BEGIN
    ALTER TABLE PBS_PARAMETERS 
    ADD PACKAGING_STORE_LIST NVARCHAR(MAX); 
END

</cfquery>

