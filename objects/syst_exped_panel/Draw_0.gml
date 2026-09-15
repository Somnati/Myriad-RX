/// the expeditions' face - hub / trip / haul by `view`. Everything is
/// stamps and text under the fade; the portraits are sh_planet_lite on
/// a square quad (a shader of its own, reset before the text).
var _e   = g.exped;
var _dim = dim;
var _ink = sett_ink;
var _ea  = ui_anim_in(oa, 0);
if (_ea < .001) exit;
ui_fade_set(_ea);
draw_set_font(fnt);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
var _br = abs(dsin(current_time * .3));

// the ground + the strip
draw_sprite_ext(spr_pixel_1x1, 0, 0, hh, room_width, room_height - hh, 0, c_black, .94);
draw_sprite_ext(spr_pixel_1x1, 0, 0, strip_y, room_width, 16, 0, c_hsv(169, 186, 5), 1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, strip_y + 15, room_width, 1, 0, _ink, .25);
draw_set_color(c_steelblue);
draw_set_alpha(.95);
draw_text(6, strip_y + 5, "expeditions");
if (land) {
	draw_set_color(_dim);
	draw_set_alpha(.6);
	draw_text(6 + string_width("expeditions") + 8, strip_y + 5,
		(array_length(_e.trips) == 0) ? "" : (string(array_length(_e.trips)) + " out"));
}
// the debug clock
for (var _k = 0; _k < 3; _k++) {
	var _r = __spd_r(_k);
	var _on = (_e.spd == [1, 10, 100][_k]);
	draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, _r.w, _r.h, 0, c_black, .8);
	draw_px_rect(_r.x, _r.y, _r.w, _r.h, _on ? c_lavender : rgb(170, 190, 230), _on ? .9 : .4);
	draw_set_halign(fa_center);
	draw_set_color(_on ? c_lavender : _dim);
	draw_set_alpha(.9);
	draw_text(_r.x + _r.w * .5, _r.y + 3, "x" + string([1, 10, 100][_k]));
}
draw_set_halign(fa_left);

// [back], on a page
if (view != "hub") {
	var _bk = __back_r();
	draw_sprite_ext(spr_pixel_1x1, 0, _bk.x, _bk.y, _bk.w, _bk.h, 0, c_black, .8);
	draw_px_rect(_bk.x, _bk.y, _bk.w, _bk.h, rgb(170, 190, 230), .5);
	draw_set_halign(fa_center);
	draw_set_color(c_white);
	draw_set_alpha(.9);
	draw_text(_bk.x + _bk.w * .5, _bk.y + 3, "< back");
	draw_set_halign(fa_left);
}

// ======================= THE HAUL =======================
if (view == "haul") {
	var _hi = __haul_i();
	if (_hi < 0) { ui_fade_set(1); exit; }
	var _h = _e.hauls[_hi];
	var _found = 0;
	for (var _i = 0; _i < array_length(_h.finds); _i++) if (_h.finds[_i].kind == "sprite") _found++;
	var _recruit = (_found > 0 && array_length(g.sprites) + _found > SPRITE_CAP);

	if (swap_pick) {
		// THE ROSTER: who makes room
		draw_set_halign(fa_center);
		draw_set_color(c_white);
		draw_set_alpha(.95);
		draw_text(room_width * .5, list_y + 12, "the roster is full - who makes room for the new one?");
		for (var _k = 0; _k < array_length(g.sprites); _k++) {
			var _sp = g.sprites[_k];
			var _pr = __pick_r(_k);
			draw_sprite_ext(spr_pixel_1x1, 0, _pr.x, _pr.y, _pr.w, _pr.h, 0, c_black, .8);
			draw_px_rect(_pr.x, _pr.y, _pr.w, _pr.h, _sp.col, .4);
			__dot(_pr.x + 10, _pr.y + 8, 5, _sp.col, .95);
			draw_set_halign(fa_left);
			draw_set_color(c_white);
			draw_set_alpha(.95);
			draw_text(_pr.x + 20, _pr.y + 4, _sp.name);
			var _ri = upgrade_rarity_info(_sp[$ "rar"] ?? 0);
			draw_set_halign(fa_right);
			draw_set_color(_ri.col);
			draw_set_alpha(.8);
			var _mm = is_struct(_sp[$ "mem"]) ? _sp.mem : undefined;
			draw_text(_pr.x + _pr.w - 6, _pr.y + 4, _ri.name + ((_mm != undefined && _mm.trips > 0) ? ("  -  " + string(_mm.trips) + ((_mm.trips == 1) ? " trip" : " trips")) : ""));
		}
		draw_set_halign(fa_left);
		ui_fade_set(1);
		exit;
	}

	ui_fade_set(1); shader_reset();
	var _cw = land ? 260 : (room_width - 8), _ch = 40 + array_length(_h.finds) * 12 + (_recruit ? 52 : 40);
	var _cx = (room_width - _cw) * .5, _cy = max(list_y + 22, (room_height - _ch) * .5 - 6);
	ui_fade_set(_ea);
	draw_sprite_ext(spr_pixel_1x1, 0, _cx, _cy, _cw, _ch, 0, c_black, .9);
	draw_px_rect(_cx, _cy, _cw, _ch, _h.routed ? c_hred : c_gold, .6);
	draw_sprite_ext(spr_pixel_1x1, 0, _cx, _cy, _cw, 1, 0, _h.routed ? c_hred : c_gold, .9);
	ui_fade_set(1);
	__portrait(_h.dest, _cx + 22, _cy + 22, 12);
	ui_fade_set(_ea);
	draw_set_halign(fa_left);
	draw_set_color(c_white);
	draw_set_alpha(.95);
	draw_text(_cx + 42, _cy + 8, exped_crew_txt(_h.names) + ((array_length(_h.names) > 1) ? " are" : " is") + " back from " + _h.dest.name);
	draw_set_color(_h.routed ? c_hred : c_sgreen);
	draw_set_alpha(.85);
	draw_text(_cx + 42, _cy + 19, _h.routed ? ("routed - " + string(_h.cleared) + " of " + string(EXPED_ROOMS) + " rooms")
		: (string(_h.cleared) + " of " + string(EXPED_ROOMS) + " rooms cleared"));
	draw_sprite_ext(spr_pixel_1x1, 0, _cx + 8, _cy + 34, _cw - 16, 1, 0, _ink, .25);
	for (var _i = 0; _i < array_length(_h.finds); _i++) {
		var _l = _h.finds[_i];
		var _ry = _cy + 40 + _i * 12;
		draw_set_halign(fa_left);
		draw_set_color(_ink);
		draw_set_alpha(.55);
		draw_text(_cx + 10, _ry, (_i == 0) ? "the floor" : ("room find " + string(_i)));
		draw_set_halign(fa_right);
		draw_set_color(_l.col);
		draw_set_alpha(.95);
		draw_text(_cx + _cw - 10, _ry, (_l.kind == "sprite" && _recruit) ? "a sprite - wants to join" : _l.txt);
	}
	draw_set_halign(fa_left);
	if (_recruit) {
		draw_set_halign(fa_center);
		draw_set_color(c_gold);
		draw_set_alpha(.9);
		draw_text(room_width * .5, _cy + _ch - 34, "the roster is full (" + string(SPRITE_CAP) + ")");
		draw_set_halign(fa_left);
		var _sw = __swap_r(), _go = __go_r();
		draw_ui_button(_sw.x, _sw.y, _sw.w, _sw.h, "swap one out", c_gold, true, true);
		draw_ui_button(_go.x, _go.y, _go.w, _go.h, "let them go", c_gray, true, false);
	} else {
		var _cb = __col_r();
		draw_ui_button(_cb.x, _cb.y, _cb.w, _cb.h, "collect", c_gold, true, true);
	}
	ui_fade_set(1);
	exit;
}

