// ---- THE OPEN/CLOSE EASE (the overlay contract) ----
oa = move_to(oa, closing ? 0 : 1, closing ? UI_OUT_SPD : UI_IN_SPD);
if (abs(oa - (closing ? 0 : 1)) < .004) oa = closing ? 0 : 1;
if (closing && oa <= 0) { instance_destroy(); exit; }

var _e = g.exped;
// UNDER THE SETTINGS (2026-09-15): the panel stays up but deeper (the
// settings draws over it), its hand folded, its input off (below)
var _under = instance_exists(syst_settings);
depth = _under ? -500 : -510;
if (instance_exists(turn_px)) turn_px.depth = depth - 1;
// EVERY PAGE FADES IN (his ask, 2026-09-15: "some don't have animations"):
// a view change lights the new page from black (the one veil, turn_px);
// a turn already under way (region -> depart) is left to itself
if (view != view_last) { if (view_last != "" && pg_dir == 0) { pg_a = 0; pg_dir = 1; } view_last = view; }
if (_under && hand != "") __hand_close();
// THE SWINGS (his ask, 2026-09-15: "ui elements swing in from off screen"):
// the preparation page in (dp_in 0 -> 1) and out again (dp_dir -1, then
// dp_next); region mode's info box and buttons (rg_in)
if (view == "depart") {
	dp_in = move_to(dp_in, (dp_dir < 0) ? 0 : 1, 4);
	if (dp_dir < 0 && dp_in <= .03) { dp_in = 0; dp_dir = 0; view = dp_next; dp_look = -1; if (view == "planet") { pv_mode = "region"; view_last = view; pg_a = 1; pg_dir = 0; } else if (view == "trip") { pg_a = 0; pg_dir = 1; view_last = view; } }   // (the trip's page fades in - 2026-09-16)   // (to the region: it arrives lit and swings in - no black blink; 2026-09-16)
	else if (dp_dir >= 0 && dp_in >= .985) dp_in = 1;
} else if (pg_dir == 0) dp_in = 0;
rg_box_a = move_to(rg_box_a, rg_box_open ? 1 : 0, 5);   // the info box's fold (2026-09-16)
if (view == "planet" && pv_mode == "region") {
	// region mode swings in - and OUT the same way (rg_leave: the info box back to the left, the buttons back to their edges), then the planet
	if (rg_leave) { rg_in = move_to(rg_in, 0, 4); if (rg_in <= .03) { rg_in = 0; rg_leave = false; pv_mode = "planet"; } }
	else { rg_in = move_to(rg_in, 1, 4); if (rg_in >= .985) rg_in = 1; }
} else { rg_in = 0; rg_leave = false; }
// the sheet modal's fade (dp_sheet_a; the sprite it showed stays for the fade out), the map's legend, the haul's roster list
if (dp_sheet >= 0) dp_sheet_v = dp_sheet;
dp_sheet_a = move_to(dp_sheet_a, (view == "depart" && dp_sheet >= 0) ? 1 : 0, 6);
if (abs(dp_sheet_a - ((view == "depart" && dp_sheet >= 0) ? 1 : 0)) < .01) dp_sheet_a = (view == "depart" && dp_sheet >= 0) ? 1 : 0;
leg_a = move_to(leg_a, (view == "map" && map_legend) ? 1 : 0, 5);
swap_a = move_to(swap_a, (view == "haul" && swap_pick) ? 1 : 0, 5);
// (the banners stay in their rows - a seated one shows a [-]; no flight, his call 2026-09-16)
if (view == "depart" && is_struct(pl_dest)) dp_off = clamp(dp_off, 0, __dp_off_max());
else { dp_off = 0; dp_ldrag = undefined; }
// THE PAGE TURN: to black, the view turns, back to light (__page_go)
if (pg_dir < 0) { pg_a = move_to(pg_a, 0, 3); if (pg_a <= .04) { pg_a = 0; view = pg_next; pg_dir = 1; } }
else if (pg_dir > 0) { pg_a = move_to(pg_a, 1, 4); if (pg_a >= .97) { pg_a = 1; pg_dir = 0; } }
// the worlds are built a few rows a frame (planet_gen_step, __worlds_step:
// the board's, the trips', the planet window's), so every portrait is the
// full world within a second or two, without a hitch
// ...but NOT for the sprite menu (his report, 2026-09-17: "major lag when
// initially opening this window"): its pages never show a world or a sky,
// and on a fresh save the first touch of the galaxy builds all ten
// thousand stars in one frame. Nothing here to build for, so nothing built.
if (mode != "sprites" && galaxy_ready()) {   // (never before the chart: a hint needs the galaxy, and the galaxy would build in one frame - 2026-09-17)
	__worlds_step();
	__lod_step();   // (the zoom tiers, 2026-09-17 - here in the Step, never inside a page's target)
	if (variable_global_exists("starmap") && is_struct(g.starmap)) galaxy_neb_sheet();
}   // (the nebula sheet bakes here, in the Step, never inside a page's target - 2026-09-16)
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
if (view == "trip" && is_undefined(__trip())) { view = (__haul_i() >= 0) ? "haul" : "planet"; if (view == "haul") { pg_a = 0; pg_dir = 1; hl_open = false; } }   // (the haul fades in - his ask, 2026-09-15)
if (view == "haul" && __haul_i() < 0 && pg_dir >= 0) { view = "planet"; swap_pick = false; }   // (not mid-turn: the collect's fade-out finishes on the card)
if (view == "sheet") view = "crew";
if (view == "crew" && is_undefined(__sp_by_id(sheet_id)) && array_length(g.sprites) > 0) sheet_id = g.sprites[0].id;
if (view == "map" && !is_struct(map_dest)) view = "planet";
if (view == "hub") view = "planet";   // (the hub went, 2026-09-16)
if (!is_struct(pl_dest) && is_struct(g[$ "exped"]) && array_length(g.exped.board) > 0) pl_dest = g.exped.board[0];   // (the board's world, always)
// THE LOADING VEIL (his call, 2026-09-17: the boot's spinner moved here - a
// page waits for what it needs: the galaxy charting in the background, the
// board, the world's rows and bake). While it shows: the chart is rushed,
// the world stepped hard, and only [back] and the X answer
var _ldg = __loading();
if (is_struct(_ldg)) {
	if (instance_exists(syst_handle_save)) syst_handle_save.bg_rush = true;
	if (galaxy_ready() && mode != "sprites") { var _llim = get_timer() + 9000; while (get_timer() < _llim && is_struct(__loading())) __worlds_step(); }
	ld_v = trickle(ld_v, _ldg.prog, 4);
	if (!_under && input_free(ui_layer_overlay) && mouse_check_button_pressed(mb_left) && __back_on()) { var _lbk = __back_r(); if (point_in_rectangle(mouse_x, mouse_y, _lbk.x, _lbk.y, _lbk.x + _lbk.w, _lbk.y + _lbk.h)) __back(); }
	exit;
} else ld_v = 0;
if ((view == "planet" || view == "region" || view == "depart") && !is_struct(pl_dest)) { exped_close(); exit; }   // (no world at all: nothing to show)

