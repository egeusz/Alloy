class AlloyPlayerPawn extends UTPawn;

var SkeletalMeshComponent BBSkeletalMeshComponent; 

var PointLightComponent magnetLight;
var NxForceFieldRadialComponent magnet;

var SoundCue shock;


//v---------Camera Vars------------------------------
var float CamOffsetDistance; //distance to offset the camera above the player
var float CamPitchRotation; // rotation of camera
var Vector CamFocusPoint;//point which the camera focuses at
var int CamYawRotation;  // Camera rotation about the Z axis
var int CamVelocity; // camera current rotational velocity. 
var int CamMaxVelocity;//
var int oldPlayerYawRotation;
var int CamFloatDivisor;
var float CamOffsetX;// camera offset x
var float CamOffsetZ;// camera offset z
var float CamOffsetY;// camera offset y
var float CamHorizontalOffset; // camera horizontal Offset
var bool bFollowPlayerRotation; //If true, camera rotates with player
var float ZoomSpeed;
//^-------------------------------------------------

//v---------- Pickup Part vars----------------------
var AlloyPartPawn tLoco, tTool, tHead, tPower; //parts attached to magnet
var bool bLoco, bTool, bHead, bPower; //we have one of this part attached to the magnet
var repnotify name tHead_name;
var repnotify name tPower_name;
var repnotify name tTool_name;
var repnotify name tLoco_name;

//^-------------------------------------------------

var AnimNodeSlot AlloyAnim;

//v---------- Replication Vars----------------------
var repnotify bool bMagnetOn; //replicated bool if magnet is on. 
//^-------------------------------------------------


replication
{
	if (bNetDirty) bMagnetOn, tHead_name, tPower_name, tTool_name, tLoco_name;
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	`Log("Custom Pawn up");
	
	Mesh.AttachComponentToSocket(magnet, 'sc_magnet');
	magnet.bForceActive = false;
	Mesh.AttachComponentToSocket(magnetLight, 'sc_magnet');
	magnetLight.SetEnabled(false);
	
	CamOffsetDistance = -400;
	CamMaxVelocity = 200;
	
	tHead_name = 'none';
	tPower_name = 'none';
	tTool_name = 'none';
 	tLoco_name = 'none';
}

//-------------- replication event ---------------------------
simulated event ReplicatedEvent(name VarName) {
	`Log("-----  Pawn Replicated" @name);
	`log(VarName @ 'replicated');
	
	
	if (VarName == 'bMagnetOn') //if the magnet bool is dirty 
	{
		ReplicateMagnetToggled(); // toggle magnet on server
	} 
	else if (VarName == 'tHead_name')
	{
		`Log("----- Part" @ tHead_name);
		ClientReplicatePartAttachment(tHead_name);
	}
	else if (VarName == 'tPower_name')
	{
		`Log("----- Part" @ tPower_name);
		ClientReplicatePartAttachment(tPower_name);
	}
	else if (VarName == 'tTool_name')
	{
		`Log("----- Part" @ tTool_name);
		ClientReplicatePartAttachment(tTool_name);
	}
	else if (VarName == 'tLoco_name')
	{
		`Log("----- Part" @ tLoco_name);
		ClientReplicatePartAttachment(tLoco_name);
	}
	else {
		Super.ReplicatedEvent(VarName);
	}
	
}
 
simulated function ClientReplicatePartAttachment(name partName)
{
	`Log("----- Replicated " @partName);
	PartAttachmentReplication(partName);
}

