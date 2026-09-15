// ---- THE OPEN/CLOSE EASE (the overlay contract) ----
oa = move_to(oa, closing ? 0 : 1, closing ? UI_OUT_SPD : UI_IN_SPD);
if (abs(oa - (closing ? 0 : 1)) < .004) oa = closing ? 0 : 1;
if (closing && oa <= 0) { instance_destroy(); exit; }

var _e = g.exped;
// UNDER THE SETTINGS (2026-09-15): the panel stays up but deeper (the
// settings draws over it), its hand folded, its input off (below)
var _under = instance_exists(syst_settings);
depth = _under ? -500 : -510;
if (_under && hand != "") __hand_close();
// THE PAGE TURN: to black, the view turns, back to light (__page_go)
if (pg_dir < 0) { pg_a = move_to(pg_a, 0, 3); if (pg_a <= .04) { pg_a = 0; view = pg_next; pg_dir = 1; } }
else if (pg_dir > 0) { pg_a = move_to(pg_a, 1, 4); if (pg_a >= .97) { pg_a = 1; pg_dir = 0; } }
// the worlds are built a few rows a frame (planet_gen_step, __worlds_step:
// the board's, the trips', the planet window's), so every portrait is the
// full world within a second or two, without a hitch
__worlds_step();
// THE REPLAY: a trip page with an unseen film (and no live fight)
// plays it in the combat window, a swing every half second; the last
// frame holds a moment, then it is seen. A tap on the window skips it
if (view == "trip") {
	var _tvr = __trip();
	if (!is_undefined(_tvr)) {
		var _rr = _tvr[$ "replay"];
		// a fight watched LIVE on this page is not replayed after
		if (!is_undefined(_tvr.fight)) seen_live = string(_tvr.id) + ":" + string(_tvr[$ "fights"] ?? 0);
		if (!is_undefined(_rr) && !_rr.seen && seen_live == string(_tvr.id) + ":" + string(_rr.room)) _rr.seen = true;
		if (is_undefined(rp) && !is_undefined(_rr) && !_rr.seen && is_undefined(_tvr.fight) && array_length(_rr.ev) > 0)
			rp = { i : 0, t : 0, r : _rr, id : _tvr.id };
		if (!is_undefined(rp)) {
			if (rp.id != _tvr.id || !is_undefined(_tvr.fight)) rp = undefined;
			else {
				rp.t += delta / 60;
				var _step = (rp.i < array_length(rp.r.ev) - 1) ? .5 : 1.6;
				if (rp.t >= _step) {
					rp.t = 0;
					if (rp.i < array_length(rp.r.ev) - 1) rp.i += 1;
					else { rp.r.seen = true; rp = undefined; }
				}
			}
		}
	} else rp = undefined;
} else rp = undefined;
// a trip that got home while its page was open: the page turns to the haul
if (view == "trip" && is_undefined(__trip())) { view = (__haul_i() >= 0) ? "haul" : "hub"; if (view == "haul") { pg_a = 0; pg_dir = 1; } }   // (the haul fades in - his ask, 2026-09-15)
if (view == "haul" && __haul_i() < 0) { view = "hub"; swap_pick = false; }
if (view == "sheet") view = "crew";
if (view == "crew" && is_undefined(__sp_by_id(sheet_id)) && array_length(g.sprites) > 0) sheet_id = g.sprites[0].id;
if (view == "map" && !is_struct(map_dest)) view = "hub";
if ((view == "planet" || view == "region" || view == "depart") && !is_struct(pl_dest)) view = "hub";

