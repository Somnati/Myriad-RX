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

view    = "planet";  // the pages: planet / depart / trip / haul / map / crew / galaxy / bestiary (THE HUB WENT, his call 2026-09-16: the panel opens on the world)
mode    = "exped";   // THE SPRITE MENU (2026-09-16, his ask): "sprites" = the crew page alone, as the roster's manager (exped_open("sprites", sid)) - no expedition strip, [dismiss] at the foot
// ([dismiss]'s arm-then-tap went 2026-09-17 - it asks through the confirm popup now, twice: confirm = "dismiss", then "dismiss2")
view_id = -1;        // the trip's or haul's id
// THE WORLD AT THE START (the hub went): the board's first world, orbit mode
pl_dest = undefined; sel_dest = 0; rg_sel = 0; pl_focus = -1;
if (is_struct(g[$ "exped"]) && array_length(g.exped.board) > 0) pl_dest = g.exped.board[0];
rp      = undefined; // the combat window's REPLAY of a fight that ended off screen: { i, t, r : the film }
seen_live = "";      // "tripid:room" of a fight watched live here - it is not replayed after
sheet_id = -1;       // the sheet view's sprite (his pitch, 2026-09-14: class / level / gear)
map_dest = undefined;    // the map view's world (its region: region_get)
map_plop_key = ""; map_plop_t0 = 0; map_plop_n = 0;   // THE PLOP (q289): which region's map is falling into place, since when, how many have landed (the ticks)
map_from = "planet";     // where the map returns to
pl_dest  = undefined;    // the planet window's world
rg_sel   = 0;            // the region picked in the planet window (EXPED_REGIONS a world)
map_rgi  = 0;            // the map view's region
pl_focus = -1;           // the planet window: the region the world has turned to (-1 = none, ambient spin)
crew_trip = -1;          // the crew menu shows only this trip's crew (-1 = everyone)
crew_from = "planet";    // where the crew menu returns to (the strip's [crew] is on every page - his ask, 2026-09-15)
// ---- THE BESTIARY (his ask, 2026-09-16, grid based): the roster in cells, a card for the one picked ----
bs_sel  = -1;            // the roster index picked (-1 none)
bs_from = "planet";      // where [back] returns to
__bs_cols   = function() { return land ? 8 : 5; };
__bs_grid_r = function() { var _c = __bs_cols(); return { x : land ? 14 : 4, y : list_y + 22, w : _c * 26 - 2, h : ceil(array_length(foe_roster()) / _c) * 26 - 2 }; };
__bs_cell_r = function(_i) { var _g = __bs_grid_r(), _c = __bs_cols(); return { x : _g.x + (_i mod _c) * 26, y : _g.y + (_i div _c) * 26, w : 24, h : 24 }; };
__bs_card_r = function() { var _g = __bs_grid_r(); if (land) return { x : _g.x + _g.w + 12, y : _g.y, w : room_width - 14 - (_g.x + _g.w + 12), h : room_height - 8 - _g.y }; return { x : 4, y : _g.y + _g.h + 8, w : room_width - 8, h : room_height - 8 - (_g.y + _g.h + 8) }; };
/// the ledger's entry for a kind ({ seen, slain, vars, boss }), or undefined
__bs_met = function(_kind) { var _bb = g.exped[$ "best"]; if (!is_struct(_bb)) return undefined; return _bb[$ _kind]; };
__hub_best_r = function() { var _g = __hub_gal_r(); return { x : _g.x + _g.w + 4, y : _g.y, w : 58, h : 14 }; };
it_pop   = undefined;    // the item popup: { it, sp, worn : bool, x, y }
it_rects = [];           // the sheet's item rows, laid down by the Draw for the Step's taps: { x, y, w, h, it, worn }
dp_quest = undefined;    // the departure window's quest (undefined = an explore)
dp_stance = "steady";    // THE STANCE (2026-09-16): cautious / steady / greedy - the pills in the mission box (exped_stance)
dp_stance_rects = [];    // ...their rects, laid down by the Draw for the Step's taps
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
rg_leave = false;                           // ...and swinging back out (the back button in region mode; the planet once it is out)
dp_sheet_a = 0; dp_sheet_v = -1;            // the sheet modal's fade, and the sprite it showed (kept for the fade out)
leg_a = 0; swap_a = 0;                      // the map's legend and the haul's roster list, fading
haul_last = undefined;                      // the haul the page last drew (it stands in through the fade-out after a collect)
view_last = "";                             // the view a frame ago: a change fades the new page in (the one veil, turn_px)
__dp_bw  = function() { return land ? 120 : (room_width - 8 - 18); };   // a banner's width
__dp_bh  = function() { return 28; };                                    // ...and its height (the name line, the hp row, the mp row - 2026-09-15: room for four digits)
__dp_list_r = function() { var _o = -(1 - dp_in) * 200; return { x : (land ? 14 : 4) + _o, y : list_y + 34, w : __dp_bw() + 18, h : room_height - 8 - (list_y + 34) }; };
__dp_row_r = function(_k) { var _l = __dp_list_r(); return { x : _l.x, y : _l.y + _k * (__dp_bh() + 4) - dp_off, w : __dp_bw(), h : __dp_bh() }; };
__dp_row_in = function(_k) { var _l = __dp_list_r(), _r = __dp_row_r(_k); return (_r.y >= _l.y - 1 && _r.y + _r.h <= _l.y + _l.h + 1); };   // the row wholly in the band
__dp_plus_r = function(_k) { var _r = __dp_row_r(_k); return { x : _r.x + _r.w + 2, y : _r.y, w : 16, h : _r.h }; };   // ([+] / [-] snug to the banner, as tall as it - his ask 2026-09-16)
__dp_off_max = function() { var _l = __dp_list_r(); return max(0, array_length(g.sprites) * (__dp_bh() + 4) - 4 - _l.h); };
/// THE MISSION BOX's layout: the text and the numbers, then the seats; the box grows to fit
__dp_layout = function() {
	var _o = (1 - dp_in) * 340;
	var _x = land ? (160 + _o) : (4 + _o), _y = list_y + 18;   // (just under the strip's [crew] [back] - 2026-09-16)
	var _w = land ? (room_width - 160 - 14) : (room_width - 8);
	var _tw = _w - 16;
	var _rg = region_get(pl_dest, rg_sel);
	var _q  = (dp_mode == "quest") ? dp_quest : undefined;
	var _xc = (dp_mode == "explore" && is_struct(dp_quest)) ? dp_quest : undefined;
	draw_set_font(fnt);
	var _ns = exped_party_max();
	var _cols = 1, _srows = _ns;   // THE SEATS: a vertical list of single-line rows (his ask, 2026-09-16) - four fit
	// the text's height: the ask, the objective paragraph, the number rows (10px
	// each) - and the paragraph DROPS when the box would run off the page
	// (2026-09-16: a long ask, a long objective and two hazard rows did)
	var _ask = is_struct(_q) ? _q.txt : (is_struct(_xc) ? _xc.txt : ("wander " + _rg.name + " until recalled"));
	var _obj = is_struct(_q) ? exped_quest_obj(_q, _rg, true) : (is_struct(_xc) ? _xc.note : "they pick their own way: inns when hurt and there is coin, shops, taverns (drink, bar fights, bounties), dungeons, camps, the wild. [recall] on the trip's page brings them home");
	var _nrows = (is_struct(_q) ? 5 : 4) + __dp_haz_rows() + 2;   // (+2: the stance's pills and its blurb, 2026-09-16)
	var _seats_h = 14 + _srows * (__dp_seat_h() + 2) + 4;
	var _pnt = (is_struct(_q) && (_q[$ "pnote"] ?? "") != "") ? (string_height_ext(_q.pnote, 9, _tw) + 4) : 0;   // (a personal card's note, 2026-09-16)
	var _th = string_height_ext(_ask, 9, _tw) + 4 + string_height_ext(_obj, 9, _tw) + _pnt + 6 + 10 * _nrows;
	var _para_on = true;
	if (_y + 6 + _th + _seats_h > room_height - 8) { _para_on = false; _th = string_height_ext(_ask, 9, _tw) + 4 + 10 * _nrows; }
	var _sy0 = _y + 6 + _th + 14;
	var _h = 6 + _th + _seats_h;
	return { x : _x, y : _y, w : _w, h : _h, tw : _tw, seat_y0 : _sy0, ns : _ns, cols : _cols, para_on : _para_on };
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
			var _h1 = region_hazard_at(pl_dest, _rg, _rg.nodes[clamp(_pls[_pi], 0, array_length(_rg.nodes) - 1)].kind);   // (the season's too, 2026-09-16)
			if (!is_struct(_h1)) continue;
			var _dup = false;
			for (var _hj = 0; _hj < array_length(_hzs); _hj++) if (_hzs[_hj].key == _h1.key) _dup = true;
			if (!_dup) array_push(_hzs, _h1);
		}
	}
	else _hzs = region_hazards(_rg, pl_dest);
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
__dp_seat_h = function() { return 12; };   // a seat row: one line - "Temoo (ranger)      lv 1"
__dp_seat_r = function(_j) { var _l = __dp_layout(); return { x : _l.x + 8, y : _l.seat_y0 + _j * (__dp_seat_h() + 2), w : _l.w - 16, h : __dp_seat_h() }; };
__dp_minus_r = function(_j) { return __dp_seat_r(_j); };   // (a press on a seat row unseats it; the list's [-] does too)
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
	draw_text(_x + 16 + string_width(str_cap(_sp.name)) + 5, _y + 3, _c.name);   // (no "ranger 1" - the level sits on the right, his ask 2026-09-15)
	// the level, right; "out" / "zz" to its left when they apply
	draw_set_halign(fa_right);
	draw_set_color(_ghost ? sett_ink : sett_ink); draw_set_alpha((_ghost ? .3 : .75) * _a);
	var _lvt = "lv " + string(_sh.lv);
	draw_text(_x + _w - 4, _y + 3, _lvt);
	if (_away)          { draw_set_alpha(.6 * _a); draw_text(_x + _w - 4 - string_width(_lvt) - 6, _y + 3, "out"); }
	else if (_sp.asleep) { draw_set_alpha(.6 * _a); draw_text(_x + _w - 4 - string_width(_lvt) - 6, _y + 3, "zz"); }
	draw_set_halign(fa_left);
	if (!_ghost) {
		// hp and mp, a row each (2026-09-15: four digits must fit - his note): a
		// label, the number right-aligned, and the bar sized to what is left
		var _st = sprite_stats(_sp), _bal = cbt_balance();
		var _hpr = floor(_st.pts.hp * _bal.hp_per_point + _bal.hp_flat_add), _mpr = max(1, round(_st.pts.mp));
		var _hpc = floor(_hpr * (_sp[$ "hpf"] ?? 1)), _mpc = round(_mpr * (_sp[$ "mpf"] ?? 1));
		if (is_struct(_ovr)) { _hpr = max(1, floor(_ovr.hpmax)); _hpc = clamp(floor(_ovr.hp), 0, _hpr); _mpr = max(1, round(_ovr.mpmax)); _mpc = clamp(round(_ovr.mp), 0, _mpr); }
		// (2026-09-16: the bar runs to the banner's edge on a dark shade of its own colour; the number sits over it in the outline font)
		var _rows = [[hp_bar_col(), "hp", _hpc, _hpr], [c_sblue, "mp", _mpc, _mpr]];
		for (var _ri = 0; _ri < 2; _ri++) {
			var _rw = _rows[_ri], _ly = _y + 12 + _ri * 8;
			var _num = string(_rw[2]) + "/" + string(_rw[3]);
			var _bx = _x + 16, _bw = max(8, (_x + _w - 3) - _bx);
			draw_set_color(_rw[0]); draw_set_alpha(.9 * _a); draw_text(_x + 4, _ly, _rw[1]);
			draw_sprite_ext(spr_pixel_1x1, 0, _bx, _ly + 1, _bw, 6, 0, merge_colour(_rw[0], c_black, .75), .9 * _a);
			draw_sprite_ext(spr_pixel_1x1, 0, _bx, _ly + 1, _bw * clamp(_rw[2] / max(1, _rw[3]), 0, 1), 6, 0, _rw[0], .85 * _a);
			draw_set_font(fnt_outline); draw_set_halign(fa_right); draw_set_color(c_white); draw_set_alpha(.95 * _a); draw_text(_x + _w - 4, _ly - 1, _num); draw_set_halign(fa_left); draw_set_font(fnt);
		}
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
__page_go = function(_v) { pg_next = _v; pg_dir = -1; if (_v == "map") map_pop = -1; if (_v == "haul") hl_open = false; };
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
big_x = land ? 14 : 4; big_y = land ? (list_y + 4) : (list_y + 22); big_w = land ? 150 : (room_width - 8); big_h = land ? 48 : 62;   // the render's box (the island runs on below it) - UP and tighter on a wide page (2026-09-15: four banners under it)
isle_h = land ? (big_h + 40) : (big_h + 66);                          // the island: the render, the name, the region and the sky, the leg (wide: the buttons live in the right column's foot)
log_x = land ? (big_x + big_w + 12) : 4; log_w = land ? (room_width - log_x - 12) : (room_width - 8);
log_y = land ? (list_y + 22) : (big_y + isle_h + 6 + exped_party_max() * (__dp_bh() + 2) + 4);   // (wide: under the strip's [crew] [back] - the island on the left may sit higher)    // (portrait: the island and the banners come first)
fight_s = 80;        // the combat window's side (grown from 64 - his ask; the right column's bottom-right corner)
wb_surf = -1;        // the page surfaces (__draw_orbit, the galaxy view): nothing spills past a rect; freed in the CleanUp
// THE CONFIRM POPUP (the save menu's shape, his ask 2026-09-15: abort asks first)
confirm  = "";       // "abort" while the question is up; "dismiss" then "dismiss2" (the "are you sure") for the sprite menu's [dismiss] - his ask, 2026-09-17
conf_a   = 0;
conf_hot = 0;
conf_kind = "";   // the LAST question asked (the popup keeps its face while it fades out - bug hunt 2026-09-17)
/// the popup itself (split out 2026-09-17 - two pages ask now): the veil,
/// the box with the ease, the question centred, [the deed] + [cancel]
__draw_confirm = function(_q, _lbl, _col) {
	if (conf_a <= .01) return;
	var _cr = __conf_rect();
	var _ce = conf_a * conf_a * (3 - 2 * conf_a);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, 0, room_width, room_height, 0, c_black, .55 * _ce);
	var _ry0 = _cr.y + (1 - _ce) * 8;
	draw_sprite_ext(spr_pixel_1x1, 0, _cr.x + 2, _ry0 + 3, _cr.w, _cr.h, 0, c_black, .5 * _ce);
	draw_sprite_ext(spr_pixel_1x1, 0, _cr.x, _ry0, _cr.w, _cr.h, 0, c_hsv(169, 186, 9), _ce);
	draw_px_rect(_cr.x, _ry0, _cr.w, _cr.h, _col, .8 * _ce);
	draw_set_halign(fa_center); draw_set_valign(fa_top);
	draw_set_color(c_white); draw_set_alpha(.95 * _ce);
	draw_text(_cr.x + _cr.w * .5, _ry0 + 12, _q);
	var _cb = __conf_btns();
	ui_fade_set(_ce);
	draw_ui_button(_cb[0].x, _cb[0].y - _cr.y + _ry0, _cb[0].w, _cb[0].h, _lbl, _col, true, true);
	draw_ui_button(_cb[1].x, _cb[1].y - _cr.y + _ry0, _cb[1].w, _cb[1].h, "cancel", rgb(170, 190, 230), true, false);
	draw_set_halign(fa_left);
	ui_fade_set(1);
};
/// the dismiss questions (the sprite named; the second is the "are you sure")
__dismiss_q = function(_sp) {
	if (conf_kind == "dismiss2") return "are you sure?\nthere is no getting " + _sp.name + " back.";
	return "let " + _sp.name + " go?\nthey leave the crew for good, with everything they carry.";
};
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
gxf_u = { time : shader_get_uniform(sh_galaxy_fog, "u_time"), dither : shader_get_uniform(sh_galaxy_fog, "u_dither"), seed : shader_get_uniform(sh_galaxy_fog, "u_seed"),
          freq : shader_get_uniform(sh_galaxy_fog, "u_freq"), warp : shader_get_uniform(sh_galaxy_fog, "u_warp"), gal : shader_get_uniform(sh_galaxy_fog, "u_gal") };   // (the map's fog handles, once - q215)
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
/// [back] shows on every page but the planet's own (there it was [close] - redundant beside the panel's X, his ask 2026-09-16); the other strip buttons slide into its seat
__back_on = function() { return mode != "sprites"; };   // (the sprite menu: one page, the X closes it; the planet page's [back] goes to the star system - q270, his ask)
__crewstrip_r = function() { var _b = __back_r(); return { x : __back_on() ? (_b.x - 4 - 44) : _b.x, y : _b.y, w : 44, h : 13 }; };   // [crew] beside [back], on every page but the hub's and the crew's own
// [map] beside [crew] (his call, 2026-09-16: "move the region map button to
// the top next to the crew button"): on every page that has a region -
// the planet page in region mode, the preparation page, the trip page
__mapstrip_r = function() { var _c = __crewstrip_r(); return { x : _c.x - 4 - 44, y : _c.y, w : 44, h : 13 }; };
/// [the gist] / [all] (2026-09-16): the diary's filter, left of [map] on the trip page, in [map]'s seat on the haul's (wide only)
__histrip_r = function() { var _m = is_undefined(__map_ctx()) ? __crewstrip_r() : __mapstrip_r(); return { x : _m.x - 4 - 44, y : _m.y, w : 44, h : 13 }; };
__histrip_on = function() { return (view == "trip" || (view == "haul" && land && hl_open)); };
/// the region the page is about -> { dest, rgi }, or undefined (no [map] then)
__map_ctx = function() {
	switch (view) {
		case "planet": if (pv_mode == "region" && !rg_leave && is_struct(pl_dest)) return { dest : pl_dest, rgi : rg_sel }; break;   // (not while region mode swings out)
		case "depart": if (is_struct(pl_dest) && dp_dir == 0 && dp_in > .99) return { dest : pl_dest, rgi : rg_sel }; break;      // (not mid-swing)
		case "trip":   { var _mt = __trip(); if (!is_undefined(_mt)) return { dest : _mt.dest, rgi : _mt[$ "rgi"] ?? 0 }; break; }
	}
	return undefined;
};
/// [back] and [crew] painted (the pages that render a sky call it again AFTER the sky - the render plane covers the row)
__draw_back = function() {
	var _bk = __back_r();
	draw_set_halign(fa_center);
	draw_set_color(c_white);
	draw_set_alpha(.9);
	if (__back_on()) {
		draw_sprite_ext(spr_pixel_1x1, 0, _bk.x, _bk.y, _bk.w, _bk.h, 0, c_black, .8);
		draw_px_rect(_bk.x, _bk.y, _bk.w, _bk.h, rgb(170, 190, 230), .5);
		draw_text(_bk.x + _bk.w * .5, _bk.y + 3, "back  >");
	}   // (the planet's is the panel's close - the hub went, 2026-09-16)
	if (view != "crew" && view != "hub" && mode != "sprites" && array_length(g.sprites) > 0) {
		var _cs = __crewstrip_r();
		draw_sprite_ext(spr_pixel_1x1, 0, _cs.x, _cs.y, _cs.w, _cs.h, 0, c_black, .8);
		draw_px_rect(_cs.x, _cs.y, _cs.w, _cs.h, c_steelblue, .5);
		draw_set_color(c_steelblue);
		draw_text(_cs.x + _cs.w * .5, _cs.y + 3, "crew");
	} else if (view == "crew" && mode != "sprites") {
		// (the crew's own page: its slot holds [bestiary] - 2026-09-16; the sprite menu has no strip)
		var _cs2 = __crewstrip_r();
		draw_sprite_ext(spr_pixel_1x1, 0, _cs2.x, _cs2.y, _cs2.w, _cs2.h, 0, c_black, .8);
		draw_px_rect(_cs2.x, _cs2.y, _cs2.w, _cs2.h, c_steelblue, .5);
		draw_set_color(c_steelblue);
		draw_text(_cs2.x + _cs2.w * .5, _cs2.y + 3, "bestiary");
	}
	if (!is_undefined(__map_ctx())) {
		var _ms = __mapstrip_r();
		draw_sprite_ext(spr_pixel_1x1, 0, _ms.x, _ms.y, _ms.w, _ms.h, 0, c_black, .8);
		draw_px_rect(_ms.x, _ms.y, _ms.w, _ms.h, c_steelblue, .5);
		draw_set_color(c_steelblue);
		draw_text(_ms.x + _ms.w * .5, _ms.y + 3, "map");
	}
	if (__histrip_on()) {
		var _hs = __histrip_r();
		draw_sprite_ext(spr_pixel_1x1, 0, _hs.x, _hs.y, _hs.w, _hs.h, 0, c_black, .8);
		draw_px_rect(_hs.x, _hs.y, _hs.w, _hs.h, log_hi ? c_gold : c_steelblue, .5);
		draw_set_color(log_hi ? c_gold : c_steelblue);
		draw_text(_hs.x + _hs.w * .5, _hs.y + 3, log_hi ? "the gist" : "all");
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
		case "map":    __page_go(map_from); break;
		case "galaxy": __page_go(gx_from); break;
		case "system": if (sy_Dt < 140) { sy_Dt = 250; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); return; } __page_go(sy_from); break;   // (zoomed in on the star: [back] zooms out first - his report, q271)   // (back to the map, or the planet page it came from - 2026-09-16)
		case "station": __page_go("system"); break;   // (the station page: back to its system - 2026-09-17)
		case "depart": if (dp_dir == 0) __dp_leave("planet"); return;   // (the page swings out first, then the region - __dp_leave)
		case "planet": if (pv_mode == "region") { if (rg_leave) return; __rg_leave(); } else { __sy_enter(galaxy_world_sys(pl_dest).star); sy_from = "galaxy"; __page_go("system"); } break;   // (the planet -> its star system, q270 - his ask; no back button closes the panel: the X does) region mode swings out -> the planet; the planet's [close] folds the panel (the hub went, 2026-09-16)
		case "crew":   __page_go((crew_trip >= 0) ? "trip" : crew_from); crew_trip = -1; it_pop = undefined; break;
		case "bestiary": __page_go(bs_from); break;
		default:       __page_go("planet"); break;
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
__trip_btn_r = function(_k) { if (land) return { x : log_x + _k * 64, y : room_height - 8 - 14, w : 60, h : 14 }; var _bw = floor((big_w - 8) / 2); return { x : big_x + 4 + _k * (_bw + 2), y : big_y + isle_h - 18, w : _bw - 2, h : 13 }; };   // (wide: the right column's foot - 2026-09-15)
__trip_crew_r  = function() { return __trip_btn_r(0); };
__trip_abort_r = function() { return __trip_btn_r(1); };   // ([map] left the foot for the strip, 2026-09-16)
__view_rg_r = function() { return { x : room_width - (land ? 14 : 4) - 96, y : room_height - 8 - 16, w : 96, h : 16 }; };   // [view region], bottom right, once a region is picked
// ---- THE ORBIT VIEW (the planet page, 2026-09-15: the tech demo's rm_planet in the panel) ----
// cam = view -> world: an ARCBALL for the hand (drag post-multiplies about
// the view's axes - grab the world and pull it; the glide keeps the flick;
// geosync pre-multiplies the spin so the spot you look at stays put), and
// THE TURNTABLE FOR THE SNAP (his call, 2026-09-16: the arcball rolled the
// world a little with every turn, and a rolled world's regions stop sitting
// where their longitude and latitude say - so a snap to a region eases the
// matrix toward __cam_tt's north-up view of it, along the one rotation
// between them; "the previous panning method when it's not snapping"). The
// sky and the sun come from the galaxy (pv_sky)
pv_cam   = mat3_rot(1, 0, 0, -32);   // pitched above the plane, like the demo
pv_spin  = 0;                        // the world's own-axis angle
lod_fade = 0;                             // THE TIER'S FADE-IN (q256): 0..1, __lod_step eases it once a tier lands under the view
tiers = new TierKeep();                   // THE ZOOM TIERS (2026-09-17; the keeper's own since q216): the page's world's 3x tier and four kept
pv_spin_seed = -1;                   // ...set from the clock when a world is first shown
pv_drag  = false; pv_px = 0; pv_dx = 0; pv_dy = 0; pv_vx = 0; pv_vy = 0;
pv_geo   = true;                     // (the camera rides the spin, always - the toggle went, his call 2026-09-16)
pv_face  = -1;                       // the region the camera is turning to face (-1 = none)
pv_dw    = false; pv_dwa = 0;        // the region drawer on the right: open, and its ease
pv_dtab  = 0;                        // THE DRAWER'S TAB (his ask, 2026-09-16): 0 regions, 1 active expeditions
pv_sky   = undefined;                // galaxy_sky_build() (the page's world's - __sky_for)
skies    = new SkyCache();           // A SKY A WORLD (2026-09-16; SkyCache's own since q216): galaxy_sky_build(d) by seed, the sun's bearing refreshed on every read
sky_met  = undefined;                // THE METEOR (2026-09-16): { x, y, dx, dy, t, life } in the orbit view's page space, one every sky_meteor seconds or so
sky_met_t = 0;                       // ...seconds since the last
__sky_bakes_free = function(_c) { skies.free_bakes(_c); };
__sky_for = function(_d) { return skies.get(_d); };
ex_system_init();   // THE STAR SYSTEM VIEW and THE STATION PAGE: their state and methods (ex_system_init - q217; the Step's and the Draw's parts are ex_system_step / ex_station_step / ex_system_press / ex_system_draw / ex_station_draw)
ex_planet_init();   // THE PLANET PAGE (the orbit view, region mode, the hand's cards, the page's buttons, the trip page's camera): its state, its rectangles and its small methods (ex_planet_init - q219)
ex_galaxy_init();   // THE GALAXY VIEW (the star map): its state and methods (ex_galaxy_init - q218; the Step's and the Draw's parts are ex_galaxy_step / ex_galaxy_draw)
// THE ONE VEIL (2026-09-15): every page fades in from black on a view
// change (view_last, the Step) - a proxy a step above the panel draws it,
// so no branch has to remember to (__draw_turn)
turn_px = create_obj(0, 0, obj_draw_proxy);
turn_px.owner = id;
turn_px.depth = depth - 1;
turn_px.fn = function() { __draw_turn(); };
ex_log_init();   // THE DIARY'S LOG: its scroll, its bar (sb), its layout and its band's painter (ex_log_init - q221)
ex_sheet_init();   // THE SHEET's painter (stats / gear / misc pages, its popups, the ability picker, the pips) and the crew page's rectangles and tabs (ex_sheet_init - q221)
ex_map_init();   // THE REGION MAP's painters (the nodes, the roads, the labels, the icons, the cards, the legend) and the planet page's info box and world box (ex_map_init - q221)
ex_orbit_init();   // THE ORBIT RENDERER and the worlds' building: __draw_orbit, the cameras, the small world, __worlds_step, the tier hooks (ex_orbit_init - q219)
/// a sprite by id (undefined when gone)
/// THE LOADING VEIL's question (his call, 2026-09-17: the boot's spinner moved
/// here - "trigger a loading screen like that when you first enter a planet
/// that needs loading"): undefined = the page has what it needs; else
/// { txt, prog } - the galaxy still charting in the background (syst_handle_
/// save), the board not yet rolled, or the page's world's rows / bake
/// unfinished (the planet page's and the trip's - the big renders; the haul's
/// and the preparation's portraits stand in with the lite one as before)
__loading = function() {
	if (mode == "sprites" || view == "crew" || view == "bestiary") return undefined;
	if (!galaxy_ready()) return { txt : "charting the galaxy", prog : galaxy_progress() };
	if (!is_struct(g[$ "exped"]) || array_length(g.exped.board) == 0) return { txt : "charting the galaxy", prog : 1 };
	// THE ONE-FRAME RACE (his first live test, 2026-09-18): the chart lands and syst_production rolls the board in the
	// same frame - AFTER this panel's Step took pl_dest from an empty board - so the Draw saw the galaxy ready, the board
	// full, and pl_dest undefined: "Variable <unknown_object>.biome cannot be resolved". A page that needs a world and
	// has none yet stays under the veil one more frame (the Step's line takes the board's world next)
	if ((view == "planet" || view == "depart" || view == "region") && !is_struct(pl_dest)) return { txt : "charting the galaxy", prog : 1 };
	var _d = undefined;
	if (view == "planet") _d = pl_dest;
	else if (view == "trip") { var _lt = __trip(); if (!is_undefined(_lt)) _d = _lt.dest; }
	// THE SYSTEM'S STAMPS (q202; his call: "any planets I view in new systems should also show a loading screen"): the
	// veil until every world of the system stands (planet_lite_ready; __sy_lite_step rushed by the veil's loop) - not
	// once a dive is under way (the veil would hold the dive)
	if (view == "system" && is_struct(sy_sys) && sy_warp_pl < 0 && sy_warp_st < 0) {
		var _n = array_length(sy_pd), _rdy = 0, _part = 0;
		for (var _i = 0; _i < _n; _i++) {
			var _sp = sy_pd[_i];
			if (planet_lite_ready(_sp)) { _rdy++; continue; }
			if (_part == 0 && is_struct(_sp)) _part = planet_build_progress(_sp);
		}
		if (_rdy < _n) return { txt : "surveying the " + star_name(sy_star) + " system", prog : (_rdy + _part) / max(1, _n) };
		return undefined;
	}
	if (!is_struct(_d)) return undefined;
	var _pn = planet_get(_d.seed, exped_planet_hint(_d));
	if (!planet_lite_ready(_pn)) return { txt : "building " + _d.name, prog : planet_build_progress(_pn) };   // (rows, then sheets - one bar, q225)
	// (the 3x tier no longer holds the veil - his call, q256, reversing q202's "no pop anywhere": the veil lifts on the
	// sheet, the tier finishes behind the orbit view and fades in through the shader when it lands under the zoom)
	return undefined;
};
ld_v = 0;   // the veil's bar, easing
__sp_by_id = function(_id) {
	for (var _i = 0; _i < array_length(g.sprites); _i++) if (g.sprites[_i].id == _id) return g.sprites[_i];
	return undefined;
};
__step_r = function() { return { x : log_x, y : room_height - 8 - 14 - (land ? 17 : 0), w : 70, h : 14 }; };   // [step turn], under the fight's lines, left of the window (over the buttons' row on a wide page)
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
