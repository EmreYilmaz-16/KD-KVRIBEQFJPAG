<cfsilent>
<!--- User Access API - REST-like endpoints --->
<cfset response = structNew()>
<cfset response.success = false>
<cfset response.message = "">
<cfset response.data = "">

<cfparam name="url.action" default="">
<cfparam name="form.action" default="#url.action#">

<cfset userAccessService = createObject("component", "UserAccessService")>

<cftry>
    <cfswitch expression="#form.action#">
        
        <!--- ==================== USER ACCESS CRUD ==================== --->
        
        <!--- CREATE: Yeni kullanıcı erişimi oluştur --->
        <cfcase value="createUserAccess">
            <cfparam name="form.userId" default="0">
            <cfparam name="form.accessType" default="">
            <cfparam name="form.brandIds" default="">
            <cfparam name="form.companyIds" default="">
            
            <cfif val(form.userId) eq 0 OR len(trim(form.accessType)) eq 0>
                <cfset response.message = "userId ve accessType zorunludur">
            <cfelse>
                <cfset accessId = userAccessService.createFullUserAccess(
                    userId = val(form.userId),
                    accessType = form.accessType,
                    brandIds = form.brandIds,
                    companyIds = form.companyIds
                )>
                <cfset response.success = true>
                <cfset response.message = "Erişim başarıyla oluşturuldu">
                <cfset response.data = accessId>
            </cfif>
        </cfcase>
        
        <!--- READ: Tüm kullanıcı erişimlerini getir --->
        <cfcase value="getAllUserAccess">
            <cfset qResult = userAccessService.getAllUserAccess()>
            <cfset response.success = true>
            <cfset response.message = "Veriler başarıyla getirildi">
            <cfset response.data = queryToArray(qResult)>
        </cfcase>
        
        <!--- READ: ID'ye göre erişim getir --->
        <cfcase value="getUserAccessById">
            <cfparam name="form.accessId" default="0">
            
            <cfif val(form.accessId) eq 0>
                <cfset response.message = "accessId zorunludur">
            <cfelse>
                <cfset qResult = userAccessService.getUserAccessById(val(form.accessId))>
                <cfset response.success = true>
                <cfset response.message = "Veri başarıyla getirildi">
                <cfset response.data = queryToArray(qResult)>
            </cfif>
        </cfcase>
        
        <!--- READ: User ID'ye göre erişimleri getir --->
        <cfcase value="getUserAccessByUserId">
            <cfparam name="form.userId" default="0">
            
            <cfif val(form.userId) eq 0>
                <cfset response.message = "userId zorunludur">
            <cfelse>
                <cfset qResult = userAccessService.getUserAccessByUserId(val(form.userId))>
                <cfset response.success = true>
                <cfset response.message = "Veriler başarıyla getirildi">
                <cfset response.data = queryToArray(qResult)>
            </cfif>
        </cfcase>
        
        <!--- READ: Kullanıcının tüm erişim detaylarını getir --->
        <cfcase value="getUserAccessDetails">
            <cfparam name="form.userId" default="0">
            
            <cfif val(form.userId) eq 0>
                <cfset response.message = "userId zorunludur">
            <cfelse>
                <cfset result = userAccessService.getUserAccessDetails(val(form.userId))>
                <cfset response.success = true>
                <cfset response.message = "Veriler başarıyla getirildi">
                <cfset response.data = result>
            </cfif>
        </cfcase>
        
        <!--- UPDATE: Kullanıcı erişimini güncelle --->
        <cfcase value="updateUserAccess">
            <cfparam name="form.accessId" default="0">
            <cfparam name="form.userId" default="0">
            <cfparam name="form.accessType" default="">
            <cfparam name="form.brandIds" default="">
            <cfparam name="form.companyIds" default="">
            
            <cfif val(form.accessId) eq 0 OR val(form.userId) eq 0 OR len(trim(form.accessType)) eq 0>
                <cfset response.message = "accessId, userId ve accessType zorunludur">
            <cfelse>
                <cfset userAccessService.updateFullUserAccess(
                    accessId = val(form.accessId),
                    userId = val(form.userId),
                    accessType = form.accessType,
                    brandIds = form.brandIds,
                    companyIds = form.companyIds
                )>
                <cfset response.success = true>
                <cfset response.message = "Erişim başarıyla güncellendi">
            </cfif>
        </cfcase>
        
        <!--- DELETE: Kullanıcı erişimini sil --->
        <cfcase value="deleteUserAccess">
            <cfparam name="form.accessId" default="0">
            
            <cfif val(form.accessId) eq 0>
                <cfset response.message = "accessId zorunludur">
            <cfelse>
                <cfset userAccessService.deleteUserAccess(val(form.accessId))>
                <cfset response.success = true>
                <cfset response.message = "Erişim başarıyla silindi">
            </cfif>
        </cfcase>
        
        <!--- ==================== BRAND CRUD ==================== --->
        
        <!--- CREATE: Erişime marka ekle --->
        <cfcase value="addBrandToAccess">
            <cfparam name="form.accessId" default="0">
            <cfparam name="form.brandId" default="0">
            
            <cfif val(form.accessId) eq 0 OR val(form.brandId) eq 0>
                <cfset response.message = "accessId ve brandId zorunludur">
            <cfelse>
                <cfset userAccessService.addBrandToAccess(val(form.accessId), val(form.brandId))>
                <cfset response.success = true>
                <cfset response.message = "Marka başarıyla eklendi">
            </cfif>
        </cfcase>
        
        <!--- CREATE: Toplu marka ekle --->
        <cfcase value="addBrandsToAccess">
            <cfparam name="form.accessId" default="0">
            <cfparam name="form.brandIds" default="">
            
            <cfif val(form.accessId) eq 0 OR len(trim(form.brandIds)) eq 0>
                <cfset response.message = "accessId ve brandIds zorunludur">
            <cfelse>
                <cfset userAccessService.addBrandsToAccess(val(form.accessId), form.brandIds)>
                <cfset response.success = true>
                <cfset response.message = "Markalar başarıyla eklendi">
            </cfif>
        </cfcase>
        
        <!--- READ: Erişime ait markaları getir --->
        <cfcase value="getBrandsByAccessId">
            <cfparam name="form.accessId" default="0">
            
            <cfif val(form.accessId) eq 0>
                <cfset response.message = "accessId zorunludur">
            <cfelse>
                <cfset qResult = userAccessService.getBrandsByAccessId(val(form.accessId))>
                <cfset response.success = true>
                <cfset response.message = "Markalar başarıyla getirildi">
                <cfset response.data = queryToArray(qResult)>
            </cfif>
        </cfcase>
        
        <!--- DELETE: Erişimden marka sil --->
        <cfcase value="removeBrandFromAccess">
            <cfparam name="form.accessId" default="0">
            <cfparam name="form.brandId" default="0">
            
            <cfif val(form.accessId) eq 0 OR val(form.brandId) eq 0>
                <cfset response.message = "accessId ve brandId zorunludur">
            <cfelse>
                <cfset userAccessService.removeBrandFromAccess(val(form.accessId), val(form.brandId))>
                <cfset response.success = true>
                <cfset response.message = "Marka başarıyla silindi">
            </cfif>
        </cfcase>
        
        <!--- DELETE: Erişimdeki tüm markaları sil --->
        <cfcase value="removeAllBrandsFromAccess">
            <cfparam name="form.accessId" default="0">
            
            <cfif val(form.accessId) eq 0>
                <cfset response.message = "accessId zorunludur">
            <cfelse>
                <cfset userAccessService.removeAllBrandsFromAccess(val(form.accessId))>
                <cfset response.success = true>
                <cfset response.message = "Tüm markalar başarıyla silindi">
            </cfif>
        </cfcase>
        
        <!--- ==================== COMPANY CRUD ==================== --->
        
        <!--- CREATE: Erişime şirket ekle --->
        <cfcase value="addCompanyToAccess">
            <cfparam name="form.accessId" default="0">
            <cfparam name="form.companyId" default="0">
            
            <cfif val(form.accessId) eq 0 OR val(form.companyId) eq 0>
                <cfset response.message = "accessId ve companyId zorunludur">
            <cfelse>
                <cfset userAccessService.addCompanyToAccess(val(form.accessId), val(form.companyId))>
                <cfset response.success = true>
                <cfset response.message = "Şirket başarıyla eklendi">
            </cfif>
        </cfcase>
        
        <!--- CREATE: Toplu şirket ekle --->
        <cfcase value="addCompaniesToAccess">
            <cfparam name="form.accessId" default="0">
            <cfparam name="form.companyIds" default="">
            
            <cfif val(form.accessId) eq 0 OR len(trim(form.companyIds)) eq 0>
                <cfset response.message = "accessId ve companyIds zorunludur">
            <cfelse>
                <cfset userAccessService.addCompaniesToAccess(val(form.accessId), form.companyIds)>
                <cfset response.success = true>
                <cfset response.message = "Şirketler başarıyla eklendi">
            </cfif>
        </cfcase>
        
        <!--- READ: Erişime ait şirketleri getir --->
        <cfcase value="getCompaniesByAccessId">
            <cfparam name="form.accessId" default="0">
            
            <cfif val(form.accessId) eq 0>
                <cfset response.message = "accessId zorunludur">
            <cfelse>
                <cfset qResult = userAccessService.getCompaniesByAccessId(val(form.accessId))>
                <cfset response.success = true>
                <cfset response.message = "Şirketler başarıyla getirildi">
                <cfset response.data = queryToArray(qResult)>
            </cfif>
        </cfcase>
        
        <!--- DELETE: Erişimden şirket sil --->
        <cfcase value="removeCompanyFromAccess">
            <cfparam name="form.accessId" default="0">
            <cfparam name="form.companyId" default="0">
            
            <cfif val(form.accessId) eq 0 OR val(form.companyId) eq 0>
                <cfset response.message = "accessId ve companyId zorunludur">
            <cfelse>
                <cfset userAccessService.removeCompanyFromAccess(val(form.accessId), val(form.companyId))>
                <cfset response.success = true>
                <cfset response.message = "Şirket başarıyla silindi">
            </cfif>
        </cfcase>
        
        <!--- DELETE: Erişimdeki tüm şirketleri sil --->
        <cfcase value="removeAllCompaniesFromAccess">
            <cfparam name="form.accessId" default="0">
            
            <cfif val(form.accessId) eq 0>
                <cfset response.message = "accessId zorunludur">
            <cfelse>
                <cfset userAccessService.removeAllCompaniesFromAccess(val(form.accessId))>
                <cfset response.success = true>
                <cfset response.message = "Tüm şirketler başarıyla silindi">
            </cfif>
        </cfcase>
        
        <cfdefaultcase>
            <cfset response.message = "Geçersiz action parametresi">
        </cfdefaultcase>
        
    </cfswitch>
    
    <cfcatch type="any">
        <cfset response.success = false>
        <cfset response.message = "Hata: #cfcatch.message#">
        <cfset response.detail = cfcatch.detail>
    </cfcatch>
</cftry>

<!--- Query'i Array'e dönüştürme fonksiyonu --->
<cffunction name="queryToArray" access="private" returntype="array" output="false">
    <cfargument name="q" type="query" required="true">
    
    <cfset var result = arrayNew(1)>
    <cfset var cols = listToArray(arguments.q.columnList)>
    
    <cfloop query="arguments.q">
        <cfset var row = structNew()>
        <cfloop array="#cols#" index="col">
            <cfset row[col] = arguments.q[col][arguments.q.currentRow]>
        </cfloop>
        <cfset arrayAppend(result, row)>
    </cfloop>
    
    <cfreturn result>
</cffunction>

</cfsilent>
<cfcontent type="application/json" reset="true">
<cfoutput>#serializeJSON(response)#</cfoutput>
