/// @description  play_sound_ext(snd,pmn,pmx,vol,vib);
/// @param snd
/// @param pmn
/// @param pmx
/// @param vol
/// @param vib
function play_sound_ext(argument0, argument1, argument2, argument3, argument4) {

	var _snd;

	if argument3 > 0{
		
	// SOUND
	_snd = audio_play_sound(argument0,1,0);
		
	// PITCH
	if argument1 != 1 and argument2 != 1 
	audio_sound_pitch(_snd,random_range(argument1,argument2));

	// VOLUME (scaled by the effects-volume setting; master volume and
	// mute live on the master bus, applied by system's step)
	var _sfx = variable_global_exists("vol_sfx") ? g.vol_sfx / 100 : 1;
	audio_sound_gain(_snd,argument3*_sfx,0);
	
	// HAPTIC
	if argument4 != 0 vibrate(30,argument4);
	}




}
