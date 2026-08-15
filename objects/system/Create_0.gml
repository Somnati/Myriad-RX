// SYSTEM v1.01

//app_resize();
return_status = os_paused();

debug_pro_watch("g.playtime", "playtime");
show_debug_message("WATCH COUNT = " + string(array_length(global.__dbgpro_watch)));


g.font = font_add_sprite(spr_font,ord(" "),true,1);
g.font_large = font_add_sprite(spr_font_large,ord(" "),true,1); // Myriad's tile font
g.font_outline = font_add_sprite(spr_font_outline,ord(" "),true,-1); // Myriad DE port, sep -1 (outline overlaps)
g.font_large_outline = font_add_sprite(spr_font_large_outline,ord(" "),true,-1);
draw_set_font(g.font);

// DELTA
syst_delta = (delta_time/1000000)*60;
delta1 = pre_delta;
delta2 = pre_delta;
delta3 = pre_delta;
delta4 = pre_delta;
delta5 = pre_delta;

has_vibration = false; 
has_vibration_int = 0; 
has_vibration_mill = 0;

// SETTINGS
desired_fps = display_get_frequency(); prev_fps = 0;
debug = false;
// boot defaults for everything the settings screen binds to. the
// settings.ini load (handle_settings) overwrites these right after,
// so a fresh install gets sane values and nothing ever reads an
// undeclared global. a NEW setting's default goes HERE (the full
// checklist lives in settings_content's header).
g.haptics = true
g.vol_master = 100; // 0..100, applied to the master bus in Step
g.vol_sfx    = 100; // 0..100, read by play_sound_ext
g.mute       = false;
g.show_fps   = false; // corner readout, drawn by syst_display Draw GUI
g.autosave   = true;  // gates syst_handle_save's rotating autosave
g.part_style = 0;     // bezier profit bits' look: 0 standard (glowing
	// square) / 1 circle / 2 coin / 3 munny (settings > gameplay)
g.trans_kind = 1;     // room transition: 0 circle wipe / 1 slice wipe
	// (round 7's showcase; settings > display, latched per flight
	// by goto_room)
quit = false;






