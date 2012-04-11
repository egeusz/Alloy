class AlloyPartPawn extends KAsset 	
placeable;


//----------------- AI Classes------------------
var (alloy_AI) class AlloyAIComponentClassName; //AI class of the component. Set in the Archetype. 
var AlloyAIComponent AlloyAIComponentActive; //The curret AI component. Gets built when a part is attached to bot 
//----------------------------------------------

//----------------- Animation and Renderstuff---
var AnimNodeSlot AlloyAnim; //Annimation stuff?
var DynamicLightEnvironmentComponent LightEnvironment;
var ParticleSystem ParticleTemplate; //The Particle System Template for the Beam 
var ParticleSystemComponent PEmitter; //Holds the Emitter for the Beam 
//----------------------------------------------

//----------------- Part States ----------------
var  bool bIsAttached;  //replicated- if part is attached to a bot change the physics state
//replicated- if part is attached to a magnet change the physics state

//var repnotify AlloyPartReplication ReplicationState; 
//----------------------------------------------


simulated event PostBeginPlay()
{
	
	Super.PostBeginPlay();
	detachPart(); // make sure the Part is in detacehd mode when spawned
	AlloyAIComponentActive = AlloyAIComponent(new AlloyAIComponentClassName); // create the specified AI class from archatype
	
	//ReplicationState = Spawn(class'AlloyPartReplication');
}

//-------------------Replication--------------------------------

//-------------------------------------------------------------




//------------Physics Modes------------------------------------
//-- Detach part from bot or magnet
simulated function detachPart()
{
	// set the current base to none
	bIsAttached = False;
	setPhysicsToDetached(); //set the physics to detached mode
	SetBase(none);
	//ReplicationState.setNewState(none,none,'none',false);
	
}

//-- Attach part to a bot. 
simulated function attachPart(Actor newBase,SkeletalMeshComponent baseMesh, name socket)
{
	local vector socketLocation;
	local rotator socketRotation;
	
	setPhysicsToAttached(); //Set the physics of the part to attached mode
	
	baseMesh.GetSocketWorldLocationAndRotation(socket, socketLocation, socketRotation); //get the socket location
	SetLocation(socketLocation); 
	SetRotation(socketRotation);
	
	SetBase(newBase,,baseMesh, socket); //attach part
	
	bIsAttached = True;
	
	//ReplicationState.setNewState(newBase, baseMesh, socket, bIsAttached); //update the replicated state
}


//-- set the physics of the part to detached mode. like a KAsset
simulated function setPhysicsToDetached()
{
	SkeletalMeshComponent.WakeRigidBody();	
	
	SkeletalMeshComponent.SetBlockRigidBody(true);
	SkeletalMeshComponent.SetRBChannel(RBCC_GameplayPhysics);
	SkeletalMeshComponent.SetRBCollidesWithChannel(RBCC_Default,True);
	SkeletalMeshComponent.SetRBCollidesWithChannel(RBCC_Pawn,True);
	SkeletalMeshComponent.SetRBCollidesWithChannel(RBCC_Vehicle,True);
	SkeletalMeshComponent.SetRBCollidesWithChannel(RBCC_Untitled3,True);
	SkeletalMeshComponent.SetRBCollidesWithChannel(RBCC_EffectPhysics, True);
	SkeletalMeshComponent.SetRBCollidesWithChannel(RBCC_GameplayPhysics, True);
	SkeletalMeshComponent.SetRBCollidesWithChannel(RBCC_BlockingVolume,True);
	SkeletalMeshComponent.bUpdateKinematicBonesFromAnimation=FALSE;
	SetPhysics(PHYS_RigidBody);
	SkeletalMeshComponent.PhysicsWeight = 1.0;
}


//--Set the physics of the part to attached mode so it can play animations and follow bot base
simulated function setPhysicsToAttached()
{
	SkeletalMeshComponent.bUpdateKinematicBonesFromAnimation=True;
	SkeletalMeshComponent.PhysicsWeight = 0.0;
	SetPhysics(PHYS_None);	
}


