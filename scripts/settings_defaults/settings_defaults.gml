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
	g.blur                  = true;
	g.cursor_ray            = true;
	g.motion_blur           = true;
	g.tap_fx                = 1;
	g.show_fps              = false;
	g.fit_margin            = 12;   // % of screen height kept for OS chrome
	g.orient                = -1;   // -1 auto / 0 portrait / 1 landscape
	g.vis_grid_alpha        = 75;   // visualiser grid opacity, %
	g.vis_glow              = 15;   // visualiser glow intensity, %
	g.dice_mat              = "random"; // dice finish (dice_mat_config)
	g.puck_mat              = "random"; // the puck's (same roster; random = black rubber)
	g.bit_pick              = { profit : "glow", credit : "glow",
	                            unit : "glow", tile : "plain" }; // bit_config ids

	// audio
	g.vol_master = 100;
	g.vol_sfx    = 100;
	g.mute       = false;

	// input
	g.haptics = true;

	// gameplay
	g.autosave = true;
	// THE BACKUP LADDER (see save_autosave_rotate): how old a backup
	// slot must be before it accepts a promotion, in minutes. 0/0 is
	// the old flat cascade - three files spanning three minutes.
	g.backup_mid  = 10;
	g.backup_deep = 60;
	g.profit_color = c_sgreen;   // the one profit tint (see system's Create)
	g.display_gps  = 0;          // dial rate readout: per cycle
	g.buy_round    = true;       // DE's round-up bulk buys
	g.persist_popups = false;    // DE's credit panel: only after a drop
	// the three swappable sounds, stored BY ID - see sfx_config
	g.sfx_pick       = { tap : "click1", dial : "off", crit : "orb",
	                     credit : "diamond" };
	g.vol_tap        = 100;      // the two faders he asked for: one for
	g.vol_dial       = 100;      // a thing you do, one for a thing that
	                             // happens (sfx_volume)
}
