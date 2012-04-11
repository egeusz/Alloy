class AlloyAIComponent_Tool_Claw extends AlloyAIComponent_Tool;

	var float ToolRange;
	
	var float Cooldown;

function Initialize(){
	`Log("Its claw time!");

}

function Attack(AlloyAIController toolController, Actor target){

	if(AlloyBotPawn(target).Health < 0){
		`Log("This is now dead: "@target);
		toolController.TargetActor = none;
		toolController.GotoState('Wander', , , false );
		return;
	}

	if(Cooldown < 0){
		`Log("Claw Attacking");
		AlloyBotPawn(toolController.Pawn).ToolPart.Attack('tool_claw_anim_collect');
		target.TakeDamage(5, toolController, target.Location, vect(0,0,0), class'DamageType');
		Cooldown = 15.0f;
	} else {
		Cooldown = Cooldown - 1;
	}
	
}

function Collect(AlloyAIController toolController, Actor target){
	`Log("Claw Collecting");
}

function float GetRange(){

return ToolRange;
}


defaultproperties
{
	ToolRange = 100
	Cooldown = 15.0
}