// THE SUN IS LIVE (his report, 2026-09-15: "mid-morning but clearly night" -
// the render's sun was the one at open, the words read the clock's; the
// orbits ran a year in minutes, so they parted within it)
if (is_struct(pv_sky) && (view == "planet" || view == "trip")) pv_sky.light_w = galaxy_sun_dir();
// THE ORBIT VIEW'S CLOCK: the world spins its own axis (the universal
// clock sets it the first time), the camera rides the spin (geosync), and
// turns to face a picked region (pv_face) - a rotation about the view axis
// that lifts the spot's view z toward one; the sign is tried both ways
if (view == "planet" && is_struct(pl_dest)) {
	var _pn4 = planet_get(pl_dest.seed, exped_planet_hint(pl_dest));
	if (pv_spin_seed != pl_dest.seed) { pv_spin_seed = pl_dest.seed; pv_spin = planet_spin_now(_pn4); pv_sky = galaxy_sky_build(); }
	// (the clock's spin, exactly: the agent's daylight reads the same clock)
	var _ns = planet_spin_now(_pn4);
	var _ds = angle_difference(_ns, pv_spin);
	pv_spin = _ns;
	var _sax = mat3_apply(mat3_rot(0, 0, 1, _pn4.tilt), 0, 1, 0);
	if (pv_geo) pv_cam = mat3_mul(mat3_rot(_sax[0], _sax[1], _sax[2], _ds), pv_cam);
	if (pv_face >= 0) {
		var _rgf = region_get(pl_dest, pv_face);
		var _wm4 = mat3_mul(mat3_rot(0, 0, 1, _pn4.tilt), mat3_rot(0, 1, 0, pv_spin));
		var _tf = __spot_dir(_rgf.spot.lon, _rgf.spot.lat);
		var _nw = mat3_apply(_wm4, _tf[0], _tf[1], _tf[2]);
		var _vf = mat3_apply(mat3_transpose(pv_cam), _nw[0], _nw[1], _nw[2]);
		if (_vf[2] > .9995) pv_face = -1;
		else {
			var _ang = darccos(clamp(_vf[2], -1, 1)) * (1 - power(.88, delta));
			var _axl = sqrt(_vf[0] * _vf[0] + _vf[1] * _vf[1]);
			var _ax0 = (_axl < .0001) ? 0 : (_vf[1] / _axl);
			var _ax1 = (_axl < .0001) ? 1 : (-_vf[0] / _axl);
			var _c1 = mat3_mul(pv_cam, mat3_rot(_ax0, _ax1, 0, _ang));
			var _c2 = mat3_mul(pv_cam, mat3_rot(_ax0, _ax1, 0, -_ang));
			var _v1 = mat3_apply(mat3_transpose(_c1), _nw[0], _nw[1], _nw[2]);
			var _v2 = mat3_apply(mat3_transpose(_c2), _nw[0], _nw[1], _nw[2]);
			pv_cam = (_v1[2] >= _v2[2]) ? _c1 : _c2;
		}
	}
	pv_dwa = move_to(pv_dwa, pv_dw ? 1 : 0, 6);
	// region mode: the pull-in, the clouds thinning (both eased)
	pv_zoom  = lerp(pv_zoom,  (pv_mode == "region") ? PV_ZOOM_RG : 1, 1 - power(.88, delta));
	pv_cfade = lerp(pv_cfade, (pv_mode == "region") ? .12 : 1, 1 - power(.88, delta));
}
// THE TRIP PAGE'S WORLD: the same render, its camera turned to the trip's
// region once (a new trip on the page), riding the spin after (geosync)
if (view == "trip") {
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
if (view != "planet") { pv_drag = false; pv_vx = 0; pv_vy = 0; }
// THE DIARY'S BAR: seated on the log's column while a diary shows, hidden
// otherwise; it follows the newest line unless you scrolled up
if (view == "trip" || view == "haul") {
	var _lr = __log_r();
	var _ll = __log_lines();
	// A RE-WRAP KEEPS YOUR PLACE (his ask, 2026-09-15): the band's width
	// changed (the trip page turned into the haul) - the line at the top of
	// the band before is the line at the top after
	if (is_array(_ll) && log_lay.w != _lr.w - 8 && log_lay.n == array_length(_ll) && array_length(log_lay.hs) > 0) {
		var _acc = 0, _top = array_length(log_lay.hs), _off = 0;
		for (var _li = 0; _li < array_length(log_lay.hs); _li++) { if (_acc + log_lay.hs[_li] > log_scroll) { _top = _li; _off = log_scroll - _acc; break; } _acc += log_lay.hs[_li]; }
		var _lay2 = __log_layout(_ll, _lr.w - 8);
		var _acc2 = 0;
		for (var _li = 0; _li < min(_top, array_length(_lay2.hs)); _li++) _acc2 += _lay2.hs[_li];
		log_scroll = _acc2 + ((_top < array_length(_lay2.hs)) ? min(_off, _lay2.hs[_top] - 1) : 0);
		if (instance_exists(sb)) { sb.ty = log_scroll; sb.input = log_scroll; sb.ty_speed_actual = 0; }
	}
	var _lmax = max(0, __log_content_h() - _lr.h);
	if (is_array(_ll)) {
		// THE FOLLOW: at the bottom, a new line pulls the band down with it;
		// scrolled up at all, the band holds still (the bar's own ty is the
		// scroll's truth every step, so the bar is told too - his report:
		// it never followed)
		if (log_n != array_length(_ll)) {
			if (log_follow) { log_scroll = _lmax; if (instance_exists(sb)) { sb.ty = _lmax; sb.input = _lmax; sb.ty_speed_actual = 0; } }
			log_n = array_length(_ll);
		}
		log_follow = (log_scroll >= _lmax - 2);
	}
	log_scroll = clamp(log_scroll, 0, _lmax);
	if (instance_exists(sb)) {
		sb.x = _lr.x + _lr.w - sprite_get_width(spr_scrollbar);
		sb.y = _lr.y;
		sb.image_yscale = _lr.h / max(1, sprite_get_height(spr_scrollbar));
		sb.wheel_x1 = _lr.x; sb.wheel_x2 = _lr.x + _lr.w;
		sb.visible = (oa >= .999 && !closing && _lmax > 0);
		sb.enabled = (oa >= .999 && !closing && !_under);
	}
} else {
	log_n = -1; log_follow = true; log_scroll = 0;
	if (instance_exists(sb)) { sb.visible = false; sb.enabled = false; }
}
if (view != "galaxy") gx_press = false;

if (oa < .999 || closing) exit;
if (_under) exit;   // (the settings own the input; the pages keep drawing under them)
if (!input_free(ui_layer_overlay)) exit;
// ---- THE CONFIRM POPUP owns the panel while it is up (abort) ----
if (view != "trip") confirm = "";   // (the page turned under it - a trip got home)
conf_a = move_to(conf_a, (confirm != "") ? 1 : 0, 5);
if (confirm != "") {
	var _cb = __conf_btns();
	conf_hot = 0;
	for (var _ci = 0; _ci < 2; _ci++) {
		var _cbb = _cb[_ci];
		if (point_in_rectangle(mouse_x, mouse_y, _cbb.x, _cbb.y, _cbb.x + _cbb.w, _cbb.y + _cbb.h)) conf_hot = _ci + 1;
	}
	if (keyboard_check_pressed(vk_escape)) { confirm = ""; play_sound_ext(snd_matclick2, .8, .9, .5, 1); exit; }
	if (conf_a > .9 && mouse_check_button_pressed(mb_left)) {
		if (conf_hot == 1) {
			if (confirm == "abort") { var _atr = __trip(); if (!is_undefined(_atr)) exped_abort(_atr); }
			confirm = "";
			play_sound_ext(snd_apply, 1, 1.2, .5, 1);
		} else if (conf_hot == 2) { confirm = ""; play_sound_ext(snd_matclick2, .8, .9, .5, 1); }
	}
	exit;
}
if (conf_a > .01) exit;   // (fading out: nothing under it acts yet)
if (pg_dir != 0) exit;    // (the page is turning)
// ---- THE HAND (the quest / explore cards) owns the page while it is up ----
if (hand != "") {
	if (view != "planet" || pv_mode != "region") __hand_close();
	else if (hand_out) {
		// THE FOLD: each card flies down to the deck in its turn and goes as
		// it leaves the screen; the veil lifts; nothing takes a press
		hand_a = move_to(hand_a, 0, 4);
		var _left = 0;
		for (var _d = 0; _d < array_length(hand_ids); _d++) {
			var _c = hand_ids[_d];
			if (!instance_exists(_c)) continue;
			_left += 1;
			if (_c.throw_delay > 0) { _c.throw_delay -= delta; continue; }
			var _k = 1 - power(.7, delta);
			_c.x = lerp(_c.x, _c.seat.x, _k); _c.y = lerp(_c.y, _c.seat.y, _k);
			_c.rot_z = lerp(_c.rot_z, -(_c.x - room_width * .5) * .12, _k);
			_c.rot_x = lerp(_c.rot_x, 40, _k); _c.rot_y = lerp(_c.rot_y, 0, _k);
			if (_c.y > room_height + _c.card_h * .5 + 2) { instance_destroy(_c); _left -= 1; }
		}
		if (_left == 0) __hand_close();
		exit;
	} else {
		if (keyboard_check_pressed(vk_escape)) { __hand_fold(); exit; }
		hand_a = move_to(hand_a, 1, 5);
		var _sec = floor(current_time / 1000);
		for (var _d = 0; _d < array_length(hand_ids); _d++) {
			var _c = hand_ids[_d];
			if (!instance_exists(_c)) continue;
			if (hand_sec != _sec) _c.invalidate_front();   // (who is on it, live)
			// THE THROW: unseen until its turn, then snapped to its seat from the
			// bottom middle (a quarter of the gap a frame), the lean and the
			// twist settling with it
			if (_c.throw_delay > 0) { _c.throw_delay -= delta; _c.visible = false; continue; }
			_c.visible = true;
			if (!_c.settled) {
				var _k = 1 - power(.7, delta);
				_c.x = lerp(_c.x, _c.seat.x, _k); _c.y = lerp(_c.y, _c.seat.y, _k);
				_c.rot_x = lerp(_c.rot_x, 0, _k); _c.rot_z = lerp(_c.rot_z, 0, _k);
				if (point_distance(_c.x, _c.y, _c.seat.x, _c.seat.y) < 1) { _c.x = _c.seat.x; _c.y = _c.seat.y; _c.rot_z = 0; _c.settled = true; }
				continue;
			}
			var _hov = point_in_rectangle(mouse_x, mouse_y, _c.x - _c.card_w * .5, _c.y - _c.card_h * .5, _c.x + _c.card_w * .5, _c.y + _c.card_h * .5);
			// hover leans the card toward the pointer; idle keeps it held (the deck's)
			var _ty2 = _hov ? clamp((mouse_x - _c.x) * .35, -14, 14) : 4 * dsin(current_time / 900 + _d * 2);
			var _tx2 = _hov ? clamp(-(mouse_y - _c.y) * .35, -14, 14) : 3 * dsin(current_time / 1300 + _d);
			_c.rot_y = trickle(_c.rot_y, _ty2, 6);
			_c.rot_x = trickle(_c.rot_x, _tx2, 6);
		}
		hand_sec = _sec;
		if (mouse_check_button_pressed(mb_left)) {
			var _onany = false;
			for (var _d = 0; _d < array_length(hand_ids); _d++) {
				var _c2 = hand_ids[_d];
				if (!instance_exists(_c2)) continue;
				if (!point_in_rectangle(mouse_x, mouse_y, _c2.x - _c2.card_w * .5, _c2.y - _c2.card_h * .5, _c2.x + _c2.card_w * .5, _c2.y + _c2.card_h * .5)) continue;
				_onany = true;
				if (!_c2.settled) break;   // still flying in: not a pick
				__hand_pick(_d);
				break;
			}
			if (!_onany) __hand_fold();
		}
		exit;
	}
}
// ---- [back], and escape: one step up the chain (__back, the Create) ----
if (keyboard_check_pressed(vk_escape)) {
	if (view != "hub") __back(); else exped_close();
	exit;
}
if (variable_global_exists("click_owner") && g.click_owner != noone) exit;

// ======================= THE ORBIT VIEW: the grab, the drag, the glide, the tap =======================
// (held and released input - above the press gate)
if (view == "planet" && is_struct(pl_dest)) {
	var _ocf = starmap_config();
	var _pvr = __pv_r();
	var _pin = point_in_rectangle(mouse_x, mouse_y, _pvr.x, _pvr.y, _pvr.x + _pvr.w, _pvr.y + _pvr.h);
	if (!pv_drag && mouse_check_button_pressed(mb_left) && _pin && !__pv_ui_hit()) { pv_drag = true; pv_px = 0; pv_dx = mouse_x; pv_dy = mouse_y; pv_vx = 0; pv_vy = 0; }
	if (pv_drag && mouse_check_button(mb_left)) {
		var _mx = mouse_x - pv_dx, _my = mouse_y - pv_dy;
		pv_px += abs(_mx) + abs(_my);
		if (pv_px > 4) pv_face = -1;   // a real drag lets go of the turn
		// swipe = grab the world and pull it with you (the demo's sign)
		if (_mx != 0) pv_cam = mat3_mul(pv_cam, mat3_rot(0, 1, 0,  _mx * _ocf.orbit_sens));
		if (_my != 0) pv_cam = mat3_mul(pv_cam, mat3_rot(1, 0, 0, -_my * _ocf.orbit_sens));
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
				var _best = -1, _bd = dcos(12);
				for (var _i = 0; _i < EXPED_REGIONS; _i++) {
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
			pv_cam = mat3_mul(pv_cam, mat3_rot(0, 1, 0,  pv_vx * _ocf.orbit_sens * delta));
			pv_cam = mat3_mul(pv_cam, mat3_rot(1, 0, 0, -pv_vy * _ocf.orbit_sens * delta));
			var _dk = power(_ocf.orbit_glide, delta);
			pv_vx *= _dk; pv_vy *= _dk;
		} else { pv_vx = 0; pv_vy = 0; }
	}
}
// ======================= THE GALAXY VIEW: pan, zoom, tap a star =======================
if (view == "galaxy") {
	var _gcf = starmap_config();
	var _gr = __gx_r();
	var _gin = point_in_rectangle(mouse_x, mouse_y, _gr.x, _gr.y, _gr.x + _gr.w, _gr.y + _gr.h);
	if (_gin) {
		var _z0 = gx_zoom;
		if (mouse_wheel_up())   gx_zoom = min(gx_zoom * _gcf.zoom_step, _gcf.zoom_max);
		if (mouse_wheel_down()) gx_zoom = max(gx_zoom / _gcf.zoom_step, _gcf.zoom_min);
		if (gx_zoom != _z0) { var _vcx = gx_x + _gr.w * .5 / _z0, _vcy = gx_y + _gr.h * .5 / _z0; gx_x = _vcx - _gr.w * .5 / gx_zoom; gx_y = _vcy - _gr.h * .5 / gx_zoom; }
	}
	var _gbk = __back_r();
	var _onbk = point_in_rectangle(mouse_x, mouse_y, _gbk.x, _gbk.y, _gbk.x + _gbk.w, _gbk.y + _gbk.h);
	var _mmr = __gx_mm_r();
	var _onmm = point_in_rectangle(mouse_x, mouse_y, _mmr.x, _mmr.y, _mmr.x + _mmr.w, _mmr.y + _mmr.h);
	if (_onmm && mouse_check_button_pressed(mb_left)) {
		// the minimap: a tap jumps the camera there
		var _smm = starmap_get();
		var _jx = (mouse_x - _mmr.x) / _mmr.w * _smm.width, _jy = (mouse_y - _mmr.y) / _mmr.h * _smm.height;
		gx_x = _jx - _gr.w * .5 / gx_zoom; gx_y = _jy - _gr.h * .5 / gx_zoom;
		play_sound_ext(snd_softclick, .95, 1.05, .3, 1);
	}
	if (!gx_press && mouse_check_button_pressed(mb_left) && _gin && !_onbk && !_onmm) { gx_press = true; gx_px = mouse_x; gx_py = mouse_y; gx_cx0 = gx_x; gx_cy0 = gx_y; gx_travel = 0; }
	if (gx_press && mouse_check_button(mb_left)) {
		gx_travel = max(gx_travel, point_distance(gx_px, gx_py, mouse_x, mouse_y));
		gx_x = gx_cx0 - (mouse_x - gx_px) / gx_zoom;
		gx_y = gx_cy0 - (mouse_y - gx_py) / gx_zoom;
	} else if (gx_press) {
		gx_press = false;
		if (gx_travel <= _gcf.tap_max_dist) {
			// the nearest star to the tap, on its parallax-shifted draw position
			var _sm = starmap_get();
			var _vis = star_visible(gx_x, gx_y, gx_zoom, _gr.w, _gr.h);
			var _vcx2 = gx_x + _gr.w * .5 / gx_zoom, _vcy2 = gx_y + _gr.h * .5 / gx_zoom;
			var _bi = -1, _bd = _gcf.tap_radius;
			for (var _i = 0; _i < array_length(_vis); _i++) {
				var _st = _sm.stars[_vis[_i]];
				var _sx = _gr.x + ((_vcx2 + (_st.x - _vcx2) * _st.d) - gx_x) * gx_zoom;
				var _sy = _gr.y + ((_vcy2 + (_st.y - _vcy2) * _st.d) - gx_y) * gx_zoom;
				var _dd = point_distance(_sx, _sy, mouse_x, mouse_y);
				if (_dd < _bd) { _bd = _dd; _bi = _vis[_i]; }
			}
			if (_bi >= 0 && _bi != gx_sel) { gx_sel = _bi; gx_sys = starsystem_generate(_sm.stars[_bi].seed, _sm.stars[_bi].props); play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1); }
			else if (_bi < 0) gx_sel = -1;
		}
	}
	var _gcfg = starmap_config();
	gx_x = clamp(gx_x, -_gr.w * .5 / gx_zoom, _gcfg.plane_w - _gr.w * .5 / gx_zoom);
	gx_y = clamp(gx_y, -_gr.h * .5 / gx_zoom, _gcfg.plane_h - _gr.h * .5 / gx_zoom);
}

