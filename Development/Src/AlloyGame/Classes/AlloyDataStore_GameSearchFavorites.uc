/**
 * This data store class provides query and search results for the "Favorites" page.  In functionality, it's essentially
 * the same as the history data store - just stores a different list of servers.
 *
 * Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
 */
class AlloyDataStore_GameSearchFavorites extends AlloyDataStore_GameSearchPersonal;

var	transient	AlloyDataStore_GameSearchHistory	HistoryGameSearchDataStore;

/**
 * @param	bRestrictCheckToSelf	if TRUE, will not check related game search data stores for outstanding queries.
 *
 * @return	TRUE if a server list query was started but has not completed yet.
 */
function bool HasOutstandingQueries( optional bool bRestrictCheckToSelf )
{
	local bool bResult;

	bResult = Super.HasOutstandingQueries(bRestrictCheckToSelf);
	if ( !bResult && !bRestrictCheckToSelf && HistoryGameSearchDataStore != None )
	{
		bResult = HistoryGameSearchDataStore.HasOutstandingQueries(true);
	}

	return bResult;
}

DefaultProperties
{
	Tag=AlloyGameFavorites
	GameSearchCfgList.Add((GameSearchClass=class'AlloyGame.AlloyGameSearchPersonal',DefaultGameSettingsClass=class'AlloyGame.AlloyGameSettingsPersonal',SearchResultsProviderClass=class'AlloyGame.AlloyUIDataProvider_SearchResult',SearchName="AlloyGameSearchFavorites"))
}