reliable server function ServerReplicatePartAttachment(name partName)
{
	`Log("----- Server Replicated " @partName);
	PartAttachmentReplication(partName);
}

//replicates the part attachment. searches the local world for a Part that has the same name and attaches it
simulated function PartAttachmentReplication(name partName)
{
	local AlloyPartPawn AP;
	
	if (partName != 'none' )
	{
		`Log("----- Looking for" @partName);
		foreach WorldInfo.AllActors(class'AlloyPartPawn', AP)
		{
			if(partName == AP.name)
			{
				if(AP.AlloyAIComponentActive.Tag == "head")
				{
					`Log("----- Attaching Head" );
					bHead = true;
					tHead = AP;
					tHead.attachPart(self, Mesh, 'sock_head');
					tHead_name = AP.name;
				
			//`Log("Found Head");
				}
				else if(AP.AlloyAIComponentActive.Tag == "power")
				{
					`Log("----- Attaching Power" );
					bPower = true;
					tPower = AP;
					tPower.attachPart(self, Mesh, 'sock_power');	
					tPower_name = AP.name;
			//`Log("Found Power");
				}
				else if(AP.AlloyAIComponentActive.Tag == "tool")
				{
					`Log("----- Attaching Tool" );
					bTool = true;
					tTool = AP;
					tTool.attachPart(self, Mesh, 'sock_arms');	
					tTool_name = AP.name;
					//`Log("Found Tool");
				}
				else if(AP.AlloyAIComponentActive.Tag == "loco")
				{
					`Log("----- Attaching Loco" );
					bLoco = true;
					tLoco = AP;
					tLoco.attachPart(self, Mesh, 'sock_loco');
					tLoco_name = AP.name;	
					//`Log("Found Loco");
				}
			}	
			else
			{
				/*
				if(tHead != none && )
				{	
					tHead.detachPart();
					bHead = false;
					tHead = none; 
					tHead_name = 'none';
			
				*/
				
			}
		}
	}


}

//-- Print out all pawns in game for testing
simulated function PrintActors()
{
	local Pawn P;
	local AlloyPartPawn AP;
	
	`Log("       ");
	
  foreach WorldInfo.AllActors(class'Pawn', P)
	{
		`Log("Pawn Name -- "@P.name);
	}
	foreach WorldInfo.AllActors(class'AlloyPartPawn', AP)
	{
		`Log("Pawn Name -- "@AP.name);
	}
	
		`Log("My Name >>-- " @name); 
	
	if (Role < Role_Authority)
	{
		`Log("I am Client");
	}
	 if (Role == Role_Authority)
	{
		`Log("I am Server");
	}
	if ( Role == ROLE_AutonomousProxy)
	{
		`Log("I am AutonomousProxy");
	}
	if ( Role == ROLE_SimulatedProxy)
	{
		`Log("I am SimulatedProxy");
	}
	`Log("       ");	

}

//-------------------------------------------------------------------------


//---------------------Magnet Stuff----------------------------------------
//toggles the magnet on or off
simulated function ToggleMagnet()
{
	bMagnetOn = !bMagnetOn; // the bool is toggled
	MagnetToggled(); //then toggle local player
	if (Role < Role_Authority) { //then tell surver to toggle magnet
		ServerToggleMagnet();
	}
}


// toggle all other replicated magnet functions  
reliable server function ServerToggleMagnet() {
	bMagnetOn = !bMagnetOn;
	MagnetToggled();
}

simulated function MagnetToggled() {
	if (bMagnetOn)
	{
		magnet.bForceActive = true;
		magnetLight.SetEnabled(true);
	}
	else
	{
		magnet.bForceActive = false;
		magnetLight.SetEnabled(false);
		DoShock(self,AlloyTeamInfo(AlloyPlayerReplicationInfo(PlayerReplicationInfo).Team));
		//StopAnim();
		
	}
}

simulated function ReplicateMagnetToggled() {
	if (bMagnetOn)
	{
		magnet.bForceActive = true;
		magnetLight.SetEnabled(true);
	}
	else
	{
		magnet.bForceActive = false;
		magnetLight.SetEnabled(false);
		//StopAnim();
		
	}
}

//>>>>>> Temparary Comment out to clean up Log from replication Errors <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
//               DO NOT DELETE 
/*// Calculate the transition between magnet animations
simulated event Tick(float DeltaTime){
	super.Tick(DeltaTime);
	
	if(bMagnetOn && VSize(Velocity) !=0 && AlloyAnim.GetPlayedAnimation() != 'builderbot_anim_magmovactivate')
	{
		//PlayAnim('builderbot_anim_magmovactivate', true);
	} 
	else if (bMagnetOn && VSize(Velocity) ==0 && AlloyAnim.GetPlayedAnimation() != 'builderbot_anim_magactivate')
	{
		//PlayAnim('builderbot_anim_magactivate', true);
	}
}
//               DO NOT DELETE 
*/
//----------------------------------------------------------------------------




//-----------------------Camera Stuff----------------------------------------------
//-- Calcualte the Camera locations and rotations
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
   //`Log("CameraCalc");
	Mesh.GetSocketWorldLocationAndRotation('sock_camfocus', CamFocusPoint);
	out_CamLoc = CamFocusPoint;
	
	CamPitchRotation = ((CamOffsetDistance/50) - 10)*182; 
	CamHorizontalOffset = (Cos(CamPitchRotation  * UnrRotToRad) * (CamOffsetDistance));
	CamOffsetZ = Sin(CamPitchRotation  * UnrRotToRad) * (CamOffsetDistance);
	
	
	//16384 = 90 degrees. 65536 = 360. 1 degree = 182 
	//degree to radians (Pi / 180.0)
  
	//if ratation is turned off
	if(!bFollowPlayerRotation)
  {
    out_CamRot.Pitch = CamPitchRotation;
    out_CamRot.Yaw = 0;
    out_CamRot.Roll = 0;
		out_CamLoc.X += CamHorizontalOffset;
		out_CamLoc.Z += CamOffsetZ;
   }
   else
   {    
		//UDK randomly offsets the playerotation by large values over 180 degrees. Check for random offset
		if ( Rotation.Yaw - oldPlayerYawRotation > 32500 || Rotation.Yaw - oldPlayerYawRotation < -32500)
		{			
			CamYawRotation += Rotation.Yaw - oldPlayerYawRotation;//offset Camera by random offset
		}
		CamFloatDivisor = -(CamHorizontalOffset/20) + 10; //offset Camera by random offset
		CamVelocity = ((Rotation.Yaw) - (CamYawRotation))/CamFloatDivisor; //get the camera's velocity. 
		CamYawRotation += CamVelocity; 
		
		out_CamRot.Pitch = CamPitchRotation;
    out_CamRot.Yaw = CamYawRotation;
		out_CamRot.Roll = 0;
		
		//find the camera's horizontal positions
		CamOffsetY = Sin(CamYawRotation * UnrRotToRad) * CamHorizontalOffset;
		CamOffsetX = Cos(CamYawRotation * UnrRotToRad) * CamHorizontalOffset;	
		
		out_CamLoc.X += CamOffsetX;
		out_CamLoc.Y += CamOffsetY;
		out_CamLoc.Z += CamOffsetZ;
		
		oldPlayerYawRotation = Rotation.Yaw; //store old rotation.
		
		//`Log("CamVel " @CamVelocity);
		//`Log("CamRot         " @CamYawRotation);
		//`Log("PlyRot                            " @Rotation.Yaw);
	}
   return true;
}

