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
	draw_text(_bk.x + _bk.w * .5, _bk.y + 3, "back  >");
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
	// the card on the left, the trip's log on the right (his ask, 2026-09-15:
	// "i want to see the log on that screen so i can read what they did")
	var _nb = array_length(_h.sids);   // the banners' rows
	var _cw = land ? 224 : (room_width - 8), _ch = 40 + _nb * 12 + 4 + array_length(_h.finds) * 12 + (_recruit ? 52 : 40);
	var _cx = land ? 14 : 4, _cy = list_y + 22;
	ui_fade_set(_ea);
	draw_sprite_ext(spr_pixel_1x1, 0, _cx, _cy, _cw, _ch, 0, c_black, .9);
	draw_px_rect(_cx, _cy, _cw, _ch, _h.routed ? c_hred : c_gold, .6);
	draw_sprite_ext(spr_pixel_1x1, 0, _cx, _cy, _cw, 1, 0, _h.routed ? c_hred : c_gold, .9);
	ui_fade_set(1);
	__world_small(_h.dest, _cx + 22, _cy + 22, 12);
	ui_fade_set(_ea);
	draw_set_halign(fa_left);
	draw_set_color(c_white);
	draw_set_alpha(.95);
	draw_text_ext(_cx + 42, _cy + 6, exped_crew_txt(_h.names) + ((array_length(_h.names) > 1) ? " are" : " is") + " back from " + _h.dest.name, 9, _cw - 48);
	draw_set_color(_h.routed ? c_hred : c_sgreen);
	draw_set_alpha(.85);
	draw_text(_cx + 42, _cy + 24, (_h.routed ? "routed - " : "") + string(_h[$ "wins"] ?? 0) + " fights won, " + string(_h.cleared) + " things done");
	draw_sprite_ext(spr_pixel_1x1, 0, _cx + 8, _cy + 34, _cw - 16, 1, 0, _ink, .25);
	// THE CREW'S BANNERS (his ask, 2026-09-15): the crew as they came home
	var _hhp = _h[$ "hp"] ?? [], _hhm = _h[$ "hpmax"] ?? [];
	for (var _k = 0; _k < _nb; _k++) {
		var _by = _cy + 38 + _k * 12;
		var _hpk = (_k < array_length(_hhp)) ? _hhp[_k] : 1, _hmk = max(1, (_k < array_length(_hhm)) ? _hhm[_k] : 1);
		var _up = (_hpk > 0);
		draw_sprite_ext(spr_pixel_1x1, 0, _cx + 8, _by, _cw - 16, 11, 0, c_black, .5);
		draw_sprite_ext(spr_pixel_1x1, 0, _cx + 8, _by, 2, 11, 0, _h.cols[_k], _up ? .9 : .3);
		__dot(_cx + 18, _by + 5, 3, _h.cols[_k], _up ? .95 : .3);
		var _rsp = __sp_by_id(_h.sids[_k]);
		draw_set_halign(fa_left); draw_set_color(_up ? _ink : _dim); draw_set_alpha(.85);
		draw_text(_cx + 25, _by + 1, _h.names[_k] + (is_undefined(_rsp) ? "" : ("  lv " + string(sprite_sheet(_rsp).lv))) + (_up ? "" : "  -  down"));
		var _bw = 50, _hf = clamp(_hpk / _hmk, 0, 1);
		draw_sprite_ext(spr_pixel_1x1, 0, _cx + _cw - 14 - _bw, _by + 3, _bw, 5, 0, c_black, .7);
		draw_sprite_ext(spr_pixel_1x1, 0, _cx + _cw - 14 - _bw, _by + 3, _bw * _hf, 5, 0, (_hf > .35) ? c_sgreen : c_hred, .9);
		draw_px_rect(_cx + _cw - 14 - _bw, _by + 3, _bw, 5, c_white, .12);
	}
	for (var _i = 0; _i < array_length(_h.finds); _i++) {
		var _l = _h.finds[_i];
		var _ry = _cy + 40 + _nb * 12 + 4 + _i * 12;
		draw_set_halign(fa_left);
		draw_set_color(_ink);
		draw_set_alpha(.55);
		draw_text(_cx + 10, _ry, (_i == 0) ? "the floor" : ("find " + string(_i)));
		draw_set_halign(fa_right);
		draw_set_color(_l.col);
		draw_set_alpha(.95);
		draw_text(_cx + _cw - 10, _ry, (_l.kind == "sprite" && _recruit) ? "a sprite - wants to join" : _l.txt);
	}
	// the log: newest at the bottom, as much as fits
	if (land) {
		var _lx = _cx + _cw + 12, _lw = room_width - _lx - 14;
		draw_set_halign(fa_left);
		draw_set_color(_ink); draw_set_alpha(.5);
		draw_text(_lx, _cy, "the diary");
		__draw_log(_h.log, _lx, _cy + 12, _lw, room_height - 10, exped_biomes()[_h.dest.biome].col2);
	}
	draw_set_halign(fa_left);
	if (_recruit) {
		draw_set_halign(fa_center);
		draw_set_color(c_gold);
		draw_set_alpha(.9);
		draw_text(_cx + _cw * .5, _cy + _ch - 34, "the roster is full (" + string(SPRITE_CAP) + ")");
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

// ======================= THE MAP (his ask, 2026-09-14: "the region debug map") =======================
// the world's region: edges with their hours, nodes by kind with names,
// the landing zone ringed, crews out to the world at the landing zone
// (they do not walk the graph yet - the agent is slice three), a legend
if (view == "map") {
	var _d  = map_dest;
	var _rg = region_get(_d, map_rgi);
	var _kk = region_kinds();
	var _mr = __map_r();
	var _bb = exped_biomes()[_d.biome];
	// the header (short: the back button sits on the right)
	draw_set_color(c_white); draw_set_alpha(.95);
	draw_text(_mr.x, list_y + 6, _d.name + "  -  " + _rg.name);
	draw_set_color(_dim); draw_set_alpha(.7);
	draw_text(_mr.x + string_width(_d.name + "  -  " + _rg.name) + 10, list_y + 6, "lv " + string(_rg.lv) + "  -  " + string(array_length(_rg.nodes)) + " places");
	// the ground
	draw_sprite_ext(spr_pixel_1x1, 0, _mr.x, _mr.y, _mr.w, _mr.h, 0, c_black, .6);
	draw_px_rect(_mr.x, _mr.y, _mr.w, _mr.h, _ink, .15);
	var _px = function(_v, _mr) { return _mr.x + 8 + _v * (_mr.w - 16); };
	var _py = function(_v, _mr) { return _mr.y + 8 + _v * (_mr.h - 16); };
	// the roads, with their hours at the midpoint
	for (var _ei = 0; _ei < array_length(_rg.edges); _ei++) {   // (_e is g.exped up top - the shadow crashed the map, 2026-09-14)
		var _ed = _rg.edges[_ei];
		var _a = _rg.nodes[_ed.a], _b2 = _rg.nodes[_ed.b];
		var _x1 = _px(_a.x, _mr), _y1 = _py(_a.y, _mr), _x2 = _px(_b2.x, _mr), _y2 = _py(_b2.y, _mr);
		draw_px_line(_x1, _y1, _x2, _y2, _ink, .25);   // (the house line: a primitive would lose the shader's texcoord)
		draw_set_alpha(.35); draw_set_color(_dim);
		draw_set_halign(fa_center);
		draw_text((_x1 + _x2) * .5, (_y1 + _y2) * .5 - 4, string(_ed.d) + "h");
	}
	// the places
	draw_set_halign(fa_left);
	for (var _i = 0; _i < array_length(_rg.nodes); _i++) {
		var _nd = _rg.nodes[_i];
		var _kd = _kk[$ _nd.kind] ?? _kk.field;
		var _nx = _px(_nd.x, _mr), _ny = _py(_nd.y, _mr);
		if (_nd.kind == "landing") {
			draw_circle_colour(_nx, _ny, 5, c_white, c_white, true);
			__dot(_nx, _ny, 2, c_white, .9);
		} else __dot(_nx, _ny, _kd.r, _kd.col, .95);
		// every place by its name (his ask, 2026-09-15: the wild's full names);
		// the places that matter carry their kind under it, the wild is dim
		if (_kd.wild) { draw_set_color(merge_colour(_kd.col, _dim, .4)); draw_set_alpha(.6); draw_text(_nx + _kd.r + 3, _ny - 4, _nd.name); }
		else {
			draw_set_color(_kd.col); draw_set_alpha(.9);
			draw_text(_nx + _kd.r + 3, _ny - 4, _nd.name);
			draw_set_color(_dim); draw_set_alpha(.4);
			draw_text(_nx + _kd.r + 3, _ny + 5, _kd.name);
		}
	}
	// who is out to this world: at their node, or along their road; the
	// path they mean to walk drawn in their colour
	for (var _t = 0; _t < array_length(_e.trips); _t++) {
		var _tr2 = _e.trips[_t];
		if (_tr2.dest.seed != _d.seed) continue;
		var _tc = _tr2.cols[0];
		var _cpos = clamp(_tr2[$ "pos"] ?? _rg.landing, 0, array_length(_rg.nodes) - 1);
		var _cx = _px(_rg.nodes[_cpos].x, _mr), _cy = _py(_rg.nodes[_cpos].y, _mr);
		if (is_struct(_tr2[$ "road"])) {
			var _ra = _rg.nodes[_tr2.road.a], _rb = _rg.nodes[_tr2.road.b];
			var _q = clamp(_tr2.road.t / max(1, _tr2.road.d * EXPED_HOUR), 0, 1);
			_cx = lerp(_px(_ra.x, _mr), _px(_rb.x, _mr), _q);
			_cy = lerp(_py(_ra.y, _mr), _py(_rb.y, _mr), _q);
		}
		// the path ahead
		var _pp = _tr2[$ "path"] ?? [];
		var _lx0 = _cx, _ly0 = _cy;
		for (var _k = 0; _k < array_length(_pp); _k++) {
			var _pn = _rg.nodes[clamp(_pp[_k], 0, array_length(_rg.nodes) - 1)];
			var _lx1 = _px(_pn.x, _mr), _ly1 = _py(_pn.y, _mr);
			draw_px_line(_lx0, _ly0, _lx1, _ly1, _tc, .5);
			_lx0 = _lx1; _ly0 = _ly1;
		}
		if (_tr2.stage != 1) { _cx = _px(_rg.nodes[_rg.landing].x, _mr) - 12; _cy = _py(_rg.nodes[_rg.landing].y, _mr); }
		for (var _k = 0; _k < array_length(_tr2.sids); _k++) __dot(_cx - 6 + _k * 6, _cy + 8, 3, _tr2.cols[_k], (_tr2.hp[_k] > 0) ? .95 : .3);
		draw_set_color(_tc); draw_set_alpha(.85);
		draw_text(_cx - 6, _cy + 12, exped_crew_txt(_tr2.names) + ": " + ((_tr2.stage == 1) ? exped_where(_tr2) : ((_tr2.stage == 0) ? "on the way" : "gone home")));
	}
	// the legend
	var _lgx = _mr.x, _lgy = _mr.y + _mr.h + 3;
	var _legend = ["settlement", "village", "town", "city", "camp", "dungeon", "field", "forest", "hills", "marsh"];
	for (var _i = 0; _i < array_length(_legend); _i++) {
		var _kd = _kk[$ _legend[_i]];
		__dot(_lgx + 3, _lgy + 4, 2, _kd.col, .9);
		draw_set_color(_dim); draw_set_alpha(.7);
		draw_text(_lgx + 8, _lgy, _kd.name);
		_lgx += string_width(_kd.name) + 16;
		if (_lgx > room_width - 60) break;
	}
	draw_set_color(_dim); draw_set_alpha(.35);
	draw_set_halign(fa_right);
	draw_text(room_width - (land ? 14 : 4), _mr.y + _mr.h + 3, "debug - the player never sees this");
	draw_set_halign(fa_left);
	ui_fade_set(1);
	exit;
}

// ======================= THE CREW MENU (his ask, 2026-09-14: tabs left, the sheet right) =======================
if (view == "crew" || view == "sheet") {
	var _cl = __crew_list();
	if (is_undefined(__sp_by_id(sheet_id)) && array_length(_cl) > 0) sheet_id = _cl[0].id;
	it_rects = [];
	// the tabs (a trip's crew only, when it came from a trip's page)
	draw_set_color(_ink); draw_set_alpha(.6);
	draw_text(land ? 14 : 4, list_y + 6, (crew_trip >= 0) ? "the crew on this trip" : ("the crew  -  " + string(array_length(g.sprites)) + " of " + string(SPRITE_CAP)));
	for (var _k = 0; _k < array_length(_cl); _k++) {
		var _sp = _cl[_k];
		var _tb = __tab_r(_k);
		if (_tb.y + _tb.h > room_height - 4) break;
		var _on = (_sp.id == sheet_id);
		var _away = (_sp[$ "trip"] ?? false);
		draw_sprite_ext(spr_pixel_1x1, 0, _tb.x, _tb.y, _tb.w, _tb.h, 0, _on ? merge_colour(_sp.col, c_black, .75) : c_black, _on ? .95 : .6);
		draw_px_rect(_tb.x, _tb.y, _tb.w, _tb.h, _sp.col, _on ? .9 : .3);
		if (_on) draw_sprite_ext(spr_pixel_1x1, 0, _tb.x + _tb.w, _tb.y, 10, _tb.h, 0, merge_colour(_sp.col, c_black, .75), .95);   // the tab bleeds into the sheet
		__dot(_tb.x + 7, _tb.y + 7, 3, _sp.col, _away ? .4 : .95);
		draw_set_color(_on ? c_white : _ink); draw_set_alpha(_on ? .95 : .75);
		draw_text(_tb.x + 14, _tb.y + 3, string_copy(_sp.name, 1, land ? 8 : 6));
		draw_set_halign(fa_right);
		draw_set_color(_dim); draw_set_alpha(.7);
		draw_text(_tb.x + _tb.w - 3, _tb.y + 3, "lv" + string(sprite_sheet(_sp).lv));
		draw_set_halign(fa_left);
	}
	// the sheet
	var _sp = __sp_by_id(sheet_id);
	if (is_undefined(_sp)) { draw_set_color(_dim); draw_set_alpha(.5); draw_text(__sheet_x0(), list_y + 24, "no sprites yet"); ui_fade_set(1); exit; }
	var _sh = sprite_sheet(_sp);
	var _st = sprite_stats(_sp);
	var _c  = _st.cls;
	var _bal = cbt_balance();
	var _x0 = __sheet_x0(), _y0 = list_y + 22, _x1 = room_width - (land ? 14 : 4);
	var _w = _x1 - _x0;
	draw_sprite_ext(spr_pixel_1x1, 0, _x0, _y0, _w, room_height - 8 - _y0, 0, merge_colour(_sp.col, c_black, .9), .6);
	draw_px_rect(_x0, _y0, _w, room_height - 8 - _y0, _sp.col, .35);
	// the header: name, class, level - and the xp bar
	var _hx = _x0 + 8, _hy = _y0 + 6;
	__dot(_hx + 5, _hy + 5, 5, _sp.col, .95);
	draw_set_font(fnt_large);
	draw_set_color(_sp.col); draw_set_alpha(.95);
	draw_text(_hx + 16, _hy - 2, _sp.name);
	var _nx = _hx + 16 + string_width(_sp.name) + 10;
	draw_set_font(fnt);
	draw_set_color(_c.col); draw_set_alpha(.95);
	draw_text(_nx, _hy, _c.name);
	draw_set_color(_ink); draw_set_alpha(.85);
	draw_text(_nx + string_width(_c.name) + 8, _hy, "level " + string(_sh.lv));
	var _pl = sprite_personalities();
	draw_set_color(_dim); draw_set_alpha(.7);
	draw_text(_nx + string_width(_c.name) + 8, _hy + 10, _pl[clamp(_sp.pers, 0, array_length(_pl) - 1)].name + "  -  " + ((_sp[$ "trip"] ?? false) ? "out" : (_sp.asleep ? "asleep" : "home")));
	var _need = sprite_xp_need(_sh.lv);
	var _xw = land ? 110 : 80, _xx = _x1 - 8 - _xw;
	draw_set_halign(fa_right); draw_set_color(_dim); draw_set_alpha(.7);
	draw_text(_x1 - 8, _hy - 1, "next  " + string(round(_sh.xp)) + " / " + string(_need));
	draw_set_halign(fa_left);
	draw_sprite_ext(spr_pixel_1x1, 0, _xx, _hy + 10, _xw, 3, 0, c_black, .7);
	draw_sprite_ext(spr_pixel_1x1, 0, _xx, _hy + 10, _xw * clamp(_sh.xp / max(1, _need), 0, 1), 3, 0, c_gold, .9);
	// HP / MP bars (the Disgaea row): the maxima - a sprite at home is whole
	var _hpr = round((_st.pts.hp * _bal.hp_per_point + _bal.hp_flat_add) * 10) / 10;
	var _mpr = max(1, round(_st.pts.mp));
	// the current hp: a sprite out on a trip carries it there; at home it is whole
	var _hpc = _hpr;
	for (var _t = 0; _t < array_length(_e.trips); _t++) {
		var _tt = _e.trips[_t];
		for (var _k = 0; _k < array_length(_tt.sids); _k++) if (_tt.sids[_k] == _sp.id) _hpc = min(_hpr, _tt.hp[_k]);
	}
	var _by = _hy + 24, _bw = land ? 150 : (_w - 16);
	draw_set_color(c_hred); draw_set_alpha(.9); draw_text(_hx, _by, "hp");
	draw_sprite_ext(spr_pixel_1x1, 0, _hx + 18, _by + 2, _bw, 5, 0, c_black, .7);
	draw_sprite_ext(spr_pixel_1x1, 0, _hx + 18, _by + 2, _bw * clamp(_hpc / max(1, _hpr), 0, 1), 5, 0, c_hred, .8);
	draw_set_halign(fa_right); draw_set_color(c_white); draw_set_alpha(.9); draw_text(_hx + 18 + _bw - 2, _by - 1, string(_hpc) + " / " + string(_hpr)); draw_set_halign(fa_left);
	draw_set_color(c_sblue); draw_set_alpha(.9); draw_text(_hx, _by + 10, "mp");
	draw_sprite_ext(spr_pixel_1x1, 0, _hx + 18, _by + 12, _bw, 5, 0, c_black, .7);
	draw_sprite_ext(spr_pixel_1x1, 0, _hx + 18, _by + 12, _bw, 5, 0, c_sblue, .8);
	draw_set_halign(fa_right); draw_set_color(c_white); draw_set_alpha(.9); draw_text(_hx + 18 + _bw - 2, _by + 9, string(_mpr) + " / " + string(_mpr)); draw_set_halign(fa_left);
	// the stats grid (two columns of three), base + the gear's share
	var _keys = ["atk", "def", "mag", "mdef", "spd", "hit"];
	var _labels = ["atk", "def", "int", "res", "spd", "hit"];
	var _gy = _by + 26;
	for (var _k = 0; _k < 6; _k++) {
		var _cx = _hx + (_k mod 2) * (land ? 92 : 80), _cy = _gy + (_k div 2) * 11;
		draw_set_color(_dim); draw_set_alpha(.8);
		draw_text(_cx, _cy, _labels[_k]);
		draw_set_halign(fa_right);
		draw_set_color(_ink); draw_set_alpha(.95);
		draw_text(_cx + 58, _cy, string_format(_st.pts[$ _keys[_k]], 1, 1));
		draw_set_halign(fa_left);
		var _g = _st.gear[$ _keys[_k]];
		if (_g > 0) { draw_set_color(c_sgreen); draw_set_alpha(.8); draw_text(_cx + 62, _cy, "+" + string_format(_g, 1, 1)); }
	}
	draw_set_color(_dim); draw_set_alpha(.7);
	draw_text(_hx, _gy + 34, "crit " + string(_c.crit) + "%  x" + string(_c.cmulti) + "     counter " + string(_c.cnt) + "%" + (_c.magic ? "     casts" : "") + "     " + string(round(_st.total)) + " pts");
	// the equipment (the Disgaea list): slot - item
	var _ex = land ? (_x0 + 208) : _hx, _ey = land ? (_by) : (_gy + 48);
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
		draw_set_color(_dim); draw_set_alpha(.8);
		draw_text(_ex + 3, _ry + 1, _rw.lbl);
		if (is_undefined(_rw.it)) { draw_set_color(_dim); draw_set_alpha(.4); draw_text(_ex + 52, _ry + 1, "(none)"); }
		else {
			draw_set_color(_rw.it.col); draw_set_alpha(.95);
			draw_text(_ex + 52, _ry + 1, _rw.it.name);
			draw_set_halign(fa_right); draw_set_color(_dim); draw_set_alpha(.6);
			draw_text(_x1 - 11, _ry + 1, "lv" + string(_rw.it.lv));
			draw_set_halign(fa_left);
		}
	}
	// the skills, under the stats; the pocket and the notepad under the equipment
	var _sk = sprite_skills(_sp);
	var _ky = _gy + 48;
	draw_set_color(_ink); draw_set_alpha(.5);
	draw_text(_hx, _ky, "skills");
	for (var _i = 0; _i < array_length(_sk); _i++) {
		var _s = _sk[_i];
		var _ly = _ky + 11 + _i * 10;
		draw_set_color(_s.magic ? c_hpurple : c_horange); draw_set_alpha(.9);
		draw_text(_hx, _ly, _s.name);
		draw_set_color(_dim); draw_set_alpha(.7);
		draw_text(_hx + 84, _ly, string(_s.cost) + "mp " + ((_s[$ "mult"] ?? 0) > 0 ? ("x" + string_format(_s.mult, 1, 1)) : "") + ((_s[$ "healp"] ?? 0) > 0 ? ("heals " + string(round(_s.healp * 100)) + "%") : ""));
	}
	if (_sh.lv < 20) { draw_set_color(_dim); draw_set_alpha(.4); draw_text(_hx, _ky + 11 + array_length(_sk) * 10, "next skill at level " + string((_sh.lv < 10) ? 10 : 20)); }
	var _py = _ey + array_length(_rows) * 12 + 4;
	draw_set_color(_ink); draw_set_alpha(.5);
	draw_text(_ex, _py, "pocket  " + string(array_length(_sh.inv)) + " / " + string(SPRITE_INV));
	var _pn = min(array_length(_sh.inv), 4);
	for (var _i = 0; _i < _pn; _i++) {
		draw_set_color(_sh.inv[_i].col); draw_set_alpha(.6); draw_text(_ex + 4, _py + 10 + _i * 9, _sh.inv[_i].name);
		array_push(it_rects, { x : _ex, y : _py + 9 + _i * 9, w : _x1 - 8 - _ex, h : 9, it : _sh.inv[_i], worn : false });
	}
	if (array_length(_sh.inv) > _pn) { draw_set_color(_dim); draw_set_alpha(.4); draw_text(_ex + 4, _py + 10 + _pn * 9, "...and " + string(array_length(_sh.inv) - _pn) + " more"); }
	var _ny = _py + 10 + (min(array_length(_sh.inv), 4) + ((array_length(_sh.inv) > 4) ? 1 : 0)) * 9 + 4;
	draw_set_color(_ink); draw_set_alpha(.5);
	draw_text(_ex, _ny, "notepad  " + string(array_length(_sh.notes)) + " / " + string(SPRITE_NOTES));
	var _nmax = max(0, floor((room_height - 10 - (_ny + 10)) / 9));
	var _n0 = max(0, array_length(_sh.notes) - _nmax);
	for (var _i = _n0; _i < array_length(_sh.notes); _i++) {
		var _nt = _sh.notes[_i];
		draw_set_color((_nt.tag != "") ? c_horange : _dim); draw_set_alpha((_nt.tag != "") ? .8 : .6);
		draw_text(_ex + 4, _ny + 10 + (_i - _n0) * 9, "- " + _nt.txt);
	}
	if (array_length(_sh.notes) == 0) { draw_set_color(_dim); draw_set_alpha(.35); draw_text(_ex + 4, _ny + 10, "- (blank)"); }
	// THE ITEM POPUP (his ask, 2026-09-15): the item's lines, what it is worth
	// to this sprite (gear_score, the class's eye), and against what is
	// worn in its slot - the difference per line
	if (is_struct(it_pop) && !is_undefined(it_pop.sp)) {
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
	// demo's raycast sphere with the mountains, its ring if it has one)
	// over its own stars, through the box's surface (__draw_world_rect:
	// nothing spills past the box); the lite portrait holds the spot
	// while the world is still being built
	draw_sprite_ext(spr_pixel_1x1, 0, big_x, big_y, big_w, big_h, 0, c_black, .95);
	__draw_world_rect(_d, big_x + 1, big_y + 1, big_w - 2, land ? 102 : 62, (big_w - 2) * .5, land ? 47 : 29, land ? 34 : 20, 1, undefined, 1, false);
	draw_px_rect(big_x, big_y, big_w, big_h, merge_colour(_b.col2, c_white, .2), .5);
	ui_fade_set(_ea);
	// the buttons, under the box: [crew] [map] [abort]
	var _tcr = __trip_crew_r();
	draw_ui_button(_tcr.x, _tcr.y, _tcr.w, _tcr.h, "crew", c_steelblue, true, false);
	var _tmr = __trip_map_r();
	draw_ui_button(_tmr.x, _tmr.y, _tmr.w, _tmr.h, "map", c_steelblue, true, false);
	var _abr = __trip_abort_r();
	var _can_abort = !(_tr[$ "aborted"] ?? false) && _tr.stage != 2;
	draw_ui_button(_abr.x, _abr.y, _abr.w, _abr.h, (_tr[$ "aborted"] ?? false) ? "aborted" : "abort", c_hred, _can_abort, false);
	draw_set_halign(fa_center);
	draw_set_color(c_white);
	draw_set_alpha(.95);
	draw_text(big_x + big_w * .5, big_y + (land ? 88 : 54), _d.name);
	draw_set_color(merge_colour(_b.col2, c_white, .3));
	draw_set_alpha(.8);
	draw_text(big_x + big_w * .5, big_y + (land ? 98 : 64), exped_region(_tr).name + "  -  lv " + string(exped_trip_lv(_tr)));
	draw_set_halign(fa_left);
	// THE CREW'S BANNERS, under the buttons (his ask, 2026-09-15): a row
	// each - dot, name, level, the hp bar - LIVE in a fight (the pawn's hp
	// by its trip index, or the replay frame's), the trip's hp between
	var _lf = _tr.fight;
	for (var _k = 0; _k < _n; _k++) {
		var _cr = __crew_row_r(_k);
		var _hpk = _tr.hp[_k], _hmk = max(1, _tr.hpmax[_k]);
		if (!is_undefined(_lf)) { for (var _pi = 0; _pi < array_length(_lf.party); _pi++) if ((_lf.party[_pi][$ "mi"] ?? -1) == _k) _hpk = _lf.party[_pi].hp; }
		else if (!is_undefined(rp)) { var _rfr = rp.r.ev[rp.i]; for (var _pi = 0; _pi < array_length(rp.r.party); _pi++) if ((rp.r.party[_pi][$ "mi"] ?? _pi) == _k && _pi < array_length(_rfr.php)) _hpk = _rfr.php[_pi]; }
		var _up = (_hpk > 0);
		draw_sprite_ext(spr_pixel_1x1, 0, _cr.x, _cr.y, _cr.w, _cr.h, 0, c_black, .6);
		draw_sprite_ext(spr_pixel_1x1, 0, _cr.x, _cr.y, 2, _cr.h, 0, _tr.cols[_k], _up ? .9 : .3);
		__dot(_cr.x + 10, _cr.y + 5, 3, _tr.cols[_k], _up ? .95 : .3);
		draw_set_color(_up ? _ink : _dim); draw_set_alpha(.85);
		var _rsp = __sp_by_id(_tr.sids[_k]);
		draw_text(_cr.x + 17, _cr.y + 1, _tr.names[_k] + (is_undefined(_rsp) ? "" : ("  lv " + string(sprite_sheet(_rsp).lv))));   // (tap the row: the sheet)
		var _bw = 50;
		var _hf = clamp(_hpk / _hmk, 0, 1);
		draw_sprite_ext(spr_pixel_1x1, 0, _cr.x + _cr.w - 6 - _bw, _cr.y + 3, _bw, 5, 0, c_black, .7);
		draw_sprite_ext(spr_pixel_1x1, 0, _cr.x + _cr.w - 6 - _bw, _cr.y + 3, _bw * _hf, 5, 0, (_hf > .35) ? c_sgreen : c_hred, .9);
		draw_px_rect(_cr.x + _cr.w - 6 - _bw, _cr.y + 3, _bw, 5, c_white, .12);
	}

	// the track: the flight there | the world | the flight home - the fill
	// is the current leg (a road's hours while walking), and under it
	// WHERE they are and the quest (exped_where)
	var _sx = log_x, _sy = log_y, _sw = log_w;
	var _travel = _tr.dur * EXPED_TRAVEL;
	var _tf = 0, _leg = "";
	if (_tr.stage == 0) { _tf = clamp(_tr.t / max(1, _travel), 0, 1); _leg = "the flight"; }
	else if (_tr.stage == 2) { _tf = clamp((_tr.t - (_tr[$ "leave_t"] ?? _tr.t)) / max(1, _tr.dur * EXPED_RETURN), 0, 1); _leg = "the flight home"; }
	else if (is_struct(_tr[$ "road"])) { _tf = clamp(_tr.road.t / max(1, _tr.road.d * EXPED_HOUR), 0, 1); _leg = "the road"; }
	else if (is_struct(_tr[$ "act"])) { _tf = 1 - clamp(_tr.act.left / max(1, EXPED_ROOM_T), 0, 1); _leg = "at " + exped_region(_tr).nodes[clamp(_tr.pos, 0, array_length(exped_region(_tr).nodes) - 1)].name; }
	else { _tf = 0; _leg = "deciding"; }
	draw_sprite_ext(spr_pixel_1x1, 0, _sx, _sy + 8, _sw, 6, 0, c_black, .7);
	draw_sprite_ext(spr_pixel_1x1, 0, _sx, _sy + 8, _sw * _tf, 6, 0, (_tr.stage == 1) ? c_sgreen : c_steelblue, .9);
	draw_px_rect(_sx, _sy + 8, _sw, 6, c_steelblue, .35);
	draw_set_color(_dim);
	draw_set_alpha(.7);
	draw_text(_sx, _sy + 18, _leg);
	draw_set_halign(fa_right);
	draw_set_color(c_white);
	draw_set_alpha(.85);
	var _mode = _tr[$ "mode"] ?? "quest";
	if (_mode == "explore" && !(_tr[$ "recall"] ?? false) && _tr.stage == 1) {
		var _rr2 = __recall_r();
		draw_ui_button(_rr2.x, _rr2.y, _rr2.w, _rr2.h, "recall", c_horange, true, true);
	} else draw_text(_sx + _sw, _sy + 18, exped_where(_tr) + ((_e.spd > 1) ? ("  at x" + string(_e.spd)) : ""));
	draw_set_halign(fa_left);
	// the quest line, or the explore's clock
	var _q = _tr[$ "quest"];
	draw_set_color(c_gold); draw_set_alpha(.9);
	if (is_struct(_q)) draw_text_ext(_sx, _sy + 28, _q.txt + "  -  " + string(_q.done) + " / " + string(_q.n) + ((_q.done >= _q.n) ? "  done" : ""), 9, _sw);
	else draw_text(_sx, _sy + 28, "exploring  -  " + string_format((_tr[$ "planet_t"] ?? 0) / EXPED_HOUR, 1, 1) + "h on the world  -  " + string(_tr[$ "credits"] ?? 0) + " credits in the pocket" + ((_tr[$ "recall"] ?? false) ? "  -  recalled" : ""));
	if (is_struct(_q)) { draw_set_color(_dim); draw_set_alpha(.6); draw_text(_sx, _sy + 38, string(_tr[$ "credits"] ?? 0) + " credits in the pocket"); }

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
			for (var _pi = 0; _pi < array_length(rp.r.party); _pi++) {
				var _pm = rp.r.party[_pi];
				array_push(_pp, { name : _pm.name, col : _pm.col, hpmax : _pm.hpmax,
				                  hp : (_pi < array_length(_fr.php)) ? _fr.php[_pi] : _pm.hp });
			}
			var _pf = [];
			var _rfs = rp.r[$ "foes"] ?? [ rp.r.foe ];
			for (var _fi = 0; _fi < array_length(_rfs); _fi++) {
				var _rf = _rfs[_fi];
				var _fhps = _fr[$ "fhps"] ?? [ _fr.fhp ];
				array_push(_pf, { name : _rf.name, hpmax : _rf.hpmax, lv : _rf[$ "lv"] ?? 1, kind : _rf[$ "kind"] ?? "", col : _rf[$ "col"] ?? c_hred,
				                  hp : (_fi < array_length(_fhps)) ? _fhps[_fi] : _fr.fhp });
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
			draw_text(_tx, _fy + 12, "replay  -  fight " + string(rp.r.room) + "  -  tap to skip");
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
	var _ly = _sy + 48;
	var _ly_end = _fighting ? (_fy - 6) : (room_height - 10);
	__draw_log(_tr.log, _sx, _ly, _sw, _ly_end, _b.col2);
	// THE CONFIRM POPUP (abort): the save menu's box, over everything
	if (conf_a > .01) {
		var _cr = __conf_rect();
		var _ce = conf_a * conf_a * (3 - 2 * conf_a);
		draw_sprite_ext(spr_pixel_1x1, 0, 0, 0, room_width, room_height, 0, c_black, .55 * _ce);
		var _ry0 = _cr.y + (1 - _ce) * 8;
		draw_sprite_ext(spr_pixel_1x1, 0, _cr.x + 2, _ry0 + 3, _cr.w, _cr.h, 0, c_black, .5 * _ce);
		draw_sprite_ext(spr_pixel_1x1, 0, _cr.x, _ry0, _cr.w, _cr.h, 0, c_hsv(169, 186, 9), _ce);
		draw_px_rect(_cr.x, _ry0, _cr.w, _cr.h, c_hred, .8 * _ce);
		draw_set_halign(fa_center); draw_set_valign(fa_top);
		draw_set_color(c_white); draw_set_alpha(.95 * _ce);
		var _cq = (_tr.stage == 0) ? "turn the ship around?\n" + exped_crew_txt(_tr.names) + " will fly home without landing."
		                          : "abort the mission?\n" + exped_crew_txt(_tr.names) + " will head for the landing zone" + (is_struct(_tr[$ "quest"]) ? " and the quest is dropped." : ".");
		draw_text(_cr.x + _cr.w * .5, _ry0 + 12, _cq);
		var _cb = __conf_btns();
		ui_fade_set(_ce);
		draw_ui_button(_cb[0].x, _cb[0].y - _cr.y + _ry0, _cb[0].w, _cb[0].h, "abort", c_hred, true, true);
		draw_ui_button(_cb[1].x, _cb[1].y - _cr.y + _ry0, _cb[1].w, _cb[1].h, "cancel", rgb(170, 190, 230), true, false);
		draw_set_halign(fa_left);
	}
	ui_fade_set(1);
	exit;
}

// ======================= THE PLANET (his ask, 2026-09-15): the world, its facts, its regions =======================
if (view == "planet") {
	var _d = pl_dest;
	var _b = exped_biomes()[_d.biome];
	var _bx = __pl_box();
	draw_set_color(c_white); draw_set_alpha(.95);
	draw_text(_bx.x, list_y + 6, _d.name);
	draw_set_color(merge_colour(_b.col2, c_white, .3)); draw_set_alpha(.8);
	draw_text(_bx.x + string_width(_d.name) + 10, list_y + 6, _b.name + " world  -  tier " + string(_d.tier));
	// the world, big (__draw_world_box: the spin, the zoom, the spots)
	__draw_world_box(_d);
	ui_fade_set(_ea);
	// the facts, under it
	var _fy = _bx.y + _bx.h + 4;
	draw_set_color(_dim); draw_set_alpha(.75);
	draw_text(_bx.x, _fy, _b.hint + "  -  " + crunch_time_long(_d.dist * EXPED_TRAVEL * 60 / max(1, _e.spd)) + " flight");
	// the wild: what the regions' terrain grows (region_gen's wild lists, the union)
	var _wl = [];
	for (var _wi = 0; _wi < EXPED_REGIONS; _wi++) { var _wrg = region_get(_d, _wi); var _wk = _wrg[$ "wild"] ?? []; for (var _wj = 0; _wj < array_length(_wk); _wj++) if (!array_contains(_wl, _wk[_wj])) array_push(_wl, _wk[_wj]); }
	var _wtxt = "";
	for (var _wi = 0; _wi < array_length(_wl); _wi++) {
		var _wn = _wl[_wi];
		if (_wn == "marsh") _wn = "marshes"; else if (_wn != "hills" && _wn != "mountains" && _wn != "tundra") _wn += "s";
		_wtxt += ((_wi > 0) ? ", " : "") + _wn;
	}
	var _wline = "the wild here: " + ((_wtxt == "") ? "unknown" : _wtxt);
	draw_text_ext(_bx.x, _fy + 10, _wline, 9, _bx.w);
	draw_text_ext(_bx.x, _fy + 10 + string_height_ext(_wline, 9, _bx.w) + 1, "medieval. settlements and camps are common, towns rare, a city rarer.", 9, _bx.w);
	// the regions: EXPED_REGIONS a world, lv +0 / +2 / +4 - tap one and the world turns to it
	draw_set_color(_ink); draw_set_alpha(.6);
	var _r0 = __pl_row(0);
	draw_text(_r0.x, _r0.y - 12, "regions  -  tap one");
	var _kk = region_kinds();
	for (var _i = 0; _i < EXPED_REGIONS; _i++) {
		var _rg = region_get(_d, _i);
		var _rr = __pl_row(_i);
		var _nciv = 0, _ndun = 0, _ncmp = 0, _nlnd = 0;
		for (var _j = 0; _j < array_length(_rg.nodes); _j++) {
			var _kd = _kk[$ _rg.nodes[_j].kind];
			if (is_undefined(_kd)) continue;
			if (_kd.civ) _nciv++;
			if (_rg.nodes[_j].kind == "dungeon") _ndun++;
			if (_rg.nodes[_j].kind == "camp") _ncmp++;
			if (_rg.nodes[_j].kind == "landing") _nlnd++;
		}
		var _on = (pl_focus == _i);
		draw_sprite_ext(spr_pixel_1x1, 0, _rr.x, _rr.y, _rr.w, _rr.h, 0, c_black, .7);
		draw_px_rect(_rr.x, _rr.y, _rr.w, _rr.h, _on ? c_gold : c_steelblue, _on ? .9 : .5);
		draw_set_color(c_white); draw_set_alpha(.95);
		draw_text(_rr.x + 6, _rr.y + 3, _rg.name);
		draw_set_halign(fa_right);
		draw_set_color((_i == 0) ? c_sgreen : ((_i == 1) ? c_gold : c_hred)); draw_set_alpha(.9);
		draw_text(_rr.x + _rr.w - 6, _rr.y + 3, "level " + string(_rg.lv));
		draw_set_halign(fa_left);
		draw_set_color(_dim); draw_set_alpha(.7);
		draw_text(_rr.x + 6, _rr.y + 13, string(array_length(_rg.nodes)) + " places: " + string(_nciv) + " settled, " + string(_ndun) + ((_ndun == 1) ? " dungeon, " : " dungeons, ") + string(_ncmp) + ((_ncmp == 1) ? " camp" : " camps") + ((_nlnd > 0) ? ", 2 landing zones" : ""));
		var _out = 0;
		for (var _t = 0; _t < array_length(_e.trips); _t++) if (_e.trips[_t].dest.seed == _d.seed && (_e.trips[_t][$ "rgi"] ?? 0) == _i) _out++;
		if (_out > 0) { draw_set_halign(fa_right); draw_set_color(c_steelblue); draw_set_alpha(.9); draw_text(_rr.x + _rr.w - 6, _rr.y + 13, string(_out) + " out"); draw_set_halign(fa_left); }
	}
	// [view region], once one is picked (bottom right)
	if (pl_focus >= 0) {
		var _vr = __view_rg_r();
		draw_ui_button(_vr.x, _vr.y, _vr.w, _vr.h, "view region", c_gold, true, true);
	} else {
		draw_set_halign(fa_right); draw_set_color(_dim); draw_set_alpha(.5);
		draw_text(room_width - (land ? 14 : 4), room_height - 8 - 12, "pick a region to view it");
		draw_set_halign(fa_left);
	}
	ui_fade_set(1);
	exit;
}

// ======================= THE REGION: the quests on offer, or explore =======================
if (view == "region") {
	var _d = pl_dest;
	var _rg = region_get(_d, rg_sel);
	draw_set_color(c_white); draw_set_alpha(.95);
	draw_text(land ? 14 : 4, list_y + 6, _d.name + "  -  " + _rg.name);
	draw_set_color(_dim); draw_set_alpha(.7);
	draw_text((land ? 14 : 4) + string_width(_d.name + "  -  " + _rg.name) + 10, list_y + 6, "lv " + string(_rg.lv));
	// the world, turned to the region (his ask: it rotates and zooms in on it)
	__draw_world_box(_d);
	ui_fade_set(_ea);
	var _mr0 = __rg_map_r();
	draw_ui_button(_mr0.x, _mr0.y, _mr0.w, _mr0.h, "map", c_steelblue, true, false);
	draw_set_color(_ink); draw_set_alpha(.6);
	draw_text(__q_row(0).x, list_y + 28, "quests on offer  -  tap one");
	var _ql = exped_region_quests(_d, rg_sel);
	var _dc = [c_sgreen, c_gold, c_horange, c_hred];
	for (var _i = 0; _i <= array_length(_ql); _i++) {
		var _qr = __q_row(_i);
		var _isx = (_i >= array_length(_ql));
		draw_sprite_ext(spr_pixel_1x1, 0, _qr.x, _qr.y, _qr.w, _qr.h, 0, c_black, .7);
		draw_px_rect(_qr.x, _qr.y, _qr.w, _qr.h, _isx ? c_horange : c_gold, .5);
		if (_isx) {
			draw_set_color(c_horange); draw_set_alpha(.95);
			draw_text(_qr.x + 6, _qr.y + 4, "explore");
			draw_set_color(_dim); draw_set_alpha(.7);
			draw_text(_qr.x + 6, _qr.y + 14, "wander the region until recalled - inns, taverns, bounties, whatever they find");
		} else {
			var _q = _ql[_i];
			draw_set_color(c_white); draw_set_alpha(.95);
			draw_text(_qr.x + 6, _qr.y + 4, _q.txt);
			draw_set_color(_dc[clamp(_q.diff, 0, 3)]); draw_set_alpha(.9);
			draw_text(_qr.x + 6, _qr.y + 14, _q.diff_txt);
			draw_set_color(_dim); draw_set_alpha(.7);
			draw_text(_qr.x + 6 + string_width(_q.diff_txt) + 8, _qr.y + 14, string(_q.hours) + "h out  -  " + string(_q.reward) + " credits  -  x" + string(_q.mult) + " xp");
		}
	}
	ui_fade_set(1);
	exit;
}

// ======================= THE DEPARTURE: the crew, the brief, [depart] =======================
if (view == "depart") {
	var _d = pl_dest;
	var _rg = region_get(_d, rg_sel);
	var _q = dp_quest;
	draw_set_color(c_white); draw_set_alpha(.95);
	draw_text(land ? 14 : 4, list_y + 6, (dp_mode == "explore") ? ("explore " + _rg.name) : ("the quest  -  " + _rg.name));
	// the crew, left
	draw_set_color(_ink); draw_set_alpha(.6);
	var _np = array_length(sel_crew);
	draw_text(land ? 14 : 4, dchip_y - 12, "the crew  -  tap up to " + string(EXPED_PARTY) + ((_np > 0) ? ("  -  " + string(_np) + " picked") : ""));
	var _crew = [];
	for (var _k = 0; _k < array_length(g.sprites); _k++) {
		var _sp = g.sprites[_k];
		var _cr = __dchip_r(_k);
		var _away = (_sp[$ "trip"] ?? false);
		var _ok = !_sp.asleep && !_away;
		var _at = array_get_index(sel_crew, _sp.id);
		if (_at >= 0) array_push(_crew, _sp);
		draw_sprite_ext(spr_pixel_1x1, 0, _cr.x, _cr.y, _cr.w, _cr.h, 0, c_black, .7);
		draw_px_rect(_cr.x, _cr.y, _cr.w, _cr.h, (_at >= 0) ? c_white : _sp.col, (_at >= 0) ? .9 : (_ok ? .5 : .2));
		__dot(_cr.x + _cr.w * .5, _cr.y + _cr.h * .5 - 1, land ? 6 : 4, _sp.col, _ok ? .95 : .3);
		if (_at >= 0) { draw_set_halign(fa_center); draw_set_color(c_black); draw_set_alpha(.9); draw_text(_cr.x + _cr.w * .5 + 1, _cr.y + _cr.h * .5 - 4, string(_at + 1)); }
		draw_set_halign(fa_center);
		draw_set_color(_ok ? _ink : _dim); draw_set_alpha(_ok ? .8 : .5);
		draw_text(_cr.x + _cr.w * .5, _cr.y + _cr.h + 1, _away ? "out" : (_sp.asleep ? "zz" : (string_copy(_sp.name, 1, 4) + " " + string(sprite_sheet(_sp).lv))));
	}
	draw_set_halign(fa_left);
	// THE INSPECTED SPRITE (his ask, 2026-09-15: "i want to see the stats of
	// a sprite i select... im kinda just hoping they are strong enough"):
	// the last chip tapped - its sheet in brief, and its points against a
	// par foe of the region
	if (land) {
		var _lk = __sp_by_id(dp_look);
		var _lr = __dlook_r();
		if (!is_undefined(_lk) && _lr.h > 40) {
			var _lsh = sprite_sheet(_lk), _lst = sprite_stats(_lk), _lc = _lst.cls, _lbal = cbt_balance();
			var _lpar = sprite_par_pts(_rg.lv) * SPRITE_FOE_BUDGET;
			draw_sprite_ext(spr_pixel_1x1, 0, _lr.x, _lr.y, _lr.w, _lr.h, 0, merge_colour(_lk.col, c_black, .9), .6);
			draw_px_rect(_lr.x, _lr.y, _lr.w, _lr.h, _lk.col, .35);
			var _lx = _lr.x + 6, _ly = _lr.y + 4;
			__dot(_lx + 4, _ly + 4, 4, _lk.col, .95);
			draw_set_color(_lk.col); draw_set_alpha(.95); draw_text(_lx + 12, _ly, _lk.name);
			draw_set_color(_lc.col); draw_text(_lx + 12 + string_width(_lk.name) + 6, _ly, _lc.name + " lv " + string(_lsh.lv));
			_ly += 11;
			var _lhp = round((_lst.pts.hp * _lbal.hp_per_point + _lbal.hp_flat_add) * 10) / 10, _lmp = max(1, round(_lst.pts.mp));
			draw_set_color(_ink); draw_set_alpha(.85);
			draw_text(_lx, _ly, "hp " + string(_lhp) + "   mp " + string(_lmp));
			draw_set_halign(fa_right);
			draw_set_color((_lst.total >= _lpar) ? c_sgreen : c_hred);
			draw_text(_lr.x + _lr.w - 6, _ly, string(round(_lst.total)) + " pts  vs " + string(round(_lpar)) + " par");
			draw_set_halign(fa_left);
			_ly += 11;
			var _lkeys = ["atk", "def", "mag", "mdef", "spd", "hit"], _llbl = ["atk", "def", "int", "res", "spd", "hit"];
			for (var _k = 0; _k < 6; _k++) {
				var _gx = _lx + (_k mod 2) * 76, _gy = _ly + (_k div 2) * 10;
				draw_set_color(_dim); draw_set_alpha(.8); draw_text(_gx, _gy, _llbl[_k]);
				draw_set_halign(fa_right); draw_set_color(_ink); draw_set_alpha(.95);
				draw_text(_gx + 44, _gy, string_format(_lst.pts[$ _lkeys[_k]], 1, 1));
				draw_set_halign(fa_left);
				var _lg = _lst.gear[$ _lkeys[_k]];
				if (_lg > 0) { draw_set_color(c_sgreen); draw_set_alpha(.8); draw_text(_gx + 47, _gy, "+" + string_format(_lg, 1, 1)); }
			}
			_ly += 31;
			draw_set_color(_dim); draw_set_alpha(.8); draw_text(_lx, _ly, "weapon");
			if (is_undefined(_lsh.w1)) { draw_set_color(_dim); draw_set_alpha(.5); draw_text(_lx + 40, _ly, "(bare hands)"); }
			else { draw_set_color(_lsh.w1.col); draw_set_alpha(.95); draw_text(_lx + 40, _ly, string_copy(_lsh.w1.name, 1, 22)); }
			_ly += 10;
			var _lsk = sprite_skills(_lk), _lskt = "";
			for (var _k = 0; _k < array_length(_lsk); _k++) _lskt += ((_k > 0) ? ", " : "") + _lsk[_k].name;
			draw_set_color(_dim); draw_set_alpha(.8); draw_text(_lx, _ly, "skills");
			draw_set_color(c_horange); draw_set_alpha(.9); draw_text_ext(_lx + 40, _ly, (_lskt == "") ? "(none)" : _lskt, 9, _lr.w - 52);
		} else if (_lr.h > 40) {
			draw_set_color(_dim); draw_set_alpha(.45);
			draw_text(_lr.x + 6, _lr.y + 4, "tap a sprite to see its sheet");
		}
	}
	// the brief, right
	var _br2 = __brief_r();
	draw_sprite_ext(spr_pixel_1x1, 0, _br2.x, _br2.y, _br2.w, _br2.h, 0, c_black, .7);
	draw_px_rect(_br2.x, _br2.y, _br2.w, _br2.h, (dp_mode == "explore") ? c_horange : c_gold, .5);
	var _tx = _br2.x + 8, _ty = _br2.y + 6, _tw = _br2.w - 16;
	var _dc = [c_sgreen, c_gold, c_horange, c_hred];
	draw_set_color(c_white); draw_set_alpha(.95);
	if (is_struct(_q)) {
		draw_text_ext(_tx, _ty, _q.txt, 9, _tw);
		_ty += string_height_ext(_q.txt, 9, _tw) + 4;
		var _nd = _rg.nodes[clamp(_q.node, 0, array_length(_rg.nodes) - 1)];
		var _obj = "";
		switch (_q.kind) {
			case "slay":  _obj = "hunt " + _q.foe + "s at " + _nd.name + " (" + _nd.kind + "), " + string(_q.n) + " of them; the crew comes home when the count is met"; break;
			case "clear": _obj = "go room by room through " + _nd.name + ", " + string(_q.n) + " rooms - fights, finds, traps"; break;
			case "rout":  _obj = "walk into the camp at " + _nd.name + " and win two fights against its bandits"; break;
			case "scout": _obj = "get to " + _nd.name + " and come back with a look at it"; break;
		}
		draw_set_color(_dim); draw_set_alpha(.75);
		draw_text_ext(_tx, _ty, _obj, 9, _tw);
		_ty += string_height_ext(_obj, 9, _tw) + 6;
	} else {
		draw_text_ext(_tx, _ty, "wander " + _rg.name + " until recalled", 9, _tw);
		_ty += 12;
		draw_set_color(_dim); draw_set_alpha(.75);
		var _obj2 = "they pick their own way: inns when hurt and there is coin, shops, taverns (drink, bar fights, bounties), dungeons, camps, the wild. [recall] on the trip's page brings them home";
		draw_text_ext(_tx, _ty, _obj2, 9, _tw);
		_ty += string_height_ext(_obj2, 9, _tw) + 6;
	}
	// the numbers
	var _lvs = "";
	for (var _i = 0; _i < array_length(_crew); _i++) _lvs += ((_i > 0) ? ", " : "") + string(sprite_sheet(_crew[_i]).lv);
	draw_set_color(_ink); draw_set_alpha(.8);
	draw_text(_tx, _ty, "region strength");
	draw_set_halign(fa_right); draw_set_color(c_white); draw_text(_tx + _tw, _ty, "level " + string(_rg.lv) + ((_lvs != "") ? ("   (crew " + _lvs + ")") : "")); draw_set_halign(fa_left);
	_ty += 11;
	if (is_struct(_q)) {
		draw_set_color(_ink); draw_set_alpha(.8);
		draw_text(_tx, _ty, "difficulty");
		draw_set_halign(fa_right); draw_set_color(_dc[clamp(_q.diff, 0, 3)]); draw_text(_tx + _tw, _ty, _q.diff_txt + "  -  x" + string(_q.mult) + " xp, " + string(_q.reward) + " credits"); draw_set_halign(fa_left);
		_ty += 11;
	}
	draw_set_color(_ink); draw_set_alpha(.8);
	draw_text(_tx, _ty, "time");
	var _eta = exped_eta(_d, _q);
	draw_set_halign(fa_right); draw_set_color(c_white);
	draw_text(_tx + _tw, _ty, (_eta < 0) ? "until recalled" : ("about " + crunch_time_long(_eta * 60 / max(1, _e.spd)) + ((_e.spd > 1) ? ("  at x" + string(_e.spd)) : "")));
	draw_set_halign(fa_left);
	_ty += 11;
	var _cost = exped_cost(_d, max(1, _np));
	credits_init();
	var _have = unarb(g.credits);
	draw_set_color(_ink); draw_set_alpha(.8);
	draw_text(_tx, _ty, "the bill");
	draw_set_halign(fa_right); draw_set_color((_have >= _cost.total) ? c_lavender : c_hred);
	draw_text(_tx + _tw, _ty, "fuel " + string(_cost.fuel) + " + pocket " + string(_cost.pocket) + " = " + string(_cost.total) + "  (you have " + string(floor(_have)) + ")");
	draw_set_halign(fa_left);
	_ty += 11;
	var _od = exped_odds(_d, _q, _crew, rg_sel);
	draw_set_color(_ink); draw_set_alpha(.8);
	draw_text(_tx, _ty, "chance of success");
	draw_set_halign(fa_right);
	if (_od.p < 0) { draw_set_color(_dim); draw_text(_tx + _tw, _ty, "pick a crew"); }
	else {
		var _pc = round(_od.p * 100);
		draw_set_color((_pc >= 70) ? c_sgreen : ((_pc >= 40) ? c_gold : c_hred));
		draw_text(_tx + _tw, _ty, "about " + string(_pc) + "%  (" + string(round(_od.fights)) + ((_od.fights == 1) ? " fight" : " fights") + " expected)");
	}
	draw_set_halign(fa_left);
	// [depart]
	var _dr = __depart_r();
	var _can = (_np > 0 && _have >= _cost.total);
	draw_ui_button(_dr.x, _dr.y, _dr.w, _dr.h, (_np == 0) ? "pick a crew" : ((_have < _cost.total) ? "short of credits" : "depart"), _can ? c_sgreen : c_gray, true, _can);
	ui_fade_set(1);
	exit;
}

// ======================= THE HUB =======================
// the worlds: a card each - tap for the planet window
draw_set_color(_ink);
draw_set_alpha(.6);
draw_text(card_x0, card_y - 10, "worlds  -  tap one");
for (var _i = 0; _i < array_length(_e.board); _i++) {
	var _d = _e.board[_i];
	var _b = exped_biomes()[_d.biome];
	var _c = __card_r(_i);
	var _out = 0;
	for (var _t = 0; _t < array_length(_e.trips); _t++) if (_e.trips[_t].dest.seed == _d.seed) _out++;
	draw_sprite_ext(spr_pixel_1x1, 0, _c.x, _c.y, _c.w, _c.h, 0, c_black, .8);
	draw_px_rect(_c.x, _c.y, _c.w, _c.h, merge_colour(_b.col2, c_white, .2), .5);
	ui_fade_set(1);
	__world_small(_d, _c.x + 24, _c.y + 24, 18);
	ui_fade_set(_ea);
	draw_set_color(c_white);
	draw_set_alpha(.95);
	draw_text(_c.x + 48, _c.y + 6, _d.name);
	draw_set_color(merge_colour(_b.col2, c_white, .3));
	draw_set_alpha(.85);
	draw_text(_c.x + 48, _c.y + 16, _b.name + " world  -  tier " + string(_d.tier) + "  -  lv " + string(exped_world_lv(_d)));
	draw_set_color(_dim);
	draw_set_alpha(.7);
	draw_text(_c.x + 48, _c.y + 26, _b.hint + "  -  " + crunch_time_long(_d.dist * EXPED_TRAVEL * 60 / max(1, _e.spd)) + " flight");
	draw_text(_c.x + 6, _c.y + 48, string(EXPED_REGIONS) + " regions  -  lv " + string(exped_world_lv(_d)) + " to " + string(exped_world_lv(_d) + 2 * (EXPED_REGIONS - 1)));
	draw_set_color(c_gold); draw_set_alpha(.85);
	draw_text(_c.x + 6, _c.y + 60, "quests on offer, and explore");
	if (_out > 0) {
		draw_set_halign(fa_right);
		draw_set_color(c_steelblue);
		draw_set_alpha(.9);
		draw_text(_c.x + _c.w - 6, _c.y + 6, string(_out) + " out");
		draw_set_halign(fa_left);
	}
	draw_set_halign(fa_left);
}
// [crew]: the roster
if (array_length(g.sprites) > 0) {
	var _shr = __crewbtn_r();
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
	draw_text_ext(list_x, _ly0 + 14, "none out. tap the world, pick a region and a quest, send a crew.", 9, list_w);
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
	__world_small(_r.dest, _rr.x + 16, _rr.y + _rr.h * .5, 9);
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
		// the progress track: the leg's fill, and where they are
		var _tw = _rr.w - 40;
		var _tf = 0;
		if (_r.stage == 0) _tf = clamp(_r.t / max(1, _r.dur * EXPED_TRAVEL), 0, 1);
		else if (_r.stage == 2) _tf = clamp((_r.t - (_r[$ "leave_t"] ?? _r.t)) / max(1, _r.dur * EXPED_RETURN), 0, 1);
		else if (is_struct(_r[$ "road"])) _tf = clamp(_r.road.t / max(1, _r.road.d * EXPED_HOUR), 0, 1);
		draw_sprite_ext(spr_pixel_1x1, 0, _rr.x + 34, _rr.y + 21, _tw, 4, 0, c_black, .7);
		draw_sprite_ext(spr_pixel_1x1, 0, _rr.x + 34, _rr.y + 21, _tw * _tf, 4, 0, c_steelblue, .9);
		draw_set_halign(fa_right);
		draw_set_color(!is_undefined(_r.fight) ? c_hred : _dim);
		draw_set_alpha(.8);
		draw_text(_rr.x + _rr.w - 6, _rr.y + 5, ((_r[$ "mode"] ?? "quest") == "explore") ? "exploring" : "on a quest");
		draw_set_halign(fa_left);
		draw_set_color(_dim); draw_set_alpha(.7);
		draw_text(_rr.x + 34, _rr.y + 27, exped_where(_r));
	}
}
ui_fade_set(1);
draw_set_alpha(1);   // (the last row's .8 must not leak into the next draw - bug hunt, 2026-09-14)