// THE SUN IS LIVE (his report, 2026-09-15: "mid-morning but clearly night" -
// the render's sun was the one at open, the words read the clock's; the
// orbits ran a year in minutes, so they parted within it)
if (is_struct(pv_sky)) pv_sky.light_w = galaxy_sun_dir(0, pl_dest);   // (every page: the small worlds on the haul card and the list rows read it too - bug hunt)
// THE ORBIT VIEW'S CLOCK: the world spins its own axis (the universal
// clock sets it the first time), the camera rides the spin (geosync), and
// turns to face a picked region (pv_face) - a rotation about the view axis
// that lifts the spot's view z toward one; the sign is tried both ways
if (view == "planet" && is_struct(pl_dest)) {
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
	var _zt0 = pv_zuser * ((pv_mode == "region") ? PV_ZOOM_RG : 1);
	pv_zoom  = lerp(pv_zoom, _zt0, 1 - power(.88, delta));   // (the mode's pull-in x the wheel's - 2026-09-17)
	if (abs(pv_zoom - _zt0) < .002) pv_zoom = _zt0;        // (and lands, rather than creeping under a pixel for a second - the cells would flicker)
	pv_cfade = lerp(pv_cfade, 1 - .88 * clamp((pv_zoom - 1.2) / (PV_ZOOM_RG - 1.2), 0, 1), 1 - power(.88, delta));   // (by the ZOOM, his ask 2026-09-17: the wheel past 1.2 thins them, region mode's 1.55 is the same .12 as before)
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
	var _lmax = (_lr.h > 0) ? max(0, __log_content_h() - _lr.h) : 0;   // (no band, no bar: the haul's diary shut - bug hunt 2026-09-16)
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
if (view != "trip" && confirm == "abort") confirm = "";   // (the page turned under it - a trip got home)
if (view != "crew" && (confirm == "dismiss" || confirm == "dismiss2")) confirm = "";   // (the sprite menu's question, only there)
if (confirm != "") conf_kind = confirm;   // (remembered through the fade-out)
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
			if (confirm == "abort") { var _atr = __trip(); if (!is_undefined(_atr)) exped_abort(_atr); confirm = ""; play_sound_ext(snd_apply, 1, 1.2, .5, 1); }
			else if (confirm == "dismiss") { confirm = "dismiss2"; play_sound_ext(snd_softclick, .9, 1, .4, 1); }   // (the second question - his ask, 2026-09-17)
			else if (confirm == "dismiss2") {
				// THE DEED (exped_retire): the sprite goes; the sheet turns to the first left, or the menu folds
				var _dsp2 = __sp_by_id(sheet_id);
				if (!is_undefined(_dsp2) && !(_dsp2[$ "trip"] ?? false)) {
					var _gone = exped_retire(_dsp2.id);
					it_pop = undefined;
					if (_gone != "") assign_banner(_gone + " has gone to live somewhere quieter", c_gold, c_black);
					if (array_length(g.sprites) > 0) sheet_id = g.sprites[0].id; else closing = true;
				}
				confirm = "";
				play_sound_ext(snd_matclick2, .8, .9, .5, 1);
			}
			else confirm = "";
		} else if (conf_hot == 2) { confirm = ""; play_sound_ext(snd_matclick2, .8, .9, .5, 1); }
	}
	exit;
}
if (conf_a > .01) exit;   // (fading out: nothing under it acts yet)
if (pg_dir < 0) exit;     // (the page is turning to black; a page lighting up already takes presses - snappier)
if (view == "depart" && (dp_dir != 0 || dp_in < 1)) exit;   // (the page is swinging)
// ---- THE PREPARATION PAGE'S LIST: the wheel, or a drag on it (held input - above the press gate) ----
if (view == "depart" && is_struct(pl_dest) && dp_sheet < 0) {
	var _dl = __dp_list_r();
	var _din = point_in_rectangle(mouse_x, mouse_y, _dl.x, _dl.y, _dl.x + _dl.w, _dl.y + _dl.h);
	if (_din && __dp_off_max() > 0) {
		if (mouse_wheel_up())   dp_off -= __dp_bh() + 4;
		if (mouse_wheel_down()) dp_off += __dp_bh() + 4;
	}
	if (!is_struct(dp_ldrag) && _din && mouse_check_button_pressed(mb_left) && __dp_off_max() > 0) dp_ldrag = { y0 : mouse_y, off0 : dp_off, moved : 0 };
	if (is_struct(dp_ldrag)) {
		if (mouse_check_button(mb_left)) { dp_off = dp_ldrag.off0 - (mouse_y - dp_ldrag.y0); dp_ldrag.moved = max(dp_ldrag.moved, abs(mouse_y - dp_ldrag.y0)); }
		else dp_ldrag = undefined;
	}
	dp_off = clamp(dp_off, 0, __dp_off_max());
}
// THE [misc] LISTS scroll (2026-09-17): the wheel over the notepad or the friendships
if ((view == "crew" || view == "sheet") && sheet_pg == 2) {
	if (is_struct(misc_nrect) && point_in_rectangle(mouse_x, mouse_y, misc_nrect.x, misc_nrect.y, misc_nrect.x + misc_nrect.w, misc_nrect.y + misc_nrect.h)) {
		if (mouse_wheel_up())   misc_scr_n = max(0, misc_scr_n - 20);
		if (mouse_wheel_down()) misc_scr_n = min(misc_nmax, misc_scr_n + 20);
	}
	if (is_struct(misc_frect) && point_in_rectangle(mouse_x, mouse_y, misc_frect.x, misc_frect.y, misc_frect.x + misc_frect.w, misc_frect.y + misc_frect.h)) {
		if (mouse_wheel_up())   misc_scr_f = max(0, misc_scr_f - 20);
		if (mouse_wheel_down()) misc_scr_f = min(misc_fmax, misc_scr_f + 20);
	}
}
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
			// a slot that turned over under the hand (its clock ran out): the
			// card would show the old quest and pick the new - the hand is
			// dealt again (bug hunt 2026-09-15)
			if (hand == "quests" && is_struct(_c.face[$ "slot"]) && _c.face.slot.salt != _c.face.salt0) { __hand_open("quests"); exit; }
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
if (keyboard_check_pressed(vk_escape) && view == "depart" && dp_sheet >= 0) { dp_sheet = -1; it_pop = undefined; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); exit; }   // (the sheet modal first)
if (keyboard_check_pressed(vk_escape) && view == "trip" && tp_sheet >= 0) { tp_sheet = -1; it_pop = undefined; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); exit; }
if (keyboard_check_pressed(vk_escape)) {
	__back();   // (the planet's back is the close)
	exit;
}
if (variable_global_exists("click_owner") && g.click_owner != noone) exit;

