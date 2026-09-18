/// @description ex_sheet_init() - THE SHEET of syst_exped_panel: the one painter of a sprite's sheet (the crew page's, the preparation page's modal, the trip's) - its pages (stats, gear, misc), its popups, the ability picker, the slot rows, the pips, the name cut - and the crew page's rectangles, tabs and taps; defined on the panel (self = the panel; called from its Create). q221, the deconvolution
function ex_sheet_init() {
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
}
