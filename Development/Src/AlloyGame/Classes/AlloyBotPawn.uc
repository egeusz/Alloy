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
var particleSystem SpawnTemplate;
var particleSystem DeathTemplate;
/** Holds the Emitter for the Beam */
var ParticleSystemComponent SpawnEmitter;
var ParticleSystemComponent DeathEmitter;

// Replication Variables
var repnotify name tHead_name;
var repnotify name tPower_name;
var repnotify name tTool_name;
var repnotify name tLoco_name;


var name EndPointParamName;

replication
{
	if (bNetDirty) tHead_name, tPower_name, tTool_name, tLoco_name;
}

simulated event PostBeginPlay()
{
	`Log("Pawn made!");
	if(NPCController != none){
		ControllerClass = NPCController;
	}
	SetMovementPhysics();
	SetPhysics(PHYS_Falling);
	
	Super.PostBeginPlay();
	//SetTimer(0.01666667, true, 'UpdateLoc');
	
	//`Log("--Starting Values on bot--" @tHead_name @tPower_name  @tTool_name  @tLoco_name);
	
	tHead_name = 'none';
	tPower_name = 'none';
	tTool_name = 'none';
 	tLoco_name = 'none';
	
}

simulated function UpdateBotTeam(AlloyTeamInfo PlayerTeam)
{
	AlloyAIController(Controller).SetBotTeam(PlayerTeam);
}

reliable server function serverReplicateSetComponentsForBot(name head, name power, name tool, name loco)
{
	SetComponentsReplication(head, power, tool, loco);
}

simulated function clientReplicateSetComponentsForBot(name head, name power, name tool, name loco)
{
	SetComponentsReplication(head, power, tool, loco);
}

