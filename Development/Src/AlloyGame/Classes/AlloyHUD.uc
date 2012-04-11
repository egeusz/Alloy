class AlloyHUD extends HUD;

var bool bDrawTraces; //Hold exec console function switch to display debug of trace lines & Paths.
// The texture which represents the cursor on the screen
var const Texture2D CursorTexture; 
// The color of the cursor
var const Color CursorColor;

var FontRenderInfo TextRenderInfo; //Font for outputed text to viewport


event PostRender()
{
        local AlloyIsoCamera PlayerCam;
        local AlloyPlayerController IsoPlayerController;

        super.PostRender();

        //Get a type casted reference to our custom player controller.
        IsoPlayerController = AlloyPlayerController(PlayerOwner);

        //Get the mouse coordinates from the GameUISceneClient
        IsoPlayerController.PlayerMouse = GetMouseCoordinates();
        //Deproject the 2d mouse coordinate into 3d world. Store the MousePosWorldLocation and normal (direction).
        Canvas.DeProject(IsoPlayerController.PlayerMouse, IsoPlayerController.MousePosWorldLocation, IsoPlayerController.MousePosWorldNormal);

        //Get a type casted reference to our custom camera.
        PlayerCam = AlloyIsoCamera(IsoPlayerController.PlayerCamera);

        //Calculate a trace from Player camera + 100 up(z) in direction of deprojected MousePosWorldNormal (the direction of the mouse).
        //-----------------
        //Set the ray direction as the mouseWorldnormal
        IsoPlayerController.RayDir = IsoPlayerController.MousePosWorldNormal;
        //Start the trace at the player camera (isometric) + 100 unit z and a little offset in front of the camera (direction *10)
        IsoPlayerController.StartTrace = (PlayerCam.ViewTarget.POV.Location + vect(0,0,100)) + IsoPlayerController.RayDir * 10;
        //End this ray at start + the direction multiplied by given distance (5000 unit is far enough generally)
        IsoPlayerController.EndTrace = IsoPlayerController.StartTrace + IsoPlayerController.RayDir * 5000;

        //Trace MouseHitWorldLocation each frame to world location (here you can get from the trace the actors that are hit by the trace, for the sake of this
        //simple tutorial, we do noting with the result, but if you would filter clicks only on terrain, or if the player clicks on an npc, you would want to inspect
        //the object hit in the StartFire function
        IsoPlayerController.TraceActor = Trace(IsoPlayerController.MouseHitWorldLocation, IsoPlayerController.MouseHitWorldNormal, IsoPlayerController.EndTrace, IsoPlayerController.StartTrace, true);

        //Calculate the pawn eye location for debug ray and for checking obstacles on click.
        IsoPlayerController.PawnEyeLocation = Pawn(PlayerOwner.ViewTarget).Location + Pawn(PlayerOwner.ViewTarget).EyeHeight * vect(0,0,1);

        //Your basic draw hud routine
        DrawHUD();


  if(bDrawTraces)
		{
			//If display is enabled from console, then draw Pathfinding routes and rays.
			super.DrawRoute(Pawn(PlayerOwner.ViewTarget));
			DrawTraceDebugRays();
		}

  Super.PostRender();

}

function vector2D GetMouseCoordinates()
{
  local AlloyPlayerInput MouseInterfacePlayerInput;
  local Vector2D MousePosition;


  // Ensure that we have a valid canvas and player owner
  if (Canvas == None || PlayerOwner == None)
  {
    return vect2D(0, 0);
  }

  // Type cast to get the new player input
  MouseInterfacePlayerInput = AlloyPlayerInput(PlayerOwner.PlayerInput);

  // Ensure that the player input is valid
  if (MouseInterfacePlayerInput == None)
  {
    return vect2D(0, 0);
  }

  // We stored the mouse position as an IntPoint, but it's needed as a Vector2D
  MousePosition.X = MouseInterfacePlayerInput.MousePosition.X;
  MousePosition.Y = MouseInterfacePlayerInput.MousePosition.Y;

	return MousePosition;
}

exec function ToggleIsometricDebug()
{
        bDrawTraces = !bDrawTraces;
        if(bDrawTraces)
        {
                `Log("Showing debug line trace for mouse");
        }
        else
        {
                `Log("Disabling debug line trace for mouse");
        }
}

function DrawTraceDebugRays()
{
        local AlloyPlayerController IsoPlayerController;
        IsoPlayerController = AlloyPlayerController(PlayerOwner);

        //Draw Trace from the camera to the world using
        Draw3DLine(IsoPlayerController.StartTrace, IsoPlayerController.EndTrace, MakeColor(255,128,128,255));

        //Draw eye ray for collision and determine if a clear running is permitted(no obstacles between pawn && destination)
        Draw3DLine(IsoPlayerController.PawnEyeLocation, IsoPlayerController.MouseHitWorldLocation, MakeColor(0,200,255,255));
}

defaultproperties
{
	CursorColor=(R=255,G=255,B=255,A=255)
	CursorTexture=Texture2D'EngineResources.Cursors.Arrow'
}