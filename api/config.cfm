<cfsilent>

<cflock name="CF_CONFIGMANAGER_CONFIG" type="exclusive" timeout="60" throwontimeout="true">
<cfset verb = cgi.request_method />
<cfloop collection="#jsonData#" item="objName">
    <cftry>
        <!--- for each key in the adminSettings struct, try to initilize the coresponding admin api component --->

        <cfif fileExists(expandPath("./idempotent/#lcase(objName)#.cfc"))>
            <cfset adminComponent = createObject("component","idempotent.#objName#") />
        <cfelse>
            <cfset adminComponent = createObject("component","CFIDE.adminapi.#objName#") />
        </cfif>
        
        <cfset adminObj = jsonData[objName] />
        <!---
        for each key in the admin api component struct, try to invoke the corresponding setter method
        note: keys correspond to setter methods, without the "set" prefix so
        datasource.mySQL == createObject("component","cfide.adminapi.datasource).setMySQL()
        --->
        <cfloop collection="#adminObj#" item="setter">
            <cftry>

                <cfset invocations = adminObj[setter] />

                <cfloop array="#invocations#" index="args">
                    <cfswitch expression="#verb#">
						<cfcase value="post">					
							<cfinvoke component="#adminComponent#" method="set#setter#" argumentCollection="#args#" />
							<cfset logInfo("Invoked #objName#.set#setter#. Arguments: #serializeJSON(args)#.") />
						</cfcase>
						<cfcase value="delete">
							<cfif StructKeyExists(#adminComponent#, "delete") >
								<cfinvoke component="#adminComponent#" method="delete" argumentCollection="#args#" />
								<cfset logInfo("Invoked #objName#.delete. Arguments: #serializeJSON(args)#.") />
							<cfelse>
								<cfset logError("Error invoking #objName#.delete. Method does not have a delete command") />
								<cfheader statuscode="500" statustext="Error invoking #objName#.delete. Method does not have a delete command" />
								<cfabort />
							</cfif>
						</cfcase>
					</cfswitch>
                    
                </cfloop>

                <cfcatch type="any">
                    <cfset logError("Error invoking #objName#.set#setter#. Error Message: #cfcatch.message#. Arguments: #serializeJSON(args)#.") />
                    <cfheader statuscode="500" statustext="Error: #cfcatch.message#" />
                    <cfabort />
                </cfcatch>

            </cftry>

        </cfloop>

        <cfcatch type="any">
            <cfset logError("Error creating #objName#. #cfcatch.message#") />
            <cfheader statuscode="500" statustext="Error: #cfcatch.message#" />
            <cfabort />
        </cfcatch>

    </cftry>

</cfloop>

</cflock>

<cfheader statuscode="200" statustext="Success" />

</cfsilent>