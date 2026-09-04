// SYSTEM v1.01

//app_resize();
return_status = os_paused();

debug_pro_watch("g.playtime", "playtime");
show_debug_message("WATCH COUNT = " + string(array_length(g.__dbgpro_watch)));


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
// THE PROFIT COLOUR - ONE global that everything profit-denominated
// reads: the counter, the bezier motes, dial payouts, rates, prices.
// Myriad DE does exactly this (g.profit_color) so the player can
// recolour their money and have the whole game agree. When the
// settings row for it lands it needs to change nothing but this value.
g.profit_color = c_sgreen;
// THE DIAL RATE VIEW (DE's view button): 0 = profit per cycle, 1 = per
// second. A display pref, so it rides settings.ini like the tint
g.display_gps = 0;
// ROUNDED BULK BUYS (DE's law): x10 buys UP TO the next round level.
// off = a flat +10. His toggle, settings > gameplay
g.buy_round = true;
// profit earned but not yet DELIVERED by its motes. Registered by
// give_profit and released as each mote lands, so the counter can hold
// it back. A global, because the alternative - summing the live motes
// each frame - only works if the motes already exist when the sum
// runs, and that depends on room instance order.
g.profit_flight = 0;
g.trans_kind = 1;     // room transition: 0 circle wipe / 1 slice wipe
	// (round 7's showcase; settings > display, latched per flight
	// by goto_room)
quit = false;