// ======================= THE ORBIT VIEW: the grab, the drag, the glide, the tap =======================
// (held and released input - above the press gate)
if (view == "planet" && is_struct(pl_dest)) {
	var _ocf = starmap_config();
	var _pvr = __pv_r();
	var _pin = point_in_rectangle(mouse_x, mouse_y, _pvr.x, _pvr.y, _pvr.x + _pvr.w, _pvr.y + _pvr.h);
	// THE WHEEL (his ask, 2026-09-17): closer or further, in either mode - on top of region mode's pull-in.
	// The drag turns fewer degrees a pixel the closer you are, so the ground under the hand keeps pace with it
	if (_pin && !__pv_ui_hit()) {
		if (mouse_wheel_up())   pv_zuser = min(pv_zuser * 1.18, PV_ZOOM_MAX);
		if (mouse_wheel_down()) pv_zuser = max(pv_zuser / 1.18, PV_ZOOM_MIN);
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
			pv_cam = mat3_mul(pv_cam, mat3_rot(0, 1, 0,  pv_vx * _osens * delta));
			pv_cam = mat3_mul(pv_cam, mat3_rot(1, 0, 0, -pv_vy * _osens * delta));
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
	// [ENTER] (2026-09-16): into the tapped star's system
	var _ger = __gx_enter_r();
	var _onstrip = (gx_sel >= 0 && is_struct(gx_sys) && point_in_rectangle(mouse_x, mouse_y, _ger.x, _ger.y, _ger.x + _ger.w, _ger.y + _ger.h));
	if (_onstrip && mouse_check_button_pressed(mb_left)) {
		__sy_enter(gx_sel); sy_from = "galaxy";
		__page_go("system");
		play_sound_ext(snd_apply, 1, 1.2, .5, 1);
		exit;
	}
	if (!gx_press && mouse_check_button_pressed(mb_left) && _gin && !_onbk && !_onmm && !_onstrip) { gx_press = true; gx_px = mouse_x; gx_py = mouse_y; gx_cx0 = gx_x; gx_cy0 = gx_y; gx_travel = 0; }
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

// ======================= THE STAR SYSTEM VIEW (the demo's): orbit the camera, glide, the wheel's distance, the dive =======================
if (view == "system" && is_struct(sy_sys)) {
	var _ocf = starmap_config();
	// the dive: an eased swell about the picked world (or station - 2026-09-17), then its page (behind the veil)
	if (sy_warp_pl >= 0 || sy_warp_st >= 0) {
		sy_warp_t = min(sy_warp_t + delta / 30, 1);
		var _we = sy_warp_t * sy_warp_t * (3 - 2 * sy_warp_t);
		sy_warp_s = power(15, _we);
		if (sy_warp_t >= 1) {
			if (sy_warp_st >= 0) {
				st_sel = sy_warp_st; st_yaw = 0; st_pitch = -20; st_cam = mat3_mul(mat3_rot(0, 1, 0, st_yaw), mat3_rot(1, 0, 0, st_pitch)); st_vx = 0; st_vy = 0; st_drag = false;
				sy_warp_st = -1; sy_warp_s = 1; sy_warp_t = 0;
				view = "station"; pg_a = 0; pg_dir = 1; view_last = view;
			} else {
				var _di = exped_world_open(sy_star, sy_warp_pl);
				sy_warp_pl = -1; sy_warp_s = 1; sy_warp_t = 0;
				if (_di >= 0) { sel_dest = _di; pl_dest = g.exped.board[_di]; rg_sel = 0; pl_focus = -1; pv_mode = "planet"; pv_zoom = 1; pv_zuser = 1; pv_cfade = 1; view = "planet"; pg_a = 0; pg_dir = 1; view_last = view; }
			}
		}
		exit;
	}
	var _svr = __sy_view_r();
	var _sdk = point_in_rectangle(mouse_x, mouse_y, __sy_dock_x(), list_y + 16, room_width, room_height - 8);   // (the drawer and its tab: no place to drag or wheel from)
	var _sin = point_in_rectangle(mouse_x, mouse_y, _svr.x, _svr.y, _svr.x + _svr.w, _svr.y + _svr.h) && !_sdk;
	if (_sin) { if (mouse_wheel_up()) sy_D = max(sy_D / 1.08, 150); if (mouse_wheel_down()) sy_D = min(sy_D * 1.08, 430); }
	var _bk0 = __back_r();
	var _onbk0 = point_in_rectangle(mouse_x, mouse_y, _bk0.x, _bk0.y, _bk0.x + _bk0.w, _bk0.y + _bk0.h);
	var _ser = __sy_enter_r(), _sgl0 = __galaxy_r();
	var _oner = (sy_dwa <= .3 && point_in_rectangle(mouse_x, mouse_y, _ser.x, _ser.y, _ser.x + _ser.w, _ser.y + _ser.h)) || point_in_rectangle(mouse_x, mouse_y, _sgl0.x, _sgl0.y, _sgl0.x + _sgl0.w, _sgl0.y + _sgl0.h);
	if (!sy_drag && mouse_check_button_pressed(mb_left) && _sin && !_onbk0 && !_oner) { sy_drag = true; sy_drag_px = 0; sy_dx = mouse_x; sy_dy = mouse_y; }
	if (sy_drag && mouse_check_button(mb_left)) {
		var _dx = mouse_x - sy_dx, _dy = mouse_y - sy_dy;
		sy_drag_px += abs(_dx) + abs(_dy);
		if (_dx != 0) sy_cam = mat3_mul(sy_cam, mat3_rot(0, 1, 0,  _dx * _ocf.orbit_sens));
		if (_dy != 0) sy_cam = mat3_mul(sy_cam, mat3_rot(1, 0, 0, -_dy * _ocf.orbit_sens));
		sy_vx = lerp(sy_vx, _dx, .5); sy_vy = lerp(sy_vy, _dy, .5);
		sy_dx = mouse_x; sy_dy = mouse_y;
	}
	if (!sy_drag) {
		if (abs(sy_vx) > .02 || abs(sy_vy) > .02) {
			sy_cam = mat3_mul(sy_cam, mat3_rot(0, 1, 0,  sy_vx * _ocf.orbit_sens * delta));
			sy_cam = mat3_mul(sy_cam, mat3_rot(1, 0, 0, -sy_vy * _ocf.orbit_sens * delta));
			var _dk = power(_ocf.orbit_glide, delta);
			sy_vx *= _dk; sy_vy *= _dk;
		} else { sy_vx = 0; sy_vy = 0; }
	}
	if (sy_drag && mouse_check_button_released(mb_left)) {
		sy_drag = false;
		if (sy_drag_px <= 4) {
			// a tap: the nearest world under it (the demo's reach), or space - nothing
			var _hit = -1, _pls2 = sy_sys.planets;
			for (var _i = 0; _i < array_length(_pls2); _i++) {
				var _pw2 = __sy_ppos(_pls2[_i]); var _pp2 = __sy_proj(_pw2[0], 0, _pw2[2]);
				if (is_undefined(_pp2)) continue;
				if (point_distance(mouse_x, mouse_y - list_y, _pp2[0], _pp2[1]) <= _pls2[_i].size * _pp2[2] * 1.9 + 6) { _hit = _i; break; }
			}
			// ...or the nearest station (2026-09-17): a station and a world are never both picked
			var _shit = -1;
			for (var _j = 0; _j < array_length(sy_stns); _j++) {
				var _sq2 = __st_ppos(sy_stns[_j]); var _sp2 = __sy_proj(_sq2[0], 0, _sq2[2]);
				if (is_undefined(_sp2)) continue;
				if (point_distance(mouse_x, mouse_y - list_y, _sp2[0], _sp2[1]) <= sy_stns[_j].size * _sp2[2] * 1.9 + 6) { _shit = _j; break; }
			}
			// ...or a belt's band (the polish, 2026-09-17): the nearest point of its ring within reach names it - nothing to enter
			var _bhit = -1;
			if (_hit < 0 && _shit < 0) for (var _b = 0; _b < array_length(sy_belts) && _bhit < 0; _b++) {
				var _bo = sy_belts[_b].orbit;
				for (var _ba = 0; _ba < 360; _ba += 4) { var _bq = __sy_proj(dcos(_ba) * _bo, 0, dsin(_ba) * _bo); if (is_undefined(_bq)) continue; if (point_distance(mouse_x, mouse_y - list_y, _bq[0], _bq[1]) <= max(5, sy_belts[_b].width * .5 * _bq[2]) + 2) { _bhit = _b; break; } }
			}
			if (_shit >= 0 && _hit < 0) { if (_shit != sy_ssel) play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1); sy_ssel = _shit; sy_sel = -1; sy_bsel = -1; }
			else if (_bhit >= 0) { if (_bhit != sy_bsel) play_sound_ext(snd_softclick, 1, 1.1, .35, 1); sy_bsel = _bhit; sy_sel = -1; sy_ssel = -1; }
			else { if (_hit >= 0 && _hit != sy_sel) play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1); sy_sel = _hit; sy_ssel = -1; sy_bsel = -1; }
		}
	}
	sy_dwa = move_to(sy_dwa, sy_dw ? 1 : 0, 6);   // the drawer's ease
}
// ======================= THE STATION PAGE (2026-09-17): drag to look round, a glide on release =======================
if (view == "station" && st_sel >= 0 && st_sel < array_length(sy_stns)) {
	var _ocs = starmap_config();
	var _stvr = __sy_view_r();
	var _bks = __back_r();
	var _stin = point_in_rectangle(mouse_x, mouse_y, _stvr.x, _stvr.y, _stvr.x + _stvr.w, _stvr.y + _stvr.h) && !point_in_rectangle(mouse_x, mouse_y, _bks.x, _bks.y, _bks.x + _bks.w, _bks.y + _bks.h);
	if (!st_drag && mouse_check_button_pressed(mb_left) && _stin) { st_drag = true; st_drag_px = 0; st_dx = mouse_x; st_dy = mouse_y; }
	if (st_drag && mouse_check_button(mb_left)) {
		var _sdx = mouse_x - st_dx, _sdy = mouse_y - st_dy;
		st_drag_px += abs(_sdx) + abs(_sdy);
		st_yaw += _sdx * _ocs.orbit_sens; st_pitch = clamp(st_pitch - _sdy * _ocs.orbit_sens, -80, 80);
		st_vx = lerp(st_vx, _sdx, .5); st_vy = lerp(st_vy, _sdy, .5);
		st_dx = mouse_x; st_dy = mouse_y;
	}
	if (!st_drag) {
		if (abs(st_vx) > .02 || abs(st_vy) > .02) {
			st_yaw += st_vx * _ocs.orbit_sens * delta; st_pitch = clamp(st_pitch - st_vy * _ocs.orbit_sens * delta, -80, 80);
			var _sdk = power(_ocs.orbit_glide, delta);
			st_vx *= _sdk; st_vy *= _sdk;
		} else { st_vx = 0; st_vy = 0; }
	}
	st_cam = mat3_mul(mat3_rot(0, 1, 0, st_yaw), mat3_rot(1, 0, 0, st_pitch));   // (the turntable: yaw about the world's up, pitch about the view's side - it never rolls)
	if (st_drag && mouse_check_button_released(mb_left)) st_drag = false;
}
if (!mouse_check_button_pressed(mb_left)) exit;   // EVERYTHING BELOW IS A PRESS

