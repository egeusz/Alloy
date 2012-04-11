class AlloyBotPawn extends UDKPawn
	Placeable;

var DynamicLightEnvironmentComponent LightEnvironment;

var class<AlloyAIController> NPCController;

// -- AI components for bot--
var AlloyAIComponent_Head HeadAI;
var AlloyAIComponent_Power PowerAI;
var AlloyAIComponent_Tool ToolAI;
var AlloyAIComponent_Loco LocoAI;

// --refrences for parts --
var AlloyPartPawn HeadPart;
var AlloyPartPawn PowerPart;
var AlloyPartPawn ToolPart;
var AlloyPartPawn LocoPart;


/** The Particle System Template for the Beam */
var particleSystem BeamTemplate;

/** Holds the Emitter for the Beam */
var ParticleSystemComponent BeamEmitter;

var name EndPointParamName;


simulated event PostBeginPlay()
{
	`Log("Pawn made!");
	if(NPCController != none){
		ControllerClass = NPCController;
	}
	SetMovementPhysics();
	SetPhysics(PHYS_Falling);
	
	Super.PostBeginPlay();
	SetTimer(0.01666667, true, 'UpdateLoc');
}

//--attach a part to the bot--
simulated function AttachPart(AlloyPartPawn AP, name APsocket)
{
	AP.setPhysicsToAttached(); //set part mode and physics to attached
	AP.SetBase(self,, Mesh, APsocket); // set base to bot
}

simulated function DetachPart(AlloyPartPawn AP)
{
	AP.setPhysicsToDetached(); //set part mode and physics to attached
	AP.SetBase(none); // set base to bot
}


simulated function setComponentsForBot(AlloyPartPawn h, AlloyPartPawn p, AlloyPartPawn t, AlloyPartPawn l)
{
	
	//-- set refrences to parts in bot--
	HeadPart = h;
	PowerPart = p;
	ToolPart = t;
	LocoPart  = l;
	
	/*
	HeadPart.setPhysicsToAttached();
	PowerPart.setPhysicsToAttached();
	ToolPart.setPhysicsToAttached();
	LocoPart.setPhysicsToAttached();
	*/	
	
	// --attach the peices to the bot-- 		
	AttachPart(HeadPart, 'sock_root');
	AttachPart(PowerPart,'sock_root');
	AttachPart(ToolPart, 'sock_root');
	ToolPart.InitAnimTree();
	AttachPart(LocoPart, 'sock_root');

	//-- create and store AI components for bot --
	HeadAI  = AlloyAIComponent_Head (h.AlloyAIComponentActive);
	PowerAI = AlloyAIComponent_Power(p.AlloyAIComponentActive);
	ToolAI  = AlloyAIComponent_Tool (t.AlloyAIComponentActive);
	LocoAI  = AlloyAIComponent_Loco (l.AlloyAIComponentActive);
	
	SpawnDefaultController();
	
	AlloyAIController(Controller).SetupPawn();
	
}



simulated function FireLaser(AlloyBotPawn target) 
{

	//Create the laser beam if none exists
	if(BeamEmitter == None) {
		BeamEmitter = new(self) class'UTParticleSystemComponent';
		BeamTemplate = ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Altbeam'; //This defines which particle to use
		BeamEmitter.SetAbsolute(false, false, false); // I have no clue what this does
		BeamEmitter.SetTemplate(BeamTemplate);
		
		BeamEmitter.SetTickGroup(TG_PostUpdateWork);
		BeamEmitter.bUpdateComponentInTick = true;
		self.AttachComponent(BeamEmitter); // Set source of beam
	}
		
	BeamEmitter.SetVectorParameter(EndPointParamName, target.Location); // Set target of beam
	BeamEmitter.ActivateSystem();
	
	//`Log("Attacking closest target. Remaining health: "$target.Health);
}

simulated function StopLaser() 
{
	BeamEmitter.DeactivateSystem();
}




simulated function UpdateLoc()
{
//`Log(myLoco.location);
	//myLoco.SetLocation(location);
	//myHead.SetLocation(location);
	//myBody.SetLocation(location);
	//myTool.SetLocation(location);
}

//when bot dies detach its parts
function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	
	DetachPart(HeadPart);
	DetachPart(PowerPart);
	DetachPart(ToolPart);
	DetachPart(LocoPart);
	
	
	return super.Died(Killer, DamageType, HitLocation);
	
	

}

defaultproperties
{
	EndPointParamName = LinkBeamEnd

   WalkingPct=+0.4
   CrouchedPct=+0.4
   BaseEyeHeight=38.0
   EyeHeight=0.0
   GroundSpeed=100.0
   AirSpeed=440.0
   WaterSpeed=220.0
   AccelRate=1024.0
   JumpZ=500.0
   CrouchHeight=29.0
   CrouchRadius=21.0
   WalkableFloorZ=0.78
   
   Components.Remove(Sprite)
   
   Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
      bSynthesizeSHLight=TRUE
      bIsCharacterLightEnvironment=TRUE
      bUseBooleanEnvironmentShadowing=FALSE
   End Object
   
	 Components.Add(MyLightEnvironment)
   LightEnvironment=MyLightEnvironment
	
	//--blank root mesh with base socket--
	Begin Object class=SkeletalMeshComponent Name=SkeletalMeshComponent3
		SkeletalMesh=SkeletalMesh'blank_bone.blankrootbone'
		LightEnvironment=MyLightEnvironment
		bAcceptsLights=true
	End Object
	Mesh=SkeletalMeshComponent3
	Components.Add(SkeletalMeshComponent3) 
	
	
	Begin Object Class=CylinderComponent Name=CollisionCylinder1
		CollisionRadius=+0034.000000
		CollisionHeight=+0078.000000
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true
		CollideActors=true
	End Object
	CollisionComponent=CollisionCylinder1
	CylinderComponent=CollisionCylinder1
	Components.Add(CollisionCylinder1)	
  
	bCanBeBaseForPawns=true
	bHardAttach = true

   NPCController=class'AlloyAIController'
	
}