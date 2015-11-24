<cfcomponent>
	
	<cfset this.Program		= "dnscmd" />
	<cfset this.Server		= "localhost" />
	<cfset this.Domain		= "locushost.com" />
	<cfset this.ExcludeSubs	= "*,@,Returned,stats,www,command" />
	<cfset this.Timeout		= "5" />
	<cfset this.Commands 	= StructNew() />
	
	<cfset this.Commands['Domains']	= "/EnumZones" />
	<cfset this.Commands['Add'] 	= "/RecordAdd" />
	<cfset this.Commands['Delete']  = "/RecordDelete" />
	<cfset this.Commands['List']    = "/EnumRecords" />
	<cfset this.Commands['Reload']  = "/ZoneReload" />


	<cffunction name="Init">
		<cfargument name="program" required="true" />
		<cfargument name="server" required="true" />
		<cfargument name="domain" required="true" />
		
		<cfset SetProgram(arguments.program) />
		<cfset SetServer(arguments.server) />
		<cfset SetDomain(arguments.domain) />
	</cffunction>
	
	
	<cffunction name="SetProgram">
		<cfargument name="program" required="true" />
		
		<cfset this.Program = arguments.program />
	</cffunction>
	
	<cffunction name="SetServer">
		<cfargument name="server" required="true" />
		
		<cfset this.Server = arguments.server />
	</cffunction>
	
	<cffunction name="SetDomain">
		<cfargument name="domain" required="true" />
		
		<cfset this.Domain = arguments.domain />
	</cffunction>
	
	<cffunction name="SetCommand">
		<cfargument name="command" required="true" />
		<cfargument name="value" required="true" />
		
		<cfset this.Commands[arguments.command] = arguments.value />
	</cffunction>
	
	<cffunction name="SetExcludeSubs">
		<cfargument name="subs" required="true" />
		
		<cfset this.ExcludeSubs = arguments.subs />
	</cffunction>
	

	<cffunction name="Domains">
		<cfset var dnsTxt = "" /> 
		<cfset var parts = "" />
		<cfset var ret = arrayNew(1) />
		<cfset var foundStart = false />
		<cfset var foundEnd = false />
		
		<cftry>
			<cfexecute name="dnscmd" arguments="#this.Server# #this.Commands.Domains#" variable="dnsTxt" timeout="#this.Timeout#" />
			
			<cfloop index="dns" list="#dnsTxt#" delimiters="#Chr(13)##Chr(10)#">
				<cfif Len(Trim(dns))>
					<cfset parts = ListToArray(trim(dns), " ") />

					<cfif parts[1] EQ ".">
						<cfset foundStart = true />
					</cfif>
					
					<cfif foundStart AND parts[1] NEQ "." AND parts[1] NEQ "Command">
						<cfset ArrayAppend(ret, parts[1]) />
					</cfif>
				</cfif>
			</cfloop>
			
			<cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn ret />
	</cffunction>
	

	<cffunction name="List">
		<cfargument name="type" required="true" />
		
		<cfset var dnsTxt = "" /> 
		<cfset var parts = "" /> 
		<cfset var ret = arrayNew(1) />
		
		<cftry>
			<cfexecute name="dnscmd" arguments="#this.Server# #this.Commands.List# #this.Domain# . /Type #arguments.type#" variable="dnsTxt" timeout="#this.Timeout#" />
			
			<cfloop index="dns" list="#dnsTxt#" delimiters="#Chr(13)##Chr(10)#">
				<cfset parts = ListToArray(dns, " ") />
				<cfif NOT LIstFindNoCase(this.ExcludeSubs, parts[1])>
					<cfset ArrayAppend(ret, parts[1]) />
				</cfif>	
			</cfloop>
			
			<cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn ret />
	</cffunction>
	

	<cffunction name="Contains">
		<cfargument name="sub" required="true" />
		
		<cfset var ret = false /> 
		
		<cftry>
			<cfif ListFindNoCase(ArrayToList(List()), arguments.sub)>
				<cfset ret = true />
			</cfif>
			
			<cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn ret />
	</cffunction>
	

	<cffunction name="Add">
		<cfargument name="sub" required="true" />
		<cfargument name="type" required="true" />
		<cfargument name="ipaddress" required="true" />
		
		<cfset var dnsTxt = "" /> 
		
		<cftry>
			<cfexecute name="dnscmd" arguments="#this.Server# #this.Commands.Add# #this.Domain# #arguments.sub# #arguments.type# #arguments.ipaddress#" variable="dnsTxt" timeout="#this.Timeout#" />
			
			<cfcatch>
				<cfreturn false />
			</cfcatch>
		</cftry>
		
		<cfif FindNoCase("success", dnsTxt)>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
	

	<cffunction name="Reload">
		<cfset var dnsTxt = "" /> 
		
		<cftry>
			<cfexecute name="dnscmd" arguments="#this.Server# #this.Commands.Reload# #this.Domain# " variable="dnsTxt" timeout="#this.Timeout#" />
			
			<cfcatch>
				<cfreturn false />
			</cfcatch>
		</cftry>
		
		<cfif FindNoCase("success", dnsTxt)>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
	

	<cffunction name="Delete">
		<cfargument name="sub" required="true" />
		<cfargument name="type" required="true" />
		
		<cfset var dnsTxt = "" /> 
		
		<cftry>
			<cfif NOT ListFindNoCase(this.ExcludeSubs, arguments.sub)>
				<cfexecute name="dnscmd" arguments="#this.Server# #this.Commands.Delete# #this.Domain# #arguments.sub# #arguments.type# /f" variable="dnsTxt" timeout="#this.Timeout#" />
			<cfelse>
				<cfreturn false />
			</cfif>
			
			<cfcatch>
				<cfreturn false />
			</cfcatch>
		</cftry>
		
		<cfif FindNoCase("success", dnsTxt)>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
</cfcomponent>