// the debug clock: x1 / x10 / x100 (not on the sprite menu)
if (mode != "sprites")
for (var _k = 0; _k < 3; _k++) {
	var _r = __spd_r(_k);
	if (point_in_rectangle(mouse_x, mouse_y, _r.x, _r.y, _r.x + _r.w, _r.y + _r.h)) {
		_e.spd = [1, 10, 100][_k];
		play_sound_ext(snd_softclick, 1, 1.1, .4, 1);
		exit;
	}
}
// THE STAR SYSTEM's dock (2026-09-16): a row picks a world, [enter] dives into it (the swell, then its page)
if (view == "system" && is_struct(sy_sys) && sy_warp_pl < 0) {
	var _npl = array_length(sy_sys.planets);
	// [galaxy] bottom left: the map (its [back] returns here)
	var _sgl = __galaxy_r();
	if (point_in_rectangle(mouse_x, mouse_y, _sgl.x, _sgl.y, _sgl.x + _sgl.w, _sgl.y + _sgl.h)) { gx_from = "system"; __page_go("galaxy"); play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1); exit; }
	// the drawer's tab: open / close
	var _stb = __sy_tab_r();
	if (point_in_rectangle(mouse_x, mouse_y, _stb.x, _stb.y, _stb.x + _stb.w, _stb.y + _stb.h)) { sy_dw = !sy_dw; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); exit; }
	// [enter] bottom right while the drawer is shut: a station picked dives to its page (2026-09-17)
	if (sy_dwa <= .3 && sy_ssel >= 0) { var _ser3 = __sy_enter_r(); if (point_in_rectangle(mouse_x, mouse_y, _ser3.x, _ser3.y, _ser3.x + _ser3.w, _ser3.y + _ser3.h)) { sy_warp_st = sy_ssel; sy_warp_t = 0; sy_warp_s = 1; play_sound_ext(snd_matclick2, 1.2, 1.4, .6, 1); exit; } }
	if (sy_dwa <= .3 && sy_sel >= 0 && sy_sel < _npl && galaxy_world_biome(sy_sys.planets[sy_sel]) >= 0) { var _ser2 = __sy_enter_r(); if (point_in_rectangle(mouse_x, mouse_y, _ser2.x, _ser2.y, _ser2.x + _ser2.w, _ser2.y + _ser2.h)) { sy_warp_pl = sy_sel; sy_warp_t = 0; sy_warp_s = 1; play_sound_ext(snd_matclick2, 1.2, 1.4, .6, 1); exit; } }
	if (sy_dwa >= .5) {   // (the drawer open: its rows and [enter])
	for (var _j = 0; _j < array_length(sy_stns); _j++) { var _rr2 = __sy_row_r(_npl + _j); if (_rr2.y + _rr2.h > room_height - 8 - 20) break; if (point_in_rectangle(mouse_x, mouse_y, _rr2.x, _rr2.y, _rr2.x + _rr2.w, _rr2.y + _rr2.h)) { sy_ssel = _j; sy_sel = -1; sy_bsel = -1; play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1); exit; } }   // (a station's row - 2026-09-17)
	for (var _b = 0; _b < array_length(sy_belts); _b++) { var _rr3 = __sy_row_r(_npl + array_length(sy_stns) + _b); if (_rr3.y + _rr3.h > room_height - 8 - 20) break; if (point_in_rectangle(mouse_x, mouse_y, _rr3.x, _rr3.y, _rr3.x + _rr3.w, _rr3.y + _rr3.h)) { sy_bsel = _b; sy_sel = -1; sy_ssel = -1; play_sound_ext(snd_softclick, 1, 1.1, .35, 1); exit; } }   // (a belt's row: named, lit - the polish)
	for (var _i = 0; _i < _npl; _i++) { var _rr = __sy_row_r(_i); if (_rr.y + _rr.h > room_height - 8 - 20) break; if (point_in_rectangle(mouse_x, mouse_y, _rr.x, _rr.y, _rr.x + _rr.w, _rr.y + _rr.h)) { sy_ssel = -1; sy_bsel = -1; sy_sel = _i; play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1); exit; } }
	var _sor = __sy_open_r();
	if (point_in_rectangle(mouse_x, mouse_y, _sor.x, _sor.y, _sor.x + _sor.w, _sor.y + _sor.h)) {
		if (sy_ssel >= 0) { sy_warp_st = sy_ssel; sy_warp_t = 0; sy_warp_s = 1; play_sound_ext(snd_matclick2, 1.2, 1.4, .6, 1); exit; }   // (a station - 2026-09-17)
		if (sy_sel < 0 || sy_sel >= _npl || galaxy_world_biome(sy_sys.planets[sy_sel]) < 0) { play_sound_ext(snd_matclick2, .7, .8, .35, 0); exit; }
		sy_warp_pl = sy_sel; sy_warp_t = 0; sy_warp_s = 1;
		play_sound_ext(snd_matclick2, 1.2, 1.4, .6, 1);
		exit;
	}
	}
}
// [back] from any page (drawn on the right, syst_exped_panel's Draw); [crew] beside it (his ask, 2026-09-15)
if (view != "hub") {
	var _bk = __back_r();
	if (__back_on() && point_in_rectangle(mouse_x, mouse_y, _bk.x, _bk.y, _bk.x + _bk.w, _bk.y + _bk.h)) { __back(); exit; }
	if (view != "crew" && array_length(g.sprites) > 0) {
		var _cs = __crewstrip_r();
		if (point_in_rectangle(mouse_x, mouse_y, _cs.x, _cs.y, _cs.x + _cs.w, _cs.y + _cs.h)) {
			crew_from = view; __page_go("crew"); crew_trip = -1; it_pop = undefined;
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			exit;
		}
	}
	// [bestiary] in the crew page's slot (2026-09-16)
	// THE SPRITE MENU's [dismiss] (2026-09-16; 2026-09-17: it ASKS - the confirm
	// popup, then its "are you sure" - the deed is in the popup's yes above)
	if (view == "crew" && mode == "sprites") {
		var _dr = __dismiss_r(), _dsp = __sp_by_id(sheet_id);
		if (!is_undefined(_dsp) && !(_dsp[$ "trip"] ?? false) && point_in_rectangle(mouse_x, mouse_y, _dr.x, _dr.y, _dr.x + _dr.w, _dr.y + _dr.h)) {
			confirm = "dismiss"; it_pop = undefined;
			play_sound_ext(snd_softclick, .9, 1, .4, 1);
			exit;
		}
	}
	if (view == "crew" && mode != "sprites") {
		var _cs2 = __crewstrip_r();
		if (point_in_rectangle(mouse_x, mouse_y, _cs2.x, _cs2.y, _cs2.x + _cs2.w, _cs2.y + _cs2.h)) {
			bs_from = "crew"; __page_go("bestiary"); it_pop = undefined;
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			exit;
		}
	}
	// [the gist] / [all] (2026-09-16): the diary's filter
	if (__histrip_on()) {
		var _hs = __histrip_r();
		if (point_in_rectangle(mouse_x, mouse_y, _hs.x, _hs.y, _hs.x + _hs.w, _hs.y + _hs.h)) {
			log_hi = !log_hi; log_follow = true;
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			exit;
		}
	}
	// [map] beside it: the page's region (2026-09-16 - one button, one place)
	var _mc = __map_ctx();
	if (!is_undefined(_mc)) {
		var _ms = __mapstrip_r();
		if (point_in_rectangle(mouse_x, mouse_y, _ms.x, _ms.y, _ms.x + _ms.w, _ms.y + _ms.h)) {
			map_dest = _mc.dest; map_rgi = _mc.rgi; map_from = view; __page_go("map"); it_pop = undefined;
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			exit;
		}
	}
}

