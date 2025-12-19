<cfcomponent displayname="UserAccessService" hint="User Access CRUD Operations">

    <cfset variables.dsn = "w3qa">

    <!--- ==================== USER_ACCESS_PBS CRUD ==================== --->
    
    <!--- CREATE: Yeni kullanıcı erişimi ekle --->
    <cffunction name="createUserAccess" access="public" returntype="numeric" output="false">
        <cfargument name="userId" type="numeric" required="true">
        <cfargument name="accessType" type="string" required="true">
        
        <cfset var result = 0>
        
        <cfquery name="qInsert" datasource="#variables.dsn#" result="insertResult">
            INSERT INTO USER_ACCESS_PBS (USER_ID, ACCESS_TYPE)
            VALUES (
                <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#arguments.accessType#" cfsqltype="cf_sql_varchar" maxlength="30">
            )
        </cfquery>
        
        <cfset result = insertResult.generatedKey>
        
        <cfreturn result>
    </cffunction>
    
    <!--- READ: Tüm kullanıcı erişimlerini getir --->
    <cffunction name="getAllUserAccess" access="public" returntype="query" output="false">
        <cfset var qSelect = "">
        
        <cfquery name="qSelect" datasource="#variables.dsn#">
            SELECT ua.ACCESS_ID, ua.USER_ID, ua.ACCESS_TYPE,
                   m.EMPLOYEE_NAME+' '+m.EMPLOYEE_SURNAME as USER_NAME
            FROM USER_ACCESS_PBS ua
            LEFT JOIN EMPLOYEES m ON ua.USER_ID = m.EMPLOYEE_ID
            ORDER BY ua.ACCESS_ID
        </cfquery>
        
        <cfreturn qSelect>
    </cffunction>
    
    <!--- READ: ID'ye göre kullanıcı erişimi getir --->
    <cffunction name="getUserAccessById" access="public" returntype="query" output="false">
        <cfargument name="accessId" type="numeric" required="true">
        
        <cfset var qSelect = "">
        
        <cfquery name="qSelect" datasource="#variables.dsn#">
            SELECT ua.ACCESS_ID, ua.USER_ID, ua.ACCESS_TYPE,
                   m.EMPLOYEE_NAME+' '+m.EMPLOYEE_SURNAME as USER_NAME
            FROM USER_ACCESS_PBS ua
            LEFT JOIN EMPLOYEES m ON ua.USER_ID = m.EMPLOYEE_ID
            WHERE ua.ACCESS_ID = <cfqueryparam value="#arguments.accessId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cfreturn qSelect>
    </cffunction>
    
    <!--- READ: User ID'ye göre erişimleri getir --->
    <cffunction name="getUserAccessByUserId" access="public" returntype="query" output="false">
        <cfargument name="userId" type="numeric" required="true">
        
        <cfset var qSelect = "">
        
        <cfquery name="qSelect" datasource="#variables.dsn#">
            SELECT ua.ACCESS_ID, ua.USER_ID, ua.ACCESS_TYPE,
                   m.EMPLOYEE_NAME+' '+m.EMPLOYEE_SURNAME as USER_NAME
            FROM USER_ACCESS_PBS ua
            LEFT JOIN EMPLOYEES m ON ua.USER_ID = m.EMPLOYEE_ID
            WHERE ua.USER_ID = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cfreturn qSelect>
    </cffunction>
    
    <!--- UPDATE: Kullanıcı erişimini güncelle --->
    <cffunction name="updateUserAccess" access="public" returntype="boolean" output="false">
        <cfargument name="accessId" type="numeric" required="true">
        <cfargument name="userId" type="numeric" required="true">
        <cfargument name="accessType" type="string" required="true">
        
        <cfquery name="qUpdate" datasource="#variables.dsn#">
            UPDATE USER_ACCESS_PBS
            SET USER_ID = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_integer">,
                ACCESS_TYPE = <cfqueryparam value="#arguments.accessType#" cfsqltype="cf_sql_varchar" maxlength="30">
            WHERE ACCESS_ID = <cfqueryparam value="#arguments.accessId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cfreturn true>
    </cffunction>
    
    <!--- DELETE: Kullanıcı erişimini sil --->
    <cffunction name="deleteUserAccess" access="public" returntype="boolean" output="false">
        <cfargument name="accessId" type="numeric" required="true">
        
        <!--- Önce ilişkili kayıtları sil --->
        <cfquery name="qDeleteBrands" datasource="#variables.dsn#">
            DELETE FROM USER_ACCESS_BRANDS_PBS
            WHERE ACCESS_ID = <cfqueryparam value="#arguments.accessId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cfquery name="qDeleteCompanies" datasource="#variables.dsn#">
            DELETE FROM USER_ACCESS_COMPANIES_PBS
            WHERE ACCESS_ID = <cfqueryparam value="#arguments.accessId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <!--- Ana kaydı sil --->
        <cfquery name="qDelete" datasource="#variables.dsn#">
            DELETE FROM USER_ACCESS_PBS
            WHERE ACCESS_ID = <cfqueryparam value="#arguments.accessId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cfreturn true>
    </cffunction>

    <!--- ==================== USER_ACCESS_BRANDS_PBS CRUD ==================== --->
    
    <!--- CREATE: Erişime marka ekle --->
    <cffunction name="addBrandToAccess" access="public" returntype="boolean" output="false">
        <cfargument name="accessId" type="numeric" required="true">
        <cfargument name="brandId" type="numeric" required="true">
        
        <cfquery name="qInsert" datasource="#variables.dsn#">
            INSERT INTO USER_ACCESS_BRANDS_PBS (ACCESS_ID, BRAND_ID)
            VALUES (
                <cfqueryparam value="#arguments.accessId#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#arguments.brandId#" cfsqltype="cf_sql_integer">
            )
        </cfquery>
        
        <cfreturn true>
    </cffunction>
    
    <!--- CREATE: Toplu marka ekleme --->
    <cffunction name="addBrandsToAccess" access="public" returntype="boolean" output="false">
        <cfargument name="accessId" type="numeric" required="true">
        <cfargument name="brandIds" type="string" required="true" hint="Virgülle ayrılmış brand ID'leri">
        
        <cfset var brandIdList = listToArray(arguments.brandIds)>
        
        <cfloop array="#brandIdList#" index="brandId">
            <cfquery name="qInsert" datasource="#variables.dsn#">
                INSERT INTO USER_ACCESS_BRANDS_PBS (ACCESS_ID, BRAND_ID)
                VALUES (
                    <cfqueryparam value="#arguments.accessId#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#val(brandId)#" cfsqltype="cf_sql_integer">
                )
            </cfquery>
        </cfloop>
        
        <cfreturn true>
    </cffunction>
    
    <!--- READ: Access ID'ye göre markaları getir --->
    <cffunction name="getBrandsByAccessId" access="public" returntype="query" output="false">
        <cfargument name="accessId" type="numeric" required="true">
        
        <cfset var qSelect = "">
        
        <cfquery name="qSelect" datasource="#variables.dsn#_product">
            SELECT uab.ACCESS_ID, uab.BRAND_ID, pb.BRAND_NAME
            FROM #dsn#.USER_ACCESS_BRANDS_PBS uab
            LEFT JOIN PRODUCT_BRANDS pb ON uab.BRAND_ID = pb.BRAND_ID
            WHERE uab.ACCESS_ID = <cfqueryparam value="#arguments.accessId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cfreturn qSelect>
    </cffunction>
    
    <!--- DELETE: Erişimden marka sil --->
    <cffunction name="removeBrandFromAccess" access="public" returntype="boolean" output="false">
        <cfargument name="accessId" type="numeric" required="true">
        <cfargument name="brandId" type="numeric" required="true">
        
        <cfquery name="qDelete" datasource="#variables.dsn#">
            DELETE FROM USER_ACCESS_BRANDS_PBS
            WHERE ACCESS_ID = <cfqueryparam value="#arguments.accessId#" cfsqltype="cf_sql_integer">
              AND BRAND_ID = <cfqueryparam value="#arguments.brandId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cfreturn true>
    </cffunction>
    
    <!--- DELETE: Erişimdeki tüm markaları sil --->
    <cffunction name="removeAllBrandsFromAccess" access="public" returntype="boolean" output="false">
        <cfargument name="accessId" type="numeric" required="true">
        
        <cfquery name="qDelete" datasource="#variables.dsn#">
            DELETE FROM USER_ACCESS_BRANDS_PBS
            WHERE ACCESS_ID = <cfqueryparam value="#arguments.accessId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cfreturn true>
    </cffunction>

    <!--- ==================== USER_ACCESS_COMPANIES_PBS CRUD ==================== --->
    
    <!--- CREATE: Erişime şirket ekle --->
    <cffunction name="addCompanyToAccess" access="public" returntype="boolean" output="false">
        <cfargument name="accessId" type="numeric" required="true">
        <cfargument name="companyId" type="numeric" required="true">
        
        <cfquery name="qInsert" datasource="#variables.dsn#">
            INSERT INTO USER_ACCESS_COMPANIES_PBS (ACCESS_ID, COMPANY_ID)
            VALUES (
                <cfqueryparam value="#arguments.accessId#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#arguments.companyId#" cfsqltype="cf_sql_integer">
            )
        </cfquery>
        
        <cfreturn true>
    </cffunction>
    
    <!--- CREATE: Toplu şirket ekleme --->
    <cffunction name="addCompaniesToAccess" access="public" returntype="boolean" output="false">
        <cfargument name="accessId" type="numeric" required="true">
        <cfargument name="companyIds" type="string" required="true" hint="Virgülle ayrılmış company ID'leri">
        
        <cfset var companyIdList = listToArray(arguments.companyIds)>
        
        <cfloop array="#companyIdList#" index="companyId">
            <cfquery name="qInsert" datasource="#variables.dsn#">
                INSERT INTO USER_ACCESS_COMPANIES_PBS (ACCESS_ID, COMPANY_ID)
                VALUES (
                    <cfqueryparam value="#arguments.accessId#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#val(companyId)#" cfsqltype="cf_sql_integer">
                )
            </cfquery>
        </cfloop>
        
        <cfreturn true>
    </cffunction>
    
    <!--- READ: Access ID'ye göre şirketleri getir --->
    <cffunction name="getCompaniesByAccessId" access="public" returntype="query" output="false">
        <cfargument name="accessId" type="numeric" required="true">
        
        <cfset var qSelect = "">
        
        <cfquery name="qSelect" datasource="#variables.dsn#">
            SELECT uac.ACCESS_ID, uac.COMPANY_ID, p.NICKNAME as COMPANY_NAME
            FROM USER_ACCESS_COMPANIES_PBS uac
            LEFT JOIN COMPANY p ON uac.COMPANY_ID = p.COMPANY_ID
            WHERE uac.ACCESS_ID = <cfqueryparam value="#arguments.accessId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cfreturn qSelect>
    </cffunction>
    
    <!--- DELETE: Erişimden şirket sil --->
    <cffunction name="removeCompanyFromAccess" access="public" returntype="boolean" output="false">
        <cfargument name="accessId" type="numeric" required="true">
        <cfargument name="companyId" type="numeric" required="true">
        
        <cfquery name="qDelete" datasource="#variables.dsn#">
            DELETE FROM USER_ACCESS_COMPANIES_PBS
            WHERE ACCESS_ID = <cfqueryparam value="#arguments.accessId#" cfsqltype="cf_sql_integer">
              AND COMPANY_ID = <cfqueryparam value="#arguments.companyId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cfreturn true>
    </cffunction>
    
    <!--- DELETE: Erişimdeki tüm şirketleri sil --->
    <cffunction name="removeAllCompaniesFromAccess" access="public" returntype="boolean" output="false">
        <cfargument name="accessId" type="numeric" required="true">
        
        <cfquery name="qDelete" datasource="#variables.dsn#">
            DELETE FROM USER_ACCESS_COMPANIES_PBS
            WHERE ACCESS_ID = <cfqueryparam value="#arguments.accessId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cfreturn true>
    </cffunction>

    <!--- ==================== YARDIMCI FONKSİYONLAR ==================== --->
    
    <!--- Kullanıcının tüm erişim detaylarını getir --->
    <cffunction name="getUserAccessDetails" access="public" returntype="struct" output="false">
        <cfargument name="userId" type="numeric" required="true">
        
        <cfset var result = structNew()>
        <cfset var qAccess = "">
        <cfset var accessList = arrayNew(1)>
        
        <!--- Kullanıcının erişimlerini getir --->
        <cfquery name="qAccess" datasource="#variables.dsn#">
            SELECT ua.ACCESS_ID, ua.USER_ID, ua.ACCESS_TYPE,
                   m.EMPLOYEE_NAME+' '+m.EMPLOYEE_SURNAME as USER_NAME
            FROM USER_ACCESS_PBS ua
            LEFT JOIN EMPLOYEES m ON ua.USER_ID = m.EMPLOYEE_ID
            WHERE ua.USER_ID = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cfloop query="qAccess">
            <cfset var accessItem = structNew()>
            <cfset accessItem.accessId = qAccess.ACCESS_ID>
            <cfset accessItem.userId = qAccess.USER_ID>
            <cfset accessItem.accessType = qAccess.ACCESS_TYPE>
            
            <!--- Bu erişime ait markaları getir --->
            <cfset accessItem.brands = getBrandsByAccessId(qAccess.ACCESS_ID)>
            
            <!--- Bu erişime ait şirketleri getir --->
            <cfset accessItem.companies = getCompaniesByAccessId(qAccess.ACCESS_ID)>
            
            <cfset arrayAppend(accessList, accessItem)>
        </cfloop>
        
        <cfset result.userId = arguments.userId>
        <cfset result.accessList = accessList>
        
        <cfreturn result>
    </cffunction>
    
    <!--- Tam erişim kaydı oluştur (markalar ve şirketlerle birlikte) --->
    <cffunction name="createFullUserAccess" access="public" returntype="numeric" output="false">
        <cfargument name="userId" type="numeric" required="true">
        <cfargument name="accessType" type="string" required="true">
        <cfargument name="brandIds" type="string" required="false" default="">
        <cfargument name="companyIds" type="string" required="false" default="">
        
        <cfset var accessId = 0>
        
        <cftransaction>
            <!--- Ana erişim kaydını oluştur --->
            <cfset accessId = createUserAccess(arguments.userId, arguments.accessType)>
            
            <!--- Markaları ekle --->
            <cfif len(trim(arguments.brandIds))>
                <cfset addBrandsToAccess(accessId, arguments.brandIds)>
            </cfif>
            
            <!--- Şirketleri ekle --->
            <cfif len(trim(arguments.companyIds))>
                <cfset addCompaniesToAccess(accessId, arguments.companyIds)>
            </cfif>
        </cftransaction>
        
        <cfreturn accessId>
    </cffunction>
    
    <!--- Tam erişim kaydı güncelle (markalar ve şirketlerle birlikte) --->
    <cffunction name="updateFullUserAccess" access="public" returntype="boolean" output="false">
        <cfargument name="accessId" type="numeric" required="true">
        <cfargument name="userId" type="numeric" required="true">
        <cfargument name="accessType" type="string" required="true">
        <cfargument name="brandIds" type="string" required="false" default="">
        <cfargument name="companyIds" type="string" required="false" default="">
        
        <cftransaction>
            <!--- Ana erişim kaydını güncelle --->
            <cfset updateUserAccess(arguments.accessId, arguments.userId, arguments.accessType)>
            
            <!--- Mevcut markaları sil ve yenilerini ekle --->
            <cfset removeAllBrandsFromAccess(arguments.accessId)>
            <cfif len(trim(arguments.brandIds))>
                <cfset addBrandsToAccess(arguments.accessId, arguments.brandIds)>
            </cfif>
            
            <!--- Mevcut şirketleri sil ve yenilerini ekle --->
            <cfset removeAllCompaniesFromAccess(arguments.accessId)>
            <cfif len(trim(arguments.companyIds))>
                <cfset addCompaniesToAccess(arguments.accessId, arguments.companyIds)>
            </cfif>
        </cftransaction>
        
        <cfreturn true>
    </cffunction>

</cfcomponent>