simulated singular event Rotator GetBaseAimRotation()
{
   local rotator   POVRot, tempRot;

   tempRot = Rotation;
   tempRot.Pitch = 0;
   SetRotation(tempRot);
   POVRot = Rotation;
   POVRot.Pitch = 0; 

   return POVRot;
}

simulated function ZoomIn() {
	if(CamOffsetDistance < -100)
	{
		CamOffsetDistance += ZoomSpeed;
	}
	//`Log("Cam Float  :" @CamFloatDivisor);
	//`Log("Cam Rot  :" @CamPitchRotation);
	//`Log("Cam Dist :" @CamOffsetDistance);
	//`Log("Cam XDist:" @CamOffsetX);
	//`Log("Cam ZDist:" @CamOffsetZ);
	
	//`Log("isWalking  :" @bIsWalking);
}

simulated function ZoomOut() {
	if(CamOffsetDistance > -3000)
	{
		CamOffsetDistance -= ZoomSpeed;
	}
	
	//`Log("Cam Float  :" @CamFloatDivisor);
	//`Log("Cam Rot  :" @CamPitchRotation);
	//`Log("Cam Dist :" @CamOffsetDistance);
	//`Log("Cam XDist:" @CamOffsetX);
	// `Log("Cam ZDist:" @CamOffsetZ);
	
	//`Log("isWalking   :" @bIsWalking);
}
//----------------------------------------------------------------


//----------------------Bot Building------------------------------

//-- if the magnet is on, start looking for parts to pick up
simulated function CheckMagnetAndParts()
{
	if (magnet.bForceActive == true)
	{
		//`Log("Player Mag On");
		PickupParts(); //pick up parts nearby if magnet is active
	}
}


//-- Detaches any parts atached to the magnet.
simulated function DropParts() //Currently called in ToggleMagnet() in off position
{
	//If parts are not null, detach them from the magnet
	if(tHead != none){
		tHead.detachPart();
		tHead = none;
		tHead_name = 'none'; 
	}
	if(tPower != none){
		tPower.detachPart();
		tPower = none;
		tPower_name = 'none'; 
	}
	if(tTool != none){
		tTool.detachPart();
		tTool = none;
		tTool_name = 'none'; 
	}
	if(tLoco != none){
		tLoco.detachPart();
		tLoco = none;
		tLoco_name = 'none'; 
	}
	
	//clear bools
	bHead = false;
	bPower = false;
	bTool = false;
	bLoco = false;
	
}


