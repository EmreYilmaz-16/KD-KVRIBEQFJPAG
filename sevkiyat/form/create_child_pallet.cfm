<cfparam name="url.parent_pallet_id" default="">

<cfscript>
function generatePalletCode() {
	var currentStamp = Now();
	var randomNumber = RandRange(0, 99999, "SHA1PRNG");
	var randomPart = Right("00000" & randomNumber, 5);
	return "PLT"
		& DateFormat(currentStamp, "dd")
		& DateFormat(currentStamp, "mm")
		& DateFormat(currentStamp, "yyyy")
		& TimeFormat(currentStamp, "HH")
		& TimeFormat(currentStamp, "mm")
		& randomPart;
}
</cfscript>

<cfset response = {
	success = false,
	message = "",
	data = {}
}>

<cfset recordEmp = 0>
<cfif StructKeyExists(session, "ep") AND StructKeyExists(session.ep, "userid")>
	<cfset recordEmp = Val(session.ep.userid)>
</cfif>

<cfset recordDate = Now()>
<cfset parentPalletId = Val(url.parent_pallet_id)>

<cfif parentPalletId EQ 0>
	<cfset response.message = "Gecersiz ana palet ID.">
<cfelse>
	<cftry>
		<!--- Ana paletin bilgilerini al --->
		<cfquery name="getParentPallet" datasource="#dsn3#">
			SELECT
				PALLET_CODE,
				PALLET_TYPE,
				COMPANY_ID,
				PALLET_WEIGHT
			FROM #dsn3#.SHIPPING_PALLETS_PBS
			WHERE ID = <cfqueryparam value="#parentPalletId#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfif getParentPallet.RecordCount EQ 0>
			<cfset response.message = "Ana palet bulunamadi.">
		<cfelse>
			<!--- Yeni yavru palet kodu üret --->
			<cfset childPalletCode = generatePalletCode()>
			<cfset maxAttempts = 5>
			<cfset attemptCount = 0>
			<cfset codeExists = true>

			<!--- Benzersiz kod garantisi --->
			<cfloop condition="codeExists AND attemptCount LT maxAttempts">
				<cfquery name="checkCode" datasource="#dsn3#">
					SELECT TOP 1 1
					FROM #dsn3#.SHIPPING_PALLETS_PBS
					WHERE UPPER(PALLET_CODE) = <cfqueryparam value="#UCase(childPalletCode)#" cfsqltype="cf_sql_nvarchar" maxlength="50">
				</cfquery>

				<cfif checkCode.RecordCount EQ 0>
					<cfset codeExists = false>
				<cfelse>
					<cfset childPalletCode = generatePalletCode()>
					<cfset attemptCount = attemptCount + 1>
				</cfif>
			</cfloop>

			<cfif codeExists>
				<cfset response.message = "Benzersiz palet kodu olusturulamadi. Lutfen tekrar deneyin.">
			<cfelse>
				<!--- Yavru paleti kaydet --->
				<cfquery name="insertChildPallet" datasource="#dsn3#">
					INSERT INTO #dsn3#.SHIPPING_PALLETS_PBS
						(PALLET_CODE, PALLET_TYPE, RECORD_DATE, RECORD_EMP, COMPANY_ID, PALLET_WEIGHT, MAIN_PALET_ID)
					VALUES
						(
							<cfqueryparam value="#childPalletCode#" cfsqltype="cf_sql_nvarchar" maxlength="50">,
							<cfqueryparam value="#Val(getParentPallet.PALLET_TYPE)#" cfsqltype="cf_sql_integer">,
							<cfqueryparam value="#recordDate#" cfsqltype="cf_sql_timestamp">,
							<cfqueryparam value="#recordEmp#" cfsqltype="cf_sql_integer">,
							<cfqueryparam value="#Val(getParentPallet.COMPANY_ID)#" cfsqltype="cf_sql_integer" null="#Val(getParentPallet.COMPANY_ID) EQ 0#">,
							<cfqueryparam value="#Val(getParentPallet.PALLET_WEIGHT)#" cfsqltype="cf_sql_decimal" null="#Val(getParentPallet.PALLET_WEIGHT) EQ 0#">,
							<cfqueryparam value="#parentPalletId#" cfsqltype="cf_sql_integer">
						);
					SELECT SCOPE_IDENTITY() AS NEW_ID
				</cfquery>

				<cfset response.success = true>
				<cfset response.message = "Yavru palet basariyla olusturuldu.">
				<cfset response.data = {
					childPalletId = insertChildPallet.NEW_ID,
					childPalletCode = childPalletCode,
					parentPalletCode = getParentPallet.PALLET_CODE
				}>
			</cfif>
		</cfif>

		<cfcatch type="any">
			<cfset response.message = "Kayit sirasinda hata olustu: " & cfcatch.message>
		</cfcatch>
	</cftry>
</cfif>

<cfcontent type="application/json" reset="true">
<cfoutput>#SerializeJSON(response)#</cfoutput>
