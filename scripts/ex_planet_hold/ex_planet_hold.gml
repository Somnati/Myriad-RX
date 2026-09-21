/// @description ex_planet_hold() -> true when the event is done (the old exit): THE ORBIT VIEW under the hand - the drag, the glide, the wheel's zoom, the snap to a region (syst_exped_panel's Step, held input, q219; self = the panel)
function ex_planet_hold() {
	if (!(view == "planet" && is_struct(pl_dest))) return false;
	var _ocf = starmap_config();
	var _pvr = __pv_r();
	var _pin = point_in_rectangle(mouse_x, mouse_y, _pvr.x, _pvr.y, _pvr.x + _pvr.w, _pvr.y + _pvr.h);
	// THE WHEEL (his ask, 2026-09-17): closer or further, in either mode - on top of region mode's pull-in.
	// The drag turns fewer degrees a pixel the closer you are, so the ground under the hand keeps pace with it
	if (rg_infl && pv_mode == "region") {   // (the ledger up: the wheel scrolls it, not the world - q286; in region mode alone - q300)
		if (mouse_wheel_up())   rg_infl_scroll = max(0, rg_infl_scroll - 22);
		if (mouse_wheel_down()) rg_infl_scroll = min(rg_infl_hmax, rg_infl_scroll + 22);
	}
	else if (pv_dwa > .5 && pv_dtab == 0 && mouse_x >= __pv_dw_x() && mouse_y < room_height - 30) {   // (the drawer's rows: the wheel scrolls them - q295)
		if (mouse_wheel_up())   pv_rsc = max(0, pv_rsc - 1);
		if (mouse_wheel_down()) pv_rsc = pv_rsc + 1;   // (the draw clamps it to the list)
	}
	else if (_pin && !__pv_ui_hit()) {
		// THE LADDER (q302, his "position snap"): the wheel steps between the zooms where a drawn texel is whole cells
		// (__zoom_ladder - the mode's range: region mode out to the whole planet, in to the same ceiling - q269)
		var _zmode = (pv_mode == "region") ? PV_ZOOM_RG : 1, _zt = pv_zuser * _zmode, _lad = __zoom_ladder(_zmode);
		if (array_length(_lad) == 0) {   // (a world with no rungs in range - a stamp: the old continuous wheel; bug pass q313)
			var _zlo = (pv_mode == "region") ? (1.3 / PV_ZOOM_RG) : PV_ZOOM_MIN, _zhi = (pv_mode == "region") ? max(1, PV_ZOOM_MAX * 1.85 / PV_ZOOM_RG) : PV_ZOOM_MAX;
			if (mouse_wheel_up())   pv_zuser = min(pv_zuser * 1.18, _zhi);
			if (mouse_wheel_down()) pv_zuser = max(pv_zuser / 1.18, _zlo);
		} else {
			if (mouse_wheel_up())   { for (var _li = 0; _li < array_length(_lad); _li++) if (_lad[_li] > _zt * 1.01) { pv_zuser = _lad[_li] / _zmode; break; } }
			if (mouse_wheel_down()) { for (var _li = array_length(_lad) - 1; _li >= 0; _li--) if (_lad[_li] < _zt * .99) { pv_zuser = _lad[_li] / _zmode; break; } }
		}
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
				if (_best >= 0) { __pv_pick(_best); __rg_enter(); }   // (straight into region mode - q309, his ask)
				else play_sound_ext(snd_matclick2, .7, .8, .3, 0);
			}
		}
		// A PLACE ON THE WORLD (q303): in region mode a still tap on a place opens its card (the map's); the same place
		// again, or a tap elsewhere, folds it
		if (pv_px <= 4 && pv_mode == "region") {
			var _pvr2 = __pv_r(), _hit2 = undefined, _hd2 = 9;
			for (var _wi = 0; _wi < array_length(wn_pts); _wi++) {
				var _wp = wn_pts[_wi];
				if (_wp.a < .2) continue;
				var _dd2 = point_distance(mouse_x - _pvr2.x, mouse_y - _pvr2.y, _wp.x, _wp.y);
				if (_dd2 < _hd2) { _hd2 = _dd2; _hit2 = _wp; }
			}
			if (is_struct(_hit2)) { pv_pop = (is_struct(pv_pop) && pv_pop.ri == _hit2.ri && pv_pop.ni == _hit2.ni) ? undefined : { ri : _hit2.ri, ni : _hit2.ni }; play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1); }
			else {
				var _hadpop = is_struct(pv_pop);
				pv_pop = undefined;
				// THE TAP OFF THE REGION (q309, his ask): on another region's ground - view that one; on the sea or off the world -
				// back to the world view; on this region's own ground - the card folds, nothing more
				var _pc3 = __pv_c(), _ppn3 = planet_get(pl_dest.seed, exped_planet_hint(pl_dest));
				var _pk3 = planet_pick(_ppn3, mouse_x, mouse_y, _pc3.x, _pc3.y, _ocf.pr * pv_zoom, pv_mat_m);
				var _tid3 = 0;
				if (_pk3.hit && is_struct(_ppn3[$ "terr"]) && _ppn3.terr.n > 0) {
					var _tu3 = frac(arctan2(_pk3.tz, _pk3.tx) / (2 * pi) + .5 + 1), _tv3 = clamp(arccos(clamp(_pk3.ty, -1, 1)) / pi, 0, .9999);
					_tid3 = _ppn3.terr.ids[clamp(floor(_tu3 * _ppn3.tw), 0, _ppn3.tw - 1) + clamp(floor(_tv3 * _ppn3.th), 0, _ppn3.th - 1) * _ppn3.tw];
				}
				if (_tid3 > 0 && _tid3 <= region_count(pl_dest) && _tid3 - 1 != rg_sel) { if (hand != "") __hand_fold(); rg_infl = false; __pv_pick(_tid3 - 1); }
				else if (_tid3 == 0 && !_hadpop) __rg_leave();
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
