class AlloyAIComponent_Head_Aggressive extends AlloyAIComponent_Head;


function HeadUseTool(AlloyAIController toolController, Actor target){
	toolController.Tool.Attack(toolController, target);
}

function bool Search(Actor target){

//	`Log("Looking at target class: "@target.Class);

	if(Pawn(target).Health <= 0 )
	{
//		`Log("Looking at a dead robot: "@target);
		return false;
	}
	
	if(target.Class == class'AlloyBotPawn' && AlloyAIController(AlloyBotPawn(target).Controller).BotTeam.GetTeamNum() == TeamNum)
	{
//		`Log("Same team robot: "@target);
		return false;
	}
	else if(target.Class == class'AlloyPlayerPawn' && AlloyPlayerController(alloyPlayerPawn(target).Controller).GetTeamNum() == TeamNum)
	{
//		`Log("Same team player: "@target);
		return false;
	}
	
	if(target.Tag != 'AlloyBot')
	{
//		`Log("Not a valid Target");
	  return false;
	}
//	`Log("MyTeam, TargetTeam "@TeamNum @AlloyPlayerController(alloyPlayerPawn(target).Controller).GetTeamNum());
	
	return true;
}

function Hit(AlloyAIController headController, optional Actor target){
		AlloyBotPawn(headController.Pawn).HeadPart.PlayAnim('head_aggressive_anim_hit');
}

defaultproperties
{
	WalkingAnim = "head_aggressive_anim_moving"
	TargetType = class'Pawn'
  ViewRange = 800
}
