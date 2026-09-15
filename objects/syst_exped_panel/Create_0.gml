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
pl_spin  = 0;            // the world's spin as drawn (deg)
pl_spin_t = 0;           // ...and where it is turning to
pl_zoom  = 1;            // ...and how far in
pl_spin_off = 0;         // the ambient spin's offset, so leaving a focus does not jump
crew_trip = -1;          // the crew menu shows only this trip's crew (-1 = everyone)
it_pop   = undefined;    // the item popup: { it, sp, worn : bool, x, y }
it_rects = [];           // the sheet's item rows, laid down by the Draw for the Step's taps: { x, y, w, h, it, worn }
dp_quest = undefined;    // the departure window's quest (undefined = an explore)
dp_mode  = "quest";      // ...and its mode
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
big_x = land ? 14 : 4; big_y = list_y + 20; big_w = land ? 150 : (room_width - 8); big_h = land ? 150 : 96;
log_x = land ? (big_x + big_w + 12) : 4; log_w = land ? (room_width - log_x - 12) : (room_width - 8);
log_y = land ? big_y : (big_y + big_h + 6);
fight_s = 64;        // the combat window's side

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
__chip_r = function(_k) {
	var _per = land ? 5 : 6;
	return { x : card_x0 + (_k mod _per) * (chip + chip_gap), y : crew_y + 10 + (_k div _per) * (chip + 10), w : chip, h : chip };
};
__crew_rows = function() { var _per = land ? 5 : 6; return max(1, ceil(array_length(g.sprites) / _per)); };
__send_r = function() { return { x : card_x0, y : crew_y + 10 + __crew_rows() * (chip + 10) + 2, w : land ? 74 : (room_width - 8), h : 14 }; };   // [quest]
__explore_r = function() { var _s = __send_r(); return { x : _s.x + _s.w + 4, y : _s.y, w : land ? 74 : (room_width - 8), h : 14 }; };   // [explore]
__list_y0 = function() { return land ? (card_y - 10) : (__send_r().y + 14 + 8); };
__row_r  = function(_i) { return { x : list_x, y : __list_y0() + 12 + _i * (row_h + 3), w : list_w, h : row_h }; };
__spd_r  = function(_k) { return { x : room_width - 8 - 3 * 28 + _k * 28, y : strip_y + 2, w : 26, h : 12 }; };
__back_r = function() { return { x : room_width - (land ? 14 : 4) - 44, y : list_y + 3, w : 44, h : 13 }; };   // on the RIGHT (his ask, 2026-09-15: the titles sit left)
/// [back] and escape: one step up the chain - map -> where it came from;
/// depart -> region -> planet -> hub; crew / trip / haul -> hub
__back = function() {
	swap_pick = false;
	switch (view) {
		case "map":    view = map_from; break;
		case "depart": view = "region"; break;
		case "region": view = "planet"; pl_focus = -1; break;
		case "crew":   view = (crew_trip >= 0) ? "trip" : "hub"; crew_trip = -1; it_pop = undefined; break;
		default:       view = "hub"; break;
	}
	play_sound_ext(snd_softclick, .95, 1.05, .4, 1);
};
// the planet window: the world big on the left, its facts, the regions on the right
__pl_box  = function() { return { x : land ? 14 : 4, y : list_y + 22, w : land ? 170 : (room_width - 8), h : land ? 150 : 96 }; };
__pl_row  = function(_i) { var _b = __pl_box(); return { x : land ? (_b.x + _b.w + 12) : _b.x, y : (land ? list_y + 44 : _b.y + _b.h + 26) + _i * 26, w : land ? (room_width - (_b.x + _b.w + 12) - 14) : _b.w, h : 24 }; };
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
__trip_crew_r = function() { return { x : big_x + big_w - 34 - 40, y : big_y + 4, w : 36, h : 11 }; };
/// where a region's spot sits on the drawn world: the same matrix planet_draw
/// hands the shader (world = rot(tilt) x rot(y, spin); a texture direction t
/// shows at n = W t), so the marker lands where the terrain does
__spot_view = function(_pn, _spin, _lon, _lat) {
	var _tx = dcos(_lat) * dcos(_lon), _ty = dsin(_lat), _tz = dcos(_lat) * dsin(_lon);
	var _w = mat3_mul(mat3_rot(0, 0, 1, _pn.tilt), mat3_rot(0, 1, 0, _spin));
	return mat3_apply(_w, _tx, _ty, _tz);
};
/// the spin that brings a spot to the front: sampled, so no sign convention can be wrong
__spin_for = function(_pn, _lon, _lat) {
	var _best = 0, _bz = -2;
	for (var _s = 0; _s < 360; _s += 3) {
		var _n = __spot_view(_pn, _s, _lon, _lat);
		if (_n[2] > _bz) { _bz = _n[2]; _best = _s; }
	}
	return _best;
};
// the region window: the quests, then explore
__q_row   = function(_i) { var _b = __pl_box(); return { x : land ? (_b.x + _b.w + 12) : _b.x, y : (land ? (list_y + 40) : (_b.y + _b.h + 26)) + _i * 30, w : land ? (room_width - (_b.x + _b.w + 12) - 14) : _b.w, h : 27 }; };
// the departure window: the crew chips left, the brief right, [depart] under the brief
dchip_y   = list_y + 40;
__dchip_r = function(_k) { var _per = land ? 5 : 6; return { x : (land ? 14 : 4) + (_k mod _per) * (chip + chip_gap), y : dchip_y + (_k div _per) * (chip + 10), w : chip, h : chip }; };
__brief_r = function() { return { x : land ? 176 : 4, y : list_y + 22, w : land ? (room_width - 176 - 14) : (room_width - 8), h : land ? (room_height - 8 - 22 - (list_y + 22)) : 110 }; };
__depart_r = function() { var _b = __brief_r(); return { x : _b.x, y : _b.y + _b.h + 4, w : 100, h : 16 }; };
__crewbtn_r = function() { return { x : card_x0, y : room_height - 8 - 14, w : 60, h : 14 }; };
__rg_map_r = function() { return { x : room_width - (land ? 14 : 4) - 44 - 50, y : list_y + 3, w : 44, h : 13 }; };
__sheet_r = function() { var _s = __explore_r(); return { x : _s.x + _s.w + 4, y : _s.y, w : 44, h : 14 }; };   // [crew]
// the crew menu: tabs down the left (one a sprite), the picked one's sheet on the right (his ask, 2026-09-14)
tab_w = land ? 78 : 60; tab_h = 15;
__tab_r = function(_k) { return { x : land ? 14 : 4, y : list_y + 22 + _k * (tab_h + 2), w : tab_w, h : tab_h }; };
__sheet_x0 = function() { return (land ? 14 : 4) + tab_w + 10; };
__recall_r = function() { return { x : log_x + log_w - 60, y : log_y + 18, w : 60, h : 12 }; };
crew_row_h = land ? 36 : 44;
// the map view: the region drawn into this rect; [map] chips on a world card and the trip page
__map_r = function() { return { x : land ? 14 : 4, y : list_y + 22, w : room_width - (land ? 28 : 8), h : room_height - 8 - 14 - (list_y + 22) }; };
__card_map_r = function(_i) { var _c = __card_r(_i); return { x : _c.x + _c.w - 27, y : _c.y + 3, w : 24, h : 10 }; };
__trip_map_r = function() { return { x : big_x + big_w - 34, y : big_y + 4, w : 30, h : 11 }; };
__crew_y0 = function() { return list_y + 22; };
__list_row_r = function(_k) { return { x : land ? 14 : 4, y : __crew_y0() + _k * crew_row_h - crew_off, w : room_width - (land ? 28 : 8), h : crew_row_h - 3 }; };   // (the crew LIST's rows; __crew_row_r is the trip page's)
__crew_max_off = function() { return max(0, array_length(g.sprites) * crew_row_h - (room_height - 8 - __crew_y0())); };
__sheet_prev_r = function() { return { x : room_width - (land ? 14 : 4) - 44, y : list_y + 22, w : 20, h : 13 }; };
__sheet_next_r = function() { return { x : room_width - (land ? 14 : 4) - 20, y : list_y + 22, w : 20, h : 13 }; };
__crew_row_r = function(_k) { return { x : big_x + 8, y : big_y + (land ? 112 : 76) + _k * 11 - 2, w : big_w - 16, h : 10 }; };
/// the diary painter: truth lines plain, "~ " lines as the crew's voice
/// (dimmer, indented), newest at the bottom, as many whole entries as
/// fit between y and y_end. col = the world's colour for the voice
__draw_log = function(_log, _x, _y, _w, _y_end, _col) {
	var _nl = array_length(_log);
	var _hs = array_create(_nl, 0);
	var _room = _y_end - _y;
	var _from = _nl;
	draw_set_font(fnt);
	for (var _i = _nl - 1; _i >= 0; _i--) {
		var _isv = (string_copy(_log[_i], 1, 2) == "~ ");
		var _h = string_height_ext(_isv ? string_delete(_log[_i], 1, 2) : _log[_i], 9, _w - (_isv ? 8 : 0)) + 2;
		if (_h > _room) break;
		_room -= _h;
		_hs[_i] = _h;
		_from = _i;
	}
	var _yy = _y;
	for (var _i = _from; _i < _nl; _i++) {
		var _isv = (string_copy(_log[_i], 1, 2) == "~ ");
		var _last = (_i == _nl - 1);
		if (_isv) {
			draw_set_color(_last ? merge_colour(sett_ink, c_white, .5) : merge_colour(sett_ink, _col, .35));
			draw_set_alpha(_last ? .9 : .55);
			draw_text_ext(_x + 8, _yy, string_delete(_log[_i], 1, 2), 9, _w - 8);
		} else {
			draw_set_color(_last ? c_white : sett_ink);
			draw_set_alpha(_last ? .95 : .7);
			draw_text_ext(_x, _yy, _log[_i], 9, _w);
		}
		_yy += _hs[_i];
	}
	draw_set_alpha(1);
};
/// the world in its box, turned by pl_spin and zoomed by pl_zoom, with the
/// regions' spots on it (the focused one ringed); the planet and region windows
__draw_world_box = function(_d) {
	var _b = exped_biomes()[_d.biome];
	var _bx = __pl_box();
	draw_sprite_ext(spr_pixel_1x1, 0, _bx.x, _bx.y, _bx.w, _bx.h, 0, c_black, .95);
	ui_fade_set(1);
	planet_sky_draw(_d.seed, _bx.x + 2, _bx.y + 2, _bx.w - 4, _bx.h - 4);
	var _pn = planet_get(_d.seed, exped_planet_hint(_d));
	var _pcx = _bx.x + _bx.w * .5, _pcy = _bx.y + _bx.h * .5, _ppr = min(_bx.w, _bx.h) * .3 * pl_zoom;
	if (_pn.row >= _pn.th) planet_draw(_pn, _pcx, _pcy, _ppr, pl_spin);
	else __portrait(_d, _pcx, _pcy, _ppr);
	// the spots: a dot a region where the same matrix puts it, the focused one ringed
	if (_pn.row >= _pn.th) {
		for (var _i = 0; _i < EXPED_REGIONS; _i++) {
			var _rg = region_get(_d, _i);
			var _n = __spot_view(_pn, pl_spin, _rg.spot.lon, _rg.spot.lat);
			if (_n[2] <= .05) continue;   // the far side
			var _sx = _pcx + _n[0] * _ppr, _sy = _pcy + _n[1] * _ppr;
			var _a = .4 + .6 * _n[2];
			draw_circle_colour(_sx, _sy, 2, c_white, c_white, false);
			if (_i == pl_focus) draw_circle_colour(_sx, _sy, 5 + dsin(current_time * .3) * 1.5, c_gold, c_gold, true);
			draw_set_color((_i == pl_focus) ? c_gold : c_white); draw_set_alpha(_a);
			draw_text(_sx + 6, _sy - 4, (_i == pl_focus) ? _rg.name : ("lv " + string(_rg.lv)));
		}
	}
	draw_px_rect(_bx.x, _bx.y, _bx.w, _bx.h, merge_colour(_b.col2, c_white, .2), .5);
	draw_set_alpha(1);
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
