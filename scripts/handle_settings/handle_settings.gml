/// @description handle_settings(sv_save / sv_load);
/// @param method
/// settings live in their OWN ini, split from the savefile (same split
/// as old myriad): display/options here, progress in savefile.ini. the
/// point: exporting/importing a save never drags device settings along.
/// runs in syst_handle_save's scope, same as handle_save().
function handle_settings(_method) {

	action = _method;

	//////////////////////////////////////////////////////////////////
	ini_open("settings.ini");
	if system.debug = true show("opened > settings.ini");
	//////////////////////////////////////////////////////////////////

	section = "display";

	// fullscreen: persist the INTENDED state, not the momentary one.
	// portrait rooms (gameload included) auto-park fullscreen off and
	// flag fs_restore on syst_display: that's the framework's doing, not
	// a player choice, so saves write TRUE while the flag is up. loads
	// are untouched: a loaded true in a portrait room just re-parks
	var _fs_live = g.fullscreen;
	if (_method == sv_save)
	if (instance_exists(syst_display))
	if (variable_instance_exists(syst_display, "fs_restore"))
	if (syst_display.fs_restore) g.fullscreen = true;

	g.fullscreen = handle("fullscreen",g.fullscreen);
	// ALWAYS FULLSCREEN ON STARTUP (his ask, 2026-09-11): a boot load
	// forces the choice to fullscreen whatever the last session left -
	// the toggle in settings still works for the session; this only
	// says what the game boots into. Saves keep the live choice as
	// before, so nothing else about the key changes
	g.fs_on_boot = handle("fs_on_boot", g.fs_on_boot);
	if (_method == sv_load && g.fs_on_boot) g.fullscreen = true;

	if (_method == sv_save) g.fullscreen = _fs_live; // keep the live state
	// the CHOSEN size persists, never the live one (which portrait
	// rooms park at 144 - saving that used to lose the player's pick)
	g.screen_size_user = handle("screen_size",g.screen_size_user);
	g.fullscreen_borderless = handle("fullscreen_borderless",g.fullscreen_borderless);
	g.vsync = handle("vsync",abs(g.vsync));
	g.blur = handle("blur",g.blur);
	g.cursor_ray = handle("cursor_ray",g.cursor_ray); // the pointer's raycast shading
	g.motion_blur = handle("motion_blur",g.motion_blur); // per-object motion blur (the puck)
	g.tap_fx = handle("tap_fx",g.tap_fx); // the tap effect (syst_tapfx's chip)
	// the tube (syst_crt): where, which seat, the knobs
	g.crt_mode    = handle("crt_mode",g.crt_mode);
	g.crt_over_ui = handle("crt_over_ui",g.crt_over_ui);
	g.crt_curve   = handle("crt_curve",g.crt_curve);
	g.crt_scan    = handle("crt_scan",g.crt_scan);
	g.crt_grille  = handle("crt_grille",g.crt_grille);
	g.crt_chroma  = handle("crt_chroma",g.crt_chroma);
	g.crt_vig     = handle("crt_vig",g.crt_vig);
	g.crt_bloom   = handle("crt_bloom",g.crt_bloom);
	g.bat_opt     = handle("bat_opt",g.bat_opt);       // the battery optimiser (debug toggle for now)
	g.scene_light = handle("scene_light",g.scene_light); // the field's light on the solids, %
	g.crt_roll    = handle("crt_roll",g.crt_roll);
	g.num_format = handle("num_format",g.num_format); // how every number reads (num_format_config)
	g.tap_text = handle("tap_text",g.tap_text);       // DE's taptextformat: 0 at the tap / 1 centred / 2 none
	g.tps_readout = handle("tps_readout",g.tps_readout);
	g.bounce_text = handle("bounce_text",g.bounce_text);
	g.mote_arc = handle("mote_arc",g.mote_arc);       // DE's part_grav, three ways
	g.random_profit_color = handle("random_profit_color",g.random_profit_color);
	g.swipe_protect = handle("swipe_protect",g.swipe_protect);
	g.puck_hand = handle("puck_hand",g.puck_hand);   // the arrow rides a held puck
	if (_method == sv_load) g.num_format = clamp(floor(g.num_format), 0, array_length(num_format_config()) - 1);
	system.desired_fps = handle("fps_cap",system.desired_fps);
	g.show_fps = handle("show_fps",g.show_fps);
	g.fit_margin = handle("fit_margin",g.fit_margin); // portrait chrome reserve
	g.orient = handle("orient",g.orient); // -1 auto / 0 portrait / 1 landscape
	g.vis_grid_alpha = handle("vis_grid_alpha",g.vis_grid_alpha); // grid %
	g.vis_glow = handle("vis_glow",g.vis_glow); // glow fx layer intensity %
	g.dice_mat = handle("dice_mat",g.dice_mat); // dice finish, by roster id
	g.coin_mat = handle("coin_mat",g.coin_mat); // the coin's
	g.menu_style = handle("menu_style",g.menu_style); // the header menu's panel
	g.title_bg = handle("title_bg",g.title_bg); // the title's backdrop
	g.puck_mat = handle("puck_mat",g.puck_mat); // the puck's, same roster
	g.trans_kind = handle("trans_kind",g.trans_kind); // room transition style

	section = "audio";

	g.vol_master = handle("vol_master",g.vol_master);
	g.vol_sfx = handle("vol_sfx",g.vol_sfx);
	g.mute = handle("mute",g.mute);
	g.haptics = handle("haptics",g.haptics);

	section = "gameplay";

	g.autosave = handle("autosave",g.autosave);
	g.backup_mid  = handle("backup_mid",  g.backup_mid);
	g.backup_deep = handle("backup_deep", g.backup_deep);
	// the profit tint persists so a future settings row just works
	g.profit_color = handle("profit_color", g.profit_color);
	g.display_gps  = handle("display_gps",  g.display_gps); // the view button's pick
	g.buy_round    = handle("buy_round",    g.buy_round);   // rounded bulk buys
	g.persist_popups = handle("persist_popups", g.persist_popups); // the credit panel stays out
	// the swappable sounds, BY ID. Three keys rather than one struct
	// because handle() speaks primitives, and three strings in an ini is
	// a thing a person can read and fix by hand.
	g.sfx_pick.tap  = handle("sfx_tap",  g.sfx_pick.tap);
	g.sfx_pick.dial = handle("sfx_dial", g.sfx_pick.dial);
	g.sfx_pick.crit = handle("sfx_crit", g.sfx_pick.crit);
	g.sfx_pick.credit = handle("sfx_credit", g.sfx_pick.credit);
	// the motes' look per lane, by bit_config id - the same shape
	g.bit_pick.profit = handle("bit_profit", g.bit_pick.profit);
	g.bit_pick.credit = handle("bit_credit", g.bit_pick.credit);
	g.bit_pick.unit   = handle("bit_unit",   g.bit_pick.unit);
	g.bit_pick.tile   = handle("bit_tile",   g.bit_pick.tile);
	g.vol_tap      = handle("vol_tap",      g.vol_tap);
	g.vol_dial     = handle("vol_dial",     g.vol_dial);

	section = "favorites";

	// STARRED SETTINGS (the settings screen's favorites tab) ride the
	// ini as a pipe-joined key list, statistics' pattern - device-side,
	// like every other preference about the settings screen itself
	if (!variable_global_exists("settings_fav"))      g.settings_fav      = {};
	if (!variable_global_exists("settings_fav_show")) g.settings_fav_show = false;
	g.settings_fav_show = handle("settings_fav_show", g.settings_fav_show);
	var _sf_keys = struct_get_names(g.settings_fav);
	var _sf_txt = "";
	for (var _i = 0; _i < array_length(_sf_keys); _i++)
		_sf_txt += ((_i > 0) ? "|" : "") + _sf_keys[_i];
	_sf_txt = handle("settings_fav", _sf_txt);
	if (_method == sv_load) {
		g.settings_fav = {};
		var _sfs = string_split(_sf_txt, "|", true);
		for (var _i = 0; _i < array_length(_sfs); _i++)
			g.settings_fav[$ _sfs[_i]] = true;
	}

	// MYRIAD RX: the "balance" section returns when the DE parity
	// rebuild lands its balance_init - every knob a rebuilt system
	// gains gets its handle() line here (device-side by design: tuning
	// sessions survive restarts and never travel inside a save)

	//////////////////////////////////////////////////////////////////
	ini_close();
	//////////////////////////////////////////////////////////////////

	// make loaded settings TAKE EFFECT: the display framework only
	// applies screen_size when it arrives as the negative sentinel, so
	// re-arm it after a load; same trick for a loaded vsync ON. fps/
	// audio/blur apply on their own (their systems watch the globals
	// every step)
	if (_method == sv_load) {
		g.screen_size = -abs(g.screen_size_user);
		if (g.vsync > 0) g.vsync = -g.vsync;
	}
}
