class AlloyGame extends UDKGame;

var AlloyTeamInfo Teams[4];
var int PlayerCount;

event PostBeginPlay()
{
	Super.PostBeginPlay();
}
function PreBeginPlay()
{
	super.PreBeginPlay();
	
	CreateTeam(0);
	CreateTeam(1);
	CreateTeam(2);
	CreateTeam(3);
}

event PostLogin(PlayerController NewPlayer)
{
	local byte teamIndex;
	Super.PostLogin(NewPlayer);
	teamIndex = PlayerCount++;
	AlloyPlayerController(NewPlayer).SetTeam(Teams[teamIndex]);
	`Log("Logged in and set team index to "@teamIndex);
}

function AlloyTeamInfo GetTeam( int TeamIndex )
{
	return Teams[TeamIndex];
}

function CreateTeam(int TeamIndex)
{
	Teams[TeamIndex] = spawn(class'AlloyTeamInfo');
	Teams[TeamIndex].Initialize(TeamIndex);
	GameReplicationInfo.SetTeam(TeamIndex, Teams[TeamIndex]);
}

function bool SetPause(PlayerController PC, optional delegate<CanUnpause> CanUnpauseDelegate = CanUnpause) {
	if ( !PC.IsLocalPlayerController() )
	{
		return false;
	}
	
	return Super.SetPause(PC, CanUnpauseDelegate);
}



defaultproperties
{
	PlayerControllerClass=class'AlloyGame.AlloyPlayerController'
	DefaultPawnClass=class'AlloyPlayerPawn'
	//HUDType=class'AlloyGame.AlloyHUD'
	PlayerReplicationInfoClass=class'AlloyGame.AlloyPlayerReplicationInfo'
	GameReplicationInfoClass=class'AlloyGame.AlloyGameReplicationInfo'
	PlayerCount=0;
//	BotClass=class'UTBot'
}