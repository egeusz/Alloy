class AlloyAIComponent_Loco_Treads extends AlloyAIComponent_Loco
;

function Hit(AlloyAIController locoController, optional Actor target){
		`Log("Loco Being Hit");
		AlloyBotPawn(locoController.Pawn).LocoPart.PlayAnim('head_collector_anim_hit');
}

defaultproperties
{
		LocoSpeed = 70.0
		Health = 100.0
}
