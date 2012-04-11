class AlloyBotPawnSingle extends AlloyBotPawn
	Placeable;

var AlloyPartPawn PawnArchetype;

var AlloyPartPawn Heads;
var array<AlloyPartPawn> Powers;
var array<AlloyPartPawn> Locos;
var array<AlloyPartPawn> Tools;

var bool bLoco, bTool, bHead, bPower;

simulated event PostBeginPlay()
{
	`Log("Single Pawn made!");
	`Log("bStatic: "@bStatic);
	`Log("bNoDelete: "@bNoDelete);
//	Heads = AlloyPartPawn'head_aggressive.AlloyPartPawn_head_aggressive';
	Super.PostBeginPlay();
	grabNearby();
	//setComponentsForBot(AlloyPartPawn h, AlloyPartPawn p, AlloyPartPawn t, AlloyPartPawn l)
	
}

function grabNearby()
{
	local AlloyPartPawn AP; //current AlloyPartPawn
	local float Distance; // current distance of AP
	local int SpawnRadius; //local spawn radius	
	local AlloyTeamInfo team;
	SpawnRadius = 200; 
	
//	Spawn(class'AlloyBotPawn',self);
	
	foreach WorldInfo.AllActors(class'AlloyPartPawn', AP)
	{
		if(AP.GetBaseMost() == none)
		{
			AP.setPhysicsToDetached();
		}
		
		Distance = Vsize( Location - AP.getLocation());	//get the distence of the part from the magnet and the current part	
		if(AP.AlloyAIComponentActive.Tag == "head" && AP.bIsAttached == False && bHead == false && Distance < SpawnRadius)
		{
			bHead = true;
			HeadPart = AP;
			tHead_name = AP.name;
			
			if( Role < Role_Authority ) // tell the server to replicate attachment
  		{
//    		ServerReplicatePartAttachment(AP.name);
  		}
				
			`Log("Found Head");
		}
		else if(AP.AlloyAIComponentActive.Tag == "power" && AP.bIsAttached == False && bPower == false && Distance < SpawnRadius)
		{
			bPower = true;
			PowerPart = AP;
			tPower_name = AP.name;
			
			if( Role < Role_Authority ) // tell the server to replicate attachment
  		{
//    		ServerReplicatePartAttachment(AP.name);
  		}
			`Log("Found Power");
		}
		else if(AP.AlloyAIComponentActive.Tag == "tool" && AP.bIsAttached == False && bTool == false && Distance < SpawnRadius)
		{
			bTool = true;
			ToolPart = AP;
			tTool_name = AP.name;
			
			if( Role < Role_Authority ) // tell the server to replicate attachment
  		{
//				ServerReplicatePartAttachment(AP.name);
  		}
			`Log("Found Tool");
		}
		else if(AP.AlloyAIComponentActive.Tag == "loco" && AP.bIsAttached == False && bLoco == false && Distance < SpawnRadius)
		{
			bLoco = true;
			LocoPart = AP;
			tLoco_name = AP.name;	
			
			if( Role < Role_Authority ) // tell the server to replicate attachment
  		{
//    		ServerReplicatePartAttachment(AP.name);
  		}
			`Log("Found Loco");
		}
	}
	
	  SpawnDefaultController();//spawn the AI controler
		team = spawn(class'AlloyTeamInfo');
		team.Initialize(5);
		UpdateBotTeam(team); // set the team for the AI controller
		setComponentsForBot(HeadPart, PowerPart, ToolPart, LocoPart); //give it its parts
		
}

/*
		makeBot = Spawn(class'AlloyBotPawn',self,, MagLocation+vect(0,0,10)); //spawn the bot
  	makeBot.SpawnDefaultController();//spawn the AI controler
		makeBot.UpdateBotTeam(PlayerTeam); // set the team for the AI controller
		makeBot.setComponentsForBot(tHead, tPower, tTool, tLoco); //give it its parts
*/

defaultproperties{

	
	}