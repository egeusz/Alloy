class AlloyPartPawn extends GamePawn 	
placeable;

var DynamicLightEnvironmentComponent LightEnvironment;

var bool bIsAttachedToBot; 

var (alloy_AI) class AlloyAIComponentClassName;

var AlloyAIComponent AlloyAIComponentActive;

var AnimNodeSlot AttackAnim;


simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	
	SetCollisionType(COLLIDE_NoCollision); // make sure collition type is NoCollision incase some one messed up the archetpye 
	setPhysicsToDetached(); // make sure the Part is in detacehd mode when spawned
	AlloyAIComponentActive = AlloyAIComponent(new AlloyAIComponentClassName); // create the specified AI class from archatype
	
}

function InitAnimTree()
{
	`Log("Mesh :"@Mesh);
  AttackAnim = AnimNodeSlot(Mesh.FindAnimNode('AlloyCustomAnim'));
	`Log("Created AttackAnim: "@AttackAnim);
}

function Attack(Name toolAttack){
	local float dur;
	AttackAnim.StopCustomAnim(0.0);
	`Log("Calling AttackAnim: "@AttackAnim);
	dur = AttackAnim.PlayCustomAnim(toolAttack , 1.0, 0.2, 0.2, , true);
	`Log("AttackAnim Triggered: "@dur);
}

//-- set the physics of the part to detached mode. like a KAsset
simulated function setPhysicsToDetached()
{
	Mesh.WakeRigidBody();	
	
	Mesh.SetBlockRigidBody(true);
	Mesh.SetRBChannel(RBCC_GameplayPhysics);
	Mesh.SetRBCollidesWithChannel(RBCC_Default,True);
	Mesh.SetRBCollidesWithChannel(RBCC_Pawn,True);
	Mesh.SetRBCollidesWithChannel(RBCC_Vehicle,True);
	Mesh.SetRBCollidesWithChannel(RBCC_Untitled3,True);
	Mesh.SetRBCollidesWithChannel(RBCC_EffectPhysics, True);
	Mesh.SetRBCollidesWithChannel(RBCC_GameplayPhysics, True);
	Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume,True);
	Mesh.bUpdateKinematicBonesFromAnimation=FALSE;
	SetPhysics(PHYS_RigidBody);
	Mesh.PhysicsWeight = 1.0;
	
	bIsAttachedToBot = False;

}

//--set the physics of the part to attached mode so it can play animations and follow bot base
simulated function setPhysicsToAttached()
{
	
	
	Mesh.bUpdateKinematicBonesFromAnimation=True;
	Mesh.PhysicsWeight = 0.0;
	SetPhysics(PHYS_None);
	
	bIsAttachedToBot = True;
}

simulated function Vector getLocation()
{
	local Vector SocketLocation;

	Mesh.GetSocketWorldLocationAndRotation('sock_loc', SocketLocation); 

	return SocketLocation; 
}

simulated event Destroyed()
{
  Super.Destroyed();

  AttackAnim = None;
}


defaultproperties
{
	
	bIsAttachedToBot = False
	
	bBlockActors = False
	bCanBeBaseForPawns=true
	bHardAttach = true
	
	TickGroup=TG_PostAsyncWork
	
	
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
    bSynthesizeSHLight=TRUE
    bIsCharacterLightEnvironment=TRUE
    bUseBooleanEnvironmentShadowing=FALSE
   End Object
   Components.Add(MyLightEnvironment)
   LightEnvironment=MyLightEnvironment
	
	// make base skelmesh. overwritten in archatype
	Begin Object class=SkeletalMeshComponent Name=SkeletalMeshComponent0
		LightEnvironment=MyLightEnvironment
		bAcceptsLights=true
		bHasPhysicsAssetInstance=true		
		
	End Object
	Mesh=SkeletalMeshComponent0
	CollisionComponent=SkeletalMeshComponent0
	Components.Add(SkeletalMeshComponent0) 
	CollisionType = COLLIDE_NoCollision
	
}