if (!mouse_check_button_pressed(mb_left)) exit;   // EVERYTHING BELOW IS A PRESS

// the debug clock: x1 / x10 / x100
for (var _k = 0; _k < 3; _k++) {
	var _r = __spd_r(_k);
	if (point_in_rectangle(mouse_x, mouse_y, _r.x, _r.y, _r.x + _r.w, _r.y + _r.h)) {
		_e.spd = [1, 10, 100][_k];
		play_sound_ext(snd_softclick, 1, 1.1, .4, 1);
		exit;
	}
}
// [back] from any page (drawn on the right, syst_exped_panel's Draw); [crew] beside it (his ask, 2026-09-15)
if (view != "hub") {
	var _bk = __back_r();
	if (point_in_rectangle(mouse_x, mouse_y, _bk.x, _bk.y, _bk.x + _bk.w, _bk.y + _bk.h)) { __back(); exit; }
	if (view != "crew" && array_length(g.sprites) > 0) {
		var _cs = __crewstrip_r();
		if (point_in_rectangle(mouse_x, mouse_y, _cs.x, _cs.y, _cs.x + _cs.w, _cs.y + _cs.h)) {
			crew_from = view; view = "crew"; crew_trip = -1; it_pop = undefined;
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			exit;
		}
	}
}

