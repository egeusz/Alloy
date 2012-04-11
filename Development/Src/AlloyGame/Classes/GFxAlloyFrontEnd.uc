/**********************************************************************

Filename    :   GFxAlloyFrontEnd.uc
Content     :   GFx-UDK Front End Implementaiton

Copyright   :   (c) 2010 Scaleform Corp. All Rights Reserved.

Notes       :   A manager for the UDK's front end menu. This class loads
                all of the menu views as MovieClips into itself using 
                attachMovie() and loadMovie(). The data for the views 
                defined in DefaultUI.ini. 

                All loaded views contain a reference to this class for general 
                menu functionality including pushing/popping views, spawning dialogs,
                setting focus, and setting Escape/Back key press events.                

                There is an ActionScript class associated with this manager:
                MenuManager.as. That class contains logic for animating views
                and utilizing necessary GFx AS extensions (eg. Selection["modalClip"]).

                Associated Flash content: udk_manager.fla

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING 
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/
class GFxAlloyFrontEnd extends GFxMoviePlayer
    config(UI);

/** Reference to _root of the movie's (udk_manager.swf) stage. */
var GFxObject RootMC;

/** Reference to the manager MovieClip (_root.manager) where views will be attached. */
var GFxObject ManagerMC;

var bool bInitialized;

/** View declarations. */
var GFxAlloyFrontEnd_MainMenu MainMenuView;

var GFxAlloyFrontEnd_InstantAction InstantActionView;

var GFxAlloyFrontEnd_Multiplayer MultiplayerView;

var GFxAlloyFrontEnd_HostGame HostGameView;

var GFxAlloyFrontEnd_MapSelect MapSelectView;

var GFxAlloyFrontEnd_GameMode GameModeView;

var GFxAlloyFrontEnd_Mutators MutatorsView;

var GFxAlloyFrontEnd_Settings SettingsView;

var GFxAlloyFrontEnd_ServerSettings ServerSettingsView;

var GFxAlloyFrontEnd_JoinGame JoinGameView;

var GFxAlloyFrontEnd_InfoDialog InfoDialog;

var GFxAlloyFrontEnd_JoinDialog JoinDialog;

var GFxAlloyFrontEnd_FilterDialog FilterDialog;

var GFxAlloyFrontEnd_ErrorDialog ErrorDialog;

var GFxAlloyFrontEnd_PasswordDialog PasswordDialog;

/** Structure which defines a unique menu view to be loaded. */
struct ViewInfo
{
	/** Unique string. */
	var name ViewName;

    /** SWF content to be loaded. */
    var string SWFName;

    /** Dependant views that should be loaded if this view is displayed. */
    var array<name> DependantViews;
};

/** Array of all menu views to be loaded, defined in DefaultUI.ini. */
var config array<ViewInfo>			ViewData;

/** 
 *  Shadow of the AS view stack. Necessary to update ( View.OnTopMostView(false) ) views that
 *  alreday exist on the stack. 
 */
var array<GFxAlloyFrontEnd_View>		ViewStack;

/**
 * An array of names of views which have been attachMovie()'d and loadMovie()'d. Views
 * are loaded based on their DependantViews array, defined in Default.ini.
 */
var array<name>						LoadedViews;

/**
 * A delegate for Escape/Back key press which will generally move the user backward
 * through the menu or select "Cancel".
 */
delegate EscapeDelegate();

function bool Start(optional bool StartPaused = false)
{
	super.Start();
	Advance(0);

	if (!bInitialized)
	{
		ConfigFrontEnd();
	}

	// @todo sf: Stops the game running the background from ending. We should set the Kismet level up
	// properly rather than use pause instead.
	ConsoleCommand("pause");

	if (class'WorldInfo'.static.IsConsoleBuild(CONSOLE_XBox360) || class'WorldInfo'.static.IsConsoleBuild(CONSOLE_PS3))
	{
		ASShowCursor(false);
	}

	LoadViews();
	return TRUE;
}

/** 
 *  Configuration method which stores references to _root and
 *  _root.manager for use in attaching views.
 */
final function ConfigFrontEnd()
{ 
	RootMC = GetVariableObject("_root");
	ManagerMC = RootMC.GetObject("manager");

	bInitialized = TRUE;
}

/** 
 *  Creates MovieClips in ManagerMC into which the views are loaded. These MovieClips
 *  are then stored in MenuViews for later manipulation.
 */
