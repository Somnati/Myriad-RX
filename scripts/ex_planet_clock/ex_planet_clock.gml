/// @description ex_planet_clock() -> true when the event is done (the old exit): THE ORBIT VIEW'S CLOCK - the world spins its own axis by the universal clock, the sky follows the world, the region's camera (syst_exped_panel's Step, q219; self = the panel)
function ex_planet_clock() {
	if (!(view == "planet" && is_struct(pl_dest))) return false;
	var _pn4 = planet_get(pl_dest.seed, exped_planet_hint(pl_dest));
	if (pv_spin_seed != pl_dest.seed) { pv_spin_seed = pl_dest.seed; pv_spin = planet_spin_now(_pn4); pv_sky = __sky_for(pl_dest); }   // (the world's own sky, 2026-09-16)
	// (the clock's spin, exactly: the agent's daylight reads the same clock)
	var _ns = planet_spin_now(_pn4);
	var _ds = angle_difference(_ns, pv_spin);
	pv_spin = _ns;
	// geosync: the camera rides the spin (pre-multiplied, world space)
	var _sax = mat3_apply(mat3_rot(0, 0, 1, _pn4.tilt), 0, 1, 0);
	if (pv_geo) pv_cam = mat3_mul(mat3_rot(_sax[0], _sax[1], _sax[2], _ds), pv_cam);
	// THE SNAP (2026-09-16): toward the turntable's north-up view of the region,
	// along the one rotation between here and there; the hand stays an arcball
	if (pv_face >= 0) {
		var _yp = __spot_yp(_pn4, pv_spin, region_get(pl_dest, pv_face));
		var _tgt = __cam_tt(_pn4, _yp.yaw, _yp.pitch);
		var _stp = __cam_toward(pv_cam, _tgt, 1 - power(.88, delta));
		if (is_undefined(_stp)) { pv_cam = _tgt; pv_face = -1; } else pv_cam = _stp;
	}
	pv_dwa = move_to(pv_dwa, pv_dw ? 1 : 0, 6);
	// region mode: the pull-in, the clouds thinning (both eased)
	var _zmode = (pv_mode == "region") ? PV_ZOOM_RG : 1;
	var _zt0 = __zoom_snap(pv_zuser * _zmode, _zmode);   // (the nearest rung of the ladder - q302: a drawn texel whole cells)
	pv_zt = _zt0;
	pv_zoom  = lerp(pv_zoom, _zt0, 1 - power(.88, delta));   // (the mode's pull-in x the wheel's - 2026-09-17)
	if (abs(pv_zoom - _zt0) < .002) pv_zoom = _zt0;        // (and lands, rather than creeping under a pixel for a second - the cells would flicker)
	pv_cfade = lerp(pv_cfade, 1 - .88 * clamp((pv_zoom - 1.2) / (PV_ZOOM_RG - 1.2), 0, 1), 1 - power(.88, delta));   // (by the ZOOM, his ask 2026-09-17: the wheel past 1.2 thins them, region mode's 1.55 is the same .12 as before)
	pv_pfade = 1 - .75 * clamp((pv_zoom - 3.5) / 2.5, 0, 1);
	// THE PHASE SNAP'S EASE (q305, his ask: "smooth as it pans"): in over a third of a second once the camera is still (no
	// hand, no glide, no face-turn, the zoom landed), out in a few frames at the first motion
	var _still = !pv_drag && abs(pv_vx) <= .02 && abs(pv_vy) <= .02 && pv_face < 0 && abs(pv_zoom - _zt0) < .002 && !rg_leave;
	pv_snap_a = _still ? min(1, pv_snap_a + delta / 20) : max(0, pv_snap_a - delta / 4);   // (the volcanoes' plumes hold until much closer: full to x3.5, a quarter by x6 - his ask 2026-09-17)
	return false;
}