// ======================= THE CREW MENU: tabs on the left =======================
if (view == "crew") {
	// a popup up: any press closes it
	if (is_struct(it_pop)) { it_pop = undefined; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); exit; }
	var _cl = __crew_list();
	for (var _k = 0; _k < array_length(_cl); _k++) {
		var _tb = __tab_r(_k);
		if (point_in_rectangle(mouse_x, mouse_y, _tb.x, _tb.y, _tb.x + _tb.w, _tb.y + _tb.h)) {
			sheet_id = _cl[_k].id;
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			exit;
		}
	}
	// an item row: its popup (the rects the Draw laid down)
	for (var _k = 0; _k < array_length(it_rects); _k++) {
		var _ir = it_rects[_k];
		if (point_in_rectangle(mouse_x, mouse_y, _ir.x, _ir.y, _ir.x + _ir.w, _ir.y + _ir.h)) {
			it_pop = { it : _ir[$ "it"], sk : _ir[$ "sk"], nt : _ir[$ "nt"], st : _ir[$ "st"], lvup : _ir[$ "lvup"] ?? false, sp : __sp_by_id(sheet_id), worn : _ir[$ "worn"] ?? false, x : _ir.x, y : _ir.y + _ir.h + 2 };
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			exit;
		}
	}
	exit;
}

