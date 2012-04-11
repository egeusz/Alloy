class AlloyAIComponent_Tool extends AlloyAIComponent
abstract;

	var float ToolRange;	
	var float ToolDamage;
	var float ToolHeal;
	
function Initialize(){
}

simulated function AlloyDamage(Actor P, float damage, AlloyAIController toolController)
{
		ServerTakeDamage(P, damage, toolController);
}

reliable server function ServerTakeDamage(Actor P, float damage, AlloyAIController toolController){
			P.TakeDamage(damage, toolController, P.Location, vect(0,0,0), class'DamageType');
//			`Log("Server Damage should be happening!");
}

function Use(AlloyAIController toolController, Actor target){
	
}

function Attack(AlloyAIController toolController, Actor target){
	
}

function Collect(AlloyAIController toolController, Actor target){
	
}

function Defend(AlloyAIController toolController, Actor target){
	
}

function Repair(AlloyAIController toolController, Actor target){
	
}

function Hit(AlloyAIController toolController, optional Actor target){
	
}

defaultproperties
{
	Tag = "tool"
}
