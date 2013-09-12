<cfcomponent extends="mxunit.framework.TestCase">

	<cffunction name="beforeTests">
		<cfscript>
			variables.apiUrl = "http://127.0.0.1:8500/CFIDE/administrator/configmanager/api/config.cfm";
			variables.username = "admin";
			variables.password = "vagrant";
		</cfscript>
	</cffunction>

	<cffunction name="setup">
		<cfset deleteTestDatasource("test_mssql") />
	</cffunction>

	<cffunction name="teardown">
		<cfset deleteTestDatasource("test_mssql") />
	</cffunction>

	<cffunction name="testAuthenticaitonNoCredentials">
		<cfset var apiResult = "" />
		<cfhttp url="#variables.apiUrl#" method="get" result="apiResult" />
		<cfset assertEquals("401 UNAUTHORIZED",apiResult.statusCode) />
	</cffunction>

	<cffunction name="testAuthenticaitonWithCredentials">
		<cfset var apiResult = "" />
		<cfhttp url="#variables.apiUrl#" method="get" username="#variables.username#" password="#variables.password#" result="apiResult" />
		<cfset assertEquals("400 BAD REQUEST",apiResult.statusCode) />
	</cffunction>

	<cffunction name="testApiCallWithValidApplicationJSONContentType">
		<cfset var apiResult = "" />

		<!--- first set the config to a known state --->
		<cfset setCacheProperty("SaveClassFiles",false) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult">
			<cfhttpparam type="header" name="Content-Type" value="application/json" />
			<cfhttpparam type="body" value="{ ""runtime"" : { ""cacheProperty"" : [ {""propertyName"" : ""SaveClassFiles"", ""propertyValue"" : true } ] } }" />
		</cfhttp>

		<cfset var expected = true />
		<!--- get the current config --->
		<cfset var actual = getCacheProperty("SaveClassFiles") />

		<cfset assertEquals("200 SUCCESS",apiResult.statusCode) />
		<cfset assertEquals(expected,actual,"Expected SaveClassFiles to be true.") />

	</cffunction>

	<cffunction name="testApiCallWithValidTextJSONContentType">
		<cfset var apiResult = "" />

		<!--- first set the config to a known state --->
		<cfset setCacheProperty("SaveClassFiles",false) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="{ ""runtime"" : { ""cacheProperty"" : [ {""propertyName"" : ""SaveClassFiles"", ""propertyValue"" : true } ] } }" />
		</cfhttp>

		<cfset var expected = true />
		<!--- get the current config --->
		<cfset var actual = getCacheProperty("SaveClassFiles") />

		<cfset assertEquals("200 SUCCESS",apiResult.statusCode) />
		<cfset assertEquals(expected,actual,"Expected SaveClassFiles to be true.") />

	</cffunction>

	<cffunction name="testApiCallWithInValidJSON">
		<cfset var apiResult = "" />
		
		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult">
			<cfhttpparam type="header" name="Content-Type" value="application/json" />
			<cfhttpparam type="body" value="{ ""runtime"" : { ""cacheProperty"" : [ {""propertyName"" : ""SaveClassFiles"", ""propertyValue"" : true } } }" />
		</cfhttp>

		<cfset assertEquals("400 BAD REQUEST",apiResult.statusCode) />

	</cffunction>


	<!--- MSSQL --->


	<cffunction name="testCreateMSSQL">
		<cfset var apiResult = "" />

		<cfset var jsonStruct = { 
					datasource = { 
						MSSql = [ 
						   {
							 name = "test_mssql", 
							 host = "sql.example.com",
							 database = "test",
							 username = "test",
							 password = "test",
							 sendStringParametersAsUnicode = true,
							 disable_clob = false,
							 disable_blob = false
						   }
						]
					}
				} />
		<cfset var jsonData = SerializeJSON(jsonStruct) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData#" />
		</cfhttp>

		<cfset assertEquals("200 SUCCESS",apiResult.statusCode) />

	</cffunction>

	<cffunction name="testUpdateMSSQLNoChange">
		<cfset var apiResult1 = "" />
		<cfset var apiResult2 = "" />

		<cfset var jsonStruct = { 
					datasource = { 
						MSSql = [ 
						   {
							 name = "test_mssql", 
							 host = "sql.example.com",
							 database = "test",
							 username = "test",
							 password = "test",
							 sendStringParametersAsUnicode = true,
							 disable_clob = false,
							 disable_blob = false
						   }
						]
					}
				} />
		<cfset var jsonData = SerializeJSON(jsonStruct) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult1">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData#" />
		</cfhttp>

		<cfset assertEquals("200 SUCCESS",apiResult1.statusCode) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult2">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData#" />
		</cfhttp>

		
		<cfset assertEquals("200 SUCCESS",apiResult2.statusCode) />

	</cffunction>

	<cffunction name="testUpdateMSSQLNWithChange">
		<cfset var apiResult1 = "" />
		<cfset var apiResult2 = "" />

		<cfset var jsonStruct1 = { 
					datasource = { 
						MSSql = [ 
						   {
							 name = "test_mssql", 
							 host = "sql.example.com",
							 database = "test",
							 username = "test",
							 password = "test",
							 sendStringParametersAsUnicode = true,
							 disable_clob = false,
							 disable_blob = false
						   }
						]
					}
				} />
		<cfset var jsonData1 = SerializeJSON(jsonStruct1) />

		<cfset var jsonStruct2 = { 
					datasource = { 
						MSSql = [ 
						   {
							 name = "test_mssql", 
							 host = "sql.example.com",
							 database = "test",
							 username = "test",
							 password = "test",
							 sendStringParametersAsUnicode = true,
							 disable_clob = true,
							 disable_blob = true
						   }
						]
					}
				} />
		<cfset var jsonData2 = SerializeJSON(jsonStruct2) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult1">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData1#" />
		</cfhttp>

		<cfset assertEquals("200 SUCCESS",apiResult1.statusCode) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult2">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData2#" />
		</cfhttp>

		<cfset assertEquals("200 SUCCESS",apiResult2.statusCode) />

	</cffunction>

	<cffunction name="testUpdateMSSQLNWithPasswordChange">
		<cfset var apiResult1 = "" />
		<cfset var apiResult2 = "" />

		<cfset var jsonStruct1 = { 
					datasource = { 
						MSSql = [ 
						   {
							 name = "test_mssql", 
							 host = "sql.example.com",
							 database = "test",
							 username = "test",
							 password = "test",
							 sendStringParametersAsUnicode = true,
							 disable_clob = false,
							 disable_blob = false
						   }
						]
					}
				} />
		<cfset var jsonData1 = SerializeJSON(jsonStruct1) />

		<cfset var jsonStruct2 = { 
					datasource = { 
						MSSql = [ 
						   {
							 name = "test_mssql", 
							 host = "sql.example.com",
							 database = "test",
							 username = "test",
							 password = "test2",
							 sendStringParametersAsUnicode = true,
							 disable_clob = false,
							 disable_blob = false
						   }
						]
					}
				} />
		<cfset var jsonData2 = SerializeJSON(jsonStruct2) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult1">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData1#" />
		</cfhttp>

		<cfset assertEquals("200 SUCCESS",apiResult1.statusCode) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult2">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData2#" />
		</cfhttp>

		<cfset assertEquals("200 SUCCESS",apiResult2.statusCode) />

	</cffunction>


	<!--- MySQL5 --->


	<cffunction name="testCreateMySQL5">
		<cfset var apiResult = "" />

		<cfset var jsonStruct = { 
					datasource = { 
						MySQL5 = [ 
						   {
							 name = "test_mysql5", 
							 host = "sql.example.com",
							 database = "test",
							 username = "test",
							 password = "test",
							 disable_clob = false,
							 disable_blob = false
						   }
						]
					}
				} />
		<cfset var jsonData = SerializeJSON(jsonStruct) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData#" />
		</cfhttp>

		<cfset assertEquals("200 SUCCESS",apiResult.statusCode) />

	</cffunction>

	<cffunction name="testUpdateMySQL5NoChange">
		<cfset var apiResult1 = "" />
		<cfset var apiResult2 = "" />

		<cfset var jsonStruct = { 
					datasource = { 
						MySQL5 = [ 
						   {
							 name = "test_mysql5", 
							 host = "sql.example.com",
							 database = "test",
							 username = "test",
							 password = "test",
							 disable_clob = false,
							 disable_blob = false
						   }
						]
					}
				} />
		<cfset var jsonData = SerializeJSON(jsonStruct) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult1">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData#" />
		</cfhttp>

		<cfset assertEquals("200 SUCCESS",apiResult1.statusCode) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult2">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData#" />
		</cfhttp>

		
		<cfset assertEquals("200 SUCCESS",apiResult2.statusCode) />

	</cffunction>

	<cffunction name="testUpdateMySQL5NWithChange">
		<cfset var apiResult1 = "" />
		<cfset var apiResult2 = "" />

		<cfset var jsonStruct1 = { 
					datasource = { 
						MySQL5 = [ 
						   {
							 name = "test_mysql5", 
							 host = "sql.example.com",
							 database = "test",
							 username = "test",
							 password = "test",
							 disable_clob = false,
							 disable_blob = false
						   }
						]
					}
				} />
		<cfset var jsonData1 = SerializeJSON(jsonStruct1) />

		<cfset var jsonStruct2 = { 
					datasource = { 
						MySQL5 = [ 
						   {
							 name = "test_mysql5", 
							 host = "sql.example.com",
							 database = "test",
							 username = "test",
							 password = "test",
							 disable_clob = true,
							 disable_blob = true
						   }
						]
					}
				} />
		<cfset var jsonData2 = SerializeJSON(jsonStruct2) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult1">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData1#" />
		</cfhttp>

		<cfset assertEquals("200 SUCCESS",apiResult1.statusCode) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult2">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData2#" />
		</cfhttp>

		<cfset assertEquals("200 SUCCESS",apiResult2.statusCode) />

	</cffunction>

	<cffunction name="testUpdateMySQL5NWithPasswordChange">
		<cfset var apiResult1 = "" />
		<cfset var apiResult2 = "" />

		<cfset var jsonStruct1 = { 
					datasource = { 
						MySQL5 = [ 
						   {
							 name = "test_mysql5", 
							 host = "sql.example.com",
							 database = "test",
							 username = "test",
							 password = "test",
							 disable_clob = false,
							 disable_blob = false
						   }
						]
					}
				} />
		<cfset var jsonData1 = SerializeJSON(jsonStruct1) />

		<cfset var jsonStruct2 = { 
					datasource = { 
						MySQL5 = [ 
						   {
							 name = "test_mysql5", 
							 host = "sql.example.com",
							 database = "test",
							 username = "test",
							 password = "test2",
							 disable_clob = false,
							 disable_blob = false
						   }
						]
					}
				} />
		<cfset var jsonData2 = SerializeJSON(jsonStruct2) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult1">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData1#" />
		</cfhttp>

		<cfset assertEquals("200 SUCCESS",apiResult1.statusCode) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult2">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData2#" />
		</cfhttp>

		<cfset assertEquals("200 SUCCESS",apiResult2.statusCode) />

	</cffunction>


	<!--- MySQL_DD --->


	<cffunction name="testCreateMySQL_DD">
		<cfset var apiResult = "" />

		<cfset var jsonStruct = { 
					datasource = { 
						MySQL_DD = [ 
						   {
							 name = "test_mysql_dd", 
							 host = "sql.example.com",
							 database = "test",
							 username = "test",
							 password = "test",
							 disable_clob = false,
							 disable_blob = false
						   }
						]
					}
				} />
		<cfset var jsonData = SerializeJSON(jsonStruct) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData#" />
		</cfhttp>

		<cfset assertEquals("200 SUCCESS",apiResult.statusCode) />

	</cffunction>

	<cffunction name="testUpdateMySQL_DDNoChange">
		<cfset var apiResult1 = "" />
		<cfset var apiResult2 = "" />

		<cfset var jsonStruct = { 
					datasource = { 
						MySQL_DD = [ 
						   {
							 name = "test_mysql_dd", 
							 host = "sql.example.com",
							 database = "test",
							 username = "test",
							 password = "test",
							 disable_clob = false,
							 disable_blob = false
						   }
						]
					}
				} />
		<cfset var jsonData = SerializeJSON(jsonStruct) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult1">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData#" />
		</cfhttp>

		<cfset assertEquals("200 SUCCESS",apiResult1.statusCode) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult2">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData#" />
		</cfhttp>

		
		<cfset assertEquals("200 SUCCESS",apiResult2.statusCode) />

	</cffunction>

	<cffunction name="testUpdateMySQL_DDNWithChange">
		<cfset var apiResult1 = "" />
		<cfset var apiResult2 = "" />

		<cfset var jsonStruct1 = { 
					datasource = { 
						MySQL_DD = [ 
						   {
							 name = "test_mysql_dd", 
							 host = "sql.example.com",
							 database = "test",
							 username = "test",
							 password = "test",
							 disable_clob = false,
							 disable_blob = false
						   }
						]
					}
				} />
		<cfset var jsonData1 = SerializeJSON(jsonStruct1) />

		<cfset var jsonStruct2 = { 
					datasource = { 
						MySQL_DD = [ 
						   {
							 name = "test_mysql_dd", 
							 host = "sql.example.com",
							 database = "test",
							 username = "test",
							 password = "test",
							 disable_clob = true,
							 disable_blob = true
						   }
						]
					}
				} />
		<cfset var jsonData2 = SerializeJSON(jsonStruct2) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult1">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData1#" />
		</cfhttp>

		<cfset assertEquals("200 SUCCESS",apiResult1.statusCode) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult2">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData2#" />
		</cfhttp>

		<cfset assertEquals("200 SUCCESS",apiResult2.statusCode) />

	</cffunction>

	<cffunction name="testUpdateMySQL_DDNWithPasswordChange">
		<cfset var apiResult1 = "" />
		<cfset var apiResult2 = "" />

		<cfset var jsonStruct1 = { 
					datasource = { 
						MySQL_DD = [ 
						   {
							 name = "test_mysql_dd", 
							 host = "sql.example.com",
							 database = "test",
							 username = "test",
							 password = "test",
							 disable_clob = false,
							 disable_blob = false
						   }
						]
					}
				} />
		<cfset var jsonData1 = SerializeJSON(jsonStruct1) />

		<cfset var jsonStruct2 = { 
					datasource = { 
						MySQL_DD = [ 
						   {
							 name = "test_mysql_dd", 
							 host = "sql.example.com",
							 database = "test",
							 username = "test",
							 password = "test2",
							 disable_clob = false,
							 disable_blob = false
						   }
						]
					}
				} />
		<cfset var jsonData2 = SerializeJSON(jsonStruct2) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult1">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData1#" />
		</cfhttp>

		<cfset assertEquals("200 SUCCESS",apiResult1.statusCode) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult2">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData2#" />
		</cfhttp>

		<cfset assertEquals("200 SUCCESS",apiResult2.statusCode) />

	</cffunction>


	<!--- Oracle --->


	<cffunction name="testCreateOracle">
		<cfset var apiResult = "" />

		<cfset var jsonStruct = { 
					datasource = { 
						Oracle = [ 
						   {
							 name = "test_oracle", 
							 host = "sql.example.com",
							 database = "test",
							 username = "test",
							 password = "test",
							 sid = "ORCL",
							 disable_clob = false,
							 disable_blob = false
						   }
						]
					}
				} />
		<cfset var jsonData = SerializeJSON(jsonStruct) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData#" />
		</cfhttp>

		<cfset assertEquals("200 SUCCESS",apiResult.statusCode) />

	</cffunction>

	<cffunction name="testUpdateOracleNoChange">
		<cfset var apiResult1 = "" />
		<cfset var apiResult2 = "" />

		<cfset var jsonStruct = { 
					datasource = { 
						Oracle = [ 
						   {
							 name = "test_oracle", 
							 host = "sql.example.com",
							 database = "test",
							 username = "test",
							 password = "test",
							 sid = "ORCL",
							 disable_clob = false,
							 disable_blob = false
						   }
						]
					}
				} />
		<cfset var jsonData = SerializeJSON(jsonStruct) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult1">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData#" />
		</cfhttp>

		<cfset assertEquals("200 SUCCESS",apiResult1.statusCode) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult2">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData#" />
		</cfhttp>

		
		<cfset assertEquals("200 SUCCESS",apiResult2.statusCode) />

	</cffunction>

	<cffunction name="testUpdateOracleNWithChange">
		<cfset var apiResult1 = "" />
		<cfset var apiResult2 = "" />

		<cfset var jsonStruct1 = { 
					datasource = { 
						Oracle = [ 
						   {
							 name = "test_oracle", 
							 host = "sql.example.com",
							 database = "test",
							 username = "test",
							 password = "test",
							 sid = "ORCL",
							 disable_clob = false,
							 disable_blob = false
						   }
						]
					}
				} />
		<cfset var jsonData1 = SerializeJSON(jsonStruct1) />

		<cfset var jsonStruct2 = { 
					datasource = { 
						Oracle = [ 
						   {
							 name = "test_oracle", 
							 host = "sql.example.com",
							 database = "test",
							 username = "test",
							 password = "test",
							 sid = "ORCL",
							 disable_clob = true,
							 disable_blob = true
						   }
						]
					}
				} />
		<cfset var jsonData2 = SerializeJSON(jsonStruct2) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult1">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData1#" />
		</cfhttp>

		<cfset assertEquals("200 SUCCESS",apiResult1.statusCode) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult2">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData2#" />
		</cfhttp>

		<cfset assertEquals("200 SUCCESS",apiResult2.statusCode) />

	</cffunction>

	<cffunction name="testUpdateOracleNWithPasswordChange">
		<cfset var apiResult1 = "" />
		<cfset var apiResult2 = "" />

		<cfset var jsonStruct1 = { 
					datasource = { 
						Oracle = [ 
						   {
							 name = "test_oracle", 
							 host = "sql.example.com",
							 database = "test",
							 username = "test",
							 password = "test",
							 sid = "ORCL",
							 disable_clob = false,
							 disable_blob = false
						   }
						]
					}
				} />
		<cfset var jsonData1 = SerializeJSON(jsonStruct1) />

		<cfset var jsonStruct2 = { 
					datasource = { 
						Oracle = [ 
						   {
							 name = "test_oracle", 
							 host = "sql.example.com",
							 database = "test",
							 username = "test",
							 password = "test2",
							 sid = "ORCL",
							 disable_clob = false,
							 disable_blob = false
						   }
						]
					}
				} />
		<cfset var jsonData2 = SerializeJSON(jsonStruct2) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult1">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData1#" />
		</cfhttp>

		<cfset assertEquals("200 SUCCESS",apiResult1.statusCode) />

		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult2">
			<cfhttpparam type="header" name="Content-Type" value="text/json" />
			<cfhttpparam type="body" value="#jsonData2#" />
		</cfhttp>

		<cfset assertEquals("200 SUCCESS",apiResult2.statusCode) />

	</cffunction>




	<cffunction name="testApiCallWithMultipleSettings">
		<cfset var apiResult = "" />		
		<cfset var mappingPath = GetDirectoryFromPath(ExpandPath('.')) />
		<cfset var jsonStruct = {
			runtime = {
				cacheProperty = [
						{propertyName = "TrustedCache", propertyValue = false },
						{propertyName = "InRequestTemplateCache", propertyValue = false },
						{propertyName = "ComponentCache", propertyValue = false },
						{propertyName = "SaveClassFiles", propertyValue = false },
						{propertyName = "CacheRealPath", propertyValue = false }
					]	
				},
			extensions = {
				mapping = [
						{mapName = "/ConfigManagerTestMapping", mapPath = mappingPath }
					]
				}
			} />
		<cfset var jsonData = SerializeJSON(jsonStruct) />
	
		<cfhttp url="#variables.apiUrl#" method="post" username="#variables.username#" password="#variables.password#" result="apiResult">
			<cfhttpparam type="header" name="Content-Type" value="application/json" />
			<cfhttpparam type="body" value="#jsonData#" />
		</cfhttp>

		<cfset assertEquals("200 SUCCESS",apiResult.statusCode) />

		<cfset var expected = false />
		<cfset var actual = "" />

		<!--- get the current config --->
		<cfset actual = getCacheProperty("TrustedCache") />
		<cfset assertEquals(expected,actual,"Expected TrustedCache to be false.") />
		<cfset actual = getCacheProperty("InRequestTemplateCache") />
		<cfset assertEquals(expected,actual,"Expected InRequestTemplateCache to be false.") />
		<cfset actual = getCacheProperty("ComponentCache") />
		<cfset assertEquals(expected,actual,"Expected ComponentCache to be false.") />
		<cfset actual = getCacheProperty("SaveClassFiles") />
		<cfset assertEquals(expected,actual,"Expected SaveClassFiles to be false.") />
		<cfset actual = getCacheProperty("CacheRealPath") />
		<cfset assertEquals(expected,actual,"Expected CacheRealPath to be false.") />
		<cfset var mappings = getMappings() />
		<cfset assertTrue(StructKeyExists(mappings,"/ConfigManagerTestMapping"),"Expected /ConfigManagerTestMapping to exists.") />
		<cfset assertEquals(mappingPath,mappings['/ConfigManagerTestMapping'],"Expected /ConfigManagerTestMapping to point to #mappingPath#.") />

	</cffunction>

	<cffunction name="setCacheProperty" access="private">
		<cfargument name="propertyName" />
		<cfargument name="propertyValue" />

		<cfset var admin = CreateObject("component","cfide.adminapi.administrator") />
		<cfset admin.login(adminUserId=variables.username,adminPassword=variables.password) />
		<cfset var runtime = createObject("component","cfide.adminapi.runtime") />
		<cfset runtime.setCacheProperty(argumentcollection=arguments) />

	</cffunction>

	<cffunction name="getCacheProperty" access="private">
		<cfargument name="propertyName" />

		<cfset var admin = CreateObject("component","cfide.adminapi.administrator") />
		<cfset admin.login(adminUserId=variables.username,adminPassword=variables.password) />
		<cfset var runtime = createObject("component","cfide.adminapi.runtime") />
		<cfreturn runtime.getCacheProperty(argumentcollection=arguments) />

	</cffunction>


	<cffunction name="getMappings" access="private">
		<cfargument name="propertyName" />

		<cfset var admin = CreateObject("component","cfide.adminapi.administrator") />
		<cfset admin.login(adminUserId=variables.username,adminPassword=variables.password) />
		<cfset var extensions = createObject("component","cfide.adminapi.extensions") />
		<cfreturn extensions.getMappings() />

	</cffunction>

	<cffunction name="deleteTestDatasource" access="private">
		<cfargument name="dsn" />

		<cfset var admin = CreateObject("component","cfide.adminapi.administrator") />
		<cfset admin.login(adminUserId=variables.username,adminPassword=variables.password) />
		<cfset var datasource = createObject("component","cfide.adminapi.datasource") />
		<cftry>
			<cfreturn datasource.deleteDatasource(dsn) />
			<cfcatch type="any" />
		</cftry>		

	</cffunction>

</cfcomponent>