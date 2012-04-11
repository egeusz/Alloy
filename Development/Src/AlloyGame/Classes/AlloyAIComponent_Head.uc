class AlloyAIComponent_Head extends AlloyAIComponent
abstract;

var float ViewRange;
var class<Actor> TargetType;
var byte TeamNum;

simulated function Initialize(byte team){
	`Log("Up and running: "@team @Class);
	TeamNum = team;
}


function bool Search(Actor target){

}

function HeadUseTool(AlloyAIController toolController, Actor target){

}

function Hit(AlloyAIController headController, optional Actor target){
}




defaultproperties
{

	Tag = "head"

}

