component extends="coldbox.system.Interceptor" output=false {

// PUBLIC
	public void function configure() output=false {}

	public void function postReadPresideObject( event, interceptData ) output=false {
		var objectMeta = interceptData.objectMeta ?: {};

		objectMeta.siteFiltered = objectMeta.siteFiltered ?: false;

		if ( objectMeta.siteFiltered ) {
			_injectSiteTenancyFields( objectMeta );
		}
	}

// PRIVATE HELPERS

	private void function _injectSiteTenancyFields( required struct meta ) output=false {
		var defaultConfiguration = { relationship="many-to-one", relatedto="site", required=false, ondelete="cascade", onupdate="cascade", generator="none", indexes="_site", uniqueindexes="", control="none" };
		var indexNames           = [];

		for( var prop in arguments.meta.properties ){
			if ( prop == "site" ) { continue; }

			prop = arguments.meta.properties[ prop ];

			if ( Len( Trim( prop.indexes ?: "" ) ) ) {
				var newIndexDefinition = "";

				for( var ix in ListToArray( prop.indexes ) ) {
					var siteIndexName = ListFirst( ix, "|" ) & "|1";
					if ( !ListFindNoCase( defaultConfiguration.indexes, siteIndexName ) ) {
						defaultConfiguration.indexes = ListAppend( defaultConfiguration.indexes, siteIndexName );
					}

					if ( ListLen( ix, "|" ) > 1 ) {
						newIndexDefinition = ListAppend( newIndexDefinition, ListFirst( ix, "|" ) & "|" & Val( ListRest( ix, "|" ) )+1 );
					} else {
						newIndexDefinition = ListAppend( newIndexDefinition, ix & "|2" );
					}
				}

				prop.indexes = newIndexDefinition;
			}

			if ( Len( Trim( prop.uniqueindexes ?: "" ) ) ) {
				var newIndexDefinition = "";

				for( var ix in ListToArray( prop.uniqueindexes ) ) {
					var siteIndexName = ListFirst( ix, "|" ) & "|1";
					if ( !ListFindNoCase( defaultConfiguration.uniqueIndexes, siteIndexName ) ) {
						defaultConfiguration.uniqueIndexes = ListAppend( defaultConfiguration.uniqueIndexes, siteIndexName );
					}

					if ( ListLen( ix, "|" ) > 1 ) {
						newIndexDefinition = ListAppend( newIndexDefinition, ListFirst( ix, "|" ) & "|" & Val( ListRest( ix, "|" ) )+1 );
					} else {
						newIndexDefinition = ListAppend( newIndexDefinition, ix & "|2" );
					}
				}

				prop.uniqueindexes = newIndexDefinition;
			}
		}

		arguments.meta.properties.site = arguments.meta.properties.site ?: {};

		StructAppend( arguments.meta.properties.site, defaultConfiguration, false );

		if ( not arguments.meta.propertyNames.find( "site" ) ) {
			ArrayAppend( arguments.meta.propertyNames, "site" );
		}

		if ( not ListFindNoCase( arguments.meta.dbFieldList, "site" ) ) {
			arguments.meta.dbFieldList = ListAppend( arguments.meta.dbFieldList, "site" );
		}
	}
}