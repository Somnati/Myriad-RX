/// syst_exped_panel - THE EXPEDITIONS (the mock, his go 2026-09-12;
/// the HUB + DETAIL shape, parties, the combat window, 2026-09-13).
/// Three views in one panel, `view`:
///   "hub"   the destinations on offer, the crew (tap up to EXPED_PARTY
///           to pick a party), and THE LIST of every expedition out and
///           every haul waiting - tap one to open it
///   "trip"  one trip: the world big, the crew's hp, the stage track,
///           the DIARY, and while a fight is on THE COMBAT WINDOW - a
///           small square where it plays out a turn a second (the
///           crew's dots, the foe, hp bars, a flash on each hit)
///   "map"   a world's REGION, the debug map (his ask, 2026-09-14: "so i can
///           see what the sprites are able to explore"): the nodes by
///           kind, the edges with their hours, the landing zone, who is
///           out to it. [map] on a world card, [map] on a trip's page
///   "crew"  every sprite, a row each (his ask, 2026-09-14): name / class /
///           level / hp, the eight stats, what is worn; scrolls (wheel or
///           drag); tap a row for its sheet. [crew] in the hub
///   "sheet" one sprite's sheet (2026-09-14): class, level + xp, the eight
///           stats with the gear's share, the slots and what is worn, the
///           pocket, the skills; [<] [>] browse the roster. From the hub's
///           [sheet] (the picked sprite) or a crew row on a trip's page
///   "haul"  a returned crew's card: the finds and [collect] - or, when
///           a found sprite would be the eleventh, THE RECRUIT MOMENT:
///           [swap] (pick who retires) or [let go]
/// [back] returns to the hub from either. On the overlay contract every
/// panel shares. The data is g.exped (exped_init); this is pure view.

exped_init();
depth   = -510;
oa      = 0;
closing = false;
opaque  = true;

hh = instance_exists(obj_ui_header) ? obj_ui_header.bar_h : 16;
strip_y = hh; list_y = hh + 16;
land = (room_width > 300);
dim  = rgb(120, 130, 150);

view    = "hub";     // hub / trip / haul
view_id = -1;        // the trip's or haul's id
rp      = undefined; // the combat window's REPLAY of a fight that ended off screen: { i, t, r : the film }
seen_live = "";      // "tripid:room" of a fight watched live here - it is not replayed after
sheet_id = -1;       // the sheet view's sprite (his pitch, 2026-09-14: class / level / gear)
map_dest = undefined;    // the map view's world (its region: region_get)
map_from = "hub";        // where the map returns to
pl_dest  = undefined;    // the planet window's world
rg_sel   = 0;            // the region picked in the planet window (EXPED_REGIONS a world)
map_rgi  = 0;            // the map view's region
pl_focus = -1;           // the planet window: the region the world has turned to (-1 = none, ambient spin)
crew_trip = -1;          // the crew menu shows only this trip's crew (-1 = everyone)
crew_from = "hub";       // where the crew menu returns to (the strip's [crew] is on every page - his ask, 2026-09-15)
it_pop   = undefined;    // the item popup: { it, sp, worn : bool, x, y }
it_rects = [];           // the sheet's item rows, laid down by the Draw for the Step's taps: { x, y, w, h, it, worn }
dp_quest = undefined;    // the departure window's quest (undefined = an explore)
dp_look  = -1;           // the departure window's INSPECTED sprite (the last chip tapped): its sheet in brief under the chips
__dlook_r = function() { var _rows = max(1, ceil(array_length(g.sprites) / (land ? 5 : 6))); var _y = dchip_y + _rows * (chip + 10) + 2; return { x : land ? 14 : 4, y : _y, w : land ? 156 : (room_width - 8), h : room_height - 8 - _y }; };
dp_mode  = "quest";      // ...and its mode
dp_slot  = -1;           // ...and the offer slot it came from (exped_offer_take on departure; -1 = none / an explore)
// THE HAND (his ask, 2026-09-15: "put the quests on the cards we have"):
// "" / "quests" / "explore" while the cards are up, the obj_card
// instances, the veil's ease, the second the faces were last repainted
// (their clocks are live text)
hand = ""; hand_ids = []; hand_a = 0; hand_sec = -1;
hand_out = false;                    // the hand folding back into the deck (the cards fly down, the veil lifts)
// THE PAGE TURN (his ask: "a fade in animation when i click a quest and
// it takes me to the expedition prep room"): the view coming, the light
// (1 = lit; it goes to black, the view turns, it comes back), the direction
pg_next = ""; pg_a = 1; pg_dir = 0;
__page_go = function(_v) { pg_next = _v; pg_dir = -1; };
/// the turn's veil over the page (under the strip), for the pages that turn
__draw_turn = function() {
	if (pg_a >= .999) return;
	var _fa = g.ui_fade_a;
	ui_fade_set(1);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, list_y, room_width, room_height - list_y, 0, c_black, 1 - pg_a);
	ui_fade_set(_fa);
};
crew_off = 0;        // the crew list's scroll (px)
crew_drag = undefined;   // { y0, off0, moved } while a finger drags the list
sel_dest = 0;        // the world picked (one on the board, his call: always the first)
sel_crew = [];       // sprite ids picked for the party, in order
swap_pick = false;   // the recruit moment's roster list is up

// ---- the hub's layout ----
// destinations: three cards across the left; the crew under them; the
// list of expeditions down the right (portrait: everything stacks)
card_w = land ? 150 : (room_width - 8); card_h = land ? 96 : 84;   // ONE world: a wide card with its quest (2026-09-14)
card_gap = land ? 6 : 3;
card_x0 = land ? 14 : 4;
card_y  = list_y + 14;                 // under the "worlds on offer" label
crew_y  = card_y + card_h + 10;
chip    = land ? 24 : 18; chip_gap = land ? 4 : 2;
list_x  = land ? (card_x0 + card_w + 14) : 4;
list_w  = land ? (room_width - list_x - 10) : (room_width - 8);
row_h   = land ? 36 : 30;

// ---- the trip view ----
big_x = land ? 14 : 4; big_y = list_y + 20; big_w = land ? 150 : (room_width - 8); big_h = land ? 106 : 66;   // the world box holds the render only (2026-09-15: the banners moved under it)
log_x = land ? (big_x + big_w + 12) : 4; log_w = land ? (room_width - log_x - 12) : (room_width - 8);
log_y = land ? big_y : (big_y + big_h + 22 + EXPED_PARTY * 12 + 4);   // (portrait: the button row and the banners under the box come first)
fight_s = 64;        // the combat window's side
wb_surf = -1;        // the page surfaces (__draw_orbit, the galaxy view): nothing spills past a rect; freed in the CleanUp
// THE CONFIRM POPUP (the save menu's shape, his ask 2026-09-15: abort asks first)
confirm  = "";       // "abort" while the question is up
conf_a   = 0;
conf_hot = 0;
__conf_rect = function() {
	var _w = min(room_width - 16, 230), _h = 74;
	return { x : floor((room_width - _w) * .5), y : floor((room_height - _h) * .5), w : _w, h : _h };
};
__conf_btns = function() {
	var _r = __conf_rect();
	var _bw = 84, _bh = 18, _g = 8;
	var _x0 = _r.x + floor((_r.w - _bw * 2 - _g) * .5);
	return [ { x : _x0, y : _r.y + _r.h - _bh - 8, w : _bw, h : _bh, id : "ok" },
	         { x : _x0 + _bw + _g, y : _r.y + _r.h - _bh - 8, w : _bw, h : _bh, id : "cancel" } ];
};