//-- Check to see if there are parts near the magnet and then attaches them to the magnet socket if they are
simulated function PickupParts() // Called in CheckMagnetAndParts()
{
	local AlloyPartPawn AP; //current AlloyPartPawn
	local float Distance; // current distance of AP
	local Vector MagLocation;//
	local int SpawnRadius; //local spawn radius	
	SpawnRadius = 50; 
	
	Mesh.GetSocketWorldLocationAndRotation('sc_magnet', MagLocation);// get the current magnet location
	
	foreach WorldInfo.AllActors(class'AlloyPartPawn', AP)
	{
		if(AP.GetBaseMost() == none)
		{
			AP.setPhysicsToDetached();
		}
		
		Distance = Vsize( MagLocation - AP.getLocation());	//get the distence of the part from the magnet and the current part	
		if(AP.AlloyAIComponentActive.Tag == "head" && AP.bIsAttached == False && bHead == false && Distance < SpawnRadius)
		{
			bHead = true;
			tHead = AP;
			tHead.attachPart(self, Mesh, 'sock_head');
			tHead_name = AP.name;
			
			if( Role < Role_Authority ) // tell the server to replicate attachment
  		{
    		ServerReplicatePartAttachment(AP.name);
  		}
				
			//`Log("Found Head");
		}
		else if(AP.AlloyAIComponentActive.Tag == "power" && AP.bIsAttached == False && bPower == false && Distance < SpawnRadius)
		{
			bPower = true;
			tPower = AP;
			tPower.attachPart(self, Mesh, 'sock_power');	
			tPower_name = AP.name;
			
			if( Role < Role_Authority ) // tell the server to replicate attachment
  		{
    		ServerReplicatePartAttachment(AP.name);
  		}
			//`Log("Found Power");
		}
		else if(AP.AlloyAIComponentActive.Tag == "tool" && AP.bIsAttached == False && bTool == false && Distance < SpawnRadius)
		{
			bTool = true;
			tTool = AP;
			tTool.attachPart(self, Mesh, 'sock_arms');	
			tTool_name = AP.name;
			
			if( Role < Role_Authority ) // tell the server to replicate attachment
  		{
    		ServerReplicatePartAttachment(AP.name);
  		}
			//`Log("Found Tool");
		}
		else if(AP.AlloyAIComponentActive.Tag == "loco" && AP.bIsAttached == False && bLoco == false && Distance < SpawnRadius)
		{
			bLoco = true;
			tLoco = AP;
			tLoco.attachPart(self, Mesh, 'sock_loco');
			tLoco_name = AP.name;	
			
			if( Role < Role_Authority ) // tell the server to replicate attachment
  		{
    		ServerReplicatePartAttachment(AP.name);
  		}
			//`Log("Found Loco");
		}
	}
		
}



// --Builds a bot if it has 1 of each part
simulated function DoShock(Pawn P, AlloyTeamInfo PlayerTeam) 
{
	local Vector MagLocation;//
	local AlloyBotPawn makeBot; //new AlloyBot
	`Log("Found:" @bHead @bPower @bTool @bLoco);
  	//-- if enough parts were found spawn bot --
	if (bHead == true && bPower == true && bTool == true && bLoco == true)
	{	
			tHead.SetBase(none); //clear part bases, just incase
			tPower.SetBase(none);
			tTool.SetBase(none);
			tLoco.SetBase(none);
		
			Mesh.GetSocketWorldLocationAndRotation('sock_botspawn', MagLocation); //get the magnet location
		
			makeBot = Spawn(class'AlloyBotPawn',self,, MagLocation+vect(0,0,10)); //spawn the bot
  
			makeBot.SpawnDefaultController();//spawn the AI controler
			makeBot.UpdateBotTeam(PlayerTeam); // set the team for the AI controller
			makeBot.setComponentsForBot(tHead, tPower, tTool, tLoco); //give it its parts
		
			//`Log("New bot's controller: "@makeBot.Controller);	
			//`Log("new bot's location: "@makeBot.Location);
		
			bHead = false; //clear bools
			bPower = false;
			bTool = false;
			bLoco = false;
	
			tHead = none; //clear parts attached to magnet
			tPower = none;
			tTool = none;
			tLoco = none;
		
	}
	else
	{
		DropParts(); //drop all parts attaced to magnet
	}
	
	
}
//-----------------------------------------------------------------------------------




