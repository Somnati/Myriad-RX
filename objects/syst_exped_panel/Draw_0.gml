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
// THE TITLE SAYS THE PAGE (his ask, 2026-09-15): three parts - a prefix,
// the WORLD'S NAME in its seeded colour, a suffix - so every page reads
// "expedition - Mudra IV / the landing reach" or the like
var _t1 = "expeditions", _t2 = "", _t3 = "", _td = undefined;
switch (view) {
	case "planet": _td = pl_dest; _t3 = "  /  " + exped_biomes()[pl_dest.biome].name + " world" + ((pv_mode == "region") ? ("  /  " + region_get(pl_dest, rg_sel).name) : ""); break;
	case "depart": _td = pl_dest; _t3 = "  /  preparation"; break;
	case "trip":   { var _ttr = __trip(); if (!is_undefined(_ttr)) { _td = _ttr.dest; _t3 = "  /  " + exped_region(_ttr).name; } break; }
	case "haul":   { var _thi = __haul_i(); if (_thi >= 0) { _td = _e.hauls[_thi].dest; _t3 = "  /  home"; } break; }
	case "map":    if (is_struct(map_dest)) { _td = map_dest; _t3 = "  /  " + region_get(map_dest, map_rgi).name + " map"; } break;
	case "crew":   _t1 = "expedition  -  the crew"; break;
	case "galaxy": _t1 = "expedition  -  the galaxy"; break;
}
if (is_struct(_td)) { _t1 = land ? "expedition  -  " : ""; _t2 = _td.name; if (!land) _t3 = ""; }
var _ttl = _t1 + _t2 + _t3;
draw_set_color(c_steelblue);
draw_set_alpha(.95);
draw_text(6, strip_y + 5, _t1);
if (_t2 != "") {
	draw_set_color(exped_world_col(_td));
	draw_text(6 + string_width(_t1), strip_y + 5, _t2);
	draw_set_color(c_steelblue);
	draw_text(6 + string_width(_t1 + _t2), strip_y + 5, _t3);
}
if (land) {
	draw_set_color(_dim);
	draw_set_alpha(.6);
	draw_text(6 + string_width(_ttl) + 8, strip_y + 5,
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

// [back] (and [crew]) on a page
if (view != "hub") __draw_back();

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
	var _cw = land ? 224 : (room_width - 8);
	// THE FINDS (his ask, 2026-09-15: "remake the findings so it looks nicer
	// and makes sense"): a label a kind, the text wrapped to the card
	var _flw = _cw - 66, _fhs = [], _fsum = 0;
	for (var _i = 0; _i < array_length(_h.finds); _i++) {
		var _ftx = (_h.finds[_i].kind == "sprite" && _recruit) ? "a sprite - wants to join" : _h.finds[_i].txt;
		var _fh = string_height_ext(_ftx, 9, _flw) + 2;
		array_push(_fhs, _fh); _fsum += _fh;
	}
	var _ch = 40 + _nb * 12 + 4 + 11 + _fsum + (_recruit ? 52 : 40);
	var _cx = land ? 14 : 4, _cy = list_y + 22;
	ui_fade_set(_ea);
	draw_sprite_ext(spr_pixel_1x1, 0, _cx, _cy, _cw, _ch, 0, c_black, .9);
	draw_px_rect(_cx, _cy, _cw, _ch, _h.routed ? c_hred : c_gold, .6);
	draw_sprite_ext(spr_pixel_1x1, 0, _cx, _cy, _cw, 1, 0, _h.routed ? c_hred : c_gold, .9);
	ui_fade_set(1);
	__world_small(_h.dest, _cx + 22, _cy + 22, 12, region_get(_h.dest, _h[$ "rgi"] ?? 0));   // (facing the region it came from)
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
	var _fy = _cy + 40 + _nb * 12 + 4;
	draw_set_halign(fa_left);
	draw_set_color(_ink); draw_set_alpha(.5);
	draw_text(_cx + 10, _fy, "brought home");
	_fy += 11;
	for (var _i = 0; _i < array_length(_h.finds); _i++) {
		var _l = _h.finds[_i];
		var _flb = "";
		switch (_l.kind) {
			case "credits": _flb = "credits"; break;
			case "gear":    _flb = "gear"; break;
			case "sprite":  _flb = "a sprite"; break;
			case "offer":   _flb = "an offer"; break;
			case "charm":   _flb = "a charm"; break;
			case "chart":   _flb = "a chart"; break;
			case "mats":    _flb = "materials"; break;
			default:        _flb = _l.kind; break;
		}
		draw_set_color(merge_colour(_l.col, _ink, .5)); draw_set_alpha(.7);
		draw_text(_cx + 10, _fy, _flb);
		draw_set_color(_l.col); draw_set_alpha(.95);
		draw_text_ext(_cx + 56, _fy, (_l.kind == "sprite" && _recruit) ? "a sprite - wants to join" : _l.txt, 9, _flw);
		_fy += _fhs[_i];
	}
	// the log: newest at the bottom, as much as fits
	if (land) {
		var _lx = _cx + _cw + 12, _lw = room_width - _lx - 14;
		draw_set_halign(fa_left);
		draw_set_color(_ink); draw_set_alpha(.5);
		draw_text(_lx, _cy, "the diary");
		__draw_log_band(_h.log, { x : _lx, y : _cy + 12, w : _lw, h : room_height - 10 - (_cy + 12) }, exped_biomes()[_h.dest.biome].col2);
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

// ======================= THE MAP (round three, 2026-09-15) =======================
// the region's circle in the rect; the roads along their bent lines with
// the hours at the middle; icons by kind (a flag, houses, tents,
// doorways); labels placed clear of the roads; the crews walking the
// bent roads; [legend] lists the kinds
if (view == "map") {
	var _d  = map_dest;
	var _rg = region_get(_d, map_rgi);
	var _kk = region_kinds();
	if (land) __info_box_size(_d, _rg);   // (the box's width first: the map sits right of it)
	var _mr = __map_r();
	var _bb = exped_biomes()[_d.biome];
	var _lkey = string(_rg.seed) + ":" + string(map_rgi) + ":" + string(_mr.w) + "x" + string(_mr.h);
	var _lab = __map_labels(_rg, _mr, _lkey);
	// the header (short: the back button sits on the right)
	draw_set_color(exped_world_col(_d)); draw_set_alpha(.95);
	draw_text(land ? 14 : 4, list_y + 6, _d.name);
	draw_set_color(c_white);
	draw_text((land ? 14 : 4) + string_width(_d.name), list_y + 6, "  -  " + _rg.name);
	// THE INFO BOX on the map too (his ask, 2026-09-15), the map to its right
	if (land) __draw_info_box(_d, _rg, __map_box_r());
	// the ground, and the region's circle
	draw_sprite_ext(spr_pixel_1x1, 0, _mr.x, _mr.y, _mr.w, _mr.h, 0, c_black, .6);
	draw_px_rect(_mr.x, _mr.y, _mr.w, _mr.h, _ink, .15);
	var _ccx = _mr.x + _mr.w * .5, _ccy = _mr.y + _mr.h * .5, _crad = min(_mr.w, _mr.h) * .5 - 10;
	for (var _a = 0; _a < 360; _a += 6) draw_sprite_ext(spr_pixel_1x1, 0, floor(_ccx + lengthdir_x(_crad + 6, _a)), floor(_ccy + lengthdir_y(_crad + 6, _a)), 1, 1, 0, _bb.col2, .35);
	// the roads: the bent lines, the hours at the middle point
	for (var _ei = 0; _ei < array_length(_rg.edges); _ei++) {
		var _ed = _rg.edges[_ei];
		var _pts = _ed[$ "pts"];
		if (!is_array(_pts) || array_length(_pts) < 2) _pts = [ _rg.nodes[_ed.a], _rg.nodes[_ed.b] ];
		var _boat = (_ed[$ "boat"] ?? false);
		for (var _k = 1; _k < array_length(_pts); _k++) {
			var _p1 = __map_xy(_pts[_k - 1], _rg, _mr), _p2 = __map_xy(_pts[_k], _rg, _mr);
			if (_boat) { if (_k mod 2 == 1) draw_px_line(_p1.x, _p1.y, _p2.x, _p2.y, rgb(120, 190, 210), .35); }
			else draw_px_line(_p1.x, _p1.y, _p2.x, _p2.y, _ink, .28);
		}
		var _mid = region_road_point(_rg, _ed.a, _ed.b, .5);
		var _mp = __map_xy(_mid, _rg, _mr);
		draw_set_alpha(.4); draw_set_color(_dim);
		draw_set_halign(fa_center);
		draw_text(_mp.x, _mp.y - 4, string(_ed.d) + "h");
	}
	// the places: an icon by kind, the label where it fits
	draw_set_halign(fa_left);
	for (var _i = 0; _i < array_length(_rg.nodes); _i++) {
		var _nd = _rg.nodes[_i];
		var _kd = _kk[$ _nd.kind] ?? _kk.field;
		var _np = __map_xy(_nd, _rg, _mr);
		var _nx = floor(_np.x), _ny = floor(_np.y);
		var _lz = (_nd[$ "landing"] ?? false);
		if (_lz && _nd.kind != "landing") __map_icon(_nd.kind, false, _nx, _ny, _kd.col);   // (a town with the landing zone inside: the house, and the flag beside it)
		__map_icon(_nd.kind, _lz, _nx + ((_lz && _nd.kind != "landing") ? 9 : 0), _ny, _lz ? c_white : _kd.col);
		var _lp = is_undefined(_lab[_i]) ? { x : _nx + 7, y : _ny - 4 } : _lab[_i];
		if (_kd.wild) { draw_set_color(merge_colour(_kd.col, _dim, .4)); draw_set_alpha(.6); }
		else { draw_set_color(_lz ? c_white : _kd.col); draw_set_alpha(.9); }
		draw_text(floor(_lp.x), floor(_lp.y), _nd.name);
	}
	// who is out to this world: at their node, or along their road (the
	// bent one); the path they mean to walk drawn in their colour
	for (var _t = 0; _t < array_length(_e.trips); _t++) {
		var _tr2 = _e.trips[_t];
		if (_tr2.dest.seed != _d.seed || (_tr2[$ "rgi"] ?? 0) != map_rgi) continue;
		var _tc = _tr2.cols[0];
		var _cpos = clamp(_tr2[$ "pos"] ?? _rg.landing, 0, array_length(_rg.nodes) - 1);
		var _cp = __map_xy(_rg.nodes[_cpos], _rg, _mr);
		var _cx = _cp.x, _cy = _cp.y;
		if (is_struct(_tr2[$ "road"])) {
			var _q = clamp(_tr2.road.t / max(1, _tr2.road.d * EXPED_HOUR), 0, 1);
			var _rp = region_road_point(_rg, _tr2.road.a, _tr2.road.b, _q);
			var _rpp = __map_xy(_rp, _rg, _mr);
			_cx = _rpp.x; _cy = _rpp.y;
		}
		// THE ROUTE, along the roads' own lines (his report: some roads had no
		// highlight - the road being walked was skipped, and six samples cut
		// the corners of a bent one): the road under them from where they
		// stand, then every road of the path; a quest crew with no path yet
		// shows the way to its objective, dimmer
		var _pp = _tr2[$ "path"] ?? [];
		var _from = _cpos;
		if (_tr2.stage == 1 && is_struct(_tr2[$ "road"])) {
			__map_road_hl(_rg, _mr, _tr2.road.a, _tr2.road.b, clamp(_tr2.road.t / max(1, _tr2.road.d * EXPED_HOUR), 0, 1), _tc, .6);
			_from = _tr2.road.b;
		}
		var _hlal = .55;
		if (array_length(_pp) == 0 && _tr2.stage == 1 && is_struct(_tr2[$ "quest"]) && _tr2.quest.done < _tr2.quest.n && !(_tr2[$ "recall"] ?? false) && !(_tr2[$ "aborted"] ?? false)) { _pp = region_path(_rg, _from, _tr2.quest.node); _hlal = .28; }
		for (var _k = 0; _k < array_length(_pp); _k++) {
			var _to = clamp(_pp[_k], 0, array_length(_rg.nodes) - 1);
			if (_to != _from) __map_road_hl(_rg, _mr, _from, _to, 0, _tc, _hlal);
			_from = _to;
		}
		// the objective: a pulsing square in the crew's colour
		if (_tr2.stage == 1 && is_struct(_tr2[$ "quest"]) && _tr2.quest.done < _tr2.quest.n) {
			var _qn = __map_xy(_rg.nodes[clamp(_tr2.quest.node, 0, array_length(_rg.nodes) - 1)], _rg, _mr);
			var _qs = 7 + floor(_br * 2);
			draw_px_rect(floor(_qn.x) - _qs, floor(_qn.y) - _qs, _qs * 2, _qs * 2, _tc, .5 + .4 * _br);
		}
		if (_tr2.stage != 1) { var _lzp = __map_xy(_rg.nodes[_rg.landing], _rg, _mr); _cx = _lzp.x - 12; _cy = _lzp.y; }
		for (var _k = 0; _k < array_length(_tr2.sids); _k++) __dot(_cx - 6 + _k * 6, _cy + 8, 3, _tr2.cols[_k], (_tr2.hp[_k] > 0) ? .95 : .3);
		draw_set_color(_tc); draw_set_alpha(.85);
		draw_text(_cx - 6, _cy + 12, exped_crew_txt(_tr2.names) + ": " + ((_tr2.stage == 1) ? exped_where(_tr2) : ((_tr2.stage == 0) ? "on the way" : "gone home")));
	}
	// [legend], and the note
	var _lgr = __legend_r();
	draw_ui_button(_lgr.x, _lgr.y, _lgr.w, _lgr.h, "legend", c_steelblue, true, false);
	draw_set_color(_dim); draw_set_alpha(.4);
	draw_set_halign(fa_right);
	draw_text(room_width - (land ? 14 : 4), _mr.y + _mr.h + 3, "hours on the roads  -  a crew's route in its colour");
	draw_set_halign(fa_left);
	if (map_legend) {
		// THE LEGEND (his ask): every kind, its icon or dot, its name; two columns
		var _lgk = ["landing", "settlement", "village", "town", "city", "camp", "dungeon", "crypt", "ruin", "shrine", "mine", "field", "forest", "hills", "marsh", "mountains", "desert", "tundra", "coast", "isle"];
		var _lgw = 230, _lgh = 14 + ceil(array_length(_lgk) / 2) * 12 + 6;
		var _lgx = _mr.x + 8, _lgy = _mr.y + _mr.h - _lgh - 8;
		draw_sprite_ext(spr_pixel_1x1, 0, _lgx + 2, _lgy + 3, _lgw, _lgh, 0, c_black, .5);
		draw_sprite_ext(spr_pixel_1x1, 0, _lgx, _lgy, _lgw, _lgh, 0, c_hsv(169, 186, 9), .98);
		draw_px_rect(_lgx, _lgy, _lgw, _lgh, c_steelblue, .8);
		draw_set_color(c_steelblue); draw_set_alpha(.95);
		draw_text(_lgx + 6, _lgy + 4, "the legend");
		for (var _i = 0; _i < array_length(_lgk); _i++) {
			var _lk = _lgk[_i];
			var _lkd = _kk[$ _lk];
			if (is_undefined(_lkd)) continue;
			var _lx = _lgx + 8 + (_i mod 2) * 112, _ly = _lgy + 18 + (_i div 2) * 12;
			__map_icon(_lk, (_lk == "landing"), _lx + 5, _ly + 3, (_lk == "landing") ? c_white : _lkd.col);
			draw_set_color(_ink); draw_set_alpha(.85);
			draw_text(_lx + 16, _ly, _lkd.name);
		}
	}
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
	__draw_sheet(_sp, __sheet_x0(), list_y + 22, room_width - (land ? 14 : 4));
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
	var _rg = exped_region(_tr);
	var _wc = exped_world_col(_d);
	var _lf = _tr.fight;
	// ---- THE WORLD'S ISLAND: the render (its camera fixed on the trip's
	// region - tp_cam), the name, the region, the leg, the buttons ----
	var _isl = __trip_isle_r();
	draw_sprite_ext(spr_pixel_1x1, 0, _isl.x, _isl.y, _isl.w, _isl.h, 0, c_black, .85);
	draw_px_rect(_isl.x, _isl.y, _isl.w, _isl.h, _wc, .35);
	draw_sprite_ext(spr_pixel_1x1, 0, _isl.x, _isl.y, 2, _isl.h, 0, _wc, .9);
	__draw_orbit(_d, big_x + 2, big_y + 1, big_w - 3, big_h - 2, (big_w - 3) * .5, (big_h - 2) * .5 + 2, land ? 30 : 26, tp_cam, tp_spin, _tr[$ "rgi"] ?? 0, _tr[$ "rgi"] ?? 0, 1);
	ui_fade_set(_ea);
	draw_set_halign(fa_center);
	draw_set_font(fnt_large);
	draw_set_color(_wc); draw_set_alpha(.95);
	draw_text(big_x + big_w * .5, big_y + big_h + 3, str_cap(_d.name));
	draw_set_font(fnt);
	draw_set_color(merge_colour(_b.col2, c_white, .3)); draw_set_alpha(.8);
	draw_text(big_x + big_w * .5, big_y + big_h + 17, _rg.name + "  -  lv " + string(exped_trip_lv(_tr)));
	draw_set_halign(fa_left);
	// the leg: a labelled bar (the hub's), then the day and the weather
	var _travel = _tr.dur * EXPED_TRAVEL;
	var _tf = 0, _leg = "";
	if (_tr.stage == 0) { _tf = clamp(_tr.t / max(1, _travel), 0, 1); _leg = "flying out"; }
	else if (_tr.stage == 2) { _tf = clamp((_tr.t - (_tr[$ "leave_t"] ?? _tr.t)) / max(1, _tr.dur * EXPED_RETURN), 0, 1); _leg = "flying home"; }
	else if (is_struct(_tr[$ "road"])) { _tf = clamp(_tr.road.t / max(1, _tr.road.d * EXPED_HOUR), 0, 1); _leg = "on the road"; }
	else if (is_struct(_tr[$ "act"])) { _tf = 1 - clamp(_tr.act.left / max(1, EXPED_ROOM_T), 0, 1); _leg = "at " + _rg.nodes[clamp(_tr.pos, 0, array_length(_rg.nodes) - 1)].name; }
	else { _tf = 0; _leg = "deciding"; }
	var _lgy = big_y + big_h + 30;
	draw_set_color(_dim); draw_set_alpha(.7);
	draw_text(big_x + 6, _lgy, string_copy(_leg, 1, 14));
	var _lbx = big_x + 6 + max(46, string_width(string_copy(_leg, 1, 14)) + 6), _lbw = big_x + big_w - 6 - _lbx;
	draw_sprite_ext(spr_pixel_1x1, 0, _lbx, _lgy + 2, _lbw, 4, 0, c_black, .7);
	draw_sprite_ext(spr_pixel_1x1, 0, _lbx, _lgy + 2, _lbw * _tf, 4, 0, (_tr.stage == 1) ? c_sgreen : c_steelblue, .9);
	draw_px_rect(_lbx, _lgy + 2, _lbw, 4, c_white, .1);
	draw_set_color(_dim); draw_set_alpha(.6);
	var _sky = (_tr.stage == 1) ? (((_tr[$ "night"] ?? false) ? "night" : "day") + (((_tr[$ "weather"] ?? "clear") != "clear") ? (", " + _tr.weather) : "")) : "in space";
	draw_text(big_x + 6, _lgy + 11, _sky + ((_e.spd > 1) ? ("  -  x" + string(_e.spd)) : ""));
	// [crew] [map] [abort] at the island's foot
	var _tcr = __trip_crew_r();
	draw_ui_button(_tcr.x, _tcr.y, _tcr.w, _tcr.h, "crew", c_steelblue, true, false);
	var _tmr = __trip_map_r();
	draw_ui_button(_tmr.x, _tmr.y, _tmr.w, _tmr.h, "map", c_steelblue, true, false);
	var _abr = __trip_abort_r();
	var _can_abort = !(_tr[$ "aborted"] ?? false) && _tr.stage != 2;
	draw_ui_button(_abr.x, _abr.y, _abr.w, _abr.h, (_tr[$ "aborted"] ?? false) ? "aborted" : "abort", c_hred, _can_abort, false);
	// ---- THE CREW as banners (the preparation page's), hp / mp LIVE in a
	// fight (the pawn's, or the replay frame's), the trip's between ----
	for (var _k = 0; _k < _n; _k++) {
		var _cr = __crew_row_r(_k);
		var _rsp = __sp_by_id(_tr.sids[_k]);
		var _hpk = _tr.hp[_k], _hmk = max(1, _tr.hpmax[_k]);
		var _mpf = (is_array(_tr[$ "mp"]) && _k < array_length(_tr.mp)) ? _tr.mp[_k] : 1;
		var _mpm = is_undefined(_rsp) ? 1 : max(1, round(sprite_stats(_rsp).pts.mp)), _mpk = round(_mpm * _mpf);
		if (!is_undefined(_lf)) { for (var _pi = 0; _pi < array_length(_lf.party); _pi++) if ((_lf.party[_pi][$ "mi"] ?? -1) == _k) { _hpk = _lf.party[_pi].hp; _mpk = _lf.party[_pi][$ "mp"] ?? _mpk; _mpm = max(1, _lf.party[_pi][$ "maxmp"] ?? _mpm); } }
		else if (!is_undefined(rp)) { var _rfr = rp.r.ev[rp.i]; for (var _pi = 0; _pi < array_length(rp.r.party); _pi++) if ((rp.r.party[_pi][$ "mi"] ?? _pi) == _k && _pi < array_length(_rfr.php)) _hpk = _rfr.php[_pi]; }
		var _up = (_hpk > 0);
		if (!is_undefined(_rsp)) __dp_banner(_rsp, _cr.x, _cr.y, _cr.w, _up ? 1 : .45, false, { hp : _hpk, hpmax : _hmk, mp : _mpk, mpmax : _mpm });
		else {
			draw_sprite_ext(spr_pixel_1x1, 0, _cr.x, _cr.y, _cr.w, _cr.h, 0, c_black, .6);
			draw_sprite_ext(spr_pixel_1x1, 0, _cr.x, _cr.y, 2, _cr.h, 0, _tr.cols[_k], _up ? .9 : .3);
			draw_set_color(_up ? _ink : _dim); draw_set_alpha(.85); draw_text(_cr.x + 8, _cr.y + 3, _tr.names[_k]);
		}
		if (!_up) { draw_set_halign(fa_right); draw_set_color(c_hred); draw_set_alpha(.9); draw_text(_cr.x + _cr.w - 4, _cr.y + 3, "down"); draw_set_halign(fa_left); }
	}

	// ---- THE QUEST'S ISLAND, right: the ask and the tally, the pocket and
	// the wins; [recall] on an explore ----
	var _sx = log_x, _sy = log_y, _sw = log_w;
	var _q = _tr[$ "quest"];
	var _mode = _tr[$ "mode"] ?? "quest";
	draw_sprite_ext(spr_pixel_1x1, 0, _sx, _sy, _sw, 36, 0, c_black, .8);
	draw_px_rect(_sx, _sy, _sw, 36, is_struct(_q) ? c_gold : c_horange, .3);
	draw_sprite_ext(spr_pixel_1x1, 0, _sx, _sy, 2, 36, 0, is_struct(_q) ? c_gold : c_horange, .9);
	var _qtw = _sw - 16 - ((_mode == "explore" && !(_tr[$ "recall"] ?? false) && _tr.stage == 1) ? 62 : 0);
	draw_set_color(is_struct(_q) ? c_gold : c_horange); draw_set_alpha(.95);
	if (is_struct(_q)) draw_text(_sx + 8, _sy + 4, string_copy(_q.txt, 1, land ? 52 : 26));
	else {
		var _tex = _tr[$ "ex"], _texw = "exploring " + _rg.name;
		if (is_struct(_tex) && _tex.kind == "ramble") _texw = "roaming " + _rg.name + " - " + string(_tex.n) + "h asked";
		else if (is_struct(_tex) && _tex.kind == "survey") _texw = "surveying " + _rg.name + " - " + string(max(0, array_length(_tr[$ "visited"] ?? []) - 1)) + " of " + string(_tex.n) + " places";
		draw_text(_sx + 8, _sy + 4, string_copy(_texw, 1, land ? 52 : 26));
	}
	// the tally line: done / n (or the hours), the pocket, the wins, where
	draw_set_color(_ink); draw_set_alpha(.8);
	var _tl = is_struct(_q) ? (string(_q.done) + " / " + string(_q.n) + ((_q.done >= _q.n) ? "  done" : "")) : (string_format((_tr[$ "planet_t"] ?? 0) / EXPED_HOUR, 1, 1) + "h on the world");
	draw_text(_sx + 8, _sy + 15, _tl);
	draw_set_color(c_lavender); draw_set_alpha(.85);
	draw_text(_sx + 8 + string_width(_tl) + 10, _sy + 15, string(_tr[$ "credits"] ?? 0) + " cr in the pocket");
	draw_set_color(_dim); draw_set_alpha(.7);
	draw_text(_sx + 8, _sy + 25, string_copy(exped_where(_tr) + ((_tr[$ "recall"] ?? false) ? "  -  heading home" : ""), 1, land ? 56 : 28));
	draw_set_halign(fa_right);
	draw_set_color((_tr[$ "wins"] ?? 0) > 0 ? c_sgreen : _dim); draw_set_alpha(.8);
	draw_text(_sx + _sw - 8, _sy + 25, string(_tr[$ "wins"] ?? 0) + ((_tr[$ "wins"] ?? 0) == 1 ? " fight won" : " fights won"));
	draw_set_halign(fa_left);
	if (_mode == "explore" && !(_tr[$ "recall"] ?? false) && _tr.stage == 1) {
		var _rr2 = __recall_r();
		draw_ui_button(_rr2.x, _rr2.y, _rr2.w, _rr2.h, "recall", c_horange, true, true);
	}

	// ---- THE COMBAT WINDOW (his ask: moved to the corner, a little bigger,
	// not a centrepiece), while a fight is on - or while a fight that ended
	// off screen REPLAYS from its film (rp): the crew as their own
	// portraits bottom left, the foes as diamonds top right, hp over each,
	// the flash and the shake on whoever was hit, the damage in the outline
	// font; the fight's lines to the window's LEFT ----
	var _fighting = !is_undefined(_tr.fight) || !is_undefined(rp);
	var _fr0 = __fight_r();
	var _fy = _fr0.y;
	if (_fighting) {
		var _f = _tr.fight;
		if (is_undefined(_f)) {
			// the film's frame as a fight: hp from the event, the flash on
			// its target, the party's shape from the record
			var _fr = rp.r.ev[rp.i];
			var _pp = [];
			for (var _pi = 0; _pi < array_length(rp.r.party); _pi++) {
				var _pm = rp.r.party[_pi];
				array_push(_pp, { name : _pm.name, col : _pm.col, hpmax : _pm.hpmax, sid : _pm[$ "sid"] ?? -1, mi : _pm[$ "mi"] ?? _pi,
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
		var _fx = _fr0.x, _fs = fight_s;
		draw_sprite_ext(spr_pixel_1x1, 0, _fx, _fy, _fs, _fs, 0, c_black, .88);
		// the ground: a dark band, a floor line
		draw_sprite_ext(spr_pixel_1x1, 0, _fx + 1, _fy + _fs - 18, _fs - 2, 17, 0, merge_colour(_b.col2, c_black, .82), .9);
		draw_sprite_ext(spr_pixel_1x1, 0, _fx + 4, _fy + _fs - 18, _fs - 8, 1, 0, _ink, .25);
		draw_px_rect(_fx, _fy, _fs, _fs, (_f[$ "replay"] ?? false) ? _dim : c_hred, ((_f[$ "replay"] ?? false) ? .4 : .5) + .3 * _br);
		var _flash_t = (!is_undefined(_f.last)) ? clamp(1 - (current_time - _f.last.at) / 350, 0, 1) : 0;
		// the foes, a row top right: a diamond each, its hp above
		var _fos = _f[$ "foes"] ?? [ _f.b ];
		var _nfo = array_length(_fos);
		for (var _j = 0; _j < _nfo; _j++) {
			var _fo = _fos[_j];
			var _jx = _fx + _fs - 14 - _j * 18, _jy = _fy + 28 - (_j mod 2) * 7;
			var _jhit = (_flash_t > 0 && _f.last.side == "b" && (_f.last.i == _j || (_f.last.i < 0 && _j == 0)));
			var _shk = _jhit ? (irandom(2) - 1) : 0;
			var _jc = _fo[$ "col"] ?? c_hred;
			if (_fo.hp > 0) { draw_sprite_ext(spr_pixel_1x1, 0, _jx - 6 + _shk, _jy - 6, 12, 12, 45, merge_colour(_jc, c_black, .35), .95); draw_sprite_ext(spr_pixel_1x1, 0, _jx - 4 + _shk, _jy - 4, 8, 8, 45, _jhit ? c_white : _jc, .95); }
			else draw_sprite_ext(spr_pixel_1x1, 0, _jx - 6, _jy + 3, 12, 3, 0, _jc, .4);
			var _jf = clamp(_fo.hp / max(1, _fo.hpmax), 0, 1);
			draw_sprite_ext(spr_pixel_1x1, 0, _jx - 7, _jy - 14, 14, 2, 0, c_black, .8);
			draw_sprite_ext(spr_pixel_1x1, 0, _jx - 7, _jy - 14, 14 * _jf, 2, 0, c_hred, .9);
		}
		// the crew, bottom left: their own portraits (the room's blobs), hp over each
		ui_fade_set(1);
		for (var _k = 0; _k < array_length(_f.party); _k++) {
			var _m = _f.party[_k];
			var _mx = _fx + 14 + _k * 18, _my = _fy + _fs - 24 - (_k mod 2) * 7;
			var _mhit = (_flash_t > 0 && _f.last.side == "a" && _f.last.i == _k);
			var _sk = _mhit ? (irandom(2) - 1) : 0;
			var _msp = __sp_by_id(_m[$ "sid"] ?? -1);
			if (is_undefined(_msp) && (_m[$ "mi"] ?? -1) >= 0 && _m.mi < _n) _msp = __sp_by_id(_tr.sids[_m.mi]);
			if (_m.hp > 0) {
				if (!is_undefined(_msp)) sprite_portrait(_msp, _mx + _sk, _my, 1); else __dot(_mx + _sk, _my, 5, _m.col, .95);
				if (_mhit) draw_sprite_ext(spr_pixel_1x1, 0, _mx - 6 + _sk, _my - 6, 12, 12, 0, c_white, .55);
			} else __dot(_mx, _my + 5, 5, _m.col, .25);
			var _mf = clamp(_m.hp / max(1, _m.hpmax), 0, 1);
			draw_sprite_ext(spr_pixel_1x1, 0, _mx - 7, _my - 12, 14, 2, 0, c_black, .8);
			draw_sprite_ext(spr_pixel_1x1, 0, _mx - 7, _my - 12, 14 * _mf, 2, 0, (_mf > .35) ? c_sgreen : c_horange, .9);
		}
		ui_fade_set(_ea);
		// the damage number, floating off the one hit (the outline font)
		if (_flash_t > 0) {
			draw_set_font(fnt_outline); draw_set_halign(fa_center);
			draw_set_color(c_white); draw_set_alpha(_flash_t);
			var _dx = (_f.last.side == "b") ? (_fx + _fs - 14 - max(0, _f.last.i) * 18) : (_fx + 14 + _f.last.i * 18);
			var _dy = ((_f.last.side == "b") ? (_fy + 28) : (_fy + _fs - 24)) - 20 - (1 - _flash_t) * 8;
			draw_text(_dx, _dy, "-" + string(_f.last.dmg));
			draw_set_halign(fa_left); draw_set_font(fnt);
		}
		// the fight's lines, to the window's left: the pack, the action, the last line
		var _tx = _sx, _ltw = _fx - 8 - _sx;
		draw_set_color(c_hred); draw_set_alpha(.95);
		var _pk = "";
		for (var _j = 0; _j < _nfo; _j++) _pk += ((_j > 0) ? ", " : "") + ((_fos[_j].hp > 0) ? _fos[_j].name : ("[" + _fos[_j].name + "]"));
		draw_text_ext(_tx, _fy + 2, _pk, 9, _ltw);
		var _pkh = string_height_ext(_pk, 9, _ltw);
		draw_set_color(_dim); draw_set_alpha(.7);
		if (_f[$ "replay"] ?? false) draw_text(_tx, _fy + 4 + _pkh, "replay  -  fight " + string(rp.r.room) + "  -  tap to skip");
		else draw_text(_tx, _fy + 4 + _pkh, "action " + string(_f.turn) + "  -  lv " + string(_f.b[$ "lv"] ?? 1) + "  -  " + string(_nfo) + ((_nfo == 1) ? " foe" : " foes"));
		var _fl = array_length(_f.log);
		draw_set_color(c_white); draw_set_alpha(.9);
		draw_text_ext(_tx, _fy + 16 + _pkh, (_fl > 0) ? _f.log[_fl - 1] : "...", 9, _ltw);
		if (!(_f[$ "replay"] ?? false)) {
			var _st = __step_r();
			draw_ui_button(_st.x, _st.y, _st.w, _st.h, _f.over ? "done" : "step turn", c_hred, !_f.over, !_f.over);
		} else if (_f.over) {
			var _rdr = (rp.r[$ "drawn"] ?? false);
			draw_set_color(_f.won ? c_sgreen : (_rdr ? _dim : c_hred));
			draw_set_alpha(.9);
			draw_text(_tx, _fy + _fs - 12, _f.won ? "won" : (_rdr ? "withdrew" : "routed"));
		}
	}

	// ---- THE DIARY, under the quest's island: truth lines plain, the "~ "
	// lines the crew's own voice, "+ " the rewards in gold; newest at the
	// bottom, on the scrollbar (it follows the newest line while you sit there) ----
	var _ly = _sy + 42;
	var _ly_end = _fighting ? (_fy - 6) : (room_height - 10);
	__draw_log_band(_tr.log, { x : _sx, y : _ly, w : _sw, h : _ly_end - _ly }, _b.col2);
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

// ======================= THE PLANET PAGE (2026-09-15): the orbit view =======================
// the tech demo's rm_planet in the panel: the whole page is the sky (the
// real neighbourhood, the milky way, the system's sun) with the world in
// the middle, the camera orbiting it by drag; the regions' spots are on
// the globe (tap one), the drawer on the right lists them
if (view == "planet") {
	var _d = pl_dest;
	var _b = exped_biomes()[_d.biome];
	var _ocf = starmap_config();
	var _pvr = __pv_r(), _pvc = __pv_c();
	var _pn = planet_get(_d.seed, exped_planet_hint(_d));
	var _built = (_pn.row >= _pn.th);
	var _w = _pvr.w, _h = _pvr.h;
	if (!surface_exists(wb_surf) || surface_get_width(wb_surf) != _w || surface_get_height(wb_surf) != _h) {
		if (surface_exists(wb_surf)) surface_free(wb_surf);
		wb_surf = page_surface(_w, _h);
	}
	if (!surface_exists(sky_fog_surf) || surface_get_width(sky_fog_surf) != _w || surface_get_height(sky_fog_surf) != _h) {
		if (surface_exists(sky_fog_surf)) surface_free(sky_fog_surf);
		sky_fog_surf = surface_create(_w, _h);
	}
	var _lcx = _pvc.x - _pvr.x, _lcy = _pvc.y - _pvr.y;
	var _pr = _ocf.pr * pv_zoom;
	var _mats = __draw_orbit(_d, _pvr.x, _pvr.y, _w, _h, _lcx, _lcy, _pr, pv_cam, pv_spin, (pv_mode == "region") ? pl_focus : -2, pl_focus, pv_cfade);
	pv_mat_m = _mats.m; pv_mat_r = _mats.r;
	ui_fade_set(_ea);
	// the facts over the sky (the world's name lives in the strip now - his
	// ask, 2026-09-15; the tier and the flight time are gone)
	if (is_struct(pv_sky)) {
		var _sm = starmap_get(), _hm = galaxy_home();
		draw_set_color(_dim); draw_set_alpha(.7);
		draw_text(land ? 14 : 4, list_y + 6, "the " + star_name(_hm.star) + " system  -  " + _sm.regions[_sm.stars[_hm.star].props.region].name + "  -  " + string(array_length(_hm.sys.planets)) + " worlds");
	}
	// the hint, bottom middle
	draw_set_halign(fa_center); draw_set_color(_dim); draw_set_alpha(.6);
	draw_text(room_width * .5, room_height - 8 - 12, (pv_mode == "region") ? "drag to orbit" : "drag to orbit  -  tap a region");
	draw_set_halign(fa_left);
	// the left column: [galaxy] at the foot, [region map] over it in region mode, the geosync toggle on top
	var _gl = __galaxy_r();
	draw_ui_button(_gl.x, _gl.y, _gl.w, _gl.h, "galaxy", c_steelblue, true, false);
	var _ge = __geo_r();
	draw_ui_button(_ge.x, _ge.y, _ge.w, _ge.h, pv_geo ? (land ? "riding the spin" : "geosync") : "free camera", pv_geo ? c_sgreen : c_gray, true, false);
	if (pv_mode == "region") {
		// REGION MODE: THE INFO BOX left (his shape, 2026-09-15: the name, then
		// "level 1 - peaceful / temperature - warm / weather - calm / time -
		// dusk / flora - bountiful / fauna - passive / civilization -
		// farmlands", the word coloured by its threat - region_info), [region
		// map] in the left column, [quests] over [explore] bottom right
		var _rg = region_get(_d, rg_sel);
		__draw_info_box(_d, _rg, __rg_banner_r());
		var _mr0 = __rgmap_r();
		draw_ui_button(_mr0.x, _mr0.y, _mr0.w, _mr0.h, "region map", c_steelblue, true, false);
		var _qb = __quests_r();
		draw_ui_button(_qb.x, _qb.y, _qb.w, _qb.h, "quests", c_gold, true, true);
		var _xb = __explore_r();
		draw_ui_button(_xb.x, _xb.y, _xb.w, _xb.h, "explore", c_horange, true, false);
		// THE HAND'S VEIL (the cards themselves are obj_card instances over the panel)
		if (hand_a > .001) {
			draw_sprite_ext(spr_pixel_1x1, 0, 0, list_y, room_width, room_height - list_y, 0, c_black, .85 * hand_a);   // (darker - his ask)
			draw_set_halign(fa_center); draw_set_color(_dim); draw_set_alpha(.7 * hand_a);
			draw_text(room_width * .5, list_y + 24, (hand == "quests") ? "quests on offer  -  tap one; off the cards to close" : "explore  -  tap a card; off the cards to close");
			// THE CLOCK under each card (his ask): grey, reddening as the slot
			// nears its re-deal (the last half hour); a taken one says so
			for (var _hc = 0; _hc < array_length(hand_ids); _hc++) {
				var _cd = hand_ids[_hc];
				if (!instance_exists(_cd) || !_cd.visible || !_cd.settled) continue;
				var _csl = _cd.face[$ "slot"];
				if (!is_struct(_csl)) continue;
				if (_csl.taken != 0) { draw_set_color(c_steelblue); draw_set_alpha(.8 * hand_a); draw_text(_cd.x, _cd.y + _cd.card_h * .5 + 4, "taken"); }
				else {
					var _urg = 1 - clamp(_csl.left / EXPED_QUEST_LIFE_LO, 0, 1);
					draw_set_color(merge_colour(c_gray, c_hred, _urg)); draw_set_alpha((.7 + .3 * _urg) * hand_a);
					draw_text(_cd.x, _cd.y + _cd.card_h * .5 + 4, "gone in " + crunch_time_long(_csl.left / max(1, g.exped.spd)));
				}
			}
			draw_set_halign(fa_left);
		}
	} else if (pl_focus >= 0) {
		var _vr = __view_rg_r();
		draw_ui_button(_vr.x, _vr.y, _vr.w, _vr.h, "view region", c_gold, true, true);
	} else {
		draw_set_halign(fa_right); draw_set_color(_dim); draw_set_alpha(.5);
		draw_text(room_width - (land ? 14 : 4), room_height - 8 - 12, "pick a region to view it");
		draw_set_halign(fa_left);
	}
	// THE DRAWER: the tab on the right edge, the regions when open (planet mode only)
	var _dwx = __pv_dw_x();
	if (pv_mode == "region") { __draw_back(); ui_fade_set(1); exit; }
	if (pv_dwa > .01) draw_sprite_ext(spr_pixel_1x1, 0, _dwx + 9, list_y + 16, room_width - (_dwx + 9), room_height - 30 - (list_y + 16), 0, c_black, .82 * pv_dwa);   // (ends above the button row)
	var _tb = __pv_tab_r();
	draw_sprite_ext(spr_pixel_1x1, 0, _tb.x, _tb.y, _tb.w, _tb.h, 0, c_black, .85);
	draw_px_rect(_tb.x, _tb.y, _tb.w, _tb.h, c_steelblue, .6);
	draw_set_color(c_steelblue); draw_set_alpha(.9);
	draw_text(_tb.x + 2, _tb.y + _tb.h * .5 - 4, pv_dw ? ">" : "<");
	if (pv_dwa > .3) {
		draw_set_color(_ink); draw_set_alpha(.6 * pv_dwa);
		draw_text(_dwx + 13, list_y + 24, "regions  -  tap one");
		var _kk = region_kinds();
		for (var _i = 0; _i < EXPED_REGIONS; _i++) {
			var _rg = region_get(_d, _i);
			var _rr = __pv_row_r(_i);
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
			draw_text(_rr.x + 5, _rr.y + 3, string_copy(_rg.name, 1, land ? 18 : 14));
			draw_set_halign(fa_right);
			draw_set_color((_i == 0) ? c_sgreen : ((_i == 1) ? c_gold : c_hred)); draw_set_alpha(.9);
			draw_text(_rr.x + _rr.w - 5, _rr.y + 3, "lv " + string(_rg.lv));
			draw_set_halign(fa_left);
			draw_set_color(_dim); draw_set_alpha(.7);
			var _rinf = region_info(_d, _rg), _rbio = "";
			for (var _ri2 = 0; _ri2 < array_length(_rinf); _ri2++) if (_rinf[_ri2].k == "biome") _rbio = _rinf[_ri2].v;
			draw_text(_rr.x + 5, _rr.y + 13, (_rg[$ "mood"] ?? "quiet") + "  -  " + _rbio);   // (the mood and the biome, the info box's words)
			var _out = 0;
			for (var _t = 0; _t < array_length(_e.trips); _t++) if (_e.trips[_t].dest.seed == _d.seed && (_e.trips[_t][$ "rgi"] ?? 0) == _i) _out++;
			if (_out > 0) { draw_set_halign(fa_right); draw_set_color(c_steelblue); draw_set_alpha(.9); draw_text(_rr.x + _rr.w - 5, _rr.y + 13, string(_out) + " out"); draw_set_halign(fa_left); }
		}
		draw_set_color(_dim); draw_set_alpha(.5 * pv_dwa);
		draw_text(_dwx + 13, list_y + 40 + EXPED_REGIONS * 26 + 4, "tap a row: the world turns to it");
	}
	__draw_back();
	ui_fade_set(1);
	exit;
}

// ======================= THE GALAXY (2026-09-15): the star map =======================
// the tech demo's rm_starmap as a page: the parallax backdrop, the stars
// off the draw grid with their depth parallax, the nebula fog sheet
// (baked once a galaxy, dithered), the home star ringed. Drag pans,
// the wheel zooms, a tap names a star. Travel comes later
if (view == "galaxy") {
	var _gcf = starmap_config();
	var _sm = starmap_get();
	var _hm = galaxy_home();
	var _gr = __gx_r();
	var _vw = _gr.w, _vh = _gr.h;
	if (!gx_init) { gx_init = true; gx_zoom = 1; gx_x = _sm.stars[_hm.star].x - _vw * .5; gx_y = _sm.stars[_hm.star].y - _vh * .5; }
	if (array_length(gx_para) == 0) {
		var _tw = _vw + 200, _th = _vh + 200;
		for (var _l = 0; _l < _gcf.para_layers; _l++) {
			var _lst = [];
			repeat (_gcf.para_stars) array_push(_lst, { x : random(_tw), y : random(_th), col : choose(rgb(150, 160, 190), rgb(150, 160, 190), rgb(190, 170, 150)), a : .08 + .07 * _l + random(.06) });
			array_push(gx_para, { f : .15 + .175 * _l, tw : _tw, th : _th, stars : _lst });
		}
	}
	// (the fade off before anything bakes: a sheet baked under the open
	// animation's fade shader would keep that alpha for good)
	var _fa = g.ui_fade_a;
	ui_fade_set(1);
	// the fog sheet: the density grid baked once, warm core to cool rim
	if (!surface_exists(gx_fog) || gx_fog_seed != _sm.seed) {
		if (surface_exists(gx_fog)) surface_free(gx_fog);
		var _ngw = _sm.ngw;
		gx_fog = surface_create(_ngw, _ngw);
		surface_set_target(gx_fog);
		draw_clear_alpha(c_black, 0);
		for (var _cy = 0; _cy < _ngw; _cy++)
		for (var _cx = 0; _cx < _ngw; _cx++) {
			var _acc = 0, _wsm = 0;
			for (var _oy = -1; _oy <= 1; _oy++)
			for (var _ox = -1; _ox <= 1; _ox++) {
				var _nx = _cx + _ox, _ny = _cy + _oy;
				if (_nx < 0 || _ny < 0 || _nx >= _ngw || _ny >= _ngw) continue;
				var _wt = ((_ox == 0) ? 2 : 1) * ((_oy == 0) ? 2 : 1);
				_acc += _sm.ngrid[_nx + _ny * _ngw] * _wt;
				_wsm += _wt;
			}
			var _dn = (_acc / _wsm) / _sm.nmax;
			if (_dn <= .01) continue;
			_dn = power(_dn, .40);
			var _wx = (_cx + .5) * _sm.ncell, _wy = (_cy + .5) * _sm.ncell;
			var _rd = clamp(point_distance(_wx, _wy, _sm.cx, _sm.cy) / _sm.gal_r, 0, 1);
			var _col = merge_colour(rgb(255, 185, 125), rgb(130, 155, 255), _rd);
			_col = merge_colour(rgb(24, 22, 30), _col, .55 + .45 * _dn);
			draw_sprite_ext(spr_pixel_1x1, 0, _cx, _cy, 1, 1, 0, _col, _dn);
		}
		surface_reset_target();
		gx_fog_seed = _sm.seed;
	}
	if (!surface_exists(wb_surf) || surface_get_width(wb_surf) != _vw || surface_get_height(wb_surf) != _vh) {
		if (surface_exists(wb_surf)) surface_free(wb_surf);
		wb_surf = page_surface(_vw, _vh);
	}
	surface_set_target(wb_surf);
	draw_clear_alpha(c_black, 1);
	draw_set_alpha(1);
	// the parallax backdrop: wrapped tiles panning slower than the plane
	for (var _l = 0; _l < array_length(gx_para); _l++) {
		var _pl = gx_para[_l];
		var _lz = lerp(1, gx_zoom, _pl.f);
		var _twz = _pl.tw * _lz, _thz = _pl.th * _lz;
		var _ox = gx_x * _pl.f * _lz, _oy = gx_y * _pl.f * _lz;
		var _sx0 = (_twz - _vw) * .5, _sy0 = (_thz - _vh) * .5;
		for (var _i = 0; _i < array_length(_pl.stars); _i++) {
			var _ps = _pl.stars[_i];
			var _px = (_ps.x * _lz - _ox) mod _twz; if (_px < 0) _px += _twz;
			var _py = (_ps.y * _lz - _oy) mod _thz; if (_py < 0) _py += _thz;
			draw_sprite_ext(spr_pixel_1x1, 0, _px - _sx0, _py - _sy0, _lz, _lz, 0, _ps.col, _ps.a);
		}
	}
	// the stars, with their depth parallax about the view's centre
	var _vcx = gx_x + _vw * .5 / gx_zoom, _vcy = gx_y + _vh * .5 / gx_zoom;
	var _vis = star_visible(gx_x, gx_y, gx_zoom, _vw, _vh);
	var _m = 12 * gx_zoom + 4;
	for (var _i = 0; _i < array_length(_vis); _i++) {
		var _st = _sm.stars[_vis[_i]];
		var _sx = ((_vcx + (_st.x - _vcx) * _st.d) - gx_x) * gx_zoom;
		var _sy = ((_vcy + (_st.y - _vcy) * _st.d) - gx_y) * gx_zoom;
		if (_sx < -_m || _sx > _vw + _m || _sy < -_m || _sy > _vh + _m) continue;
		var _s = _st.props.size * gx_zoom;
		draw_sprite_ext(spr_pixel_1x1, 0, _sx - _s * .5, _sy - _s * .5, _s, _s, 0, _st.props.color, 1);
	}
	// the fog, additive over the stars (the demo's order), bilinear; dithered
	// here only on an 8-bit page (a float page dithers once, at its blit)
	var _fd = _gcf.fog_depth;
	var _ffx = (_vcx * (1 - _fd) - gx_x) * gx_zoom, _ffy = (_vcy * (1 - _fd) - gx_y) * gx_zoom;
	var _ffs = _fd * gx_zoom * _sm.width / surface_get_width(gx_fog);
	var _ftf = gpu_get_tex_filter();
	gpu_set_tex_filter(true);
	gpu_set_blendmode(bm_add);
	if (!page_float()) { shader_set(sh_fog_dither); shader_set_uniform_f(shader_get_uniform(sh_fog_dither, "u_time"), (current_time mod 100000) / 1000); }
	draw_surface_ext(gx_fog, _ffx, _ffy, _ffs, _ffs, 0, c_white, _gcf.fog_alpha);
	if (!page_float()) shader_reset();
	gpu_set_blendmode(bm_normal);
	gpu_set_tex_filter(_ftf);
	// the home star: a pulsing hollow square and its name; the tapped star: a white one
	draw_set_font(fnt); draw_set_halign(fa_left); draw_set_valign(fa_top);
	var _marks = [ { i : _hm.star, col : c_gold, txt : star_name(_hm.star) + "  -  you are here" } ];
	if (gx_sel >= 0 && gx_sel != _hm.star) array_push(_marks, { i : gx_sel, col : c_white, txt : star_name(gx_sel) + "  -  class " + _sm.stars[gx_sel].props.stellar_class + (is_struct(gx_sys) ? ("  -  " + string(array_length(gx_sys.planets)) + " worlds") : "") });
	for (var _k = 0; _k < array_length(_marks); _k++) {
		var _mk = _marks[_k];
		var _st = _sm.stars[_mk.i];
		var _sx = ((_vcx + (_st.x - _vcx) * _st.d) - gx_x) * gx_zoom;
		var _sy = ((_vcy + (_st.y - _vcy) * _st.d) - gx_y) * gx_zoom;
		var _ms = 8 + ((_mk.i == _hm.star) ? floor(1.5 + 1.5 * dsin(current_time * .25)) * 2 : 0);
		draw_px_rect(floor(_sx - _ms * .5), floor(_sy - _ms * .5), _ms, _ms, _mk.col, .95);
		draw_set_color(_mk.col); draw_set_alpha(.95);
		draw_text(floor(_sx) + _ms * .5 + 4, floor(_sy) - 4, _mk.txt);
	}
	draw_set_alpha(1);
	surface_reset_target();
	// THE MINIMAP (the demo's, his ask): the whole galaxy as dots baked once,
	// the view's rectangle over it, the home star gold; tap it to jump
	var _mmr = __gx_mm_r();
	if (!surface_exists(gx_mm) || gx_mm_seed != _sm.seed) {
		if (surface_exists(gx_mm)) surface_free(gx_mm);
		gx_mm = surface_create(_mmr.w, _mmr.h);
		surface_set_target(gx_mm);
		draw_clear_alpha(c_black, 0);
		var _msc = _mmr.w / _sm.width;
		for (var _i = 0; _i < _sm.count; _i++) {
			var _st = _sm.stars[_i];
			draw_sprite_ext(spr_pixel_1x1, 0, floor(_st.x * _msc), floor(_st.y * _msc), 1, 1, 0, _st.props.color, .22 + .3 * clamp(_st.props.size / 4, 0, 1));
		}
		surface_reset_target();
		gx_mm_seed = _sm.seed;
	}
	ui_fade_set(_fa);
	// THE GLOW (his memory of the demo's glow layer, as a shader: sh_blur -
	// the finished map at half size, two passes, laid back additively) -
	// into the page on a float page, then the page to the screen through
	// the one dither; on an 8-bit page the glow lands on the screen after
	if (page_float()) { __bloom(wb_surf, _vw, _vh, _gr.x, _gr.y, .75); page_blit(wb_surf, _gr.x, _gr.y); }
	else { page_blit(wb_surf, _gr.x, _gr.y); __bloom(wb_surf, _vw, _vh, _gr.x, _gr.y, .75); }
	ui_fade_set(_ea);
	draw_sprite_ext(spr_pixel_1x1, 0, _mmr.x - 1, _mmr.y - 1, _mmr.w + 2, _mmr.h + 2, 0, c_black, .7);
	draw_surface(gx_mm, _mmr.x, _mmr.y);
	draw_px_rect(_mmr.x - 1, _mmr.y - 1, _mmr.w + 2, _mmr.h + 2, c_steelblue, .5);
	var _msc2 = _mmr.w / _sm.width;
	var _vx0 = _mmr.x + gx_x * _msc2, _vy0 = _mmr.y + gx_y * _msc2, _vw0 = max(2, _vw / gx_zoom * _msc2), _vh0 = max(2, _vh / gx_zoom * _msc2);
	draw_px_rect(floor(_vx0), floor(_vy0), ceil(_vw0), ceil(_vh0), c_white, .7);
	var _hst = _sm.stars[_hm.star];
	draw_sprite_ext(spr_pixel_1x1, 0, floor(_mmr.x + _hst.x * _msc2) - 1, floor(_mmr.y + _hst.y * _msc2) - 1, 2, 2, 0, c_gold, 1);
	// the title
	draw_set_color(c_white); draw_set_alpha(.95);
	draw_text(land ? 14 : 4, list_y + 6, _sm.name);
	draw_set_color(_dim); draw_set_alpha(.7);
	draw_text((land ? 14 : 4) + string_width(_sm.name) + 10, list_y + 6, string(_sm.count) + " stars  -  " + _sm.regions[_sm.stars[_hm.star].props.region].name + "  -  x" + string_format(gx_zoom, 1, 2));
	draw_set_alpha(.5);
	draw_text(land ? 14 : 4, list_y + 20, "drag to pan  -  wheel to zoom  -  tap a star");
	__draw_back();
	ui_fade_set(1);
	exit;
}

// (the region window is gone - the planet page's region mode, 2026-09-15)

// ======================= THE DEPARTURE: the crew, the brief, [depart] =======================
if (view == "depart") {
	var _d = pl_dest;
	var _rg = region_get(_d, rg_sel);
	var _q  = (dp_mode == "quest") ? dp_quest : undefined;                          // the quest picked
	var _xc = (dp_mode == "explore" && is_struct(dp_quest)) ? dp_quest : undefined;  // ...or the explore card (2026-09-15)
	var _oL = -(1 - dp_in) * 200;   // the swing: the list from the left, the box from the right
	var _ns = exped_party_max();
	if (array_length(dp_slots) != _ns) { var _old2 = dp_slots; dp_slots = array_create(_ns, -1); for (var _k = 0; _k < min(array_length(_old2), _ns); _k++) dp_slots[_k] = _old2[_k]; }
	draw_set_color(c_white); draw_set_alpha(.95);
	draw_text((land ? 14 : 4) + _oL, list_y + 6, (dp_mode == "explore") ? ((is_struct(_xc) ? (_xc.name + "  -  ") : "explore ") + _rg.name) : ("the quest  -  " + _rg.name));
	// THE CREW as banners in a list: tap one for its sheet, [+] to seat it;
	// a seated one leaves a grey ghost here until it is home again
	var _dl = __dp_list_r();
	draw_set_color(_ink); draw_set_alpha(.6);
	draw_text(_dl.x, list_y + 22, "the crew  -  tap for the sheet, [+] to seat" + ((__dp_off_max() > 0) ? "  -  scrolls" : ""));
	var _crew = [];
	var _np = 0;
	for (var _j = 0; _j < _ns; _j++) if (dp_slots[_j] >= 0 && !is_undefined(__sp_by_id(dp_slots[_j]))) { array_push(_crew, __sp_by_id(dp_slots[_j])); _np++; }
	var _fly = [];   // banners in flight: drawn last, over everything
	for (var _k = 0; _k < array_length(g.sprites); _k++) {
		if (!__dp_row_in(_k)) continue;
		var _sp = g.sprites[_k];
		var _rr = __dp_row_r(_k);
		var _seated = (__dp_seat_of(_sp.id) >= 0);
		var _away = (_sp[$ "trip"] ?? false);
		var _ps = dp_pos[$ string(_sp.id)];
		var _home = is_struct(_ps) && point_distance(_ps.x, _ps.y, _rr.x, _rr.y) < 1;
		// the ghost stays until the banner is HOME (his report: the row lost it while the banner flew)
		if (_seated || !_home) __dp_banner(_sp, _rr.x, _rr.y, _rr.w, 1, true);
		if (!_seated && is_struct(_ps)) { if (_home) __dp_banner(_sp, _rr.x, _rr.y, _rr.w, _away ? .45 : 1, false); else array_push(_fly, _sp); }
		if (!_seated) {
			var _pr = __dp_plus_r(_k);
			var _can = !_away && (_np < _ns);
			draw_sprite_ext(spr_pixel_1x1, 0, _pr.x, _pr.y, _pr.w, _pr.h, 0, c_black, .8);
			draw_px_rect(_pr.x, _pr.y, _pr.w, _pr.h, _can ? c_sgreen : _dim, _can ? .7 : .25);
			draw_set_halign(fa_center); draw_set_color(_can ? c_sgreen : _dim); draw_set_alpha(_can ? .95 : .35);
			draw_text(_pr.x + _pr.w * .5, _pr.y + 3, "+");
			draw_set_halign(fa_left);
		}
	}
	// THE MISSION BOX: the text, the numbers, then the seats inside it
	var _lay = __dp_layout();
	var _br2 = { x : _lay.x, y : _lay.y, w : _lay.w, h : _lay.h };
	draw_sprite_ext(spr_pixel_1x1, 0, _br2.x, _br2.y, _br2.w, _br2.h, 0, c_black, .7);
	draw_px_rect(_br2.x, _br2.y, _br2.w, _br2.h, (dp_mode == "explore") ? c_horange : c_gold, .5);
	var _tx = _br2.x + 8, _ty = _br2.y + 6, _tw = _lay.tw;
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
		var _xt = is_struct(_xc) ? _xc.txt : ("wander " + _rg.name + " until recalled");
		draw_text_ext(_tx, _ty, _xt, 9, _tw);
		_ty += string_height_ext(_xt, 9, _tw) + 4;
		draw_set_color(_dim); draw_set_alpha(.75);
		var _obj2 = is_struct(_xc) ? _xc.note : "they pick their own way: inns when hurt and there is coin, shops, taverns (drink, bar fights, bounties), dungeons, camps, the wild. [recall] on the trip's page brings them home";
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
		draw_set_halign(fa_right); draw_set_color(_dc[clamp(_q.diff, 0, 3)]); draw_text(_tx + _tw, _ty, _q.diff_txt + "  -  " + string(sprite_xp_quest(_q[$ "lv"] ?? _rg.lv, 1, _q.mult)) + " xp, " + string(_q.reward) + " credits"); draw_set_halign(fa_left);
		_ty += 11;
	}
	draw_set_color(_ink); draw_set_alpha(.8);
	draw_text(_tx, _ty, "time");
	var _eta = exped_eta(_d, is_struct(_xc) ? _xc : _q);
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
	if (_od.p < 0) { draw_set_color(_dim); draw_text(_tx + _tw, _ty, "seat a crew"); }
	else {
		var _pc = round(_od.p * 100);
		draw_set_color((_pc >= 70) ? c_sgreen : ((_pc >= 40) ? c_gold : c_hred));
		draw_text(_tx + _tw, _ty, "about " + string(_pc) + "%  (" + string(round(_od.fights)) + ((_od.fights == 1) ? " fight" : " fights") + " expected)");
	}
	draw_set_halign(fa_left);
	// THE SEATS, inside the box: a [+] while empty, the banner when taken, a [-] beside it
	draw_set_color(_dim); draw_set_alpha(.5);
	draw_text(_tx, _lay.seat_y0 - 12, "the party  -  " + string(_np) + " of " + string(_ns));
	for (var _j = 0; _j < _ns; _j++) {
		var _sr = __dp_seat_r(_j);
		var _sid = dp_slots[_j];
		var _ssp = (_sid >= 0) ? __sp_by_id(_sid) : undefined;
		draw_sprite_ext(spr_pixel_1x1, 0, _sr.x, _sr.y, _sr.w, _sr.h, 0, c_black, .6);
		draw_px_rect(_sr.x, _sr.y, _sr.w, _sr.h, _dim, .35);
		if (is_undefined(_ssp)) {
			draw_set_halign(fa_center); draw_set_color(_dim); draw_set_alpha(.5);
			draw_text(_sr.x + _sr.w * .5, _sr.y + 7, "+");
			draw_set_halign(fa_left);
		} else {
			var _ps2 = dp_pos[$ string(_sid)];
			var _home2 = is_struct(_ps2) && point_distance(_ps2.x, _ps2.y, _sr.x, _sr.y) < 1;
			if (_home2) __dp_banner(_ssp, _sr.x, _sr.y, _sr.w, 1, false); else array_push(_fly, _ssp);
			var _mr2 = __dp_minus_r(_j);
			draw_sprite_ext(spr_pixel_1x1, 0, _mr2.x, _mr2.y, _mr2.w, _mr2.h, 0, c_black, .8);
			draw_px_rect(_mr2.x, _mr2.y, _mr2.w, _mr2.h, c_hred, .7);
			draw_set_halign(fa_center); draw_set_color(c_hred); draw_set_alpha(.95);
			draw_text(_mr2.x + _mr2.w * .5, _mr2.y + 3, "-");
			draw_set_halign(fa_left);
		}
	}
	// [depart]
	var _dr = __depart_r();
	var _can = (_np > 0 && _have >= _cost.total);
	draw_ui_button(_dr.x, _dr.y, _dr.w, _dr.h, (_np == 0) ? "seat a crew" : ((_have < _cost.total) ? "short of credits" : "depart"), _can ? c_sgreen : c_gray, true, _can);
	// the banners in flight, over everything
	for (var _f = 0; _f < array_length(_fly); _f++) {
		var _fsp = _fly[_f], _fps = dp_pos[$ string(_fsp.id)];
		if (is_struct(_fps)) { draw_sprite_ext(spr_pixel_1x1, 0, _fps.x + 2, _fps.y + 3, __dp_bw(), __dp_bh(), 0, c_black, .5); __dp_banner(_fsp, _fps.x, _fps.y, __dp_bw(), 1, false); }
	}
	// THE SHEET AS A MODAL (a tap on a banner): the crew page's own painter
	// under a dim veil; a press off it closes it
	var _msp = __sp_by_id(dp_sheet);
	if (!is_undefined(_msp)) {
		var _msr = __dp_sheet_r();
		draw_sprite_ext(spr_pixel_1x1, 0, 0, list_y, room_width, room_height - list_y, 0, c_black, .7);
		it_rects = [];
		__draw_sheet(_msp, _msr.x, _msr.y, _msr.x + _msr.w);
	}
	ui_fade_set(1);
	exit;
}

// ======================= THE HUB (redone 2026-09-15: "make it nicer") =======================
// THE WORLD CARD: the world big, its name, its kind and level, then its
// regions as rows, the flight and who is out at the foot. Tap = its page
draw_set_color(_ink);
draw_set_alpha(.6);
draw_text(card_x0, card_y - 10, "the world  -  tap it");
for (var _i = 0; _i < array_length(_e.board); _i++) {
	var _d = _e.board[_i];
	var _b = exped_biomes()[_d.biome];
	var _c = __card_r(_i);
	var _wc = exped_world_col(_d);
	var _out = 0;
	for (var _t = 0; _t < array_length(_e.trips); _t++) if (_e.trips[_t].dest.seed == _d.seed) _out++;
	draw_sprite_ext(spr_pixel_1x1, 0, _c.x, _c.y, _c.w, _c.h, 0, c_black, .85);
	draw_px_rect(_c.x, _c.y, _c.w, _c.h, _wc, .35);
	draw_sprite_ext(spr_pixel_1x1, 0, _c.x, _c.y, 2, _c.h, 0, _wc, .9);
	// the world, big, at the top; its name under it
	var _pr = land ? 26 : 22;
	ui_fade_set(1);
	__world_small(_d, _c.x + _c.w * .5, _c.y + 8 + _pr, _pr);
	ui_fade_set(_ea);
	draw_set_halign(fa_center);
	draw_set_font(fnt_large);
	draw_set_color(_wc); draw_set_alpha(.95);
	draw_text(_c.x + _c.w * .5, _c.y + 8 + _pr * 2 + 6, str_cap(_d.name));
	draw_set_font(fnt);
	draw_set_color(merge_colour(_b.col2, c_white, .3)); draw_set_alpha(.85);
	draw_text(_c.x + _c.w * .5, _c.y + 8 + _pr * 2 + 20, _b.name + " world  -  lv " + string(exped_world_lv(_d)));
	draw_set_halign(fa_left);
	var _ry = _c.y + 8 + _pr * 2 + 34;
	draw_sprite_ext(spr_pixel_1x1, 0, _c.x + 8, _ry, _c.w - 16, 1, 0, _ink, .25);
	_ry += 6;
	// the regions: a row each - the name, the level in its colour, the mood under
	draw_set_color(_ink); draw_set_alpha(.5);
	draw_text(_c.x + 8, _ry, "regions");
	_ry += 11;
	var _lvc = [c_sgreen, c_gold, c_hred];
	for (var _ri = 0; _ri < EXPED_REGIONS; _ri++) {
		if (_ry + 10 > _c.y + _c.h - 24) break;
		var _rg = region_get(_d, _ri);
		var _rout = 0;
		for (var _t = 0; _t < array_length(_e.trips); _t++) if (_e.trips[_t].dest.seed == _d.seed && (_e.trips[_t][$ "rgi"] ?? 0) == _ri) _rout++;
		draw_set_color(c_white); draw_set_alpha(.9);
		draw_text(_c.x + 8, _ry, string_copy(str_cap(_rg.name), 1, land ? 18 : 16));
		draw_set_halign(fa_right);
		draw_set_color(_lvc[clamp(_ri, 0, 2)]); draw_set_alpha(.9);
		draw_text(_c.x + _c.w - 8, _ry, "lv " + string(_rg.lv));
		draw_set_halign(fa_left);
		draw_set_color(_dim); draw_set_alpha(.6);
		draw_text(_c.x + 8, _ry + 9, (_rg[$ "mood"] ?? "quiet") + ((_rout > 0) ? ("  -  " + string(_rout) + " out") : ""));
		_ry += 20;
	}
	// the foot: the flight, and who is out
	draw_set_color(_dim); draw_set_alpha(.6);
	draw_text(_c.x + 8, _c.y + _c.h - 12, crunch_time_long(_d.dist * EXPED_TRAVEL * 60 / max(1, _e.spd)) + " flight");
	if (_out > 0) { draw_set_halign(fa_right); draw_set_color(c_steelblue); draw_set_alpha(.9); draw_text(_c.x + _c.w - 8, _c.y + _c.h - 12, string(_out) + " out"); draw_set_halign(fa_left); }
}
// [crew]: the roster; [galaxy]: the star map
if (array_length(g.sprites) > 0) {
	var _shr = __crewbtn_r();
	draw_ui_button(_shr.x, _shr.y, _shr.w, _shr.h, "crew", c_steelblue, true, false);
}
var _hgl = __hub_gal_r();
draw_ui_button(_hgl.x, _hgl.y, _hgl.w, _hgl.h, "galaxy", c_steelblue, true, false);

// THE LIST: hauls waiting, then trips out - an island each
var _ly0 = __list_y0();
var _nh = array_length(_e.hauls), _nt = array_length(_e.trips);
draw_set_color(_ink); draw_set_alpha(.6);
draw_text(list_x, _ly0 + 2, "expeditions");
if (_nh + _nt > 0) {
	draw_set_color(_dim); draw_set_alpha(.6);
	draw_text(list_x + string_width("expeditions") + 8, _ly0 + 2, ((_nt > 0) ? (string(_nt) + " out") : "") + ((_nt > 0 && _nh > 0) ? ", " : "") + ((_nh > 0) ? (string(_nh) + " home") : ""));
}
var _rows = _nh + _nt;
if (_rows == 0) {
	var _er = __row_r(0);
	draw_sprite_ext(spr_pixel_1x1, 0, _er.x, _er.y, _er.w, 16, 0, c_black, .5);
	draw_sprite_ext(spr_pixel_1x1, 0, _er.x, _er.y, 2, 16, 0, _dim, .5);
	draw_set_color(_dim); draw_set_alpha(.6);
	draw_text(_er.x + 8, _er.y + 4, "nothing out  -  tap the world, pick a region, a quest, a crew");
}
for (var _i = 0; _i < _rows; _i++) {
	var _rr = __row_r(_i);
	if (_rr.y + _rr.h > room_height - 4) break;
	var _ish = (_i < _nh);
	var _r  = _ish ? _e.hauls[_i] : _e.trips[_i - _nh];
	var _rg2 = region_get(_r.dest, _r[$ "rgi"] ?? 0);
	var _fight = (!_ish && !is_undefined(_r.fight));
	var _acc = _ish ? (_r.routed ? c_horange : c_gold) : (_fight ? c_hred : c_steelblue);
	draw_sprite_ext(spr_pixel_1x1, 0, _rr.x, _rr.y, _rr.w, _rr.h, 0, c_black, .8);
	draw_px_rect(_rr.x, _rr.y, _rr.w, _rr.h, _acc, .25);
	draw_sprite_ext(spr_pixel_1x1, 0, _rr.x, _rr.y, 2, _rr.h, 0, _acc, .9);
	// the world, facing the region
	ui_fade_set(1);
	__world_small(_r.dest, _rr.x + 20, _rr.y + _rr.h * .5, 12, _rg2);
	ui_fade_set(_ea);
	var _tx = _rr.x + 40, _tw = _rr.w - 48;
	// line one: the crew's dots and names; the state on the right
	for (var _k = 0; _k < array_length(_r.sids); _k++) __dot(_tx + 3 + _k * 8, _rr.y + 8, 3, _r.cols[_k], (_ish || _r.hp[_k] > 0) ? .95 : .3);
	draw_set_color(c_white); draw_set_alpha(.95);
	var _crn = str_cap(exped_crew_txt(_r.names));
	draw_text(_tx + array_length(_r.sids) * 8 + 4, _rr.y + 4, string_copy(_crn, 1, land ? 30 : 20));
	draw_set_halign(fa_right);
	if (_ish) { draw_set_color(_acc); draw_set_alpha(.95); draw_text(_rr.x + _rr.w - 6, _rr.y + 4, _r.routed ? "limped home" : "home"); }
	else {
		var _mode = ((_r[$ "mode"] ?? "quest") == "explore") ? ((is_struct(_r[$ "ex"]) && _r.ex.kind == "ramble") ? "roaming" : ((is_struct(_r[$ "ex"]) && _r.ex.kind == "survey") ? "surveying" : "exploring")) : "on a quest";
		draw_set_color(_fight ? c_hred : _dim); draw_set_alpha(.85);
		draw_text(_rr.x + _rr.w - 6, _rr.y + 4, _fight ? "in a fight" : _mode);
	}
	draw_set_halign(fa_left);
	// line two: the world (its colour) / the region
	draw_set_color(exped_world_col(_r.dest)); draw_set_alpha(.95);
	draw_text(_tx, _rr.y + 14, _r.dest.name);
	draw_set_color(_dim); draw_set_alpha(.7);
	draw_text(_tx + string_width(_r.dest.name), _rr.y + 14, "  /  " + _rg2.name);
	if (_ish) {
		// a haul: its finds, and the ask
		var _nf = array_length(_r.finds);
		draw_set_color(_acc); draw_set_alpha(.9);
		draw_text(_tx, _rr.y + 25, string(_r[$ "wins"] ?? 0) + ((_r[$ "wins"] ?? 0) == 1 ? " fight won" : " fights won") + "  -  " + string(_nf) + ((_nf == 1) ? " find" : " finds"));
		draw_set_color(c_gold); draw_set_alpha(.7 + .25 * _br);
		draw_text(_tx, _rr.y + 34, "tap to collect the haul");
	} else {
		// line three: the leg, as a labelled bar; line four: where they are
		var _leg = (_r.stage == 0) ? "flying out" : ((_r.stage == 2) ? "flying home" : "on the world");
		var _tf = 0;
		if (_r.stage == 0) _tf = clamp(_r.t / max(1, _r.dur * EXPED_TRAVEL), 0, 1);
		else if (_r.stage == 2) _tf = clamp((_r.t - (_r[$ "leave_t"] ?? _r.t)) / max(1, _r.dur * EXPED_RETURN), 0, 1);
		else if (is_struct(_r[$ "road"])) _tf = clamp(_r.road.t / max(1, _r.road.d * EXPED_HOUR), 0, 1);
		draw_set_color(_dim); draw_set_alpha(.7);
		draw_text(_tx, _rr.y + 25, _leg);
		var _bx = _tx + 54, _bw = _tw - 54;
		draw_sprite_ext(spr_pixel_1x1, 0, _bx, _rr.y + 27, _bw, 4, 0, c_black, .7);
		draw_sprite_ext(spr_pixel_1x1, 0, _bx, _rr.y + 27, _bw * _tf, 4, 0, _acc, .9);
		draw_px_rect(_bx, _rr.y + 27, _bw, 4, c_white, .1);
		draw_set_color(_dim); draw_set_alpha(.6);
		draw_text(_tx, _rr.y + 34, string_copy(exped_where(_r), 1, land ? 48 : 30));
	}
}
ui_fade_set(1);
draw_set_alpha(1);   // (the last row's .8 must not leak into the next draw - bug hunt, 2026-09-14)
