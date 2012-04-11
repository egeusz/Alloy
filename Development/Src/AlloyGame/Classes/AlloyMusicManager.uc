class AlloyMusicManager extends Info
	config(Game);
	
	var array<AudioComponent> CurrentTracks;
	var array<AudioComponent> MusicTracks; /** Music Tracks - see ChangeTrack() for definition of slots. */
	
	var float	MusicStartTime;			/** Time at which current track started playing */	
	var int LastBeat; 				/** Count of beats since MusicStartTime */
	
	var bool bIsPlaying;
	
	
	var globalconfig float MusicVolume;	/** Maximum volume for music audiocomponents (max value for VolumeMultiplier). */
	
	
	event PostBeginPlay()
{
	Super.PostBeginPlay();
	`Log("Custom MusicManager online");
	bIsPlaying = false;
	MusicVolume = 1.0;
	InitTracks();
	// start music on a short timer so we avoid the long initial tick that can make the music skip
//	StartMusic();
}

function InitTracks(){
	MusicTracks[0] = CreateNewTrack(SoundCue'sound_alloyMusic.BassCue');
	MusicTracks[1] = CreateNewTrack(SoundCue'sound_alloyMusic.DrumsCue');
	MusicTracks[2] = CreateNewTrack(SoundCue'sound_alloyMusic.1_4notesCue');
	MusicTracks[3] = CreateNewTrack(SoundCue'sound_alloyMusic.1_8notesCue');
	
	CurrentTracks[MusicTracks.Length] = none;
}


function AddSongLayer(int songIndex){
	if (CurrentTracks[songIndex] == none || CurrentTracks[songIndex] != MusicTracks[songIndex]){
		CurrentTracks[songIndex] = MusicTracks[songIndex];
		CurrentTracks[songIndex].OnAudioFinished = SongFinished;
		`Log("added track: "@songIndex);
		if(!bIsPlaying){
			CurrentTracks[songIndex].Play();
			bIsPlaying = true;
		}
	}
}

function RemoveSongLayer(int songIndex){
	`Log("Removing Track: "@songIndex);
	CurrentTracks[songIndex] = none;
}

function SongFinished(AudioComponent AC){
	local int index;

for (index = 0; index < CurrentTracks.Length; ++index) {
		if(CurrentTracks[index] != none && !CurrentTracks[index].isPlaying()){
			CurrentTracks[index].play();
				`Log("Song playing: "@index);
		}
	}
}

/* CreateNewTrack()
* Create a new AudioComponent to play MusicCue.
* @param MusicCue:  the sound cue to play
* @returns the new audio component
*/
function AudioComponent CreateNewTrack(SoundCue MusicCue)
{
	local AudioComponent AC;

	AC = CreateAudioComponent( MusicCue, false, true );

	// AC will be none if -nosound option used
	if ( AC != None )
	{
		AC.bAllowSpatialization = false;
		AC.bShouldRemainActiveIfDropped = true;
	}
	return AC;
}
defaultproperties
{



}