//-----------------------Animation---------------------------------------------------
function PlayAnim(Name inAnim, optional bool loop){
	local AnimNode node;
	
	//		 AlloyAnim = AnimNodeSlot(SkeletalMeshComponent.FindAnimNode('AlloyCustomAnim'));
	node = Mesh.FindAnimNode('AlloyCustomAnim');
	

	if(AlloyAnim == none)
	{
		 AlloyAnim = AnimNodeSlot(node);
	}

//	AlloyAnim.StopCustomAnim(1.0);
//	`Log("Calling AlloyAnim: "@AlloyAnim);
	AlloyAnim.PlayCustomAnim(inAnim , 1.0, 0.5, 0.5, loop , true);
}


function StopAnim(){
	AlloyAnim.StopCustomAnim(0.8);
}

event Landed(Object.Vector HitNormal, Actor FloorActor)
{
	super.Landed(HitNormal, FloorActor);
	AlloyPlayerController(Controller).bAirborne = false;
}

event Falling()
{
	super.Falling();
	AlloyPlayerController(Controller).bAirborne = true;
}
//----------------------------------------------------------------------------


//override to make player mesh visible by default
simulated event BecomeViewTarget( PlayerController PC )
{
   local UTPlayerController UTPC;

   Super.BecomeViewTarget(PC);

   if (LocalPlayer(PC.Player) != None)
   {
      UTPC = UTPlayerController(PC);
      if (UTPC != None)
      {
         //set player controller to behind view and make mesh visible
         UTPC.SetBehindView(true);
         SetMeshVisibility(UTPC.bBehindView); 
         UTPC.bNoCrosshair = true;
      }
   }
}


defaultproperties
{
	HealthMax = 100
	Tag = "AlloyBot"
	bCanBeBaseForPawns=true
	
	shock = SoundCue'sound_alloyEffects.soundCue_builder1'
	
	TickGroup=TG_PostAsyncWork//seems to make the Player and other pawns udate their postions properly. allready set in subclasss
	
	Begin Object Class=SkeletalMeshComponent Name=BuilderBotSkeletalMeshComponent     
		SkeletalMesh=SkeletalMesh'bb_builderBot.builderBot_mesh'
		AnimSets(0)=AnimSet'bb_builderBot.builderBot_animSet'
		AnimTreeTemplate=AnimTree'bb_builderBot.builderBot_animTree'
		PhysicsAsset=PhysicsAsset'bb_builderBot.builderBot_mesh_Physics'
		
        PhysicsWeight=1.000000
        bSkipAllUpdateWhenPhysicsAsleep=True
        bHasPhysicsAssetInstance=True
        bUpdateKinematicBonesFromAnimation=True
        ReplacementPrimitive=None
            
        RBChannel=RBCC_GameplayPhysics
        CollideActors=True
        BlockActors=True
        BlockZeroExtent=True
        BlockRigidBody=True
        bBlockFootPlacement=False
            
        RBCollideWithChannels=(Default=True,GameplayPhysics=True,EffectPhysics=True,BlockingVolume=True)
        ObjectArchetype=SkeletalMeshComponent'Engine.Default__KAsset:KAssetSkelMeshComponent'
		
		LightEnvironment=MyLightEnvironment
		bAcceptsLights=true
		
		
	End Object
	Components.Add(BuilderBotSkeletalMeshComponent)
	Mesh=BuilderBotSkeletalMeshComponent
	
		Begin Object Class=NxForceFieldRadialComponent Name=BuilderBotNxForceFieldRadialComponent
		ForceRadius=200.0
		ForceStrength=-200.0
		SelfRotationStrength=0.0
		bDestroyWhenInactive=false
		
		ForceFalloff=RIF_Constant
	
	End Object
	Components.Add(BuilderBotNxForceFieldRadialComponent)
	magnet=BuilderBotNxForceFieldRadialComponent
	
	
	Begin Object Class=PointLightComponent Name=PointLightComponent0  
        Radius=256.000000
        LightmassSettings=(LightSourceRadius=32.000000)
        Brightness=8.000000
        LightColor=(B=255,G=50,R=0,A=0)
        
        
        
    End Object
	Components.Add(PointLightComponent0)
	magnetLight = PointLightComponent0;
	
	
  bFollowPlayerRotation = true;
  ZoomSpeed=100.0;
  CamOffsetDistance= -200.0
	
	
}