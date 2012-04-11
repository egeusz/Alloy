class AlloyAIComponent_Tool_Claw extends AlloyAIComponent_Tool;

function Initialize(){
	`Log("I fought the claw and the claw won");

}

function Attack(AlloyAIController toolController, Actor target){

	if(Pawn(target).Health <= 0){
//		`Log("This is now dead: "@target);
		toolController.TargetActor = none;
		toolController.GotoState('Wander', , , false );
		return;
	}

	if(Cooldown < 0){
//		`Log("Claw Attacking");
		AlloyBotPawn(toolController.Pawn).ToolPart.PlayAnim('tool_claw_anim_attack');
		AlloyBotPawn(toolController.Pawn).ToolPart.TriggerParticle(ParticleSystem'Particles.Spark_Explosion');
		target.TakeDamage(ToolDamage, toolController, target.Location, vect(0,0,0), class'DamageType');
//		`Log("Hammer hit health remaining: "@AlloyBotPawn(target).Health);
		AlloyBotPawn(target).Hit();
		Cooldown = 15.0f;
	} else {
		Cooldown = Cooldown - 1;
	}
	
}

function Collect(AlloyAIController toolController, Actor target){
		if(Cooldown < 0){
//		`Log("Claw Collecting");
		AlloyBotPawn(toolController.Pawn).ToolPart.PlayAnim('tool_claw_anim_collect');
		Cooldown = 15.0f;
	} else {
		Cooldown = Cooldown - 1;
	}
}

function Defend(AlloyAIController toolController, Actor target){
		if(Cooldown < 0){
//		`Log("Claw Defending");
		AlloyBotPawn(toolController.Pawn).ToolPart.PlayAnim('tool_claw_anim_defend');
		Cooldown = 15.0f;
	} else {
		Cooldown = Cooldown - 1;
	}
}

function Hit(AlloyAIController toolController, optional Actor target){
		if(Cooldown < 0){
//		`Log("Claw Being Hit");
		AlloyBotPawn(toolController.Pawn).ToolPart.PlayAnim('tool_claw_anim_hit');
		Cooldown = 15.0f;
	} else {
		Cooldown = Cooldown - 1;
	}
}

function Repair(AlloyAIController toolController, Actor target){
	if(Pawn(target).Health >= Pawn(target).HealthMax){
//		`Log("This is now fullyHealed: "@target);
		toolController.TargetActor = none;
		toolController.GotoState('Wander', , , false );
		return;
	}

		if(Cooldown < 0){
//		`Log("Claw Repairing");
		AlloyBotPawn(toolController.Pawn).ToolPart.PlayAnim('tool_claw_anim_repair');//
		target.HealDamage(ToolHeal, toolController, class'DamageType');
		Cooldown = 15.0f;
	} else {
		Cooldown = Cooldown - 1;
	}
}



defaultproperties
{
	WalkingAnim = "tool_claw_anim_move"
	ToolRange = 100
	Cooldown = 15.0
	ToolDamage = 5
	ToolHeal = 10
}
