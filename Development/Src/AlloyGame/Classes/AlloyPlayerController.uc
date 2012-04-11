class AlloyPlayerController extends UTPlayerController;

var vector PlayerViewOffset;


var Vector2D    PlayerMouse;                //Hold calculated mouse position (this is calculated in HUD)

var Vector      MouseHitWorldLocation;      //Hold where the ray casted from the mouse in 3d coordinate intersect with world geometry. We will
//use this information for our movement target when not in pathfinding.

var Vector      MouseHitWorldNormal;        //Hold the normalized vector of world location to get direction to MouseHitWorldLocation (calculated in HUD, not used)
var Vector      MousePosWorldLocation;      //Hold deprojected mouse location in 3d world coordinates. (calculated in HUD, not used)
var Vector      MousePosWorldNormal;        //Hold deprojected mouse location normal. (calculated in HUD, used for camera ray from above)



/*****************************************************************
*  Calculated in Hud after mouse deprojection, uses MousePosWorldNormal as direction vector
*  This is what calculated MouseHitWorldLocation and MouseHitWorldNormal.
*
*  See Hud.PostRender, Mouse deprojection needs Canvas variable.
*
*  **/
var vector      StartTrace;                 //Hold calculated start of ray from camera
var Vector      EndTrace;                   //Hold calculated end of ray from camera to ground
var vector      RayDir;                     //Hold the direction for the ray query.
var Vector      PawnEyeLocation;            //Hold location of pawn eye for rays that query if an obstacle exist to destination to pathfind.
var Actor       TraceActor;                 //If an actor is found under mouse cursor when mouse moves, its going to end up here.
//var AlloyMouseCursor MouseCursor; //Hold the 3d mouse cursor

var float DeltaTimeAccumulated; //Accumulate time to check for mouse clicks
var bool bLeftMousePressed; //Initialize this function in StartFire and off in StopFire
var bool bRightMousePressed; //Initialize this function in StartFire and off in StopFire

var bool bAirborne;

var AlloyMusicManager AlloyMusic;

simulated event PostBeginPlay()
{
	//local byte teamNum;
	//teamNum = GetTeamNum();
	super.PostBeginPlay();
//	MouseCursor = Spawn(class'AlloyMouseCursor', self, 'marker');
	AlloyMusic = Spawn(class'AlloyMusicManager', self);
	//`Log("Im up and my team is: "@teamNum);
}

simulated function SetTeam(AlloyTeamInfo NewTeam)
{
	AlloyPlayerReplicationInfo(PlayerReplicationInfo).Team = NewTeam;
	`Log("I've been assigned to team "@GetTeamNum());
}



state PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;

   function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
   {
      if( Pawn == None )
      {
         return;
      }

      if (Role == ROLE_Authority)
      {
         // Update ViewPitch for remote clients
         Pawn.SetRemoteViewPitch( Rotation.Pitch );
      }

      Pawn.Acceleration = NewAccel;

      CheckJumpOrDuck();
   }
}

function PlayerTick(Float Delta)
{
	//`Log("Player Pawn Tick");
	
	AlloyPlayerPawn(Pawn).CheckMagnetAndParts();
	
	super.PlayerTick(Delta);
		
}


function UpdateRotation( float DeltaTime )
{
   local Rotator   DeltaRot, newRotation, ViewRotation;

   ViewRotation = Rotation;
   if (Pawn!=none)
   {
      Pawn.SetDesiredRotation(ViewRotation);
   }

   // Calculate Delta to be applied on ViewRotation
   DeltaRot.Yaw   = PlayerInput.aTurn;
   DeltaRot.Pitch   = 0;

   ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
   SetRotation(ViewRotation);

   NewRotation = ViewRotation;
   NewRotation.Roll = Rotation.Roll;

   if ( Pawn != None )
      Pawn.FaceRotation(NewRotation, deltatime);
}

exec function ZoomIn() {
//	`Log("Zooming In -- OK");
	AlloyPlayerPawn(Pawn).ZoomIn();
}

exec function ZoomOut() {
//	`Log("Zooming Out -- OK");
	AlloyPlayerPawn(Pawn).ZoomOut();
}

/* NEED TO REMAP THESE THAT FOLLOW: */

function CheckJumpOrDuck() {
	super.CheckJumpOrDuck();
		
		
		if ( bPressedJump && (Pawn != None) && !bAirborne) {
			
			AlloyPlayerPawn(Pawn).PlayAnim('builderbot_anim_jump', false);
			bAirborne = true;
			
			AlloyPlayerPawn(Pawn).PrintActors();
		}
		
		

/*	
	// If the player presses the jump button and there exists a pawn
	if ( bPressedJump && (Pawn != None) ) {
		// Typecast the pawn to type AlloyPlayerPawn and execute its DoShock function.
		AlloyPlayerPawn(Pawn).DoShock(Pawn, AlloyTeamInfo(AlloyPlayerReplicationInfo(PlayerReplicationInfo).Team));
	}
*/
}



exec function StartFire(optional byte FireModeNum)
{

  //Initialize mouse pressed over time.
  bLeftMousePressed = FireModeNum == 0;
  bRightMousePressed = FireModeNum == 1 ;

  //comment these if not needed
  if(bLeftMousePressed)
	{
		//`Log("Left Mouse pressed");
		AlloyPlayerPawn(Pawn).ToggleMagnet();
			
	}
  if(bRightMousePressed) 
	{
			//`Log("Right Mouse pressed");
	}
}

exec function StopFire(optional byte FireModeNum )
{
  //`Log("delta accumulated"@DeltaTimeAccumulated);
  //Un-Initialize mouse pressed over time.
  if(bLeftMousePressed && FireModeNum == 0)
  {		
    bLeftMousePressed = false;
    //`Log("Left Mouse released");
  }
  if(bRightMousePressed && FireModeNum == 1)
  {
  	bRightMousePressed = false;
    //`Log("Right Mouse released");
  }
}



/* CONSOLE DEBUGGGING FUNCTIONS */

exec function AlloyTakeDamage(float damage)
{
	Pawn.Health = Pawn.Health - damage;
}

exec function AlloyChangeTeam(int teamNum)
{
	local AlloyTeamInfo Teams;
	Teams = spawn(class'AlloyTeamInfo');
	Teams.Initialize(teamNum);
	WorldInfo.Game.GameReplicationInfo.SetTeam(teamNum, Teams);
}


defaultproperties
{
	InputClass=class'AlloyPlayerInput'
}