// ---- the shader's handles ----
u_quad  = shader_get_uniform(sh_planet_lite, "u_quad");
u_cells = shader_get_uniform(sh_planet_lite, "u_cells");
u_col1  = shader_get_uniform(sh_planet_lite, "u_col1");
u_col2  = shader_get_uniform(sh_planet_lite, "u_col2");
u_col3  = shader_get_uniform(sh_planet_lite, "u_col3");
u_sea   = shader_get_uniform(sh_planet_lite, "u_sea");
u_seed  = shader_get_uniform(sh_planet_lite, "u_seed");
u_time  = shader_get_uniform(sh_planet_lite, "u_time");
u_light = shader_get_uniform(sh_planet_lite, "u_light");

/// a world's portrait: a raycast sphere in the biome's colours,
/// turning slowly, seeded by the destination
__portrait = function(_d, _cx, _cy, _r) {
	var _b = exped_biomes()[_d.biome];
	var _qs = ceil(_r * 2 * 1.2) + 2;   // the quad holds the disc AND its halo (the shader maps the disc to 1/1.2 of it)
	var _qx = _cx - _qs * .5, _qy = _cy - _qs * .5;
	shader_set(sh_planet_lite);
	shader_set_uniform_f(u_quad, _qx, _qy, _qs, _qs);
	shader_set_uniform_f(u_cells, _qs);
	shader_set_uniform_f(u_col1, colour_get_red(_b.col1) / 255, colour_get_green(_b.col1) / 255, colour_get_blue(_b.col1) / 255);
	shader_set_uniform_f(u_col2, colour_get_red(_b.col2) / 255, colour_get_green(_b.col2) / 255, colour_get_blue(_b.col2) / 255);
	shader_set_uniform_f(u_col3, colour_get_red(_b.col3) / 255, colour_get_green(_b.col3) / 255, colour_get_blue(_b.col3) / 255);
	shader_set_uniform_f(u_sea, _b.sea);
	shader_set_uniform_f(u_seed, (_d.seed mod 100000));
	shader_set_uniform_f(u_time, ((current_time mod 200000) / 1000) * .15 + (_d.seed mod 360));
	shader_set_uniform_f(u_light, -.5, -.55, .67);
	draw_sprite_stretched(spr_pixel_1x1, 0, _qx, _qy, _qs, _qs);
	shader_reset();
};

/// a sprite's mark: its body as a dot in its colour (the crew chips,
/// the list's faces, the combat window)
__dot = function(_x, _y, _r, _col, _a) {
	draw_sprite_ext(spr_pixel_1x1, 0, _x - _r + 1, _y - _r, _r * 2 - 2, _r * 2, 0, _col, _a);
	draw_sprite_ext(spr_pixel_1x1, 0, _x - _r, _y - _r + 1, _r * 2, _r * 2 - 2, 0, _col, _a);
};