// ======================= THE MAP: [legend] =======================
if (view == "map") {
	var _lgr = __legend_r();
	if (point_in_rectangle(mouse_x, mouse_y, _lgr.x, _lgr.y, _lgr.x + _lgr.w, _lgr.y + _lgr.h)) { map_legend = !map_legend; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); exit; }
	if (map_legend) { map_legend = false; exit; }   // (any other press folds it)
	exit;
}

// ======================= THE PLANET PAGE: its buttons, the drawer =======================
// (the grab / drag / tap are above the press gate)
if (view == "planet") {
	// [galaxy]: the star map
	var _gl = __galaxy_r();
	if (point_in_rectangle(mouse_x, mouse_y, _gl.x, _gl.y, _gl.x + _gl.w, _gl.y + _gl.h)) {
		gx_from = "planet"; view = "galaxy";
		play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
		exit;
	}
	// the geosync toggle (the demo's): the camera rides the spin, or not
	var _ge = __geo_r();
	if (point_in_rectangle(mouse_x, mouse_y, _ge.x, _ge.y, _ge.x + _ge.w, _ge.y + _ge.h)) {
		pv_geo = !pv_geo;
		play_sound_ext(snd_softclick, .95, 1.05, .4, 1);
		exit;
	}
	// REGION MODE (his ask: no separate window - the camera pulls in, the
	// info box left): [region map] in the left column, [quests] / [explore]
	// bottom right deal THE HAND (the cards pick the departure)
	if (pv_mode == "region") {
		var _mr0 = __rgmap_r();
		if (point_in_rectangle(mouse_x, mouse_y, _mr0.x, _mr0.y, _mr0.x + _mr0.w, _mr0.y + _mr0.h)) {
			map_dest = pl_dest; map_rgi = rg_sel; map_from = "planet"; view = "map";
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			exit;
		}
		var _qb = __quests_r();
		if (point_in_rectangle(mouse_x, mouse_y, _qb.x, _qb.y, _qb.x + _qb.w, _qb.y + _qb.h)) { __hand_open("quests"); exit; }
		var _xb = __explore_r();
		if (point_in_rectangle(mouse_x, mouse_y, _xb.x, _xb.y, _xb.x + _xb.w, _xb.y + _xb.h)) { __hand_open("explore"); exit; }
		exit;
	}
	// [view region]: the pull-in (region mode) on the picked one
	if (pl_focus >= 0) {
		var _vr = __view_rg_r();
		if (point_in_rectangle(mouse_x, mouse_y, _vr.x, _vr.y, _vr.x + _vr.w, _vr.y + _vr.h)) {
			rg_sel = pl_focus; pv_face = pl_focus; pv_mode = "region"; pv_dw = false;
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			exit;
		}
	}
	// the drawer's tab: open / close
	var _tb = __pv_tab_r();
	if (point_in_rectangle(mouse_x, mouse_y, _tb.x, _tb.y, _tb.x + _tb.w, _tb.y + _tb.h)) {
		pv_dw = !pv_dw;
		play_sound_ext(snd_softclick, .95, 1.05, .4, 1);
		exit;
	}
	// a region row (the drawer open): the camera turns to it
	if (pv_dwa > .5) {
		for (var _i = 0; _i < EXPED_REGIONS; _i++) {
			var _pr0 = __pv_row_r(_i);
			if (!point_in_rectangle(mouse_x, mouse_y, _pr0.x, _pr0.y, _pr0.x + _pr0.w, _pr0.y + _pr0.h)) continue;
			if (pl_focus == _i && pv_face < 0) { pv_face = _i; play_sound_ext(snd_softclick, .95, 1.05, .3, 1); exit; }
			__pv_pick(_i);
			exit;
		}
	}
	exit;
}
// ======================= THE GALAXY: presses do nothing here (the pan / tap are above) =======================
if (view == "galaxy") exit;

