/// @description ex_planet_hold() -> true when the event is done (the old exit): THE ORBIT VIEW under the hand - the drag, the glide, the wheel's zoom, the snap to a region (syst_exped_panel's Step, held input, q219; self = the panel)
function ex_planet_hold() {
	if (!(view == "planet" && is_struct(pl_dest))) return false;
	var _ocf = starmap_config();
	var _pvr = __pv_r();
	var _pin = point_in_rectangle(mouse_x, mouse_y, _pvr.x, _pvr.y, _pvr.x + _pvr.w, _pvr.y + _pvr.h);
	// THE WHEEL (his ask, 2026-09-17): closer or further, in either mode - on top of region mode's pull-in.
	// The drag turns fewer degrees a pixel the closer you are, so the ground under the hand keeps pace with it
	if (rg_infl) {   // (the ledger up: the wheel scrolls it, not the world - q286)
		if (mouse_wheel_up())   rg_infl_scroll = max(0, rg_infl_scroll - 22);
		if (mouse_wheel_down()) rg_infl_scroll = min(rg_infl_hmax, rg_infl_scroll + 22);
	}
	else if (_pin && !__pv_ui_hit()) {
		// (the wheel's reach is the TOTAL zoom's: in region mode - x PV_ZOOM_RG, five now - it may come out to the whole planet
		// (x1.3 total) and in to the same ceiling as the planet view's - q269)
		var _zlo = (pv_mode == "region") ? (1.3 / PV_ZOOM_RG) : PV_ZOOM_MIN, _zhi = (pv_mode == "region") ? max(1, PV_ZOOM_MAX * 1.85 / PV_ZOOM_RG) : PV_ZOOM_MAX;
		if (mouse_wheel_up())   pv_zuser = min(pv_zuser * 1.18, _zhi);
		if (mouse_wheel_down()) pv_zuser = max(pv_zuser / 1.18, _zlo);
	}
	var _osens = _ocf.orbit_sens / max(.5, pv_zoom);
	if (!pv_drag && mouse_check_button_pressed(mb_left) && _pin && !__pv_ui_hit()) { pv_drag = true; pv_px = 0; pv_dx = mouse_x; pv_dy = mouse_y; pv_vx = 0; pv_vy = 0; }
	if (pv_drag && mouse_check_button(mb_left)) {
		var _mx = mouse_x - pv_dx, _my = mouse_y - pv_dy;
		pv_px += abs(_mx) + abs(_my);
		if (pv_px > 4) pv_face = -1;   // a real drag lets go of the turn
		// swipe = grab the world and pull it with you (the demo's sign - the arcball, his call 2026-09-16)
		if (_mx != 0) pv_cam = mat3_mul(pv_cam, mat3_rot(0, 1, 0,  _mx * _osens));
		if (_my != 0) pv_cam = mat3_mul(pv_cam, mat3_rot(1, 0, 0, -_my * _osens));
		pv_vx = lerp(pv_vx, _mx, .5); pv_vy = lerp(pv_vy, _my, .5);
		pv_dx = mouse_x; pv_dy = mouse_y;
	} else if (pv_drag) {
		pv_drag = false;
		if (pv_px <= 4 && pv_mode == "planet") {
			// a still tap: the region under it - planet_pick (the render run
			// backwards, at the drawn radius) then the nearest spot within twelve degrees
			var _pc = __pv_c();
			var _ppn = planet_get(pl_dest.seed, exped_planet_hint(pl_dest));
			var _pk = planet_pick(_ppn, mouse_x, mouse_y, _pc.x, _pc.y, _ocf.pr * pv_zoom, pv_mat_m);
			if (_pk.hit) {
				// THE TERRITORY UNDER THE TAP (q287): the picked texel's id from the sheet; off every territory (the deep sea, an
				// unowned strand) the nearest seed within twelve degrees as before
				var _best = -1, _bd = dcos(12), _nrg = region_count(pl_dest);
				if (is_struct(_ppn[$ "terr"]) && _ppn.terr.n > 0) {
					var _tu = frac(arctan2(_pk.tz, _pk.tx) / (2 * pi) + .5 + 1), _tv = clamp(arccos(clamp(_pk.ty, -1, 1)) / pi, 0, .9999);
					var _tix = clamp(floor(_tu * _ppn.tw), 0, _ppn.tw - 1), _tiy = clamp(floor(_tv * _ppn.th), 0, _ppn.th - 1);
					var _tid = _ppn.terr.ids[_tix + _tiy * _ppn.tw];
					if (_tid > 0 && _tid <= _nrg) _best = _tid - 1;
				}
				if (_best < 0) for (var _i = 0; _i < _nrg; _i++) {
					var _rgp = region_get(pl_dest, _i);
					var _tp = __spot_dir(_rgp.spot.lon, _rgp.spot.lat);
					var _dot = _tp[0] * _pk.tx + _tp[1] * _pk.ty + _tp[2] * _pk.tz;
					if (_dot > _bd) { _bd = _dot; _best = _i; }
				}
				if (_best >= 0) __pv_pick(_best);
				else play_sound_ext(snd_matclick2, .7, .8, .3, 0);
			}
		}
	}
	if (!pv_drag) {
		if (abs(pv_vx) > .02 || abs(pv_vy) > .02) {
			pv_cam = mat3_mul(pv_cam, mat3_rot(0, 1, 0,  pv_vx * _osens * delta));
			pv_cam = mat3_mul(pv_cam, mat3_rot(1, 0, 0, -pv_vy * _osens * delta));
			var _dk = power(_ocf.orbit_glide, delta);
			pv_vx *= _dk; pv_vy *= _dk;
		} else { pv_vx = 0; pv_vy = 0; }
	}
	return false;
}
