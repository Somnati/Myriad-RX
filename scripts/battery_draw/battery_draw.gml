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
function battery_draw() {
	battery_init();
	autom_init();
	var _a = g.autom, _b = g.battery;
	var _sum = BAT_W_RUN + BAT_W_FAB + BAT_W_MERGE;
	var _d = 0;
	if (_a.run.on) _d += BAT_W_RUN   * sqr(_b.rate.run   / 100);
	if (_a.fab.on) _d += BAT_W_FAB   * sqr(_b.rate.fab   / 100);
	if (variable_global_exists("tiles") && g.tiles.automerge)
	               _d += BAT_W_MERGE * sqr(_b.rate.merge / 100);
	return _d / _sum;
}
