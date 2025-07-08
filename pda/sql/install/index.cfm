<cftry>
<cfset request.pageTitle = "Install PDA Database">
<cfset request.pageDescription = "Install PDA Database">    
<cfset request.pageKeywords = "install, pda, database, ColdFusion, SQL">
<cfset request.pageName = "install">
<cfset request.pagePath = "install">
<cfset request.pageType = "install">
<cfset request.pageSubType = "pda">
<cfset request.pageSubPath = "pda">
<cfset request.pageSubTitle = "PDA Database Installation">
<cfset request.pageSubDescription = "Install the PDA database for ColdFusion applications.">
<cfset request.pageSubKeywords = "pda, database, installation, ColdFusion, SQL">
<cfset request.pageSubName = "pda-install">

<cfquery name="createTbl" datasource="#dsn#">

CREATE TABLE IF NOT EXISTS PDA_FUSEACTIONS (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    PAGE_FUSEACTION VARCHAR(255) NOT NULL,
    W3C_FUSEACTION VARCHAR(255),
    PAGE_HEAD TEXT,
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    ICON VARCHAR(255),
    IS_DEFAULT BOOLEAN DEFAULT FALSE,
    PDA_MODULE_ID INT
);

CREATE TABLE IF NOT EXISTS PDA_MODULES (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    MODULE_NAME VARCHAR(255) NOT NULL,
    DESCRIPTION TEXT,
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    ICON VARCHAR(255)
    
);

INSERT INTO PDA_MODULES (MODULE_NAME, DESCRIPTION, IS_ACTIVE, ICON)
VALUES 
('PDA', 'PDA Module for ColdFusion applications', TRUE, 'pda-icon.png'),
('PDA Admin', 'Administration module for PDA', TRUE, 'pda-admin-icon.png');
INSERT INTO PDA_FUSEACTIONS (PAGE_FUSEACTION, W3C_FUSEACTION, PAGE_HEAD, IS_ACTIVE, ICON, IS_DEFAULT, PDA_MODULE_ID)
VALUES
('pda-home', 'pda-home', '<title>PDA Home</title>', TRUE, 'pda-home-icon.png', TRUE, 1),
('pda-settings', 'pda-settings', '<title>PDA Settings</title>', TRUE, 'pda-settings-icon.png', FALSE, 1),
('pda-admin', 'pda-admin', '<title>PDA Admin</title>', TRUE, 'pda-admin-icon.png', FALSE, 2);
('pda-help', 'pda-help', '<title>PDA Help</title>', TRUE, 'pda-help-icon.png', FALSE, 1);
('add-pda-fuseaction', 'add-pda-fuseaction', '<title>Add PDA Fuseaction</title>', TRUE, 'add-fuseaction-icon.png', FALSE, 2);
('edit-pda-fuseaction', 'edit-pda-fuseaction', '<title>Edit PDA Fuseaction</title>', TRUE, 'edit-fuseaction-icon.png', FALSE, 2);
('delete-pda-fuseaction', 'delete-pda-fuseaction', '<title>Delete PDA Fuseaction</title>', TRUE, 'delete-fuseaction-icon.png', FALSE, 2);
('add-pda-module', 'add-pda-module', '<title>Add PDA Module</title>', TRUE, 'add-module-icon.png', FALSE, 2),
('edit-pda-module', 'edit-pda-module', '<title>Edit PDA Module</title>', TRUE, 'edit-module-icon.png', FALSE, 2),
('delete-pda-module', 'delete-pda-module', '<title>Delete PDA Module</title>', TRUE, 'delete-module-icon.png', FALSE, 2);

</cfquery> 


</cftry>
