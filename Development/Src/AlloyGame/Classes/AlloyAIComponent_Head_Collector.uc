class AlloyAIComponent_Head_Collector extends AlloyAIComponent_Head;


function HeadUseTool(AlloyAIController toolController, Actor target){
	toolController.Tool.Collect(toolController, target);
}

function bool Search(Actor target){
	if(!AlloyPartPawn(target).bIsAttached){
//	`Log("Collector Searching");
		return true;
	} else {
		
		return false;
	}

}

function Hit(AlloyAIController headController, optional Actor target){
		AlloyBotPawn(headController.Pawn).HeadPart.PlayAnim('head_collector_anim_hit');
}

defaultproperties
{
	WalkingAnim = "head_collector_anim_moving"
	TargetType = class'AlloyPartPawn'
	ViewRange = 800
}
