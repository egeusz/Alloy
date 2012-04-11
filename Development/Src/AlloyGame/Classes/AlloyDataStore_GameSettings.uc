/**
 * Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
 */

/**
 * Warfare specific datastore for TDM game creation
 */
class AlloyDataStore_GameSettings extends UIDataStore_OnlineGameSettings;

defaultproperties
{
	GameSettingsCfgList.Add((GameSettingsClass=class'AlloyGame.AlloyGameSettings',SettingsName="AlloyGameSettings"))
	Tag=AlloyGameSettings
}