// ======================= THE CREW LIST (his ask, 2026-09-14) =======================
// a row a sprite: the dot, the name, the class, the level, the hp; the
// eight stats; what is worn (the rarity's colour). Scrolls; tap = the sheet
if (view == "crew") {
	var _y0 = __crew_y0();
	var _keys = ["hp", "mp", "atk", "mag", "def", "mdef", "spd", "hit"];
	var _cls = sprite_classes();
	for (var _k = 0; _k < array_length(g.sprites); _k++) {
		var _sp = g.sprites[_k];
		var _r = __crew_row_r(_k);
		if (_r.y + _r.h < _y0 || _r.y > room_height - 8) continue;
		var _sh = sprite_sheet(_sp);
		var _st = sprite_stats(_sp);
		var _c  = _st.cls;
		var _away = (_sp[$ "trip"] ?? false);
		// the row's plate, clipped to the list's top
		var _ry = max(_r.y, _y0), _rh = _r.y + _r.h - _ry;
		if (_rh <= 0) continue;
		draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _ry, _r.w, _rh, 0, c_black, .55);
		draw_px_rect(_r.x, _ry, _r.w, _rh, _sp.col, .25);
		if (_r.y < _y0) continue;   // (a row cut by the top draws its plate only)
		var _tx = _r.x + 16, _ty = _r.y + 3;
		__dot(_r.x + 8, _ty + 4, 4, _sp.col, _away ? .4 : .95);
		draw_set_color(_sp.col); draw_set_alpha(.95);
		draw_text(_tx, _ty, _sp.name);
		var _nx = _tx + string_width(_sp.name) + 6;
		draw_set_color(_c.col); draw_set_alpha(.9);
		draw_text(_nx, _ty, _c.name);
		_nx += string_width(_c.name) + 6;
		draw_set_color(_ink); draw_set_alpha(.85);
		var _hpr = round((_st.pts.hp * cbt_balance().hp_per_point + cbt_balance().hp_flat_add) * 10) / 10;
		draw_text(_nx, _ty, "lv " + string(_sh.lv) + "   " + string(_hpr) + " hp   " + string(round(_st.total)) + " pts");
		draw_set_halign(fa_right);
		draw_set_color(_dim); draw_set_alpha(.7);
		draw_text(_r.x + _r.w - 4, _ty, _away ? "out" : (_sp.asleep ? "asleep" : "home"));
		draw_set_halign(fa_left);
		// the eight stats, one line
		var _sx = _tx, _sy = _ty + 11;
		for (var _q = 0; _q < 8; _q++) {
			draw_set_color(_dim); draw_set_alpha(.7);
			draw_text(_sx, _sy, _keys[_q]);
			draw_set_color(_ink); draw_set_alpha(.9);
			draw_text(_sx + string_width(_keys[_q]) + 2, _sy, string_format(_st.pts[$ _keys[_q]], 1, (land ? 1 : 0)));
			_sx += land ? 52 : 40;
			if (!land && _q == 3) { _sx = _tx; _sy += 9; }
		}
		// what is worn, in one line (the rarity's colour each)
		var _wx = _tx, _wy = _ty + (land ? 22 : 30);
		var _worn = _st.worn;
		if (array_length(_worn) == 0) { draw_set_color(_dim); draw_set_alpha(.4); draw_text(_wx, _wy, "wearing nothing"); }
		for (var _w = 0; _w < array_length(_worn); _w++) {
			var _it = _worn[_w];
			if (_w > 0) { draw_set_color(_dim); draw_set_alpha(.5); draw_text(_wx, _wy, "-"); _wx += 8; }
			draw_set_color(_it.col); draw_set_alpha(.9);
			draw_text(_wx, _wy, _it.name);
			_wx += string_width(_it.name) + 4;
			if (_wx > _r.x + _r.w - 40) break;
		}
	}
	// the list's title over the rows, and a scroll hint on the right
	draw_sprite_ext(spr_pixel_1x1, 0, 0, list_y + 16, room_width, _y0 - (list_y + 16), 0, c_black, .94);
	draw_set_color(_ink); draw_set_alpha(.6);
	draw_text(land ? 14 : 4, list_y + 6, "the crew  -  " + string(array_length(g.sprites)) + " of " + string(SPRITE_CAP) + "  -  tap one for its sheet");
	if (__crew_max_off() > 0) {
		var _th = room_height - 8 - _y0;
		var _bh = max(8, _th * _th / (array_length(g.sprites) * crew_row_h));
		var _by = _y0 + (_th - _bh) * (crew_off / __crew_max_off());
		draw_sprite_ext(spr_pixel_1x1, 0, room_width - (land ? 10 : 3), _by, 2, _bh, 0, _ink, .35);
	}
	ui_fade_set(1);
	exit;
}

