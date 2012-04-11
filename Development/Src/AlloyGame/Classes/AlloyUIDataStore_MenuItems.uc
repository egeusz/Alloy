/**
 * Inherited version of the game resource datastore that has UT specific dataproviders.
 *
 * Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
 */
class AlloyUIDataStore_MenuItems extends UDKUIDataStore_MenuItems
	Config(Game);

DefaultProperties
{
	Tag=AlloyMenuItems
	MapInfoDataProviderClass=class'AlloyUIDataProvider_MapInfo'
}


