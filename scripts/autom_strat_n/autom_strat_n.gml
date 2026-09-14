/// @description autom_strat_n() -> the dials the master row watches:
/// in the filter (g.autom.dial[i].on) AND owned (a level) - what the
/// panel and the statistics count (the RAM bill is the timer's alone)
function autom_strat_n() {
	if (!variable_global_exists("dial")) return 0;
	autom_init();
	var _n = 0;
	var _m = min(g.dial_total, array_length(g.autom.dial));
	for (var _i = 0; _i < _m; _i++) if (g.autom.dial[_i].on && g.dial[_i].level > 0) _n++;
	return _n;
}
