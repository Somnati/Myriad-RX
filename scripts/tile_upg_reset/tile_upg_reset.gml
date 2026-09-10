/// @description tile_upg_reset() - every tile upgrade level back to 0.
/// No refund: the shards spent are spent. The board, the shards, the
/// flux - nothing else is touched.
///
/// ⚖️ THE SECOND RESET (his ask, 2026-09-10: "a second reset button to
/// reset just the upgrades"). The board's RESET wipes the whole table
/// and the rebirth wipes it for flux; this is the third thing a person
/// testing a cost curve needs - the levels back to zero with the board
/// and its income left standing, so the next run up the ladder is
/// priced against a real board rather than a fresh one.
///
/// BY KEY, NOT BY ROSTER: a level that survived here would be a level
/// the save writes back out, and the upg struct can hold keys the
/// roster no longer lists (slots, and whatever a later roster adds).
/// tiles_wipe uses this for its upgrade half - one loop.
function tile_upg_reset() {
	tiles_init();
	var _t = g.tiles;
	var _ks = variable_struct_get_names(_t.upg);
	for (var _k = 0; _k < array_length(_ks); _k++) _t.upg[$ _ks[_k]] = 0;
	_t.dirty = true;    // gps does not read the levels, but the view's
	_t.rev++;           // caches do - a bumped rev is a rebuilt drawer
	tiles_sync();       // fab_t / stored_max derive from the levels
}
