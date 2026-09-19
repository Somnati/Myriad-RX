/// @description ex_planet_init() - THE PLANET PAGE of syst_exped_panel (the orbit view and its region mode): its state (pv_* the view, rg_* region mode, tp_* the trip page's camera), its rectangles (the drawer, the tabs, the rows, the buttons), the hand's seats and cards, and the pick - defined on the panel (self = the panel; called from its Create). q219, the deconvolution
function ex_planet_init() {
pv_mat_m = [1, 0, 0, 0, 1, 0, 0, 0, 1];   // texture-from-view, published by the draw for the step's pick
pv_mat_r = [1, 0, 0, 0, 1, 0, 0, 0, 1];   // ...and its inverse (the spots)
pv_mode  = "planet";                 // "planet" (the world, the drawer) or "region" (pulled in on the pick: the banner, the quests)
pv_zoom  = 1;                        // region mode's pull-in (PV_ZOOM_RG) x the hand's wheel, eased
pv_zuser = 1;                        // THE WHEEL's zoom (2026-09-17): PV_ZOOM_MIN..PV_ZOOM_MAX, on top of the mode's pull-in; a fresh world starts at 1
pv_cfade = 1;                        // ...and the clouds thinning with it
pv_pfade = 1;                        // ...the volcanoes' plumes thinning later (2026-09-17)
// the trip page's world: the same render, the camera fixed on the trip's region
tp_id = -1; tp_cam = mat3_rot(1, 0, 0, -32); tp_spin = 0;
tp_sheet = -1;   // THE SHEET MODAL on the trip page (his ask, 2026-09-16): the sprite shown (-1 = none) - a banner opens it, in place of the crew menu
__tp_sheet_r = function() { if (land) return { x : log_x, y : log_y, w : log_w, h : room_height - 8 - log_y }; return { x : 4, y : list_y + 22, w : room_width - 8, h : room_height - 8 - (list_y + 22) }; };   // over the log column (wide) / the page (portrait)
sky_fog_surf = -1;                   // sh_sky_fog's canvas (the page's size)
__pv_r     = function() { return { x : 0, y : list_y, w : room_width, h : room_height - list_y }; };   // (from the strip down - his ask, 2026-09-15: no gap over the sky)
__pv_c     = function() { var _r = __pv_r(); return { x : _r.x + _r.w * .5 - 46 * pv_dwa, y : _r.y + _r.h * .5 + 2 }; };   // (the world slides left as the drawer opens)
__pv_dw_w  = function() { return land ? 150 : 120; };
__pv_dw_x  = function() { return room_width - 9 - __pv_dw_w() * pv_dwa; };   // the drawer's left edge (its tab)
__pv_tab_r = function() { return { x : __pv_dw_x(), y : list_y + 22, w : 9, h : 60 }; };
__pv_box_r = function() { var _x = __pv_dw_x() + 9; return { x : _x, y : list_y + 16, w : room_width - _x, h : room_height - 30 - (list_y + 16) }; };   // the drawer's box (the outline, his ask 2026-09-16)
__pv_dtab_r = function(_i) { var _w = floor((__pv_dw_w() - 8 - 3) / 2); return { x : __pv_dw_x() + 13 + _i * (_w + 3), y : list_y + 20, w : _w, h : 22 }; };   // the two tabs at the top
__pv_row_r = function(_i) { return { x : __pv_dw_x() + 13, y : list_y + 48 + _i * 26, w : __pv_dw_w() - 8, h : 24 }; };
__pv_trip_r = function(_k) { return { x : __pv_dw_x() + 13, y : list_y + 48 + _k * 14, w : __pv_dw_w() - 8, h : 12 }; };   // THE EXPEDITIONS on their own tab (2026-09-16): hauls first, then trips   // THE EXPEDITIONS in the drawer (the hub's list moved here, 2026-09-16): hauls first, then trips
__best_r = function() { var _g = __galaxy_r(); return { x : _g.x, y : _g.y - 40, w : _g.w, h : 16 }; };   // [bestiary] over [star system] (planet mode; the geosync toggle went - his call 2026-09-16)
__system_r = function() { var _g = __galaxy_r(); return { x : _g.x, y : _g.y - 20, w : _g.w, h : 16 }; };   // [star system] over [galaxy] (his ask, 2026-09-16)
// THE BUTTON COLUMNS (his ask, 2026-09-15): bottom left, stacked - [galaxy]
// at the foot, the geosync toggle over it ([region map] sat between them in
// region mode until 2026-09-16 - it is [map] in the strip now); bottom
// right in region mode - [quests] over [explore]
__galaxy_r = function() { return { x : land ? 14 : 4, y : room_height - 8 - 16, w : land ? 90 : 70, h : 16 }; };
__explore_r = function() { var _w = land ? 96 : 60; return { x : room_width - (land ? 14 : 4) - _w + (1 - rg_in) * 140, y : room_height - 8 - 16, w : _w, h : 16 }; };   // (region mode's swing: in from the right)
__quests_r  = function() { var _x = __explore_r(); return { x : _x.x, y : _x.y - 20, w : _x.w, h : 16 }; };
// region mode: the info box on the left (region_info's lines)
rg_box_w = 150; rg_box_h = 110;      // the info box's size, as its lines want (__info_box_size; the Draw keeps it fresh)
rg_box_open = false; rg_box_a = 0;   // THE FOLD (his ask, 2026-09-16): shut = the first lines at their own width; open = every line at the longest's; eased
__rg_banner_r = function() { return { x : (land ? 14 : 4) - (1 - rg_in) * 220, y : list_y + 22, w : rg_box_w, h : rg_box_h }; };   // (where the world box sits: a swap in place; clear of the toggle below - 2026-09-16)   // (region mode's swing: in from the left)
// THE HAND'S SEATS: the cards in a row across the page (portrait: two columns)
__hand_seats = function(_n) {
	var _out = [];
	var _pv = __pv_r();
	if (land) {
		var _pitch = min(92, floor((room_width - 24 - 84) / max(1, _n - 1))), _x0 = room_width * .5 - (_n - 1) * .5 * _pitch, _y = _pv.y + _pv.h * .5 - 6;   // (a little high: the clock sits under the card; six fit closer - the personal card, 2026-09-16)
		for (var _i = 0; _i < _n; _i++) array_push(_out, { x : floor(_x0 + _i * _pitch), y : floor(_y) });
	} else {
		var _x0 = room_width * .5 - 33, _y0 = _pv.y + 42;
		for (var _i = 0; _i < _n; _i++) array_push(_out, { x : floor(_x0 + (_i mod 2) * 66), y : floor(_y0 + (_i div 2) * 80) });
	}
	return _out;
};
/// a quest / explore card's face (self = the card; face = what it says)
__qcard_face = function() {
	draw_clear_alpha(c_black, 1);
	var _col = face.col;
	draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, 0, 0, card_w, card_h, 0, merge_colour(_col, c_black, .8), merge_colour(_col, c_black, .8), c_black, c_black, 1);
	draw_px_rect(1, 1, card_w - 2, card_h - 2, _col, .9);
	draw_set_halign(fa_center); draw_set_valign(fa_top);
	var _big = (card_w >= 80);
	var _tw = card_w - 8;
	// the title: the place (a quest) or the card's name (an explore), in its kind's colour
	draw_set_font(_big ? fnt_large : fnt);
	if (string_width(face.title) > _tw) draw_set_font(fnt);
	draw_set_color(_col); draw_set_alpha(1);
	var _ty = _big ? 6 : 4;
	var _tsep = (draw_get_font() == fnt_large) ? 12 : 9;
	draw_text_ext(card_w * .5, _ty, str_cap(face.title), _tsep, _tw);
	_ty += string_height_ext(face.title, _tsep, _tw) + 2;
	draw_set_font(fnt);
	draw_set_color(merge_colour(_col, c_white, .4)); draw_set_alpha(.7);
	draw_text(card_w * .5, _ty, face.sub);
	_ty += 10;
	// the hazard, in its colour (2026-09-15)
	if (is_struct(face[$ "haz"])) { draw_set_color(face.haz.col); draw_set_alpha(.95); draw_text(card_w * .5, _ty, face.haz.name); _ty += 10; } else _ty += 2;
	// the objective
	draw_set_color(c_white); draw_set_alpha(.92);
	draw_text_ext(card_w * .5, _ty, face.txt, 9, card_w - 10);
	// THE FOOT, in a black box (his ask): the difficulty (or an explore's
	// span), then the hours / the credits (lavender) / the xp (green)
	var _dc = [c_sgreen, c_gold, c_horange, c_hred];
	var _fh = _big ? 30 : 26;
	draw_sprite_ext(spr_pixel_1x1, 0, 2, card_h - 2 - _fh, card_w - 4, _fh, 0, c_black, .88);
	draw_sprite_ext(spr_pixel_1x1, 0, 2, card_h - 2 - _fh, card_w - 4, 1, 0, _col, .5);
	var _f1 = card_h - 2 - _fh + 3, _f2 = card_h - 2 - _fh + (_big ? 15 : 13);
	var _sl = face[$ "slot"];
	if (!is_undefined(face[$ "diff_txt"])) {
		draw_set_color(_dc[clamp(face.diff, 0, 3)]); draw_set_alpha(.95);
		draw_text(card_w * .5, _f1, face.diff_txt);
	} else if (!is_undefined(face[$ "foot"])) {
		draw_set_color(merge_colour(_col, c_white, .5)); draw_set_alpha(.8);
		draw_text(card_w * .5, _f1, face.foot);
	}
	if (!is_undefined(face[$ "hrs"])) {
		var _sep = "  -  ";
		var _wall = string_width(face.hrs + _sep + face.cr + _sep + face.xp);
		var _fx = card_w * .5 - _wall * .5;
		draw_set_halign(fa_left);
		draw_set_color(sett_ink); draw_set_alpha(.85); draw_text(_fx, _f2, face.hrs + _sep); _fx += string_width(face.hrs + _sep);
		draw_set_color(c_lavender); draw_set_alpha(.95); draw_text(_fx, _f2, face.cr); _fx += string_width(face.cr);
		draw_set_color(sett_ink); draw_set_alpha(.85); draw_text(_fx, _f2, _sep); _fx += string_width(_sep);
		draw_set_color(c_sgreen); draw_set_alpha(.95); draw_text(_fx, _f2, face.xp);
		draw_set_halign(fa_center);
	} else if (!is_undefined(face[$ "meta"])) {
		draw_set_color(sett_ink); draw_set_alpha(.75);
		draw_text(card_w * .5, _f2, face.meta);
	}
	// taken: who is on it, over the objective
	if (is_struct(_sl) && _sl.taken != 0) {
		var _who = "returned";
		for (var _t = 0; _t < array_length(g.exped.trips); _t++) if (g.exped.trips[_t].id == _sl.taken) _who = exped_crew_txt(g.exped.trips[_t].names);
		if (_sl.taken < 0 && is_struct(pl_dest)) { var _rvf = exped_rivals(pl_dest); _who = _rvf[clamp(-_sl.taken - 1, 0, array_length(_rvf) - 1)].name; }   // (a rival crew's, 2026-09-16)
		draw_set_color(c_steelblue); draw_set_alpha(.95);
		draw_text_ext(card_w * .5, card_h - 2 - _fh - 20, "taken  -  " + _who, 9, _tw);
	}
	// taken: the face goes dark under a stamp
	if (is_struct(_sl) && _sl.taken != 0) {
		draw_sprite_ext(spr_pixel_1x1, 0, 0, 0, card_w, card_h, 0, c_black, .5);
		draw_set_font(_big ? fnt_large : fnt);
		draw_set_color(c_steelblue); draw_set_alpha(.9);
		draw_text(card_w * .5, card_h * .5 - 6, "taken");
		draw_set_font(fnt);
	}
	draw_set_halign(fa_left); draw_set_alpha(1);
};
__qcard_back = function() {
	draw_clear_alpha(rgb(12, 22, 36), 1);
	draw_px_rect(1, 1, card_w - 2, card_h - 2, face.col, .8);
	draw_px_rect(5, 5, card_w - 10, card_h - 10, face.col, .3);
	draw_set_halign(fa_center);
	draw_set_font(fnt_large);
	draw_set_color(face.col); draw_set_alpha(.9);
	draw_text(card_w * .5, card_h * .5 - 5, "?");
	draw_set_font(fnt);
	draw_set_halign(fa_left); draw_set_alpha(1);
};
/// the hand dealt: the region's quests, or the explore cards
__hand_open = function(_kind) {
	__hand_close();
	if (!is_struct(pl_dest)) return;
	var _rg = region_get(pl_dest, rg_sel);
	var _kk = region_kinds();
	var _faces = [];
	if (_kind == "quests") {
		var _sl = exped_region_quests(pl_dest, rg_sel);
		for (var _i = 0; _i < array_length(_sl); _i++) {
			var _q = _sl[_i].q;
			var _nd = _rg.nodes[clamp(_q[$ "p0"] ?? _q.node, 0, array_length(_rg.nodes) - 1)];   // (the card's place: the first stop, 2026-09-15)
			var _kd = _kk[$ _nd.kind];
			var _obj = exped_quest_obj(_q, _rg, false);
			array_push(_faces, { title : _nd.name, sub : (((_sl[_i][$ "pers"] ?? false) ? "personal  -  " : "") + (is_struct(_kd) ? _kd.name : _nd.kind)), col : is_struct(_kd) ? _kd.col : c_gold, txt : _obj, haz : region_hazard_at(pl_dest, _rg, _nd.kind),   // (a personal card says so; the season's hazard - 2026-09-16)
			                     diff : _q.diff, diff_txt : _q.diff_txt, hrs : string(_q.hours) + "h", cr : string(_q.reward) + " cr", xp : string(sprite_xp_quest(_q.lv, 1, _q.mult)) + " xp",   // (the xp in xp - his ask: "x3" meant nothing)
			                     slot : _sl[_i], si : _i, hours : _q.hours, salt0 : _sl[_i].salt });
		}
		// easiest to hardest, left to right (his call); the shorter road first among equals
		array_sort(_faces, function(_a, _b) { return (_a.diff != _b.diff) ? (_a.diff - _b.diff) : (_a.hours - _b.hours); });
	} else {
		var _xc = exped_explore_cards(pl_dest, rg_sel);
		for (var _i = 0; _i < array_length(_xc); _i++) {
			var _c = _xc[_i];
			array_push(_faces, { title : _c.name, sub : "explore", col : c_horange, txt : _c.txt,
			                     foot : (_c.ex == "wander") ? "until recalled" : ((_c.ex == "ramble") ? ("about " + string(_c.n) + "h") : (string(_c.n) + " places")),
			                     meta : "xp by the hours out", card : _c, si : -1 });
		}
	}
	// THE THROW (his ask: "thrown in from the bottom starting from the
	// middle and quickly finding their place... snappy"): every card starts
	// under the bottom edge at the middle, the middle seat is dealt first
	// and the rest outward, each a few frames behind; the Step snaps them
	// to their seats (no finishes on these - his call)
	var _seats = __hand_seats(array_length(_faces));
	var _mid = (array_length(_faces) - 1) * .5;
	for (var _i = 0; _i < array_length(_faces); _i++) {
		var _c = create_obj(room_width * .5, room_height + 70, obj_card);
		_c.depth = depth - 3;   // over the panel, under the menu's blur (-515)
		_c.auto = false;
		if (!land) { _c.card_w = 60; _c.card_h = 76; }
		_c.face = _faces[_i];
		_c.draw_front_content = method(_c, __qcard_face);
		_c.draw_back_content  = method(_c, __qcard_back);
		_c.seat = _seats[_i];
		_c.settled = false;
		_c.throw_delay = abs(_i - _mid) * 4;
		_c.visible = false;
		_c.rot_y = 0;
		_c.rot_x = 42;
		_c.rot_z = -(_seats[_i].x - room_width * .5) * .12;
		_c.fx = 0;
		_c.invalidate_front(); _c.invalidate_back();
		array_push(hand_ids, _c);
	}
	hand = _kind; hand_a = 0; hand_sec = -1;
	play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
};
__hand_close = function() {
	for (var _i = 0; _i < array_length(hand_ids); _i++) if (instance_exists(hand_ids[_i])) instance_destroy(hand_ids[_i]);
	hand_ids = []; hand = ""; hand_a = 0; hand_out = false;
};
/// THE FOLD (his ask: "the cards go back into their deck"): every card
/// flies back down to the bottom middle, the outer ones first, and the
/// veil lifts with them; the Step destroys each as it leaves the screen
__hand_fold = function() {
	if (hand == "" || hand_out) return;
	hand_out = true;
	var _n = array_length(hand_ids), _mid = (_n - 1) * .5;
	for (var _i = 0; _i < _n; _i++) {
		var _c = hand_ids[_i];
		if (!instance_exists(_c)) continue;
		_c.seat = { x : room_width * .5, y : room_height + 70 };
		_c.settled = false;
		_c.throw_delay = (_mid - abs(_i - _mid)) * 3;
		_c.rot_x = 0;
	}
	play_sound_ext(snd_softclick, .95, 1.05, .4, 1);
};
/// a card tapped: the departure (a taken quest says no)
__hand_pick = function(_i) {
	if (_i < 0 || _i >= array_length(hand_ids)) return;
	var _f = hand_ids[_i].face;
	if (hand == "quests") {
		if (_f.slot.taken != 0) { play_sound_ext(snd_matclick2, .7, .8, .35, 0); return; }
		dp_quest = _f.slot.q; dp_mode = "quest"; dp_slot = _f.si;   // (the SLOT's index - the cards are sorted)
	} else {
		dp_quest = _f.card; dp_mode = "explore"; dp_slot = -1;
	}
	dp_look = -1;
	__hand_close();
	dp_in = 0; dp_dir = 0;
	__page_go("depart");
	play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
};
__hub_gal_r = function() { var _c = __crewbtn_r(); return { x : _c.x + ((array_length(g.sprites) > 0) ? (_c.w + 4) : 0), y : _c.y, w : 50, h : 14 }; };
/// a region's spot as a unit vector in TEXTURE space (sphere_uv's frame)
__spot_dir = function(_lon, _lat) { return [dcos(_lat) * dcos(_lon), dsin(_lat), dcos(_lat) * dsin(_lon)]; };
/// THE GROUND UNDER A SPOT (his report, 2026-09-16: "the land shifts when i
/// rotate"): the shader paints the terrain at 1 + relief x h - the mountains
/// stand off the sphere in true parallax - so a spot projected on the unit
/// sphere watched its land slide sideways toward the limb. This is the
/// bake's height at the spot's texel (the same curve the shader marches:
/// (elev - base) / (1 - base), to the 1.6) times the relief the render was
/// given - the spot's radius, so marker and land move as one
__spot_r = function(_pn, _lon, _lat) {
	if (_pn.row < _pn.th || _pn.kind == "gas") return 1;
	var _bump = (variable_global_exists("planet_relief_pct") ? g.planet_relief_pct : 140) / 100;
	var _relf = planet_config().relief * max(.4, _bump);
	var _tx = floor(frac(_lon / 360 + .5 + 1) * _pn.tw) mod _pn.tw, _ty = clamp(floor((90 - _lat) / 180 * _pn.th), 0, _pn.th - 1);
	var _base = max(_pn.sea, .34);
	var _h = power(clamp((_pn.elev[_tx + _ty * _pn.tw] - _base) / max(.001, 1 - _base), 0, 1), 1.6);
	return 1 + _relf * _h;
};
/// a press on one of the page's controls is not a grab of the world
__pv_ui_hit = function() {
	var _bk = __back_r(); if (point_in_rectangle(mouse_x, mouse_y, _bk.x, _bk.y, _bk.x + _bk.w, _bk.y + _bk.h)) return true;
	var _cs = __crewstrip_r(); if (point_in_rectangle(mouse_x, mouse_y, _cs.x, _cs.y, _cs.x + _cs.w, _cs.y + _cs.h)) return true;
	var _g = __galaxy_r(); if (point_in_rectangle(mouse_x, mouse_y, _g.x, _g.y, _g.x + _g.w, _g.y + _g.h)) return true;
	if (pv_mode == "planet") { var _bsr = __best_r(); if (point_in_rectangle(mouse_x, mouse_y, _bsr.x, _bsr.y, _bsr.x + _bsr.w, _bsr.y + _bsr.h)) return true; }   // ([bestiary], 2026-09-16)
	if (pv_mode == "region") {
		var _bn = __rg_banner_r(); if (point_in_rectangle(mouse_x, mouse_y, _bn.x, _bn.y, _bn.x + _bn.w, _bn.y + _bn.h)) return true;
		var _qb = __quests_r(); if (point_in_rectangle(mouse_x, mouse_y, _qb.x, _qb.y, _qb.x + _qb.w, _qb.y + _qb.h)) return true;
		var _xb = __explore_r(); if (point_in_rectangle(mouse_x, mouse_y, _xb.x, _xb.y, _xb.x + _xb.w, _xb.y + _xb.h)) return true;
		return false;
	}
	if (pl_focus >= 0) { var _v = __view_rg_r(); if (point_in_rectangle(mouse_x, mouse_y, _v.x, _v.y, _v.x + _v.w, _v.y + _v.h)) return true; }
	if (mouse_x >= __pv_dw_x() && mouse_y < room_height - 30) return true;   // the tab and the drawer (the button row under it stays live)
	return false;
};
/// a region picked on the planet page (a tap on its spot, or its row): the
/// camera turns to face it, the region window's small world too
/// NO LANDING (his call (b), 2026-09-18): a gas giant has no ground - its regions were a rock world's forests (region_gen
/// only reads rock terrain). Viewable in orbit; no spots, no region mode, no pick, no departure - until the cloud cities
__nolanding = function(_d) { return is_struct(_d) && (_d[$ "biome"] ?? 0) == 8; };
__pv_pick = function(_i) {
	if (__nolanding(pl_dest)) return;   // (no ground to pick - q243)
	rg_sel = _i; pl_focus = _i; pv_face = _i;
	pv_vx = 0; pv_vy = 0;   // (the tap's own glide would fight the snap - "jitters back and forth", his report 2026-09-17)
	play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
};
}