// ======================= THE SHEET (2026-09-14, his pitch) =======================
// one sprite's class, level and xp, the eight stats (base + gear), the
// garnish, the four slot kinds with what is worn, the pocket, the skills
if (view == "sheet") {
	var _sp = __sp_by_id(sheet_id);
	if (is_undefined(_sp)) { ui_fade_set(1); exit; }
	var _sh = sprite_sheet(_sp);
	var _st = sprite_stats(_sp);
	var _c  = _st.cls;
	var _x0 = land ? 14 : 4, _y0 = list_y + 22;
	// the header: the dot, the name, the class, the level, the xp bar
	__dot(_x0 + 6, _y0 + 5, 5, _sp.col, .95);
	draw_set_color(_sp.col);
	draw_set_alpha(.95);
	draw_text(_x0 + 16, _y0, _sp.name);
	var _nx = _x0 + 16 + string_width(_sp.name) + 8;
	draw_set_color(_c.col);
	draw_text(_nx, _y0, _c.name);
	draw_set_color(_ink);
	draw_set_alpha(.85);
	draw_text(_nx + string_width(_c.name) + 8, _y0, "lv " + string(_sh.lv));
	var _need = sprite_xp_need(_sh.lv);
	var _xw = land ? 120 : 90, _xx = room_width - (land ? 14 : 4) - _xw - (land ? 60 : 0);
	draw_sprite_ext(spr_pixel_1x1, 0, _xx, _y0 + 3, _xw, 4, 0, c_black, .7);
	draw_sprite_ext(spr_pixel_1x1, 0, _xx, _y0 + 3, _xw * clamp(_sh.xp / max(1, _need), 0, 1), 4, 0, c_gold, .9);
	draw_set_color(_dim);
	draw_set_alpha(.7);
	draw_text(_xx, _y0 + 9, string(round(_sh.xp)) + " / " + string(_need) + " xp  -  " + string(SPRITE_LV_KILLS) + " par kills a level");
	// [<] [>] browse the roster
	var _pv = __sheet_prev_r(), _nv = __sheet_next_r();
	draw_ui_button(_pv.x, _pv.y, _pv.w, _pv.h, "<", rgb(170, 190, 230), true, false);
	draw_ui_button(_nv.x, _nv.y, _nv.w, _nv.h, ">", rgb(170, 190, 230), true, false);
	// the stats, two columns of four: label, the total, the gear's share
	var _keys = ["hp", "mp", "atk", "mag", "def", "mdef", "spd", "hit"];
	var _sy = _y0 + 24;
	draw_set_color(_ink);
	draw_set_alpha(.5);
	draw_text(_x0, _sy - 11, "stats  -  " + string(round(_st.total)) + " points  (a kill pays its foe's)");
	for (var _k = 0; _k < 8; _k++) {
		var _cx = _x0 + (_k div 4) * (land ? 110 : 80), _cy = _sy + (_k mod 4) * 11;
		draw_set_color(_dim); draw_set_alpha(.8);
		draw_text(_cx, _cy, _keys[_k]);
		draw_set_color(_ink); draw_set_alpha(.9);
		draw_set_halign(fa_right);
		draw_text(_cx + 58, _cy, string_format(_st.pts[$ _keys[_k]], 1, 1));
		draw_set_halign(fa_left);
		var _g = _st.gear[$ _keys[_k]];
		if (_g > 0) { draw_set_color(c_sgreen); draw_set_alpha(.8); draw_text(_cx + 62, _cy, "+" + string_format(_g, 1, 1)); }
	}
	var _hpr = round((_st.pts.hp * cbt_balance().hp_per_point + cbt_balance().hp_flat_add) * 10) / 10;
	draw_set_color(_dim); draw_set_alpha(.7);
	draw_text(_x0, _sy + 46, string(_hpr) + " hp  -  crit " + string(_c.crit) + "% x" + string(_c.cmulti) + "  -  counter " + string(_c.cnt) + "%" + (_c.magic ? "  -  casts" : ""));
	// the gear, right: the four slot kinds
	var _gx = land ? 250 : _x0, _gy = land ? _sy : (_sy + 60);
	draw_set_color(_ink); draw_set_alpha(.5);
	draw_text(_gx, _gy - 11, "gear");
	var _rows = [];
	array_push(_rows, { lbl : "primary",   it : _sh.w1 });
	array_push(_rows, { lbl : "secondary", it : _sh.w2 });
	for (var _i = 0; _i < _c.armor; _i++) array_push(_rows, { lbl : "armor",    it : (_i < array_length(_sh.armor)) ? _sh.armor[_i] : undefined });
	for (var _i = 0; _i < _c.talis; _i++) array_push(_rows, { lbl : "talisman", it : (_i < array_length(_sh.talis)) ? _sh.talis[_i] : undefined });
	for (var _i = 0; _i < array_length(_rows); _i++) {
		var _rw = _rows[_i];
		var _ry = _gy + _i * 11;
		draw_set_color(_dim); draw_set_alpha(.8);
		draw_text(_gx, _ry, _rw.lbl);
		if (is_undefined(_rw.it)) { draw_set_color(_dim); draw_set_alpha(.4); draw_text(_gx + 56, _ry, "- nothing -"); }
		else {
			draw_set_color(_rw.it.col); draw_set_alpha(.95);
			draw_text(_gx + 56, _ry, _rw.it.name);
			draw_set_color(_dim); draw_set_alpha(.6);
			draw_text(_gx + 56 + string_width(_rw.it.name) + 6, _ry, "lv" + string(_rw.it.lv) + " " + string_format(gear_score(_sp, _rw.it), 1, 0));
		}
	}
	// the pocket
	var _py = _gy + array_length(_rows) * 11 + 6;
	draw_set_color(_ink); draw_set_alpha(.5);
	draw_text(_gx, _py, "pocket  " + string(array_length(_sh.inv)) + " / " + string(SPRITE_INV));
	for (var _i = 0; _i < array_length(_sh.inv); _i++) {
		var _iy = _py + 11 + _i * 9;
		if (_iy > room_height - 12) break;
		draw_set_color(_sh.inv[_i].col); draw_set_alpha(.6);
		draw_text(_gx + 4, _iy, _sh.inv[_i].name);
	}
	// the skills, under the stats
	var _sk = sprite_skills(_sp);
	var _ky = _sy + 60;
	draw_set_color(_ink); draw_set_alpha(.5);
	draw_text(_x0, _ky, "skills");
	for (var _i = 0; _i < array_length(_sk); _i++) {
		var _s = _sk[_i];
		var _ly = _ky + 11 + _i * 10;
		draw_set_color(_s.magic ? c_hpurple : c_horange); draw_set_alpha(.9);
		draw_text(_x0, _ly, _s.name);
		draw_set_color(_dim); draw_set_alpha(.7);
		draw_text(_x0 + 90, _ly, string(_s.cost) + " mp  " + _s.targ + ((_s[$ "mult"] ?? 0) > 0 ? ("  x" + string_format(_s.mult, 1, 1)) : "") + ((_s[$ "healp"] ?? 0) > 0 ? ("  heals " + string(round(_s.healp * 100)) + "%") : ""));
	}
	if (_sh.lv < 20) { draw_set_color(_dim); draw_set_alpha(.4); draw_text(_x0, _ky + 11 + array_length(_sk) * 10, "next skill at level " + string((_sh.lv < 10) ? 10 : 20)); }
	// THE NOTEPAD (his ask): what it wrote on its journeys, newest last;
	// a foe note carries its tag colour (it counts: SPRITE_NOTE_HIT)
	var _ny = _ky + 11 + (array_length(_sk) + 1) * 10 + 4;
	draw_set_color(_ink); draw_set_alpha(.5);
	draw_text(_x0, _ny, "notepad  " + string(array_length(_sh.notes)) + " / " + string(SPRITE_NOTES));
	var _nmax = floor((room_height - 8 - (_ny + 11)) / 9);
	var _n0 = max(0, array_length(_sh.notes) - _nmax);
	for (var _i = _n0; _i < array_length(_sh.notes); _i++) {
		var _nt = _sh.notes[_i];
		var _ly2 = _ny + 11 + (_i - _n0) * 9;
		draw_set_color((_nt.tag != "") ? c_horange : _dim); draw_set_alpha((_nt.tag != "") ? .8 : .6);
		draw_text(_x0 + 4, _ly2, "- " + _nt.txt);
	}
	if (array_length(_sh.notes) == 0) { draw_set_color(_dim); draw_set_alpha(.35); draw_text(_x0 + 4, _ny + 11, "- (blank. it will write on the way)"); }
	ui_fade_set(1);
	exit;
}

