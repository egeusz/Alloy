class AlloyAIComponent_Head_Collector extends AlloyAIComponent_Head;


var class<Actor> TargetType;

var float ViewRange;

function Initialize(){
	`Log("Collector head created");
	ViewRange = 800;
	TargetType = class'AlloyPartPawn';
}


function class<Actor> GetTargetType(){
	return TargetType;
}

function float GetViewRange(){
	return ViewRange;
}

function HeadUseTool(AlloyAIController toolController, Actor target){
	toolController.Tool.Collect(toolController, target);
}

function bool Search(Actor target){
	if(!AlloyPartPawn(target).bIsAttachedToBot){
//	`Log("Collector Searching");
		return true;
	} else {
		
		return false;
	}

}

defaultproperties
{
	
}
