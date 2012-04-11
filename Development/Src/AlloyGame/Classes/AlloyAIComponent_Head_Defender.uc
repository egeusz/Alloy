class AlloyAIComponent_Head_Defender extends AlloyAIComponent_Head;


function HeadUseTool(AlloyAIController toolController, Actor target){
	toolController.Tool.Defend(toolController, target);
}

function bool Search(Actor target){
	if(AlloyBotPawn(target).Health > 0 && true){ //add code that checks team here
		return true;	
	}
//	`Log("Looking at a dead robot: "@target);
	return false;

}

function Hit(AlloyAIController headController, optional Actor target){
		AlloyBotPawn(headController.Pawn).HeadPart.PlayAnim('head_defender_anim_hit');
}

defaultproperties
{
	WalkingAnim = "head_defender_anim_idle"
	TargetType = class'AlloyBotPawn'
  ViewRange = 800
}
