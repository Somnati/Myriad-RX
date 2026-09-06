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

	if (_method == sv_save) g.fullscreen = _fs_live; // keep the live state
	// the CHOSEN size persists, never the live one (which portrait
	// rooms park at 144 - saving that used to lose the player's pick)
	g.screen_size_user = handle("screen_size",g.screen_size_user);
	g.fullscreen_borderless = handle("fullscreen_borderless",g.fullscreen_borderless);
	g.vsync = handle("vsync",abs(g.vsync));
	g.blur = handle("blur",g.blur);
	system.desired_fps = handle("fps_cap",system.desired_fps);
	g.show_fps = handle("show_fps",g.show_fps);
	g.fit_margin = handle("fit_margin",g.fit_margin); // portrait chrome reserve
	g.orient = handle("orient",g.orient); // -1 auto / 0 portrait / 1 landscape
	g.vis_grid_alpha = handle("vis_grid_alpha",g.vis_grid_alpha); // grid %
	g.vis_glow = handle("vis_glow",g.vis_glow); // glow fx layer intensity %
	g.trans_kind = handle("trans_kind",g.trans_kind); // room transition style

	section = "audio";

	g.vol_master = handle("vol_master",g.vol_master);
	g.vol_sfx = handle("vol_sfx",g.vol_sfx);
	g.mute = handle("mute",g.mute);
	g.haptics = handle("haptics",g.haptics);

	section = "gameplay";

	g.autosave = handle("autosave",g.autosave);
	// the profit tint persists so a future settings row just works
	g.profit_color = handle("profit_color", g.profit_color);
	g.display_gps  = handle("display_gps",  g.display_gps); // the view button's pick
	g.buy_round    = handle("buy_round",    g.buy_round);   // rounded bulk buys
	g.persist_popups = handle("persist_popups", g.persist_popups); // the credit panel stays out

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
