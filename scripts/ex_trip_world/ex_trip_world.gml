/// @description ex_trip_world() - THE TRIP PAGE'S WORLD: the same render, its camera turned to the trip's region (syst_exped_panel's Step, q220; self = the panel)
function ex_trip_world() {
	var _ttr = __trip();
	if (!is_undefined(_ttr)) {
		var _tpn = planet_get(_ttr.dest.seed, exped_planet_hint(_ttr.dest));
		if (tp_id != _ttr.id) { tp_id = _ttr.id; tp_spin = planet_spin_now(_tpn); tp_cam = __cam_face(_tpn, tp_spin, exped_region(_ttr), mat3_rot(1, 0, 0, -32)); }
		var _tns = planet_spin_now(_tpn);
		var _tds = angle_difference(_tns, tp_spin);
		tp_spin = _tns;
		var _tax = mat3_apply(mat3_rot(0, 0, 1, _tpn.tilt), 0, 1, 0);
		tp_cam = mat3_mul(mat3_rot(_tax[0], _tax[1], _tax[2], _tds), tp_cam);
	}
}