final function LoadViews()
{
	local byte i;
	for (i = 0; i < ViewData.Length; i++) 
	{
		LoadView( ViewData[i] );
	}
}

/** 
 *  Create a view using existing ViewInfo. 
 *
 *  @param InViewInfo, the data for the view which includes the SWFName and the name for the view.
 */
final function LoadView(ViewInfo InViewInfo)
{
	local ASValue asval;
	local array<ASValue> args;
	local GFxObject ViewContainer, ViewLoader;

	ViewContainer = ManagerMC.CreateEmptyMovieClip( String(InViewInfo.ViewName) $ "Container" );
	ViewLoader = ViewContainer.CreateEmptyMovieClip( String(InViewInfo.ViewName) );

	asval.Type = AS_String;
	asval.s = InViewInfo.SWFName;
	args[0] = asval;

	ViewContainer.SetVisible( false );
	ViewLoader.Invoke( "loadMovie", args );
	LoadedViews.AddItem( InViewInfo.ViewName );
}

/** 
 *  Loads a view using the view name. Used for loading views based on the current screen.
 *  Views that should be loaded for each screen are defined in DefaultUI.ini.
 *
 *  @param InViewName		The name of the view to be loaded.
 */
final function LoadViewByName( name InViewName )
{
	local byte i;
	for( i = 0; i < ViewData.Length; i++ )
	{
		// Find the view data by the view name and check that it is not already loaded.
		if ( ViewData[i].ViewName == InViewName && !IsViewLoaded(InViewName) )
		{
			// Load the view.
			LoadView( ViewData[i] );             
		}
	}
}

/**  
 *  Checks whether a view has already been loaded using the view name. 
 *
 *  @param InViewName		The name of the view to check.
 */
final function bool IsViewLoaded( name InViewName )
{
	local byte i;
	for( i = 0; i < ViewData.Length; i++ )
	{
		// Check if the view has already been loaded using the view name.
		if ( LoadedViews[i] == InViewName )
		{
			return TRUE;
		}
	}
	return FALSE;
}

/** 
 * Used by views to set the function triggered by "escape" input. 
 *
 * @param InDelegate	The EscapeDelegate that should be called on Escape/Cancel key press.
 */
final function SetEscapeDelegate( delegate<EscapeDelegate> InDelegate )
{
	local GFxObject _global;
	_global = GetVariableObject("_global");        
	ActionScriptSetFunction(_global, "OnEscapeKeyPress");
}

/** 
 *  Pushes a view onto MenuManager.as's view stack by name.
 *  This is the primarily method by which views on the stack notify the
 *  GFxAlloyFrontEnd that the state of the stack needs to be updated.
 */ 
final function PushViewByName(name TargetViewName, optional GFxAlloyFrontEnd_Screen ParentView)
{
	`log( "GFxAlloyFrontEnd::PushViewByName(" @ string(TargetViewName) @ ")",,'DevUI');    
	switch (TargetViewName)
	{
		case ( 'InstantAction' ): 
			ConfigureTargetView( InstantActionView ); 
			break;
		case ( 'Multiplayer' ):
			ConfigureTargetView( MultiplayerView );
			break;
		case ( 'GameMode' ):      
			ConfigureTargetView( GameModeView ); 
			break;  
		case ( 'MapSelect' ):     
			ConfigureTargetView( MapSelectView ); 
			break;  
		case ( 'Settings' ):
			ConfigureTargetView( SettingsView );
			break;
		case ( 'Mutators' ):
			ConfigureTargetView( MutatorsView );
			break;
		case ( 'HostGame' ):
			ConfigureTargetView( HostGameView );
			break;
		case ( 'ServerSettings' ):
			ConfigureTargetView( ServerSettingsView );
			break;
		case ( 'JoinGame' ):
			ConfigureTargetView( JoinGameView );
			break;
		default:
			`log( "View ["$TargetViewName$"] not found." ,,'DevUI');  
			break;
	}
}

/** 
 *  Configures a dialog and pushes it on to the view stack. 
 *  Returns a reference to the dialog which can be manipulated to the view which spawned it.
 */
