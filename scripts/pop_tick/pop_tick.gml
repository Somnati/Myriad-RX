/// @description pop_tick(dt) - every pushed place drifts back to its baseline (q284): exp(-dt / tau), tau by the place's size (region_pop: a city three days, a settlement ten); a quiet record is dropped. A world nobody can reach holds
function pop_tick(_dt) {
	var _ps = g.exped[$ "pop"];
	if (!is_struct(_ps) || _dt <= 0) return;
	var _ks = variable_struct_get_names(_ps);
	for (var _i = 0; _i < array_length(_ks); _i++) {
		var _kv = string_split(_ks[_i], ":");
		if (array_length(_kv) < 3) { variable_struct_remove(_ps, _ks[_i]); continue; }
		var _d = lane_dest(real(_kv[0]));
		if (!is_struct(_d)) continue;
		var _rg = region_get(_d, real(_kv[1])), _pp = region_pop(_d, _rg, real(_kv[2]));
		if (is_undefined(_pp)) { variable_struct_remove(_ps, _ks[_i]); continue; }
		var _r = _ps[$ _ks[_i]];
		_r.d *= exp(-_dt / (_pp.tau * 24 * EXPED_HOUR));
		if (abs(_r.d) < .01) variable_struct_remove(_ps, _ks[_i]);
	}
}
