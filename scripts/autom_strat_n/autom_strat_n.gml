/// @description autom_strat_n() -> the dials a strategy watches (those with a level)
function autom_strat_n() {
	if (!variable_global_exists("dial")) return 0;
	var _n = 0;
	for (var _i = 0; _i < g.dial_total; _i++) if (g.dial[_i].level > 0) _n++;
	return _n;
}
