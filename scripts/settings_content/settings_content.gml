/// @description settings_content() - THE settings screen, declared as
/// calls (same authoring pattern as menu2_content / stats_v2_content).
/// runs in syst_settings' scope EVERY step, so rows can appear and
/// vanish conditionally - that's how the mobile/desktop split works.
///
/// ==================== HOW TO ADD A SETTING ==========================
/// 1. pick (or add) a section:   settings_section("name", color);
///    - a new section automatically gets a tab in the left rail, and
///      its rows show ONLY while that tab is active.
/// 2. add ONE row under it. the menu of row types:
///
///    on/off switch (the sliding paddle):
///      settings_toggle("label",
///          function() { return g.my_thing; },        // read it
///          function(_v) { g.my_thing = _v; },        // write it
///          "optional help text (tap the ? to read)");
///
///    dropdown (the house pillbox - best for 3+ options):
///      settings_pill("label", "unique_kind", "current choice label",
///          function() { set_pill("option a", { val : "a" });
///                       set_pill("option b", { val : "b" }); },
///          function(_v) { g.my_choice = _v; });
///      the pick fn can wrap risky display changes in
///      __confirm("keep it?", revert_fn) - apply FIRST, hand over a
///      revert; the popup auto-reverts after 10s if unconfirmed.
///
///    single choice as inline pip rows (rarely - pillbox reads better):
///      settings_radio("option A", "unique_key_a",
///          method({ v : 0 }, function() { return g.my_choice == v; }),
///          method({ v : 0 }, function() { g.my_choice = v; }));
///      (the method({...}) wrapper bakes the option's value in - GML
///       function literals DON'T capture local variables, so a bare
///       function inside a loop would see only the loop's LAST value)
///
///    number on a drag track:
///      settings_slider("label", min, max,
///          function() { return g.my_number; },
///          function(_v) { g.my_number = _v; },
///          "%",  // readout suffix
///          5,    // snap step (1 = free)
///          "optional help");
///
///    read-only line:      settings_info("label", "value", "help");
///    tappable command:    settings_action("label", function() { ... });
///
/// 3. if the setting is a NEW global: give it a boot default in
///    system's Create (the SETTINGS block), a reset line in
///    settings_defaults(), and a save line in handle_settings().
///    that's every touchpoint. widgets, layout, scrolling, saving-on-
///    change, chips - all automatic.
/// ====================================================================
function settings_content() {

	var _desktop = (os_type != os_android && os_type != os_ios);

	// ============================ display ===========================
	settings_section("display", c_steelblue);

	if (_desktop) {
		settings_toggle("fullscreen",
			function() { return g.fullscreen; },
			function(_v) { g.fullscreen = _v; },
			"fill the whole screen. off = the floating window (which you "
			+ "can throw around, yes).");

		settings_toggle("borderless fullscreen",
			function() { return g.fullscreen_borderless; },
			function(_v) { g.fullscreen_borderless = _v; },
			"fullscreen as a borderless window: instant alt-tab, no "
			+ "display mode switch.");

		// windowed size: ONE dropdown row on the pillbox framework.
		// options build at TAP time from scr_res_list (the one table -
		// the swap in scr_display1 reads the same call). the pick
		// applies immediately, then the keep/revert countdown guards
		// against sizes the display can't actually show.
		var _cur = "?";
		var _ls = scr_res_list();
		for (var _i = 0; _i < array_length(_ls); _i++)
			if (_ls[_i].w == g.screen_size_user) _cur = _ls[_i].label;
		settings_pill("resolution", "res", _cur,
			function() { // build: one pill per size that fits
				var _l = scr_res_list();
				for (var _j = 0; _j < array_length(_l); _j++) {
					var _on = (_l[_j].w == g.screen_size_user);
					set_pill(_l[_j].label + (_l[_j].native ? " (native)" : ""), {
						val : _l[_j].w,
						col : _on ? c_gold : sett_ink,
						enabled : _on,
					});
				}
			},
			function(_w) { // pick: apply, then ask to keep it
				if (_w == g.screen_size_user) return;
				var _prev = g.screen_size_user;
				g.screen_size_user = _w;
				g.screen_size = -_w; // negative = "apply" sentinel
				__confirm("keep this resolution?",
					method({ prev : _prev }, function() {
						g.screen_size_user = prev;
						g.screen_size = -prev;
					}));
			},
			"window size, from what this display fits. applies while "
			+ "windowed; picked while fullscreen it waits for the drop "
			+ "back. reverts by itself if you can't confirm.",
			g.fullscreen ? c_gray : -1);

		// how much screen height a portrait room leaves for the OS
		// chrome. Kept as a PERCENTAGE so it holds at any DPI - see
		// scr_display1's fit block for why this exists at all.
		settings_slider("portrait margin", 0, 30,
			function() { return g.fit_margin; },
			function(_v) {
				// the slider calls this every frame of a drag; only a real
				// step re-arms, or the swap logs once per frame
				if (_v == g.fit_margin) return;
				g.fit_margin = _v;
				g.screen_size = -abs(g.screen_size); // re-arm the fit
			},
			"%", 1,
			"how much of the screen height a portrait room keeps clear "
			+ "for the title bar and the taskbar. too little and the "
			+ "bottom of the room hides behind them. you'll see it "
			+ "change back in the clicker.");

		settings_toggle("vsync",
			function() { return g.vsync != 0; },
			function(_v) { g.vsync = _v ? 1 : 0; display_reset(0, g.vsync); },
			"locks the frame rate to the display so motion can't tear. "
			+ "while on, the fps cap below stops mattering.");
	}

	// ORIENTATION: forces the SHAPE of every room that has two of
	// them (room_pairs - today that is the clicker). Rooms with
	// one shape are unaffected, so the settings/statistics
	// screens stay landscape whatever this says.
	settings_pill("orientation", "orient",
		(g.orient == 0) ? "portrait" : ((g.orient == 1) ? "landscape" : "auto"),
		function() {
			set_pill("auto",      { val : -1,
				col : (g.orient == -1) ? c_gold : sett_ink,
				enabled : (g.orient == -1) });
			set_pill("landscape", { val : 1,
				col : (g.orient == 1) ? c_gold : sett_ink,
				enabled : (g.orient == 1) });
			set_pill("portrait",  { val : 0,
				col : (g.orient == 0) ? c_gold : sett_ink,
				enabled : (g.orient == 0) });
		},
		function(_v) { g.orient = _v; },
		"which shape of room you play in. auto follows the device - "
		+ "phone portrait, desktop landscape. applies to rooms that "
		+ "have both shapes; the rest are landscape only.");

	settings_slider("fps cap", 30, 240,
		function() { return system.desired_fps; },
		function(_v) { system.desired_fps = _v; },
		" fps", 5,
		"how many frames per second the game runs at. higher = smoother "
		+ "and hungrier; on battery, lower is kinder.");

	// ============================ visuals ===========================
	// THE LOOK, split out of display 2026-09-06 (his ask to organise the
	// room): display had grown into eleven rows mixing window management
	// with cosmetics. "display" is now the WINDOW - where the game sits
	// and how fast it runs - and everything about how it LOOKS lives
	// here, where a player looking to make it prettier or cheaper can
	// find it all in one place.
	settings_section("visuals", c_salmon);

	// THE VISUALISER GRID. The renderer multiplies every grid piece -
	// the border, the inner rules and the outer frame - by one master
	// alpha, so this single number takes the lattice from solid to
	// gone without touching the blocks themselves.
	settings_slider("visualiser grid", 0, 100,
		function() { return g.vis_grid_alpha; },
		function(_v) {
			g.vis_grid_alpha = _v;
			// live, if the visualiser happens to be alive
			if (instance_exists(obj_bignum5))
				obj_bignum5.vis.renderer.grid_alpha = _v / 100;
		},
		"%", 5,
		"how strongly the lattice behind the number is drawn. 0 leaves "
		+ "just the blocks.");

	settings_toggle("menu blur",
		function() { return g.blur; },
		function(_v) { g.blur = _v; },
		"blurs the room behind menus, and carries the shading at its "
		+ "edges - the blur is what keeps that gradient smooth, so the "
		+ "two go together. off saves a little gpu.");

	// room transition style (round 7's showcase slice wipe vs the
	// classic circle; goto_room latches the pick per flight)
	settings_pill("transition", "transkind",
		(g.trans_kind == 1) ? "slice" : "circle",
		function() {
			set_pill("slice",  { val : 1,
				col : (g.trans_kind == 1) ? c_gold : sett_ink,
				enabled : (g.trans_kind == 1) });
			set_pill("circle", { val : 0,
				col : (g.trans_kind == 0) ? c_gold : sett_ink,
				enabled : (g.trans_kind == 0) });
		},
		function(_v) { g.trans_kind = _v; },
		"how room changes look: slice = staggered slats snapping across, "
		+ "circle = the classic closing wipe.");


	// ============================ audio =============================
	settings_section("audio", c_gold);

	settings_toggle("mute all",
		function() { return g.mute; },
		function(_v) { g.mute = _v; },
		"silences everything without touching the volume levels.");

	settings_slider("master volume", 0, 100,
		function() { return g.vol_master; },
		function(_v) { g.vol_master = _v; },
		"%", 1);

	settings_slider("effects volume", 0, 100,
		function() { return g.vol_sfx; },
		function(_v) { g.vol_sfx = _v; },
		"%", 1,
		"clicks, dice, ui. release the knob to hear it.");

	// music lands later - when it does, this is the whole hookup:
	// settings_slider("music volume", 0, 100,
	//     function() { return g.vol_music; },
	//     function(_v) { g.vol_music = _v; }, "%", 1);

	// ============================ gameplay ==========================
	settings_section("gameplay", c_seagreen);

	settings_toggle("autosave",
		function() { return g.autosave; },
		function(_v) { g.autosave = _v; },
		"a rotating autosave every minute, only when something actually "
		+ "changed. off = manual saves only. living dangerously.");

	settings_toggle("rounded bulk buys",
		function() { return g.buy_round; },
		function(_v) { g.buy_round = _v; if (instance_exists(syst_dials)) syst_dials.qtic = 0; },
		"myriad's rule: x10 buys UP TO the next round level (at level 37 "
		+ "it buys 3, to reach 40), x100 to the next hundred. off = a "
		+ "flat +10 / +100 from wherever you are.");

	settings_toggle("always show popups",
		function() { return g.persist_popups; },
		function(_v) { g.persist_popups = _v; },
		"myriad's setting: the credit panel stays out in the money room "
		+ "instead of sliding in only when credits drop.");

	if (variable_global_exists("time_played_active")) {
		settings_info("time played", crunch_time_long(g.time_played_active * 60));
		// active + away: DE's single "time played" figure
		settings_info("total time", crunch_time_long((g.time_played_active
			+ (variable_global_exists("time_played_offline")
				? g.time_played_offline : 0)) * 60));
	}

	// ============================ input =============================
	settings_section("input", c_horange);

	if (!_desktop)
		settings_toggle("haptics",
			function() { return g.haptics; },
			function(_v) { g.haptics = _v; },
			"vibration feedback on taps and clicks.");

	if (_desktop)
		settings_info("keybinds", "soon",
			"nothing is rebindable yet - when keybinds exist, this is "
			+ "where they'll live.");

	// ============================ data ==============================
	settings_section("data", c_pink);

	settings_action("save now",
		function() { syst_handle_save.action = sv_save; saved_flash = 60; },
		"writes the save file this instant (settings save themselves "
		+ "whenever you change one).");

	settings_action("saves + profiles",
		function() { goto_room(rm_saves); },
		"import, export, and profile management.");

	settings_action("reset settings",
		function() { settings_defaults(); dirty_tic = 45; },
		"puts every option on this screen back to its default. your "
		+ "save data is NOT touched.", c_hred);


	// ============= balance tabs (MYRIAD RX placeholder) =============
	// dev knobs return per system as the DE parity rebuild lands its
	// balance_init - each rebuilt system adds its section here (the
	// techdemo's settings_content is the shape reference)

	// ============================ about =============================
	settings_section("about", c_lavender);

	settings_info("version", GM_version);
	settings_info("display",
		string(display_get_width()) + " x " + string(display_get_height())
		+ " @ " + string(display_get_frequency()) + "hz");
	settings_info("platform", _desktop ? "desktop" : "mobile");

	// the debug overlay lived on F1 - which mobile doesn't have
	settings_toggle("show fps",
		function() { return g.show_fps; },
		function(_v) { g.show_fps = _v; },
		"a small live frame rate readout in the bottom-left corner, "
		+ "in every room.");

	settings_toggle("debug overlay",
		function() { return system.debug; },
		function(_v) { system.debug = _v; },
		"the developer watch overlay (same as F1 on pc). not saved - "
		+ "it always boots off.");
}