// ======================= THE CREW MENU: tabs on the left =======================
// ======================= THE BESTIARY: a cell =======================
if (view == "bestiary") {
	var _nk = array_length(foe_roster());
	for (var _i = 0; _i < _nk; _i++) {
		var _cr = __bs_cell_r(_i);
		if (point_in_rectangle(mouse_x, mouse_y, _cr.x, _cr.y, _cr.x + _cr.w, _cr.y + _cr.h)) { bs_sel = _i; play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1); exit; }
	}
	exit;
}

if (view == "crew") {
	// the ability picker up: a row picks, anywhere else folds (2026-09-17; vaulted behind SPRITE_AB_PICK - the tooltip folds like any popup)
	if (SPRITE_AB_PICK && is_struct(it_pop) && !is_undefined(it_pop[$ "ab"]) && it_pop.ab < 4) { __ab_pick_tap(); exit; }
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
	// an item row: its popup (the rects the Draw laid down - __sheet_tap, the one handler)
	__sheet_tap();
	exit;
}

// ======================= THE MAP: [legend] =======================
if (view == "map") {
	if (land) { var _ibx = __map_box_r(); if (point_in_rectangle(mouse_x, mouse_y, _ibx.x, _ibx.y, _ibx.x + _ibx.w, _ibx.y + _ibx.h)) { rg_box_open = !rg_box_open; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); exit; } }   // (the info box's fold, 2026-09-16)
	var _lgr = __legend_r();
	if (point_in_rectangle(mouse_x, mouse_y, _lgr.x, _lgr.y, _lgr.x + _lgr.w, _lgr.y + _lgr.h)) { map_legend = !map_legend; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); exit; }
	if (map_legend) { map_legend = false; exit; }   // (any other press folds it)
	// a place: its card (his ask, 2026-09-16); the same place again, or a press elsewhere, folds it
	if (is_struct(map_dest)) {
		var _rg0 = region_get(map_dest, map_rgi), _mr0 = __map_r();
		var _hit = -1, _hd = 9;
		for (var _i = 0; _i < array_length(_rg0.nodes); _i++) {
			var _hp = __map_xy(_rg0.nodes[_i], _rg0, _mr0);
			var _dd = point_distance(mouse_x, mouse_y, _hp.x, _hp.y);
			if (_dd < _hd) { _hd = _dd; _hit = _i; }
		}
		if (_hit >= 0) { map_pop = (map_pop == _hit) ? -1 : _hit; play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1); exit; }
		if (map_pop >= 0) { map_pop = -1; exit; }
	}
	exit;
}

