class AlloyAIComponent_Tool_Hammer extends AlloyAIComponent_Tool;

var float ToolRange;

var float Cooldown;

function Initialize(){
	`Log("Its hammer time!");
}

function Attack(AlloyAIController toolController, Actor target){

	if(AlloyBotPawn(target).Health < 0){
		`Log("This is now dead: "@target);
		toolController.TargetActor = none;
		toolController.GotoState('Wander', , , false );
		return;
	}
		
	
	if(Cooldown < 0){
		`Log("Hammer attacking");
//		tool_hammer_anim_attack
		AlloyBotPawn(toolController.Pawn).ToolPart.Attack('tool_hammer_anim_attack');
		target.TakeDamage(10, toolController, target.Location, vect(0,0,0), class'DamageType');
		Cooldown = 15.0f;
	} else {
		Cooldown = Cooldown - 1;
	}
	
}

function Collect(AlloyAIController toolController, Actor target){
	`Log("Hammer ...Collecting");
}

function float GetRange(){

return ToolRange;
}


defaultproperties
{
	Cooldown = 15.0
	ToolRange = 100
}
