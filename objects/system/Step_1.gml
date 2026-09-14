
// the menu blur, for the drawer AND the settings / statistics overlays.
// It derives from whatever is up rather than being pushed by each of
// them, and it rebuilds the layer per room - see ui_blur_tick.
ui_blur_tick();

return_status = os_paused();
if quit = true game_end();

if prev_fps != desired_fps
game_set_speed(desired_fps,gamespeed_fps);
prev_fps = desired_fps;

// AUDIO: the one authority on the master bus. the settings sliders
// just move the globals; this applies them every step (per-sound sfx
// volume happens inside play_sound_ext)
audio_master_gain(g.mute ? 0 : g.vol_master / 100);
// THE SCRATCH LOOP'S SAFETY (2026-09-14): obj_tickets loops snd_scratch
// while a ticket is being scratched and stops it itself - but a room
// restart under the hand (an autorebirth firing) destroys that instance
// with the loop still going. The handle is mirrored in g.scratch_snd;
// no ticket instance, no loop
if (variable_global_exists("scratch_snd") && g.scratch_snd >= 0 && !instance_exists(obj_tickets)) {
	if (audio_is_playing(g.scratch_snd)) audio_stop_sound(g.scratch_snd);
	g.scratch_snd = -1;
}



// DELTA CHECK
if not os_paused() 
{
delta5 = delta4;
delta4 = delta3;
delta3 = delta2;
delta2 = delta1;
delta1 = pre_delta;
syst_delta = clamp(mean(delta1,delta2,delta3,delta4,delta5),0.05,5);
}

// escape routes contextually (ux pass): close/exit/back first, the
// game only ENDS from the title screen - scr_escape is the registry
if keyboard_check_pressed(vk_escape) scr_escape();
// R-restart was a global debug hammer that collided with every room
// using [r] (pool rack, procgen reseed) - debug builds only now
if debug if keyboard_check_pressed(ord("R")) room_restart();

if keyboard_check_pressed(vk_f1){
	debug = toggle(debug);
} 

if debug = true if not instance_exists(obj_debug_pro) create_obj(obj_debug_pro);

device_mouse_dbclick_enable(false);

// HAPTICS
if has_vibration = true{
Haptics_VibrateIntensity(has_vibration_mill,has_vibration_int);
has_vibration = false; has_vibration_int = 0; has_vibration_mill = 0;}


