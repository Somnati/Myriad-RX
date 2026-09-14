/// @description settings_defaults([section]) - put every option back
/// to its out-of-the-box value - or ONE TAB's options (his ask,
/// 2026-09-11: a reset on each tab that needs one). The tab names are
/// settings_content's section names; "all" is the whole screen.
/// IF YOU ADD A SETTING with a new global, add its default HERE, in
/// its tab's block (and its save line in handle_settings) - three
/// touchpoints total: content row, this reset, the save.
/// @param [section]   "all" / "display" / "visuals" / "crt" / "readouts"
///                    / "audio" / "gameplay" / "input" / "data"
function settings_defaults(_section = "all") {
	var _all = (_section == "all");

	if (_all || _section == "display") {
		g.fullscreen            = true;
		g.fs_on_boot            = false;
		g.fullscreen_borderless = true;
		g.screen_size_user      = scr_res_list()[0].w; // native / best fit
		g.screen_size           = -abs(g.screen_size_user); // re-arm the swap
		g.vsync                 = 0;
		display_reset(0, 0);
		system.desired_fps      = display_get_frequency();
		g.show_fps              = false;
		g.fit_margin            = 12;   // % of screen height kept for OS chrome
		g.orient                = -1;   // -1 auto / 0 portrait / 1 landscape
	}

	if (_all || _section == "visuals") {
		g.blur                  = true;
		g.cursor_ray            = true;
		g.motion_blur           = true;
		g.tap_fx                = 2;
		g.scene_light           = 60;
		g.trans_kind            = 1;    // the slice wipe
		g.mote_arc              = 0;
		g.random_profit_color   = false;
		g.vis_grid_alpha        = 75;   // visualiser grid opacity, %
		g.vis_glow              = 15;   // visualiser glow intensity, %
		g.dice_mat              = "random"; // dice finish (dice_mat_config)
		g.coin_mat              = "gold";   // the coin's, same roster
		g.menu_style            = "default"; // the header menu's panel (default / black / glass)
		g.title_bg              = "starfield"; // the title's backdrop (starfield / blocks)
		g.puck_mat              = "random"; // the puck's (same roster; random = black rubber)
		g.bit_pick              = { profit : "glow", credit : "glow",
		                            unit : "glow", tile : "plain" }; // bit_config ids
		g.profit_color          = c_sgreen;   // the one profit tint (see system's Create)
	}

	if (_all || _section == "crt") {
		g.crt_mode              = 2;
		g.crt_over_ui           = true;
		g.crt_curve             = 40;
		g.crt_scan              = 60;
		g.crt_grille            = 50;
		g.crt_chroma            = 50;
		g.crt_vig               = 0;
		g.crt_bloom             = 25;
		g.crt_roll              = true;
	}

	if (_all || _section == "readouts") {
		g.num_format            = 0;
		g.tap_text              = 0;
		g.tps_readout           = true;
		g.bounce_text           = true;
		g.display_gps           = 0;    // dial rate readout: per cycle
	}

	if (_all || _section == "audio") {
		g.vol_master = 100;
		g.vol_sfx    = 100;
		g.mute       = false;
		// the three swappable sounds, stored BY ID - see sfx_config
		g.sfx_pick   = { tap : "click1", dial : "off", crit : "orb",
		                 credit : "diamond" };
		g.vol_tap    = 100;      // the two faders he asked for: one for
		g.vol_dial   = 100;      // a thing you do, one for a thing that
		                         // happens (sfx_volume)
	}

	if (_all || _section == "gameplay") {
		g.buy_round      = true;    // DE's round-up bulk buys
		g.persist_popups = false;   // DE's credit panel: only after a drop
		g.bat_opt        = false;
	}

	if (_all || _section == "input") {
		g.haptics       = true;
		g.swipe_protect = true;   // on by default (his call, 2026-09-13)
	}

	if (_all || _section == "data") {
		g.autosave = true;
		// THE BACKUP LADDER (see save_autosave_rotate): how old a backup
		// slot must be before it accepts a promotion, in minutes. 0/0 is
		// the old flat cascade - three files spanning three minutes.
		g.backup_mid  = 10;
		g.backup_deep = 60;
	}
}
