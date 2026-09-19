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
		if (_quiet) variable_struct_remove(_ls, _ks[_i]);
	}
}
