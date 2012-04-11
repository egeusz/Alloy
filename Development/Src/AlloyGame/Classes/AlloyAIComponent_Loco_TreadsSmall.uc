class AlloyAIComponent_Loco_TreadsSmall extends AlloyAIComponent_Loco
;

function Hit(AlloyAIController locoController, optional Actor target){
		`Log("SmallTreads Being Hit");
		AlloyBotPawn(locoController.Pawn).LocoPart.PlayAnim('loco_smalltreads_anim_hit');
}

defaultproperties
{
		WalkingAnim = "loco_smalltreads_anim_forward"
		LocoSpeed = 100.0
		Health = 90.0
		HealthMax = 90.0
}
