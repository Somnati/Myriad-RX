/// @description update_dials() - re-derive EVERY dial plus the fleet
/// aggregates, then the tap (Myriad DE's update_all_gps into
/// update_clicker). THE ONE RESYNC POINT: any code that changes a
/// level, buys a dial, or loads a save calls this and everything
/// downstream is correct again.
/// g.all_level (the summed levels) and g.all_gps (the summed per-second
/// output) are what the TAP reads - see update_click. That is the
/// syphon: dials make taps stronger, so the two halves of the game
/// never compete.
function update_dials() {
	if (!variable_global_exists("dial")) { create_dials(); return; }

	g.all_level = 0;
	g.all_gps   = 0;

	for (var _i = 0; _i < g.dial_total; _i++) {
		update_dial(_i);
		var _d = g.dial[_i];
		g.all_level += _d.level;
		if (_d.gps >= arb(1)) g.all_gps = do_add(g.all_gps, _d.gps);
	}

	// THE TILE TABLE EARNS TOO, so it belongs in the fleet's rate - the
	// header reads all_gps, the offline report quotes it, and rebirth
	// prices a run against it. Leaving the table out would have made
	// every one of those quietly understate the game.
	if (variable_global_exists("tiles"))
		if (g.tiles.gps >= arb(1))
			g.all_gps = do_add(g.all_gps, g.tiles.gps);

	update_click();
}