// ======================= THE TRIP =======================
if (view == "trip") {
	var _tr = __trip();
	if (is_undefined(_tr)) { ui_fade_set(1); exit; }
	var _d  = _tr.dest;
	var _b  = exped_biomes()[_d.biome];
	var _n  = array_length(_tr.sids);
	// THE WORLD: the full planet (planet_get / planet_draw - the tech
	// demo's raycast sphere with the mountains) over its own stars; the
	// lite portrait holds the spot while the world is still being built
	draw_sprite_ext(spr_pixel_1x1, 0, big_x, big_y, big_w, big_h, 0, c_black, .95);
	ui_fade_set(1);
	planet_sky_draw(_d.seed, big_x + 2, big_y + 2, big_w - 4, land ? 100 : 60);
	var _pn = planet_get(_d.seed, exped_planet_hint(_d));
	var _pcx = big_x + big_w * .5, _pcy = big_y + (land ? 48 : 30), _ppr = land ? 34 : 20;
	if (_pn.row >= _pn.th) planet_draw(_pn, _pcx, _pcy, _ppr);
	else __portrait(_d, _pcx, _pcy, _ppr);
	draw_px_rect(big_x, big_y, big_w, big_h, merge_colour(_b.col2, c_white, .2), .5);
	ui_fade_set(_ea);
	draw_set_halign(fa_center);
	draw_set_color(c_white);
	draw_set_alpha(.95);
	draw_text(big_x + big_w * .5, big_y + (land ? 88 : 54), _d.name);
	draw_set_color(merge_colour(_b.col2, c_white, .3));
	draw_set_alpha(.8);
	draw_text(big_x + big_w * .5, big_y + (land ? 98 : 64), _b.name + " world  -  tier " + string(_d.tier) + "  -  lv " + string(exped_world_lv(_d)));
	draw_set_halign(fa_left);
	// the crew's hp, one bar each
	for (var _k = 0; _k < _n; _k++) {
		var _hy = big_y + (land ? 112 : 76) + _k * 11;
		if (_hy + 8 > big_y + big_h) break;
		__dot(big_x + 12, _hy + 3, 3, _tr.cols[_k], (_tr.hp[_k] > 0) ? .95 : .3);
		draw_set_color((_tr.hp[_k] > 0) ? _ink : _dim);
		draw_set_alpha(.8);
		draw_text(big_x + 19, _hy - 1, _tr.names[_k] + "  lv " + string(sprite_sheet(__sp_by_id(_tr.sids[_k]) ?? { id : 0 }).lv));   // (tap the row: the sheet)
		var _bw = big_w - 24 - 52;
		var _hf = clamp(_tr.hp[_k] / max(1, _tr.hpmax[_k]), 0, 1);
		draw_sprite_ext(spr_pixel_1x1, 0, big_x + big_w - 12 - _bw, _hy + 1, _bw, 4, 0, c_black, .7);
		draw_sprite_ext(spr_pixel_1x1, 0, big_x + big_w - 12 - _bw, _hy + 1, _bw * _hf, 4, 0, (_hf > .35) ? c_sgreen : c_hred, .9);
	}

	// the stage track: travel | delve | return
	var _sx = log_x, _sy = log_y, _sw = log_w;
	var _tf = clamp(_tr.t / max(1, _tr.dur), 0, 1);
	draw_sprite_ext(spr_pixel_1x1, 0, _sx, _sy + 8, _sw, 6, 0, c_black, .7);
	draw_sprite_ext(spr_pixel_1x1, 0, _sx, _sy + 8, _sw * _tf, 6, 0, c_steelblue, .9);
	draw_px_rect(_sx, _sy + 8, _sw, 6, c_steelblue, .35);
	var _m1 = _sx + _sw * EXPED_TRAVEL, _m2 = _sx + _sw * (1 - EXPED_RETURN);
	draw_sprite_ext(spr_pixel_1x1, 0, _m1, _sy + 6, 1, 10, 0, c_white, .5);
	draw_sprite_ext(spr_pixel_1x1, 0, _m2, _sy + 6, 1, 10, 0, c_white, .5);
	draw_set_color(_dim);
	draw_set_alpha(.7);
	draw_text(_sx, _sy + 18, "travel");
	draw_text(_m1 + 4, _sy + 18, "delve");
	draw_text(_m2 + 4, _sy + 18, "return");
	draw_set_halign(fa_right);
	draw_set_color(c_white);
	draw_set_alpha(.85);
	var _left = max(0, _tr.dur - _tr.t) / max(1, _e.spd);
	draw_text(_sx + _sw, _sy + 18, ((_tr.stage == 0) ? "travelling" : ((_tr.stage == 1) ? "delving" : "returning"))
		+ "  -  " + crunch_time_long(_left * 60) + ((_e.spd > 1) ? (" at x" + string(_e.spd)) : ""));
	draw_set_halign(fa_left);
	for (var _i = 0; _i < EXPED_ROOMS; _i++) {
		var _px = _m1 + (_m2 - _m1) * (_i + 1) / EXPED_ROOMS;
		var _done = (_i <= _tr.room_i);
		var _kc = c_white;
		switch (_tr.rooms[_i]) { case "find": _kc = c_gold; break; case "rest": _kc = c_sgreen; break; case "trap": _kc = c_horange; break; case "fight": _kc = c_hred; break; }
		draw_sprite_ext(spr_pixel_1x1, 0, _px - 2, _sy + 9, 4, 4, 0, _done ? _kc : c_black, _done ? .95 : .8);
		if (!_done) draw_px_rect(_px - 2, _sy + 9, 4, 4, _kc, .5);
	}

	// THE COMBAT WINDOW, while a fight is on - or while a fight that
	// ended off screen REPLAYS from its film (rp): a square at the
	// column's foot - the foe top right, the crew bottom left, hp bars,
	// a flash on whoever was just hit, the line beside it
	var _fighting = !is_undefined(_tr.fight) || !is_undefined(rp);
	var _fy = room_height - 8 - fight_s;
	if (_fighting) {
		var _f = _tr.fight;
		if (is_undefined(_f)) {
			// the film's frame as a fight: hp from the event, the flash on
			// its target, the party's shape from the record
			var _fr = rp.r.ev[rp.i];
			var _pp = [];
			for (var _q = 0; _q < array_length(rp.r.party); _q++) {
				var _pm = rp.r.party[_q];
				array_push(_pp, { name : _pm.name, col : _pm.col, hpmax : _pm.hpmax,
				                  hp : (_q < array_length(_fr.php)) ? _fr.php[_q] : _pm.hp });
			}
			var _pf = [];
			var _rfs = rp.r[$ "foes"] ?? [ rp.r.foe ];
			for (var _q = 0; _q < array_length(_rfs); _q++) {
				var _rf = _rfs[_q];
				var _fhps = _fr[$ "fhps"] ?? [ _fr.fhp ];
				array_push(_pf, { name : _rf.name, hpmax : _rf.hpmax, lv : _rf[$ "lv"] ?? 1, kind : _rf[$ "kind"] ?? "", col : _rf[$ "col"] ?? c_hred,
				                  hp : (_q < array_length(_fhps)) ? _fhps[_q] : _fr.fhp });
			}
			_f = { party : _pp, foes : _pf, b : _pf[0],
			       turn : rp.i + 1, over : (rp.i >= array_length(rp.r.ev) - 1), won : rp.r.won,
			       log : [ _fr.txt ], last : (_fr.dmg > 0) ? { side : _fr.side, i : _fr.i, dmg : _fr.dmg, at : current_time - rp.t * 1000 } : undefined,
			       replay : true };
		}
		var _fx = _sx;
		draw_sprite_ext(spr_pixel_1x1, 0, _fx, _fy, fight_s, fight_s, 0, c_black, .85);
		draw_px_rect(_fx, _fy, fight_s, fight_s, c_hred, .5 + .3 * _br);
		// a floor line
		draw_sprite_ext(spr_pixel_1x1, 0, _fx + 4, _fy + fight_s - 12, fight_s - 8, 1, 0, _ink, .2);
		var _flash_t = (!is_undefined(_f.last)) ? clamp(1 - (current_time - _f.last.at) / 350, 0, 1) : 0;
		// the foes, a row top right (as many as the crew, exped_fight_new):
		// a diamond each, its hp above, the one hit flashes white
		var _fos = _f[$ "foes"] ?? [ _f.b ];
		var _nfo = array_length(_fos);
		var _bx = _fx + fight_s - 16, _by = _fy + 22;
		for (var _j = 0; _j < _nfo; _j++) {
			var _fo = _fos[_j];
			var _jx = _fx + fight_s - 12 - _j * 13, _jy = _fy + 22 - (_j mod 2) * 6;
			var _jhit = (_flash_t > 0 && _f.last.side == "b" && (_f.last.i == _j || (_f.last.i < 0 && _j == 0)));
			var _shk = _jhit ? (irandom(2) - 1) : 0;
			var _jc = _fo[$ "col"] ?? c_hred;
			if (_fo.hp > 0) draw_sprite_ext(spr_pixel_1x1, 0, _jx - 5 + _shk, _jy - 5, 10, 10, 45, _jhit ? c_white : _jc, .95);
			else draw_sprite_ext(spr_pixel_1x1, 0, _jx - 5, _jy + 2, 10, 3, 0, _jc, .4);
			var _jf = clamp(_fo.hp / max(1, _fo.hpmax), 0, 1);
			draw_sprite_ext(spr_pixel_1x1, 0, _jx - 6, _jy - 12, 12, 2, 0, c_black, .8);
			draw_sprite_ext(spr_pixel_1x1, 0, _jx - 6, _jy - 12, 12 * _jf, 2, 0, c_hred, .9);
		}
		// the crew
		for (var _k = 0; _k < array_length(_f.party); _k++) {
			var _m = _f.party[_k];
			var _mx = _fx + 12 + _k * 13, _my = _fy + fight_s - 20 - (_k mod 2) * 6;
			var _mhit = (_flash_t > 0 && _f.last.side == "a" && _f.last.i == _k);
			var _sk = _mhit ? (irandom(2) - 1) : 0;
			if (_m.hp > 0) __dot(_mx + _sk, _my, 5, _mhit ? c_white : _m.col, .95);
			else __dot(_mx, _my + 4, 5, _m.col, .25);
			var _mf = clamp(_m.hp / max(1, _m.hpmax), 0, 1);
			draw_sprite_ext(spr_pixel_1x1, 0, _mx - 6, _my - 10, 12, 2, 0, c_black, .8);
			draw_sprite_ext(spr_pixel_1x1, 0, _mx - 6, _my - 10, 12 * _mf, 2, 0, (_mf > .35) ? c_sgreen : c_horange, .9);
		}
		// the damage number, floating off the one hit
		if (_flash_t > 0) {
			draw_set_halign(fa_center);
			draw_set_color(c_white);
			draw_set_alpha(_flash_t);
			var _dx = (_f.last.side == "b") ? (_fx + fight_s - 12 - max(0, _f.last.i) * 13) : (_fx + 12 + _f.last.i * 13);
			var _dy = ((_f.last.side == "b") ? _by : (_fy + fight_s - 20)) - 16 - (1 - _flash_t) * 8;
			draw_text(_dx, _dy, "-" + string(_f.last.dmg));
			draw_set_halign(fa_left);
		}
		// beside it: the foe, the turn, the last line
		var _tx = _fx + fight_s + 8;
		draw_set_color(c_hred);
		draw_set_alpha(.95);
		// the pack: every foe's name, the down ones dimmed by their bracket
		var _pk = "";
		for (var _j = 0; _j < _nfo; _j++) _pk += ((_j > 0) ? ", " : "") + ((_fos[_j].hp > 0) ? _fos[_j].name : ("[" + _fos[_j].name + "]"));
		draw_text_ext(_tx, _fy + 2, _pk, 9, _sw - fight_s - 8);
		draw_set_color(_dim);
		draw_set_alpha(.7);
		if (_f[$ "replay"] ?? false)
			draw_text(_tx, _fy + 12, "replay  -  room " + string(rp.r.room + 1) + "  -  tap to skip");
		else
			draw_text(_tx, _fy + 14 + ((string_width(_pk) > _sw - fight_s - 8) ? 9 : 0), "action " + string(_f.turn) + "  -  lv " + string(_f.b[$ "lv"] ?? 1) + "  -  " + string(_nfo) + ((_nfo == 1) ? " foe" : " foes"));
		var _fl = array_length(_f.log);
		draw_set_color(c_white);
		draw_set_alpha(.9);
		draw_text_ext(_tx, _fy + 26 + ((string_width(_pk) > _sw - fight_s - 8) ? 9 : 0), (_fl > 0) ? _f.log[_fl - 1] : "...", 9, _sw - fight_s - 8);
		if (!(_f[$ "replay"] ?? false)) {
			var _st = __step_r();
			draw_ui_button(_st.x, _st.y, _st.w, _st.h, _f.over ? "done" : "step turn", c_hred, !_f.over, !_f.over);
		} else if (_f.over) {
			draw_set_color(_f.won ? c_sgreen : c_hred);
			draw_set_alpha(.9);
			draw_text(_tx, _fy + fight_s - 12, _f.won ? "won" : "routed");
		}
	}

	// THE DIARY: truth lines plain, the "~ " lines (exped_say) as the
	// crew's own voice - dimmer, indented, wrapped to the column.
	// Newest at the bottom; as many whole entries as fit above it
	var _ly = _sy + 30;
	var _ly_end = _fighting ? (_fy - 6) : (room_height - 10);
	var _nl = array_length(_tr.log);
	var _hs = array_create(_nl, 0);
	var _room = _ly_end - _ly;
	var _from = _nl;
	for (var _i = _nl - 1; _i >= 0; _i--) {
		var _isv = (string_copy(_tr.log[_i], 1, 2) == "~ ");
		var _h = string_height_ext(_isv ? string_delete(_tr.log[_i], 1, 2) : _tr.log[_i], 9, _sw - (_isv ? 8 : 0)) + 2;
		if (_h > _room) break;
		_room -= _h;
		_hs[_i] = _h;
		_from = _i;
	}
	var _yy = _ly;
	for (var _i = _from; _i < _nl; _i++) {
		var _isv = (string_copy(_tr.log[_i], 1, 2) == "~ ");
		var _last = (_i == _nl - 1);
		if (_isv) {
			draw_set_color(_last ? merge_colour(_ink, c_white, .5) : merge_colour(_ink, _b.col2, .35));
			draw_set_alpha(_last ? .9 : .55);
			draw_text_ext(_sx + 8, _yy, string_delete(_tr.log[_i], 1, 2), 9, _sw - 8);
		} else {
			draw_set_color(_last ? c_white : _ink);
			draw_set_alpha(_last ? .95 : .7);
			draw_text_ext(_sx, _yy, _tr.log[_i], 9, _sw);
		}
		_yy += _hs[_i];
	}
	ui_fade_set(1);
	exit;
}