// (the region window is gone - the planet page's region mode, 2026-09-15)

// ======================= THE DEPARTURE: the crew, the brief, [depart] =======================
if (view == "depart") {
	var _dr = __depart_r();
	if (point_in_rectangle(mouse_x, mouse_y, _dr.x, _dr.y, _dr.x + _dr.w, _dr.y + _dr.h)) {
		var _crew = [];
		for (var _c = 0; _c < array_length(sel_crew); _c++) { var _sp = __sp_by_id(sel_crew[_c]); if (!is_undefined(_sp)) array_push(_crew, _sp); }
		var _di = -1;
		for (var _i = 0; _i < array_length(_e.board); _i++) if (_e.board[_i].seed == pl_dest.seed) _di = _i;
		if (_di >= 0 && array_length(_crew) > 0 && exped_start(_di, _crew, dp_mode, dp_quest, rg_sel)) {
			play_sound_ext(snd_apply, 1, 1.2, .5, 1);
			if (dp_mode == "quest" && dp_slot >= 0) exped_offer_take(pl_dest, rg_sel, dp_slot, g.exped.seq);   // (the board marks it taken - 2026-09-15)
			dp_slot = -1;
			sel_crew = [];
			view = "hub";
		} else play_sound_ext(snd_matclick2, .7, .8, .35, 0);
		exit;
	}
	// the crew: tap to add to the party, tap again to drop; up to EXPED_PARTY
	for (var _k = 0; _k < array_length(g.sprites); _k++) {
		var _cr = __dchip_r(_k);
		if (!point_in_rectangle(mouse_x, mouse_y, _cr.x, _cr.y, _cr.x + _cr.w, _cr.y + _cr.h)) continue;
		var _sp = g.sprites[_k];
		dp_look = _sp.id;   // (inspected, picked or not)
		var _at = array_get_index(sel_crew, _sp.id);
		if (_at >= 0) { array_delete(sel_crew, _at, 1); play_sound_ext(snd_softclick, .9, 1, .4, 1); exit; }
		if ((_sp[$ "trip"] ?? false) || array_length(sel_crew) >= EXPED_PARTY) { play_sound_ext(snd_matclick2, .7, .8, .35, 0); exit; }
		// a napping one wakes on the tap (his ask: no walking off to poke it)
		if (_sp.asleep) { _sp.asleep = false; _sp.hurt = 0; save_mark_dirty(); }
		array_push(sel_crew, _sp.id);
		play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
		exit;
	}
	exit;
}