// ======================= THE PLANET PAGE: its buttons, the drawer =======================
// (the grab / drag / tap are above the press gate)
if (view == "planet") {
	if (rg_leave) exit;   // (region mode is swinging out: nothing to press until it has)
	// [galaxy]: the star map
	var _gl = __galaxy_r();
	if (point_in_rectangle(mouse_x, mouse_y, _gl.x, _gl.y, _gl.x + _gl.w, _gl.y + _gl.h)) {
		gx_from = "planet"; __page_go("galaxy");
		play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
		exit;
	}
	// [star system] (2026-09-16): the demo's view of this world's system
	var _syr = __system_r();
	if (point_in_rectangle(mouse_x, mouse_y, _syr.x, _syr.y, _syr.x + _syr.w, _syr.y + _syr.h)) {
		__sy_enter(galaxy_world_sys(pl_dest).star); sy_from = "planet"; __page_go("system");
		play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
		exit;
	}
	// REGION MODE (his ask: no separate window - the camera pulls in, the
	// info box left): [quests] / [explore] bottom right deal THE HAND (the
	// cards pick the departure); [map] is in the strip (2026-09-16)
	if (pv_mode == "region") {
		var _ibr = __rg_banner_r();
		if (point_in_rectangle(mouse_x, mouse_y, _ibr.x, _ibr.y, _ibr.x + _ibr.w, _ibr.y + _ibr.h)) { rg_box_open = !rg_box_open; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); exit; }   // (the fold, 2026-09-16)
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
		// the tabs (2026-09-16)
		for (var _ti = 0; _ti < 2; _ti++) { var _tr2 = __pv_dtab_r(_ti); if (point_in_rectangle(mouse_x, mouse_y, _tr2.x, _tr2.y, _tr2.x + _tr2.w, _tr2.y + _tr2.h)) { if (pv_dtab != _ti) { pv_dtab = _ti; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); } exit; } }
		if (pv_dtab == 0) for (var _i = 0; _i < EXPED_REGIONS; _i++) {
			var _pr0 = __pv_row_r(_i);
			if (!point_in_rectangle(mouse_x, mouse_y, _pr0.x, _pr0.y, _pr0.x + _pr0.w, _pr0.y + _pr0.h)) continue;
			if (pl_focus == _i && pv_face < 0) { pv_face = _i; play_sound_ext(snd_softclick, .95, 1.05, .3, 1); exit; }
			__pv_pick(_i);
			exit;
		}
		// THE EXPEDITIONS in the drawer (2026-09-16): a haul's row opens the haul, a trip's the trip
		var _nl = (pv_dtab == 1) ? (array_length(_e.hauls) + array_length(_e.trips)) : 0;
		for (var _k = 0; _k < _nl; _k++) {
			var _pr1 = __pv_trip_r(_k);
			if (_pr1.y + _pr1.h > room_height - 32) break;
			if (!point_in_rectangle(mouse_x, mouse_y, _pr1.x, _pr1.y, _pr1.x + _pr1.w, _pr1.y + _pr1.h)) continue;
			if (_k < array_length(_e.hauls)) { view_id = _e.hauls[_k].id; __page_go("haul"); }
			else { view_id = _e.trips[_k - array_length(_e.hauls)].id; __page_go("trip"); }
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			exit;
		}
	}
	// [bestiary] in the left column (planet mode)
	if (pv_mode == "planet") {
		var _bsr = __best_r();
		if (point_in_rectangle(mouse_x, mouse_y, _bsr.x, _bsr.y, _bsr.x + _bsr.w, _bsr.y + _bsr.h)) {
			bs_from = "planet"; __page_go("bestiary");
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			exit;
		}
	}
	exit;
}
// ======================= THE GALAXY: presses do nothing here (the pan / tap are above) =======================
if (view == "galaxy") exit;

