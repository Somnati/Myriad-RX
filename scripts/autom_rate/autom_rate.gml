/// @description autom_rate(kind) - the rate one of the three DEFAULT
/// automations runs at, as a multiplier on its own clock:
///   "run"    the dials' cycling (prod_dials: an autonomous dial's
///            cycle accrues at this rate; off, every dial is manual -
///            one banked cycle, tap to run, DE's rule)
///   "fab"    the fabricator (tiles_tick / tiles_fastforward)
///   "merge"  the automerger (same two; the switch is the table's own)
/// on ? speed% x the RAM throttle : 0. Online and offline read the same
/// call, so an absence runs at exactly the rate the player left set.
/// @param kind
function autom_rate(_kind) {
	autom_init();
	var _a = g.autom;
	switch (_kind) {
		case "run":   return _a.run.on ? (_a.run.spd / 100) * ram_throttle() : 0;
		case "fab":   return _a.fab.on ? (_a.fab.spd / 100) * ram_throttle() : 0;
		case "merge": return (_a.am_speed / 100) * ram_throttle();
	}
	return 1;
}
