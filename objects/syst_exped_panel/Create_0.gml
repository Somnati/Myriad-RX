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
dp_look  = -1;           // the preparation page's INSPECTED sprite: its sheet in brief, a popup (tap a banner)
// THE PREPARATION PAGE (reworked 2026-09-15, his ask; round two the same
// day): the crew as BANNERS in a list on the left, a [+] beside each -
// tap the banner for its sheet (the crew page's own), tap [+] to seat it;
// THE MISSION BOX on the right with the SEATS inside it under the numbers
// (exped_party_max() of them - the box grows to fit), a [-] beside each
// seat to send one back. A seated banner leaves a grey ghost in its row
// until it is home again; banners SWING between the list and the seats
// (dp_pos). The list scrolls (dp_off) when the crew outgrows the band
dp_slots = array_create(exped_party_max(), -1);   // the seats: a sprite id each, -1 empty (sel_crew = the seated, in seat order)
dp_pos   = {};                              // sid -> { x, y } where the banner is drawn now (eased toward its seat or its row)
dp_off   = 0;                               // the list's scroll (px)
dp_ldrag = undefined;                       // { y0, off0, moved } while a finger drags the list
dp_in    = 0; dp_dir = 0; dp_next = "";     // THE SWING: the page slides in (0 -> 1) and out (dp_dir -1, then dp_next)
rg_in    = 0;                               // region mode's own swing (the info box from the left, the buttons from the right)
view_last = "";                             // the view a frame ago: a change fades the new page in (the one veil, turn_px)
__dp_bw  = function() { return land ? 120 : (room_width - 8 - 18); };   // a banner's width
__dp_bh  = function() { return 22; };                                    // ...and its height (the name line, the hp / mp line)
__dp_list_r = function() { var _o = -(1 - dp_in) * 200; return { x : (land ? 14 : 4) + _o, y : list_y + 34, w : __dp_bw() + 18, h : room_height - 8 - (list_y + 34) }; };
__dp_row_r = function(_k) { var _l = __dp_list_r(); return { x : _l.x, y : _l.y + _k * (__dp_bh() + 4) - dp_off, w : __dp_bw(), h : __dp_bh() }; };
__dp_row_in = function(_k) { var _l = __dp_list_r(), _r = __dp_row_r(_k); return (_r.y >= _l.y - 1 && _r.y + _r.h <= _l.y + _l.h + 1); };   // the row wholly in the band
__dp_plus_r = function(_k) { var _r = __dp_row_r(_k); return { x : _r.x + _r.w + 3, y : _r.y + 4, w : 14, h : 14 }; };
__dp_off_max = function() { var _l = __dp_list_r(); return max(0, array_length(g.sprites) * (__dp_bh() + 4) - 4 - _l.h); };
/// THE MISSION BOX's layout: the text and the numbers, then the seats; the box grows to fit
__dp_layout = function() {
	var _o = (1 - dp_in) * 340;
	var _x = land ? (160 + _o) : (4 + _o), _y = list_y + 22;
	var _w = land ? (room_width - 160 - 14) : (room_width - 8);
	var _tw = _w - 16;
	var _rg = region_get(pl_dest, rg_sel);
	var _q  = (dp_mode == "quest") ? dp_quest : undefined;
	var _xc = (dp_mode == "explore" && is_struct(dp_quest)) ? dp_quest : undefined;
	draw_set_font(fnt);
	var _th = 0;
	if (is_struct(_q)) {
		var _obj = exped_quest_obj(_q, _rg, true);   // (the one builder, 2026-09-15)
		_th = string_height_ext(_q.txt, 9, _tw) + 4 + string_height_ext(_obj, 9, _tw) + 6 + 11 * (5 + __dp_haz_rows());
	} else {
		var _xt = is_struct(_xc) ? _xc.txt : ("wander " + _rg.name + " until recalled");
		var _obj2 = is_struct(_xc) ? _xc.note : "they pick their own way: inns when hurt and there is coin, shops, taverns (drink, bar fights, bounties), dungeons, camps, the wild. [recall] on the trip's page brings them home";
		_th = string_height_ext(_xt, 9, _tw) + 4 + string_height_ext(_obj2, 9, _tw) + 6 + 11 * (4 + __dp_haz_rows());
	}
	var _ns = exped_party_max();
	var _sy0 = _y + 6 + _th + 14;
	var _h = 6 + _th + 14 + _ns * (__dp_bh() + 4) + 4;
	return { x : _x, y : _y, w : _w, h : _h, tw : _tw, seat_y0 : _sy0, ns : _ns };
};
__brief_r = function() { var _l = __dp_layout(); return { x : _l.x, y : _l.y, w : _l.w, h : _l.h }; };
/// THE HAZARDS of the mission (2026-09-15): a quest's place, or every one an explore's region carries; who in the seats holds each, who is bare
__dp_hazards = function() {
	var _out = [];
	if (!is_struct(pl_dest)) return _out;
	var _rg = region_get(pl_dest, rg_sel), _hzs = [];
	if (dp_mode == "quest" && is_struct(dp_quest)) {
		// every stop's hazard, each once (the two-stop kinds, 2026-09-15)
		var _pls = exped_quest_places(dp_quest);
		for (var _pi = 0; _pi < array_length(_pls); _pi++) {
			var _h1 = cbt_hazard_at(_rg.nodes[clamp(_pls[_pi], 0, array_length(_rg.nodes) - 1)].kind);
			if (!is_struct(_h1)) continue;
			var _dup = false;
			for (var _hj = 0; _hj < array_length(_hzs); _hj++) if (_hzs[_hj].key == _h1.key) _dup = true;
			if (!_dup) array_push(_hzs, _h1);
		}
	}
	else _hzs = region_hazards(_rg);
	for (var _i = 0; _i < array_length(_hzs); _i++) {
		var _hz = _hzs[_i], _held = [], _bare = [];
		for (var _j = 0; _j < array_length(dp_slots); _j++) {
			if (dp_slots[_j] < 0) continue;
			var _sp = __sp_by_id(dp_slots[_j]);
			if (is_undefined(_sp)) continue;
			if (cbt_hazard_hold(_sp, _hz).ok) array_push(_held, _sp.name); else array_push(_bare, _sp.name);
		}
		array_push(_out, { hz : _hz, held : _held, bare : _bare });
	}
	return _out;
};
/// ...and the rows they take in the mission box: one each, and one more under it when someone seated is bare (what holds it)
__dp_haz_rows = function() { var _l = __dp_hazards(), _r = 0; for (var _i = 0; _i < array_length(_l); _i++) _r += 1 + ((array_length(_l[_i].bare) > 0) ? 1 : 0); return _r; };
__dp_seat_r = function(_j) { var _l = __dp_layout(); return { x : _l.x + 8, y : _l.seat_y0 + _j * (__dp_bh() + 4), w : __dp_bw(), h : __dp_bh() }; };
__dp_minus_r = function(_j) { var _r = __dp_seat_r(_j); return { x : _r.x + _r.w + 4, y : _r.y + 4, w : 14, h : 14 }; };
__depart_r = function() { var _b = __brief_r(); return { x : _b.x + _b.w - 100, y : min(room_height - 8 - 16, _b.y + _b.h + 4) + (1 - dp_in) * 60, w : 100, h : 16 }; };
/// the seat a sprite sits in (-1 = the list)
__dp_seat_of = function(_sid) { for (var _j = 0; _j < array_length(dp_slots); _j++) if (dp_slots[_j] == _sid) return _j; return -1; };
/// sel_crew follows the seats (the odds, the bill, the departure read it)
__dp_sync = function() { sel_crew = []; for (var _j = 0; _j < array_length(dp_slots); _j++) if (dp_slots[_j] >= 0 && !is_undefined(__sp_by_id(dp_slots[_j]))) array_push(sel_crew, dp_slots[_j]); };
/// a sprite into the next free seat; a napping one wakes on the way
__dp_seat = function(_sid) {
	if (array_length(dp_slots) != exped_party_max()) { var _old = dp_slots; dp_slots = array_create(exped_party_max(), -1); for (var _k = 0; _k < min(array_length(_old), array_length(dp_slots)); _k++) dp_slots[_k] = _old[_k]; }
	var _sp = __sp_by_id(_sid);
	if (is_undefined(_sp) || (_sp[$ "trip"] ?? false) || __dp_seat_of(_sid) >= 0) { play_sound_ext(snd_matclick2, .7, .8, .35, 0); return false; }
	var _j = -1;
	for (var _k = 0; _k < array_length(dp_slots) && _j < 0; _k++) if (dp_slots[_k] < 0) _j = _k;
	if (_j < 0) { play_sound_ext(snd_matclick2, .7, .8, .35, 0); return false; }
	dp_slots[_j] = _sid;
	if (_sp.asleep) { _sp.asleep = false; _sp.hurt = 0; save_mark_dirty(); }
	__dp_sync();
	play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
	return true;
};
__dp_unseat = function(_sid) { var _j = __dp_seat_of(_sid); if (_j >= 0) dp_slots[_j] = -1; __dp_sync(); play_sound_ext(snd_softclick, .9, 1, .4, 1); };
/// the page swings out, then turns (the reverse of its entrance)
__dp_leave = function(_next) { dp_next = _next; dp_dir = -1; dp_sheet = -1; it_pop = undefined; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); };
/// a banner (22 tall): the colour bar and the dot, the name and class, then hp and mp - a thin bar each with the numbers beside
__dp_banner = function(_sp, _x, _y, _w, _a, _ghost, _ovr = undefined) {   // ovr = { hp, hpmax, mp, mpmax } (the trip page: the trip's, live in a fight)
	var _sh = sprite_sheet(_sp), _c = sprite_classes()[_sh.cls];
	var _away = (_sp[$ "trip"] ?? false);
	var _h = __dp_bh();
	draw_sprite_ext(spr_pixel_1x1, 0, _x, _y, _w, _h, 0, c_black, .8 * _a);
	draw_px_rect(_x, _y, _w, _h, _ghost ? sett_ink : _sp.col, (_ghost ? .25 : .6) * _a);
	draw_sprite_ext(spr_pixel_1x1, 0, _x, _y, 2, _h, 0, _sp.col, (_ghost ? .3 : .9) * _a);
	__dot(_x + 9, _y + 7, 3, _sp.col, (_ghost ? .3 : .95) * _a);
	draw_set_halign(fa_left); draw_set_valign(fa_top);
	draw_set_color(_ghost ? sett_ink : c_white); draw_set_alpha((_ghost ? .35 : .95) * _a);
	draw_text(_x + 16, _y + 3, str_cap(_sp.name));
	draw_set_color(_ghost ? sett_ink : _c.col); draw_set_alpha((_ghost ? .3 : .85) * _a);
	draw_text(_x + 16 + string_width(str_cap(_sp.name)) + 5, _y + 3, _c.name + " " + string(_sh.lv));
	if (_away) { draw_set_halign(fa_right); draw_set_color(sett_ink); draw_set_alpha(.6 * _a); draw_text(_x + _w - 4, _y + 3, "out"); draw_set_halign(fa_left); }
	else if (_sp.asleep) { draw_set_halign(fa_right); draw_set_color(sett_ink); draw_set_alpha(.6 * _a); draw_text(_x + _w - 4, _y + 3, "zz"); draw_set_halign(fa_left); }
	if (!_ghost) {
		// hp / mp: a label, a 3px bar, the numbers (the sheet's, condensed)
		var _st = sprite_stats(_sp), _bal = cbt_balance();
		var _hpr = floor(_st.pts.hp * _bal.hp_per_point + _bal.hp_flat_add), _mpr = max(1, round(_st.pts.mp));
		var _hpc = floor(_hpr * (_sp[$ "hpf"] ?? 1)), _mpc = round(_mpr * (_sp[$ "mpf"] ?? 1));
		if (is_struct(_ovr)) { _hpr = max(1, floor(_ovr.hpmax)); _hpc = clamp(floor(_ovr.hp), 0, _hpr); _mpr = max(1, round(_ovr.mpmax)); _mpc = clamp(round(_ovr.mp), 0, _mpr); }
		var _half = floor((_w - 8) * .5), _bw = max(8, _half - 14 - 26);
		var _ly = _y + 13;
		draw_set_color(c_hred); draw_set_alpha(.9 * _a); draw_text(_x + 4, _ly, "hp");
		draw_sprite_ext(spr_pixel_1x1, 0, _x + 15, _ly + 2, _bw, 3, 0, c_black, .7 * _a);
		draw_sprite_ext(spr_pixel_1x1, 0, _x + 15, _ly + 2, _bw * clamp(_hpc / max(1, _hpr), 0, 1), 3, 0, c_hred, .85 * _a);
		draw_set_color(sett_ink); draw_set_alpha(.9 * _a); draw_text(_x + 15 + _bw + 3, _ly, string(_hpc) + "/" + string(_hpr));
		var _mx = _x + 4 + _half;
		draw_set_color(c_sblue); draw_set_alpha(.9 * _a); draw_text(_mx, _ly, "mp");
		draw_sprite_ext(spr_pixel_1x1, 0, _mx + 11, _ly + 2, _bw, 3, 0, c_black, .7 * _a);
		draw_sprite_ext(spr_pixel_1x1, 0, _mx + 11, _ly + 2, _bw * clamp(_mpc / max(1, _mpr), 0, 1), 3, 0, c_sblue, .85 * _a);
		draw_set_color(sett_ink); draw_set_alpha(.9 * _a); draw_text(_mx + 11 + _bw + 3, _ly, string(_mpc) + "/" + string(_mpr));
	}
	draw_set_alpha(1);
};
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
card_w = land ? 150 : (room_width - 8); card_h = land ? (room_height - 8 - 14 - 6 - (list_y + 22)) : 178;   // ONE world: a tall card - the world, its name, its regions (redone 2026-09-15)
card_gap = land ? 6 : 3;
card_x0 = land ? 14 : 4;
card_y  = list_y + 22;                 // under the "the world" label
crew_y  = card_y + card_h + 10;
chip    = land ? 24 : 18; chip_gap = land ? 4 : 2;
list_x  = land ? (card_x0 + card_w + 14) : 4;
list_w  = land ? (room_width - list_x - 10) : (room_width - 8);
row_h   = land ? 44 : 40;              // a trip's island (redone 2026-09-15: four lines)

