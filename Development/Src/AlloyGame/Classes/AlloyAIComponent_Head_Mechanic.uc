class AlloyAIComponent_Head_Mechanic extends AlloyAIComponent_Head;

var class<Actor> TargetType;

var float ViewRange;

function Initialize(){
	`Log("Aggro head created");
	ViewRange = 800;
	TargetType = class'AlloyBotPawn';
	
}


function class<Actor> GetTargetType(){
	return TargetType;
}

function float GetViewRange(){
	return ViewRange;
}

function HeadUseTool(AlloyAIController toolController, Actor target){
	toolController.Tool.Attack(toolController, target);
}

function bool Search(Actor target){
	if(AlloyBotPawn(target).Health > 0 && true){ //add code that checks team here
		return true;	
	}
	`Log("Looking at a dead robot: "@target);
	return false;

}

defaultproperties
{
  
}