// ======================= THE HUB =======================
// the destinations
draw_set_color(_ink);
draw_set_alpha(.6);
draw_text(card_x0, card_y - 10, "worlds on offer");
for (var _i = 0; _i < array_length(_e.board); _i++) {
	var _d = _e.board[_i];
	var _b = exped_biomes()[_d.biome];
	var _c = __card_r(_i);
	var _on = (sel_dest == _i);
	var _out = 0;
	for (var _t = 0; _t < array_length(_e.trips); _t++) if (_e.trips[_t].dest.seed == _d.seed) _out++;
	draw_sprite_ext(spr_pixel_1x1, 0, _c.x, _c.y, _c.w, _c.h, 0, c_black, .8);
	draw_px_rect(_c.x, _c.y, _c.w, _c.h, _on ? c_white : merge_colour(_b.col2, c_white, .2), _on ? .9 : .4);
	ui_fade_set(1);
	__portrait(_d, _c.x + _c.w * .5, _c.y + (land ? 22 : 16), land ? 15 : 11);
	ui_fade_set(_ea);
	draw_set_halign(fa_center);
	draw_set_color(c_white);
	draw_set_alpha(.95);
	draw_text(_c.x + _c.w * .5, _c.y + (land ? 42 : 32), _d.name);
	draw_set_color(merge_colour(_b.col2, c_white, .3));
	draw_set_alpha(.85);
	draw_text(_c.x + _c.w * .5, _c.y + (land ? 52 : 42), land ? (_b.name + "  -  tier " + string(_d.tier) + "  lv " + string(exped_world_lv(_d))) : ("t" + string(_d.tier)));
	draw_set_color(_dim);
	draw_set_alpha(.7);
	draw_text(_c.x + _c.w * .5, _c.y + (land ? 62 : 52), land ? (_b.hint + "  -  " + crunch_time_long(_d.dist * 60 / max(1, _e.spd))) : crunch_time_long(_d.dist * 60 / max(1, _e.spd)));
	if (_out > 0) {
		draw_set_color(c_steelblue);
		draw_set_alpha(.9);
		draw_text(_c.x + _c.w * .5, _c.y + _c.h - 9, string(_out) + " out");
	}
}
draw_set_halign(fa_left);

