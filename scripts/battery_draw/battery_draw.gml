/// @description battery_draw() - charge spent per second of absence,
/// as a fraction of "everything at 100%": each machine that is ON
/// draws its weight x (rate/100)^2, over the sum of every weight. So
/// all three at full is exactly 1 (the charge IS hours of absence),
/// a machine at 50% draws a quarter of its share, and one switched
/// off draws nothing. The square is the whole point of the offline
/// rate sliders: slower is more than proportionally cheaper, so a
/// long night away is best run slow. Machines switched off in the
/// automation panel (the dials' cycling, the fabricator, the table's
/// automerge flag) do not draw.
/// OVER BUDGET BURNS CHARGE (his call, 2026-09-14): RAM is the online
/// budget and used to cost nothing away. Now the draw is divided by
/// ram_throttle - the same factor that slows every clock online - so
/// hardware running at 62 of 18 sticks drains the battery x3.4. One
/// penalty, in offline's own currency; the away rates themselves are
/// not slowed (that would be the same penalty twice).
function battery_draw() {
	battery_init();
	autom_init();
	var _a = g.autom, _b = g.battery;
	// the optimiser's rates during a replay it ran (battery_optimise),
	// the player's own otherwise
	var _r = _b[$ "opt_rate"] ?? _b.rate;
	var _sum = BAT_W_RUN + BAT_W_FAB + BAT_W_MERGE;
	var _d = 0;
	if (_a.run.on) _d += BAT_W_RUN   * sqr(_r.run   / 100);
	if (_a.fab.on) _d += BAT_W_FAB   * sqr(_r.fab   / 100);
	if (variable_global_exists("tiles") && g.tiles.automerge)
	               _d += BAT_W_MERGE * sqr(_r.merge / 100);
	return (_d / _sum) / ram_throttle();
}
