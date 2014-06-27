<cfparam name="args.userRecord" type="query" />

<cfoutput>
	<cfif !args.userRecord.recordCount>
		<em>#translateResource( 'cms:unknown.user' )#</em>
	<cfelse>
		<img class="user-photo tiny" src="http://www.gravatar.com/avatar/#LCase( Hash( LCase( args.userRecord.email_address ) ) )#?r=g&d=mm&s=20" alt="Avatar for #HtmlEditFormat( args.userRecord.label )#" />
		<span class="user-info">#args.userRecord.label#</span>
	</cfif>
</cfoutput>