// ======================= THE HAUL: collect, or the recruit moment =======================
if (view == "haul") {
	var _hi = __haul_i();
	if (swap_pick) {
		// the roster: tap who retires
		for (var _k = 0; _k < array_length(g.sprites); _k++) {
			var _pr = __pick_r(_k);
			if (point_in_rectangle(mouse_x, mouse_y, _pr.x, _pr.y, _pr.x + _pr.w, _pr.y + _pr.h)) {
				var _sid = g.sprites[_k].id;
				exped_collect(_hi, room_width * .5, room_height * .5, "swap:" + string(_sid));
				swap_pick = false;
				view = "hub";
				play_sound_ext(snd_apply, 1, 1.2, .5, 1);
				exit;
			}
		}
		exit;
	}
	var _h = _e.hauls[_hi];
	var _found = 0;
	for (var _i = 0; _i < array_length(_h.finds); _i++) if (_h.finds[_i].kind == "sprite") _found++;
	var _recruit = (_found > 0 && array_length(g.sprites) + _found > SPRITE_CAP);
	if (_recruit) {
		var _sw = __swap_r(), _go = __go_r();
		if (point_in_rectangle(mouse_x, mouse_y, _sw.x, _sw.y, _sw.x + _sw.w, _sw.y + _sw.h)) { swap_pick = true; play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1); exit; }
		if (point_in_rectangle(mouse_x, mouse_y, _go.x, _go.y, _go.x + _go.w, _go.y + _go.h)) {
			exped_collect(_hi, room_width * .5, room_height * .5, "letgo");
			view = "hub";
			play_sound_ext(snd_apply, 1, 1.2, .5, 1);
			exit;
		}
	} else {
		var _cb = __col_r();
		if (point_in_rectangle(mouse_x, mouse_y, _cb.x, _cb.y, _cb.x + _cb.w, _cb.y + _cb.h)) {
			exped_collect(_hi, room_width * .5, room_height * .5);
			view = "hub";
			play_sound_ext(snd_apply, 1, 1.2, .5, 1);
			exit;
		}
	}
	exit;
}

