/// @description autom_rate(kind) - the rate one of the three DEFAULT
/// automations runs at, as a multiplier on its own clock:
///   "run"    the dials' cycling (prod_dials: an autonomous dial's
///            cycle accrues at this rate; off, every dial is manual -
///            one banked cycle, tap to run, DE's rule)
///   "fab"    the fabricator (tiles_tick / tiles_fastforward)
///   "merge"  the automerger (same two; the switch is the table's own)
/// ONLINE: on ? speed% x the RAM throttle : 0.
/// OFFLINE (g.offline_replaying, raised by offline_replay around the
/// replay): on ? the BATTERY's offline rate for the machine : 0 - the
/// battery panel's sliders are the away speeds, RAM is the online
/// budget, and the one call serves both so nothing forks.
/// @param kind
function autom_rate(_kind) {
	autom_init();
	var _a = g.autom;
	if (variable_global_exists("offline_replaying") && g.offline_replaying) {
		battery_init();
		// the optimiser's rates for THIS replay, if it ran (battery_optimise)
		var _r = g.battery[$ "opt_rate"] ?? g.battery.rate;
		// the staff work offline too (sprite_staff: no RAM, no battery)
		switch (_kind) {
			case "run":   return _a.run.on ? (_r.run   / 100) * (1 + sprite_staff("run")) : 0;
			case "fab":   return _a.fab.on ? (_r.fab   / 100) * (1 + sprite_staff("fab")) : 0;
			case "merge": return (_r.merge / 100) * (1 + sprite_staff("merge"));
		}
		return 1;
	}
	switch (_kind) {
		case "run":   return _a.run.on ? (_a.run.spd / 100) * ram_throttle() * (1 + sprite_staff("run")) : 0;
		case "fab":   return _a.fab.on ? (_a.fab.spd / 100) * ram_throttle() * (1 + sprite_staff("fab")) : 0;
		case "merge": return (_a.am_speed / 100) * ram_throttle() * (1 + sprite_staff("merge"));
	}
	return 1;
}
