class AlloyPlayerPawn extends UTPawn;

var SkeletalMeshComponent BBSkeletalMeshComponent; 

var PointLightComponent magnetLight;
var NxForceFieldRadialComponent magnet;

var SoundCue shock;

var float CamOffsetDistance; //distance to offset the camera above the player
var float CamPitchRotation; // rotation of camera
var float CamOffsetX;// camera offset x
var float CamOffsetZ;// camera offset y
var bool bFollowPlayerRotation; //If true, camera rotates with player
var float ZoomSpeed;


simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	`Log("Custom Pawn up");
	
	Mesh.AttachComponentToSocket(magnet, 'sc_magnet');
	magnet.bForceActive = false;
	Mesh.AttachComponentToSocket(magnetLight, 'sc_magnet');
	magnetLight.SetEnabled(false);
}

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


//toggles the magnet on or off
simulated function ToggleMagnet()
{
	if (magnet.bForceActive == false)
	{
		magnet.bForceActive = true;
		magnetLight.SetEnabled(true);
	}
	else
	{
		magnet.bForceActive = false;
		magnetLight.SetEnabled(false);
	}


}


simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
   //`Log("CameraCalc");
	
	out_CamLoc = Location;
	//CameraRotation = ATan2(CamOffsetY,CamOffsetX);
	CamPitchRotation = ((CamOffsetDistance/50) - 10)*182; 
	CamOffsetX = (Cos(CamPitchRotation  * UnrRotToRad) * (CamOffsetDistance));
	CamOffsetZ = Sin(CamPitchRotation  * UnrRotToRad) * (CamOffsetDistance);
	
	
	//16384 = 90 degrees. 1 degree = 182 
	//degree to radians (Pi / 180.0)
  if(!bFollowPlayerRotation)
  {
    out_CamRot.Pitch = CamPitchRotation;
    out_CamRot.Yaw = 0;
    out_CamRot.Roll = 0;
			
		out_CamLoc.X += CamOffsetX;
		out_CamLoc.Z += CamOffsetZ;
   }
   else
   {
    out_CamRot.Pitch = CamPitchRotation;
    out_CamRot.Yaw = Rotation.Yaw;
    out_CamRot.Roll = 0;
			
		out_CamLoc.X += CamOffsetX;
		out_CamLoc.Z += CamOffsetZ;
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
	
	`Log("Cam Rot  :" @CamPitchRotation);
	`Log("Cam Dist :" @CamOffsetDistance);
	`Log("Cam XDist:" @CamOffsetX);
	`Log("Cam ZDist:" @CamOffsetZ);
	
	
}

simulated function ZoomOut() {
	
	if(CamOffsetDistance > -3000)
	{
		CamOffsetDistance -= ZoomSpeed;
	}
	
	
	`Log("Cam Rot  :" @CamPitchRotation);
	`Log("Cam Dist :" @CamOffsetDistance);
	`Log("Cam XDist:" @CamOffsetX);
  `Log("Cam ZDist:" @CamOffsetZ);
	
}


//run on spacebar push, responsible for finding nearest 4 components and creating bot
simulated function TogglePartPhysics()
{
	local AlloyPartPawn AP;

	foreach WorldInfo.AllActors(class'AlloyPartPawn', AP)
	{
			if (AP.bIsAttachedToBot == true)
			{
					AP.setPhysicsToDetached();
			}
			else
			{
					AP.setPhysicsToAttached();
			}
	}

}

simulated function DoShock(Pawn P) 
{
	
	
	local AlloyPartPawn AP; //current AlloyPartPawn
	local float Distance; // current distance of AP
	local AlloyBotPawn makeBot; //new AlloyBot
	local AlloyPartPawn tLoco, tTool, tHead, tPower; //temporary variables to hold the components
	local bool bLoco, bTool, bHead, bPower; //bools that, when true, mean that the tActor variables contain an actor, thus we can spawn our AlloyBot
	local int SpawnRadius; //local spawn radius	
	
		
	`Log("Doing Shock");
	
	bHead = false;
	bPower = false;
	bTool = false;
	bLoco = false;
	
	
	SpawnRadius = 200; 
	
	foreach WorldInfo.AllActors(class'AlloyPartPawn', AP)
	{
		
		//-- get the socket location for the part because in detacehd physics mode the pawn location is not updated with the mesh location. 
		Distance = Vsize( P.Location - AP.getLocation()); //calculate distence based on socket location
		//`Log("Sock_loc: " @AP.getLocation());
		//`Log("Pawn_loc: " @AP.Location);
		if(AP.AlloyAIComponentActive.Tag == "head" && AP.bIsAttachedToBot == false && Distance < SpawnRadius)
		{
			bHead = true;
			tHead = AP;
			//`Log("Found Head");
		}
		else if(AP.AlloyAIComponentActive.Tag == "power" && AP.bIsAttachedToBot == false && Distance < SpawnRadius)
		{
			bPower = true;
			tPower = AP;
			//`Log("Found Power");
		}
		else if(AP.AlloyAIComponentActive.Tag == "tool" && AP.bIsAttachedToBot == false && Distance < SpawnRadius)
		{
			bTool = true;
			tTool = AP;
			//`Log("Found Tool");
			
		}
		else if(AP.AlloyAIComponentActive.Tag == "loco" && AP.bIsAttachedToBot == false && Distance < SpawnRadius)
		{
			bLoco = true;
			tLoco = AP;
			//`Log("Found Loco");
		}
	}
	
	
	//-- if enough parts were found spawn bot --
	`Log("Found:" @bHead @bPower @bTool @bLoco);
	if (bHead == true && bPower == true && bTool == true && bLoco == true)
	{	
			makeBot = Spawn(class'AlloyBotPawn',self,, P.Location+vect(0,200,200)); //spawn the bot
			makeBot.setComponentsForBot(tHead, tPower, tTool, tLoco); //give it its parts
//			makeBot.SpawnDefaultController();//spawn the AI controler
			`Log("New bot's controller: "@makeBot.Controller);
			
			`Log("new bot's location: "@makeBot.Location);
			

	}

}

defaultproperties
{

	bCanBeBaseForPawns=true
	
	shock = SoundCue'sound_alloyEffects.soundCue_builder1'
	
	
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
	
	
  bFollowPlayerRotation = false;
  ZoomSpeed=100.0;
  CamOffsetDistance= -200.0
	
	
}