simulated event ReplicatedEvent(name VarName) {
	if (VarName == 'tHead_name' || VarName == 'tPower_name' || VarName == 'tTool_name' || VarName == 'tLoco_name' ) //if the magnet bool is dirty 
	{
		`Log("-- Attempt to replicate parts on Bot--" @tHead_name @tPower_name  @tTool_name  @tLoco_name);
		clientReplicateSetComponentsForBot(tHead_name, tPower_name, tTool_name, tLoco_name); // toggle magnet on server
	}
	
}	



simulated function setComponentsForBot(AlloyPartPawn h, AlloyPartPawn p, AlloyPartPawn t, AlloyPartPawn l)
{
	//-- set refrences to parts in bot--
	HeadPart = h;
	PowerPart = p;
	ToolPart = t;
	LocoPart  = l;	
	// --attach the peices to the bot-- 		
	LocoPart.attachPart(self, Mesh, 'sock_root'); // attach loco to bot base
	PowerPart.attachPart(LocoPart,LocoPart.SkeletalMeshComponent, 'sock_power'); //attach power to loco 
	ToolPart.attachPart(PowerPart,PowerPart.SkeletalMeshComponent, 'sock_arms'); //attach tool to power
	HeadPart.attachPart(PowerPart,PowerPart.SkeletalMeshComponent, 'sock_head'); //attach head to power
	//-- create and store AI components for bot --
	HeadAI  = AlloyAIComponent_Head (h.AlloyAIComponentActive);
	PowerAI = AlloyAIComponent_Power(p.AlloyAIComponentActive);
	ToolAI  = AlloyAIComponent_Tool (t.AlloyAIComponentActive);
	LocoAI  = AlloyAIComponent_Loco (l.AlloyAIComponentActive);
	GroundSpeed = LocoAI.LocoSpeed*PowerAI.MoveSpeed;
	Health = LocoAI.Health;
	HealthMax = LocoAI.HealthMax;
	
	//SpawnDefaultController();
	AlloyAIController(Controller).SetupPawn();
	

	SpawnParticle();
	
	tHead_name = HeadPart.Name;
	tPower_name = PowerPart.Name;
	tTool_name = ToolPart.Name;
	tLoco_name = LocoPart.Name;
	
	if( Role < Role_Authority ) // tell the server to replicate attachment
 	{
		serverReplicateSetComponentsForBot(tHead_name, tPower_name, tTool_name, tLoco_name);
	}
}


simulated function DetachPart(AlloyPartPawn AP)
{
	AP.detachPart(); //set part mode and physics to attached
	AP.SetBase(none); // set base to bot
}


simulated function SetComponentsReplication(name head, name power, name tool, name loco)
{
	local AlloyPartPawn AP;
	if(head != 'none' && power != 'none' && tool != 'none' && loco != 'none'){
 		`Log("--Replicating Bot Attachments--" );
		foreach WorldInfo.AllActors(class'AlloyPartPawn', AP)
		{
			//-- set refrences to parts in bot--
			if(head == AP.name)
			{		
				`Log("--Got Head--" );
				HeadPart = AP;
			}
			if(power == AP.name)
			{
				`Log("--Got Power--" );
				PowerPart = AP;
			}
			if(tool == AP.name)
			{
				`Log("--Got Tool--" );
				ToolPart = AP;
			}
			if(loco == AP.name)
			{
				`Log("--Got Loco--" );
				LocoPart  = AP;	
			}
		}
		// --attach the peices to the bot-- 		
		LocoPart.attachPart(self, Mesh, 'sock_root'); // attach loco to bot base
		PowerPart.attachPart(LocoPart,LocoPart.SkeletalMeshComponent, 'sock_power'); //attach power to loco 
		ToolPart.attachPart(PowerPart,PowerPart.SkeletalMeshComponent, 'sock_arms'); //attach tool to power
		HeadPart.attachPart(PowerPart,PowerPart.SkeletalMeshComponent, 'sock_head'); //attach head to power
		//-- create and store AI components for bot --
		HeadAI  = AlloyAIComponent_Head (HeadPart.AlloyAIComponentActive);
		PowerAI = AlloyAIComponent_Power(PowerPart.AlloyAIComponentActive);
		ToolAI  = AlloyAIComponent_Tool (ToolPart.AlloyAIComponentActive);
		LocoAI  = AlloyAIComponent_Loco (LocoPart.AlloyAIComponentActive);
		GroundSpeed = LocoAI.LocoSpeed*PowerAI.MoveSpeed;
		Health = LocoAI.Health;
		HealthMax = LocoAI.HealthMax;
	
		//SpawnDefaultController();
		//AlloyAIController(Controller).SetupPawn();
		

		SpawnParticle();
		
		tHead_name = HeadPart.Name;
		tPower_name = PowerPart.Name;
		tTool_name = ToolPart.Name;
		tLoco_name = LocoPart.Name;
	}
	
	if(head == 'none' && power == 'none' && tool == 'none' && loco == 'none')
	{
		`Log("--Replicating Dumping Bot Parts--" );
		DeathParticle();
		DetachPart(HeadPart);
		DetachPart(PowerPart);
		DetachPart(ToolPart);
		DetachPart(LocoPart);
		
		tHead_name = 'none';
		tPower_name = 'none';
		tTool_name = 'none';
 		tLoco_name = 'none';
	}
}

function PlayWalks()
{
	LocoPart.PlayWalk(LocoAI.WalkingAnim);
	HeadPart.PlayWalk(HeadAI.WalkingAnim);
	ToolPart.PlayWalk(ToolAI.WalkingAnim);
}

function StopWalks()
{
	LocoPart.StopWalk(LocoAI.WalkingAnim);
	HeadPart.StopWalk(HeadAI.WalkingAnim);
	ToolPart.StopWalk(ToolAI.WalkingAnim);
}

simulated function DeathParticle() 
{

	if(DeathEmitter == None) {
		DeathEmitter = new(self) class'UTParticleSystemComponent';
		DeathTemplate = ParticleSystem'Particles.Bot_Death'; //This defines which particle to use
		DeathEmitter.SetAbsolute(false, false, false); // I have no clue what this does
		DeathEmitter.SetTemplate(DeathTemplate);
		
		DeathEmitter.SetTickGroup(TG_PostUpdateWork);
		DeathEmitter.bUpdateComponentInTick = true;
		self.AttachComponent(DeathEmitter); // Set source of beam
	}
		
	DeathEmitter.ActivateSystem();
	
}

simulated function SpawnParticle() 
{

	if(SpawnEmitter == None) {
		SpawnEmitter = new(self) class'UTParticleSystemComponent';
		SpawnTemplate = ParticleSystem'Particles.Bot_Spawn'; //This defines which particle to use
		SpawnEmitter.SetAbsolute(false, false, false); // I have no clue what this does
		SpawnEmitter.SetTemplate(SpawnTemplate);
		
		SpawnEmitter.SetTickGroup(TG_PostUpdateWork);
		SpawnEmitter.bUpdateComponentInTick = true;
		self.AttachComponent(SpawnEmitter); // Set source of beam
	}
		
	SpawnEmitter.ActivateSystem();
	
}


simulated function Hit()
{
	`Log("I should be being hit! ");
	HeadAI.Hit(AlloyAIController(Controller));
	ToolAI.Hit(AlloyAIController(Controller));
	LocoAI.Hit(AlloyAIController(Controller));	
}


/*
simulated function UpdateLoc()
{
//`Log(myLoco.location);
	//myLoco.SetLocation(location);
	//myHead.SetLocation(location);
	//myBody.SetLocation(location);
	//myTool.SetLocation(location);
}
*/
//when bot dies detach its parts
function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	DeathParticle();
	DetachPart(HeadPart);
	DetachPart(PowerPart);
	DetachPart(ToolPart);
	DetachPart(LocoPart);
	
	self.Destroy();
	
	return super.Died(Killer, DamageType, HitLocation);
	
}

defaultproperties
{

	Tag = "AlloyBot"
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