<cfquery name="getNextId" datasource="#dsn3#">
    SELECT ISNULL(MAX(KARMA_EMIR_ID), 0) + 1 AS NEXT_ID
    FROM KARMA_EMIR WITH (TABLOCKX)
</cfquery>

<cfset nextId = getNextId.NEXT_ID>
<cfset currentDate = Now()>
<cfset emirNo = "UPE-" & Year(currentDate) & "-" & NumberFormat(Month(currentDate), "00") & "-" & NumberFormat(Day(currentDate), "00") & "-" & nextId>

<cfquery name="ins" datasource="#dsn3#">
    INSERT INTO KARMA_EMIR(PRODUCT_ID, AMOUNT, RECORD_DATE, RECORD_EMP, CURRENT_STATUS, EMIR_NO)
    VALUES(
        <cfqueryparam value="#URL.PRODUCT_ID#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#URL.AMOUNT#" cfsqltype="cf_sql_integer">,
        GETDATE(),
        <cfqueryparam value="#session.ep.userid#" cfsqltype="cf_sql_integer">,
        1,
        <cfqueryparam value="#emirNo#" cfsqltype="cf_sql_varchar">
    )
</cfquery>