// ======================= THE TRIP: a fight can be stepped by hand =======================
if (view == "trip") {
	var _tr = __trip();
	// a tap on the replay's window skips the rest of it
	if (!is_undefined(rp)) {
		var _fy0 = room_height - 8 - fight_s;
		if (point_in_rectangle(mouse_x, mouse_y, log_x, _fy0, log_x + log_w, _fy0 + fight_s)) {
			rp.r.seen = true; rp = undefined;
			play_sound_ext(snd_softclick, .95, 1.05, .4, 1);
			exit;
		}
	}
	// [recall]: an exploring crew comes home
	if (!is_undefined(_tr) && (_tr[$ "mode"] ?? "quest") == "explore" && !(_tr[$ "recall"] ?? false)) {
		var _rr2 = __recall_r();
		if (point_in_rectangle(mouse_x, mouse_y, _rr2.x, _rr2.y, _rr2.x + _rr2.w, _rr2.y + _rr2.h)) {
			exped_recall(_tr);
			play_sound_ext(snd_apply, 1, 1.2, .5, 1);
			exit;
		}
	}
	// [map]: the world's region
	if (!is_undefined(_tr)) {
		var _mr = __trip_map_r();
		if (point_in_rectangle(mouse_x, mouse_y, _mr.x, _mr.y, _mr.x + _mr.w, _mr.y + _mr.h)) {
			map_dest = _tr.dest; map_rgi = _tr[$ "rgi"] ?? 0; map_from = "trip"; view = "map";
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			exit;
		}
	}
	// [crew]: this trip's crew, in the crew menu (his ask: only the sprites on the quest)
	if (!is_undefined(_tr)) {
		var _tcr = __trip_crew_r();
		if (point_in_rectangle(mouse_x, mouse_y, _tcr.x, _tcr.y, _tcr.x + _tcr.w, _tcr.y + _tcr.h)) {
			crew_trip = _tr.id; sheet_id = _tr.sids[0]; view = "crew"; it_pop = undefined;
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			exit;
		}
	}
	// [abort]: the question first (the confirm popup); the crew comes home
	if (!is_undefined(_tr) && !(_tr[$ "aborted"] ?? false) && _tr.stage != 2) {
		var _abr = __trip_abort_r();
		if (point_in_rectangle(mouse_x, mouse_y, _abr.x, _abr.y, _abr.x + _abr.w, _abr.y + _abr.h)) {
			confirm = "abort";
			play_sound_ext(snd_softclick, .95, 1.05, .4, 1);
			exit;
		}
	}
	// a crew row opens that sprite's sheet (this crew only)
	if (!is_undefined(_tr)) {
		for (var _k = 0; _k < array_length(_tr.sids); _k++) {
			var _cr = __crew_row_r(_k);
			if (point_in_rectangle(mouse_x, mouse_y, _cr.x, _cr.y, _cr.x + _cr.w, _cr.y + _cr.h)) {
				sheet_id = _tr.sids[_k]; view = "crew"; crew_trip = _tr.id; it_pop = undefined;
				play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
				exit;
			}
		}
	}
	if (!is_undefined(_tr) && !is_undefined(_tr.fight) && !_tr.fight.over) {
		var _sr = __step_r();
		if (point_in_rectangle(mouse_x, mouse_y, _sr.x, _sr.y, _sr.x + _sr.w, _sr.y + _sr.h)) {
			exped_fight_turn(_tr.fight);
			play_sound_ext(snd_matclick2, .9, 1.1, .4, 1);
		}
	}
	exit;
}

// ======================= THE HUB =======================
// the list: a trip or a haul opens its page
var _rows = array_length(_e.hauls) + array_length(_e.trips);
for (var _i = 0; _i < _rows; _i++) {
	var _rr = __row_r(_i);
	if (!point_in_rectangle(mouse_x, mouse_y, _rr.x, _rr.y, _rr.x + _rr.w, _rr.y + _rr.h)) continue;
	if (_i < array_length(_e.hauls)) { view = "haul"; view_id = _e.hauls[_i].id; pg_a = 0; pg_dir = 1; }
	else { view = "trip"; view_id = _e.trips[_i - array_length(_e.hauls)].id; }
	play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
	exit;
}
// [crew]: the roster
if (array_length(g.sprites) > 0) {
	var _shr = __crewbtn_r();
	if (point_in_rectangle(mouse_x, mouse_y, _shr.x, _shr.y, _shr.x + _shr.w, _shr.y + _shr.h)) {
		view = "crew"; crew_trip = -1; it_pop = undefined; crew_from = "hub";
		play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
		exit;
	}
}
// [galaxy]: the star map (his ask, 2026-09-15)
var _hgl = __hub_gal_r();
if (point_in_rectangle(mouse_x, mouse_y, _hgl.x, _hgl.y, _hgl.x + _hgl.w, _hgl.y + _hgl.h)) {
	gx_from = "hub"; view = "galaxy";
	play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
	exit;
}
// a world: its planet window
for (var _i = 0; _i < array_length(_e.board); _i++) {
	var _c = __card_r(_i);
	if (point_in_rectangle(mouse_x, mouse_y, _c.x, _c.y, _c.x + _c.w, _c.y + _c.h)) {
		sel_dest = _i; pl_dest = _e.board[_i]; rg_sel = 0; pl_focus = -1; view = "planet"; pv_mode = "planet"; pv_zoom = 1; pv_cfade = 1;
		play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
		exit;
	}
}