// the crew: tap to pick a party
draw_set_color(_ink);
draw_set_alpha(.6);
var _np = array_length(sel_crew);
draw_text(card_x0, crew_y, (array_length(g.sprites) > 0)
	? ("the crew - tap up to " + string(EXPED_PARTY) + ((_np > 0) ? ("  -  " + string(_np) + " picked") : ""))
	: "no sprites yet - spawn one (the debug sprite) to send it");
for (var _k = 0; _k < array_length(g.sprites); _k++) {
	var _sp = g.sprites[_k];
	var _cr = __chip_r(_k);
	var _away = (_sp[$ "trip"] ?? false);
	var _ok = !_sp.asleep && !_away;
	var _at = array_get_index(sel_crew, _sp.id);
	draw_sprite_ext(spr_pixel_1x1, 0, _cr.x, _cr.y, _cr.w, _cr.h, 0, c_black, .7);
	draw_px_rect(_cr.x, _cr.y, _cr.w, _cr.h, (_at >= 0) ? c_white : _sp.col, (_at >= 0) ? .9 : (_ok ? .5 : .2));
	__dot(_cr.x + _cr.w * .5, _cr.y + _cr.h * .5 - 1, land ? 6 : 4, _sp.col, _ok ? .95 : .3);
	if (_at >= 0) {
		draw_set_halign(fa_center);
		draw_set_color(c_black);
		draw_set_alpha(.9);
		draw_text(_cr.x + _cr.w * .5 + 1, _cr.y + _cr.h * .5 - 4, string(_at + 1));
	}
	draw_set_halign(fa_center);
	draw_set_color(_ok ? _ink : _dim);
	draw_set_alpha(_ok ? .8 : .5);
	draw_text(_cr.x + _cr.w * .5, _cr.y + _cr.h + 1, _away ? "out" : (_sp.asleep ? "zz" : string_copy(_sp.name, 1, land ? 5 : 3)));
}
draw_set_halign(fa_left);
var _sr = __send_r();
var _can = (sel_dest >= 0 && _np > 0);
draw_ui_button(_sr.x, _sr.y, _sr.w, _sr.h,
	_can ? ("send " + string(_np) + " to " + _e.board[sel_dest].name) : ((sel_dest < 0) ? "pick a world" : "pick a crew"),
	_can ? c_sgreen : c_gray, true, _can);
