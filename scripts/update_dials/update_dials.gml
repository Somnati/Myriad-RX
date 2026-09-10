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

	g.all_level   = 0;
	g.all_gps_raw = 0;

	for (var _i = 0; _i < g.dial_total; _i++) {
		update_dial(_i);
		var _d = g.dial[_i];
		g.all_level += _d.level;
		if (_d.gps >= arb(1)) g.all_gps_raw = do_add(g.all_gps_raw, _d.gps);
	}

	// ⚖️ THE FLEET TOTAL IS WHAT THE FLEET PAYS (his report, 2026-09-10:
	// "billions per cycle from my dials but the p/s at the bottom
	// doesn't show that... my gain per tap isn't scaling with my
	// dials"). The dial curves sum to all_gps_raw; the tile table's
	// dial profit boost multiplies every payout (prod_dials), so the
	// rate the game actually runs at is the raw sum x that boost. DE's
	// tap syphoned pre_os_gps, which update_auto set AFTER the mod_gps
	// (tile) multiply - so the boosted total is also what the tap's 1%
	// is of. all_gps_raw survives for the one reader that wants a
	// ratio (the drawer's % view). fleet_refresh re-derives this once a
	// second, because the board grows on its own between dial changes.
	g.all_gps = fleet_total();

	// (the tile table is NOT in here. It earns SHARDS, its own currency,
	// so it has no business in the profit fleet's rate - and keeping it
	// out is what stops rebirth, which prices a run off profit held,
	// from quietly measuring the tile board. See tiles_init.)

	update_click();
}
