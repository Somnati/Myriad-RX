/// @description ram_oc_any() -> is anything running on an overclock notch?
/// The band goes hot on this - the sticks and the label lean orange -
/// so the state is visible from every tab, not only on the row.
function ram_oc_any() {
	autom_init();
	var _a = g.autom;
	if (!_a.oc) return false;
	if (_a.tap.on && _a.tap.rate > 10) return true;
	if (_a.run.on && _a.run.spd > 100) return true;
	if (_a.fab.on && _a.fab.spd > 100) return true;
	if (variable_global_exists("tiles") && g.tiles.automerge && _a.am_speed > 100) return true;
	if (_a.upg.buy && _a.upg.t < RAM_TIMER_MIN) return true;
	if (_a.dial_all.on && _a.dial_all.t < RAM_TIMER_MIN) return true;
	var _tn = variable_struct_get_names(_a.tiles);
	for (var _i = 0; _i < array_length(_tn); _i++) {
		var _p = _a.tiles[$ _tn[_i]];
		if (_p.on && _p.t < RAM_TIMER_MIN) return true;
	}
	return false;
}
