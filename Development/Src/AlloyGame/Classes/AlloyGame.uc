class AlloyGame extends UTDeathMatch;

var AlloyTeamInfo Teams[4];

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

function AlloyTeamInfo GetTeam( int TeamIndex )
{
	return Teams[TeamIndex];
}

function CreateTeam(int TeamIndex)
{
	Teams[TeamIndex] = spawn(class'AlloyTeamInfo');
	GameReplicationInfo.SetTeam(TeamIndex, Teams[TeamIndex]);
}



defaultproperties
{
	PlayerControllerClass=class'AlloyGame.AlloyPlayerController'
	DefaultPawnClass=class'AlloyPlayerPawn'
	//HUDType=class'AlloyGame.AlloyHUD'
	PlayerReplicationInfoClass=class'AlloyGame.AlloyPlayerReplicationInfo'
	GameReplicationInfoClass=class'AlloyGame.AlloyGameReplicationInfo'
//	BotClass=class'UTBot'
}