// ---- the trip view ----
// THE TRIP PAGE (polished 2026-09-15): the world's island on the left (the
// render, the name, the region, the leg, the buttons), the crew's banners
// under it; the quest's island and the diary on the right; the combat
// window in the right column's bottom-right corner
big_x = land ? 14 : 4; big_y = list_y + 22; big_w = land ? 150 : (room_width - 8); big_h = land ? 66 : 62;   // the render's box (the island runs on below it)
isle_h = big_h + 66;                                                  // the island: the render, the name and region, the leg, the buttons
log_x = land ? (big_x + big_w + 12) : 4; log_w = land ? (room_width - log_x - 12) : (room_width - 8);
log_y = land ? big_y : (big_y + isle_h + 6 + EXPED_PARTY * 24 + 4);    // (portrait: the island and the banners come first)
fight_s = 80;        // the combat window's side (grown from 64 - his ask; the right column's bottom-right corner)
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
__list_y0 = function() { return land ? (card_y - 10) : (card_y + card_h + 8); };   // (portrait: under the card)
__row_r  = function(_i) { return { x : list_x, y : __list_y0() + 12 + _i * (row_h + 4), w : list_w, h : row_h }; };
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
		case "depart": if (dp_dir == 0) __dp_leave("planet"); return;   // (the page swings out first, then the region - __dp_leave)
		case "planet": if (pv_mode == "region") { pv_mode = "planet"; rg_in = 0; } else view = "hub"; break;   // region mode -> the planet, the planet -> the hub
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
__trip_isle_r = function() { return { x : big_x, y : big_y, w : big_w, h : isle_h }; };
__trip_btn_r = function(_k) { var _bw = floor((big_w - 8) / 3); return { x : big_x + 4 + _k * (_bw + 2), y : big_y + isle_h - 18, w : _bw - 2, h : 13 }; };
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
__rgmap_r  = function() { var _g = __galaxy_r(); return { x : _g.x - (1 - rg_in) * 140, y : _g.y - 20, w : _g.w, h : 16 }; };   // [region map] (region mode; swings in from the left)
__geo_r    = function() { var _g = __galaxy_r(); return { x : _g.x, y : _g.y - ((pv_mode == "region") ? 40 : 20), w : _g.w, h : 16 }; };
__explore_r = function() { var _w = land ? 96 : 60; return { x : room_width - (land ? 14 : 4) - _w + (1 - rg_in) * 140, y : room_height - 8 - 16, w : _w, h : 16 }; };   // (region mode's swing: in from the right)
__quests_r  = function() { var _x = __explore_r(); return { x : _x.x, y : _x.y - 20, w : _x.w, h : 16 }; };
// region mode: the info box on the left (region_info's lines)
rg_box_w = 150; rg_box_h = 110;      // the info box's size, as its lines want (__info_box_size; the Draw keeps it fresh)
__rg_banner_r = function() { return { x : (land ? 14 : 4) - (1 - rg_in) * 220, y : list_y + 40, w : rg_box_w, h : rg_box_h }; };   // (region mode's swing: in from the left)
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
			var _nd = _rg.nodes[clamp(_q[$ "pi"] ?? _q.node, 0, array_length(_rg.nodes) - 1)];   // (the card's place: the first stop, 2026-09-15)
			var _kd = _kk[$ _nd.kind];
			var _obj = exped_quest_obj(_q, _rg, false);
			array_push(_faces, { title : _nd.name, sub : is_struct(_kd) ? _kd.name : _nd.kind, col : is_struct(_kd) ? _kd.col : c_gold, txt : _obj, haz : cbt_hazard_at(_nd.kind),
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
// THE ONE VEIL (2026-09-15): every page fades in from black on a view
// change (view_last, the Step) - a proxy a step above the panel draws it,
// so no branch has to remember to (__draw_turn)
turn_px = create_obj(0, 0, obj_draw_proxy);
turn_px.owner = id;
turn_px.depth = depth - 1;
turn_px.fn = function() { __draw_turn(); };
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
		return { x : log_x, y : log_y + 42, w : log_w, h : _yend - (log_y + 42) };   // (under the quest's island)
	}
	if (view == "haul") { var _cw = land ? 224 : (room_width - 8), _lx = (land ? 14 : 4) + _cw + 12; return { x : _lx, y : list_y + 22 + 12, w : room_width - _lx - 14, h : room_height - 10 - (list_y + 22 + 12) }; }
	return { x : 0, y : 0, w : 0, h : 0 };
};
gx_para = [];                        // the parallax backdrop's layers (built on the first draw)
__gx_r = function() { return { x : 0, y : list_y, w : room_width, h : room_height - list_y }; };
// the departure window: the crew chips left, the brief right, [depart] under the brief
/// THE SHEET (2026-09-15: one painter - the crew page draws it in its rail's shadow, the preparation page as a modal): the sprite's whole sheet from (x0, y0) to x1, the rows laid into it_rects for the taps
__draw_sheet = function(_sp, _x0, _y0, _x1) {
	var _ink = sett_ink, _dim = dim, _e = g.exped, _ea = g.ui_fade_a;
	var _sh = sprite_sheet(_sp);
	var _st = sprite_stats(_sp);
	var _c  = _st.cls;
	var _bal = cbt_balance();
	var _w = _x1 - _x0;
	// THE GROUND: black (the gradient came and went the same day - his call)
	var _gh0 = room_height - 8 - _y0;
	draw_sprite_ext(spr_pixel_1x1, 0, _x0, _y0, _w, _gh0, 0, c_black, .92);
	draw_px_rect(_x0, _y0, _w, _gh0, _sp.col, .35);
	// the header: the name, the class UNDER it (his ask), the personality
	// line further down; the level beside the xp bar (with its brothers)
	var _hx = _x0 + 8, _hy = _y0 + 6;
	// THE PORTRAIT: the room's blob (his ask, 2026-09-15), the name in the
	// big font capitalised, the class under it
	ui_fade_set(1);
	sprite_portrait(_sp, _hx + 7, _hy + 9, 1);   // (the room's size exactly - x2 was "HUGE")
	ui_fade_set(_ea);
	draw_set_font(fnt_large);
	draw_set_color(_sp.col); draw_set_alpha(.95);
	draw_text(_hx + 18, _hy - 2, str_cap(_sp.name));
	draw_set_font(fnt);
	draw_set_color(_c.col); draw_set_alpha(.95);
	draw_text(_hx + 18, _hy + 12, _c.name);
	var _pl = sprite_personalities();
	var _need = sprite_xp_need(_sh.lv);
	// THE LEVEL CORNER (his ask, 2026-09-15): "level N" above the bar at its
	// start, "next a / b" above it at its end, the bar between; no outline
	// (the tap rect is invisible; a highlight while its popup is up)
	var _xw = land ? 150 : 80, _xx = _x1 - 8 - _xw;
	if (is_struct(it_pop) && (it_pop[$ "lvup"] ?? false)) { draw_sprite_ext(spr_pixel_1x1, 0, _xx - 4, _hy - 3, _xw + 8, 18, 0, c_white, .1); draw_px_rect(_xx - 4, _hy - 3, _xw + 8, 18, c_white, .45); }
	draw_set_color(_ink); draw_set_alpha(.9);
	draw_text(_xx, _hy - 1, "level " + string(_sh.lv));
	draw_set_halign(fa_right); draw_set_color(_dim); draw_set_alpha(.7);
	draw_text(_x1 - 8, _hy - 1, "next  " + string(round(_sh.xp)) + " / " + string(_need));
	draw_set_halign(fa_left);
	draw_sprite_ext(spr_pixel_1x1, 0, _xx, _hy + 10, _xw, 3, 0, c_black, .7);
	draw_sprite_ext(spr_pixel_1x1, 0, _xx, _hy + 10, _xw * clamp(_sh.xp / max(1, _need), 0, 1), 3, 0, c_gold, .9);
	array_push(it_rects, { x : _xx - 4, y : _hy - 3, w : _xw + 8, h : 18, lvup : true });
	// HP / MP bars (the Disgaea row): the maxima - a sprite at home is whole
	var _hpr = floor(_st.pts.hp * _bal.hp_per_point + _bal.hp_flat_add);   // (whole hp - his ask; sprite_pawn floors the same)
	var _mpr = max(1, round(_st.pts.mp));
	// the current hp and mp: a sprite out on a trip carries them there; at
	// home they are what it came back with, climbing (sprites_tick)
	var _hpc = floor(_hpr * (_sp[$ "hpf"] ?? 1)), _mpc = round(_mpr * (_sp[$ "mpf"] ?? 1));
	for (var _t = 0; _t < array_length(_e.trips); _t++) {
		var _tt = _e.trips[_t];
		for (var _k = 0; _k < array_length(_tt.sids); _k++) if (_tt.sids[_k] == _sp.id) { _hpc = floor(min(_hpr, _tt.hp[_k])); if (is_array(_tt[$ "mp"]) && _k < array_length(_tt.mp)) _mpc = round(_mpr * _tt.mp[_k]); }
	}
	var _by = _hy + 28, _bw = land ? 150 : (_w - 16);
	// (the hp / mp rows and every stat are taps: what the stat does - his ask, 2026-09-15)
	var _hlw = _bw + 20;
	if (is_struct(it_pop) && it_pop[$ "st"] == "hp") { draw_sprite_ext(spr_pixel_1x1, 0, _hx - 2, _by - 1, _hlw, 10, 0, c_white, .1); draw_px_rect(_hx - 2, _by - 1, _hlw, 10, c_white, .45); }
	if (is_struct(it_pop) && it_pop[$ "st"] == "mp") { draw_sprite_ext(spr_pixel_1x1, 0, _hx - 2, _by + 9, _hlw, 10, 0, c_white, .1); draw_px_rect(_hx - 2, _by + 9, _hlw, 10, c_white, .45); }
	array_push(it_rects, { x : _hx - 2, y : _by - 1, w : _hlw, h : 10, st : "hp" });
	array_push(it_rects, { x : _hx - 2, y : _by + 9, w : _hlw, h : 10, st : "mp" });
	draw_set_color(c_hred); draw_set_alpha(.9); draw_text(_hx, _by, "hp");
	draw_sprite_ext(spr_pixel_1x1, 0, _hx + 18, _by + 2, _bw, 5, 0, c_black, .7);
	draw_sprite_ext(spr_pixel_1x1, 0, _hx + 18, _by + 2, _bw * clamp(_hpc / max(1, _hpr), 0, 1), 5, 0, c_hred, .8);
	draw_set_font(fnt_outline); draw_set_halign(fa_right); draw_set_color(c_white); draw_set_alpha(.9); draw_text(_hx + 18 + _bw - 2, _by - 1, string(_hpc) + " / " + string(_hpr)); draw_set_halign(fa_left); draw_set_font(fnt);
	draw_set_color(c_sblue); draw_set_alpha(.9); draw_text(_hx, _by + 10, "mp");
	draw_sprite_ext(spr_pixel_1x1, 0, _hx + 18, _by + 12, _bw, 5, 0, c_black, .7);
	draw_sprite_ext(spr_pixel_1x1, 0, _hx + 18, _by + 12, _bw * clamp(_mpc / max(1, _mpr), 0, 1), 5, 0, c_sblue, .8);
	draw_set_font(fnt_outline); draw_set_halign(fa_right); draw_set_color(c_white); draw_set_alpha(.9); draw_text(_hx + 18 + _bw - 2, _by + 9, string(_mpc) + " / " + string(_mpr)); draw_set_halign(fa_left); draw_set_font(fnt);
	// the stats grid (two columns of three), base + the gear's share
	var _keys = ["atk", "def", "mag", "mdef", "spd", "hit"];
	var _labels = ["atk", "def", "int", "res", "spd", "hit"];
	var _gy = _by + 26;
	for (var _k = 0; _k < 6; _k++) {
		var _cx = _hx + (_k mod 2) * (land ? 84 : 80), _cy = _gy + (_k div 2) * 11;
		array_push(it_rects, { x : _cx - 2, y : _cy - 1, w : 80, h : 10, st : _keys[_k] });
		if (is_struct(it_pop) && it_pop[$ "st"] == _keys[_k]) { draw_sprite_ext(spr_pixel_1x1, 0, _cx - 2, _cy - 1, 80, 10, 0, c_white, .1); draw_px_rect(_cx - 2, _cy - 1, 80, 10, c_white, .45); }
		draw_set_color(_dim); draw_set_alpha(.8);
		draw_text(_cx, _cy, _labels[_k]);
		draw_set_halign(fa_right);
		draw_set_font(fnt_outline); draw_set_color(c_white); draw_set_alpha(.95);
		draw_text(_cx + 58, _cy, string_format(_st.pts[$ _keys[_k]], 1, 1));
		draw_set_font(fnt); draw_set_halign(fa_left);
		var _g = _st.gear[$ _keys[_k]];
		if (_g > 0) { draw_set_color(c_sgreen); draw_set_alpha(.8); draw_text(_cx + 62, _cy, "+" + string_format(_g, 1, 1)); }
	}
	draw_set_color(_dim); draw_set_alpha(.7);
	draw_text(_hx, _gy + 34, "crit " + string(_c.crit) + "% x" + string(_c.cmulti) + "  -  counter " + string(_c.cnt) + "%");   // (the basics / points line went - his ask, 2026-09-15)
	draw_set_color(_dim); draw_set_alpha(.7);
	draw_text(_hx, _gy + 44, "mood  -  " + _pl[clamp(_sp.pers, 0, array_length(_pl) - 1)].name);
	// the equipment (the Disgaea list): slot - item
	var _ex = land ? (_x0 + 182) : _hx, _ey = land ? (_by) : (_gy + 48);   // (the column moved left - his ask: long names fell off the edge)
	draw_set_color(_ink); draw_set_alpha(.5);
	draw_text(_ex, _ey - 11, "equip");
	var _rows = [];
	array_push(_rows, { lbl : "weapon",  it : _sh.w1 });
	array_push(_rows, { lbl : "offhand", it : _sh.w2 });
	for (var _i = 0; _i < _c.armor; _i++) array_push(_rows, { lbl : "armor",    it : (_i < array_length(_sh.armor)) ? _sh.armor[_i] : undefined });
	for (var _i = 0; _i < _c.talis; _i++) array_push(_rows, { lbl : "talisman", it : (_i < array_length(_sh.talis)) ? _sh.talis[_i] : undefined });
	for (var _i = 0; _i < array_length(_rows); _i++) {
		var _rw = _rows[_i];
		var _ry = _ey + _i * 12;
		draw_sprite_ext(spr_pixel_1x1, 0, _ex, _ry - 1, _x1 - 8 - _ex, 11, 0, c_black, .35);
		if (!is_undefined(_rw.it)) array_push(it_rects, { x : _ex, y : _ry - 1, w : _x1 - 8 - _ex, h : 11, it : _rw.it, worn : true });
		// (the row whose popup is up wears a highlight - his ask)
		if (is_struct(it_pop) && !is_undefined(_rw.it) && it_pop[$ "it"] == _rw.it) { draw_sprite_ext(spr_pixel_1x1, 0, _ex, _ry - 1, _x1 - 8 - _ex, 11, 0, c_white, .1); draw_px_rect(_ex, _ry - 1, _x1 - 8 - _ex, 11, c_white, .45); }
		draw_set_color(_dim); draw_set_alpha(.8);
		draw_text(_ex + 3, _ry + 1, _rw.lbl);
		if (is_undefined(_rw.it)) { draw_set_color(_dim); draw_set_alpha(.4); draw_text(_ex + 46, _ry + 1, "(none)"); }
		else {
			// a long name is cut with ".." to the room before the level tag (the popup says it whole)
			var _nm = _rw.it.name, _navail = (_x1 - 11 - 20) - (_ex + 46);
			if (string_width(_nm) > _navail) { while (string_width(_nm + "..") > _navail && string_length(_nm) > 2) _nm = string_copy(_nm, 1, string_length(_nm) - 1); _nm += ".."; }
			draw_set_color(_rw.it.col); draw_set_alpha(.95);
			draw_text(_ex + 46, _ry + 1, _nm);
			draw_set_halign(fa_right); draw_set_color(_dim); draw_set_alpha(.6);
			draw_text(_x1 - 11, _ry + 1, "lv" + string(_rw.it.lv));
			draw_set_halign(fa_left);
		}
	}
	// the skills, under the stats; the pocket and the notepad under the equipment
	var _sk = sprite_skills(_sp);
	var _ky = _gy + 58;
	draw_set_color(_ink); draw_set_alpha(.5);
	draw_text(_hx, _ky, "skills");
	var _skw = land ? 168 : (_w - 16);
	for (var _i = 0; _i < array_length(_sk); _i++) {
		var _s = _sk[_i];
		var _ly = _ky + 11 + _i * 11;
		// a row like the gear's (his ask): tap it for what the skill does
		draw_sprite_ext(spr_pixel_1x1, 0, _hx - 3, _ly - 1, _skw, 10, 0, c_black, .35);
		array_push(it_rects, { x : _hx - 3, y : _ly - 1, w : _skw, h : 10, sk : _s });
		if (is_struct(it_pop) && it_pop[$ "sk"] == _s) { draw_sprite_ext(spr_pixel_1x1, 0, _hx - 3, _ly - 1, _skw, 10, 0, c_white, .1); draw_px_rect(_hx - 3, _ly - 1, _skw, 10, c_white, .45); }
		draw_set_color(_s.magic ? c_hpurple : c_horange); draw_set_alpha(.9);
		draw_text(_hx, _ly, _s.name);
		draw_set_halign(fa_right); draw_set_color(c_sblue); draw_set_alpha(.85);
		draw_text(_hx - 3 + _skw - 4, _ly, string(_s.cost) + " mp");
		draw_set_halign(fa_left);
	}
	var _py = _ey + array_length(_rows) * 12 + 4;
	draw_set_color(_ink); draw_set_alpha(.5);
	draw_text(_ex, _py, "pocket  " + string(array_length(_sh.inv)) + " / " + string(SPRITE_INV));
	var _pn = min(array_length(_sh.inv), 4);
	for (var _i = 0; _i < _pn; _i++) {
		if (is_struct(it_pop) && it_pop[$ "it"] == _sh.inv[_i]) { draw_sprite_ext(spr_pixel_1x1, 0, _ex, _py + 9 + _i * 9, _x1 - 8 - _ex, 9, 0, c_white, .1); draw_px_rect(_ex, _py + 9 + _i * 9, _x1 - 8 - _ex, 9, c_white, .45); }
		draw_set_color(_sh.inv[_i].col); draw_set_alpha(.6); draw_text(_ex + 4, _py + 10 + _i * 9, _sh.inv[_i].name);
		array_push(it_rects, { x : _ex, y : _py + 9 + _i * 9, w : _x1 - 8 - _ex, h : 9, it : _sh.inv[_i], worn : false });
	}
	if (array_length(_sh.inv) > _pn) { draw_set_color(_dim); draw_set_alpha(.4); draw_text(_ex + 4, _py + 10 + _pn * 9, "...and " + string(array_length(_sh.inv) - _pn) + " more"); }
	var _ny = _py + 10 + (min(array_length(_sh.inv), 4) + ((array_length(_sh.inv) > 4) ? 1 : 0)) * 9 + 4;
	draw_set_color(_ink); draw_set_alpha(.5);
	draw_text(_ex, _ny, "notepad  " + string(array_length(_sh.notes)) + " / " + string(SPRITE_NOTES));
	// wrapped to the column (his ask), newest at the bottom, as many as fit;
	// tap a note for what it does (the popup)
	var _ntw = _x1 - 8 - _ex - 6;
	var _nhs = array_create(array_length(_sh.notes), 0), _nroom = room_height - 10 - (_ny + 10), _n0 = array_length(_sh.notes);
	for (var _i = array_length(_sh.notes) - 1; _i >= 0; _i--) {
		var _nh = string_height_ext("- " + _sh.notes[_i].txt, 9, _ntw) + 1;
		if (_nh > _nroom) break;
		_nroom -= _nh; _nhs[_i] = _nh; _n0 = _i;
	}
	var _nyy = _ny + 10;
	for (var _i = _n0; _i < array_length(_sh.notes); _i++) {
		var _nt = _sh.notes[_i];
		if (is_struct(it_pop) && it_pop[$ "nt"] == _nt) { draw_sprite_ext(spr_pixel_1x1, 0, _ex, _nyy - 1, _x1 - 8 - _ex, _nhs[_i], 0, c_white, .1); draw_px_rect(_ex, _nyy - 1, _x1 - 8 - _ex, _nhs[_i], c_white, .45); }
		draw_set_color((_nt.tag != "") ? c_horange : _dim); draw_set_alpha((_nt.tag != "") ? .8 : .6);
		draw_text_ext(_ex + 4, _nyy, "- " + _nt.txt, 9, _ntw);
		array_push(it_rects, { x : _ex, y : _nyy - 1, w : _x1 - 8 - _ex, h : _nhs[_i], nt : _nt });
		_nyy += _nhs[_i];
	}
	if (array_length(_sh.notes) == 0) { draw_set_color(_dim); draw_set_alpha(.35); draw_text(_ex + 4, _ny + 10, "- (blank)"); }
	// THE ITEM POPUP (his ask, 2026-09-15): the item's lines, what it is worth
	// to this sprite (gear_score, the class's eye), and against what is
	// worn in its slot - the difference per line
	if (is_struct(it_pop) && !is_undefined(it_pop.sp) && (it_pop[$ "lvup"] ?? false)) {
		// THE NEXT LEVEL (his ask): each stat that climbs, and by how much
		var _lpsp = it_pop.sp, _lpsh = sprite_sheet(_lpsp), _lpc = sprite_classes()[_lpsh.cls], _lpb = cbt_balance();
		var _lkeys = ["hp", "atk", "def", "mag", "mdef", "spd", "hit", "mp"], _llab = ["hp", "atk", "def", "int", "res", "spd", "hit", "mp"];
		var _lpw = 120, _lph = 20 + 8 * 10 + 6;
		var _lpx = clamp(it_pop.x, 4, room_width - _lpw - 4), _lpy = clamp(it_pop.y, list_y + 20, room_height - _lph - 4);
		draw_sprite_ext(spr_pixel_1x1, 0, _lpx + 2, _lpy + 3, _lpw, _lph, 0, c_black, .5);
		draw_sprite_ext(spr_pixel_1x1, 0, _lpx, _lpy, _lpw, _lph, 0, c_hsv(169, 186, 9), .98);
		draw_px_rect(_lpx, _lpy, _lpw, _lph, c_gold, .8);
		draw_set_color(c_gold); draw_set_alpha(.95);
		draw_text(_lpx + 6, _lpy + 4, "next level up");
		for (var _j = 0; _j < 8; _j++) {
			var _gain = _lpc.shape[$ _lkeys[_j]] * SPRITE_LV_PTS / 40;
			if (_lkeys[_j] == "hp") _gain *= _lpb.hp_per_point;
			draw_set_color(_ink); draw_set_alpha(.85);
			draw_text(_lpx + 6, _lpy + 18 + _j * 10, _llab[_j]);
			draw_set_halign(fa_right); draw_set_color(c_sgreen); draw_set_alpha(.95);
			draw_text(_lpx + _lpw - 6, _lpy + 18 + _j * 10, "+" + string_format(_gain, 1, 1));
			draw_set_halign(fa_left);
		}
	} else if (is_struct(it_pop) && !is_undefined(it_pop.sp) && !is_undefined(it_pop[$ "st"])) {
		// THE STAT POPUP (his ask, 2026-09-15): what the stat does
		var _sdl = cbt_stat_desc(it_pop.st);
		var _sdw = 210, _sdh = 20;
		for (var _j = 1; _j < array_length(_sdl); _j++) _sdh += string_height_ext(_sdl[_j], 9, _sdw - 12) + 2;
		var _sdx = clamp(it_pop.x, 4, room_width - _sdw - 4), _sdy = clamp(it_pop.y, list_y + 20, room_height - _sdh - 4);
		draw_sprite_ext(spr_pixel_1x1, 0, _sdx + 2, _sdy + 3, _sdw, _sdh, 0, c_black, .5);
		draw_sprite_ext(spr_pixel_1x1, 0, _sdx, _sdy, _sdw, _sdh, 0, c_hsv(169, 186, 9), .98);
		draw_px_rect(_sdx, _sdy, _sdw, _sdh, c_white, .6);
		draw_set_color(c_white); draw_set_alpha(.95);
		draw_text(_sdx + 6, _sdy + 4, _sdl[0]);
		var _sdy2 = _sdy + 16;
		for (var _j = 1; _j < array_length(_sdl); _j++) {
			draw_set_color(_ink); draw_set_alpha(.9);
			draw_text_ext(_sdx + 6, _sdy2, _sdl[_j], 9, _sdw - 12);
			_sdy2 += string_height_ext(_sdl[_j], 9, _sdw - 12) + 2;
		}
	} else if (is_struct(it_pop) && !is_undefined(it_pop.sp) && !is_undefined(it_pop[$ "nt"])) {
		// THE NOTE POPUP (his ask): what a note does to the sprite
		var _pnt = it_pop.nt;
		var _ntxt = (_pnt.tag != "" && string_pos("foe:", _pnt.tag) == 1)
			? ("a STUDIED foe: +" + string(SPRITE_NOTE_HIT) + " to hit against " + string_delete(_pnt.tag, 1, 4) + "s in every fight from now on (the note counts once a kind)")
			: "a useless note. it changes nothing. they seem to like having it.";
		var _npw = 200, _nph = 30 + string_height_ext(_ntxt, 9, _npw - 12);
		var _npx = clamp(it_pop.x, 4, room_width - _npw - 4), _npy = clamp(it_pop.y, list_y + 20, room_height - _nph - 4);
		draw_sprite_ext(spr_pixel_1x1, 0, _npx + 2, _npy + 3, _npw, _nph, 0, c_black, .5);
		draw_sprite_ext(spr_pixel_1x1, 0, _npx, _npy, _npw, _nph, 0, c_hsv(169, 186, 9), .98);
		draw_px_rect(_npx, _npy, _npw, _nph, (_pnt.tag != "") ? c_horange : _dim, .8);
		draw_set_color((_pnt.tag != "") ? c_horange : _ink); draw_set_alpha(.95);
		draw_text_ext(_npx + 6, _npy + 4, "\"" + _pnt.txt + "\"", 9, _npw - 12);
		draw_set_color(_ink); draw_set_alpha(.85);
		draw_text_ext(_npx + 6, _npy + 8 + string_height_ext("\"" + _pnt.txt + "\"", 9, _npw - 12), _ntxt, 9, _npw - 12);
	} else if (is_struct(it_pop) && !is_undefined(it_pop.sp) && !is_undefined(it_pop[$ "sk"])) {
		// THE SKILL POPUP (his ask, 2026-09-15): what it does, when the ai uses it
		var _psk = it_pop.sk;
		var _slines = cbt_skill_desc(_psk);
		var _spw = 210, _sph = 22;
		for (var _j = 0; _j < array_length(_slines); _j++) _sph += string_height_ext(_slines[_j], 9, _spw - 12) + 2;
		var _spx = clamp(it_pop.x, 4, room_width - _spw - 4), _spy = clamp(it_pop.y, list_y + 20, room_height - _sph - 4);
		draw_sprite_ext(spr_pixel_1x1, 0, _spx + 2, _spy + 3, _spw, _sph, 0, c_black, .5);
		draw_sprite_ext(spr_pixel_1x1, 0, _spx, _spy, _spw, _sph, 0, c_hsv(169, 186, 9), .98);
		draw_px_rect(_spx, _spy, _spw, _sph, _psk.magic ? c_hpurple : c_horange, .8);
		draw_set_color(_psk.magic ? c_hpurple : c_horange); draw_set_alpha(.95);
		draw_text(_spx + 6, _spy + 4, _psk.name + ((_psk[$ "tmpl"] ?? -1) >= 0 ? "  -  its own" : "  -  the class's"));
		var _ty3 = _spy + 16;
		for (var _j = 0; _j < array_length(_slines); _j++) {
			draw_set_color((_j == array_length(_slines) - 1) ? _dim : _ink); draw_set_alpha((_j == array_length(_slines) - 1) ? .6 : .9);
			draw_text_ext(_spx + 6, _ty3, _slines[_j], 9, _spw - 12);
			_ty3 += string_height_ext(_slines[_j], 9, _spw - 12) + 2;
		}
	} else if (is_struct(it_pop) && !is_undefined(it_pop.sp) && !is_undefined(it_pop[$ "it"])) {
		var _it = it_pop.it, _psp = it_pop.sp;
		var _psh = sprite_sheet(_psp), _pcls = sprite_classes()[_psh.cls];
		var _lines = variable_struct_get_names(_it.pts);
		// what it would replace (the worst of a multi-slot)
		var _cmp = undefined;
		if (!it_pop.worn) {
			if (_it.slot == "w1" || _it.slot == "w2") _cmp = _psh[$ _it.slot];
			else { var _arr = _psh[$ _it.slot]; var _wsc = infinity; for (var _j = 0; _j < array_length(_arr); _j++) { var _s2 = gear_score(_psp, _arr[_j]); if (_s2 < _wsc) { _wsc = _s2; _cmp = _arr[_j]; } } }
		}
		var _pw = 168, _ph = 44 + array_length(_lines) * 10 + (is_undefined(_cmp) ? 0 : 12);
		var _ppx = clamp(it_pop.x, 4, room_width - _pw - 4), _ppy = clamp(it_pop.y, list_y + 20, room_height - _ph - 4);
		draw_sprite_ext(spr_pixel_1x1, 0, _ppx + 2, _ppy + 3, _pw, _ph, 0, c_black, .5);
		draw_sprite_ext(spr_pixel_1x1, 0, _ppx, _ppy, _pw, _ph, 0, c_hsv(169, 186, 9), .98);
		draw_px_rect(_ppx, _ppy, _pw, _ph, _it.col, .8);
		draw_set_color(_it.col); draw_set_alpha(.95);
		draw_text_ext(_ppx + 6, _ppy + 4, _it.name, 9, _pw - 12);
		var _ty2 = _ppy + 4 + string_height_ext(_it.name, 9, _pw - 12) + 2;
		draw_set_color(_dim); draw_set_alpha(.7);
		var _slotn = (_it.slot == "w1") ? "weapon" : ((_it.slot == "w2") ? "offhand" : ((_it.slot == "armor") ? "armor" : "talisman"));
		draw_text(_ppx + 6, _ty2, upgrade_rarity_info(_it.rar).name + " " + _it.fam + "  -  " + _slotn + "  -  lv " + string(_it.lv) + (it_pop.worn ? "  -  worn" : "  -  in the pocket"));
		_ty2 += 12;
		for (var _j = 0; _j < array_length(_lines); _j++) {
			var _ln = _lines[_j];
			var _v = _it.pts[$ _ln];
			var _wv = is_undefined(_cmp) ? 0 : (_cmp.pts[$ _ln] ?? 0);
			draw_set_color(_ink); draw_set_alpha(.9);
			draw_text(_ppx + 6, _ty2, _ln);
			draw_set_halign(fa_right);
			draw_set_color(c_sgreen);
			draw_text(_ppx + 70, _ty2, "+" + string_format(_v, 1, 1));
			if (!is_undefined(_cmp)) {
				var _dv = _v - _wv;
				draw_set_color((_dv > 0) ? c_sgreen : ((_dv < 0) ? c_hred : _dim)); draw_set_alpha(.85);
				draw_text(_ppx + _pw - 6, _ty2, ((_dv >= 0) ? "+" : "") + string_format(_dv, 1, 1) + " vs worn");
			}
			draw_set_halign(fa_left);
			_ty2 += 10;
		}
		if (!is_undefined(_cmp)) {
			// lines the worn one has that this one lacks
			var _wl = variable_struct_get_names(_cmp.pts);
			for (var _j = 0; _j < array_length(_wl); _j++) if (is_undefined(_it.pts[$ _wl[_j]])) { draw_set_color(c_hred); draw_set_alpha(.7); draw_text(_ppx + 6, _ty2, _wl[_j] + "  -" + string_format(_cmp.pts[$ _wl[_j]], 1, 1) + " vs worn"); _ty2 += 10; }
		}
		draw_set_color(c_gold); draw_set_alpha(.9);
		var _sc = gear_score(_psp, _it);
		draw_text(_ppx + 6, _ty2 + 2, "worth " + string_format(_sc, 1, 0) + " to " + _psp.name + " (" + _pcls.name + ")" + (is_undefined(_cmp) ? "" : ("  vs " + string_format(gear_score(_psp, _cmp), 1, 0))));
	}
};
dp_sheet = -1;   // the sheet modal on the preparation page: the sprite shown (-1 = none)
__dp_sheet_r = function() { var _x0 = land ? 58 : 4, _x1 = room_width - (land ? 58 : 4); return { x : _x0, y : list_y + 22, w : _x1 - _x0, h : room_height - 8 - (list_y + 22) }; };
/// a press on the sheet's rows (it_rects, laid by __draw_sheet): the popup - or a popup up closes; true when the press was the sheet's
__sheet_tap = function() {
	if (is_struct(it_pop)) { it_pop = undefined; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); return true; }
	for (var _k = 0; _k < array_length(it_rects); _k++) {
		var _ir = it_rects[_k];
		if (point_in_rectangle(mouse_x, mouse_y, _ir.x, _ir.y, _ir.x + _ir.w, _ir.y + _ir.h)) {
			it_pop = { it : _ir[$ "it"], sk : _ir[$ "sk"], nt : _ir[$ "nt"], st : _ir[$ "st"], lvup : _ir[$ "lvup"] ?? false, sp : __sp_by_id(sheet_id), worn : _ir[$ "worn"] ?? false, x : _ir.x, y : _ir.y + _ir.h + 2 };
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			return true;
		}
	}
	return false;
};
// (the chips and the old brief rects went with the preparation page's rework, 2026-09-15 - see __dp_* above)
__crewbtn_r = function() { return { x : card_x0, y : room_height - 8 - 14, w : 60, h : 14 }; };
// the crew menu: tabs down the left (one a sprite), the picked one's sheet on the right (his ask, 2026-09-14)
tab_w = land ? 78 : 60; tab_h = 15;
__tab_r = function(_k) { return { x : land ? 14 : 4, y : list_y + 22 + _k * (tab_h + 2), w : tab_w, h : tab_h }; };
__sheet_x0 = function() { return (land ? 14 : 4) + tab_w + 10; };
__recall_r = function() { return { x : log_x + log_w - 62, y : log_y + 4, w : 56, h : 12 }; };   // (in the quest island's corner)
__fight_r  = function() { return { x : log_x + log_w - fight_s, y : room_height - 8 - fight_s, w : fight_s, h : fight_s }; };   // the combat window: the right column's bottom-right corner
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
/// a road highlighted along its OWN polyline from fraction q0 of the way (arc length) to its end - the crew's route (the map)
__map_road_hl = function(_rg, _mr, _a, _b, _q0, _col, _al) {
	var _pts = undefined, _rev = false;
	for (var _e = 0; _e < array_length(_rg.edges); _e++) {
		var _ed = _rg.edges[_e];
		if (_ed.a == _a && _ed.b == _b) { _pts = _ed[$ "pts"]; break; }
		if (_ed.a == _b && _ed.b == _a) { _pts = _ed[$ "pts"]; _rev = true; break; }
	}
	if (!is_array(_pts) || array_length(_pts) < 2) {
		var _s1 = region_road_point(_rg, _a, _b, _q0), _s2 = _rg.nodes[clamp(_b, 0, array_length(_rg.nodes) - 1)];
		var _m1 = __map_xy(_s1, _rg, _mr), _m2 = __map_xy(_s2, _rg, _mr);
		draw_px_line(_m1.x, _m1.y, _m2.x, _m2.y, _col, _al);
		return;
	}
	// walk the polyline from a to b (reversed when stored the other way)
	var _n = array_length(_pts);
	var _seq = [];
	for (var _k = 0; _k < _n; _k++) array_push(_seq, _rev ? _pts[_n - 1 - _k] : _pts[_k]);
	var _len = 0;
	for (var _k = 1; _k < _n; _k++) _len += point_distance(_seq[_k - 1].x, _seq[_k - 1].y, _seq[_k].x, _seq[_k].y);
	var _want = clamp(_q0, 0, 1) * _len, _acc = 0;
	for (var _k = 1; _k < _n; _k++) {
		var _sl = point_distance(_seq[_k - 1].x, _seq[_k - 1].y, _seq[_k].x, _seq[_k].y);
		if (_acc + _sl <= _want) { _acc += _sl; continue; }
		var _f = (_sl > 0) ? clamp((_want - _acc) / _sl, 0, 1) : 0;
		var _p1 = { x : lerp(_seq[_k - 1].x, _seq[_k].x, _f), y : lerp(_seq[_k - 1].y, _seq[_k].y, _f) };
		var _m1 = __map_xy(_p1, _rg, _mr), _m2 = __map_xy(_seq[_k], _rg, _mr);
		draw_px_line(_m1.x, _m1.y, _m2.x, _m2.y, _col, _al);
		_acc += _sl; _want = -1;   // (the rest whole)
	}
};
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
__crew_row_r = function(_k) { return { x : big_x, y : big_y + isle_h + 6 + _k * 24, w : big_w, h : 22 }; };   // the crew's banners under the island (the preparation page's)
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
__step_r = function() { return { x : log_x, y : room_height - 8 - 14, w : 70, h : 14 }; };   // [step turn], under the fight's lines, left of the window
__col_r  = function() { return { x : (land ? 14 : 4) + 16, y : room_height - 8 - 16, w : 90, h : 16 }; };    // under the haul card, [send again] beside it
__again_r = function() { return { x : (land ? 14 : 4) + 118, y : room_height - 8 - 16, w : 90, h : 16 }; };
/// [SEND AGAIN] (his pick from the review, 2026-09-15: one tap, not five): this haul's crew, as they are, back to the same
/// region on the easiest open card - or a wander when the board there is empty. -> { ok, why, di, crew, mode, pick, slot, txt, short }
__again_plan = function(_h) {
	var _e = g.exped, _di = -1;
	for (var _i = 0; _i < array_length(_e.board); _i++) if (_e.board[_i].seed == _h.dest.seed) _di = _i;
	if (_di < 0) return { ok : false, why : "that world is off the board" };
	var _crew = [], _short = (_h[$ "routed"] ?? false);
	var _hhp = _h[$ "hp"] ?? [], _hhm = _h[$ "hpmax"] ?? [], _hmp = _h[$ "mp"] ?? [];
	for (var _k = 0; _k < array_length(_h.sids) && array_length(_crew) < exped_party_max(); _k++) {
		var _sp = __sp_by_id(_h.sids[_k]);
		if (is_undefined(_sp)) continue;
		array_push(_crew, _sp);
		if (_k < array_length(_hhp) && _k < array_length(_hhm) && _hhp[_k] < _hhm[_k]) _short = true;
		if (_k < array_length(_hmp) && _hmp[_k] < 1) _short = true;
	}
	if (array_length(_crew) == 0) return { ok : false, why : "nobody left to send" };
	var _rgi = _h[$ "rgi"] ?? 0;
	// the easiest open card (the hand's order: difficulty, then the shorter road)
	var _sl = exped_region_quests(_h.dest, _rgi), _best = -1;
	for (var _i = 0; _i < array_length(_sl); _i++) {
		if (_sl[_i].taken != 0) continue;
		var _q = _sl[_i].q;
		if (_best < 0 || _q.diff < _sl[_best].q.diff || (_q.diff == _sl[_best].q.diff && (_q[$ "hours"] ?? 0) < (_sl[_best].q[$ "hours"] ?? 0))) _best = _i;
	}
	var _mode = "quest", _pick = undefined, _txt = "";
	if (_best >= 0) { _pick = _sl[_best].q; _txt = _pick.txt + "  (" + _pick.diff_txt + ")"; }
	else { var _xc = exped_explore_cards(_h.dest, _rgi); if (array_length(_xc) == 0) return { ok : false, why : "nothing to do there" }; _mode = "explore"; _pick = _xc[0]; _txt = _pick.txt; }
	var _cost = exped_cost(_h.dest, array_length(_crew));
	credits_init();
	var _ok = (g.credits >= arb(_cost.total));
	return { ok : _ok, why : _ok ? "" : ("short of credits for another trip (" + string(_cost.total) + ")"), di : _di, crew : _crew, mode : _mode, pick : _pick, slot : _best, txt : _txt, short : _short };
};
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
