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

	// (the tile table is NOT in here. It earns SHARDS, its own currency,
	// so it has no business in the profit fleet's rate - and keeping it
	// out is what stops rebirth, which prices a run off profit held,
	// from quietly measuring the tile board. See tiles_init.)

	update_click();
}