// [sheet]: the picked sprite's (or the first one's) class / level / gear
if (array_length(g.sprites) > 0) {
	var _shr = __sheet_r();
	draw_ui_button(_shr.x, _shr.y, _shr.w, _shr.h, "crew", c_steelblue, true, false);
}

// THE LIST: hauls waiting, then trips out
draw_set_color(_ink);
draw_set_alpha(.6);
var _ly0 = __list_y0();
draw_text(list_x, _ly0 + 2, "expeditions");
var _rows = array_length(_e.hauls) + array_length(_e.trips);
if (_rows == 0) {
	draw_set_color(_dim);
	draw_set_alpha(.5);
	draw_text_ext(list_x, _ly0 + 14, "none out. pick a world and a crew, and send them.", 9, list_w);
}
for (var _i = 0; _i < _rows; _i++) {
	var _rr = __row_r(_i);
	if (_rr.y + _rr.h > room_height - 4) break;
	var _ish = (_i < array_length(_e.hauls));
	var _r  = _ish ? _e.hauls[_i] : _e.trips[_i - array_length(_e.hauls)];
	var _rb = exped_biomes()[_r.dest.biome];
	draw_sprite_ext(spr_pixel_1x1, 0, _rr.x, _rr.y, _rr.w, _rr.h, 0, c_hsv(169, 160, 7), .96);
	draw_sprite_ext(spr_pixel_1x1, 0, _rr.x, _rr.y, _rr.w, 1, 0, c_white, .07);
	draw_sprite_ext(spr_pixel_1x1, 0, _rr.x, _rr.y, 2, _rr.h, 0, _ish ? c_gold : c_steelblue, .85);
	ui_fade_set(1);
	__portrait(_r.dest, _rr.x + 16, _rr.y + _rr.h * .5, 9);
	ui_fade_set(_ea);
	// the crew's faces
	for (var _k = 0; _k < array_length(_r.sids); _k++) __dot(_rr.x + 34 + _k * 9, _rr.y + 9, 3, _r.cols[_k],
		(_ish || _r.hp[_k] > 0) ? .95 : .3);
	draw_set_color(c_white);
	draw_set_alpha(.95);
	draw_text(_rr.x + 34 + array_length(_r.sids) * 9 + 3, _rr.y + 5, _r.dest.name);
	if (_ish) {
		draw_set_color(_r.routed ? c_horange : c_gold);
		draw_set_alpha(.9);
		draw_text(_rr.x + 34, _rr.y + 18, _r.routed ? "limped home  -  collect" : "back  -  collect the haul");
	} else {
		// the progress track with the room pips, and the state
		var _tw = _rr.w - 40;
		var _tf = clamp(_r.t / max(1, _r.dur), 0, 1);
		draw_sprite_ext(spr_pixel_1x1, 0, _rr.x + 34, _rr.y + 21, _tw, 4, 0, c_black, .7);
		draw_sprite_ext(spr_pixel_1x1, 0, _rr.x + 34, _rr.y + 21, _tw * _tf, 4, 0, c_steelblue, .9);
		var _q1 = _rr.x + 34 + _tw * EXPED_TRAVEL, _q2 = _rr.x + 34 + _tw * (1 - EXPED_RETURN);
		for (var _p = 0; _p < EXPED_ROOMS; _p++) {
			var _px = _q1 + (_q2 - _q1) * (_p + 1) / EXPED_ROOMS;
			var _done = (_p <= _r.room_i);
			var _kc = c_white;
			switch (_r.rooms[_p]) { case "find": _kc = c_gold; break; case "rest": _kc = c_sgreen; break; case "trap": _kc = c_horange; break; case "fight": _kc = c_hred; break; }
			draw_sprite_ext(spr_pixel_1x1, 0, _px - 1, _rr.y + 21, 3, 4, 0, _done ? _kc : c_black, _done ? .95 : .6);
		}
		draw_set_halign(fa_right);
		draw_set_color(!is_undefined(_r.fight) ? c_hred : _dim);
		draw_set_alpha(.8);
		var _left = max(0, _r.dur - _r.t) / max(1, _e.spd);
		draw_text(_rr.x + _rr.w - 6, _rr.y + 5, !is_undefined(_r.fight) ? "fighting" : (_r.routed ? "routed - returning" : ((_r.stage == 0) ? "travelling" : ((_r.stage == 1) ? ("room " + string(max(0, _r.room_i + 1))) : "returning")) + "  " + crunch_time_long(_left * 60)));
		draw_set_halign(fa_left);
	}
}
ui_fade_set(1);
draw_set_alpha(1);   // (the last row's .8 must not leak into the next draw - bug hunt, 2026-09-14)