// (the region window is gone - the planet page's region mode, 2026-09-15)

// ======================= THE DEPARTURE: [+] / [-], a banner = its sheet, [depart] =======================
if (view == "depart") {
	// THE SHEET MODAL owns the page while it is up: its rows and popups, or a press off it closes it
	if (dp_sheet >= 0) {
		if (__sheet_tap()) exit;
		var _msr = __dp_sheet_r();
		if (point_in_rectangle(mouse_x, mouse_y, _msr.x, _msr.y, _msr.x + _msr.w, _msr.y + _msr.h)) exit;
		// off the sheet: it closes, and the press goes on to whatever it hit
		// (another banner opens its sheet in the same press - his ask
		// 2026-09-15); [depart] under the box only closes it
		dp_sheet = -1; it_pop = undefined; it_rects = [];
		play_sound_ext(snd_softclick, .95, 1.05, .4, 1);
		var _dr0 = __depart_r();
		if (point_in_rectangle(mouse_x, mouse_y, _dr0.x, _dr0.y, _dr0.x + _dr0.w, _dr0.y + _dr0.h)) exit;
	}
	var _dr = __depart_r();
	if (point_in_rectangle(mouse_x, mouse_y, _dr.x, _dr.y, _dr.x + _dr.w, _dr.y + _dr.h)) {
		__dp_sync();
		var _crew = [];
		for (var _c = 0; _c < array_length(sel_crew); _c++) { var _sp = __sp_by_id(sel_crew[_c]); if (!is_undefined(_sp)) array_push(_crew, _sp); }
		var _di = -1;
		for (var _i = 0; _i < array_length(_e.board); _i++) if (_e.board[_i].seed == pl_dest.seed) _di = _i;
		if (_di >= 0 && array_length(_crew) > 0 && exped_start(_di, _crew, dp_mode, dp_quest, rg_sel, dp_stance)) {   // (the stance rides along, 2026-09-16)
			play_sound_ext(snd_apply, 1, 1.2, .5, 1);
			if (dp_mode == "quest" && dp_slot >= 0) exped_offer_take(pl_dest, rg_sel, dp_slot, g.exped.seq, dp_quest);   // (the board marks it taken - 2026-09-15; not if the slot turned over meanwhile)
			dp_slot = -1;
			sel_crew = []; dp_slots = array_create(exped_party_max(), -1); dp_pos = {};
			view_id = g.exped.seq;   // (the trip that just left - its page, his ask 2026-09-16)
			__dp_leave("trip");   // (the page swings out, then the trip's page with the diary)
		} else play_sound_ext(snd_matclick2, .7, .8, .35, 0);
		exit;
	}
	// THE STANCE pills (2026-09-16): a press picks the word
	for (var _si = 0; _si < array_length(dp_stance_rects); _si++) {
		var _sr2 = dp_stance_rects[_si];
		if (!point_in_rectangle(mouse_x, mouse_y, _sr2.x, _sr2.y, _sr2.x + _sr2.w, _sr2.y + _sr2.h)) continue;
		if (dp_stance != _sr2.key) { dp_stance = _sr2.key; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); }
		exit;
	}
	// a seat row: a press unseats it
	for (var _j = 0; _j < array_length(dp_slots); _j++) {
		if (dp_slots[_j] < 0) continue;
		var _mr2 = __dp_minus_r(_j);
		if (!point_in_rectangle(mouse_x, mouse_y, _mr2.x, _mr2.y, _mr2.x + _mr2.w, _mr2.y + _mr2.h)) continue;
		__dp_unseat(dp_slots[_j]);
		exit;
	}
	// the list: [+] seats a banner, [-] unseats it (the banner stays put); the banner itself opens its sheet
	for (var _k = 0; _k < array_length(g.sprites); _k++) {
		if (!__dp_row_in(_k)) continue;
		var _sp = g.sprites[_k];
		var _pr = __dp_plus_r(_k);
		if (point_in_rectangle(mouse_x, mouse_y, _pr.x, _pr.y, _pr.x + _pr.w, _pr.y + _pr.h)) {
			if (__dp_seat_of(_sp.id) >= 0) __dp_unseat(_sp.id); else __dp_seat(_sp.id);
			exit;
		}
		var _rr = __dp_row_r(_k);
		if (point_in_rectangle(mouse_x, mouse_y, _rr.x, _rr.y, _rr.x + _rr.w, _rr.y + _rr.h)) {
			// the sheet, as a modal over this page (his call: snappy, click off to close)
			dp_sheet = _sp.id; sheet_id = _sp.id; it_pop = undefined; it_rects = [];
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			exit;
		}
	}
	exit;
}

