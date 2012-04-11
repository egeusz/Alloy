class AlloyAIController extends GameAIController;

// distance to wandergoal before it has 'reached it'
var int WANDERDISTANCEGOAL;


// VectorLocation of Target
var Vector TargetLoc;

// AI team 
var AlloyTeamInfo team;



// Actor Target
var Actor TargetActor; // PathNode, or AIRObot, or allied robot, builderbot

// Search Target
var class<Actor> SearchTargetType;

// Search Range of current AI
var float TargetViewRange;

// Tool range of Use()
var float ToolRange;

// Main bot Pawn that holds all the parts
var AlloyBotPawn myPawn;


// what kinds of parts are attached to the bot
	var AlloyAIComponent_Loco Loco;
	var AlloyAIComponent_Power Power;
	var AlloyAIComponent_Tool Tool;	
	var AlloyAIComponent_Head Head;


//at the start of the level
simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	

	team = AlloyGame(WorldInfo.Game).GetTeam(1);
	team.AddToTeam( self );
	`Log("My team: "@team.GetTeamNum());
}

// once the bot appears in game, associate the pawn with the AI controller.
event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);
	Pawn.SetMovementPhysics();
}

// Get Bot parts (components)
function SetupPawn(){
	`Log("My Pawn: "@Pawn);
	myPawn =    AlloyBotPawn(Pawn);
	Loco =      myPawn.LocoAI;
	Power =     myPawn.PowerAI;
	Tool =      myPawn.ToolAI;
	Head =      myPawn.HeadAI;
	
	SetupAI();
	
	SearchTargetType = Head.GetTargetType();
	`Log("TargetType: "@SearchTargetType);
	TargetViewRange = Head.GetViewRange();
	ToolRange = Tool.GetRange();
}

function SetupAI(){
	Head.Initialize();
	Tool.Initialize();
}



/* Getters and Setters */
function NavigationPoint GetWanderGoal(){
	return FindRandomDest();
}

function SetTargetActor(Actor target){
	TargetActor = target;
}

function Actor GetTargetActor(){
	return TargetActor;
}

function NavigateTowards(Actor moveTarget1){
	local Vector targetLocation;
	
	SetDestinationPosition(moveTarget.Location);
	targetLocation = moveTarget.Location;
	
	if( FastTrace(targetLocation, Pawn.Location)){ // and better check here!
//		MoveToward(moveTarget);
	}else{
		
//		MoveToward(moveTarget);//Put better pathfinding here!
	}
}


//Returns closest actor within TargetViewRange that appeases Head.Search 
function Search(){
	local Actor A;
	local Actor closest;
	local float cdist;
	local float dist;
	
//	`Log("Searching: "@Pawn.Controller);
	cdist = 0.0;
	
	ForEach WorldInfo.AllActors(SearchTargetType, A){//
//		`Log("looking at: "@A);
		dist = VSize(Pawn.Location - A.Location);
//		`Log("dist: "@dist);
//		`Log("PawnLocation: "@Pawn.Location);
//		`Log("A Location: "@A.Location);
		if( Pawn != A && cdist == 0.0 && Head.Search(A)) {
			cdist = dist;
			closest = A;
		} else if( Pawn != A && dist < cdist && Head.Search(A)) {
			cdist = dist;
			closest = A;
		}
	}

	if(cdist != 0.0 && cdist < TargetViewRange) {
//		`Log("Target Found: "@closest);
//		`Log("Target Pos: "@closest.Location);
		SetTargetActor(closest);
		GotoState('ApproachTarget');
	} else {
//	`Log("Cdist: "@cdist);
//	`Log("No target found of type: "@SearchTargetType);
	
	}
}

function UseTool(AlloyAIController control, Actor target){
	Tool.Use(self, target);
}

// Default state in which the robot looks for a target, calls Search() on tick if a target is found in Search
// the state ApproachTarget is pushed
state auto Wander{

	local Actor WanderGoal;
	local float dist;
	
function Tick(Float Delta){
	Search();
	
	if(WanderGoal == none){
		WanderGoal = GetWanderGoal();
	}
	
	dist = VSize(Pawn.Location - WanderGoal.Location);
	if(dist < WanderDistanceGoal){
  	WanderGoal = GetWanderGoal();
	}
}

Begin:
	`Log("Entering wander state");
	Sleep(0); //http://forums.epicgames.com/threads/842897-Improving-my-AI-efficiency
	if(WanderGoal == none){
		WanderGoal = GetWanderGoal();
	}
	if(Actorreachable(WanderGoal))
{
//  MoveToward(TargetActor);
	MoveToward(WanderGoal);
}
else
{
	FindPathTo(WanderGoal.Location);

  MoveTarget = FindPathToward(RouteCache[0]);
  MoveToward(MoveTarget);
}
//	moveTo(TargetActor.Location);
	if(dist > ToolRange)
	{
		goto('Begin');
	}
	
}
	
// State in which the robot moves towards his target until he is in ToolRange at which
// point he pushes the state EngageTarget to use the Tool.
state ApproachTarget{

//	local Actor MoveTarget;
	local float dist;
	
function Tick (Float Delta){
	
	if(TargetActor == none){
	GotoState('Wander');
	}
	
	dist = VSize(Pawn.Location - TargetActor.Location);
	// if the 'Use Tool' results in success and the job is done
	// Target Actor is set to none and the state is Poped next round
	if(dist < ToolRange){
		GotoState('EngageTarget');
	}
	

	
}

Begin:
	Sleep(0); //http://forums.epicgames.com/threads/842897-Improving-my-AI-efficiency
//	`Log("Entering ApproachTarget state:"@Head);
	
if(Actorreachable(TargetActor))
{
//  MoveToward(TargetActor);
	MoveToward(TargetActor);
}
else
{

	FindPathTo(TargetActor.Location);

  MoveTarget = FindPathToward(RouteCache[0]);
  MoveToward(MoveTarget);
}
//	moveTo(TargetActor.Location);
//	`Log("Finished moving towards");
//	`Log("Tool Range: "@ToolRange);
	if(dist > ToolRange)
	{
		goto('Begin');
	}
	
}


// Tool in which the tool is used assuming it is still in range, and then pops out to Engaging the target again
state EngageTarget{
	
	local float dist;
	
Begin:
	Sleep(0);
//	`Log("Entering EngageTarget state "@Head);
	dist = VSize(Pawn.Location - TargetActor.Location);
	if(dist < ToolRange){
		Pawn.Velocity = vect(0,0,0);
		Pawn.Acceleration = vect(0,0,0);
//		`Log("Using tool on: "@TargetActor);
		Head.HeadUseTool(self, TargetActor);
	}
//	`Log("popping EngagmentState "@Head);
	GotoState('ApproachTarget');
}
	

defaultproperties
{
	Tag = "ROBOT"
	WanderDistanceGoal = 1000;
}