function GFxAlloyFrontEnd_Dialog SpawnDialog(name TargetDialogName, optional GFxAlloyFrontEnd_Screen ParentView)
{
	`log( "GFxAlloyFrontEnd::SpawnDialog(" @ string(TargetDialogName) @ ")" ,,'DevUI');    
	switch ( TargetDialogName )
	{
		case ( 'InfoDialog' ):
			ConfigureTargetDialog( InfoDialog ); 
			return InfoDialog;
		case ( 'JoinDialog' ):
			ConfigureTargetDialog( JoinDialog );
			return JoinDialog;
		case ( 'ErrorDialog' ):
			ConfigureTargetDialog( ErrorDialog );
			return ErrorDialog;
		case ( 'PasswordDialog' ):
			ConfigureTargetDialog( PasswordDialog );
			return PasswordDialog;
		case ( 'FilterDialog' ):
			ConfigureTargetDialog( FilterDialog );
			return FilterDialog;
		default:
			`log( "Dialog ["$TargetDialogName$"] not found." ,,'DevUI');  
			return none;
	}
}

/**
 * Activates, updates, and pushes a dialog on the stack.
 * This method is called when a dialog is created by name using SpawnDialog().
 */
function ConfigureTargetDialog(coerce GFxAlloyFrontEnd_View TargetDialog)
{
	if (TargetDialog != none)
	{
		if (ViewStack.Length > 0)
		{
			ViewStack[ViewStack.Length - 1].DisableSubComponents(true);
		}

		TargetDialog.OnViewActivated();
		TargetDialog.OnTopMostView( true ); 

		ViewStack.AddItem( TargetDialog );
		PushDialogView( TargetDialog );
	}
	else 
	{
		`log( "GFxAlloyFrontEnd::ConfigureTargetDialog: TargetDialog is none. Unable to push view." ,,'DevUI');
	}
}

/** 
 * Activates, updates, and pushes a view on the stack if it is allowed.
 * This method is called when a view is created by name using PushViewByName().
 */
function ConfigureTargetView(GFxAlloyFrontEnd_View TargetView)
{
    if( IsViewAllowed( TargetView ) )
    {
        // LoadDependantViews( TargetView.ViewName );
        // Disable the current top most view's controls to prevent focus from escaping during the transition.
		if (ViewStack.Length > 0)
		{
			ViewStack[ViewStack.Length - 1].DisableSubComponents(true);
		}
        
        TargetView.OnViewActivated();
        TargetView.OnTopMostView( true );

        ViewStack.AddItem( TargetView );
        PushView( TargetView );      
    }    
}

/** Check whether target view is appropriate to add to the view stack. */
function bool IsViewAllowed(GFxAlloyFrontEnd_View TargetView)
{
    local byte i;	
    local name TargetViewName;

    // Check to see that we weren't passed a null view.
    if ( TargetView == none )
    {
		`log( "GFxAlloyFrontEnd:: TargetView is null. Unable to push view onto stack." ,,'DevUI');         
        return false;
    }

    // Check to see if the view is already loaded on the view stack using the view name. 
    TargetViewName = TargetView.ViewName;
    for ( i = 0; i < ViewStack.Length; i++ )
    {
        if (ViewStack[i].ViewName == TargetViewName)
        {
			`log( "GFxFrontEnd:: TargetView is already on the stack." ,,'DevUI');             
            return false;
        }
    }

    return true;
}

/** Pushes a view onto MenuManager.as view stack. */
function PushView(coerce GFxAlloyFrontEnd_View targetView) 
{     
    ActionScriptVoid("pushStandardView"); 
}

/** AS stub for pushing a view onto the stack. */
function PushDialogView(coerce GFxAlloyFrontEnd_View dialogView) 
{
    ActionScriptVoid("pushDialogView");
}

/** Gives focus to a particular GFxObject. */
function SetSelectionFocus(coerce GFxObject MovieClip)
{    
    if (MovieClip != none)
    {
        ASSetSelectionFocus(MovieClip);       
    }
}

/** AS stub for access to Selection.setFocus() via SetSelectionFocus(). */
function ASSetSelectionFocus(GFxObject MovieClip)
{
    ActionScriptVoid("setSelectionFocus");    
}

/** Pops a view from the view stack and handles update/close of existing views. */
function GFxObject PopView() 
{       
    if ( ViewStack.Length <= 1 ) 
    {
        return none;
    }

    // Call OnViewClosed() for the popped view. 
    // Generally, this will disable the view's list to prevent accidental mouse rollOvers that cause
    // focus to change undesirably as the view is tweened out.
    ViewStack[ViewStack.Length-1].OnViewClosed();

    // DestroyDependantViews( ViewStack[ViewStack.Length - 1].ViewName );

    // Remove the view from the stack in US so we know what's still on top.   
    ViewStack.Remove(ViewStack.Length-1, 1);     

    // Update the new top most view.    
    ViewStack[ViewStack.Length-1].OnTopMostView( false ); 

    return PopViewStub();
}

/** Pops a view from the MenuManager.as view stack. */
final function GFxObject PopViewStub() { return ActionScriptObject("popView"); }

/** Updates the layout of all views in MenuManager.as view stack. */
final function UpdateViewLayout() 
{ 
    ActionScriptVoid("updateViewLayout");
}

final function ConfigureView(GFxAlloyFrontEnd_View InView, name WidgetName, name WidgetPath)
{	
    SetWidgetPathBinding(InView, WidgetPath);
    InView.MenuManager = self;
    InView.ViewName = WidgetName;
    InView.OnViewLoaded();
}

final function ASShowCursor(bool bShowCursor)
{
    ActionScriptVoid("showCursor");
}

/** Callback when at least one CLIK widget with enableInitCallback set to TRUE has been initialized in a frame */
function PostWidgetInit()
{
    //
}

/** @return Checks to see if the platform is currently connected to a network. */
function bool CheckLinkConnectionAndError( optional string AlternateTitle, optional string AlternateMessage )
{
    local GFxAlloyFrontEnd_ErrorDialog Dialog;
    local bool bResult;

	if( class'GFxUIView'.static.HasLinkConnection() )
	{
		bResult = true;
	}
	else
	{
		if ( AlternateTitle == "" )
		{
			AlternateTitle = "<Strings:UTGameUI.Errors.Error_Title>";
		}
		if ( AlternateMessage == "" )
		{
			AlternateMessage = "<Strings:UTGameUI.Errors.LinkDisconnected_Message>";
		}

        Dialog = GFxAlloyFrontEnd_ErrorDialog(SpawnDialog('ErrorDialog'));
        Dialog.SetTitle(AlternateTitle);
        Dialog.SetInfo(AlternateMessage);
		bResult = false;
	}

    return bResult;
}

/** 
 *  Callback when a CLIK widget with enableInitCallback set to TRUE is initialized.  
 *  Returns TRUE if the widget was handled, FALSE if not. 
 */
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{    
	local bool bResult;
	bResult = false;

	//`log( "GFxAlloyFrontEnd::WidgetInit: " @ WidgetName @ " : " @ WidgetPath @ " : " @ Widget ,,'DevUI');   
    switch(WidgetName)
    {           
        case ('MainMenu'):
            if (MainMenuView == none)
            {
                MainMenuView = GFxAlloyFrontEnd_MainMenu(Widget);
                ConfigureView(MainMenuView, WidgetName, WidgetPath);

                // Currently here because need to ensure MainMenuView has loaded.
                ConfigureTargetView(MainMenuView);                 
                bResult = true;
            }            
            break;
        case ('InstantAction'):
            if (InstantActionView == none)
            {
                InstantActionView = GFxAlloyFrontEnd_InstantAction(Widget);
                ConfigureView(InstantActionView, WidgetName, WidgetPath); 
                bResult = true;
            }
            break;
        case ('MapSelect'):
            if (MapSelectView == none)
            {
                MapSelectView = GFxAlloyFrontEnd_MapSelect(Widget);
                ConfigureView(MapSelectView, WidgetName, WidgetPath);
                bResult = true;
            }
            break;
        case ('GameMode'):
            if (GameModeView == none)
            {
                GameModeView = GFxAlloyFrontEnd_GameMode(Widget);
                ConfigureView(GameModeView, WidgetName, WidgetPath);
                bResult = true;
            }
            break;
        case ('Mutators'):
            if (MutatorsView == none)
            {
                MutatorsView = GFxAlloyFrontEnd_Mutators(Widget);
                ConfigureView(MutatorsView, WidgetName, WidgetPath);
                bResult = true;
            }
            break;
        case ('Settings'):
            if (SettingsView == none)
            {
                SettingsView = GFxAlloyFrontEnd_Settings(Widget);
                ConfigureView(SettingsView, WidgetName, WidgetPath);
                bResult = true;
            }
            break;
        case ('ServerSettings'):
            if (ServerSettingsView == none)
            {
                ServerSettingsView = GFxAlloyFrontEnd_ServerSettings(Widget);
                ConfigureView(ServerSettingsView, WidgetName, WidgetPath);
                bResult = true;
            }
            break;
        case ('HostGame'):
            if (HostGameView == none)
            {
                HostGameView = GFxAlloyFrontEnd_HostGame(Widget);
                ConfigureView(HostGameView, WidgetName, WidgetPath);
                bResult = true;
            }
            break;
        case ('Multiplayer'):
            if (MultiplayerView == none)
            {
                MultiplayerView = GFxAlloyFrontEnd_Multiplayer(Widget);
                ConfigureView(MultiplayerView, WidgetName, WidgetPath);
                bResult = true;
            }
            break;        
        case ('JoinGame'):            
            if (JoinGameView == none)
            {                
                JoinGameView = GFxAlloyFrontEnd_JoinGame(Widget);
                ConfigureView(JoinGameView, WidgetName, WidgetPath);
                bResult = true;
            }
            break;
        case ('InfoDialog'):
            if (InfoDialog == none)
            {
                InfoDialog = GFxAlloyFrontEnd_InfoDialog(Widget);
                ConfigureView(InfoDialog, WidgetName, WidgetPath); 
                bResult = true;
            }
            break;
        case ('JoinDialog'):
            if (JoinDialog == none)
            {
                JoinDialog = GFxAlloyFrontEnd_JoinDialog(Widget);
                ConfigureView(JoinDialog, WidgetName, WidgetPath); 
                bResult = true;
            }
            break;
        case ('PasswordDialog'):
            if (PasswordDialog == none)
            {                				
                PasswordDialog = GFxAlloyFrontEnd_PasswordDialog(Widget);
                ConfigureView(PasswordDialog, WidgetName, WidgetPath); 
                bResult = true;
            }
			break;
		case ('ErrorDialog'):
			if (ErrorDialog == none)
			{
				ErrorDialog = GFxAlloyFrontEnd_ErrorDialog(Widget);
				ConfigureView(ErrorDialog, WidgetName, WidgetPath); 

				// Hack to ensure that focus is set to the main menu even after all the other views have been loaded above.
				SetSelectionFocus(MainMenuView.ListMC);
				bResult = true;
			}
			break;
		case ('FilterDialog'):
			if(FilterDialog == none)
			{
				FilterDialog = GFxAlloyFrontEnd_FilterDialog(Widget);
				ConfigureView(FilterDialog, WidgetName, WidgetPath);
				bResult = true;
			}
			break;
        default:
            break;
    }

    return bResult;
}

/**  
 *  The following methods are used for creating / destroying views. They are commented out for the time being
 *  because the size/perf of having all of the views loaded from start up until level shut down is manageable
 *  and enabling them can cause instability moving between screens (needs further investigation).
 */


/**
 * Loads all dependant views for a view using the view's name. Dependant
 * views are defined in the INI file and stored in the ViewData array.
 */
final function LoadDependantViews( name InViewName )
{
	/*
    local byte i;
    local array<name> DependantViews;
    local name DependantViewName;

    // Find the ViewInfo for the view based on the name that was passed in.
    for (i = 0; i < ViewData.Length; i++ )
    {
        if (InViewName == ViewData[i].ViewName)
        {
            // Store this views dependant views (defined in the INI).
            DependantViews = ViewData[i].DependantViews;
        }
    }

    // Iterate through dependant views. If they're not loaded, load them.
    for (i = 0; i < DependantViews.Length; i++)
    {
        DependantViewName = DependantViews[i];
        if ( !IsViewLoaded( DependantViewName ) )
        {            
            LoadViewByName( DependantViewName );
        }
    } 
	*/
}

/** 
 *  A highly unstable method which unloads dependant views based on the name of the view
 *  that is being unloaded.  
 */
final function DestroyDependantViews( name InViewName )
{
	/*
    local byte i;
    local ASValue asval;
    local array<ASValue> args;
    local array<name> DependantViews;
    local name DependantViewName;
    local GFxObject ViewToUnload;

    // Find the ViewInfo for the view based on the name that was passed in.
    for (i = 0; i < ViewData.Length; i++ )
    {
        if (InViewName == ViewData[i].ViewName)
        {
            // Store this views dependant views (defined in the INI).
            DependantViews = ViewData[i].DependantViews;
        }
    }
    
     // Iterate through dependant views. If they're not loaded, load them.
    for (i = 0; i < DependantViews.Length; i++)
    {
        switch( DependantViews[i] )
        {
            case ( 'GameMode' ):      
                ViewToUnload = GameModeView;
                break;
            case ( 'MapSelect' ):     
                ViewToUnload = MapSelectView;
                break;
            case ( 'Settings' ):
                ViewToUnload = SettingsView;
                break;
            case ( 'Mutators' ):
                ViewToUnload = MutatorsView;
                break;
            case ( 'HostGame' ):
                ViewToUnload = HostGameView;
                break;
            case ( 'ServerSettings' ):
                ViewToUnload = ServerSettingsView;
                break;
            case ( 'JoinGame' ):
                ViewToUnload = JoinGameView;
                break;
            case ( 'JoinDialog' ):            
                ViewToUnload = JoinDialog;
                break;           
            case ( 'FilterDialog' ):            
                ViewToUnload = FilterDialog;
                break;           
            case ( 'ErrorDialog' ):
                ViewToUnload = ErrorDialog;
                break;            
            case ( 'PasswordDialog' ):
                ViewToUnload = PasswordDialog;
                break;
            default:
                ViewToUnload = none;
                break;
        }

        if ( ViewToUnload != none )
        {
            asval.Type = AS_Boolean;
            asval.b = TRUE;
            args[0] = asval;

            ViewToUnload.Invoke( "removeMovieClip", args );    
            LoadedViews.RemoveItem ( DependantViews[i] );
        }        
    }
	*/
}

/**
 * Pass on input to the currently focused view (JoinGame only atm)
 */
function bool FilterButtonInput(int ControllerId, name ButtonName, EInputEvent InputEvent)
{
	if (GFxAlloyFrontEnd_JoinGame(ViewStack[ViewStack.Length-1]) != none)
		return GFxAlloyFrontEnd_JoinGame(ViewStack[ViewStack.Length-1]).OnFilterButtonInput(ControllerId, ButtonName, InputEvent);

	return False;
}


defaultproperties
{    
    // Views & Dialogs
    WidgetBindings.Add((WidgetName="MainMenu",WidgetClass=class'GFxAlloyFrontEnd_MainMenu'))
    WidgetBindings.Add((WidgetName="InstantAction",WidgetClass=class'GFxAlloyFrontEnd_InstantAction'))       
    WidgetBindings.Add((WidgetName="MapSelect",WidgetClass=class'GFxAlloyFrontEnd_MapSelect'))
    WidgetBindings.Add((WidgetName="GameMode",WidgetClass=class'GFxAlloyFrontEnd_GameMode'))
    WidgetBindings.Add((WidgetName="Settings",WidgetClass=class'GFxAlloyFrontEnd_Settings'))
    WidgetBindings.Add((WidgetName="Mutators",WidgetClass=class'GFxAlloyFrontEnd_Mutators'))
        
    WidgetBindings.Add((WidgetName="Multiplayer",WidgetClass=class'GFxAlloyFrontEnd_Multiplayer'))
    WidgetBindings.Add((WidgetName="HostGame",WidgetClass=class'GFxAlloyFrontEnd_HostGame'))
    WidgetBindings.Add((WidgetName="JoinGame",WidgetClass=class'GFxAlloyFrontEnd_JoinGame'))
    WidgetBindings.Add((WidgetName="ServerSettings",WidgetClass=class'GFxAlloyFrontEnd_ServerSettings'))
    
    WidgetBindings.Add((WidgetName="InfoDialog",WidgetClass=class'GFxAlloyFrontEnd_InfoDialog'))
    WidgetBindings.Add((WidgetName="ErrorDialog",WidgetClass=class'GFxAlloyFrontEnd_ErrorDialog'))
    WidgetBindings.Add((WidgetName="JoinDialog",WidgetClass=class'GFxAlloyFrontEnd_JoinDialog'))
    WidgetBindings.Add((WidgetName="PasswordDialog",WidgetClass=class'GFxAlloyFrontEnd_PasswordDialog'))
	WidgetBindings.Add((WidgetName="FilterDialog",WidgetClass=class'GFxAlloyFrontEnd_FilterDialog'))

    // Sound Mapping
    SoundThemes(0)=(ThemeName=default,Theme=UISoundTheme'UDKFrontEnd.Sound.SoundTheme')

    bDisplayWithHudOff=TRUE    
    TimingMode=TM_Real
    bInitialized=FALSE
	MovieInfo=SwfMovie'UDKFrontEnd.alloy_manager'
	bPauseGameWhileActive=TRUE
	bCaptureInput=true
}