// ======================= THE HAUL: collect, or the recruit moment =======================
if (view == "haul") {
	var _hi = __haul_i();
	if (land && !swap_pick) { var _hlr = __hlog_r(); if (point_in_rectangle(mouse_x, mouse_y, _hlr.x, _hlr.y, _hlr.x + _hlr.w, _hlr.y + _hlr.h)) { hl_open = !hl_open; log_follow = true; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); exit; } }   // (2026-09-16)
	if (swap_pick) {
		// the roster: tap who retires
		for (var _k = 0; _k < array_length(g.sprites); _k++) {
			var _pr = __pick_r(_k);
			if (point_in_rectangle(mouse_x, mouse_y, _pr.x, _pr.y, _pr.x + _pr.w, _pr.y + _pr.h)) {
				var _sid = g.sprites[_k].id;
				exped_collect(_hi, room_width * .5, room_height * .5, "swap:" + string(_sid));
				swap_pick = false;
				__page_go("planet");
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
			__page_go("planet");
			play_sound_ext(snd_apply, 1, 1.2, .5, 1);
			exit;
		}
	} else {
		var _cb = __col_r();
		if (point_in_rectangle(mouse_x, mouse_y, _cb.x, _cb.y, _cb.x + _cb.w, _cb.y + _cb.h)) {
			exped_collect(_hi, room_width * .5, room_height * .5);
			__page_go("planet");
			play_sound_ext(snd_apply, 1, 1.2, .5, 1);
			exit;
		}
		// [SEND AGAIN] (2026-09-15): collect, wake this crew as they are (the
		// seat's rule), and off on the easiest open card
		var _ag = __again_r();
		if (point_in_rectangle(mouse_x, mouse_y, _ag.x, _ag.y, _ag.x + _ag.w, _ag.y + _ag.h)) {
			var _pl = __again_plan(_h);
			if (!_pl.ok) { play_sound_ext(snd_matclick2, .7, .8, .35, 0); exit; }
			var _rgi2 = _h[$ "rgi"] ?? 0, _dest2 = _h.dest;
			exped_collect(_hi, room_width * .5, room_height * .5);
			for (var _c = 0; _c < array_length(_pl.crew); _c++) { var _csp = _pl.crew[_c]; if (_csp.asleep) { _csp.asleep = false; _csp.hurt = 0; } }
			if (exped_start(_pl.di, _pl.crew, _pl.mode, _pl.pick, _rgi2, _h[$ "stance"] ?? "steady")) {   // (the haul's stance again)
				if (_pl.mode == "quest" && _pl.slot >= 0) exped_offer_take(_dest2, _rgi2, _pl.slot, g.exped.seq, _pl.pick);
				play_sound_ext(snd_apply, 1, 1.2, .5, 1);
			} else play_sound_ext(snd_matclick2, .7, .8, .35, 0);
			save_mark_dirty();
			__page_go("planet");
			exit;
		}
	}
	exit;
}

// ======================= THE TRIP: a fight can be stepped by hand =======================
if (view == "trip") {
	var _tr = __trip();
	// THE SHEET MODAL owns the page while it is up (the preparation page's rule):
	// its rows and popups, a press on it stays, a press off it closes it and goes on
	if (tp_sheet >= 0) {
		if (__sheet_tap()) exit;
		var _tsr = __tp_sheet_r();
		if (point_in_rectangle(mouse_x, mouse_y, _tsr.x, _tsr.y, _tsr.x + _tsr.w, _tsr.y + _tsr.h)) exit;
		tp_sheet = -1; it_pop = undefined; it_rects = [];
		play_sound_ext(snd_softclick, .95, 1.05, .4, 1);
	}
	// a tap on the replay's window skips the rest of it
	if (!is_undefined(rp)) {
		var _fw = __fight_r();
		if (point_in_rectangle(mouse_x, mouse_y, log_x, _fw.y, log_x + log_w, _fw.y + _fw.h)) {
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
	// [crew]: this trip's crew, in the crew menu (his ask: only the sprites on the quest)
	if (!is_undefined(_tr)) {
		var _tcr = __trip_crew_r();
		if (point_in_rectangle(mouse_x, mouse_y, _tcr.x, _tcr.y, _tcr.x + _tcr.w, _tcr.y + _tcr.h)) {
			crew_trip = _tr.id; sheet_id = _tr.sids[0]; __page_go("crew"); it_pop = undefined;
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
				// (the sheet as a modal here, not the crew menu - his ask, 2026-09-16)
				tp_sheet = _tr.sids[_k]; sheet_id = _tr.sids[_k]; it_pop = undefined; it_rects = [];
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

// ======================= THE HUB (went 2026-09-16 - the code stays behind this gate) =======================
if (view != "hub") exit;
// the list: a trip or a haul opens its page
var _rows = array_length(_e.hauls) + array_length(_e.trips);
for (var _i = 0; _i < _rows; _i++) {
	var _rr = __row_r(_i);
	if (!point_in_rectangle(mouse_x, mouse_y, _rr.x, _rr.y, _rr.x + _rr.w, _rr.y + _rr.h)) continue;
	if (_i < array_length(_e.hauls)) { view_id = _e.hauls[_i].id; __page_go("haul"); }
	else { view_id = _e.trips[_i - array_length(_e.hauls)].id; __page_go("trip"); }
	play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
	exit;
}
// [crew]: the roster
if (array_length(g.sprites) > 0) {
	var _shr = __crewbtn_r();
	if (point_in_rectangle(mouse_x, mouse_y, _shr.x, _shr.y, _shr.x + _shr.w, _shr.y + _shr.h)) {
		__page_go("crew"); crew_trip = -1; it_pop = undefined; crew_from = "hub";
		play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
		exit;
	}
}
// [galaxy]: the star map (his ask, 2026-09-15)
var _hgl = __hub_gal_r();
if (point_in_rectangle(mouse_x, mouse_y, _hgl.x, _hgl.y, _hgl.x + _hgl.w, _hgl.y + _hgl.h)) {
	gx_from = "hub"; __page_go("galaxy");
	play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
	exit;
}
var _hbs = __hub_best_r();
if (point_in_rectangle(mouse_x, mouse_y, _hbs.x, _hbs.y, _hbs.x + _hbs.w, _hbs.y + _hbs.h)) {
	bs_from = "hub"; __page_go("bestiary");
	play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
	exit;
}
// a world: its planet window
for (var _i = 0; _i < array_length(_e.board); _i++) {
	var _c = __card_r(_i);
	if (point_in_rectangle(mouse_x, mouse_y, _c.x, _c.y, _c.x + _c.w, _c.y + _c.h)) {
		sel_dest = _i; pl_dest = _e.board[_i]; rg_sel = 0; pl_focus = -1; __page_go("planet"); pv_mode = "planet"; pv_zoom = 1; pv_zuser = 1; pv_cfade = 1;
		play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
		exit;
	}
}
