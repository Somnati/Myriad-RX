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

		settings_toggle("always fullscreen on startup",
			function() { return g.fs_on_boot; },
			function(_v) { g.fs_on_boot = _v; },
			"every boot starts fullscreen, whatever the last session ended "
			+ "in. the fullscreen toggle above still works while you play.");

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

	// the frame rate readout sits with the frame rate cap (2026-09-10's
	// tidy: it was under about, where nobody looks for a display switch)
	settings_toggle("show fps",
		function() { return g.show_fps; },
		function(_v) { g.show_fps = _v; },
		"a small live frame rate readout in the bottom-left corner, "
		+ "in every room.");


	// ============================ visuals ===========================
	// THE LOOK, split out of display 2026-09-06 (his ask to organise the
	// room): display had grown into eleven rows mixing window management
	// with cosmetics. "display" is now the WINDOW - where the game sits
	// and how fast it runs - and everything about how it LOOKS lives
	// here, where a player looking to make it prettier or cheaper can
	// find it all in one place.
	settings_section("visuals", c_salmon);
	// (organised 2026-09-14, his ask: the money room's look here, the
	// interface on its own tab - see settings_group)

	settings_group("the field", c_salmon);

	// THE VISUALISER GRID. The renderer multiplies every grid piece -
	// the border, the inner rules and the outer frame - by one master
	// alpha, so this single number takes the lattice from solid to
	// gone without touching the blocks themselves.
	// THE ROOM'S LIGHT ON THE SOLIDS (his brother's argument, 2026-09-11)
	settings_slider("scene light", 0, 100,
		function() { return g.scene_light; },
		function(_v) { g.scene_light = _v; },
		"%", 5,
		"the field's own colour on the dice, the puck and the sprites: each "
		+ "takes the blurred screen around it, along its surface - a die "
		+ "beside a gold block goes gold on that side. 0 turns the pass off.",
		-1, undefined, true);

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
		+ "just the blocks.", -1, undefined, true);

	// THE GLOW over the block field - the room's "glow" effect layer.
	// GameMaker's own default for it is .15, so 15 here is what it
	// shipped as; 0 switches the layer off rather than running a pass
	// that contributes nothing.
	settings_slider("visualiser glow", 0, 60,
		function() { return g.vis_glow; },
		function(_v) {
			g.vis_glow = _v;
			// live, wherever the layer actually exists
			if (layer_exists("glow")) {
				var _gf = layer_get_fx("glow");
				if (_gf != -1) fx_set_parameter(_gf, "g_GlowIntensity", _v / 100);
				layer_set_visible("glow", _v > 0);
			}
		},
		"%", 1,
		"how far the block field bleeds light into the dark around it. "
		+ "0 turns the pass off entirely.", -1, undefined, true);

	// THE PROFIT COLOUR - DE's four (profit_color_config), the one global
	// every profit-denominated thing reads: the counter, the motes, the
	// dial payouts, rates, prices, the offline pile. Picking here changes
	// nothing but g.profit_color, which is the whole design.
	var _pcl = profit_color_config();
	var _pcn = "custom";
	for (var _pk = 0; _pk < array_length(_pcl); _pk++)
		if (_pcl[_pk].col == g.profit_color) _pcn = _pcl[_pk].name;
	settings_pill("profit colour", "profitcol", _pcn,
		function() {
			var _l = profit_color_config();
			for (var _j = 0; _j < array_length(_l); _j++)
				set_pill(_l[_j].name, { val : _l[_j].col, col : _l[_j].col,
				                        enabled : (_l[_j].col == g.profit_color) });
		},
		function(_v) { g.profit_color = _v; },
		"what colour your money is - the counter, the motes, every "
		+ "payout and price. DE's four.",
		g.profit_color);

	settings_group("the tap", c_salmon);

	// THE TAP EFFECT (syst_tapfx; his call 2026-09-14: out of the money
	// room's [fx] chip, into here). tapfx_names is the one list; the
	// index is the saved pick
	var _tfn = tapfx_names();
	settings_pill("tap effect", "tapfx", _tfn[clamp(floor(g.tap_fx), 0, array_length(_tfn) - 1)],
		function() {
			var _l = tapfx_names();
			var _cur = clamp(floor(g.tap_fx), 0, array_length(_l) - 1);
			for (var _j = 0; _j < array_length(_l); _j++)
				set_pill(_l[_j], { val : _j, col : (_cur == _j) ? c_gold : sett_ink, enabled : (_cur == _j) });
		},
		function(_v) { g.tap_fx = _v; },
		"what a tap draws where it lands, on top of the float and the "
		+ "motes: a soft glow, a one-cell shockwave (plain, or with a "
		+ "red/blue split), a cross, an x, a square, a ring closing in, "
		+ "a bolt - or nothing.");

	settings_toggle("crit pop",
		function() { return g.tap_crit_pop; },
		function(_v) { g.tap_crit_pop = _v; },
		"DE's critical: a white dot that opens into a ring beside a tap "
		+ "that crits, on top of whichever effect is picked.");

	settings_group("the motes", c_salmon);

	// THE MOTES, ONE PILL A LANE (his ask, 2026-09-10). The roster is
	// bit_config; the lane keys are bit_look's. Four literal blocks for
	// the reason the sound pills are four literal blocks (see there):
	// set_pill pushes onto the OWNER's _pills, and a method({lane:..})
	// wrapper would rebind self away from it. These close on pick -
	// nothing here to audition, the motes fly in other rooms.

	settings_pill("profit bits", "bitprofit",
		bit_look("profit").name,
		function() {
			var _l = bit_config();
			var _sel = bit_look("profit").id;
			for (var _j = 0; _j < array_length(_l); _j++)
				set_pill(_l[_j].name, { val : _l[_j].id,
					col : c_gold, enabled : (_l[_j].id == _sel) });
		},
		function(_v) { g.bit_pick.profit = _v; },
		"the motes a dial payout or a tap throws at the profit "
		+ "counter. glowing square is what the game has always "
		+ "drawn; plain is the same square without the halo.");

	settings_pill("credit bits", "bitcredit",
		bit_look("credit").name,
		function() {
			var _l = bit_config();
			var _sel = bit_look("credit").id;
			for (var _j = 0; _j < array_length(_l); _j++)
				set_pill(_l[_j].name, { val : _l[_j].id,
					col : c_gold, enabled : (_l[_j].id == _sel) });
		},
		function(_v) { g.bit_pick.credit = _v; },
		"the motes a credit drop throws at the credits panel.");

	settings_pill("unit bits", "bitunit",
		bit_look("unit").name,
		function() {
			var _l = bit_config();
			var _sel = bit_look("unit").id;
			for (var _j = 0; _j < array_length(_l); _j++)
				set_pill(_l[_j].name, { val : _l[_j].id,
					col : c_gold, enabled : (_l[_j].id == _sel) });
		},
		function(_v) { g.bit_pick.unit = _v; },
		"the burst the rebirth banner throws when it fires.");

	settings_pill("tile bits", "bittile",
		bit_look("tile").name,
		function() {
			var _l = bit_config();
			var _sel = bit_look("tile").id;
			for (var _j = 0; _j < array_length(_l); _j++)
				set_pill(_l[_j].name, { val : _l[_j].id,
					col : c_gold, enabled : (_l[_j].id == _sel) });
		},
		function(_v) { g.bit_pick.tile = _v; },
		"the fountain the tile table pays its shards through - one "
		+ "mote a second per tile, all from one spot. plain by "
		+ "default: that many halos in one place stop being motes.");

	// ---- the motes' flight (DE's part_grav / alt profit color) ----
	var _man = ["swoop", "bow", "straight"];
	settings_pill("mote path", "motearc", _man[clamp(g.mote_arc, 0, 2)],
		function() {
			set_pill("swoop",    { val : 0, col : (g.mote_arc == 0) ? c_gold : sett_ink, enabled : (g.mote_arc == 0) });
			set_pill("bow",      { val : 1, col : (g.mote_arc == 1) ? c_gold : sett_ink, enabled : (g.mote_arc == 1) });
			set_pill("straight", { val : 2, col : (g.mote_arc == 2) ? c_gold : sett_ink, enabled : (g.mote_arc == 2) });
		},
		function(_v) { g.mote_arc = _v; },
		"how a payout's motes fly to the counter: myriad's lazy swoop, a "
		+ "shallow bow, or a straight line. the tile fountain keeps its own.");

	settings_toggle("rainbow motes",
		function() { return g.random_profit_color; },
		function(_v) { g.random_profit_color = _v; },
		"DE's alt profit colour: every profit mote rolls its own hue "
		+ "instead of wearing the profit colour.");

	settings_group("the toys", c_salmon);

	// the dice on the tap table. The roster is dice_mat_config - adding
	// a finish is one row there and this pill grows on its own. Stays
	// open, like the sound pills: picking a material is browsing, and
	// the dice repaint live on the frame you choose.
	settings_pill("dice material", "dicemat",
		dice_mat_name(),
		function() {
			var _l = dice_mat_config();
			for (var _j = 0; _j < array_length(_l); _j++)
				set_pill(_l[_j].name, { val : _l[_j].id,
					col : c_gold, enabled : (_l[_j].id == g.dice_mat) });
		},
		function(_v) { g.dice_mat = _v; },
		"what the dice on the tap table are made of. random rolls a "
		+ "different hue and finish for every die, which is the default.",
		-1, true);

	// THE COIN's finish, off the same roster (2026-09-14): gold by default
	settings_pill("coin material", "coinmat",
		coin_mat_name(),
		function() {
			var _l = dice_mat_config();
			for (var _j = 0; _j < array_length(_l); _j++)
				set_pill(_l[_j].name, { val : _l[_j].id,
					col : c_gold, enabled : (_l[_j].id == g.coin_mat) });
		},
		function(_v) { g.coin_mat = _v; },
		"what the coin is struck from. the same finishes as the dice; "
		+ "a coin is always at least mostly metal.",
		-1, true);

	// the puck, off the dice's roster (his ask, 2026-09-10). "random" is
	// the classic black rubber here - a puck should not roll a body
	// colour - and the pill says so
	var _pm = "black rubber";
	var _pml = dice_mat_config();
	for (var _pj = 0; _pj < array_length(_pml); _pj++)
		if (_pml[_pj].id == g.puck_mat && _pml[_pj].id != "random") _pm = _pml[_pj].name;
	settings_pill("puck material", "puckmat", _pm,
		function() {
			var _l = dice_mat_config();
			for (var _j = 0; _j < array_length(_l); _j++)
				set_pill((_l[_j].id == "random") ? "black rubber" : _l[_j].name,
					{ val : _l[_j].id, col : c_gold, enabled : (_l[_j].id == g.puck_mat) });
		},
		function(_v) { g.puck_mat = _v; },
		"what the puck on the tap table is made of. black rubber is the "
		+ "classic; the rest are the dice's finishes.",
		-1, true);

	// THE EXPEDITION PAGES' DITHER (his call, 2026-09-15: "those oldschool
	// dither methods"): the one quantisation the float pages meet, at
	// their blit (sh_page_out) - the bayer ordered pattern, plain or
	// posterised into it, or a film grain
	settings_group("the expedition pages", c_salmon);
	settings_pill("page dither", "pagedith",
		g.page_dither,
		function() {
			set_pill("ordered", { val : "ordered", col : c_gold, enabled : (g.page_dither == "ordered") });
			set_pill("grain",   { val : "grain",   col : c_gold, enabled : (g.page_dither == "grain") });
		},
		function(_v) { g.page_dither = _v; },
		"how the sky, the world and the galaxy meet the screen's 8 bits: ORDERED is the old-school "
		+ "bayer crosshatch, static; GRAIN is a fresh film grain every frame. the slider under this "
		+ "sets how much of either.");
	// (LIVE: the settings fade to the knob while it is held, the expedition
	// page under it - his ask: "so i can see the changes live")
	settings_slider("dither intensity", 0, 100,
		function() { return g.page_dither_amt; },
		function(_v) { g.page_dither_amt = _v; },
		"%", 1,
		"how strong the dither is: about 17% is one level - just enough to break the bands; "
		+ "more and the pattern (or the grain) becomes part of the look. hold the knob and the "
		+ "settings fade so the expedition page shows it as you drag.",
		-1, undefined, true);
	// THE HP BARS' COLOUR (his ask, 2026-09-16): the house red, or the green
	settings_pill("hp bar colour", "hpbarcol",
		g.hp_bar_col,
		function() {
			set_pill("red",   { val : "red",   col : c_hred,   enabled : (g.hp_bar_col == "red") });
			set_pill("green", { val : "green", col : c_sgreen, enabled : (g.hp_bar_col == "green") });
		},
		function(_v) { g.hp_bar_col = _v; },
		"the colour of every hp bar - the crew's banners, the sheet, the trip page.");

	// THE TAB'S OWN RESET (his ask, 2026-09-11)
	settings_info("", "");   // (a blank row: the reset is not adjacent to anything you have to tap)
	settings_action("reset visuals to defaults",
		function() { settings_defaults("visuals"); dirty_tic = 45; },
		"puts the money room's look back to its defaults - the field, the motes, the finishes. "
		+ "(the interface tab shares the same reset)", c_hred, true);

	// ============================ interface =========================
	settings_section("interface", rgb(150, 170, 255));

	settings_group("the menu", rgb(150, 170, 255));

	settings_toggle("menu blur",
		function() { return g.blur; },
		function(_v) { g.blur = _v; },
		"blurs the room behind menus, and carries the shading at its "
		+ "edges - the blur is what keeps that gradient smooth, so the "
		+ "two go together. off saves a little gpu.");

	// THE HEADER MENU'S PANEL (his ask, 2026-09-13): the teal plate under the
	// blur (default), plain black, or the dial drawer's pixelated glass
	settings_pill("menu style", "menustyle",
		g.menu_style,
		function() {
			set_pill("default", { val : "default", col : c_gold, enabled : (g.menu_style == "default") });
			set_pill("black",   { val : "black",   col : c_gold, enabled : (g.menu_style == "black") });
			set_pill("glass",   { val : "glass",   col : c_gold, enabled : (g.menu_style == "glass") });
		},
		function(_v) { g.menu_style = _v; },
		"the header menu's panel: the teal plate under the blur, plain black, "
		+ "or the dial drawer's pixelated glass.");

	settings_group("the screen", rgb(150, 170, 255));

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

	settings_toggle("pointer shading",
		function() { return g.cursor_ray; },
		function(_v) { g.cursor_ray = _v; },
		"the arrow lit as a solid, the way the dice and the puck are - "
		+ "same light, same finish. off keeps the raycast (the squash "
		+ "still re-pixelates) but paints it flat white and ink.");

	settings_toggle("motion blur",
		function() { return g.motion_blur; },
		function(_v) { g.motion_blur = _v; },
		"the real thing, per object: the pointer, the puck and the "
		+ "money motes are drawn at several instants across each "
		+ "frame's travel, so a flick, a throw or a flying mote streaks "
		+ "the way a camera would see it. off falls back to the puck's "
		+ "old trail.");

	settings_group("the title", rgb(150, 170, 255));

	// THE TITLE'S BACKDROP (his lean, 2026-09-13): the drifting blocks, or a
	// parallax starfield
	settings_pill("title backdrop", "titlebg",
		g.title_bg,
		function() {
			set_pill("starfield", { val : "starfield", col : c_gold, enabled : (g.title_bg == "starfield") });
			set_pill("blocks",    { val : "blocks",    col : c_gold, enabled : (g.title_bg == "blocks") });
			set_pill("trace",     { val : "trace",     col : c_gold, enabled : (g.title_bg == "trace") });
			set_pill("forge",     { val : "forge",     col : c_gold, enabled : (g.title_bg == "forge") });
		},
		function(_v) { g.title_bg = _v; },
		"what drifts behind the title: a starfield flying at you, the money room's blocks in the fog, "
		+ "a pen tracing figures, or DE's gen forge - a dial's cell breathing under its halo, motes and sparks drawn to it.");

	// THE TAB'S OWN RESET (his ask, 2026-09-11)
	settings_info("", "");   // (a blank row: the reset is not adjacent to anything you have to tap)
	settings_action("reset interface to defaults",
		function() { settings_defaults("visuals"); dirty_tic = 45; },
		"puts the menu, the screen and the title back to their defaults. "
		+ "(the visuals tab shares the same reset)", c_hred, true);

	// ============================== crt =============================
	// THE TUBE (his ask, 2026-09-10): syst_crt + sh_crt. Its own tab:
	// where it runs, which seat, and the five knobs. Nothing here dims
	// a pixel except the vignette (read the shader's header).

	settings_section("crt", c_sblue);

	var _cm = ["off", "title screen", "everywhere"];
	settings_pill("crt", "crtmode", _cm[clamp(g.crt_mode, 0, 2)],
		function() {
			set_pill("off",          { val : 0, col : (g.crt_mode == 0) ? c_gold : sett_ink, enabled : (g.crt_mode == 0) });
			set_pill("title screen", { val : 1, col : (g.crt_mode == 1) ? c_gold : sett_ink, enabled : (g.crt_mode == 1) });
			set_pill("everywhere",   { val : 2, col : (g.crt_mode == 2) ? c_gold : sett_ink, enabled : (g.crt_mode == 2) });
		},
		function(_v) { g.crt_mode = _v; },
		"the picture through a tube: scanlines, a phosphor grille, curved "
		+ "glass, a red/blue split at the edges and a slow roll. the rows "
		+ "keep their brightness - only the gaps between them are dark.");

	settings_toggle("over the interface",
		function() { return g.crt_over_ui; },
		function(_v) { g.crt_over_ui = _v; },
		"on: everything is on the glass - header, menus, drawers, the "
		+ "lot; only the pointer stays off it. off: the tube sits behind "
		+ "the interface, so in the money room it is the visualiser, the "
		+ "dice and the puck alone.");

	settings_slider("curvature", 0, 100,
		function() { return g.crt_curve; },
		function(_v) { g.crt_curve = _v; },
		"%", 5,
		"how far the glass bulges. the frame stays put and nothing is "
		+ "cropped; the middle magnifies. over the interface the middle "
		+ "of the picture then sits a pixel or two from its hit regions, "
		+ "so turn this down if taps feel off.");

	settings_slider("scanlines", 0, 100,
		function() { return g.crt_scan; },
		function(_v) { g.crt_scan = _v; },
		"%", 5,
		"how dark the line between rows is. the row itself is never "
		+ "dimmed.");

	settings_slider("phosphor grille", 0, 100,
		function() { return g.crt_grille; },
		function(_v) { g.crt_grille = _v; },
		"%", 5,
		"the rgb stripe, at screen resolution. balanced so the picture's "
		+ "brightness and colour hold - it reads as texture, not tint.");

	settings_slider("bloom", 0, 100,
		function() { return g.crt_bloom; },
		function(_v) { g.crt_bloom = _v; },
		"%", 5,
		"the glass glowing around bright things - halation. adds light "
		+ "(only the bright parts spill), and it fills the scanline gaps "
		+ "softly the way a real tube does.");

	settings_slider("chroma split", 0, 100,
		function() { return g.crt_chroma; },
		function(_v) { g.crt_chroma = _v; },
		"%", 5,
		"red and blue pulled apart toward the edges, where a lens is "
		+ "worst.");

	settings_slider("vignette", 0, 100,
		function() { return g.crt_vig; },
		function(_v) { g.crt_vig = _v; },
		"%", 5,
		"the glass darkening toward the corners. the one knob here that "
		+ "dims pixels, so it starts at 0.");

	settings_toggle("roll + flicker",
		function() { return g.crt_roll; },
		function(_v) { g.crt_roll = _v; },
		"a faint bright band drifting down every few seconds, and a "
		+ "breath of flicker.");


	// THE TAB'S OWN RESET (his ask, 2026-09-11)
	settings_info("", "");   // (a blank row: the reset is not adjacent to anything you have to tap)
	settings_action("reset crt to defaults",
		function() { settings_defaults("crt"); dirty_tic = 45; },
		"puts every option on THIS tab back to its default - the tube back to everywhere, over the interface, its five knobs and the roll. "
		+ "the other tabs are not touched.", c_hred, true);

	// ============================ readouts ==========================
	// WHAT THE NUMBERS SAY AND WHERE (2026-09-10's tidy + DE's ports):
	// how figures are written, the tap's own number, the two corner
	// readouts. A player who wants a quieter screen looks here.
	settings_section("readouts", c_aqua);

	// THE NUMBER FORMAT (his ask, 2026-09-10): num_format_config's five.
	// Every crunch_arb reads the pick, so this is how the whole game
	// counts. [compare] on the menu's misc list lays them side by side.
	var _nfl = num_format_config();
	settings_pill("number format", "numfmt", _nfl[clamp(g.num_format, 0, array_length(_nfl) - 1)].name,
		function() {
			var _l = num_format_config();
			for (var _j = 0; _j < array_length(_l); _j++)
				set_pill(_l[_j].name, { val : _j, col : (g.num_format == _j) ? c_gold : sett_ink,
				                        enabled : (g.num_format == _j) });
		},
		function(_v) { g.num_format = _v; },
		"how big numbers read everywhere: short (k m b t aa ab...), the "
		+ "short-scale names (spelled out under the counter), scientific, "
		+ "or the log itself. menu > misc > number formats compares them.");

	var _ttn = ["at the tap", "centred", "none"];
	settings_pill("tap numbers", "taptext", _ttn[clamp(g.tap_text, 0, 2)],
		function() {
			set_pill("at the tap", { val : 0, col : (g.tap_text == 0) ? c_gold : sett_ink, enabled : (g.tap_text == 0) });
			set_pill("centred",    { val : 1, col : (g.tap_text == 1) ? c_gold : sett_ink, enabled : (g.tap_text == 1) });
			set_pill("none",       { val : 2, col : (g.tap_text == 2) ? c_gold : sett_ink, enabled : (g.tap_text == 2) });
		},
		function(_v) { g.tap_text = _v; },
		"DE's tap text format: the +profit float rises from the tap, or "
		+ "one big figure in the middle of the room, or nothing.");

	settings_toggle("tap rate readout",
		function() { return g.tps_readout; },
		function(_v) { g.tps_readout = _v; },
		"the 'tps N +X/s' line in the money room's bottom-left while you "
		+ "tap (DE's tap gps position, minus the position).");

	settings_toggle("bounce tracker",
		function() { return g.bounce_text; },
		function(_v) { g.bounce_text = _v; },
		"the puck's throw readout top-left: bounces, the throw's profit, "
		+ "its speed (DE's bounce text).");

	// THE TAB'S OWN RESET (his ask, 2026-09-11)
	settings_info("", "");   // (a blank row: the reset is not adjacent to anything you have to tap)
	settings_action("reset readouts to defaults",
		function() { settings_defaults("readouts"); dirty_tic = 45; },
		"puts every option on THIS tab back to its default - number format, tap numbers, the tap rate and bounce readouts, the dial view. "
		+ "the other tabs are not touched.", c_hred, true);

	// ============================ audio =============================
	settings_section("audio", c_gold);
	// (grouped 2026-09-14, his question "paired up or separate?": the MIX
	// on top, then each fader beside the sound it turns)
	settings_group("the mix", c_gold);

	settings_toggle("mute all",
		function() { return g.mute; },
		function(_v) { g.mute = _v; },
		"silences everything without touching the volume levels.");

	// THE FOUR FADERS IN FOUR COLOURS (his call, 2026-09-14): master white,
	// effects yellow, tap hred, dial sblue - and each auditions on RELEASE
	settings_slider("master volume", 0, 100,
		function() { return g.vol_master; },
		function(_v) { g.vol_master = _v; },
		"%", 1, "", c_white,
		function() { play_sound_ext(snd_matclick2, 1, 1.05, .5, 1); });

	settings_slider("effects volume", 0, 100,
		function() { return g.vol_sfx; },
		function(_v) { g.vol_sfx = _v; },
		"%", 1,
		"clicks, dice, ui. release the knob to hear it.", c_hyellow,
		function() { play_sound_ext(snd_matclick2, 1, 1.05, .5, 1); });

	// ---- THE THREE SWAPPABLE SOUNDS (DE's "gen sound", generalised) ----
	// Each pill builds itself from sfx_config, so adding a sound is one
	// row in that file and nothing here. Picking one PLAYS it - a sound
	// you have to leave the menu to hear is a sound you pick by name and
	// then regret.
	//
	// THE PILL HANDS BACK THE ID, not the row number. It used to hand
	// back an index straight into g.tap_sound, which is what made the
	// roster append-only; ids let him delete from the middle (his ask,
	// 2026-09-08) without repointing anybody's saved choice.
	//
	// ⚖️ WRITTEN OUT THREE TIMES ON PURPOSE. The obvious tidy is one
	// helper taking the kind, but GML closures do not capture locals, so
	// the kind would have to ride method({k:...}, fn) - and that rebinds
	// `self` to the struct, while set_pill pushes onto the OWNER's
	// _pills. The helper would have crashed the moment a pillbox opened.
	// Literal kinds in a declarative content script are the cheaper
	// mistake, and this file is a list of literal rows already.
	settings_group("the tap", c_gold);
	settings_pill("tap sound", "sfxtap",
		sfx_config("tap")[sfx_index("tap")].name,
		function() {
			var _l = sfx_config("tap");
			var _sel = sfx_index("tap");
			for (var _j = 0; _j < array_length(_l); _j++) {
				var _on = (_j == _sel);
				// ONE palette for every pill: `enabled` decides lit or
				// unlit, which is what lets a staying box relight by
				// flipping that one flag (syst_settings' pick handler).
				// Baking the colour per state instead would have meant
				// rebuilding the list on every audition.
				set_pill(_l[_j].name, { val : _l[_j].id,
					col : c_gold, enabled : _on });
			}
		},
		function(_v) { g.sfx_pick.tap = _v; sfx_play("tap"); },
		"what a tap sounds like. myriad de's list, minus the three he cut.",
		-1, true);   // stays open: this list is for auditioning

	// its fader, right under it (his ask for the two faders; they sat
	// as a pair at the end - a knob belongs with the sound it turns)
	settings_slider("tap volume", 0, 100,
		function() { return g.vol_tap; },
		function(_v) { g.vol_tap = _v; },
		"%", 1, "taps and criticals, as a share of the effects volume.", c_hred,
		function() { sfx_play("tap"); });

	// THE AUTOTAPPER'S OWN FADER (his ask, 2026-09-14): its taps ride the
	// tap sound at this share - half by default, so a machine tapping ten
	// times a second sits under your own taps
	settings_slider("autotapper volume", 0, 100,
		function() { return g.vol_autotap; },
		function(_v) { g.vol_autotap = _v; },
		"%", 1, "the autotapper's taps, as a share of the tap volume. it taps a lot.",
		merge_colour(c_hred, c_white, .35),
		function() { sfx_play("tap", g.vol_autotap / 100); });


	settings_pill("critical sound", "sfxcrit",
		sfx_config("crit")[sfx_index("crit")].name,
		function() {
			var _l = sfx_config("crit");
			var _sel = sfx_index("crit");
			for (var _j = 0; _j < array_length(_l); _j++) {
				var _on = (_j == _sel);
				// ONE palette for every pill: `enabled` decides lit or
				// unlit, which is what lets a staying box relight by
				// flipping that one flag (syst_settings' pick handler).
				// Baking the colour per state instead would have meant
				// rebuilding the list on every audition.
				set_pill(_l[_j].name, { val : _l[_j].id,
					col : c_gold, enabled : _on });
			}
		},
		function(_v) { g.sfx_pick.crit = _v; sfx_play("crit"); },
		"what a critical tap sounds like. it rides the tap fader - a "
		+ "critical is a tap.",
		-1, true);

	settings_pill("credit sound", "sfxcredit",
		sfx_config("credit")[sfx_index("credit")].name,
		function() {
			var _l = sfx_config("credit");
			var _sel = sfx_index("credit");
			for (var _j = 0; _j < array_length(_l); _j++) {
				var _on = (_j == _sel);
				set_pill(_l[_j].name, { val : _l[_j].id,
					col : c_gold, enabled : _on });
			}
		},
		function(_v) { g.sfx_pick.credit = _v; sfx_play("credit"); },
		"what a credit drop sounds like. it rides the tap fader - a "
		+ "credit drop is something your tap did.",
		-1, true);

	settings_group("the dials", c_gold);
	settings_pill("dial sound", "sfxdial",
		sfx_config("dial")[sfx_index("dial")].name,
		function() {
			var _l = sfx_config("dial");
			var _sel = sfx_index("dial");
			for (var _j = 0; _j < array_length(_l); _j++) {
				var _on = (_j == _sel);
				// ONE palette for every pill: `enabled` decides lit or
				// unlit, which is what lets a staying box relight by
				// flipping that one flag (syst_settings' pick handler).
				// Baking the colour per state instead would have meant
				// rebuilding the list on every audition.
				set_pill(_l[_j].name, { val : _l[_j].id,
					col : c_gold, enabled : _on });
			}
		},
		function(_v) { g.sfx_pick.dial = _v; sfx_play("dial"); },
		"what a finished dial cycle sounds like. OFF by default on "
		+ "purpose: a late fleet finishes several cycles a second, and a "
		+ "sound on every one of them stops being feedback. rate limited "
		+ "whichever you pick.",
		-1, true);

	settings_slider("dial volume", 0, 100,
		function() { return g.vol_dial; },
		function(_v) { g.vol_dial = _v; },
		"%", 1, "finished dial cycles, as a share of the effects volume.", c_sblue,
		function() { sfx_play("dial"); });


	// music lands later - when it does, this is the whole hookup:
	// settings_slider("music volume", 0, 100,
	//     function() { return g.vol_music; },
	//     function(_v) { g.vol_music = _v; }, "%", 1);

	// THE TAB'S OWN RESET (his ask, 2026-09-11)
	settings_info("", "");   // (a blank row: the reset is not adjacent to anything you have to tap)
	settings_action("reset audio to defaults",
		function() { settings_defaults("audio"); dirty_tic = 45; },
		"puts every option on THIS tab back to its default - every volume and the three swappable sounds. "
		+ "the other tabs are not touched.", c_hred, true);

	// ============================ gameplay ==========================
	// how buying and the money room BEHAVE. (autosave moved to data,
	// the two clocks to about, the number format to readouts -
	// 2026-09-10's tidies: a section is what a player would look under,
	// not where a row landed first)
	settings_section("gameplay", c_seagreen);

	// THE BATTERY OPTIMISER - an unlockable ability later; a toggle here
	// so he can feel it first (his idea, 2026-09-11)
	settings_toggle("battery optimiser (debug)",
		function() { return g.bat_opt; },
		function(_v) { g.bat_opt = _v; },
		"when you return, the replay runs the machines at the offline rates "
		+ "that make the most of the charge over exactly that absence - up "
		+ "for a short one, down for a long one - instead of the rates you "
		+ "left. your sliders are never changed.");

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

	// THE TAB'S OWN RESET (his ask, 2026-09-11)
	settings_info("", "");   // (a blank row: the reset is not adjacent to anything you have to tap)
	settings_action("reset gameplay to defaults",
		function() { settings_defaults("gameplay"); dirty_tic = 45; },
		"puts every option on THIS tab back to its default - bulk-buy rounding, the credit panel, the battery optimiser. "
		+ "the other tabs are not touched.", c_hred, true);

	// ============================ input =============================
	settings_section("input", c_horange);

	settings_toggle("swipe protection",
		function() { return g.swipe_protect; },
		function(_v) { g.swipe_protect = _v; },
		"DE's: a drawer's close swipe has to start on the drawer's own "
		+ "side. off, a swipe from anywhere shuts an open drawer.");

	// THE HAND RIDES THE PUCK (his curiosity, 2026-09-14)
	settings_toggle("hand rides the puck",
		function() { return g.puck_hand; },
		function(_v) { g.puck_hand = _v; if (!_v) g.cursor_ride = undefined; },
		"while you hold the puck the arrow sits ON it and lags with it - "
		+ "the puck still chases the real pointer exactly as before. off, "
		+ "the arrow stays with your hand.");

	if (!_desktop)
		settings_toggle("haptics",
			function() { return g.haptics; },
			function(_v) { g.haptics = _v; },
			"vibration feedback on taps and clicks.");

	if (_desktop)
		settings_info("keybinds", "soon",
			"nothing is rebindable yet - when keybinds exist, this is "
			+ "where they'll live.");

	// THE TAB'S OWN RESET (his ask, 2026-09-11)
	settings_info("", "");   // (a blank row: the reset is not adjacent to anything you have to tap)
	settings_action("reset input to defaults",
		function() { settings_defaults("input"); dirty_tic = 45; },
		"puts every option on THIS tab back to its default - haptics and swipe protection. "
		+ "the other tabs are not touched.", c_hred, true);

	// ============================ data ==============================
	settings_section("data", c_pink);

	// THE SPRITES' DEBUG SPAWN (his ask, 2026-09-11): how they are earned
	// is not decided; this is how you meet one
	settings_action("debug: spawn a sprite",
		function() {
			var _sp = sprite_spawn("tap");
			assign_banner(_sp.name + " showed up in the money room", _sp.col, c_black);
		},
		"a little helper appears in the money room and taps for you - "
		+ "slowly, lazily, and while you are away. its taps are its own, "
		+ "not yours. poke it.", c_sgreen);
	// UNLIMITED TICKETS (his ask, 2026-09-14): the book refills as you
	// scratch, off the milestone table so every rarity turns up. Not
	// saved - it boots off, like the overlay
	settings_toggle("debug: unlimited tickets",
		function() { return variable_global_exists("tickets_free") && g.tickets_free; },
		function(_v) {
			g.tickets_free = _v;
			if (_v) { ticket_init(); while (array_length(g.tickets.pile) < 3) ticket_grant("milestone", true); }
		},
		"the scratch tickets never run out: every one you finish is replaced, "
		+ "rarities off the milestone table. debug only, boots off.", c_gold);
	settings_action("debug: clear sprites",
		function() {
			g.sprites = [];
			save_mark_dirty();
			assign_banner("the sprites have gone", c_gray, c_black);
		},
		"sends every sprite away. debug only.", c_gray);

	// THE CHANGELOG (his ask, 2026-09-14): what changed, release by
	// release - "new" while the newest version is one you have not opened
	{
		var _cl = changelog_content();
		var _newest = (array_length(_cl) > 0 && array_length(_cl[0].releases) > 0) ? _cl[0].releases[0].ver : "";
		var _seen = variable_global_exists("changelog_seen") ? g.changelog_seen : "";
		settings_action((_seen != _newest && _newest != "") ? "changelog  -  new" : "changelog",
			function() { changelog_open(); },
			"what changed, release by release. newest first.", c_gold);
	}

	// autosave and its backup ladder live here, with the saves they
	// write (they sat under gameplay - a save cadence is not play)
	settings_toggle("autosave",
		function() { return g.autosave; },
		function(_v) { g.autosave = _v; },
		"a rotating autosave every minute, only when something actually "
		+ "changed. off = manual saves only. living dangerously.");

	// THE BACKUP LADDER. The three autosave slots used to be a flat
	// shift, so they only ever spanned three minutes - fine against a
	// crash, useless for undoing a decision. These two say how far
	// apart the rungs sit; the saves menu prints the real ages.
	if (g.autosave) {
		settings_slider("recent backup", 0, 60,
			function() { return g.backup_mid; },
			function(_v) { g.backup_mid = _v; }, " min", 1,
			"how old backup slot 2 must be before the newest snapshot "
			+ "pushes into it. bigger = the middle backup reaches "
			+ "further into the past. 0 = it moves every minute, the "
			+ "old behaviour.");

		settings_slider("deep backup", 0, 480,
			function() { return g.backup_deep; },
			function(_v) { g.backup_deep = _v; }, " min", 10,
			"the same gate for slot 3, the oldest backup - the one you "
			+ "reach for when you want a run back the way it was an "
			+ "hour ago, not a minute ago.");
	}

	settings_action("save now",
		function() { syst_handle_save.action = sv_save; saved_flash = 60; },
		"writes the save file this instant (settings save themselves "
		+ "whenever you change one).");

	settings_action("saves + profiles",
		function() { goto_room(rm_saves); },
		"import, export, and profile management.");

	settings_info("", "");   // (a blank row: the reset is not adjacent to anything you have to tap)
	settings_action("reset settings",
		function() { settings_defaults(); dirty_tic = 45; },
		"puts every option on this screen back to its default. your "
		+ "save data is NOT touched.", c_hred, true);


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
	// the two clocks - readouts, so they sit with the other readouts
	if (variable_global_exists("time_played_active")) {
		settings_info("time played", crunch_time_long(g.time_played_active * 60));
		// active + away: DE's single "time played" figure
		settings_info("total time", crunch_time_long((g.time_played_active
			+ (variable_global_exists("time_played_offline")
				? g.time_played_offline : 0)) * 60));
	}


	// the debug overlay lived on F1 - which mobile doesn't have
	settings_toggle("debug overlay",
		function() { return system.debug; },
		function(_v) { system.debug = _v; },
		"the developer watch overlay: fps, globals you can edit, objects, "
		+ "the log (same as F1 on pc). not saved - it always boots off.");
}
