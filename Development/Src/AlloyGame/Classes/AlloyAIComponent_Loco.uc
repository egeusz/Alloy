class AlloyAIComponent_Loco extends AlloyAIComponent
abstract;

var float LocoSpeed;
var int Health;
var int HealthMax;

function Hit(AlloyAIController locoController, optional Actor target){

}

defaultproperties
{
	Tag = "loco"
	LocoSpeed = 100.0
	Health = 100
	HealthMax = 100

}