// returns the location of the part based on the socket used for location
simulated function Vector getLocation()
{
	local Vector SocketLocation;
	SkeletalMeshComponent.GetSocketWorldLocationAndRotation('sock_loc', SocketLocation); 
	return SocketLocation; 
}

//-----------------------------------------------------------





//-----------Animation---------------------------------------

function PlayAnim(Name inAnim, optional float playRate, optional bool loop){
	if(AlloyAnim == none)
	{
		 AlloyAnim = AnimNodeSlot(SkeletalMeshComponent.FindAnimNode('AlloyCustomAnim'));
	}

	AlloyAnim.StopCustomAnim(0.2);
//	`Log("Calling AlloyAnim: "@AlloyAnim);
	AlloyAnim.PlayCustomAnim(inAnim , 1.0, 0.2, 0.2, loop , true);
}

function PlayWalk(name inAnim){
	if(AlloyAnim == none)
	{
		 AlloyAnim = AnimNodeSlot(SkeletalMeshComponent.FindAnimNode('AlloyCustomAnim'));
	}

//	AlloyAnim.StopCustomAnim(0.2);
//	`Log("Calling AlloyAnim: "@AlloyAnim);
	AlloyAnim.PlayCustomAnim(inAnim , 1.0, 0.5, 0.5, true , true);
}

function StopWalk(name inAnim)
{
	if(AlloyAnim == none)
	{
		 AlloyAnim = AnimNodeSlot(SkeletalMeshComponent.FindAnimNode('AlloyCustomAnim'));
	}
	
	if(AlloyAnim.GetPlayedAnimation() == inAnim)
	{
		AlloyAnim.StopCustomAnim(0.2);
	}
}
simulated event Destroyed()
{
  Super.Destroyed();

  AlloyAnim = None;
}
//-----------------------------------------------------------


//-----------Particles---------------------------------------
simulated function TriggerParticle(ParticleSystem particle) 
{

	//Create the laser beam if none exists
	if(PEmitter == None) {
		PEmitter = new(self) class'UTParticleSystemComponent';
		ParticleTemplate = particle; //This defines which particle to use
		PEmitter.SetAbsolute(false, false, false); // I have no clue what this does
		PEmitter.SetTemplate(ParticleTemplate);
		
		PEmitter.SetTickGroup(TG_PostUpdateWork);
		PEmitter.bUpdateComponentInTick = true;
		self.AttachComponent(PEmitter); // Set source of beam
	}
		
	PEmitter.ActivateSystem();
	
	//`Log("Attacking closest target. Remaining health: "$target.Health);
}

simulated function StopParticles() {
	PEmitter.DeactivateSystem();
}
//-----------------------------------------------------------




defaultproperties
{
	
	bIsAttached = False
	
	bBlockActors = False
	//bCanBeBaseForPawns=true
	bHardAttach = true
	
	TickGroup=TG_PostAsyncWork
	
	/*
   Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
    bSynthesizeSHLight=TRUE
    bIsCharacterLightEnvironment=TRUE
    bUseBooleanEnvironmentShadowing=FALSE
   End Object
   Components.Add(MyLightEnvironment)
   LightEnvironment=MyLightEnvironment
   */
	
	// make base skelmesh. overwritten in archatype
	Begin Object class=SkeletalMeshComponent Name=SkeletalMeshComponent0
		LightEnvironment=MyLightEnvironment
		bAcceptsLights=true
		bHasPhysicsAssetInstance=true		
		
	End Object
	SkeletalMeshComponent=SkeletalMeshComponent0
	
	CollisionComponent=SkeletalMeshComponent0
	Components.Add(SkeletalMeshComponent0) 
	
	bReplicateRigidBodyLocation=False;// updating positions Malualy at a slower rate might be better to avoid spazziness. 
}