// ---- the region law: the Step's hits and the Draw share these ----
__card_r = function(_i) { return { x : card_x0 + _i * (card_w + card_gap), y : card_y, w : card_w, h : card_h }; };
__list_y0 = function() { return land ? (card_y - 10) : (crew_y + 10 + 2 * (chip + 10) + 2 + 14 + 8); };   // (portrait: under where the hub's crew rows sat)
__row_r  = function(_i) { return { x : list_x, y : __list_y0() + 12 + _i * (row_h + 3), w : list_w, h : row_h }; };
__spd_r  = function(_k) { return { x : room_width - 8 - 3 * 28 + _k * 28, y : strip_y + 2, w : 26, h : 12 }; };
__back_r = function() { return { x : room_width - (land ? 14 : 4) - 44, y : list_y + 3, w : 44, h : 13 }; };   // on the RIGHT (his ask, 2026-09-15: the titles sit left)
__crewstrip_r = function() { var _b = __back_r(); return { x : _b.x - 4 - 44, y : _b.y, w : 44, h : 13 }; };   // [crew] beside [back], on every page but the hub's and the crew's own
/// [back] and [crew] painted (the pages that render a sky call it again AFTER the sky - the render plane covers the row)
__draw_back = function() {
	var _bk = __back_r();
	draw_sprite_ext(spr_pixel_1x1, 0, _bk.x, _bk.y, _bk.w, _bk.h, 0, c_black, .8);
	draw_px_rect(_bk.x, _bk.y, _bk.w, _bk.h, rgb(170, 190, 230), .5);
	draw_set_halign(fa_center);
	draw_set_color(c_white);
	draw_set_alpha(.9);
	draw_text(_bk.x + _bk.w * .5, _bk.y + 3, "back  >");
	if (view != "crew" && view != "hub" && array_length(g.sprites) > 0) {
		var _cs = __crewstrip_r();
		draw_sprite_ext(spr_pixel_1x1, 0, _cs.x, _cs.y, _cs.w, _cs.h, 0, c_black, .8);
		draw_px_rect(_cs.x, _cs.y, _cs.w, _cs.h, c_steelblue, .5);
		draw_set_color(c_steelblue);
		draw_text(_cs.x + _cs.w * .5, _cs.y + 3, "crew");
	}
	draw_set_halign(fa_left);
};
/// the camera that faces a region's spot dead on (a still portrait: the
/// haul card, the list rows), the world's axis up the screen
__cam_at = function(_pn, _spin, _rg) {
	var _wm = mat3_mul(mat3_rot(0, 0, 1, _pn.tilt), mat3_rot(0, 1, 0, _spin));
	var _t = __spot_dir(_rg.spot.lon, _rg.spot.lat);
	var _z = mat3_apply(_wm, _t[0], _t[1], _t[2]);
	var _up = mat3_apply(mat3_rot(0, 0, 1, _pn.tilt), 0, 1, 0);
	var _x = [_up[1] * _z[2] - _up[2] * _z[1], _up[2] * _z[0] - _up[0] * _z[2], _up[0] * _z[1] - _up[1] * _z[0]];
	var _xl = sqrt(_x[0] * _x[0] + _x[1] * _x[1] + _x[2] * _x[2]);
	if (_xl < .001) { _up = [1, 0, 0]; _x = [_up[1] * _z[2] - _up[2] * _z[1], _up[2] * _z[0] - _up[0] * _z[2], _up[0] * _z[1] - _up[1] * _z[0]]; _xl = sqrt(_x[0] * _x[0] + _x[1] * _x[1] + _x[2] * _x[2]); }
	_x = [_x[0] / _xl, _x[1] / _xl, _x[2] / _xl];
	var _y = [_z[1] * _x[2] - _z[2] * _x[1], _z[2] * _x[0] - _z[0] * _x[2], _z[0] * _x[1] - _z[1] * _x[0]];
	return [_x[0], _y[0], _z[0], _x[1], _y[1], _z[1], _x[2], _y[2], _z[2]];   // (columns = the view's axes in the world)
};
/// [back] and escape: one step up the chain - map -> where it came from;
/// depart -> region -> planet -> hub; crew / trip / haul -> hub
__back = function() {
	swap_pick = false;
	switch (view) {
		case "map":    view = map_from; break;
		case "galaxy": view = gx_from; break;
		case "depart": view = "planet"; pv_mode = "region"; break;   // (back to the region, on the planet page)
		case "planet": if (pv_mode == "region") pv_mode = "planet"; else view = "hub"; break;   // region mode -> the planet, the planet -> the hub
		case "crew":   view = (crew_trip >= 0) ? "trip" : crew_from; crew_trip = -1; it_pop = undefined; break;
		default:       view = "hub"; break;
	}
	play_sound_ext(snd_softclick, .95, 1.05, .4, 1);
};
/// the crew the crew menu lists: everyone, or one trip's (crew_trip)
__crew_list = function() {
	if (crew_trip < 0) return g.sprites;
	var _out = [];
	for (var _t = 0; _t < array_length(g.exped.trips); _t++) {
		var _tr = g.exped.trips[_t];
		if (_tr.id != crew_trip) continue;
		for (var _k = 0; _k < array_length(_tr.sids); _k++) { var _sp = __sp_by_id(_tr.sids[_k]); if (!is_undefined(_sp)) array_push(_out, _sp); }
	}
	return (array_length(_out) > 0) ? _out : g.sprites;
};
// the trip page's buttons: a row UNDER the world box (his ask, 2026-09-15:
// "move the crew/map buttons off the world panel"): [crew] [map] [abort]
__trip_btn_r = function(_k) { var _bw = floor((big_w - 8) / 3); return { x : big_x + 4 + _k * (_bw + 2), y : big_y + big_h + 4, w : _bw - 2, h : 13 }; };
__trip_crew_r  = function() { return __trip_btn_r(0); };
__trip_abort_r = function() { return __trip_btn_r(2); };
__view_rg_r = function() { return { x : room_width - (land ? 14 : 4) - 96, y : room_height - 8 - 16, w : 96, h : 16 }; };   // [view region], bottom right, once a region is picked
// ---- THE ORBIT VIEW (the planet page, 2026-09-15: the tech demo's rm_planet in the panel) ----
// cam = view -> world (an arcball: drag post-multiplies about the view's
// axes, glide keeps the flick); the world spins its own tilted axis and
// the camera RIDES it (geosync: the spot you look at stays put while the
// daylight sweeps); the sky and the sun come from the galaxy (pv_sky)
pv_cam   = mat3_rot(1, 0, 0, -32);   // pitched above the plane, like the demo
pv_spin  = 0;                        // the world's own-axis angle
pv_spin_seed = -1;                   // ...set from the clock when a world is first shown
pv_drag  = false; pv_px = 0; pv_dx = 0; pv_dy = 0; pv_vx = 0; pv_vy = 0;
pv_geo   = true;
pv_face  = -1;                       // the region the camera is turning to face (-1 = none)
pv_dw    = false; pv_dwa = 0;        // the region drawer on the right: open, and its ease
pv_sky   = undefined;                // galaxy_sky_build()
pv_mat_m = [1, 0, 0, 0, 1, 0, 0, 0, 1];   // texture-from-view, published by the draw for the step's pick
pv_mat_r = [1, 0, 0, 0, 1, 0, 0, 0, 1];   // ...and its inverse (the spots)
pv_mode  = "planet";                 // "planet" (the world, the drawer) or "region" (pulled in on the pick: the banner, the quests)
pv_zoom  = 1;                        // region mode's pull-in (PV_ZOOM_RG), eased
pv_cfade = 1;                        // ...and the clouds thinning with it
// the trip page's world: the same render, the camera fixed on the trip's region
tp_id = -1; tp_cam = mat3_rot(1, 0, 0, -32); tp_spin = 0;
sky_fog_surf = -1;                   // sh_sky_fog's canvas (the page's size)
__pv_r     = function() { return { x : 0, y : list_y, w : room_width, h : room_height - list_y }; };   // (from the strip down - his ask, 2026-09-15: no gap over the sky)
__pv_c     = function() { var _r = __pv_r(); return { x : _r.x + _r.w * .5 - 46 * pv_dwa, y : _r.y + _r.h * .5 + 2 }; };   // (the world slides left as the drawer opens)
__pv_dw_w  = function() { return land ? 150 : 120; };
__pv_dw_x  = function() { return room_width - 9 - __pv_dw_w() * pv_dwa; };   // the drawer's left edge (its tab)
__pv_tab_r = function() { return { x : __pv_dw_x(), y : list_y + 22, w : 9, h : 60 }; };
__pv_row_r = function(_i) { return { x : __pv_dw_x() + 13, y : list_y + 40 + _i * 26, w : __pv_dw_w() - 8, h : 24 }; };
// THE BUTTON COLUMNS (his ask, 2026-09-15): bottom left, stacked - [galaxy]
// at the foot, [region map] over it in region mode, the geosync toggle on
// top; bottom right in region mode - [quests] over [explore]
__galaxy_r = function() { return { x : land ? 14 : 4, y : room_height - 8 - 16, w : land ? 90 : 70, h : 16 }; };
__rgmap_r  = function() { var _g = __galaxy_r(); return { x : _g.x, y : _g.y - 20, w : _g.w, h : 16 }; };   // [region map] (region mode)
__geo_r    = function() { var _g = __galaxy_r(); return { x : _g.x, y : _g.y - ((pv_mode == "region") ? 40 : 20), w : _g.w, h : 16 }; };
__explore_r = function() { var _w = land ? 96 : 60; return { x : room_width - (land ? 14 : 4) - _w, y : room_height - 8 - 16, w : _w, h : 16 }; };
__quests_r  = function() { var _x = __explore_r(); return { x : _x.x, y : _x.y - 20, w : _x.w, h : 16 }; };
// region mode: the info box on the left (region_info's lines)
rg_box_w = 150; rg_box_h = 110;      // the info box's size, as its lines want (__info_box_size; the Draw keeps it fresh)
__rg_banner_r = function() { return { x : land ? 14 : 4, y : list_y + 40, w : rg_box_w, h : rg_box_h }; };
// THE HAND'S SEATS: the cards in a row across the page (portrait: two columns)
__hand_seats = function(_n) {
	var _out = [];
	var _pv = __pv_r();
	if (land) {
		var _pitch = 92, _x0 = room_width * .5 - (_n - 1) * .5 * _pitch, _y = _pv.y + _pv.h * .5 - 6;   // (a little high: the clock sits under the card)
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
	_ty += 12;
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
			var _nd = _rg.nodes[clamp(_q.node, 0, array_length(_rg.nodes) - 1)];
			var _kd = _kk[$ _nd.kind];
			var _obj = "";
			switch (_q.kind) {
				case "slay":  _obj = "slay " + string(_q.n) + " " + _q.foe + "s there"; break;
				case "clear": _obj = "clear it, room by room (" + string(_q.n) + ")"; break;
				case "rout":  _obj = "rout the bandits: two fights, then their chest"; break;
				case "scout": _obj = "get there, have a look, come back"; break;
			}
			array_push(_faces, { title : _nd.name, sub : is_struct(_kd) ? _kd.name : _nd.kind, col : is_struct(_kd) ? _kd.col : c_gold, txt : _obj,
			                     diff : _q.diff, diff_txt : _q.diff_txt, hrs : string(_q.hours) + "h", cr : string(_q.reward) + " cr", xp : string(sprite_xp_quest(_q.lv, 1, _q.mult)) + " xp",   // (the xp in xp - his ask: "x3" meant nothing)
			                     slot : _sl[_i], si : _i, hours : _q.hours });
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
	dp_look = (array_length(sel_crew) > 0) ? sel_crew[0] : -1;
	__hand_close();
	__page_go("depart");
	play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
};
__hub_gal_r = function() { var _c = __crewbtn_r(); return { x : _c.x + ((array_length(g.sprites) > 0) ? (_c.w + 4) : 0), y : _c.y, w : 64, h : 14 }; };
/// a region's spot as a unit vector in TEXTURE space (sphere_uv's frame)
__spot_dir = function(_lon, _lat) { return [dcos(_lat) * dcos(_lon), dsin(_lat), dcos(_lat) * dsin(_lon)]; };
/// a press on one of the page's controls is not a grab of the world
__pv_ui_hit = function() {
	var _bk = __back_r(); if (point_in_rectangle(mouse_x, mouse_y, _bk.x, _bk.y, _bk.x + _bk.w, _bk.y + _bk.h)) return true;
	var _cs = __crewstrip_r(); if (point_in_rectangle(mouse_x, mouse_y, _cs.x, _cs.y, _cs.x + _cs.w, _cs.y + _cs.h)) return true;
	var _g = __galaxy_r(); if (point_in_rectangle(mouse_x, mouse_y, _g.x, _g.y, _g.x + _g.w, _g.y + _g.h)) return true;
	var _ge = __geo_r(); if (point_in_rectangle(mouse_x, mouse_y, _ge.x, _ge.y, _ge.x + _ge.w, _ge.y + _ge.h)) return true;
	if (pv_mode == "region") {
		var _bn = __rg_banner_r(); if (point_in_rectangle(mouse_x, mouse_y, _bn.x, _bn.y, _bn.x + _bn.w, _bn.y + _bn.h)) return true;
		var _mr = __rgmap_r(); if (point_in_rectangle(mouse_x, mouse_y, _mr.x, _mr.y, _mr.x + _mr.w, _mr.y + _mr.h)) return true;
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
__pv_pick = function(_i) {
	rg_sel = _i; pl_focus = _i; pv_face = _i;
	play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
};
// ---- THE GALAXY VIEW (the star map, 2026-09-15: the tech demo's rm_starmap as a page) ----
gx_x = 0; gx_y = 0; gx_zoom = 1; gx_init = false;   // the camera's top-left on the plane, the zoom; centred on the home star the first time
gx_press = false; gx_px = 0; gx_py = 0; gx_cx0 = 0; gx_cy0 = 0; gx_travel = 0;
gx_sel = -1; gx_sys = undefined;     // the tapped star and its system
gx_from = "hub";                     // where [back] returns
gx_fog = -1; gx_fog_seed = -1;       // the nebula fog sheet, baked once a galaxy
gx_mm = -1; gx_mm_seed = -1;         // THE MINIMAP (his ask: bring it back): the star dots baked once, 80px wide
gx_glow_a = -1; gx_glow_b = -1;      // the bloom's two half-size passes (sh_blur)
/// the bloom: the finished map (src, w x h) blurred at half size, two
/// passes, laid back over the target additively at alpha a
// THE BLOOM composites INTO the page (2026-09-15): float all the way, so
// the halos meet 8-bit only at the page's blit (x / y are kept for the
// 8-bit path, where it still lands on the screen)
__bloom = function(_src, _w, _h, _x, _y, _a) {
	var _hw = max(2, floor(_w * .5)), _hh = max(2, floor(_h * .5));
	if (!surface_exists(gx_glow_a) || surface_get_width(gx_glow_a) != _hw || surface_get_height(gx_glow_a) != _hh) { if (surface_exists(gx_glow_a)) surface_free(gx_glow_a); gx_glow_a = page_surface(_hw, _hh); }
	if (!surface_exists(gx_glow_b) || surface_get_width(gx_glow_b) != _hw || surface_get_height(gx_glow_b) != _hh) { if (surface_exists(gx_glow_b)) surface_free(gx_glow_b); gx_glow_b = page_surface(_hw, _hh); }
	static _u = undefined;
	if (is_undefined(_u)) _u = { dir : shader_get_uniform(sh_blur, "u_dir"), texel : shader_get_uniform(sh_blur, "u_texel") };
	var _ftf = gpu_get_tex_filter();
	gpu_set_tex_filter(true);
	gpu_set_blendmode(bm_normal);
	surface_set_target(gx_glow_a);
	draw_clear_alpha(c_black, 1);
	shader_set(sh_blur);
	shader_set_uniform_f(_u.dir, 1, 0); shader_set_uniform_f(_u.texel, 1 / _w, 1 / _h);
	draw_surface_ext(_src, 0, 0, _hw / _w, _hh / _h, 0, c_white, 1);
	shader_reset();
	surface_reset_target();
	surface_set_target(gx_glow_b);
	draw_clear_alpha(c_black, 1);
	shader_set(sh_blur);
	shader_set_uniform_f(_u.dir, 0, 1); shader_set_uniform_f(_u.texel, 1 / _hw, 1 / _hh);
	draw_surface(gx_glow_a, 0, 0);
	shader_reset();
	surface_reset_target();
	gpu_set_blendmode(bm_add);
	if (page_float()) { surface_set_target(_src); draw_surface_ext(gx_glow_b, 0, 0, _w / _hw, _h / _hh, 0, c_white, _a); surface_reset_target(); }
	else draw_surface_ext(gx_glow_b, _x, _y, _w / _hw, _h / _hh, 0, c_white, _a);
	gpu_set_blendmode(bm_normal);
	gpu_set_tex_filter(_ftf);
};
__gx_mm_r = function() { var _sm = starmap_get(); var _w = 80; return { x : land ? 14 : 4, y : list_y + 34, w : _w, h : ceil(_sm.height * _w / _sm.width) }; };
// THE DIARY'S SCROLL (his ask, 2026-09-15: the scrollbar framework, smooth):
// log_scroll = pixels down from the diary's top; the house bar (sb,
// scrl_exped_log, pixel mode) drives it; it follows the newest line
// unless you scrolled up (log_follow)
log_scroll = 0;
log_follow = true;
log_n = -1;                          // the diary's line count last seen (a new line = follow)
log_surf = -1;                       // the diary's band, rendered offset
log_lay = { n : 0, w : 0, hs : [], total : 0 };   // the layout: every line's height, the total
sb = create_obj(0, 0, obj_scrollbar);
sb.i = scrl_exped_log;
sb.depth = depth - 1;
sb.ui_layer = ui_layer_popup;
sb.in_menu = true;
sb.col = c_steelblue;
sb.visible = false; sb.enabled = false;
/// the diary this page shows (the trip's or the haul's), or undefined
__log_lines = function() {
	if (view == "trip") { var _t = __trip(); return is_undefined(_t) ? undefined : _t.log; }
	if (view == "haul") { var _h = __haul_i(); return (_h < 0) ? undefined : g.exped.hauls[_h].log; }
	return undefined;
};
__log_band_h = function() { var _r = __log_r(); return max(1, _r.h); };
/// the layout: each line's height at the column's width, the total (once
/// a frame - the count or the width changing recomputes)
__log_layout = function(_log, _w) {
	if (is_array(_log) && log_lay.n == array_length(_log) && log_lay.w == _w && (log_lay[$ "id"] ?? -1) == view_id) return log_lay;   // (keyed by the page's trip too: another diary of the same length is another layout)
	var _hs = [], _tot = 0;
	if (is_array(_log)) {
		draw_set_font(fnt);
		for (var _i = 0; _i < array_length(_log); _i++) {
			var _pre = string_copy(_log[_i], 1, 2);
			var _isv = (_pre == "~ ");
			var _h = string_height_ext(_isv ? string_delete(_log[_i], 1, 2) : ((_pre == "+ ") ? string_delete(_log[_i], 1, 2) : _log[_i]), 9, _w - (_isv ? 8 : 0)) + 2;
			array_push(_hs, _h); _tot += _h;
		}
	}
	log_lay = { n : is_array(_log) ? array_length(_log) : 0, w : _w, hs : _hs, total : _tot, id : view_id };
	return log_lay;
};
__log_content_h = function() { var _r = __log_r(); var _l = __log_lines(); return __log_layout(_l, _r.w - 8).total; };
/// the diary painted into its band, scrolled: truth lines plain, "~ " the
/// crew's voice (dim, indented), "+ " rewards (gold); newest at the bottom
__draw_log_band = function(_log, _r, _col) {
	var _w = max(2, floor(_r.w - 8)), _h = max(2, floor(_r.h));
	if (!surface_exists(log_surf) || surface_get_width(log_surf) != _w || surface_get_height(log_surf) != _h) {
		if (surface_exists(log_surf)) surface_free(log_surf);
		log_surf = surface_create(_w, _h);
	}
	var _lay = __log_layout(_log, _w);
	var _fa = g.ui_fade_a;
	ui_fade_set(1);
	surface_set_target(log_surf);
	draw_clear_alpha(c_black, 0);
	draw_set_font(fnt); draw_set_halign(fa_left); draw_set_valign(fa_top);
	var _yy = -log_scroll;
	var _nl = array_length(_log);
	for (var _i = 0; _i < _nl; _i++) {
		var _lh = _lay.hs[_i];
		if (_yy + _lh >= 0 && _yy <= _h) {
			var _pre = string_copy(_log[_i], 1, 2);
			var _isv = (_pre == "~ "), _isr = (_pre == "+ ");
			var _last = (_i == _nl - 1);
			if (_isv) { draw_set_color(_last ? merge_colour(sett_ink, c_white, .5) : merge_colour(sett_ink, _col, .35)); draw_set_alpha(_last ? .9 : .55); draw_text_ext(8, _yy, string_delete(_log[_i], 1, 2), 9, _w - 8); }
			else if (_isr) { draw_set_color(_last ? merge_colour(c_gold, c_white, .3) : c_gold); draw_set_alpha(_last ? .95 : .8); draw_text_ext(0, _yy, string_delete(_log[_i], 1, 2), 9, _w); }
			else { draw_set_color(_last ? c_white : sett_ink); draw_set_alpha(_last ? .95 : .7); draw_text_ext(0, _yy, _log[_i], 9, _w); }
		}
		_yy += _lh;
	}
	draw_set_alpha(1);
	surface_reset_target();
	ui_fade_set(_fa);
	draw_surface(log_surf, _r.x, _r.y);
};
/// the diary's rect on the page that shows one (the wheel's target)
__log_r = function() {
	if (view == "trip") {
		var _t = __trip();
		var _fighting = !is_undefined(_t) && (!is_undefined(_t.fight) || !is_undefined(rp));
		var _yend = _fighting ? (room_height - 8 - fight_s - 6) : (room_height - 10);
		return { x : log_x, y : log_y + 48, w : log_w, h : _yend - (log_y + 48) };
	}
	if (view == "haul") { var _cw = land ? 224 : (room_width - 8), _lx = (land ? 14 : 4) + _cw + 12; return { x : _lx, y : list_y + 22 + 12, w : room_width - _lx - 14, h : room_height - 10 - (list_y + 22 + 12) }; }
	return { x : 0, y : 0, w : 0, h : 0 };
};
gx_para = [];                        // the parallax backdrop's layers (built on the first draw)
__gx_r = function() { return { x : 0, y : list_y, w : room_width, h : room_height - list_y }; };
// the departure window: the crew chips left, the brief right, [depart] under the brief
dchip_y   = list_y + 40;
__dchip_r = function(_k) { var _per = land ? 5 : 6; return { x : (land ? 14 : 4) + (_k mod _per) * (chip + chip_gap), y : dchip_y + (_k div _per) * (chip + 10), w : chip, h : chip }; };
__brief_r = function() { return { x : land ? 176 : 4, y : list_y + 22, w : land ? (room_width - 176 - 14) : (room_width - 8), h : land ? (room_height - 8 - 22 - (list_y + 22)) : 110 }; };
__depart_r = function() { var _b = __brief_r(); return { x : _b.x, y : _b.y + _b.h + 4, w : 100, h : 16 }; };
__crewbtn_r = function() { return { x : card_x0, y : room_height - 8 - 14, w : 60, h : 14 }; };
// the crew menu: tabs down the left (one a sprite), the picked one's sheet on the right (his ask, 2026-09-14)
tab_w = land ? 78 : 60; tab_h = 15;
__tab_r = function(_k) { return { x : land ? 14 : 4, y : list_y + 22 + _k * (tab_h + 2), w : tab_w, h : tab_h }; };
__sheet_x0 = function() { return (land ? 14 : 4) + tab_w + 10; };
__recall_r = function() { return { x : log_x + log_w - 60, y : log_y + 18, w : 60, h : 12 }; };
crew_row_h = land ? 36 : 44;
// the map view: the region drawn into this rect; [map] chips on a world card and the trip page
__map_r = function() { var _x = land ? (14 + rg_box_w + 10) : 4; return { x : _x, y : list_y + 22, w : room_width - _x - (land ? 14 : 4), h : room_height - 8 - 14 - (list_y + 22) }; };   // (right of the info box - his ask, 2026-09-15)
__map_box_r = function() { return { x : 14, y : list_y + 22, w : rg_box_w, h : rg_box_h }; };   // the region's info box on the map (landscape)
/// THE INFO BOX'S SIZE: as wide as its longest line (his ask), as tall as its lines
__info_box_size = function(_d, _rg) {
	var _inf = region_info(_d, _rg);
	var _wmax = land ? 200 : 120, _wmin = 96;
	draw_set_font(fnt_large);
	var _w = string_width(str_cap(_rg.name)) + 16;
	draw_set_font(fnt);
	for (var _li = 0; _li < array_length(_inf); _li++) _w = max(_w, string_width(_inf[_li].k + " - " + _inf[_li].v) + 16);
	_w = clamp(_w, _wmin, _wmax);
	draw_set_font(fnt_large);
	var _h = 5 + string_height_ext(str_cap(_rg.name), 11, _w - 14) + 3 + array_length(_inf) * 11 + 4;
	draw_set_font(fnt);
	rg_box_w = _w; rg_box_h = _h;
	return { w : _w, h : _h, inf : _inf };
};
/// THE INFO BOX painted (region_info's lines; the region page and the map share it)
__draw_info_box = function(_d, _rg, _bn) {
	var _bs = __info_box_size(_d, _rg);
	var _inf = _bs.inf;
	_bn.w = _bs.w; _bn.h = _bs.h;
	draw_sprite_ext(spr_pixel_1x1, 0, _bn.x, _bn.y, _bn.w, _bn.h, 0, c_black, .8);
	draw_sprite_ext(spr_pixel_1x1, 0, _bn.x, _bn.y, 2, _bn.h, 0, c_gold, .9);
	draw_set_font(fnt_large); draw_set_color(c_gold); draw_set_alpha(.95);
	draw_text_ext(_bn.x + 8, _bn.y + 5, str_cap(_rg.name), 11, _bn.w - 14);
	var _bny = _bn.y + 5 + string_height_ext(str_cap(_rg.name), 11, _bn.w - 14) + 3;
	draw_set_font(fnt);
	var _tc = [c_sgreen, c_gold, c_horange, c_hred];
	for (var _li = 0; _li < array_length(_inf); _li++) {
		var _ln = _inf[_li];
		draw_set_color(sett_ink); draw_set_alpha(.8);
		draw_text(_bn.x + 8, _bny, _ln.k + " - ");
		var _lc = _ln[$ "col"];
		draw_set_color(is_undefined(_lc) ? _tc[clamp(_ln.t, 0, 3)] : _lc); draw_set_alpha(.95);
		draw_text(_bn.x + 8 + string_width(_ln.k + " - "), _bny, _ln.v);
		_bny += 11;
	}
};
map_legend = false;                  // the legend popup (his ask: a [legend] button, the kinds listed)
map_lab = undefined;                 // the labels' placement, computed once a map: { key, pos[] }
__legend_r = function() { var _m = __map_r(); return { x : _m.x, y : _m.y + _m.h + 2, w : 56, h : 13 }; };
/// a node's place on the map rect: the region's circle fills the rect's
/// shorter side (his ask: bounded by a radius, not the rectangle)
__map_xy = function(_nd, _rg, _mr) {
	var _rad = _rg[$ "radius"] ?? .46, _ccx = _rg[$ "cx"] ?? .5, _ccy = _rg[$ "cy"] ?? .5;
	var _sc = (min(_mr.w, _mr.h) * .5 - 10) / _rad;
	return { x : _mr.x + _mr.w * .5 + (_nd.x - _ccx) * _sc, y : _mr.y + _mr.h * .5 + (_nd.y - _ccy) * _sc };
};
/// the pixel icons (his ask): a flag for the landing zone, a house for a
/// settled place, a tent for a camp, a doorway for a dungeon or crypt
__map_icon = function(_kind, _lz, _x, _y, _col) {
	if (_lz) {
		// the flag: a pole and a pennant, white
		draw_sprite_ext(spr_pixel_1x1, 0, _x - 3, _y - 7, 1, 10, 0, c_white, .95);
		draw_sprite_ext(spr_pixel_1x1, 0, _x - 2, _y - 7, 5, 2, 0, c_white, .95);
		draw_sprite_ext(spr_pixel_1x1, 0, _x - 2, _y - 5, 3, 1, 0, c_white, .95);
		return;
	}
	switch (_kind) {
		case "settlement": case "village": case "town": case "city": {
			// the house: a roof stepping in, a body, a door
			var _big = (_kind == "town" || _kind == "city") ? 1 : 0;
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 4 - _big, _y - 1, 8 + _big * 2, 5 + _big, 0, _col, .95);
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 3 - _big, _y - 3, 6 + _big * 2, 2, 0, _col, .95);
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 1, _y - 5 - _big, 2, 2 + _big, 0, _col, .95);
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 1, _y + 2, 2, 2 + _big, 0, c_black, .8);
			if (_kind == "city") draw_sprite_ext(spr_pixel_1x1, 0, _x + 3, _y - 6, 2, 4, 0, _col, .95);
			return;
		}
		case "camp": {
			// the tent: rows widening down, a dark flap
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 1, _y - 5, 2, 2, 0, _col, .95);
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 2, _y - 3, 4, 2, 0, _col, .95);
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 3, _y - 1, 6, 2, 0, _col, .95);
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 4, _y + 1, 8, 2, 0, _col, .95);
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 1, _y, 2, 3, 0, c_black, .8);
			return;
		}
		case "dungeon": case "crypt": {
			// the doorway: a dark arch in a block
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 4, _y - 4, 8, 8, 0, _col, .95);
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 2, _y - 2, 4, 6, 0, c_black, .85);
			return;
		}
	}
	__dot(_x, _y, 2, _col, .95);
};
/// does a segment touch a rectangle? (an end inside, or a crossing of one of its sides)
__seg_rect = function(_x1, _y1, _x2, _y2, _rx1, _ry1, _rx2, _ry2) {
	if (point_in_rectangle(_x1, _y1, _rx1, _ry1, _rx2, _ry2) || point_in_rectangle(_x2, _y2, _rx1, _ry1, _rx2, _ry2)) return true;
	var _cr = function(_ax, _ay, _bx, _by, _cx, _cy, _dx, _dy) {
		var _d = (_bx - _ax) * (_dy - _cy) - (_by - _ay) * (_dx - _cx);
		if (abs(_d) < .000001) return false;
		var _t = ((_cx - _ax) * (_dy - _cy) - (_cy - _ay) * (_dx - _cx)) / _d;
		var _u = ((_cx - _ax) * (_by - _ay) - (_cy - _ay) * (_bx - _ax)) / _d;
		return (_t >= 0 && _t <= 1 && _u >= 0 && _u <= 1);
	};
	if (_cr(_x1, _y1, _x2, _y2, _rx1, _ry1, _rx2, _ry1)) return true;
	if (_cr(_x1, _y1, _x2, _y2, _rx1, _ry2, _rx2, _ry2)) return true;
	if (_cr(_x1, _y1, _x2, _y2, _rx1, _ry1, _rx1, _ry2)) return true;
	if (_cr(_x1, _y1, _x2, _y2, _rx2, _ry1, _rx2, _ry2)) return true;
	return false;
};
/// where each label goes: four sides tried, the one crossing the fewest
/// roads (and no other label) wins; once a map (map_lab caches by key)
__map_labels = function(_rg, _mr, _key) {
	if (is_struct(map_lab) && map_lab.key == _key) return map_lab.pos;
	var _kk = region_kinds();
	var _pos = array_create(array_length(_rg.nodes), undefined);
	var _boxes = [];
	// every road segment on the map, once
	var _segs = [];
	for (var _e = 0; _e < array_length(_rg.edges); _e++) {
		var _ed = _rg.edges[_e];
		var _pts = _ed[$ "pts"];
		if (!is_array(_pts) || array_length(_pts) < 2) _pts = [ _rg.nodes[_ed.a], _rg.nodes[_ed.b] ];
		for (var _k = 1; _k < array_length(_pts); _k++) {
			var _p1 = __map_xy(_pts[_k - 1], _rg, _mr), _p2 = __map_xy(_pts[_k], _rg, _mr);
			array_push(_segs, { x1 : _p1.x, y1 : _p1.y, x2 : _p2.x, y2 : _p2.y });
		}
	}
	draw_set_font(fnt);
	for (var _i = 0; _i < array_length(_rg.nodes); _i++) {
		var _nd = _rg.nodes[_i];
		var _c = __map_xy(_nd, _rg, _mr);
		var _tw = string_width(_nd.name), _th = 8;
		var _cand = [ { x : _c.x + 7, y : _c.y - 4 }, { x : _c.x - 7 - _tw, y : _c.y - 4 }, { x : _c.x - _tw * .5, y : _c.y - 14 }, { x : _c.x - _tw * .5, y : _c.y + 6 } ];
		var _best = 0, _bs = infinity;
		for (var _q = 0; _q < 4; _q++) {
			var _b = { x1 : _cand[_q].x - 1, y1 : _cand[_q].y - 1, x2 : _cand[_q].x + _tw + 1, y2 : _cand[_q].y + _th + 1 };
			var _sc = _q * .1;   // (a tie goes to the right side, then left, up, down)
			if (_b.x1 < _mr.x || _b.x2 > _mr.x + _mr.w || _b.y1 < _mr.y || _b.y2 > _mr.y + _mr.h) _sc += 5;
			for (var _s = 0; _s < array_length(_segs); _s++) if (__seg_rect(_segs[_s].x1, _segs[_s].y1, _segs[_s].x2, _segs[_s].y2, _b.x1, _b.y1, _b.x2, _b.y2)) _sc += 1;
			for (var _o = 0; _o < array_length(_boxes); _o++) if (rectangle_in_rectangle(_b.x1, _b.y1, _b.x2, _b.y2, _boxes[_o].x1, _boxes[_o].y1, _boxes[_o].x2, _boxes[_o].y2)) _sc += 2;
			if (_sc < _bs) { _bs = _sc; _best = _q; }
		}
		_pos[_i] = _cand[_best];
		array_push(_boxes, { x1 : _cand[_best].x - 1, y1 : _cand[_best].y - 1, x2 : _cand[_best].x + _tw + 1, y2 : _cand[_best].y + _th + 1 });
	}
	map_lab = { key : _key, pos : _pos };
	return _pos;
};
__trip_map_r = function() { return __trip_btn_r(1); };
// THE CREW'S BANNERS (his ask, 2026-09-15: under the world box): a row each
// under the button row - dot, name, level, the hp bar (live in a fight)
__crew_row_r = function(_k) { return { x : big_x, y : big_y + big_h + 22 + _k * 12, w : big_w, h : 11 }; };
/// THE ORBIT RENDERER (2026-09-15: "have all models of the planet match our
/// main one... stars and all"): the sky (the real neighbourhood, the milky
/// way, the sun - pv_sky), the world at (pcx, pcy) of the rect with radius
/// pr through the camera cam (view -> world) and its own spin, and the
/// regions' spots: a 2px square each on the far-side test, the focused
/// one a pulsing hollow square in 2px lines (pixel, not a circle), labels
/// in the OUTLINE font when facing you (his ask: readable over the world).
/// Rendered into wb_surf and blitted at (x, y): nothing spills. spots =
/// -1 none, -2 all, else only that region. Returns { m, r } (texture-
/// from-view and its inverse) for the caller's pick
__draw_orbit = function(_d, _x, _y, _w, _h, _pcx, _pcy, _pr, _cam, _spin, _spots, _focus, _cfade) {
	_w = max(2, floor(_w)); _h = max(2, floor(_h));
	if (!surface_exists(wb_surf) || surface_get_width(wb_surf) != _w || surface_get_height(wb_surf) != _h) {
		if (surface_exists(wb_surf)) surface_free(wb_surf);
		wb_surf = page_surface(_w, _h);   // (float where the gpu allows: one quantisation, at the blit)
	}
	if (!surface_exists(sky_fog_surf) || surface_get_width(sky_fog_surf) != _w || surface_get_height(sky_fog_surf) != _h) {
		if (surface_exists(sky_fog_surf)) surface_free(sky_fog_surf);
		sky_fog_surf = surface_create(_w, _h);
	}
	if (!is_struct(pv_sky)) pv_sky = galaxy_sky_build();
	var _pn = planet_get(_d.seed, exped_planet_hint(_d));
	var _built = (_pn.row >= _pn.th);
	var _wm = mat3_mul(mat3_rot(0, 0, 1, _pn.tilt), mat3_rot(0, 1, 0, _spin));
	var _mm = mat3_mul(mat3_transpose(_wm), _cam);
	var _mr = mat3_transpose(_mm);
	var _fa = g.ui_fade_a;
	ui_fade_set(1);
	surface_set_target(wb_surf);
	draw_clear_alpha(c_black, 1);
	galaxy_sky_draw(pv_sky, _cam, _pcx, _pcy, _w, _h, true);
	galaxy_fog_draw(pv_sky, _cam, _pcx, _pcy, _w, _h, sky_fog_surf);
	g.dither_off = page_float();   // (the world into a float page: no dither of its own - the blit's grain is the one)
	if (_built) planet_draw(_pn, _pcx, _pcy, _pr, _spin, _cfade, _cam, pv_sky.light_w);
	g.dither_off = false;
	// (not built yet: the sky alone - the lite portrait that stood in "looked really bad", his report 2026-09-15; the boot builds the board's worlds)
	if (_built && _spots != -1) {
		draw_set_font(fnt_outline); draw_set_halign(fa_left); draw_set_valign(fa_top);
		var _pulse = floor(1.5 + 1.5 * dsin(current_time * .25));
		for (var _i = 0; _i < EXPED_REGIONS; _i++) {
			if (_spots >= 0 && _i != _spots) continue;
			var _rg = region_get(_d, _i);
			var _t = __spot_dir(_rg.spot.lon, _rg.spot.lat);
			var _v = mat3_apply(_mr, _t[0], _t[1], _t[2]);
			if (_v[2] <= .1) continue;
			var _sx = floor(_pcx) + floor(_v[0] * _pr * .5) * 2, _sy = floor(_pcy) + floor(_v[1] * _pr * .5) * 2;
			var _on = (_i == _focus);
			// an OUTLINED SQUARE (his ask): black 8x8 under a 4x4 in the colour - a 2px outline
			draw_sprite_ext(spr_pixel_1x1, 0, _sx - 4, _sy - 4, 8, 8, 0, c_black, .9);
			draw_sprite_ext(spr_pixel_1x1, 0, _sx - 2, _sy - 2, 4, 4, 0, _on ? c_gold : c_white, 1);
			if (_on) {
				var _s = 12 + _pulse * 2;
				__px_box2(_sx - _s * .5, _sy - _s * .5, _s, c_gold, .95);
			}
			if (_v[2] > .3) {
				draw_set_color(_on ? c_gold : c_white); draw_set_alpha(_on ? .95 : .85);
				draw_text(_sx + 6 + (_on ? 3 : 0), _sy - 4, _on ? _rg.name : ("lv " + string(_rg.lv)));
			}
		}
		draw_set_font(fnt);
		draw_set_alpha(1);
	}
	surface_reset_target();
	ui_fade_set(_fa);
	page_blit(wb_surf, _x, _y);   // (the one dither)
	return { m : _mm, r : _mr };
};
/// a hollow square in 2px lines (the pixel look: no fine lines)
__px_box2 = function(_x, _y, _s, _col, _a) {
	draw_sprite_ext(spr_pixel_1x1, 0, _x, _y, _s, 2, 0, _col, _a);
	draw_sprite_ext(spr_pixel_1x1, 0, _x, _y + _s - 2, _s, 2, 0, _col, _a);
	draw_sprite_ext(spr_pixel_1x1, 0, _x, _y + 2, 2, _s - 4, 0, _col, _a);
	draw_sprite_ext(spr_pixel_1x1, 0, _x + _s - 2, _y + 2, 2, _s - 4, 0, _col, _a);
};
/// a camera turned to FACE a region's spot (the face-turn run to the end):
/// the trip page's world, fixed on where the crew is
__cam_face = function(_pn, _spin, _rg, _cam) {
	var _wm = mat3_mul(mat3_rot(0, 0, 1, _pn.tilt), mat3_rot(0, 1, 0, _spin));
	var _t = __spot_dir(_rg.spot.lon, _rg.spot.lat);
	var _nw = mat3_apply(_wm, _t[0], _t[1], _t[2]);
	repeat (80) {
		var _v = mat3_apply(mat3_transpose(_cam), _nw[0], _nw[1], _nw[2]);
		if (_v[2] > .9999) break;
		var _ang = darccos(clamp(_v[2], -1, 1)) * .35;
		var _axl = sqrt(_v[0] * _v[0] + _v[1] * _v[1]);
		var _a0 = (_axl < .0001) ? 0 : (_v[1] / _axl);
		var _a1 = (_axl < .0001) ? 1 : (-_v[0] / _axl);
		var _c1 = mat3_mul(_cam, mat3_rot(_a0, _a1, 0, _ang)), _c2 = mat3_mul(_cam, mat3_rot(_a0, _a1, 0, -_ang));
		var _v1 = mat3_apply(mat3_transpose(_c1), _nw[0], _nw[1], _nw[2]), _v2 = mat3_apply(mat3_transpose(_c2), _nw[0], _nw[1], _nw[2]);
		_cam = (_v1[2] >= _v2[2]) ? _c1 : _c2;
	}
	return _cam;
};
/// a world small (the hub's card, the list's rows, the haul's card): the
/// FULL world once it is built - clouds and ring (the globe at .62 so the
/// ring fits) - the lite portrait until then (his ask: every version
/// shows clouds). The caller has the fade off (the shader replaces it)
__world_small = function(_d, _cx, _cy, _r, _rg = undefined) {
	var _pn = planet_get(_d.seed, exped_planet_hint(_d));
	if (_pn.row >= _pn.th) {
		// FACING ITS REGION when the card is about one (his ask, 2026-09-15): the
		// spot dead on, the clock's spin under it (the terminator moves, the region holds)
		if (is_struct(_rg)) { var _sp = planet_spin_now(_pn); planet_draw(_pn, _cx, _cy, _pn.ring ? (_r * .62) : _r, _sp, 1, __cam_at(_pn, _sp, _rg), is_struct(pv_sky) ? pv_sky.light_w : undefined); }
		else planet_draw(_pn, _cx, _cy, _pn.ring ? (_r * .62) : _r);
	}
	else __portrait(_d, _cx, _cy, _r);
};
/// the worlds are built a few rows a frame (planet_gen_step): the board's,
/// the trips' and the planet window's - one of them a frame, so every
/// portrait gets its full world within a second or two
__worlds_step = function() {
	var _e = g.exped;
	var _list = [];
	for (var _i = 0; _i < array_length(_e.board); _i++) array_push(_list, _e.board[_i]);
	for (var _i = 0; _i < array_length(_e.trips); _i++) array_push(_list, _e.trips[_i].dest);
	if (is_struct(pl_dest)) array_push(_list, pl_dest);
	for (var _i = 0; _i < array_length(_list); _i++) {
		var _pn = planet_get(_list[_i].seed, exped_planet_hint(_list[_i]));
		if (_pn.row < _pn.th) { planet_gen_step(_pn, 6); return; }   // (six rows a frame: a fresh world in a quarter second)
	}
};
/// a sprite by id (undefined when gone)
__sp_by_id = function(_id) {
	for (var _i = 0; _i < array_length(g.sprites); _i++) if (g.sprites[_i].id == _id) return g.sprites[_i];
	return undefined;
};
__step_r = function() { return { x : log_x + fight_s + 8, y : room_height - 8 - 14, w : 70, h : 14 }; };
__col_r  = function() { return { x : (land ? 14 : 4) + 67, y : room_height - 8 - 16, w : 90, h : 16 }; };   // under the haul card (left half)
__swap_r = function() { return { x : (land ? 14 : 4) + 16, y : room_height - 8 - 16, w : 90, h : 16 }; };
__go_r   = function() { return { x : (land ? 14 : 4) + 118, y : room_height - 8 - 16, w : 90, h : 16 }; };
__pick_r = function(_k) { return { x : room_width * .5 - 100, y : list_y + 30 + _k * 16, w : 200, h : 15 }; };

/// the trip / haul this view looks at, or undefined
__trip = function() {
	var _e = g.exped;
	for (var _i = 0; _i < array_length(_e.trips); _i++) if (_e.trips[_i].id == view_id) return _e.trips[_i];
	return undefined;
};
__haul_i = function() {
	var _e = g.exped;
	for (var _i = 0; _i < array_length(_e.hauls); _i++) if (_e.hauls[_i].id == view_id) return _i;
	return -1;
};

// THE FIRST PAGE (his call, 2026-09-15: "default to the region selection
// screen"): the world's page, with the hub a [back] away
if (array_length(g.exped.board) > 0) { sel_dest = 0; pl_dest = g.exped.board[0]; rg_sel = 0; pl_focus = -1; view = "planet"; pv_mode = "planet"; }
