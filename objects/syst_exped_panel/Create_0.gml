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
dp_look  = -1;           // the departure window's INSPECTED sprite (the last chip tapped): its sheet in brief under the chips
__dlook_r = function() { var _rows = max(1, ceil(array_length(g.sprites) / (land ? 5 : 6))); var _y = dchip_y + _rows * (chip + 10) + 2; return { x : land ? 14 : 4, y : _y, w : land ? 156 : (room_width - 8), h : room_height - 8 - _y }; };
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
big_x = land ? 14 : 4; big_y = list_y + 20; big_w = land ? 150 : (room_width - 8); big_h = land ? 106 : 66;   // the world box holds the render only (2026-09-15: the banners moved under it)
log_x = land ? (big_x + big_w + 12) : 4; log_w = land ? (room_width - log_x - 12) : (room_width - 8);
log_y = land ? big_y : (big_y + big_h + 22 + EXPED_PARTY * 12 + 4);   // (portrait: the button row and the banners under the box come first)
fight_s = 64;        // the combat window's side
wb_surf = -1;        // the world box's surface (__draw_world_rect): the globe and its ring clipped at the box; freed in the CleanUp
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
		case "galaxy": view = gx_from; break;
		case "depart": view = "planet"; pv_mode = "region"; break;   // (back to the region, on the planet page)
		case "planet": if (pv_mode == "region") pv_mode = "planet"; else view = "hub"; break;   // region mode -> the planet, the planet -> the hub
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
// the trip page's buttons: a row UNDER the world box (his ask, 2026-09-15:
// "move the crew/map buttons off the world panel"): [crew] [map] [abort]
__trip_btn_r = function(_k) { var _bw = floor((big_w - 8) / 3); return { x : big_x + 4 + _k * (_bw + 2), y : big_y + big_h + 4, w : _bw - 2, h : 13 }; };
__trip_crew_r  = function() { return __trip_btn_r(0); };
__trip_abort_r = function() { return __trip_btn_r(2); };
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
__pv_r     = function() { return { x : 0, y : list_y + 16, w : room_width, h : room_height - (list_y + 16) }; };
__pv_c     = function() { var _r = __pv_r(); return { x : _r.x + _r.w * .5 - 46 * pv_dwa, y : _r.y + _r.h * .5 + 2 }; };   // (the world slides left as the drawer opens)
__pv_dw_w  = function() { return land ? 150 : 120; };
__pv_dw_x  = function() { return room_width - 9 - __pv_dw_w() * pv_dwa; };   // the drawer's left edge (its tab)
__pv_tab_r = function() { return { x : __pv_dw_x(), y : list_y + 22, w : 9, h : 60 }; };
__pv_row_r = function(_i) { return { x : __pv_dw_x() + 13, y : list_y + 40 + _i * 26, w : __pv_dw_w() - 8, h : 24 }; };
__galaxy_r = function() { return { x : land ? 14 : 4, y : room_height - 8 - 16, w : 64, h : 16 }; };   // [galaxy], bottom left of the planet page
__geo_r    = function() { var _g = __galaxy_r(); return { x : _g.x + _g.w + 4, y : _g.y, w : 90, h : 16 }; };   // the geosync toggle (the demo's), beside it
// region mode: the banner on the left, the quests (then explore) on the right
__rg_banner_r = function() { return { x : land ? 14 : 4, y : list_y + 40, w : land ? 150 : 120, h : 96 }; };
__rg_q_row = function(_i) { var _w = land ? 196 : 150; return { x : room_width - (land ? 14 : 4) - _w, y : list_y + 44 + _i * 30, w : _w, h : 27 }; };
__hub_gal_r = function() { var _c = __crewbtn_r(); return { x : _c.x + ((array_length(g.sprites) > 0) ? (_c.w + 4) : 0), y : _c.y, w : 64, h : 14 }; };
/// a region's spot as a unit vector in TEXTURE space (sphere_uv's frame)
__spot_dir = function(_lon, _lat) { return [dcos(_lat) * dcos(_lon), dsin(_lat), dcos(_lat) * dsin(_lon)]; };
/// a press on one of the page's controls is not a grab of the world
__pv_ui_hit = function() {
	var _bk = __back_r(); if (point_in_rectangle(mouse_x, mouse_y, _bk.x, _bk.y, _bk.x + _bk.w, _bk.y + _bk.h)) return true;
	var _g = __galaxy_r(); if (point_in_rectangle(mouse_x, mouse_y, _g.x, _g.y, _g.x + _g.w, _g.y + _g.h)) return true;
	var _ge = __geo_r(); if (point_in_rectangle(mouse_x, mouse_y, _ge.x, _ge.y, _ge.x + _ge.w, _ge.y + _ge.h)) return true;
	if (pv_mode == "region") {
		var _bn = __rg_banner_r(); if (point_in_rectangle(mouse_x, mouse_y, _bn.x, _bn.y, _bn.x + _bn.w, _bn.y + _bn.h)) return true;
		var _mr = __rg_map_r(); if (point_in_rectangle(mouse_x, mouse_y, _mr.x, _mr.y, _mr.x + _mr.w, _mr.y + _mr.h)) return true;
		for (var _qi = 0; _qi <= 3; _qi++) { var _qr = __rg_q_row(_qi); if (point_in_rectangle(mouse_x, mouse_y, _qr.x, _qr.y, _qr.x + _qr.w, _qr.y + _qr.h)) return true; }
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
	var _rgs = region_get(pl_dest, _i);
	var _pn3 = planet_get(pl_dest.seed, exped_planet_hint(pl_dest));
	pl_spin_t = __spin_for(_pn3, _rgs.spot.lon, _rgs.spot.lat);
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
__bloom = function(_src, _w, _h, _x, _y, _a) {
	var _hw = max(2, floor(_w * .5)), _hh = max(2, floor(_h * .5));
	if (!surface_exists(gx_glow_a) || surface_get_width(gx_glow_a) != _hw || surface_get_height(gx_glow_a) != _hh) { if (surface_exists(gx_glow_a)) surface_free(gx_glow_a); gx_glow_a = surface_create(_hw, _hh); }
	if (!surface_exists(gx_glow_b) || surface_get_width(gx_glow_b) != _hw || surface_get_height(gx_glow_b) != _hh) { if (surface_exists(gx_glow_b)) surface_free(gx_glow_b); gx_glow_b = surface_create(_hw, _hh); }
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
	draw_surface_ext(gx_glow_b, _x, _y, _w / _hw, _h / _hh, 0, c_white, _a);
	gpu_set_blendmode(bm_normal);
	gpu_set_tex_filter(_ftf);
};
__gx_mm_r = function() { var _sm = starmap_get(); var _w = 80; return { x : land ? 14 : 4, y : list_y + 34, w : _w, h : ceil(_sm.height * _w / _sm.width) }; };
log_off = 0;                         // THE DIARY'S SCROLL (his ask): lines back from the newest (0 = live); the wheel over the log moves it
/// the diary's rect on the page that shows one (the wheel's target)
__log_r = function() {
	if (view == "trip") return { x : log_x, y : log_y + 48, w : log_w, h : room_height - 10 - (log_y + 48) };
	if (view == "haul") { var _cw = land ? 224 : (room_width - 8), _lx = (land ? 14 : 4) + _cw + 12; return { x : _lx, y : list_y + 22, w : room_width - _lx - 14, h : room_height - 10 - (list_y + 22) }; }
	return { x : 0, y : 0, w : 0, h : 0 };
};
gx_para = [];                        // the parallax backdrop's layers (built on the first draw)
__gx_r = function() { return { x : 0, y : list_y + 16, w : room_width, h : room_height - (list_y + 16) }; };
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
__card_map_r = function(_i) { var _c = __card_r(_i); return { x : _c.x + _c.w - 27, y : _c.y + 3, w : 24, h : 10 }; };
__trip_map_r = function() { return __trip_btn_r(1); };
__crew_y0 = function() { return list_y + 22; };
__list_row_r = function(_k) { return { x : land ? 14 : 4, y : __crew_y0() + _k * crew_row_h - crew_off, w : room_width - (land ? 28 : 8), h : crew_row_h - 3 }; };   // (the crew LIST's rows; __crew_row_r is the trip page's)
__crew_max_off = function() { return max(0, array_length(g.sprites) * crew_row_h - (room_height - 8 - __crew_y0())); };
__sheet_prev_r = function() { return { x : room_width - (land ? 14 : 4) - 44, y : list_y + 22, w : 20, h : 13 }; };
__sheet_next_r = function() { return { x : room_width - (land ? 14 : 4) - 20, y : list_y + 22, w : 20, h : 13 }; };
// THE CREW'S BANNERS (his ask, 2026-09-15: under the world box): a row each
// under the button row - dot, name, level, the hp bar (live in a fight)
__crew_row_r = function(_k) { return { x : big_x, y : big_y + big_h + 22 + _k * 12, w : big_w, h : 11 }; };
/// the diary painter: truth lines plain, "~ " lines as the crew's voice
/// (dimmer, indented), "+ " lines as REWARDS (gold: xp, drops, credits -
/// his ask, 2026-09-15: the fight's end in the diary), newest at the
/// bottom, as many whole entries as fit between y and y_end. col = the
/// world's colour for the voice
__draw_log = function(_log, _x, _y, _w, _y_end, _col, _off = 0) {
	var _nl = array_length(_log) - clamp(_off, 0, max(0, array_length(_log) - 1));
	if (_off > 0) {
		// scrolled: a dim line says so, and the room above it is the log's
		draw_set_font(fnt); draw_set_color(sett_ink); draw_set_alpha(.4);
		draw_text(_x, _y_end - 8, "- " + string(_off) + " newer below - wheel down -");
		_y_end -= 10;
	}
	var _hs = array_create(_nl, 0);
	var _room = _y_end - _y;
	var _from = _nl;
	draw_set_font(fnt);
	for (var _i = _nl - 1; _i >= 0; _i--) {
		var _pre = string_copy(_log[_i], 1, 2);
		var _isv = (_pre == "~ ");
		var _h = string_height_ext(_isv ? string_delete(_log[_i], 1, 2) : _log[_i], 9, _w - (_isv ? 8 : 0)) + 2;
		if (_h > _room) break;
		_room -= _h;
		_hs[_i] = _h;
		_from = _i;
	}
	var _yy = _y;
	for (var _i = _from; _i < _nl; _i++) {
		var _pre = string_copy(_log[_i], 1, 2);
		var _isv = (_pre == "~ "), _isr = (_pre == "+ ");
		var _last = (_i == _nl - 1);
		if (_isv) {
			draw_set_color(_last ? merge_colour(sett_ink, c_white, .5) : merge_colour(sett_ink, _col, .35));
			draw_set_alpha(_last ? .9 : .55);
			draw_text_ext(_x + 8, _yy, string_delete(_log[_i], 1, 2), 9, _w - 8);
		} else if (_isr) {
			draw_set_color(_last ? merge_colour(c_gold, c_white, .3) : c_gold);
			draw_set_alpha(_last ? .95 : .8);
			draw_text_ext(_x, _yy, string_delete(_log[_i], 1, 2), 9, _w);
		} else {
			draw_set_color(_last ? c_white : sett_ink);
			draw_set_alpha(_last ? .95 : .7);
			draw_text_ext(_x, _yy, _log[_i], 9, _w);
		}
		_yy += _hs[_i];
	}
	draw_set_alpha(1);
};
/// THE WORLD IN A RECT, through a surface (wb_surf, 2026-09-15): the sky,
/// the globe at (pcx, pcy) of the rect with radius pr x zoom, and nothing
/// spills past the rect - a RING (the shader draws one on a ringed world;
/// the globe shrinks so the ring fits the rect at zoom 1) or the zoom on a
/// region is simply clipped. cfade 0..1 thins the clouds (planet_draw);
/// spots draws the regions: a 2px square each where the same matrix the
/// shader gets puts it, the far side skipped (z under .12), the focused
/// one in a pulsing hollow square (his ask: pixel, not a circle). The lite
/// portrait holds the spot while the world is still being built
__draw_world_rect = function(_d, _x, _y, _w, _h, _pcx, _pcy, _pr, _zoom, _spin, _cfade, _spots) {
	_w = max(2, floor(_w)); _h = max(2, floor(_h));
	if (!surface_exists(wb_surf) || surface_get_width(wb_surf) != _w || surface_get_height(wb_surf) != _h) {
		if (surface_exists(wb_surf)) surface_free(wb_surf);
		wb_surf = surface_create(_w, _h);
	}
	var _pn = planet_get(_d.seed, exped_planet_hint(_d));
	var _built = (_pn.row >= _pn.th);
	if (_built && _pn.ring) _pr = min(_pr, min(_w, _h) * .5 / 2.3);   // (the ring reaches 2.25 radii)
	_pr *= _zoom;
	var _fa = g.ui_fade_a;
	ui_fade_set(1);
	surface_set_target(wb_surf);
	draw_clear_alpha(c_black, 1);
	planet_sky_draw(_d.seed, 0, 0, _w, _h);
	if (_built) planet_draw(_pn, _pcx, _pcy, _pr, _spin, _cfade);
	else __portrait(_d, _pcx, _pcy, _pr);
	if (_spots && _built) {
		draw_set_font(fnt); draw_set_halign(fa_left); draw_set_valign(fa_top);
		var _pulse = floor(1.5 + 1.5 * dsin(current_time * .25));   // 0..3, in steps
		for (var _i = 0; _i < EXPED_REGIONS; _i++) {
			var _rg = region_get(_d, _i);
			var _n = __spot_view(_pn, is_undefined(_spin) ? 0 : _spin, _rg.spot.lon, _rg.spot.lat);
			if (_n[2] <= .12) continue;   // the far side, and the very limb
			// on the shader's 2px cell grid
			var _sx = floor(_pcx) + floor(_n[0] * _pr * .5) * 2, _sy = floor(_pcy) + floor(_n[1] * _pr * .5) * 2;
			var _on = (_i == pl_focus);
			draw_sprite_ext(spr_pixel_1x1, 0, _sx - 1, _sy - 1, 2, 2, 0, _on ? c_gold : c_white, 1);
			if (_on) {
				var _s = 6 + _pulse * 2;
				draw_px_rect(_sx - _s * .5, _sy - _s * .5, _s, _s, c_gold, .95);
				draw_px_rect(_sx - _s * .5 + 1, _sy - _s * .5 + 1, _s - 2, _s - 2, c_gold, .5);
			}
			if (_n[2] > .3) {
				draw_set_color(_on ? c_gold : c_white); draw_set_alpha(_on ? .95 : .8);
				draw_text(_sx + 6 + (_on ? 2 : 0), _sy - 4, _on ? _rg.name : ("lv " + string(_rg.lv)));
			}
		}
		draw_set_alpha(1);
	}
	surface_reset_target();
	ui_fade_set(_fa);
	draw_surface(wb_surf, _x, _y);
};
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
		wb_surf = surface_create(_w, _h);
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
	if (_built) planet_draw(_pn, _pcx, _pcy, _pr, _spin, _cfade, _cam, pv_sky.light_w);
	else __portrait(_d, _pcx, _pcy, _pr);
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
	draw_surface(wb_surf, _x, _y);
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
/// (the old small box: the region window's spinning world - retired 2026-09-15, the planet page's region mode took its place)
__draw_world_box = function(_d) {
	var _b = exped_biomes()[_d.biome];
	var _bx = __pl_box();
	var _cf = clamp(1 - (pl_zoom - 1) / (PL_ZOOM_IN - 1), 0, 1);
	__draw_world_rect(_d, _bx.x + 1, _bx.y + 1, _bx.w - 2, _bx.h - 2, (_bx.w - 2) * .5, (_bx.h - 2) * .5, min(_bx.w, _bx.h) * .3, pl_zoom, pl_spin, _cf, true);
	draw_px_rect(_bx.x, _bx.y, _bx.w, _bx.h, merge_colour(_b.col2, c_white, .2), .5);
	draw_set_alpha(1);
};
/// a world small (the hub's card, the list's rows, the haul's card): the
/// FULL world once it is built - clouds and ring (the globe at .62 so the
/// ring fits) - the lite portrait until then (his ask: every version
/// shows clouds). The caller has the fade off (the shader replaces it)
__world_small = function(_d, _cx, _cy, _r) {
	var _pn = planet_get(_d.seed, exped_planet_hint(_d));
	if (_pn.row >= _pn.th) planet_draw(_pn, _cx, _cy, _pn.ring ? (_r * .62) : _r);
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
		if (_pn.row < _pn.th) { planet_gen_step(_pn); return; }
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
