class AlloyAIComponent_Tool_Hammer extends AlloyAIComponent_Tool;


function Initialize(){
	`Log("Its hammer time!");
}

simulated function Attack(AlloyAIController toolController, Actor target){

	if(Pawn(target).Health <= 0 || target == none){
//		`Log("This is now dead: "@target);
		toolController.TargetActor = none;
		toolController.GotoState('Wander', , , false );
		return;
	}
		
	
	if(Cooldown < 0){
//		`Log("Hammer attacking: "@target);
//		tool_hammer_anim_attack
		AlloyBotPawn(toolController.Pawn).ToolPart.TriggerParticle(ParticleSystem'Particles.Smoke_puff');
		AlloyBotPawn(toolController.Pawn).ToolPart.PlayAnim('tool_hammer_anim_attack');
		ServerTakeDamage(target, ToolDamage, toolController);
		//target.TakeDamage(ToolDamage, toolController, target.Location, vect(0,0,0), class'DamageType');
//		`Log("Hammer hit health remaining: "@Pawn(target).Health);
		AlloyBotPawn(target).Hit();
		Cooldown = 15.0f;
	} else {
		Cooldown = Cooldown - 1;
	}
}

function Collect(AlloyAIController toolController, Actor target){
		if(Cooldown < 0){
//		`Log("Hammer Collecting");
		AlloyBotPawn(toolController.Pawn).ToolPart.PlayAnim('tool_hammer_anim_attack');
		Cooldown = 15.0f;
	} else {
		Cooldown = Cooldown - 1;
	}
}

function Defend(AlloyAIController toolController, Actor target){
		if(Cooldown < 0){
//		`Log("Hammer Defending");
		AlloyBotPawn(toolController.Pawn).ToolPart.PlayAnim('tool_hammer_anim_attack');
		Cooldown = 15.0f;
	} else {
		Cooldown = Cooldown - 1;
	}
}

function Hit(AlloyAIController toolController, optional Actor target){
		if(Cooldown < 0){
//		`Log("Hammer Being Hit");
		AlloyBotPawn(toolController.Pawn).ToolPart.PlayAnim('tool_hammer_anim_hit');
		Cooldown = 15.0f;
	} else {
		Cooldown = Cooldown - 1;
	}
}

function Repair(AlloyAIController toolController, Actor target){
		if(Cooldown < 0){
//		`Log("Hammer Repairing");
		AlloyBotPawn(toolController.Pawn).ToolPart.PlayAnim('tool_hammer_anim_attack');
		
		target.TakeDamage(ToolDamage/2, toolController, target.Location, vect(0,0,0), class'DamageType');
//		`Log("Hammer hit health remaining: "@Pawn(target).Health);
		Cooldown = 15.0f;
	} else {
		Cooldown = Cooldown - 1;
	}
}


defaultproperties
{
	WalkingAnim = "tool_hammer_anim_idle"
	Cooldown = 15.0
	ToolRange = 100
	ToolDamage = 10
}
