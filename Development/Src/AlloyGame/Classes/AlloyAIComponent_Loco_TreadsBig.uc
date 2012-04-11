class AlloyAIComponent_Loco_TreadsBig extends AlloyAIComponent_Loco
;

function Hit(AlloyAIController locoController, optional Actor target){
		`Log("BigTreads Being Hit");
		AlloyBotPawn(locoController.Pawn).LocoPart.PlayAnim('loco_bigtreads_anim_hit');
}

defaultproperties
{
		WalkingAnim = "loco_bigtreads_anim_forward"
		LocoSpeed = 40.0
		Health = 120.0
		HealthMax = 120.0
}
