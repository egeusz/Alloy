class AlloyAIComponent_Loco_Spiderlegs extends AlloyAIComponent_Loco
;

function Hit(AlloyAIController locoController, optional Actor target){
		`Log("Spiderlegs Being Hit");
		AlloyBotPawn(locoController.Pawn).LocoPart.PlayAnim('loco_spiderlegs_anim_hit');
}

defaultproperties
{
		WalkingAnim = "loco_spiderlegs_anim_forward"
		LocoSpeed = 150.0
		Health = 75.0
		HealthMax = 75.0
}
