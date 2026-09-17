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
__back_on = function() { if (mode == "sprites") return false; return !(view == "planet" && pv_mode != "region"); };   // (the sprite menu: one page, the X closes it)
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
		case "system": __page_go(sy_from); break;   // (back to the map, or the planet page it came from - 2026-09-16)
		case "station": __page_go("system"); break;   // (the station page: back to its system - 2026-09-17)
		case "depart": if (dp_dir == 0) __dp_leave("planet"); return;   // (the page swings out first, then the region - __dp_leave)
		case "planet": if (pv_mode == "region") { if (rg_leave) return; if (hand != "") __hand_fold(); rg_leave = true; } else { exped_close(); return; } break;   // region mode swings out -> the planet; the planet's [close] folds the panel (the hub went, 2026-09-16)
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
pv_spin_seed = -1;                   // ...set from the clock when a world is first shown
pv_drag  = false; pv_px = 0; pv_dx = 0; pv_dy = 0; pv_vx = 0; pv_vy = 0;
pv_geo   = true;                     // (the camera rides the spin, always - the toggle went, his call 2026-09-16)
pv_face  = -1;                       // the region the camera is turning to face (-1 = none)
pv_dw    = false; pv_dwa = 0;        // the region drawer on the right: open, and its ease
pv_dtab  = 0;                        // THE DRAWER'S TAB (his ask, 2026-09-16): 0 regions, 1 active expeditions
pv_sky   = undefined;                // galaxy_sky_build() (the page's world's - __sky_for)
sky_c    = {};                       // A SKY A WORLD (2026-09-16): galaxy_sky_build(d) by seed; the sun's bearing refreshed on every read
sky_met  = undefined;                // THE METEOR (2026-09-16): { x, y, dx, dy, t, life } in the orbit view's page space, one every sky_meteor seconds or so
sky_met_t = 0;                       // ...seconds since the last
__sky_for = function(_d) {
	// (a sky is rebuilt after ten minutes: the siblings' spots are where they were WHEN IT WAS BUILT - cached for a session
	// they stood still while the system view's planets moved on; bug hunt 2026-09-16. The dust and the clouds are seeded: the same)
	var _k = string(_d.seed), _c = sky_c[$ _k];
	if (!is_struct(_c) || (current_time - (_c[$ "built"] ?? 0)) > 600000) { _c = galaxy_sky_build(_d); _c.built = current_time; sky_c[$ _k] = _c; }
	_c.light_w = galaxy_sun_dir(0, _d);
	return _c;
};
__gx_enter_r = function() { return { x : room_width - (land ? 14 : 4) - 80, y : room_height - 8 - 16, w : 80, h : 16 }; };   // [enter] the tapped star's system (bottom right, the demo's seat)
// THE STAR SYSTEM VIEW (his ask, 2026-09-16: the tech demo's, ported whole): orbits in the GALACTIC plane (world y = 0,
// the plane the sky's milky way lives in), a camera that orbits the star like the orbit view's orbits the world (drag +
// glide, wheel = distance), the planets as real sh_planet mini worlds (planet_get_lite: the same generation at 48x24),
// rings, their REAL moons (planet_moons) at their true phases, lit from the star by their true bearing, spinning by
// the universal clock; the local star's own sky behind (galaxy_sky_build for the star, no sun, no siblings); a tap
// picks (a pulsing box, the card), [enter] dives (the swell, then the world's page); a dock on the right: the star's
// numbers, the worlds listed
sy_star = -1; sy_sys = undefined; sy_sel = -1; sy_dest = undefined; sy_from = "galaxy";   // (sy_from: where [back] returns - the map, or the planet page)
sy_cam = mat3_rot(1, 0, 0, -55); sy_D = 250; sy_F = 230;
sy_drag = false; sy_drag_px = 0; sy_dx = 0; sy_dy = 0; sy_vx = 0; sy_vy = 0;
sy_warp_pl = -1; sy_warp_s = 1; sy_warp_t = 0; sy_wfx = 0; sy_wfy = 0;
sy_pd = [];                          // the lite worlds, one a planet (planet_get_lite)
sy_stns = [];                        // THE STAR'S SPACE STATIONS (station_sys, 2026-09-17): on their own rings, picked like a world
sy_belts = [];                       // THE ASTEROID BELTS (belt_sys, 2026-09-17): a crowd of rocks on a band, turning
sy_bsel = -1;                        // the belt tapped (its name in the caption, its row lit - nothing to enter)
sy_ssel = -1;                        // the picked station (-1 none; a station and a world are never both picked)
sy_warp_st = -1;                     // the dive, to a station (its page)
st_sel = -1;                         // THE STATION PAGE: which of sy_stns; its own camera and spin
st_cam = mat3_rot(1, 0, 0, -20); st_drag = false; st_drag_px = 0; st_dx = 0; st_dy = 0; st_vx = 0; st_vy = 0;
st_yaw = 0; st_pitch = -20;          // A TURNTABLE (his report, 2026-09-17: "it kinda skews when i rotate it" - a free arcball rolls; yaw and pitch never do)
__st_ppos = function(_st) { var _a = (_st.ang + _st.spd * 60 * universal_now()) mod 360; return [dcos(_a) * _st.orbit, 0, dsin(_a) * _st.orbit, _a]; };
sy_moons = [];                       // ...and their moons (planet_moons)
sy_info = [];                        // ...and their tiers (galaxy_world)
sy_cx = 0; sy_cy = 0;                // the projection's centre on the page
sy_dw = false; sy_dwa = 0;           // THE DOCK AS A DRAWER (his ask, 2026-09-16: the planet page's tab - the view slides left as it opens)
__sy_dock_w = function() { return land ? 150 : 110; };
__sy_dock_x = function() { return room_width - 9 - __sy_dock_w() * sy_dwa; };   // (the drawer's left edge: its tab when shut)
__sy_tab_r  = function() { return { x : __sy_dock_x(), y : list_y + 22, w : 9, h : 60 }; };
__sy_enter_r = function() { return { x : room_width - (land ? 14 : 4) - 80, y : room_height - 8 - 16, w : 80, h : 16 }; };   // [enter] bottom right while the drawer is shut
__sy_box_r  = function() { var _x = __sy_dock_x() + 9; return { x : _x, y : list_y + 16, w : room_width - _x, h : 54 }; };   // the star's numbers (the drawer's box runs to the edge)
__sy_row_r  = function(_i) { var _x = __sy_dock_x() + 13; return { x : _x, y : list_y + 16 + 58 + _i * 24, w : room_width - _x - 4, h : 22 }; };
__sy_open_r = function() { var _x = __sy_dock_x() + 13; return { x : _x, y : room_height - 8 - 16, w : room_width - _x - 4, h : 16 }; };
__sy_view_r = function() { return { x : 0, y : list_y, w : room_width, h : room_height - list_y }; };
/// one rock of a belt on the page (the polish, 2026-09-17): [sx, sy, k, b, belt, size, glint] under the swell - its size in cells, its glint a white flare over it
__rock_draw = function(_r, _s) {
	var _rx = floor(sy_wfx + (_r[0] - sy_wfx) * _s), _ry = floor(sy_wfy + (_r[1] - sy_wfy) * _s), _sz = _r[5];
	var _bl = sy_belts[_r[4]], _col = (sy_bsel == _r[4]) ? merge_colour(_bl.col, c_gold, .35) : _bl.col;
	draw_sprite_ext(spr_pixel_1x1, 0, _rx - (_sz div 2), _ry - (_sz div 2), _sz, _sz, 0, _col, clamp(_r[3] * (.35 + .65 * min(1, _r[2] * _s * 1.1)), .12, .95));
	if (_r[6] > 0) draw_sprite_ext(spr_pixel_1x1, 0, _rx - 1, _ry - 1, 3, 3, 0, c_white, _r[6] * .85);
};
/// world -> page: [sx, sy, scale, depth], or undefined when behind the camera
__sy_proj = function(_wx, _wy, _wz) {
	var _v = mat3_apply(mat3_transpose(sy_cam), _wx, _wy, _wz);
	var _dz = sy_D - _v[2];
	if (_dz < 24) return undefined;
	var _k = sy_F / _dz;
	return [sy_cx + _v[0] * _k, sy_cy + _v[1] * _k, _k, _dz];
};
/// a planet's world position on its orbit NOW (the universal clock)
__sy_ppos = function(_p) { var _a = (_p.ang + _p.spd * 60 * universal_now()) mod 360; return [dcos(_a) * _p.orbit, 0, dsin(_a) * _p.orbit, _a]; };
/// into a star's system: the system, the lite worlds, their moons, the tiers, the camera fresh
__sy_enter = function(_star) {
	var _sm = starmap_get();
	if (_star < 0 || _star >= _sm.count) return;
	sy_star = _star;
	sy_sys = starsystem_generate(_sm.stars[_star].seed, _sm.stars[_star].props);
	sy_sel = -1; sy_pd = []; sy_moons = []; sy_info = [];
	sy_stns = station_sys(_sm.stars[_star].seed, sy_sys); sy_ssel = -1; sy_warp_st = -1;   // (the star's stations, 2026-09-17)
	sy_belts = belt_sys(_sm.stars[_star].seed, sy_sys, sy_stns); sy_bsel = -1;   // (its belts, in the gaps the stations left)
	var _hm = galaxy_home();
	for (var _i = 0; _i < array_length(sy_sys.planets); _i++) {
		var _p = sy_sys.planets[_i];
		var _gw = galaxy_world(_star, _i);
		var _hint = is_struct(_gw) ? exped_planet_hint(_gw) : { kind : _p.kind, clim : _p.clim, ring : (_p[$ "has_ring"] ?? false) };
		array_push(sy_pd, planet_get_lite(_p.seed, _hint));
		array_push(sy_moons, planet_moons(_p.seed));
		array_push(sy_info, is_struct(_gw) ? _gw.tier : 0);
		if (is_struct(pl_dest) && pl_dest.seed == _p.seed) sy_sel = _i;
	}
	if (sy_sel < 0 && _star == _hm.star) sy_sel = _hm.planet;
	sy_dest = { seed : sy_sys.planets[0].seed, star : _star, pl : 0 };   // (a stand-in world of this star: the sky builder wants one)
	sy_cam = mat3_rot(1, 0, 0, -55); sy_D = 250; sy_vx = 0; sy_vy = 0; sy_drag = false; sy_dw = false; sy_dwa = 0;
	sy_warp_pl = -1; sy_warp_s = 1; sy_warp_t = 0;
};
/// THE STATION PAGE (2026-09-17, his ask: "click on one like I do a planet to
/// zoom in on it"): the system's sky behind, the station large in the
/// middle - its solid, lit by its star - turning under its own spin and the
/// drag's; the card bottom left says what it is
__draw_station = function() {
	var _vr = __sy_view_r();
	var _w = room_width, _h = room_height - list_y;
	if (!surface_exists(wb_surf) || surface_get_width(wb_surf) != _w || surface_get_height(wb_surf) != _h) { if (surface_exists(wb_surf)) surface_free(wb_surf); wb_surf = page_surface(_w, _h); }
	if (!surface_exists(sky_fog_surf) || surface_get_width(sky_fog_surf) != _w || surface_get_height(sky_fog_surf) != _h) { if (surface_exists(sky_fog_surf)) surface_free(sky_fog_surf); sky_fog_surf = surface_create(_w, _h); }
	var _st = sy_stns[st_sel];
	var _cx = room_width * .5, _cy = _vr.h * .5;
	var _sky = __sky_for(sy_dest);
	var _fa = g.ui_fade_a;
	ui_fade_set(1);
	surface_set_target(wb_surf);
	draw_clear_alpha(c_black, 1);
	galaxy_sky_draw(_sky, st_cam, _cx, _cy, _w, _h, false, false);
	galaxy_fog_draw(_sky, st_cam, _cx, _cy, _w, _h, sky_fog_surf, false);
	// lit from its star: from where it stands on its ring, the star is at the origin
	var _pp = __st_ppos(_st);
	var _lw = [-dcos(_pp[3]), .15, -dsin(_pp[3])];
	g.dither_off = page_float();
	station_render(_st, _cx, _cy, min(_w, _h) * .27, st_cam, _lw);
	g.dither_off = false;
	surface_reset_target();
	ui_fade_set(_fa);
	page_blit(wb_surf, 0, list_y);
};
/// the star system page painted into the page surface: the star's sky, the rings, the star and the worlds far to near
__draw_system = function() {
	var _vr = __sy_view_r();
	var _w = room_width, _h = room_height - list_y;
	if (!surface_exists(wb_surf) || surface_get_width(wb_surf) != _w || surface_get_height(wb_surf) != _h) { if (surface_exists(wb_surf)) surface_free(wb_surf); wb_surf = page_surface(_w, _h); }
	if (!surface_exists(sky_fog_surf) || surface_get_width(sky_fog_surf) != _w || surface_get_height(sky_fog_surf) != _h) { if (surface_exists(sky_fog_surf)) surface_free(sky_fog_surf); sky_fog_surf = surface_create(_w, _h); }
	sy_cx = room_width * .5 - __sy_dock_w() * sy_dwa * .5; sy_cy = _vr.h * .52;   // (page space: centred, slid left as the drawer opens)
	var _sky = __sky_for(sy_dest);
	var _fa = g.ui_fade_a;
	ui_fade_set(1);
	surface_set_target(wb_surf);
	draw_clear_alpha(c_black, 1);
	galaxy_sky_draw(_sky, sy_cam, sy_cx, sy_cy, _w, _h, false, false);
	galaxy_fog_draw(_sky, sy_cam, sy_cx, sy_cy, _w, _h, sky_fog_surf, false);   // (no sun on this sky: the star is drawn as itself)
	var _pls = sy_sys.planets, _np = array_length(_pls), _s = sy_warp_s;
	var _cfgp = planet_config(), _pxs = max(1, _cfgp.px_size);
	// the dive's focus: the picked world's spot anchors the swell
	sy_wfx = sy_cx; sy_wfy = sy_cy;
	if (sy_warp_pl >= 0) { var _fpp0 = __sy_ppos(_pls[sy_warp_pl]); var _fpp = __sy_proj(_fpp0[0], 0, _fpp0[2]); if (!is_undefined(_fpp)) { sy_wfx = _fpp[0]; sy_wfy = _fpp[1]; } }
	if (sy_warp_st >= 0) { var _fsp0 = __st_ppos(sy_stns[sy_warp_st]); var _fsp = __sy_proj(_fsp0[0], 0, _fsp0[2]); if (!is_undefined(_fsp)) { sy_wfx = _fsp[0]; sy_wfy = _fsp[1]; } }   // (the dive to a station - 2026-09-17)
	// the orbit rings: true circles in the plane, as grid-snapped cells (the demo's)
	for (var _i = 0; _i < _np; _i++) {
		var _or = _pls[_i].orbit, _stp = max(.4, _pxs * 55 / max(1, _or)), _lcx = -10000, _lcy = -10000;
		for (var _a = 0; _a < 360; _a += _stp) {
			var _rp = __sy_proj(dcos(_a) * _or, 0, dsin(_a) * _or);
			if (is_undefined(_rp)) continue;
			var _gx = floor((sy_wfx + (_rp[0] - sy_wfx) * _s) / _pxs) * _pxs, _gy = floor((sy_wfy + (_rp[1] - sy_wfy) * _s) / _pxs) * _pxs;
			if (_gx == _lcx && _gy == _lcy) continue;
			_lcx = _gx; _lcy = _gy;
			draw_sprite_ext(spr_pixel_1x1, 0, _gx, _gy, _pxs, _pxs, 0, (sy_sel == _i) ? c_gold : c_white, (sy_sel == _i) ? .3 : .14);
		}
	}
	// THE STATIONS' RINGS (2026-09-17): dashed, in the hull's colour - one in twelve cells, so a world's ring and a station's read apart
	for (var _j = 0; _j < array_length(sy_stns); _j++) {
		var _sor = sy_stns[_j].orbit, _sstp = max(.4, _pxs * 55 / max(1, _sor)), _slcx = -10000, _slcy = -10000, _dash = 0;
		for (var _a = 0; _a < 360; _a += _sstp) {
			var _srp = __sy_proj(dcos(_a) * _sor, 0, dsin(_a) * _sor);
			if (is_undefined(_srp)) continue;
			var _sgx = floor((sy_wfx + (_srp[0] - sy_wfx) * _s) / _pxs) * _pxs, _sgy = floor((sy_wfy + (_srp[1] - sy_wfy) * _s) / _pxs) * _pxs;
			if (_sgx == _slcx && _sgy == _slcy) continue;
			_slcx = _sgx; _slcy = _sgy; _dash++;
			if ((_dash mod 3) != 0) continue;
			draw_sprite_ext(spr_pixel_1x1, 0, _sgx, _sgy, _pxs, _pxs, 0, (sy_ssel == _j) ? c_gold : sy_stns[_j].hull, (sy_ssel == _j) ? .4 : .22);
		}
	}
	// z-sort the star, the worlds and the stations, far to near (a station is item 1000 + its index)
	var _items = [];
	var _sp0 = __sy_proj(0, 0, 0);
	if (!is_undefined(_sp0)) array_push(_items, [_sp0[3], -1, _sp0[0], _sp0[1], _sp0[2]]);
	for (var _i = 0; _i < _np; _i++) { var _pp0 = __sy_ppos(_pls[_i]); var _pp = __sy_proj(_pp0[0], 0, _pp0[2]); if (!is_undefined(_pp)) array_push(_items, [_pp[3], _i, _pp[0], _pp[1], _pp[2]]); }
	for (var _j = 0; _j < array_length(sy_stns); _j++) { var _sq0 = __st_ppos(sy_stns[_j]); var _sq = __sy_proj(_sq0[0], 0, _sq0[2]); if (!is_undefined(_sq)) array_push(_items, [_sq[3], 1000 + _j, _sq[0], _sq[1], _sq[2]]); }
	// THE BELTS' ROCKS (2026-09-17): every rock where it stands now - NOT in the sort (five hundred of them, sorted
	// every frame, would be the cost): split at the star's depth, the far half painted before everything, the
	// near half after (a rock over a far world reads right; a rock behind the star but before a farther world is a pixel wrong)
	var _bnow = universal_now(), _rk_far = [], _rk_near = [], _sdz = is_undefined(_sp0) ? sy_D : _sp0[3];
	var _gslot = floor(_bnow / .45), _gfr = frac(_bnow / .45);   // THE GLINTS' clock: a slot a little under half a second (each rock its own phase below)
	for (var _b = 0; _b < array_length(sy_belts); _b++) {
		var _bl = sy_belts[_b], _rks = _bl.rocks;
		// THE DUST (the polish, 2026-09-17): a faint dithered band under the rocks, three radii, brighter nearer - the belt reads edge-on too
		var _dcol = (sy_bsel == _b) ? merge_colour(_bl.col, c_gold, .5) : _bl.col;
		for (var _dr = -1; _dr <= 1; _dr++) {
			var _drad = _bl.orbit + _dr * _bl.width * .3, _dstp = max(.6, _pxs * 70 / max(1, _drad)), _dlx = -10000, _dly = -10000, _dn = 0;
			for (var _a = 0; _a < 360; _a += _dstp) {
				var _dp = __sy_proj(dcos(_a) * _drad, 0, dsin(_a) * _drad);
				if (is_undefined(_dp)) continue;
				var _dgx = floor((sy_wfx + (_dp[0] - sy_wfx) * _s) / _pxs) * _pxs, _dgy = floor((sy_wfy + (_dp[1] - sy_wfy) * _s) / _pxs) * _pxs;
				if (_dgx == _dlx && _dgy == _dly) continue;
				_dlx = _dgx; _dly = _dgy; _dn++;
				if ((_dn + _dr) mod 2 == 0) continue;   // (dithered: every other cell)
				draw_sprite_ext(spr_pixel_1x1, 0, _dgx, _dgy, _pxs, _pxs, 0, _dcol, ((sy_bsel == _b) ? .16 : .07) * (.6 + .4 * min(1, _dp[2] * 1.1)));
			}
		}
		for (var _k = 0; _k < array_length(_rks); _k++) {
			var _rk = _rks[_k], _ra = (_rk[1] + _rk[4] * 60 * _bnow) mod 360;
			var _rp = __sy_proj(dcos(_ra) * _rk[0], _rk[2], dsin(_ra) * _rk[0]);
			if (is_undefined(_rp)) continue;
			// A GLINT (the polish): a facet catching the star - a hash per rock per slot, the odd one flares and decays through its slot
			var _gl = 0;
			if (_rk[3] > .55) { var _gph = floor((_bnow + _k * .173) / .45), _gr = hash_mix(_k * 31 + _b * 977, _gph) mod 1000; if (_gr > 993) _gl = power(1 - frac((_bnow + _k * .173) / .45), 2.5); }
			array_push((_rp[3] > _sdz) ? _rk_far : _rk_near, [_rp[0], _rp[1], _rp[2], _rk[3], _b, _rk[5], _gl]);
		}
		// THE BIG ONES: into the sort with the worlds and the stations (item 3000 + belt x 8 + which)
		for (var _bi = 0; _bi < array_length(_bl.bigs); _bi++) {
			var _bg = _bl.bigs[_bi], _ba = (_bg.a0 + _bg.spd * 60 * _bnow) mod 360;
			var _bp = __sy_proj(dcos(_ba) * _bg.r, _bg.y, dsin(_ba) * _bg.r);
			if (!is_undefined(_bp)) array_push(_items, [_bp[3], 3000 + _b * 8 + _bi, _bp[0], _bp[1], _bp[2]]);
		}
	}
	for (var _k = 0; _k < array_length(_rk_far); _k++) __rock_draw(_rk_far[_k], _s);
	array_sort(_items, function(_a, _b) { return _b[0] - _a[0]; });
	g.dither_off = page_float();
	for (var _n = 0; _n < array_length(_items); _n++) {
		var _it = _items[_n];
		var _sx = sy_wfx + (_it[2] - sy_wfx) * _s, _sy = sy_wfy + (_it[3] - sy_wfy) * _s, _k = _it[4] * _s;
		if (_it[1] < 0) {
			// the star: sh_star (star_draw, 2026-09-16) - the disc, its corona and prominences; the same star its worlds' skies show
			var _stc = sy_sys.star.col, _ss = sy_sys.star.size * _k / 12;
			star_draw(_sx, _sy, 6 * _ss, _stc, sy_star * .37, 1, sy_cam);
		} else if (_it[1] >= 3000) {
			// A BIG ROCK of a belt (the polish, 2026-09-17): a small tumbling solid, lit from the star
			var _bb = sy_belts[(_it[1] - 3000) div 8].bigs[(_it[1] - 3000) mod 8], _bba = (_bb.a0 + _bb.spd * 60 * _bnow) mod 360;
			station_render(_bb.st, _sx, _sy, max(1.5, _bb.size * _k * 1.2), sy_cam, [-dcos(_bba), 0, -dsin(_bba)], (_bnow * 60 * _bb.st.spin) mod 360);
		} else if (_it[1] >= 1000) {
			// A STATION on its ring (2026-09-17): its solid, lit from the star; picked = the pulsing box, like a world's
			var _j = _it[1] - 1000, _stj = sy_stns[_j], _sq1 = __st_ppos(_stj);
			var _srad = max(2, _stj.size * _k * 1.2);
			var _svv = mat3_apply(mat3_transpose(sy_cam), _sq1[0], _sq1[1], _sq1[2]);   // (the eye sits at view z = sy_D: the ray toward it - no shear off the centre)
			station_render(_stj, _sx, _sy, _srad, sy_cam, [-dcos(_sq1[3]), 0, -dsin(_sq1[3])], undefined, [_svv[0], _svv[1], _svv[2] - sy_D]);
			if (sy_ssel == _j && sy_warp_pl < 0 && sy_warp_st < 0) { var _mr3 = _srad * 1.7 + 3 + dsin(current_time * .25) * 1.2; draw_px_rect(_sx - _mr3, _sy - _mr3, _mr3 * 2, _mr3 * 2, c_white, .8); }
		} else {
			var _i = _it[1], _p = _pls[_i], _pd = sy_pd[_i];
			var _pw = __sy_ppos(_p);
			var _rad = max(1.5, _p.size * _k * 1.2);
			// lit from the star: toward the origin from the world, in the plane (world space - planet_draw turns it through the camera)
			planet_draw(_pd, _sx, _sy, _rad, undefined, 1, sy_cam, [-dcos(_pw[3]), 0, -dsin(_pw[3])]);
			// its moons at their true phases, as the demo drew them: pixel dots on the plane
			var _mns = sy_moons[_i], _mn = min(4, _p[$ "moon_n"] ?? 0);
			for (var _m = 0; _m < _mn; _m++) {
				var _mo = _mns[_m];
				var _ma = _mo.ang + _mo.spd * 60 * universal_now(), _mr = _p.size * _mo.dist;
				var _mp = __sy_proj(_pw[0] + dcos(_ma) * _mr, 0, _pw[2] + dsin(_ma) * _mr);
				if (is_undefined(_mp)) continue;
				var _mx = sy_wfx + (_mp[0] - sy_wfx) * _s, _my = sy_wfy + (_mp[1] - sy_wfy) * _s, _ms = max(1, _mo.size * _p.size * 2 * _mp[2] * _s);
				draw_sprite_ext(spr_pixel_1x1, 0, _mx - _ms * .5, _my - _ms * .5, _ms, _ms, 0, _mo.col, .9);
			}
			// picked: the pulsing box (no mark for the opened ones - his call, 2026-09-16: the worlds need not know they have been)
			if (sy_sel == _i && sy_warp_pl < 0) { var _mr2 = _rad * 1.7 + 3 + dsin(current_time * .25) * 1.2; draw_px_rect(_sx - _mr2, _sy - _mr2, _mr2 * 2, _mr2 * 2, c_white, .8); }
			// "you": the world the panel stands on (the home world when nothing does)
			var _here = is_struct(pl_dest) ? (pl_dest.seed == _p.seed) : (galaxy_home().planet_seed == _p.seed);
			if (_here && sy_warp_pl < 0) {
				var _bob = abs(dsin(current_time * .25)) * 3, _ty = floor(_sy - _rad - 6 - _bob);
				draw_sprite_ext(spr_pixel_1x1, 0, floor(_sx) - 3, _ty - 3, 7, 1, 0, c_sgreen, .95); draw_sprite_ext(spr_pixel_1x1, 0, floor(_sx) - 2, _ty - 2, 5, 1, 0, c_sgreen, .95); draw_sprite_ext(spr_pixel_1x1, 0, floor(_sx) - 1, _ty - 1, 3, 1, 0, c_sgreen, .95); draw_sprite_ext(spr_pixel_1x1, 0, floor(_sx), _ty, 1, 1, 0, c_sgreen, .95);
				draw_set_halign(fa_center); draw_set_color(c_sgreen); draw_set_alpha(.95); draw_text(floor(_sx), _ty - 13, "you"); draw_set_halign(fa_left);
			}
		}
	}
	// ...the near half of the belts' rocks, over everything
	for (var _k = 0; _k < array_length(_rk_near); _k++) __rock_draw(_rk_near[_k], _s);
	g.dither_off = false;
	surface_reset_target();
	ui_fade_set(_fa);
	page_blit(wb_surf, 0, list_y);
};
pv_mat_m = [1, 0, 0, 0, 1, 0, 0, 0, 1];   // texture-from-view, published by the draw for the step's pick
pv_mat_r = [1, 0, 0, 0, 1, 0, 0, 0, 1];   // ...and its inverse (the spots)
pv_mode  = "planet";                 // "planet" (the world, the drawer) or "region" (pulled in on the pick: the banner, the quests)
pv_zoom  = 1;                        // region mode's pull-in (PV_ZOOM_RG), eased
pv_cfade = 1;                        // ...and the clouds thinning with it
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
__pv_pick = function(_i) {
	rg_sel = _i; pl_focus = _i; pv_face = _i;
	play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
};
// ---- THE GALAXY VIEW (the star map, 2026-09-15: the tech demo's rm_starmap as a page) ----
gx_x = 0; gx_y = 0; gx_zoom = 1; gx_init = false;   // the camera's top-left on the plane, the zoom; centred on the home star the first time
gx_press = false; gx_px = 0; gx_py = 0; gx_cx0 = 0; gx_cy0 = 0; gx_travel = 0;
gx_sel = -1; gx_sys = undefined;     // the tapped star and its system
gx_from = "planet";                  // where [back] returns
gx_mm = -1; gx_mm_seed = -1;         // THE MINIMAP (his ask: bring it back): the star dots baked once, 80px wide
gx_glow_a = -1; gx_glow_b = -1;      // the bloom's two half-size passes (sh_blur)
/// the bloom: the finished map (src, w x h) blurred at half size, two
/// passes, laid back over the target additively at alpha a
// THE BLOOM composites INTO the page (2026-09-15): float all the way, so
// the halos meet 8-bit only at the page's blit (x / y are kept for the
// 8-bit path, where it still lands on the screen)
__bloom = function(_src, _w, _h, _x, _y, _a, _ds = 1, _into = false) {   // (_into: back into the source whatever the page - the skies, 2026-09-16)   // (ds: the draw scale on the page - the map's surface is drawn gs times over, 2026-09-16)
	var _hw = max(2, floor(_w * .5 * _ds)), _hh = max(2, floor(_h * .5 * _ds));   // (half the ROOM's size: a denser source blurs the same width)
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
	shader_set_uniform_f(_u.dir, 1, 0); shader_set_uniform_f(_u.texel, 1 / (_w * _ds), 1 / (_h * _ds));
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
	if (page_float() || _into) { surface_set_target(_src); draw_surface_ext(gx_glow_b, 0, 0, _w / _hw, _h / _hh, 0, c_white, _a); surface_reset_target(); }
	else draw_surface_ext(gx_glow_b, _x, _y, _w * _ds / _hw, _h * _ds / _hh, 0, c_white, _a);
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
log_hi = false;                                    // THE GIST (2026-09-16): the diary's highlights only (exped_log_gist), the strip's toggle
hl_open = false;                                   // THE HAUL'S DIARY (2026-09-16): behind [read the diary] on the home page
log_gist = { n : -1, id : -1, arr : [] };         // ...the filtered lines, cached by the source's length and the page
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
	var _src = undefined;
	if (view == "trip") { var _t = __trip(); _src = is_undefined(_t) ? undefined : _t.log; }
	else if (view == "haul") { var _h = __haul_i(); _src = (_h < 0) ? undefined : g.exped.hauls[_h].log; }
	if (!is_array(_src) || !log_hi) return _src;
	// THE GIST (2026-09-16): the highlights only (exped_log_gist), the first line always; cached by the source's length and the page
	if (log_gist.n != array_length(_src) || log_gist.id != view_id) {
		var _arr = [];
		for (var _i = 0; _i < array_length(_src); _i++) if (_i == 0 || exped_log_gist(_src[_i])) array_push(_arr, _src[_i]);
		log_gist = { n : array_length(_src), id : view_id, arr : _arr };
	}
	return log_gist.arr;
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
			var _isv = (_pre == "~ "), _ish = (_pre == "# "), _isk = (_pre == "* ");   // (the voice, a place header, the sky - 2026-09-16)
			var _h = string_height_ext((_isv || _ish || _isk || _pre == "+ ") ? string_delete(_log[_i], 1, 2) : _log[_i], 9, _w - (_isv ? 8 : 0)) + 2 + (_ish ? 6 : 0);
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
	var _nl = is_array(_log) ? array_length(_log) : 0;
	for (var _i = 0; _i < _nl; _i++) {
		var _lh = _lay.hs[_i];
		if (_yy + _lh >= 0 && _yy <= _h) {
			var _pre = string_copy(_log[_i], 1, 2);
			var _isv = (_pre == "~ "), _isr = (_pre == "+ "), _ish = (_pre == "# "), _isk = (_pre == "* ");
			var _last = (_i == _nl - 1);
			// a place header (2026-09-16): a rule, then the line in the world's colour; the sky's lines dim
			if (_ish) { draw_sprite_ext(spr_pixel_1x1, 0, 0, _yy + 2, _w, 1, 0, _col, .35); draw_set_color(merge_colour(_col, c_white, .55)); draw_set_alpha(_last ? .95 : .9); draw_text_ext(0, _yy + 6, string_delete(_log[_i], 1, 2), 9, _w); }
			else if (_isk) { draw_set_color(merge_colour(sett_ink, _col, .5)); draw_set_alpha(_last ? .8 : .5); draw_text_ext(0, _yy, string_delete(_log[_i], 1, 2), 9, _w); }
			else if (_isv) { draw_set_color(_last ? merge_colour(sett_ink, c_white, .5) : merge_colour(sett_ink, _col, .35)); draw_set_alpha(_last ? .9 : .55); draw_text_ext(8, _yy, string_delete(_log[_i], 1, 2), 9, _w - 8); }
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
		var _yend = _fighting ? (__fight_r().y - 6) : (room_height - 8 - (land ? 18 : 2));   // (over the buttons' row on a wide page)
		return { x : log_x, y : log_y + 42, w : log_w, h : _yend - (log_y + 42) };   // (under the quest's island)
	}
	if (view == "haul") { var _cw = land ? 224 : (room_width - 8), _lx = (land ? 14 : 4) + _cw + 12, _dy = list_y + 22; return { x : _lx, y : _dy, w : room_width - _lx - 14, h : (hl_open && land) ? (room_height - 8 - 22 - _dy) : 0 }; }   // (the diary fills the column when open - 2026-09-16)   // (the band's own y - it sat 48px above it since the tally moved the band, 2026-09-16)
	return { x : 0, y : 0, w : 0, h : 0 };
};
/// [read the diary] / [close the diary] on the haul page (2026-09-16): the right column's foot
__hlog_r = function() { var _cw = 224, _lx = 14 + _cw + 12; return { x : _lx, y : room_height - 8 - 16, w : room_width - _lx - 14, h : 16 }; };
gx_para = [];                        // the parallax backdrop's layers (built on the first draw)
__gx_r = function() { return { x : 0, y : list_y, w : room_width, h : room_height - list_y }; };
// the departure window: the crew chips left, the brief right, [depart] under the brief
/// THE SHEET (2026-09-15: one painter - the crew page draws it in its rail's shadow, the preparation page as a modal): the sprite's whole sheet from (x0, y0) to x1, the rows laid into it_rects for the taps
/// a name cut with ".." to `avail` px in the font that is set (the popup says it whole)
__sheet_cut = function(_nm, _avail) {
	if (string_width(_nm) <= _avail) return _nm;
	while (string_width(_nm + "..") > _avail && string_length(_nm) > 2) _nm = string_copy(_nm, 1, string_length(_nm) - 1);
	return _nm + "..";
};
__draw_sheet = function(_sp, _x0, _y0, _x1, _y1 = undefined, _pops = true) {   // y1 = the sheet's foot (undefined = the page's); pops false = the caller draws the popups (__draw_sheet_pops) itself, later
	var _ink = sett_ink, _dim = dim, _e = g.exped, _ea = g.ui_fade_a;
	var _sh = sprite_sheet(_sp);
	var _st = sprite_stats(_sp);
	var _c  = _st.cls;
	var _bal = cbt_balance();
	var _pl = sprite_personalities();
	var _w = _x1 - _x0;
	// THE GROUND: black (the gradient came and went the same day - his call)
	var _gh0 = (is_undefined(_y1) ? (room_height - 8) : _y1) - _y0;
	draw_sprite_ext(spr_pixel_1x1, 0, _x0, _y0, _w, _gh0, 0, c_black, .985);   // (near opaque - his ask, 2026-09-16)
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
	// THE CLASS LINE (his spec, 2026-09-17): "warrior (38) - grumpy" - the
	// class, the one number that is the sprite's strength (sprite_stats'
	// total, its point worth), the mood
	var _clsline = _c.name + " (" + string(round(_st.total)) + ")  -  " + _pl[clamp(_sp.pers, 0, array_length(_pl) - 1)].name + (is_struct(_sp[$ "young"]) ? "  -  young" : "");
	draw_text(_hx + 18, _hy + 12, _clsline);
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
	// THE TITLE (the bestiary's payouts, 2026-09-16): after the class, in gold, cut before the level corner
	if ((_sh[$ "title"] ?? "") != "") { var _ttx = _hx + 18 + string_width(_clsline) + 6; draw_set_color(c_gold); draw_set_alpha(.85); draw_text(_ttx, _hy + 12, __sheet_cut("- " + _sh.title, max(24, _xx - _ttx - 4))); }
	// THE PAGE PILLS (his spec, 2026-09-17: "[stats] [gear] [misc]") under the
	// level corner. The header above is every page's; the body below is the
	// page's own. Rects for the taps ride it_rects with a `pg`
	var _pgy = _hy + 16, _pgx = _x1 - 8 - 100;
	var _pgn = ["stats", "gear", "misc"];
	for (var _pg = 0; _pg < 3; _pg++) {
		var _px0 = _pgx + _pg * 34, _on2 = (sheet_pg == _pg);
		draw_sprite_ext(spr_pixel_1x1, 0, _px0, _pgy, 32, 10, 0, _on2 ? merge_colour(_sp.col, c_black, .6) : c_black, .9);
		draw_px_rect(_px0, _pgy, 32, 10, _on2 ? _sp.col : _dim, _on2 ? .9 : .35);
		draw_set_halign(fa_center); draw_set_color(_on2 ? c_white : _dim); draw_set_alpha(_on2 ? .95 : .7);
		draw_text(_px0 + 16, _pgy + 2, _pgn[_pg]);
		draw_set_halign(fa_left);
		array_push(it_rects, { x : _px0, y : _pgy, w : 32, h : 10, pg : _pg });
	}
	var _foot = is_undefined(_y1) ? (room_height - 8) : _y1;
	var _by = _hy + 28;   // the body's top, every page
	if (sheet_pg == 1) __draw_sheet_gear(_sp, _x0, _by, _x1, _foot);
	else if (sheet_pg == 2) __draw_sheet_p2(_sp, _x0, _by - 2, _x1, _foot);
	else {
	// ==================== [stats] ====================
	// HP / MP bars (the Disgaea row): the maxima - a sprite at home is whole
	var _hpr = floor(_st.pts.hp * _bal.hp_per_point + _bal.hp_flat_add);   // (whole hp - his ask; sprite_pawn floors the same)
	var _mpr = max(1, round(_st.pts.mp));
	// the current hp and mp: a sprite out on a trip carries them there; at
	// home they are what it came back with, climbing (sprites_tick)
	var _hpc = floor(_hpr * (_sp[$ "hpf"] ?? 1)), _mpc = round(_mpr * (_sp[$ "mpf"] ?? 1));
	for (var _t = 0; _t < array_length(_e.trips); _t++) {
		var _tt = _e.trips[_t];
		for (var _k = 0; _k < array_length(_tt.sids); _k++) if (_tt.sids[_k] == _sp.id) { _hpc = floor(min(_hpr, _tt.hp[_k])); if (is_array(_tt[$ "mp"]) && _k < array_length(_tt.mp)) _mpc = round(_mpr * clamp(_tt.mp[_k], 0, 1)); }
	}
	// THE EVEN SPLIT (his ask, 2026-09-17): the left bundle (bars, the grid,
	// the resistances) and the right bundle (skills, abilities) each take
	// half the sheet; the bars and the grid stretch to the half
	var _lcw = land ? floor((_w - 24) / 2) : (_w - 16);   // the left column's content width
	var _bw = _lcw - 18;
	// (the hp / mp rows and every stat are taps: what the stat does - his ask, 2026-09-15)
	var _hlw = _bw + 20;
	if (is_struct(it_pop) && it_pop[$ "st"] == "hp") { draw_sprite_ext(spr_pixel_1x1, 0, _hx - 2, _by - 1, _hlw, 10, 0, c_white, .1); draw_px_rect(_hx - 2, _by - 1, _hlw, 10, c_white, .45); }
	if (is_struct(it_pop) && it_pop[$ "st"] == "mp") { draw_sprite_ext(spr_pixel_1x1, 0, _hx - 2, _by + 9, _hlw, 10, 0, c_white, .1); draw_px_rect(_hx - 2, _by + 9, _hlw, 10, c_white, .45); }
	array_push(it_rects, { x : _hx - 2, y : _by - 1, w : _hlw, h : 10, st : "hp" });
	array_push(it_rects, { x : _hx - 2, y : _by + 9, w : _hlw, h : 10, st : "mp" });
	var _hpcol = hp_bar_col();
	draw_set_color(_hpcol); draw_set_alpha(.9); draw_text(_hx, _by, "hp");
	draw_sprite_ext(spr_pixel_1x1, 0, _hx + 18, _by + 2, _bw, 5, 0, merge_colour(_hpcol, c_black, .75), .9);
	draw_sprite_ext(spr_pixel_1x1, 0, _hx + 18, _by + 2, _bw * clamp(_hpc / max(1, _hpr), 0, 1), 5, 0, _hpcol, .8);
	draw_set_font(fnt_outline); draw_set_halign(fa_right); draw_set_color(c_white); draw_set_alpha(.9); draw_text(_hx + 18 + _bw - 2, _by - 1, string(_hpc) + " / " + string(_hpr)); draw_set_halign(fa_left); draw_set_font(fnt);
	draw_set_color(c_sblue); draw_set_alpha(.9); draw_text(_hx, _by + 10, "mp");
	draw_sprite_ext(spr_pixel_1x1, 0, _hx + 18, _by + 12, _bw, 5, 0, merge_colour(c_sblue, c_black, .75), .9);
	draw_sprite_ext(spr_pixel_1x1, 0, _hx + 18, _by + 12, _bw * clamp(_mpc / max(1, _mpr), 0, 1), 5, 0, c_sblue, .8);
	draw_set_font(fnt_outline); draw_set_halign(fa_right); draw_set_color(c_white); draw_set_alpha(.9); draw_text(_hx + 18 + _bw - 2, _by + 9, string(_mpc) + " / " + string(_mpr)); draw_set_halign(fa_left); draw_set_font(fnt);
	// the stats grid (two columns of three), base + the gear's share
	var _keys = ["atk", "def", "mag", "mdef", "spd", "hit"];
	var _labels = ["atk", "def", "int", "res", "spd", "hit"];
	var _gy = _by + 26;
	var _cell = floor(_lcw / 2);
	for (var _k = 0; _k < 6; _k++) {
		var _cx = _hx + (_k mod 2) * _cell, _cy = _gy + (_k div 2) * 11, _cw = _cell - 2;
		array_push(it_rects, { x : _cx - 2, y : _cy - 1, w : _cw, h : 10, st : _keys[_k] });
		if (is_struct(it_pop) && it_pop[$ "st"] == _keys[_k]) { draw_sprite_ext(spr_pixel_1x1, 0, _cx - 2, _cy - 1, _cw, 10, 0, c_white, .1); draw_px_rect(_cx - 2, _cy - 1, _cw, 10, c_white, .45); }
		draw_set_color(_dim); draw_set_alpha(.8);
		draw_text(_cx, _cy, _labels[_k]);
		draw_set_halign(fa_right);
		draw_set_font(fnt_outline); draw_set_color(c_white); draw_set_alpha(.95);
		draw_text(_cx + _cell - 26, _cy, string_format(_st.pts[$ _keys[_k]], 1, 1));
		draw_set_font(fnt); draw_set_halign(fa_left);
		var _g = _st.gear[$ _keys[_k]] + _st.abil[$ _keys[_k]];   // (the gear's share AND the abilities' - 2026-09-17; the stat popup splits them)
		if (_g > 0) { draw_set_color(c_sgreen); draw_set_alpha(.8); draw_text(_cx + _cell - 23, _cy, "+" + string_format(_g, 1, 1)); }
		else if (_g < 0) { draw_set_color(c_hred); draw_set_alpha(.8); draw_text(_cx + _cell - 23, _cy, string_format(_g, 1, 1)); }
	}
	// LUCK (2026-09-16): its own row under the grid - a tap says what it does
	var _lkx = _hx, _lky = _gy + 33, _lkw = _cell - 2;
	array_push(it_rects, { x : _lkx - 2, y : _lky - 1, w : _lkw, h : 10, st : "luck" });
	if (is_struct(it_pop) && it_pop[$ "st"] == "luck") { draw_sprite_ext(spr_pixel_1x1, 0, _lkx - 2, _lky - 1, _lkw, 10, 0, c_white, .1); draw_px_rect(_lkx - 2, _lky - 1, _lkw, 10, c_white, .45); }
	draw_set_color(_dim); draw_set_alpha(.8); draw_text(_lkx, _lky, "luck");
	draw_set_halign(fa_right); draw_set_font(fnt_outline); draw_set_color(c_white); draw_set_alpha(.95);
	draw_text(_lkx + _cell - 26, _lky, string(sprite_luck(_sp)));
	draw_set_font(fnt); draw_set_halign(fa_left);
	draw_set_color(_dim); draw_set_alpha(.7);
	draw_text(_hx, _gy + 45, "crit " + string(_c.crit + sprite_luck(_sp) * .5) + "% x" + string(_c.cmulti) + "  -  counter " + string(_c.cnt) + "%");
	// THE RESISTANCES, under the stats (his call, 2026-09-17: on the left,
	// below everything): vertical, the names in their element's colour, the
	// values in their own shade - a lighter tint for a plus, a darker one
	// for a minus - never the name's colour
	var _rsy = _gy + 57;
	draw_set_color(_ink); draw_set_alpha(.5); draw_text(_hx, _rsy, "resistances");
	var _wel = "";
	for (var _wk = 0; _wk < array_length(_st.worn); _wk++) if ((_st.worn[_wk][$ "elem"] ?? "") != "" && (_st.worn[_wk].slot == "w1" || (_wel == "" && _st.worn[_wk].slot == "w2"))) _wel = _st.worn[_wk].elem;
	if (_wel != "") { var _wei = cbt_elem_info(_wel); draw_set_color(_wei.col); draw_set_alpha(.6); draw_text(_hx + string_width("resistances") + 8, _rsy, "strikes with " + _wei.name); }
	var _rsv = sprite_res(_sp), _rel = ["fire", "water", "nature"];
	for (var _ri2 = 0; _ri2 < 3; _ri2++) {
		var _rei = cbt_elem_info(_rel[_ri2]), _rv = _rsv[$ _rel[_ri2]], _ryy = _rsy + 10 + _ri2 * 10;
		draw_set_color(_rei.col); draw_set_alpha(.9); draw_text(_hx + 3, _ryy, _rei.name);
		var _vc = _dim;
		if (_rv > 0) _vc = merge_colour(_rei.col, c_white, .5);
		else if (_rv < 0) _vc = merge_colour(_rei.col, c_black, .45);
		draw_set_halign(fa_right); draw_set_color(_vc); draw_set_alpha((_rv == 0) ? .5 : .95);
		draw_text(_hx + 72, _ryy, ((_rv > 0) ? "+" : "") + string(_rv) + "%");
		draw_set_halign(fa_left);
	}

	// ---- the right column, on a 10 px pitch: THE FOUR SKILL SLOTS, THE
	// FOUR ABILITY SLOTS (his spec, 2026-09-17) ----
	var _rx0 = land ? (_hx + _lcw + 8) : _hx, _ry0 = land ? _by : (_rsy + 44);
	var _rw0 = land ? (_x1 - 8 - _rx0) : (_w - 16);
	var _sk = sprite_skills(_sp);
	var _ky = _ry0;
	draw_set_color(_ink); draw_set_alpha(.5); draw_text(_rx0, _ky, "skills");
	var _skw = _rw0;
	var _rowh = 11, _rowp = 12;
	for (var _i = 0; _i < SPRITE_SKILLS; _i++) {
		var _ly = _ky + 10 + _i * _rowp;
		if (_i >= array_length(_sk)) { __slot_row(_rx0 - 3, _ly - 1, _skw, _rowh, _dim, true); continue; }   // (an empty slot is empty - his call, 2026-09-17)
		var _s = _sk[_i];
		// the element or the school colours the row and says its word (2026-09-17)
		var _sel = _s[$ "elem"] ?? "", _ssc = _s[$ "school"] ?? "";
		var _scol = _s.magic ? c_hpurple : c_horange, _sword = "";
		if (_sel != "") { var _sei = cbt_elem_info(_sel); _scol = _sei.col; _sword = _sei.name; }
		else if (_ssc != "") { var _sci = cbt_elem_info(_ssc); _scol = _sci.col; _sword = _ssc; }
		__slot_row(_rx0 - 3, _ly - 1, _skw, _rowh, _scol, false, is_struct(it_pop) && it_pop[$ "sk"] == _s);   // (the rim = selected)
		array_push(it_rects, { x : _rx0 - 3, y : _ly - 1, w : _skw, h : _rowh, sk : _s });
		draw_set_color(merge_colour(_scol, c_white, .3)); draw_set_alpha(.95);
		draw_text(_rx0 + 6, _ly + 1, __sheet_cut(_s.name, _skw - 52 - ((_sword != "") ? string_width(_sword) + 6 : 0)));
		draw_set_halign(fa_right); draw_set_color(c_sblue); draw_set_alpha(.85);
		draw_text(_rx0 - 3 + _skw - 8, _ly + 1, string(_s.cost) + " mp");
		if (_sword != "") { draw_set_color(_scol); draw_set_alpha(.6); draw_text(_rx0 - 3 + _skw - 8 - string_width(string(_s.cost) + " mp") - 6, _ly + 1, _sword); }
		draw_set_halign(fa_left);
	}
	// THE ABILITIES: four slots - what is equipped, in its rarity's colour,
	// its line right; an empty slot says so; a tap on any opens the picker
	var _all_ab = sprite_abilities(_sp);
	var _ay = _ky + 10 + SPRITE_SKILLS * _rowp + 4;
	draw_set_color(_ink); draw_set_alpha(.5); draw_text(_rx0, _ay, "abilities");
	// "NEW" (his ask, 2026-09-17): a rung unlocked and not yet looked at - the picker clears it
	if (_sh[$ "abnew"] ?? false) { draw_set_color(c_gold); draw_set_alpha(.7 + .3 * dsin(current_time * .4)); draw_text(_rx0 + string_width("abilities") + 6, _ay, "new"); }
	var _lad = ability_unlocks(), _next_lv = -1;
	for (var _li = 0; _li < array_length(_lad); _li++) if (_sh.lv < _lad[_li].lv) { _next_lv = _lad[_li].lv; break; }
	if (_next_lv > 0) { draw_set_color(_dim); draw_set_alpha(.5); draw_text(_rx0 + string_width("abilities") + 8, _ay, "next at lv " + string(_next_lv)); }
	var _worn_ab = sprite_ability_worn(_sp);   // (the sprite's own set when the picker is vaulted - 2026-09-17)
	for (var _i = 0; _i < 4; _i++) {
		var _ly2 = _ay + 10 + _i * _rowp;
		array_push(it_rects, { x : _rx0 - 3, y : _ly2 - 1, w : _rw0, h : _rowh, ab : _i });
		var _k = _worn_ab[_i];
		if (_k < 0 || _k >= array_length(_all_ab)) {
			__slot_row(_rx0 - 3, _ly2 - 1, _rw0, _rowh, _dim, true);   // (empty is empty)
			continue;
		}
		var _a = _all_ab[_k], _arc = upgrade_rarity_info(_a.rar).col;
		__slot_row(_rx0 - 3, _ly2 - 1, _rw0, _rowh, _arc, false, is_struct(it_pop) && it_pop[$ "ab"] == _i);   // (the rim = selected)
		draw_set_color(merge_colour(_arc, c_white, .3)); draw_set_alpha(.95);
		draw_text(_rx0 + 6, _ly2 + 1, __sheet_cut(_a.name, _rw0 - 96));
		draw_set_halign(fa_right); draw_set_color(_ink); draw_set_alpha(.8);
		draw_text(_rx0 - 3 + _rw0 - 8, _ly2 + 1, ability_line(_a));
		draw_set_halign(fa_left);
	}
	// THE FLAW (2026-09-17, his call: "5th slot will be the negative"): the
	// sprite's one, seeded, never taken off - the slot in its rarity's
	// colour (a rare flaw is a mild one), the name and the line in red
	var _flw = sprite_flaw(_sp), _fly = _ay + 10 + 4 * _rowp, _flc = upgrade_rarity_info(_flw.rar).col;
	array_push(it_rects, { x : _rx0 - 3, y : _fly - 1, w : _rw0, h : _rowh, ab : 4 });
	__slot_row(_rx0 - 3, _fly - 1, _rw0, _rowh, _flc, false, is_struct(it_pop) && it_pop[$ "ab"] == 4);
	draw_set_color(merge_colour(c_hred, c_white, .25)); draw_set_alpha(.95);
	draw_text(_rx0 + 6, _fly + 1, __sheet_cut(_flw.name, _rw0 - 96));
	draw_set_halign(fa_right); draw_set_color(c_hred); draw_set_alpha(.85);
	draw_text(_rx0 - 3 + _rw0 - 8, _fly + 1, ability_line(_flw));
	draw_set_halign(fa_left);
	}
	if (_pops) __draw_sheet_pops();   // (the popups - the crew view draws them itself, LAST, over its foot; his report 2026-09-17)
};
/// THE SHEET'S POPUPS (split out of __draw_sheet 2026-09-17 - his report: the
/// sprite menu's foot drew over the gear tooltip): the ability / item / level /
/// stat / note / skill popups off it_pop, drawn after everything under them.
/// __draw_sheet calls it unless told not to (_pops false) - the crew view then
/// draws its foot and calls this after
__draw_sheet_pops = function() {
	var _ink = sett_ink, _dim = dim, _bal = cbt_balance();
	// THE ITEM POPUP (his ask, 2026-09-15): the item's lines, what it is worth
	// to this sprite (gear_score, the class's eye), and against what is
	// worn in its slot - the difference per line
	if (is_struct(it_pop) && !is_undefined(it_pop.sp) && !is_undefined(it_pop[$ "ab"]) && (!SPRITE_AB_PICK || it_pop.ab >= 4)) {
		// THE ABILITY TOOLTIP (2026-09-17, take three - the picker is VAULTED
		// behind SPRITE_AB_PICK, his call: "leave it to the sprite... redo the
		// tooltip"): the skill popup's shape, over the slot it came from (the
		// slot's own width - the right column, clear of the stat points) -
		// the name in its rarity's colour, the rarity / tier / rung under it,
		// the number with its lane NAMED, what the lane is, the flavour.
		// Opening it is "looking": the "new" flag clears
		var _tsp = it_pop.sp, _tsh = sprite_sheet(_tsp), _tall = sprite_abilities(_tsp), _twn = sprite_ability_worn(_tsp);
		if (_tsh[$ "abnew"] ?? false) { _tsh.abnew = false; save_mark_dirty(); }
		var _tk = (it_pop.ab >= 4) ? -1 : _twn[clamp(it_pop.ab, 0, 3)];
		var _tw = it_pop[$ "w"] ?? 180; _tw = clamp(_tw, 150, 210);
		var _t0 = "", _tcol = _dim, _tsub = "", _tl1 = "", _tl2 = "", _tl3 = "";
		if (it_pop.ab >= 4) {
			// THE FLAW's tooltip (2026-09-17): what it is, how mild, what it costs
			var _tfl = sprite_flaw(_tsp), _tfr = upgrade_rarity_info(_tfl.rar), _tfd = ability_lane_desc(_tfl.cfg.lane);
			_t0 = "flaw  -  " + _tfl.name; _tcol = c_hred;
			_tsub = _tfr.name + ((_tfl.rar >= 5) ? "  -  a mild one" : ((_tfl.rar >= 2) ? "  -  a lighter one" : ""));
			_tl1 = ability_line(_tfl);
			_tl2 = _tfd.what + ". every sprite and every foe carries one flaw; it never comes off.";
			_tl3 = _tfl.cfg.help;
		} else if (_tk < 0 || _tk >= array_length(_tall)) {
			var _tnx = -1, _tlad = ability_unlocks();
			for (var _li = 0; _li < array_length(_tlad); _li++) if (_tsh.lv < _tlad[_li].lv) { _tnx = _tlad[_li].lv; break; }
			_t0 = "an open slot";
			_tl2 = (_tnx > 0) ? ("the next ability comes at level " + string(_tnx) + ". the sprite wears what it judges best for its class.") : "every ability is unlocked.";
		} else {
			var _ta = _tall[_tk], _tri = upgrade_rarity_info(_ta.rar), _tld = ability_lane_desc(_ta.cfg.lane);
			_t0 = _ta.name; _tcol = _tri.col;
			_tsub = _tri.name + "  -  tier " + string(_ta.tier) + "  -  since lv " + string(ability_unlocks()[_tk].lv);
			_tl1 = ability_line(_ta);
			_tl2 = _tld.what;
			if (variable_struct_exists(_ta.cfg, "also")) _tl2 += "; and " + ability_lane_desc(_ta.cfg.also).what;
			if (variable_struct_exists(_ta.cfg, "cost")) _tl2 += ". the cost: " + string(_ta.cfg.cost.v) + "% " + ability_lane_desc(_ta.cfg.cost.lane).word;
			_tl3 = _ta.cfg.help;
		}
		var _th = 18;
		if (_tsub != "") _th += 10;
		if (_tl1 != "") _th += 12;
		if (_tl2 != "") _th += string_height_ext(_tl2, 9, _tw - 12) + 2;
		if (_tl3 != "") _th += string_height_ext(_tl3, 9, _tw - 12) + 2;
		var _tx = clamp(it_pop.x, 4, room_width - _tw - 4), _ty = clamp(it_pop.y, list_y + 20, room_height - _th - 4);
		draw_sprite_ext(spr_pixel_1x1, 0, _tx + 2, _ty + 3, _tw, _th, 0, c_black, .5);
		draw_sprite_ext(spr_pixel_1x1, 0, _tx, _ty, _tw, _th, 0, c_hsv(169, 186, 9), .98);
		draw_px_rect(_tx, _ty, _tw, _th, _tcol, .8);
		draw_set_color(_tcol); draw_set_alpha(.95); draw_text(_tx + 6, _ty + 4, _t0);
		var _tyy = _ty + 14;
		if (_tsub != "") { draw_set_color(_dim); draw_set_alpha(.7); draw_text(_tx + 6, _tyy, _tsub); _tyy += 10; }
		if (_tl1 != "") { draw_set_color(c_white); draw_set_alpha(.95); draw_text(_tx + 6, _tyy, _tl1); _tyy += 12; }
		if (_tl2 != "") { draw_set_color(_ink); draw_set_alpha(.9); draw_text_ext(_tx + 6, _tyy, _tl2, 9, _tw - 12); _tyy += string_height_ext(_tl2, 9, _tw - 12) + 2; }
		if (_tl3 != "") { draw_set_color(_dim); draw_set_alpha(.6); draw_text_ext(_tx + 6, _tyy, _tl3, 9, _tw - 12); }
	} else if (is_struct(it_pop) && !is_undefined(it_pop.sp) && !is_undefined(it_pop[$ "ab"])) {
		// THE ABILITY PICKER - VAULTED (SPRITE_AB_PICK false, 2026-09-17: "just
		// vault the option... i might add the option back"; the tooltip above
		// stands in for it). Everything under here is the live picker as it was
		// (2026-09-17, take two - his ask: "a way to show
		// tooltips when selecting abilities... a green button [equip]"). The
		// list above: every rung the sprite has unlocked, in its rarity's
		// colour with its line; a tap SELECTS. The pane under it is the
		// tooltip - what the selected one does, its tier, rung and rarity -
		// with [equip] (green) or [clear] beside it; that tap commits. The
		// one in this slot is marked, the ones in other slots dim
		var _asp = it_pop.sp, _ash = sprite_sheet(_asp), _aall = sprite_abilities(_asp);
		if (!is_array(_ash[$ "abil"])) _ash.abil = [-1, -1, -1, -1];
		var _sel = it_pop[$ "sel"] ?? -2;
		if (_ash[$ "abnew"] ?? false) { _ash.abnew = false; save_mark_dirty(); }   // (looked at)
		var _pnh = 58, _bh3 = 14;
		var _apw = 196, _aph = 22 + (array_length(_aall) + 1) * 11 + 4 + _pnh + 4 + _bh3 + 6;   // (narrower, his ask 2026-09-17)
		// ON THE RIGHT, over the ability column, clear of the stat points (his ask)
		var _apx = clamp(it_pop.x, 4, room_width - _apw - 4), _apy = clamp(list_y + 20, list_y + 20, room_height - _aph - 4);
		draw_sprite_ext(spr_pixel_1x1, 0, _apx + 2, _apy + 3, _apw, _aph, 0, c_black, .5);
		draw_sprite_ext(spr_pixel_1x1, 0, _apx, _apy, _apw, _aph, 0, c_hsv(169, 186, 9), .98);
		draw_px_rect(_apx, _apy, _apw, _aph, _asp.col, .8);
		draw_set_color(_asp.col); draw_set_alpha(.95);
		draw_text(_apx + 6, _apy + 4, "abilities  -  slot " + string(it_pop.ab + 1));
		draw_set_halign(fa_right); draw_set_color(_dim); draw_set_alpha(.6); draw_text(_apx + _apw - 6, _apy + 4, "tap to read"); draw_set_halign(fa_left);
		ab_rects = [];
		var _ayy = _apy + 16;
		for (var _k = -1; _k < array_length(_aall); _k++) {
			var _here = (_ash.abil[it_pop.ab] == _k), _elsewhere = (_k >= 0 && !_here && array_contains(_ash.abil, _k)), _on = (_sel == _k);
			draw_sprite_ext(spr_pixel_1x1, 0, _apx + 4, _ayy - 1, _apw - 8, 10, 0, _on ? merge_colour(_asp.col, c_black, .6) : c_black, _on ? .9 : .35);
			if (_on) draw_px_rect(_apx + 4, _ayy - 1, _apw - 8, 10, _asp.col, .9);
			else if (_here) draw_px_rect(_apx + 4, _ayy - 1, _apw - 8, 10, _asp.col, .4);
			array_push(ab_rects, { x : _apx + 4, y : _ayy - 1, w : _apw - 8, h : 10, k : _k });
			if (_k < 0) {
				draw_set_color(_dim); draw_set_alpha(.7); draw_text(_apx + 8, _ayy, "(nothing)");
			} else {
				var _aa = _aall[_k];
				draw_set_color(_elsewhere ? _dim : upgrade_rarity_info(_aa.rar).col); draw_set_alpha(_elsewhere ? .45 : .95);
				draw_text(_apx + 8, _ayy, __sheet_cut(_aa.name, 62));
				draw_set_color(_dim); draw_set_alpha(.6); draw_text(_apx + 74, _ayy, "t" + string(_aa.tier));
				draw_set_halign(fa_right); draw_set_color(_elsewhere ? _dim : _ink); draw_set_alpha(_elsewhere ? .45 : .85);
				draw_text(_apx + _apw - 8, _ayy, _here ? "here" : (_elsewhere ? "elsewhere" : __sheet_cut(ability_line(_aa), _apw - 8 - (_apx + 92) + _apx)));
				draw_set_halign(fa_left);
			}
			_ayy += 11;
		}
		// THE PANE: the tooltip - the name, its rung, its number with the
		// lane NAMED, what the lane is, the flavour - and the button under it
		var _pny = _ayy + 3;
		draw_sprite_ext(spr_pixel_1x1, 0, _apx + 4, _pny, _apw - 8, _pnh, 0, c_black, .45);
		draw_px_rect(_apx + 4, _pny, _apw - 8, _pnh, _dim, .3);
		var _bw3 = _apw - 8, _bx3 = _apx + 4, _by3 = _pny + _pnh + 4;
		ab_btn = undefined;
		if (_sel == -2) {
			var _nxl = -1, _lad2 = ability_unlocks();
			for (var _li = 0; _li < array_length(_lad2); _li++) if (_ash.lv < _lad2[_li].lv) { _nxl = _lad2[_li].lv; break; }
			draw_set_color(_dim); draw_set_alpha(.55);
			draw_text_ext(_apx + 8, _pny + 4, "tap an ability above to read what it does. " + ((_nxl > 0) ? ("the next rung unlocks at level " + string(_nxl) + ".") : "every rung is unlocked."), 9, _apw - 16);
			draw_ui_button(_bx3, _by3, _bw3, _bh3, "equip", c_gray, false, false);
		} else if (_sel < 0) {
			draw_set_color(_dim); draw_set_alpha(.8); draw_text(_apx + 8, _pny + 4, "nothing in this slot");
			draw_set_alpha(.55); draw_text_ext(_apx + 8, _pny + 15, "the slot stays open. an ability unlocked later fills an open slot by itself; a pick you make is never evicted.", 9, _apw - 16);
			if (_ash.abil[it_pop.ab] >= 0) { ab_btn = { x : _bx3, y : _by3, w : _bw3, h : _bh3, k : -1 }; draw_ui_button(_bx3, _by3, _bw3, _bh3, "clear the slot", c_hred, true, true); }
			else draw_ui_button(_bx3, _by3, _bw3, _bh3, "the slot is open", c_gray, false, false);
		} else {
			var _sa = _aall[_sel], _sri = upgrade_rarity_info(_sa.rar), _sld = ability_lane_desc(_sa.cfg.lane);
			var _sel_here = (_ash.abil[it_pop.ab] == _sel), _sel_else = (!_sel_here && array_contains(_ash.abil, _sel));
			draw_set_color(_sri.col); draw_set_alpha(.95); draw_text(_apx + 8, _pny + 4, _sa.name);
			draw_set_color(_dim); draw_set_alpha(.7); draw_text(_apx + 8 + string_width(_sa.name) + 6, _pny + 4, _sri.name + "  t" + string(_sa.tier) + "  lv " + string(ability_unlocks()[_sel].lv));
			draw_set_color(_ink); draw_set_alpha(.95); draw_text(_apx + 8, _pny + 15, ability_line(_sa));
			draw_set_color(_ink); draw_set_alpha(.7); draw_text_ext(_apx + 8, _pny + 26, _sld.what + ((_sa.cfg.help != "") ? ("  -  " + _sa.cfg.help) : "") + (_sel_else ? "  (worn in another slot)" : ""), 9, _apw - 16);
			if (_sel_here) { ab_btn = { x : _bx3, y : _by3, w : _bw3, h : _bh3, k : -1 }; draw_ui_button(_bx3, _by3, _bw3, _bh3, "unequip", c_hred, true, true); }
			else if (!_sel_else) { ab_btn = { x : _bx3, y : _by3, w : _bw3, h : _bh3, k : _sel }; draw_ui_button(_bx3, _by3, _bw3, _bh3, "equip", c_sgreen, true, true); }
			else draw_ui_button(_bx3, _by3, _bw3, _bh3, "worn in another slot", c_gray, false, false);
		}
	} else if (is_struct(it_pop) && !is_undefined(it_pop.sp) && (it_pop[$ "lvup"] ?? false)) {
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
		// THIS SPRITE'S OWN NUMBER, split (2026-09-17): the class's, the gear's,
		// the abilities' - the grid's one green figure is both of the last two
		var _btx = "";
		if (it_pop.st != "luck") {
			var _bst = sprite_stats(it_pop.sp), _bk = it_pop.st, _bmul = (_bk == "hp") ? _bal.hp_per_point : 1;
			var _bb = _bst.base[$ _bk] * _bmul + ((_bk == "hp") ? _bal.hp_flat_add : 0), _bg = _bst.gear[$ _bk] * _bmul, _ba = _bst.abil[$ _bk] * _bmul;
			_btx = "this one: " + string_format(_bb, 1, 1) + " the class's";
			if (_bg != 0) _btx += ", " + ((_bg > 0) ? "+" : "") + string_format(_bg, 1, 1) + " the gear's";
			if (_ba != 0) _btx += ", " + ((_ba > 0) ? "+" : "") + string_format(_ba, 1, 1) + " the abilities'";
			_sdh += string_height_ext(_btx, 9, _sdw - 12) + 2;
		}
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
		if (_btx != "") { draw_set_color(_dim); draw_set_alpha(.75); draw_text_ext(_sdx + 6, _sdy2, _btx, 9, _sdw - 12); }
	} else if (is_struct(it_pop) && !is_undefined(it_pop.sp) && !is_undefined(it_pop[$ "nt"])) {
		// THE NOTE POPUP (his ask): what a note does to the sprite
		var _pnt = it_pop.nt;
		// (what a note does, by its tag - the notes pass, 2026-09-16)
		var _ntxt = "a useless note. it changes nothing. they seem to like having it.";
		if (_pnt.tag != "") {
			var _tp = string_split(_pnt.tag, ":");
			if (_tp[0] == "foe" && array_length(_tp) >= 2) {
				var _fct = (array_length(_tp) >= 3) ? _tp[2] : "hit", _fks = foe_plural(_tp[1]);
				switch (_fct) {
					case "crit": _ntxt = "a STUDIED foe: +5 crit against " + _fks + " (where the gaps are)"; break;
					case "dmg":  _ntxt = "a STUDIED foe: a tenth more damage to " + _fks + " (where to push)"; break;
					case "mdef": _ntxt = "a STUDIED foe: their magic bites " + _fks + "' target 15% less (not standing in it)"; break;
					case "def":  _ntxt = "a STUDIED foe: " + _fks + " hit this sprite a tenth softer (not being where it lands)"; break;
					case "eva":  _ntxt = "a STUDIED foe: " + _fks + " miss this sprite 6 more in a hundred"; break;
					default:     _ntxt = "a STUDIED foe: +" + string(SPRITE_NOTE_HIT) + " to hit against " + _fks + " in every fight from now on (one note a kind)"; break;
				}
			}
			else if (_tp[0] == "road") _ntxt = "the going: a tenth quicker on any road that touches " + ((array_length(_tp) > 1) ? _tp[1] : "that land") + " while this sprite is up";
			else if (_tp[0] == "wx")   _ntxt = "the weather: no slips and no wrong turns in " + ((array_length(_tp) > 1) ? _tp[1] : "it") + " while this sprite is up";
			else if (_tp[0] == "night") _ntxt = "the dark: half the lost hours and wrong turns at night while this sprite is up";
			else if (_tp[0] == "haz")  _ntxt = "a hazard studied: " + ((array_length(_tp) > 1) ? ("the " + _tp[1]) : "it") + " bites this sprite half as hard when nothing else holds it";
			else if (_tp[0] == "inn")  _ntxt = "inns: this sprite's bed is a credit cheaper (the bill never under half)";
			else if (_tp[0] == "shop") _ntxt = "shops: this sprite haggles a credit off everything";
		}
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
		if (!it_pop.worn && _it.slot != "use" && _it.slot != "treasure") {   // (a consumable or a treasure compares with nothing - 2026-09-16 / 17)
			if (_it.slot == "w1" || _it.slot == "w2") _cmp = _psh[$ _it.slot];
			else { var _arr = _psh[$ _it.slot]; var _wsc = infinity; for (var _j = 0; _j < array_length(_arr); _j++) { var _s2 = gear_score(_psp, _arr[_j]); if (_s2 < _wsc) { _wsc = _s2; _cmp = _arr[_j]; } } }
		}
		var _pw = 168;
		// the quirks and the line of voice (the proc-gear pass, 2026-09-15)
		var _qks = _it[$ "quirks"] ?? [], _qros = gear_quirks(), _qrows = [];
		for (var _qi = 0; _qi < array_length(_qks); _qi++) for (var _qj = 0; _qj < array_length(_qros); _qj++) if (_qros[_qj].key == _qks[_qi]) {
			var _qq = _qros[_qj], _qtx = "";
			if (!is_undefined(_qq[$ "hold"]))       _qtx = "holds the " + _qq.hold;
			else if (!is_undefined(_qq[$ "crit"]))  _qtx = "+" + string(_qq.crit) + " crit";
			else if (!is_undefined(_qq[$ "cnt"]))   _qtx = "+" + string(_qq.cnt) + " counter";
			else if (!is_undefined(_qq[$ "erode"])) _qtx = "half the wear";
			else if (!is_undefined(_qq[$ "mp0"]))   _qtx = "+" + string(round(_qq.mp0 * 100)) + "% mp to start";
			else                                    _qtx = "more of it, one line short";
			array_push(_qrows, { k : _qq.key, v : _qtx });
		}
		var _desc = gear_desc(_it), _dh = string_height_ext(_desc, 9, _pw - 12);
		var _ph = 54 + array_length(_lines) * 10 + (is_undefined(_cmp) ? 0 : 12) + array_length(_qrows) * 10 + _dh + 4;
		var _ppx = clamp(it_pop.x, 4, room_width - _pw - 4), _ppy = clamp(it_pop.y, list_y + 20, room_height - _ph - 4);
		draw_sprite_ext(spr_pixel_1x1, 0, _ppx + 2, _ppy + 3, _pw, _ph, 0, c_black, .5);
		draw_sprite_ext(spr_pixel_1x1, 0, _ppx, _ppy, _pw, _ph, 0, c_hsv(169, 186, 9), .98);
		draw_px_rect(_ppx, _ppy, _pw, _ph, _it.col, .8);
		draw_set_color(_it.col); draw_set_alpha(.95);
		draw_text_ext(_ppx + 6, _ppy + 4, _it.name, 9, _pw - 12);
		var _ty2 = _ppy + 4 + string_height_ext(_it.name, 9, _pw - 12) + 2;
		draw_set_color(_dim); draw_set_alpha(.7);
		var _slotn = (_it.slot == "w1") ? "weapon" : ((_it.slot == "w2") ? "offhand" : ((_it.slot == "armor") ? "armor" : ((_it.slot == "treasure") ? "treasure" : ((_it.slot == "use") ? "potion" : "talisman"))));
		draw_text(_ppx + 6, _ty2, upgrade_rarity_info(_it.rar).name + " " + _it.fam + "  -  " + _slotn + "  -  lv " + string(_it.lv));
		_ty2 += 10;
		// THE ODDS (his ask, 2026-09-16): "1 in N" - the rung's share of the house
		// ladder at the base rate (rarity_odds: the very bands the loot rolls through)
		var _go = rarity_odds(0, .3, .03, 800, UPG_RARITY_N);   // (the fourteen - 2026-09-17)
		draw_text(_ppx + 6, _ty2, it_pop.worn ? "worn" : "in the pocket");
		draw_set_halign(fa_right); draw_set_color(_it.col); draw_set_alpha(.9);
		draw_text(_ppx + _pw - 6, _ty2, rarity_label(_go[clamp(_it.rar, 0, UPG_RARITY_N - 1)]));
		draw_set_halign(fa_left);
		_ty2 += 12;
		// the line of voice, then the quirks in green
		draw_set_color(_dim); draw_set_alpha(.75);
		draw_text_ext(_ppx + 6, _ty2, _desc, 9, _pw - 12);
		_ty2 += _dh + 4;
		for (var _qi = 0; _qi < array_length(_qrows); _qi++) {
			draw_set_color(c_sgreen); draw_set_alpha(.9);
			draw_text(_ppx + 6, _ty2, _qrows[_qi].k);
			draw_set_halign(fa_right); draw_text(_ppx + _pw - 6, _ty2, _qrows[_qi].v); draw_set_halign(fa_left);
			_ty2 += 10;
		}
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
		if (_it.slot == "treasure") draw_text(_ppx + 6, _ty2 + 2, "sells for " + string(_it.val) + " credits");
		else draw_text(_ppx + 6, _ty2 + 2, "worth " + string_format(_sc, 1, 0) + " to " + _psp.name + " (" + _pcls.name + ")" + (is_undefined(_cmp) ? "" : ("  vs " + string_format(gear_score(_psp, _cmp), 1, 0))));
	}
};
dp_sheet = -1;   // the sheet modal on the preparation page: the sprite shown (-1 = none)
__dp_sheet_r = function() { var _l = __dp_layout(); return { x : _l.x, y : _l.y, w : _l.w, h : max(_l.h, room_height - 8 - _l.y) }; };   // (the mission box's rect, sat over it - his ask 2026-09-15; never shorter than the page allows)
/// a press on the sheet's rows (it_rects, laid by __draw_sheet): the popup - or a popup up closes; true when the press was the sheet's
/// PAGE TWO of the sheet (his ask, 2026-09-17): the sprite's own ledger on
/// the left (sprite_led - trips, fights, downs, damage, mistakes, finds,
/// the distance walked), its FRIENDSHIPS on the right (exped_bond: every
/// other sprite it has been out with, closest first, the bond's tier as
/// a word and its number)
/// [gear] (his spec, 2026-09-17): the equipment in its own column, the
/// pocket beside it with the height it always wanted - every item shows
__draw_sheet_gear = function(_sp, _x0, _y0, _x1, _y1) {
	var _ink = sett_ink, _dim = dim;
	var _sh = sprite_sheet(_sp);
	var _c  = sprite_classes()[_sh.cls];
	var _ex = _x0 + 8, _ey = _y0;
	var _ew = land ? 176 : (_x1 - _x0 - 16);
	draw_set_halign(fa_left);
	draw_set_color(_ink); draw_set_alpha(.5); draw_text(_ex, _ey, "equip");
	var _rows = [];
	array_push(_rows, { lbl : "weapon",  it : _sh.w1 });
	array_push(_rows, { lbl : "offhand", it : _sh.w2 });
	for (var _i = 0; _i < _c.armor; _i++) array_push(_rows, { lbl : "armor",    it : (_i < array_length(_sh.armor)) ? _sh.armor[_i] : undefined });
	for (var _i = 0; _i < _c.talis; _i++) array_push(_rows, { lbl : "talisman", it : (_i < array_length(_sh.talis)) ? _sh.talis[_i] : undefined });
	// (the same slot as the skills and the abilities - his ask, 2026-09-17:
	// the rim and the wash in the item's rarity colour, an empty slot dim)
	for (var _i = 0; _i < array_length(_rows); _i++) {
		var _rw = _rows[_i];
		var _ry = _ey + 11 + _i * 12;
		var _rc = is_undefined(_rw.it) ? _dim : _rw.it.col;
		__slot_row(_ex, _ry - 1, _ew, 11, _rc, is_undefined(_rw.it), is_struct(it_pop) && !is_undefined(_rw.it) && it_pop[$ "it"] == _rw.it);   // (the rim = selected)
		if (!is_undefined(_rw.it)) array_push(it_rects, { x : _ex, y : _ry - 1, w : _ew, h : 11, it : _rw.it, worn : true });
		// DISGAEA'S ROW (his screenshots, 2026-09-17): the item's name on the
		// left - "(none)" dim when the slot is bare - and the slot's KIND on
		// the right, small and dim; the level tucked after the name
		var _kind = (_rw.lbl == "weapon") ? "main weapon" : ((_rw.lbl == "offhand") ? "sub weapon" : _rw.lbl);
		draw_set_halign(fa_right); draw_set_color(_dim); draw_set_alpha(is_undefined(_rw.it) ? .45 : .7);
		draw_text(_ex + _ew - 8, _ry + 1, _kind);
		draw_set_halign(fa_left);
		if (is_undefined(_rw.it)) { draw_set_color(_dim); draw_set_alpha(.45); draw_text(_ex + 8, _ry + 1, "(none)"); }
		else {
			var _room = (_ex + _ew - 8 - string_width(_kind) - 8) - (_ex + 8);
			var _nm = __sheet_cut(_rw.it.name, _room - string_width(" lv" + string(_rw.it.lv)));
			draw_set_color(merge_colour(_rw.it.col, c_white, .3)); draw_set_alpha(.95);
			draw_text(_ex + 8, _ry + 1, _nm);
			draw_set_color(_dim); draw_set_alpha(.55);
			draw_text(_ex + 8 + string_width(_nm) + 3, _ry + 1, "lv" + string(_rw.it.lv));
		}
	}
	// the pocket: the whole of it, to the foot
	var _px0 = land ? (_x0 + 196) : _ex, _py = land ? _y0 : (_ey + 11 + array_length(_rows) * 12 + 8);
	var _pw = land ? (_x1 - 8 - _px0) : _ew;
	draw_set_color(_ink); draw_set_alpha(.5);
	draw_text(_px0, _py, "pocket  " + string(array_length(_sh.inv)) + " / " + string(SPRITE_INV));
	// the pocket's ten slots, the same shape: an item in its rarity colour, an open one dim
	var _pn = array_length(_sh.inv);
	for (var _i = 0; _i < SPRITE_INV; _i++) {
		var _iy = _py + 11 + _i * 12;
		if (_iy + 11 > _y1 - 2) break;
		if (_i >= _pn) { __slot_row(_px0, _iy - 1, _pw, 11, _dim, true); continue; }   // (empty is empty)
		var _it = _sh.inv[_i];
		__slot_row(_px0, _iy - 1, _pw, 11, _it.col, false, is_struct(it_pop) && it_pop[$ "it"] == _it);   // (the rim = selected)
		draw_set_color(merge_colour(_it.col, c_white, .3)); draw_set_alpha(.95); draw_text(_px0 + 6, _iy + 1, __sheet_cut(_it.name, _pw - 12 - 18));
		draw_set_halign(fa_right); draw_set_color(_dim); draw_set_alpha(.6); draw_text(_px0 + _pw - 8, _iy + 1, "lv" + string(_it.lv)); draw_set_halign(fa_left);
		array_push(it_rects, { x : _px0, y : _iy - 1, w : _pw, h : 11, it : _it, worn : false });
	}
};
/// [misc] (his spec, 2026-09-17): the ledger on the left; on the right THE
/// NOTEPAD with THE FRIENDSHIPS under it - both scroll (the wheel over
/// either; the Step clamps misc_scr_n / misc_scr_f, the Draw lays their
/// rects and their reach down) - so every note and every friend can be read
__draw_sheet_p2 = function(_sp, _x0, _y0, _x1, _y1) {
	var _ink = sett_ink, _dim = dim;
	var _led = _sp[$ "led"];
	if (!is_struct(_led)) _led = {};
	var _lx = _x0 + 8, _ly = _y0;
	draw_set_halign(fa_left);
	draw_set_color(_ink); draw_set_alpha(.75); draw_text(_lx, _ly, "the ledger"); _ly += 12;
	var _rows = [
		{ k : "trips taken",     v : string(round(_led[$ "trips"]  ?? 0)) },
		{ k : "battles won",     v : string(round(_led[$ "won"]    ?? 0)), c : c_sgreen },
		{ k : "battles lost",    v : string(round(_led[$ "lost"]   ?? 0)), c : c_hred },
		{ k : "times down",      v : string(round(_led[$ "downs"]  ?? 0)), c : c_hred },
		{ k : "damage dealt",    v : string(round(_led[$ "dmg"]    ?? 0)) },
		{ k : "damage taken",    v : string(round(_led[$ "dtaken"] ?? 0)) },
		{ k : "mistakes made",   v : string(round(_led[$ "mist"]   ?? 0)), c : c_horange },
		{ k : "items found",     v : string(round(_led[$ "finds"]  ?? 0)) },
		{ k : "distance walked", v : dist_fmt(_led[$ "km"] ?? 0) },
	];
	var _lw = land ? 124 : (_x1 - _x0 - 16);
	for (var _i = 0; _i < array_length(_rows); _i++) {
		var _rw = _rows[_i];
		if (_ly + 10 > _y1 - 4) break;
		if (_i & 1) draw_sprite_ext(spr_pixel_1x1, 0, _lx - 3, _ly - 1, _lw + 6, 10, 0, c_white, .04);
		draw_set_halign(fa_left); draw_set_color(_dim); draw_set_alpha(.8); draw_text(_lx, _ly, _rw.k);
		draw_set_halign(fa_right); draw_set_color(_rw[$ "c"] ?? c_white); draw_set_alpha(.9); draw_text(_lx + _lw, _ly, _rw.v);
		_ly += 10;
	}
	draw_set_halign(fa_left);
	// ---- the right column: two scrolling lists ----
	var _cx0 = land ? (_x0 + 148) : _lx, _cw = land ? (_x1 - 8 - _cx0) : _lw;
	var _ctop = land ? _y0 : (_ly + 8), _cbot = _y1 - 4;
	if (_cbot - _ctop < 40) return;
	var _nh = floor((_cbot - _ctop) * .56), _fh = (_cbot - _ctop) - _nh - 6;
	// THE NOTEPAD: every note, wrapped, newest at the bottom; the wheel scrolls
	var _sh2 = sprite_sheet(_sp);
	draw_set_color(_ink); draw_set_alpha(.5); draw_text(_cx0, _ctop, "notepad  " + string(array_length(_sh2.notes)) + " / " + string(SPRITE_NOTES));
	var _ntw = _cw - 10, _nvy = _ctop + 11, _nvh = _nh - 11;
	var _nhs = array_create(array_length(_sh2.notes), 0), _ntot = 0;
	for (var _i = 0; _i < array_length(_sh2.notes); _i++) { _nhs[_i] = string_height_ext("- " + _sh2.notes[_i].txt, 9, _ntw) + 1; _ntot += _nhs[_i]; }
	misc_nmax = max(0, _ntot - _nvh);
	misc_scr_n = clamp(misc_scr_n, 0, misc_nmax);
	misc_nrect = { x : _cx0 - 3, y : _nvy, w : _cw + 6, h : _nvh };
	var _nyy = _nvy - misc_scr_n;
	for (var _i = 0; _i < array_length(_sh2.notes); _i++) {
		var _nt = _sh2.notes[_i], _h = _nhs[_i];
		if (_nyy >= _nvy && _nyy + _h <= _nvy + _nvh + 1) {   // (only what sits wholly in the window)
			if (is_struct(it_pop) && it_pop[$ "nt"] == _nt) { draw_sprite_ext(spr_pixel_1x1, 0, _cx0 - 3, _nyy - 1, _cw, _h, 0, c_white, .1); draw_px_rect(_cx0 - 3, _nyy - 1, _cw, _h, c_white, .45); }
			draw_set_color((_nt.tag != "") ? c_horange : _dim); draw_set_alpha((_nt.tag != "") ? .8 : .6);
			draw_text_ext(_cx0, _nyy, "- " + _nt.txt, 9, _ntw);
			array_push(it_rects, { x : _cx0 - 3, y : _nyy - 1, w : _cw, h : _h, nt : _nt });
		}
		_nyy += _h;
	}
	if (array_length(_sh2.notes) == 0) { draw_set_color(_dim); draw_set_alpha(.35); draw_text(_cx0, _nvy, "- (blank)"); }
	if (misc_nmax > 0) {   // the thumb, a px wide at the column's edge
		draw_sprite_ext(spr_pixel_1x1, 0, _cx0 + _cw, _nvy, 1, _nvh, 0, c_black, .6);
		var _th = max(6, _nvh * _nvh / max(1, _ntot)), _ty = _nvy + (_nvh - _th) * (misc_scr_n / misc_nmax);
		draw_sprite_ext(spr_pixel_1x1, 0, _cx0 + _cw, _ty, 1, _th, 0, _dim, .9);
	}
	// THE FRIENDSHIPS, under it: every other sprite it has been out with,
	// closest first; the wheel scrolls
	var _fx = _cx0, _fy0 = _ctop + _nh + 6;
	draw_set_color(_ink); draw_set_alpha(.5); draw_text(_fx, _fy0, "friendships");
	var _fr = [];
	for (var _i = 0; _i < array_length(g.sprites); _i++) {
		var _o = g.sprites[_i];
		if (_o.id == _sp.id) continue;
		var _b = exped_bond(_sp.id, _o.id);
		if (_b > 0) array_push(_fr, { sp : _o, b : _b });
	}
	for (var _i = 1; _i < array_length(_fr); _i++) { var _t = _fr[_i], _j = _i - 1; while (_j >= 0 && _fr[_j].b < _t.b) { _fr[_j + 1] = _fr[_j]; _j--; } _fr[_j + 1] = _t; }
	var _fvy = _fy0 + 11, _fvh = _fh - 11, _fw = _cw;
	misc_fmax = max(0, array_length(_fr) * 10 - _fvh);
	misc_scr_f = clamp(misc_scr_f, 0, misc_fmax);
	misc_frect = { x : _fx - 3, y : _fvy, w : _fw + 6, h : _fvh };
	if (array_length(_fr) == 0) {
		draw_set_color(_dim); draw_set_alpha(.5);
		draw_text_ext(_fx, _fvy, "no one yet - trips together build these", 9, _fw);
		return;
	}
	var _tw = ["", "acquainted", "friends", "inseparable"];
	var _fy = _fvy - misc_scr_f;
	for (var _i = 0; _i < array_length(_fr); _i++) {
		if (_fy >= _fvy && _fy + 10 <= _fvy + _fvh + 1) {
			var _f = _fr[_i], _tier = exped_bond_tier(_f.b);
			if (_i & 1) draw_sprite_ext(spr_pixel_1x1, 0, _fx - 3, _fy - 1, _fw + 6, 10, 0, c_white, .04);
			__dot(_fx + 3, _fy + 4, 2, _f.sp.col, .95);
			draw_set_halign(fa_left); draw_set_color(_f.sp.col); draw_set_alpha(.95); draw_text(_fx + 9, _fy, __sheet_cut(_f.sp.name, _fw - 70));
			draw_set_halign(fa_right); draw_set_color((_tier >= 3) ? c_gold : ((_tier == 2) ? c_sgreen : _dim)); draw_set_alpha(.9);
			draw_text(_fx + _fw, _fy, _tw[_tier] + "  " + string(round(_f.b)));
		}
		_fy += 10;
	}
	if (misc_fmax > 0) {
		draw_sprite_ext(spr_pixel_1x1, 0, _fx + _fw, _fvy, 1, _fvh, 0, c_black, .6);
		var _fth = max(6, _fvh * _fvh / max(1, array_length(_fr) * 10)), _fty = _fvy + (_fvh - _fth) * (misc_scr_f / misc_fmax);
		draw_sprite_ext(spr_pixel_1x1, 0, _fx + _fw, _fty, 1, _fth, 0, _dim, .9);
	}
	draw_set_halign(fa_left);
};
// THE STATUS PIPS (2026-09-17): a 2x2 dot per effect on a pawn in the
// combat window - venom green, slow blue, the mark purple, a blessing
// gold, a nerf red, regen white - under its hp bar
__pips = function(_p, _x, _y) {
	if (!is_struct(_p[$ "ail"])) return;
	var _cols = [];
	if (_p.ail.poison > 0) array_push(_cols, c_sgreen);
	if (_p.ail.slow > 0)   array_push(_cols, c_sblue);
	if (_p.ail.leech > 0)  array_push(_cols, c_hpurple);
	if (is_struct(_p[$ "bf"]) && (_p.bf.atk > 0 || _p.bf.def > 0 || _p.bf.hit > 0 || _p.bf.spd > 0)) array_push(_cols, c_gold);
	if (is_struct(_p[$ "nf"]) && (_p.nf.atk > 0 || _p.nf.def > 0 || _p.nf.hit > 0)) array_push(_cols, c_hred);
	if ((_p[$ "regen"] ?? 0) > 0) array_push(_cols, c_white);
	for (var _i = 0; _i < array_length(_cols); _i++) {
		draw_sprite_ext(spr_pixel_1x1, 0, _x + _i * 3 - 1, _y - 1, 4, 4, 0, c_black, .8);
		draw_sprite_ext(spr_pixel_1x1, 0, _x + _i * 3, _y, 2, 2, 0, _cols[_i], .95);
	}
};
// has any sprite a note on this kind? (the bestiary reveals a studied
// kind's element and table - the notepad's second job, 2026-09-17)
__kind_studied = function(_kind) {
	for (var _i = 0; _i < array_length(g.sprites); _i++) {
		var _nk = sprite_notes_kinds(g.sprites[_i]);
		for (var _k = 0; _k < array_length(_nk); _k++) if (string_pos(_kind + ":", _nk[_k]) == 1) return true;
	}
	return false;
};
/// THE ABILITY PICKER's tap (2026-09-17): a row picks that rung into the
/// slot the popup was opened on (or empties it); anywhere else folds it
/// THE SLOT ROW (his spec, 2026-09-17: "rounded ends like the ability
/// slots / upgrade slots... a faint background of its rarity with the
/// outline the solid colour of its rarity"): a capsule in the colour,
/// a black capsule a pixel inside it, the colour washed faintly over that
// ...OFF A SPRITE HE CAN EDIT (his ask, 2026-09-17): spr_slot_end, 6 x 11,
// frame 0 the rim of the left end, frame 1 its fill - drawn at the left
// end, mirrored at the right, the middle a stretch of the same two ideas
// (a 1 px rim top and bottom, the fill between). Rows are 11 tall.
__slot_row = function(_x, _y, _w, _h, _col, _open = false, _sel = false) {
	if (_open) return;   // (an empty slot is EMPTY - no rim, no wash - his call, 2026-09-17)
	// RIMLESS (his ask, 2026-09-17: "without the outline... leave the outline
	// when i select it"): the wash alone makes the capsule; the rim in the
	// colour is the SELECTED state - the popup up for this row
	var _ra = _sel ? .95 : 0, _fa = _sel ? .2 : .13;
	var _cw = sprite_get_width(spr_slot_end), _mid = _w - _cw * 2;
	// the black under everything (the wash tints black, never the sheet)
	draw_sprite_ext(spr_slot_end, 1, _x, _y, 1, 1, 0, c_black, .92);
	draw_sprite_ext(spr_slot_end, 1, _x + _w, _y, -1, 1, 0, c_black, .92);
	if (_mid > 0) draw_sprite_ext(spr_pixel_1x1, 0, _x + _cw, _y + 1, _mid, _h - 2, 0, c_black, .92);
	// the fill's wash
	if (_fa > 0) {
		draw_sprite_ext(spr_slot_end, 1, _x, _y, 1, 1, 0, _col, _fa);
		draw_sprite_ext(spr_slot_end, 1, _x + _w, _y, -1, 1, 0, _col, _fa);
		if (_mid > 0) draw_sprite_ext(spr_pixel_1x1, 0, _x + _cw, _y + 1, _mid, _h - 2, 0, _col, _fa);
	}
	// the rim (the selection only)
	if (_ra > 0) {
		draw_sprite_ext(spr_slot_end, 0, _x, _y, 1, 1, 0, _col, _ra);
		draw_sprite_ext(spr_slot_end, 0, _x + _w, _y, -1, 1, 0, _col, _ra);
		if (_mid > 0) {
			draw_sprite_ext(spr_pixel_1x1, 0, _x + _cw, _y, _mid, 1, 0, _col, _ra);
			draw_sprite_ext(spr_pixel_1x1, 0, _x + _cw, _y + _h - 1, _mid, 1, 0, _col, _ra);
		}
	}
};
__ab_pick_tap = function() {
	if (!is_struct(it_pop) || is_undefined(it_pop[$ "ab"])) return false;
	var _sp = it_pop.sp;
	if (!is_undefined(_sp)) {
		var _sh = sprite_sheet(_sp);
		if (!is_array(_sh[$ "abil"])) _sh.abil = [-1, -1, -1, -1];
		// the button commits (take two, 2026-09-17)
		if (is_struct(ab_btn) && point_in_rectangle(mouse_x, mouse_y, ab_btn.x, ab_btn.y, ab_btn.x + ab_btn.w, ab_btn.y + ab_btn.h)) {
			_sh.abil[it_pop.ab] = ab_btn.k;
			save_mark_dirty();
			play_sound_ext(snd_apply, 1, 1.1, .45, 1);
			it_pop = undefined; ab_rects = []; ab_btn = undefined;
			return true;
		}
		// a row selects - the pane reads it; the popup stays
		for (var _i = 0; _i < array_length(ab_rects); _i++) {
			var _r = ab_rects[_i];
			if (!point_in_rectangle(mouse_x, mouse_y, _r.x, _r.y, _r.x + _r.w, _r.y + _r.h)) continue;
			it_pop.sel = _r.k;
			play_sound_ext(snd_softclick, 1.05, 1.15, .35, 1);
			return true;
		}
	}
	it_pop = undefined; ab_rects = []; ab_btn = undefined;
	return true;
};
__sheet_tap = function() {
	if (SPRITE_AB_PICK && is_struct(it_pop) && !is_undefined(it_pop[$ "ab"]) && it_pop.ab < 4) return __ab_pick_tap();   // (the picker, when it is back - never the flaw's slot)
	if (is_struct(it_pop)) { it_pop = undefined; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); return true; }
	for (var _k = 0; _k < array_length(it_rects); _k++) {
		var _ir = it_rects[_k];
		if (point_in_rectangle(mouse_x, mouse_y, _ir.x, _ir.y, _ir.x + _ir.w, _ir.y + _ir.h)) {
			// the page pills (2026-09-17): no popup, just the turn
			if (!is_undefined(_ir[$ "pg"])) { sheet_pg = _ir.pg; play_sound_ext(snd_softclick, 1, 1.1, .4, 1); return true; }
			var _psp0 = __sp_by_id(sheet_id), _psel = -2;
			if (!is_undefined(_ir[$ "ab"]) && !is_undefined(_psp0) && _ir.ab < 4) { var _pwn0 = sprite_ability_worn(_psp0); if (_pwn0[_ir.ab] >= 0) _psel = _pwn0[_ir.ab]; }   // (the slot's own, read at once; the fifth is the flaw's)
			it_pop = { it : _ir[$ "it"], sk : _ir[$ "sk"], nt : _ir[$ "nt"], st : _ir[$ "st"], ab : _ir[$ "ab"], sel : _psel, lvup : _ir[$ "lvup"] ?? false, sp : _psp0, worn : _ir[$ "worn"] ?? false, x : _ir.x, y : _ir.y + _ir.h + 2, w : _ir.w };
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			return true;
		}
	}
	return false;
};
// (the chips and the old brief rects went with the preparation page's rework, 2026-09-15 - see __dp_* above)
__dismiss_r = function() { return { x : room_width - (land ? 14 : 4) - 80, y : room_height - 8 - 16, w : 80, h : 16 }; };   // THE SPRITE MENU's [dismiss] (2026-09-16)
__crewbtn_r = function() { return { x : card_x0, y : room_height - 8 - 14, w : 44, h : 14 }; };   // (narrower, 2026-09-16: three buttons fit under the card - [crew] [galaxy] [bestiary])
// the crew menu: tabs down the left (one a sprite), the picked one's sheet on the right (his ask, 2026-09-14)
tab_w = land ? 78 : 60; tab_h = 15;
ab_rects = [];  // the ability picker's rows (the Draw lays them down, __ab_pick_tap reads them) - VAULTED behind SPRITE_AB_PICK (2026-09-17)
ab_btn   = undefined;   // ...and its [equip] / [unequip] / [clear] button
misc_scr_n = 0; misc_scr_f = 0;   // the [misc] page's two scrolls: the notepad, the friendships (px)
misc_nrect = undefined; misc_frect = undefined; misc_nmax = 0; misc_fmax = 0;
sheet_pg = 0;   // the sheet's page: 0 stats, 1 gear, 2 misc (the ledger, the friendships, the notepad) - his spec 2026-09-17
// THE CREW COLUMN'S TOP: under the objective card while it is up (his
// screenshot, 2026-09-17: the folded card's three boxes sat on the first
// tab - the card lives over every panel by his earlier ask, so the tabs
// give way; they glide up as it folds)
__crew_y0 = function() {
	var _y = list_y + 22;
	if (instance_exists(syst_objectives) && syst_objectives.a > .05 && syst_objectives.okey != "") {
		var _cr = syst_objectives.__rect();
		if (_cr.x < (land ? 14 : 4) + tab_w) _y = max(_y, _cr.y + _cr.h + 4);
	}
	return _y;
};
__tab_r = function(_k) { return { x : land ? 14 : 4, y : __crew_y0() + _k * (tab_h + 2), w : tab_w, h : tab_h }; };
__sheet_x0 = function() { return (land ? 14 : 4) + tab_w + 10; };
__recall_r = function() { return { x : log_x + log_w - 62, y : log_y + 4, w : 56, h : 12 }; };   // (in the quest island's corner)
__fight_r  = function() { return { x : log_x + log_w - fight_s, y : room_height - 8 - (land ? 18 : 0) - fight_s, w : fight_s, h : fight_s }; };   // the combat window: the right column's bottom-right corner (over the buttons' row on a wide page)
crew_row_h = land ? 36 : 44;
// the map view: the region drawn into this rect; [map] chips on a world card and the trip page
__map_r = function() { var _x = land ? (14 + rg_box_w + 10) : 4; return { x : _x, y : list_y + 22, w : room_width - _x - (land ? 14 : 4), h : room_height - 8 - 14 - (list_y + 22) }; };   // (right of the info box - his ask, 2026-09-15)
__map_box_r = function() { return { x : 14, y : list_y + 22, w : rg_box_w, h : rg_box_h }; };   // the region's info box on the map (landscape)
/// THE INFO BOX'S SIZE: as wide as its longest line (his ask), as tall as its lines
__info_box_size = function(_d, _rg) {
	var _inf = region_info(_d, _rg);
	var _wmax = land ? 200 : 120, _wmin = 96, _nshow = 3;   // (shut: the first three lines - the level, the biome, the weather)
	draw_set_font(fnt_large);
	var _w0 = string_width(str_cap(_rg.name)) + 28, _w1 = _w0;   // (+28: the fold glyph beside the name)
	draw_set_font(fnt);
	for (var _li = 0; _li < array_length(_inf); _li++) {
		var _lw = string_width(_inf[_li].k) + 12 + string_width(_inf[_li].v) + 16;   // (the name left, the value right - his ask, 2026-09-16)
		if (_li < _nshow) _w0 = max(_w0, _lw);
		_w1 = max(_w1, _lw);
	}
	_w0 = clamp(_w0, _wmin, _wmax); _w1 = clamp(max(_w1, _w0), _wmin, _wmax);
	var _w = round(lerp(_w0, _w1, rg_box_a));
	draw_set_font(fnt_large);
	var _nh = string_height_ext(str_cap(_rg.name), 11, _w - 26);
	draw_set_font(fnt);
	var _n0 = min(_nshow, array_length(_inf)), _n1 = array_length(_inf);
	var _h = 5 + _nh + 3 + round(lerp(_n0, _n1, rg_box_a) * 11) + 4;
	rg_box_w = _w; rg_box_h = _h;
	return { w : _w, h : _h, inf : _inf, nh : _nh };
};
__draw_info_box = function(_d, _rg, _bn) {
	var _bs = __info_box_size(_d, _rg);
	var _inf = _bs.inf;
	_bn.w = _bs.w; _bn.h = _bs.h;
	draw_sprite_ext(spr_pixel_1x1, 0, _bn.x, _bn.y, _bn.w, _bn.h, 0, c_black, .8);
	draw_sprite_ext(spr_pixel_1x1, 0, _bn.x, _bn.y, 2, _bn.h, 0, c_gold, .9);
	draw_set_font(fnt_large); draw_set_color(c_gold); draw_set_alpha(.95);
	draw_text_ext(_bn.x + 8, _bn.y + 5, str_cap(_rg.name), 11, _bn.w - 26);
	// the fold's glyph, top right (the house chip: + shut, - open); the whole box is the tap
	draw_set_font(fnt);
	draw_sprite_ext(spr_pixel_1x1, 0, _bn.x + _bn.w - 15, _bn.y + 4, 9, 9, 0, c_black, .6);
	draw_px_rect(_bn.x + _bn.w - 15, _bn.y + 4, 9, 9, c_gold, .5);
	draw_set_color(c_gold); draw_set_alpha(.9); draw_set_halign(fa_center);
	draw_text(_bn.x + _bn.w - 10, _bn.y + 4, rg_box_open ? "-" : "+");
	draw_set_halign(fa_left);
	var _bny = _bn.y + 5 + _bs.nh + 3;
	var _tc = [c_sgreen, c_gold, c_horange, c_hred];
	for (var _li = 0; _li < array_length(_inf); _li++) {
		if (_bny + 10 > _bn.y + _bn.h - 3) break;   // (the lines the fold shows; the rest wait under it)
		var _ln = _inf[_li];
		draw_set_color(sett_ink); draw_set_alpha(.8);
		draw_text(_bn.x + 8, _bny, _ln.k);
		var _lc = _ln[$ "col"];
		draw_set_color(is_undefined(_lc) ? _tc[clamp(_ln.t, 0, 3)] : _lc); draw_set_alpha(.95);
		draw_set_halign(fa_right); draw_text(_bn.x + _bn.w - 8, _bny, __sheet_cut(_ln.v, max(20, _bn.w - 16 - string_width(_ln.k) - 8))); draw_set_halign(fa_left);   // (the value right-aligned - his ask, 2026-09-16; cut while the fold eases)
		_bny += 11;
	}
};
/// THE WORLD BOX (the planet-properties pass, 2026-09-15): the info box's twin for the world itself - planet_props' lines under the
/// world's name, on the planet page in orbit mode (it slides out to the left as the region box slides in)
__world_box_r = function(_d) {
	var _pp = planet_props(_d);
	var _wmax = land ? 200 : 120, _wmin = 96;
	draw_set_font(fnt_large);
	var _w = string_width(str_cap(_d.name)) + 16;
	draw_set_font(fnt);
	for (var _li = 0; _li < array_length(_pp.lines); _li++) _w = max(_w, string_width(_pp.lines[_li].k) + 12 + string_width(_pp.lines[_li].v) + 16);
	_w = clamp(_w, _wmin, _wmax);
	draw_set_font(fnt_large);
	var _h = 5 + string_height_ext(str_cap(_d.name), 11, _w - 14) + 3 + array_length(_pp.lines) * 11 + 4;
	draw_set_font(fnt);
	return { x : (land ? 14 : 4) - rg_in * 240, y : list_y + 22, w : _w, h : _h };
};
__draw_world_box = function(_d) {
	var _bn = __world_box_r(_d), _pp = planet_props(_d), _wc = exped_world_col(_d);
	draw_sprite_ext(spr_pixel_1x1, 0, _bn.x, _bn.y, _bn.w, _bn.h, 0, c_black, .8);
	draw_sprite_ext(spr_pixel_1x1, 0, _bn.x, _bn.y, 2, _bn.h, 0, _wc, .9);
	draw_set_font(fnt_large); draw_set_color(_wc); draw_set_alpha(.95);
	draw_text_ext(_bn.x + 8, _bn.y + 5, str_cap(_d.name), 11, _bn.w - 14);
	var _bny = _bn.y + 5 + string_height_ext(str_cap(_d.name), 11, _bn.w - 14) + 3;
	draw_set_font(fnt);
	var _tc = [c_sgreen, c_gold, c_horange, c_hred];
	for (var _li = 0; _li < array_length(_pp.lines); _li++) {
		var _ln = _pp.lines[_li];
		draw_set_color(sett_ink); draw_set_alpha(.8);
		draw_text(_bn.x + 8, _bny, _ln.k);
		var _lc = _ln[$ "col"];
		draw_set_color(is_undefined(_lc) ? _tc[clamp(_ln.t, 0, 3)] : _lc); draw_set_alpha(.95);
		draw_set_halign(fa_right); draw_text(_bn.x + _bn.w - 8, _bny, _ln.v); draw_set_halign(fa_left);   // (the value right-aligned, the region box's way - 2026-09-16)
		_bny += 11;
	}
};
map_legend = false;                  // the legend popup (his ask: a [legend] button, the kinds listed)
map_pop = -1;                        // the place whose card is up (his ask, 2026-09-16: tap a node for its info)
// the minor biomes: NO NAME on the map unless a crew has business there (his call, 2026-09-16)
__map_minor = function(_kind) { return array_contains(["field", "forest", "hills", "marsh", "desert", "mountains", "tundra", "coast", "isle"], _kind); };
/// which places wear a name: every place that is not a minor biome, and any place a crew is
/// at, on the road to, next on its path to, or has a quest at -> bool per node
__map_named = function(_rg, _d) {
	var _e = g.exped;
	var _out = array_create(array_length(_rg.nodes), false);
	for (var _i = 0; _i < array_length(_out); _i++) _out[_i] = !__map_minor(_rg.nodes[_i].kind);
	for (var _t = 0; _t < array_length(_e.trips); _t++) {
		var _tr = _e.trips[_t];
		if (_tr.dest.seed != _d.seed || (_tr[$ "rgi"] ?? 0) != _rg.ri) continue;
		// (a COPY of the quest's places - a survey's list is the quest's own array, and pushing into it grew the quest a stop a frame; bug hunt 2026-09-16)
		var _qpl = is_struct(_tr[$ "quest"]) ? exped_quest_places(_tr.quest) : [], _mark = [];
		for (var _qi = 0; _qi < array_length(_qpl); _qi++) array_push(_mark, _qpl[_qi]);
		array_push(_mark, _tr[$ "pos"] ?? _rg.landing);
		if (is_struct(_tr[$ "road"])) array_push(_mark, _tr.road.b);
		var _pp = _tr[$ "path"] ?? [];
		if (array_length(_pp) > 0) array_push(_mark, _pp[0]);
		for (var _k = 0; _k < array_length(_mark); _k++) { var _mi = _mark[_k]; if (_mi >= 0 && _mi < array_length(_out)) _out[_mi] = true; }
	}
	return _out;
};
/// THE PLACE'S CARD (his ask, 2026-09-16: "click on a node to have a popup appear that shows info"):
/// the place's papers (region_node_info: population / economy / rooms / who holds it / the
/// going... and a line of description), the roads out by name with their hours
/// (region_road_name), every crew with business there, and its LORE at the foot
__map_node_card = function(_d, _rg, _mr, _ni) {
	var _nd = _rg.nodes[_ni], _kk = region_kinds(), _kd = _kk[$ _nd.kind] ?? _kk.field, _e = g.exped;
	var _np = __map_xy(_nd, _rg, _mr);
	var _cw = 168, _iw = _cw - 12;
	var _pp = region_node_info(_d, _rg, _ni);
	var _rows = [];
	for (var _ri = 0; _ri < array_length(_pp.rows); _ri++) array_push(_rows, _pp.rows[_ri]);
	// THE LEADER of the day, the two before, the best remembered (region_node_leader - the wall clock, nothing saved; 2026-09-16)
	var _ld = region_node_leader(_d, _rg, _ni);
	if (is_struct(_ld)) {
		array_push(_rows, { k : _ld.camp ? "chief" : "led by", v : _ld.name + " the " + _ld.title + " (" + _ld.trait + ", " + string(floor(_ld.days)) + "d)", col : c_gold });
		array_push(_rows, { k : "before", v : _ld.prev[0].name + " (" + _ld.prev[0].went + ")", col : undefined });
		array_push(_rows, { k : "", v : _ld.prev[1].name + " (" + _ld.prev[1].went + ")", col : undefined });
		if (!_ld.camp) array_push(_rows, { k : "best", v : _ld.best.name + ((_ld.best.back == 0) ? " (now)" : ((_ld.best.back == 1) ? " (the last)" : (" (" + string(_ld.best.back) + " back)"))), col : c_sgreen });
	}
	var _fkc = region_node_folk(_d, _rg, _ni);
	if (is_struct(_fkc)) array_push(_rows, { k : "folk", v : _fkc.keeper.name + " (shop), " + _fkc.trader.name + " (trade)", col : undefined });
	if (!_kd.civ && _nd.kind != "landing" && _nd.kind != "shrine" && _nd.kind != "mine") {
		// (only the foes you have MET are named - the bestiary's ledger; the rest is "unmet", 2026-09-16)
		var _fk = foe_kinds_at(_nd.kind), _ft = "", _unk = 0;
		for (var _fi = 0; _fi < min(3, array_length(_fk)); _fi++) { var _fb = __bs_met(_fk[_fi]); if (is_struct(_fb) && _fb.seen > 0) _ft += ((_ft != "") ? ", " : "") + foe_plural(_fk[_fi]); else _unk++; }
		if (_unk > 0) _ft += ((_ft != "") ? ", " : "") + ((_unk == 1) ? "something unmet" : (string(_unk) + " unmet"));
		array_push(_rows, { k : "foes", v : _ft, col : c_hred });
	}
	var _hz = region_hazard_at(_d, _rg, _nd.kind);   // (the season's too, 2026-09-16)
	if (!is_undefined(_hz)) array_push(_rows, { k : "hazard", v : _hz.name, col : _hz.col });
	// THE WORLD REMEMBERS (2026-09-16): what the crews left here, and for how long
	var _mks = [["quiet", "cleared - quiet for "], ["routed", "routed - ashes for "], ["grateful", "grateful - a bed on the house for "], ["barred", "barred from the tavern for "], ["shelf", "the shelf restocks in "]];
	for (var _mi = 0; _mi < array_length(_mks); _mi++) { var _mm = exped_mem_get(_d, map_rgi, _ni, _mks[_mi][0]); if (is_struct(_mm)) array_push(_rows, { k : "memory", v : _mks[_mi][1] + string(ceil(_mm.left / EXPED_HOUR)) + "h", col : c_gold }); }
	// the roads out, by name
	var _rt = "";
	for (var _ei = 0; _ei < array_length(_rg.edges); _ei++) {
		var _ed = _rg.edges[_ei];
		var _o = (_ed.a == _ni) ? _ed.b : ((_ed.b == _ni) ? _ed.a : -1);
		if (_o < 0) continue;
		_rt += ((_rt != "") ? "; " : "") + _rg.nodes[_o].name + " " + string(_ed.d) + "h by " + region_road_name(_rg, _ei);
	}
	if (_rt != "") array_push(_rows, { k : "roads", v : _rt, col : undefined });
	for (var _t = 0; _t < array_length(_e.trips); _t++) {
		var _tr = _e.trips[_t];
		if (_tr.dest.seed != _d.seed || (_tr[$ "rgi"] ?? 0) != _rg.ri || _tr.stage != 1) continue;
		var _here = ((_tr[$ "pos"] ?? -1) == _ni && !is_struct(_tr[$ "road"]));
		var _to = (is_struct(_tr[$ "road"]) && _tr.road.b == _ni);
		var _on = array_contains(_tr[$ "path"] ?? [], _ni);
		var _qh = is_struct(_tr[$ "quest"]) ? array_contains(exped_quest_places(_tr.quest), _ni) : false;
		var _v = _here ? "here now" : (_to ? "on the road here" : (_on ? "passing through" : (_qh ? "the quest is here" : "")));
		if (_v != "") array_push(_rows, { k : exped_crew_txt(_tr.names), v : _v, col : _tr.cols[0] });
	}
	// the height: the name, the kind, the description, the rows (a value that fits sits right of
	// its key; a long one wraps under it), the lore
	draw_set_font(fnt);
	var _dh = (_pp.desc != "") ? string_height_ext(_pp.desc, 9, _iw) + 3 : 0;
	var _lh = (_pp.lore != "") ? string_height_ext("\"" + _pp.lore + "\"", 9, _iw) + 3 : 0;
	var _ch = 4 + 10 + 10 + _dh + 1;
	var _fits = array_create(array_length(_rows), true);
	for (var _ri = 0; _ri < array_length(_rows); _ri++) {
		_fits[_ri] = (string_width(_rows[_ri].k) + 8 + string_width(_rows[_ri].v) <= _iw);
		_ch += _fits[_ri] ? 10 : (10 + string_height_ext(_rows[_ri].v, 9, _iw) + 1);
	}
	_ch += 3 + _lh + 3;
	var _cx = floor(_np.x) + 12, _cy = floor(_np.y) - 8;
	if (_cx + _cw > _mr.x + _mr.w - 4) _cx = floor(_np.x) - 12 - _cw;
	_cx = clamp(_cx, _mr.x + 4, _mr.x + _mr.w - _cw - 4);
	_cy = clamp(_cy, _mr.y + 4, _mr.y + _mr.h - _ch - 4);
	draw_sprite_ext(spr_pixel_1x1, 0, _cx + 2, _cy + 3, _cw, _ch, 0, c_black, .5);
	draw_sprite_ext(spr_pixel_1x1, 0, _cx, _cy, _cw, _ch, 0, c_hsv(169, 186, 9), .98);
	draw_px_rect(_cx, _cy, _cw, _ch, _kd.col, .8);
	var _ty = _cy + 4;
	draw_set_color((_nd[$ "landing"] ?? false) ? c_white : _kd.col); draw_set_alpha(.95);
	draw_text(_cx + 6, _ty, __sheet_cut(_nd.name, _iw)); _ty += 10;
	draw_set_color(dim); draw_set_alpha(.7);
	draw_text(_cx + 6, _ty, _kd.name + ((_nd[$ "landing"] ?? false) && _nd.kind != "landing" ? "  -  the landing zone" : "")); _ty += 10;
	if (_pp.desc != "") { draw_set_color(sett_ink); draw_set_alpha(.85); draw_text_ext(_cx + 6, _ty, _pp.desc, 9, _iw); _ty += _dh; }
	_ty += 1;
	for (var _ri = 0; _ri < array_length(_rows); _ri++) {
		var _rw = _rows[_ri];
		draw_set_color(dim); draw_set_alpha(.8);
		draw_text(_cx + 6, _ty, _rw.k);
		draw_set_color(is_undefined(_rw.col) ? sett_ink : _rw.col); draw_set_alpha(.95);
		if (_fits[_ri]) { draw_set_halign(fa_right); draw_text(_cx + _cw - 6, _ty, _rw.v); draw_set_halign(fa_left); _ty += 10; }
		else { _ty += 10; draw_text_ext(_cx + 6, _ty, _rw.v, 9, _iw); _ty += string_height_ext(_rw.v, 9, _iw) + 1; }
	}
	if (_pp.lore != "") {
		_ty += 3;
		draw_sprite_ext(spr_pixel_1x1, 0, _cx + 6, _ty - 2, _iw, 1, 0, _kd.col, .25);
		draw_set_color(merge_colour(c_lavender, dim, .35)); draw_set_alpha(.8);
		draw_text_ext(_cx + 6, _ty, "\"" + _pp.lore + "\"", 9, _iw);
	}
	draw_set_alpha(1);
};
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
		case "sewer": {
			// the grate: a dark square with three bars (2026-09-16)
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 4, _y - 3, 8, 7, 0, c_black, .9);
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 4, _y - 3, 8, 1, 0, _col, .95);
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 4, _y + 3, 8, 1, 0, _col, .95);
			for (var _gb = -3; _gb <= 3; _gb += 3) draw_sprite_ext(spr_pixel_1x1, 0, _x + _gb - 1, _y - 2, 1, 5, 0, _col, .95);
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
__map_labels = function(_rg, _mr, _key, _named = undefined) {   // (named: bool per node - an unnamed place takes no label and holds no room, 2026-09-16)
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
		if (is_array(_named) && !_named[_i]) continue;
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
// THE CREW'S BANNERS (his ask, 2026-09-15: under the world box): a row each
// under the button row - dot, name, level, the hp bar (live in a fight)
__crew_row_r = function(_k) { return { x : big_x, y : big_y + isle_h + 4 + _k * (__dp_bh() + 2), w : big_w, h : __dp_bh() }; };   // the crew's banners under the island (the preparation page's) - four fit (2026-09-15)
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
	var _sky = __sky_for(_d);   // (the world's own sky, 2026-09-16)
	var _pn = planet_get(_d.seed, exped_planet_hint(_d));
	var _built = (_pn.row >= _pn.th) && ((_pn[$ "brow"] ?? 0) >= 3 * _pn.th);   // (rows AND textures: planet_draw bakes whole otherwise - __worlds_step slices it)
	var _wm = mat3_mul(mat3_rot(0, 0, 1, _pn.tilt), mat3_rot(0, 1, 0, _spin));
	var _mm = mat3_mul(mat3_transpose(_wm), _cam);
	var _mr = mat3_transpose(_mm);
	var _fa = g.ui_fade_a;
	ui_fade_set(1);
	surface_set_target(wb_surf);
	draw_clear_alpha(c_black, 1);
	// the sun's occluders: the world's disc, and the moons' (the moon maths of moon_draw - an eclipse from the camera's seat, 2026-09-16)
	var _occs = [{ x : _pcx, y : _pcy, r : _pr }];
	var _mns0 = planet_moons(_d.seed), _nmn0 = min(4, planet_props(_d).moons);
	for (var _mi0 = 0; _mi0 < _nmn0; _mi0++) { var _mv0 = moon_view_pos(_pn, _mns0[_mi0], _cam); var _k0 = 6 / max(6 - _mv0[2], .5); array_push(_occs, { kind : "moon", x : _pcx + _mv0[0] * _pr * _k0, y : _pcy + _mv0[1] * _pr * _k0, r : max(1, _mv0[3] * _pr * 1.02 * _k0) }); }
	galaxy_sky_draw(_sky, _cam, _pcx, _pcy, _w, _h, true, true, _occs);   // (the sun fades behind the world - his report 2026-09-16)
	galaxy_fog_draw(_sky, _cam, _pcx, _pcy, _w, _h, sky_fog_surf);
	// THE METEOR (2026-09-16): a streak now and then, fading along its length; page space, before the world (it is sky)
	sky_met_t += delta / 60;
	if (is_undefined(sky_met) && sky_met_t > (starmap_config()[$ "sky_meteor"] ?? 28) * random_range(.6, 1.5)) {
		var _ma = random(360), _ml = random_range(40, 90);
		sky_met = { x : random_range(_w * .1, _w * .9), y : random_range(_h * .1, _h * .6), dx : dcos(_ma) * _ml, dy : -dsin(_ma) * _ml, t : 0, life : random_range(.28, .45) };
		sky_met_t = 0;
	}
	if (is_struct(sky_met)) {
		var _mt = sky_met.t / sky_met.life;
		var _hx = sky_met.x + sky_met.dx * _mt, _hy = sky_met.y + sky_met.dy * _mt;
		for (var _mi2 = 0; _mi2 < 7; _mi2++) { var _mf = _mi2 / 7; draw_sprite_ext(spr_pixel_1x1, 0, floor(_hx - sky_met.dx * .22 * _mf), floor(_hy - sky_met.dy * .22 * _mf), 1, 1, 0, merge_colour(c_white, rgb(200, 220, 255), _mf), (1 - _mf) * (1 - _mt * _mt) * .9); }
		sky_met.t += delta / 60;
		if (sky_met.t >= sky_met.life) sky_met = undefined;
	}
	g.dither_off = page_float();   // (the world into a float page: no dither of its own - the blit's grain is the one)
	// THE MOONS (the tech demo's, back - 2026-09-15): the far half before the world, the near half after
	var _mns = planet_moons(_d.seed), _nmn = min(4, planet_props(_d).moons);
	if (_built) for (var _mi = 0; _mi < _nmn; _mi++) moon_draw(_pn, _mns[_mi], _mi, false, _pcx, _pcy, _pr, _cam, _sky.light_w);
	// the moons' shadow casters, and the storm regions' spots (2026-09-16)
	var _msh = [];
	for (var _mi = 0; _mi < _nmn; _mi++) array_push(_msh, moon_view_pos(_pn, _mns[_mi], _cam));
	var _storms = [];
	for (var _si = 0; _si < EXPED_REGIONS; _si++) { var _srg = region_get(_d, _si); if (region_weather(_d, _srg) == "storm") array_push(_storms, __spot_dir(_srg.spot.lon, _srg.spot.lat)); }
	if (_built) planet_draw(_pn, _pcx, _pcy, _pr, _spin, _cfade, _cam, _sky.light_w, _msh, _storms);
	if (_built) for (var _mi = 0; _mi < _nmn; _mi++) moon_draw(_pn, _mns[_mi], _mi, true, _pcx, _pcy, _pr, _cam, _sky.light_w);
	// THE ECLIPSE RIM (2026-09-16): the sun behind the world - its glare leaks round the limb on the side it hides behind
	if (_built) {
		var _svr = mat3_apply(mat3_transpose(_cam), _sky.light_w[0], _sky.light_w[1], _sky.light_w[2]);
		if (_svr[2] < -.1) {
			var _sfr = 230 / -_svr[2], _rsx = _pcx + _svr[0] * _sfr, _rsy = _pcy + _svr[1] * _sfr;
			var _rdd = point_distance(_rsx, _rsy, _pcx, _pcy);
			if (_rdd < _pr * 1.25 && _rdd > .5) {
				// the leak peaks AT the limb and fades as the sun sinks behind (gone by half way in) - it held whole and snapped round, his report 2026-09-16
				var _hid = clamp(1 - abs(_rdd - _pr) / (_pr * .5), 0, 1);
				var _lx = _pcx + (_rsx - _pcx) / _rdd * _pr, _ly = _pcy + (_rsy - _pcy) / _rdd * _pr;
				var _gsz = (_pr * 1.1) / max(1, sprite_get_width(spr_vis_glow_soft));
				gpu_set_blendmode(bm_add);
				draw_sprite_ext(spr_vis_glow_soft, 0, _lx, _ly, _gsz, _gsz, 0, _sky.sun_col, .28 * _hid);
				draw_sprite_ext(spr_vis_glow_soft, 0, _lx, _ly, _gsz * .45, _gsz * .45, 0, merge_colour(_sky.sun_col, c_white, .5), .35 * _hid);
				gpu_set_blendmode(bm_normal);
			}
		}
	}
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
			var _rr = __spot_r(_pn, _rg.spot.lon, _rg.spot.lat);   // (on its own ground - the mountains' parallax, 2026-09-16)
			var _sx = floor(_pcx) + floor(_v[0] * _rr * _pr * .5) * 2, _sy = floor(_pcy) + floor(_v[1] * _rr * _pr * .5) * 2;
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
	// (the turntable's, 2026-09-16: the region's longitude and latitude, north up - cam is unused, kept for the callers)
	var _yp = __spot_yp(_pn, _spin, _rg);
	return __cam_tt(_pn, _yp.yaw, _yp.pitch);
};
/// THE TURNTABLE CAMERA: yaw about the world's axis, pitch above its plane, the axis
/// up the screen (the 180 roll at the end: view y runs down the screen) -> cam = view -> world
__cam_tt = function(_pn, _yaw, _pitch) {
	var _af = mat3_rot(0, 0, 1, _pn.tilt);
	return mat3_mul(mat3_mul(_af, mat3_rot(0, 1, 0, _yaw)), mat3_mul(mat3_rot(1, 0, 0, _pitch), [-1, 0, 0, 0, -1, 0, 0, 0, 1]));
};
/// a step of the camera toward a target camera: the ONE rotation between them (axis-angle of
/// target x cam^T, world space), a fraction k of its angle; undefined once within .05 degree (arrived)
__cam_toward = function(_cam, _tgt, _k) {
	var _rr = mat3_mul(_tgt, mat3_transpose(_cam));
	var _ang = darccos(clamp((_rr[0] + _rr[4] + _rr[8] - 1) * .5, -1, 1));
	if (_ang < .05) return undefined;   // (there: the caller takes the target itself)
	var _ax = _rr[7] - _rr[5], _ay = _rr[2] - _rr[6], _az = _rr[3] - _rr[1];
	var _al = sqrt(_ax * _ax + _ay * _ay + _az * _az);
	if (_al < .0001) { _ax = 0; _ay = 1; _az = 0; }   // (180 degrees apart: any axis in the plane; take the world's up)
	// (mat3_rot's sin is flipped for the screen - both signs tried, the one that closes the gap kept)
	var _c1 = mat3_mul(mat3_rot(_ax, _ay, _az, _ang * _k), _cam), _c2 = mat3_mul(mat3_rot(_ax, _ay, _az, -_ang * _k), _cam);
	var _r1 = mat3_mul(_tgt, mat3_transpose(_c1)), _r2 = mat3_mul(_tgt, mat3_transpose(_c2));
	return ((_r1[0] + _r1[4] + _r1[8]) >= (_r2[0] + _r2[4] + _r2[8])) ? _c1 : _c2;
};
/// a region's spot as the turntable's yaw / pitch (its direction in the axis frame, the spin in;
/// the camera's own direction there is (-sin yaw cos pitch, sin pitch, cos yaw cos pitch))
__spot_yp = function(_pn, _spin, _rg) {
	var _t = __spot_dir(_rg.spot.lon, _rg.spot.lat);
	var _a = mat3_apply(mat3_rot(0, 1, 0, _spin), _t[0], _t[1], _t[2]);
	return { yaw : darctan2(-_a[0], _a[2]), pitch : darcsin(clamp(_a[1], -1, 1)) };
};
/// a world small (the hub's card, the list's rows, the haul's card): the
/// FULL world once it is built - clouds and ring (the globe at .62 so the
/// ring fits) - the lite portrait until then (his ask: every version
/// shows clouds). The caller has the fade off (the shader replaces it)
__world_small = function(_d, _cx, _cy, _r, _rg = undefined) {
	var _pn = planet_get(_d.seed, exped_planet_hint(_d));
	if (_pn.row >= _pn.th && (_pn[$ "brow"] ?? 0) >= 3 * _pn.th) {   // (built and baked - the small world too, bug hunt 2026-09-16)
		// FACING ITS REGION when the card is about one (his ask, 2026-09-15): the
		// spot dead on, the clock's spin under it (the terminator moves, the region holds)
		if (is_struct(_rg)) { var _sp = planet_spin_now(_pn); planet_draw(_pn, _cx, _cy, _pn.ring ? (_r * .62) : _r, _sp, 1, __cam_at(_pn, _sp, _rg), __sky_for(_d).light_w); }
		else planet_draw(_pn, _cx, _cy, _pn.ring ? (_r * .62) : _r);
	}
	else __portrait(_d, _cx, _cy, _r);
};
/// the worlds are built a few rows a frame (planet_gen_step): the board's,
/// the trips' and the planet window's - one of them a frame, so every
/// portrait gets its full world within a second or two
__worlds_step = function() {
	var _e = g.exped;
	// ONLY THE WORLD ON THE PAGE builds (his report, 2026-09-16: every opened world building at once lagged the first look):
	// the planet page's, a trip's or a haul's while its page shows - each on its first look, the boot's is the home world
	var _list = [];
	if (is_struct(pl_dest)) array_push(_list, pl_dest);
	if (view == "trip") { var _wt = __trip(); if (!is_undefined(_wt)) array_push(_list, _wt.dest); }
	if (view == "haul") { var _wh = __haul_i(); if (_wh >= 0) array_push(_list, _e.hauls[_wh].dest); }
	for (var _i = 0; _i < array_length(_list); _i++) {
		var _pn = planet_get(_list[_i].seed, exped_planet_hint(_list[_i]));
		if (_pn.row < _pn.th) { planet_gen_step(_pn, 6); return; }   // (six rows a frame: a fresh world in a quarter second)
		if ((_pn[$ "brow"] ?? 0) < 3 * _pn.th) { planet_bake(_pn, get_timer() + 4000); return; }   // (then its textures, four ms a frame - a world opened on the map baked whole on its first draw, a hitch; bug hunt 2026-09-16)
	}
};
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
	var _d = undefined;
	if (view == "planet") _d = pl_dest;
	else if (view == "trip") { var _lt = __trip(); if (!is_undefined(_lt)) _d = _lt.dest; }
	if (!is_struct(_d)) return undefined;
	var _pn = planet_get(_d.seed, exped_planet_hint(_d));
	if (_pn.row < _pn.th) return { txt : "building " + _d.name, prog : .7 * _pn.row / max(1, _pn.th) };
	var _brw = _pn[$ "brow"] ?? 0;
	if (_brw < 3 * _pn.th) return { txt : "building " + _d.name, prog : .7 + .3 * _brw / max(1, 3 * _pn.th) };
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
