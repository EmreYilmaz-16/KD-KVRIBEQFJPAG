<cfcomponent displayname="BarcodeService" output="false" hint="TCP üzerinden PPL komutları gönderir.">

    <!--- Yapılandırma --->
    <cfset variables.printerIpAddress = "127.0.0.1">
    <cfset variables.printerPort      = 9100>
    <!--- CRLF: bir çok termal yazıcı CRLF sever --->
    <cfset variables.EOL = chr(13) & chr(10)>

    <!--- Ctor --->
    <cffunction name="init" access="public" output="false" returntype="any" hint="IP ve Port ile başlat">
        <cfargument name="printerIpAddress" type="string" required="true">
        <cfargument name="printerPort"      type="numeric" required="false" default="9100">

        <cfset variables.printerIpAddress = arguments.printerIpAddress>
        <cfset variables.printerPort      = arguments.printerPort>

        <cfreturn this>
    </cffunction>

    <!--- Barkod yazdır --->
    <cffunction name="printBarcode" access="public" output="false" returntype="boolean" hint="PPL ile barkod yazdırır.">
        <cfargument name="barcodeData" type="string"  required="true">
        <cfargument name="barcodeType" type="string"  required="false" default="Code128">
        <cfargument name="x"           type="numeric" required="false" default="10">
        <cfargument name="y"           type="numeric" required="false" default="10">
        <cfargument name="width"       type="numeric" required="false" default="2">
        <cfargument name="height"      type="numeric" required="false" default="80">
        <cfargument name="copies"      type="numeric" required="false" default="1">

        <cftry>
            <cfset var cmd = generatePPLBarcodeCommand(
                arguments.barcodeData, arguments.barcodeType,
                arguments.x, arguments.y, arguments.width, arguments.height, arguments.copies
            )>
            <cfreturn sendToPrinter(cmd)>

            <cfcatch type="any">
                <cfdump var="#cfcatch#">
            </cfcatch>
        </cftry>
    </cffunction>

    <!--- Metin yazdır --->
    <cffunction name="printText" access="public" output="false" returntype="boolean" hint="PPL ile metin yazdırır.">
        <cfargument name="text"     type="string"  required="true">
        <cfargument name="x"        type="numeric" required="false" default="10">
        <cfargument name="y"        type="numeric" required="false" default="100">
        <cfargument name="fontSize" type="numeric" required="false" default="3">
        <cfargument name="copies"   type="numeric" required="false" default="1">

        <cftry>
            <cfset var cmd = generatePPLTextCommand(arguments.text, arguments.x, arguments.y, arguments.fontSize, arguments.copies)>
            <cfreturn sendToPrinter(cmd)>

            <cfcatch type="any">
                <cfthrow message="Metin yazdırma hatası: #cfcatch.message#" detail="#cfcatch.detail#">
            </cfcatch>
        </cftry>
    </cffunction>

    <!--- Yazıcı status (port erişilebilir mi) --->
    <cffunction name="checkPrinterStatus" access="public" output="false" returntype="boolean" hint="TCP bağlantısı kurulabiliyor mu bakar.">
        <cfset var socket = "">
        <cftry>
            <cfset var InetSocketAddress = createObject("java","java.net.InetSocketAddress")>
            <cfset var Socket            = createObject("java","java.net.Socket")>
            <!--- 1500ms timeout örnek --->
            <cfset var addr = InetSocketAddress.init( variables.printerIpAddress, javacast("int", variables.printerPort) )>
            <cfset Socket.connect( addr, javacast("int",1500) )>
            <cfset var connected = Socket.isConnected()>
            <cfif Socket><!--- CF versions vary --->
                <cfset Socket.close()>
            </cfif>
            <cfreturn connected>
            <cfcatch type="any">
                <cfreturn false>
            </cfcatch>
        </cftry>
    </cffunction>

    <!--- PRIVATE: PPL Barkod Komutu --->
    <cffunction name="generatePPLBarcodeCommand" access="private" output="false" returntype="string">
        <cfargument name="barcodeData" type="string"  required="true">
        <cfargument name="barcodeType" type="string"  required="true">
        <cfargument name="x"           type="numeric" required="true">
        <cfargument name="y"           type="numeric" required="true">
        <cfargument name="width"       type="numeric" required="true">
        <cfargument name="height"      type="numeric" required="true">
        <cfargument name="copies"      type="numeric" required="true">

        <cfset var STX = chr(2)>
        <cfset var ETX = chr(3)>
        <cfset var sb  = "">

        <!--- Başlangıç --->
        <cfset sb &= STX & variables.EOL>
        <cfset sb &= "Q1" & variables.EOL>
        <cfset sb &= "q831" & variables.EOL>
        <cfset sb &= "D#arguments.copies#" & variables.EOL>

        <!--- Barkod tipi harfi: PPLB/PPLA varyasyonlarına göre harfler değişebilir. --->
        <cfset var t = uCase(arguments.barcodeType)>
        <cfif t EQ "CODE128">
            <cfset sb &= "B#arguments.x#,#arguments.y#,I,#arguments.width#,#arguments.height#,r,m2,s#arguments.barcodeData#;" & variables.EOL>
        <cfelseif t EQ "CODE39">
            <cfset sb &= "B#arguments.x#,#arguments.y#,H,#arguments.width#,#arguments.height#,r,m2,s#arguments.barcodeData#;" & variables.EOL>
        <cfelseif t EQ "EAN13">
            <cfset sb &= "B#arguments.x#,#arguments.y#,E,#arguments.width#,#arguments.height#,r,m2,s#arguments.barcodeData#;" & variables.EOL>
        <cfelseif t EQ "EAN8">
            <cfset sb &= "B#arguments.x#,#arguments.y#,F,#arguments.width#,#arguments.height#,r,m2,s#arguments.barcodeData#;" & variables.EOL>
        <cfelseif t EQ "UPCA">
            <cfset sb &= "B#arguments.x#,#arguments.y#,A,#arguments.width#,#arguments.height#,r,m2,s#arguments.barcodeData#;" & variables.EOL>
        <cfelse>
            <!--- Varsayılan Code128 --->
            <cfset sb &= "B#arguments.x#,#arguments.y#,I,#arguments.width#,#arguments.height#,r,m2,s#arguments.barcodeData#;" & variables.EOL>
        </cfif>

        <!--- Yazdır & Bitiş --->
        <cfset sb &= "P1" & variables.EOL>
        <cfset sb &= ETX & variables.EOL>

        <cfreturn sb>
    </cffunction>

    <!--- PRIVATE: PPL Metin Komutu --->
    <cffunction name="generatePPLTextCommand" access="private" output="false" returntype="string">
        <cfargument name="text"     type="string"  required="true">
        <cfargument name="x"        type="numeric" required="true">
        <cfargument name="y"        type="numeric" required="true">
        <cfargument name="fontSize" type="numeric" required="true">
        <cfargument name="copies"   type="numeric" required="true">

        <cfset var STX = chr(2)>
        <cfset var ETX = chr(3)>
        <cfset var sb  = "">

        <!--- Başlangıç --->
        <cfset sb &= STX & variables.EOL>
        <cfset sb &= "Q1" & variables.EOL>
        <cfset sb &= "q831" & variables.EOL>
        <cfset sb &= "D#arguments.copies#" & variables.EOL>

        <!--- Not: PPL’de T komutu yazıcı/versiyona göre değişebilir. Bu örnekte T x,y,font,rot,bold,italic,reverse,N,text; varsayıldı. --->
        <!--- Metinde virgül/noktalı virgül sorun çıkarırsa temizleyin --->
        <cfset var safeText = replace(replace(arguments.text,";"," ","all"), chr(10), " ", "all")>
        <cfset safeText = replace(safeText, chr(13), " ", "all")>

        <cfset sb &= "T#arguments.x#,#arguments.y#,#arguments.fontSize#,0,0,0,N,#safeText#;" & variables.EOL>

        <!--- Yazdır & Bitiş --->
        <cfset sb &= "P1" & variables.EOL>
        <cfset sb &= ETX & variables.EOL>

        <cfreturn sb>
    </cffunction>

    <!--- PRIVATE: TCP gönder --->
    <cffunction name="sendToPrinter" access="private" output="false" returntype="boolean" hint="Komutu TCP ile yazar.">
        <cfargument name="command" type="string" required="true">
        <cfset var Socket        = "">
        <cfset var OutputStream  = "">
        <cfset var bytes         = "">
        <cftry>
            <!--- Java Socket aç --->
            <cfset Socket = createObject("java","java.net.Socket").init( variables.printerIpAddress, javacast("int", variables.printerPort ) )>
            <cfset OutputStream = Socket.getOutputStream()>

            <!--- US-ASCII byte dizisi oluştur --->
            <cfset var StringClass = createObject("java","java.lang.String").init( arguments.command )>
            <cfset bytes = StringClass.getBytes( javacast("string","US-ASCII") )>

            <!--- Yaz & flush --->
            <cfset OutputStream.write( bytes )>
            <cfset OutputStream.flush()>

            <!--- Kapat --->
            <cfif OutputStream><!--- bazı CF sürümleri null check ister --->
                <cfset OutputStream.close()>
            </cfif>
            <cfif Socket>
                <cfset Socket.close()>
            </cfif>

            <cfreturn true>

            <cfcatch type="any">
                <!--- Bağlantı/kodlama problemi vb. --->
                <cfif OutputStream>
                    <cfset OutputStream.close()>
                </cfif>
                <cfif Socket>
                    <cfset Socket.close()>
                </cfif>
                <cfthrow message="Yazıcı bağlantı hatası: #cfcatch.message#" detail="#cfcatch.detail#">
            </cfcatch>
        </cftry>
    </cffunction>

</cfcomponent>
