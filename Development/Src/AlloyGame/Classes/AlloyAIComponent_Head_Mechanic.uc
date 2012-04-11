class AlloyAIComponent_Head_Mechanic extends AlloyAIComponent_Head;


var float HealthPercent;


function HeadUseTool(AlloyAIController toolController, Actor target){
	toolController.Tool.Repair(toolController, target);
}

function bool Search(Actor target){

//	`Log("Looking at Health: "@HealthPercent @Pawn(target).Health/Pawn(target).HealthMax);

	if(Pawn(target).Health <= 0 || HealthPercent < Pawn(target).Health/Pawn(target).HealthMax )
	{
//		`Log("Looking at a dead robot: "@target);
		return false;
	}
	
	if(target.Class == class'AlloyBotPawn' && AlloyAIController(AlloyBotPawn(target).Controller).BotTeam.GetTeamNum() != TeamNum)
	{
//		`Log("Different team robot: "@target);
		return false;
	}
	else if(target.Class == class'AlloyPlayerPawn' && AlloyPlayerController(alloyPlayerPawn(target).Controller).GetTeamNum() != TeamNum)
	{
//		`Log("Different team player: "@target);
		return false;
	}
	
	if(target.Tag != 'AlloyBot')
	{
//		`Log("Not a valid Target");
	  return false;
	}
	
	
	return true;
}

function Hit(AlloyAIController headController, optional Actor target){
		AlloyBotPawn(headController.Pawn).HeadPart.PlayAnim('head_mechanic_anim_hit');
}

defaultproperties
{
	WalkingAnim = "head_mechanic_anim_move"
	TargetType = class'Pawn'
  ViewRange = 800
	HealthPercent = 0.60
}
