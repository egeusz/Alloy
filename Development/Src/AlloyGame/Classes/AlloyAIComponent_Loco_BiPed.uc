class AlloyAIComponent_Loco_BiPed extends AlloyAIComponent_Loco
;

function Hit(AlloyAIController locoController, optional Actor target){
		`Log("Biped Being Hit");
		AlloyBotPawn(locoController.Pawn).LocoPart.PlayAnim('loco_biped_anim_hit');
}

defaultproperties
{
		WalkingAnim = "loco_biped_anim_forward"
		LocoSpeed = 60.0
		Health = 60.0
		HealthMax = 60.0
}
