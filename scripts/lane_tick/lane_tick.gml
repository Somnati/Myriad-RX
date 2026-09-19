/// @description lane_tick(dt) - every disturbed region relaxes toward its average by dt seconds of the expedition clock; a quiet record is forgotten (q259)
/// Exponential relaxation: v x exp(-dt x weight / LANE_TAU) - at weight 1
/// the half-life is two world days, a city region's a few hours, the
/// wilderness's the best part of a week. THE ONE COUPLING: low order
/// drains trade (the roads unsafe, the carts stop) - one way, no loop.
/// When every lane sits within LANE_QUIET of rest the record goes: the
/// galaxy's regions cost nothing but the few a crew has lately disturbed.
/// Called by exped_tick after the memories (online, offline, x the speed)
function lane_tick(_dt) {
	var _ls = g.exped[$ "lanes"];
	if (!is_struct(_ls) || _dt <= 0) return;
	var _ks = variable_struct_get_names(_ls), _nm = lane_names();
	for (var _i = 0; _i < array_length(_ks); _i++) {
		var _r = _ls[$ _ks[_i]];
		var _f = exp(-_dt * (_r[$ "w"] ?? 1) / LANE_TAU), _quiet = true;
		if (_r.order < -.2) _r.trade = clamp(_r.trade - (-_r.order - .2) * _dt / LANE_TAU, -1, 1);
		for (var _j = 0; _j < array_length(_nm); _j++) {
			var _v = (_r[$ _nm[_j]] ?? 0) * _f;
			if (abs(_v) < LANE_QUIET) _v = 0; else _quiet = false;
			_r[$ _nm[_j]] = _v;
		}
		// THE SCARS' HOLD (q260): a lane past .7 (order, trade) or under -.7 (faith) runs a counter; at SCAR_HOLD the scar
		// lands (scar_land) and the lane drops to .3 - the push was spent on the world; off the extreme the counter drains
		var _kv = string_split(_ks[_i], ":"), _d = undefined;
		var _oh = (_r[$ "oh"] ?? 0), _th = (_r[$ "th"] ?? 0), _fl = (_r[$ "fl"] ?? 0);
		_oh = (_r.order >= .7) ? _oh + _dt : max(0, _oh - _dt);
		_th = (_r.trade >= .7) ? _th + _dt : max(0, _th - _dt);
		_fl = (_r.faith <= -.7) ? _fl + _dt : max(0, _fl - _dt);
		if ((_oh >= SCAR_HOLD || _th >= SCAR_HOLD || _fl >= SCAR_HOLD) && array_length(_kv) >= 2) _d = lane_dest(real(_kv[0]));
		if (is_struct(_d)) {
			var _ri = real(_kv[1]);
			if (_oh >= SCAR_HOLD) { if (scar_land(_d, _ri, "order")) _r.order = .3; _oh = 0; }
			if (_th >= SCAR_HOLD) { if (scar_land(_d, _ri, "trade")) _r.trade = .3; _th = 0; }
			if (_fl >= SCAR_HOLD) { if (scar_land(_d, _ri, "faith")) _r.faith = -.3; _fl = 0; }
		} else if (_oh >= SCAR_HOLD || _th >= SCAR_HOLD || _fl >= SCAR_HOLD) { _oh = 0; _th = 0; _fl = 0; }   // (a world nobody can reach: the hold is let go)
		_r.oh = _oh; _r.th = _th; _r.fl = _fl;
		if (_oh > 0 || _th > 0 || _fl > 0) _quiet = false;
		if (_quiet) variable_struct_remove(_ls, _ks[_i]);
	}
}
