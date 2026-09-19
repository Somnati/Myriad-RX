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
	if (is_struct(pv_sky) && is_array(pv_sky[$ "sibpd"])) planet_lite_step_list(pv_sky.sibpd, 1500);   // (the page's sky's sibling worlds, a slice a frame - q240)
	if (variable_global_exists("starmap") && is_struct(g.starmap)) galaxy_neb_sheet();
}   // (the nebula sheet bakes here, in the Step, never inside a page's target - 2026-09-16)
// ...and BEHIND THE SPRITE MENU (q256, his ask: "remove stutter so I can look at the crew stats while I wait"): the
// pending world, its tier and a system's stamps keep building at a share of the frame (__bg_step) - never a dropped
// frame, and the wait is spent somewhere useful. (The 2026-09-17 lag was the galaxy building whole in one frame -
// the galaxy_ready gate covers that; the chart itself charts at boot now, q256)
else if (mode == "sprites" && galaxy_ready()) __bg_step();
// THE REPLAY: a trip page with an unseen film (and no live fight)
// plays it in the combat window, a swing every half second; the last
// frame holds a moment, then it is seen. A tap on the window skips it
if ((view == "trip")) ex_trip_replay();  else rp = undefined;   // (ex_trip_replay - q220)
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
	// (the veil's work, nine ms a frame: the page's world and its zoom tier, or the system's stamps - q202)
	if (galaxy_ready() && mode != "sprites") { var _llim = get_timer() + 9000; while (get_timer() < _llim && is_struct(__loading())) { if (view == "system") __sy_lite_step(); else { __worlds_step(); __lod_step(); } } }
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
if (ex_planet_clock()) exit;   // (the orbit view's clock - ex_planet_clock, q219)
// THE TRIP PAGE'S WORLD: the same render, its camera turned to the trip's
// region once (a new trip on the page), riding the spin after (geosync)
if ((view == "trip")) ex_trip_world();   // (ex_trip_world - q220)
if (view != "planet") { pv_drag = false; pv_vx = 0; pv_vy = 0; }
// THE DIARY'S BAR: seated on the log's column while a diary shows, hidden
// otherwise; it follows the newest line unless you scrolled up
if ((view == "trip" || view == "haul")) ex_log_bar(_under);  else {   // (ex_log_bar - q220)
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
if ((view == "depart" && is_struct(pl_dest) && dp_sheet < 0)) ex_depart_list();   // (ex_depart_list - q220)
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
if (ex_planet_hold()) exit;   // (the orbit view under the hand - ex_planet_hold, q219)
// ======================= THE GALAXY VIEW: pan, zoom, tap a star =======================
if (ex_galaxy_step()) exit;   // (the galaxy view's step - ex_galaxy_step, q218)

// ======================= THE STAR SYSTEM VIEW (the demo's): orbit the camera, glide, the wheel's distance, the dive =======================
if (ex_system_step()) exit;   // (ex_system_step - q217)
// ======================= THE STATION PAGE (2026-09-17): drag to look round, a glide on release =======================
if (ex_station_step()) exit;   // (ex_station_step - q217)
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
if (ex_system_press()) exit;   // (ex_system_press - q217)
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
if ((view == "bestiary")) { if (ex_bestiary_press()) exit; }   // (ex_bestiary_press - q220)

if ((view == "crew")) { if (ex_crew_press()) exit; }   // (ex_crew_press - q220)

// ======================= THE MAP: [legend] =======================
if ((view == "map")) { if (ex_map_press()) exit; }   // (ex_map_press - q220)

// ======================= THE PLANET PAGE: its buttons, the drawer =======================
// (the grab / drag / tap are above the press gate)
if (ex_planet_press(_e)) exit;   // (the planet page's presses - ex_planet_press, q219)
// ======================= THE GALAXY: presses do nothing here (the pan / tap are above) =======================
if (view == "galaxy") exit;

// (the region window is gone - the planet page's region mode, 2026-09-15)

// ======================= THE DEPARTURE: [+] / [-], a banner = its sheet, [depart] =======================
if ((view == "depart")) { if (ex_depart_press(_e)) exit; }   // (ex_depart_press - q220)

// ======================= THE HAUL: collect, or the recruit moment =======================
if ((view == "haul")) { if (ex_haul_press(_e)) exit; }   // (ex_haul_press - q220)

// ======================= THE TRIP: a fight can be stepped by hand =======================
if ((view == "trip")) { if (ex_trip_press()) exit; }   // (ex_trip_press - q220)

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
