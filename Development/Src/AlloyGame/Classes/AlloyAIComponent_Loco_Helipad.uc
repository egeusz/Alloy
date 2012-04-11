class AlloyAIComponent_Loco_Helipad extends AlloyAIComponent_Loco
;

function Hit(AlloyAIController locoController, optional Actor target){
		`Log("Helipad Being Hit");
		AlloyBotPawn(locoController.Pawn).LocoPart.PlayAnim('loco_heli_anim_hit');
}

defaultproperties
{
		WalkingAnim = "loco_heli_anim_forward"
		LocoSpeed = 200.0
		Health = 50.0
		HealthMax = 50.0
}
