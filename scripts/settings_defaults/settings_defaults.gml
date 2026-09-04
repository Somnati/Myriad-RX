/// @description settings_defaults() - put every option back to its
/// out-of-the-box value. wired to the "reset settings" action row.
/// IF YOU ADD A SETTING with a new global, add its default HERE too
/// (and its save line in handle_settings) - three touchpoints total:
/// content row, this reset, the save. that's the whole checklist.
function settings_defaults() {

	// display
	g.fullscreen            = true;
	g.fullscreen_borderless = true;
	g.screen_size_user      = scr_res_list()[0].w; // native / best fit
	g.screen_size           = -abs(g.screen_size_user); // re-arm the swap
	g.vsync                 = 0;
	display_reset(0, 0);
	system.desired_fps      = display_get_frequency();
	g.blur                  = false;
	g.show_fps              = false;

	// audio
	g.vol_master = 100;
	g.vol_sfx    = 100;
	g.mute       = false;

	// input
	g.haptics = true;

	// gameplay
	g.autosave = true;
	g.profit_color = c_sgreen;   // the one profit tint (see system's Create)
	g.display_gps  = 0;          // dial rate readout: per cycle
	g.buy_round    = true;       // DE's round-up bulk buys
	g.persist_popups = false;    // DE's credit panel: only after a drop
}
