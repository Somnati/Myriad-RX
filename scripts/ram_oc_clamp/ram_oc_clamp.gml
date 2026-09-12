/// @description ram_oc_clamp() - drop every overclocked value back to
/// its track's end. Runs when the toggle goes OFF (the notches close,
/// so nothing may sit on them) and after a load or an unpack that
/// arrives with the toggle off. Values on the normal range are not
/// touched.
function ram_oc_clamp() {
	autom_init();
	var _a = g.autom;
	_a.tap.rate = min(_a.tap.rate, 10);
	_a.run.spd  = min(_a.run.spd, 100);
	_a.fab.spd  = min(_a.fab.spd, 100);
	_a.am_speed = min(_a.am_speed, 100);
	for (var _i = 0; _i < array_length(_a.dial); _i++)
		_a.dial[_i].t = max(_a.dial[_i].t, RAM_TIMER_MIN);
	_a.upg.t = max(_a.upg.t, RAM_TIMER_MIN);
	var _tn = variable_struct_get_names(_a.tiles);
	for (var _i = 0; _i < array_length(_tn); _i++)
		_a.tiles[$ _tn[_i]].t = max(_a.tiles[$ _tn[_i]].t, RAM_TIMER_MIN);
}
