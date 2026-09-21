/// @description ex_map_draw(_e, _br, _ink, _dim) -> true when the page is drawn: THE REGION MAP page (syst_exped_panel's Draw, q220; self = the panel; e = g.exped, br the breath, ink / dim the colours)
function ex_map_draw(_e, _br, _ink, _dim) {
	var _d  = map_dest;
	var _rg = region_get(_d, map_rgi);
	var _kk = region_kinds();
	if (land) __info_box_size(_d, _rg);   // (the box's width first: the map sits right of it)
	var _mr = __map_r();
	var _bb = exped_biomes()[_d.biome];
	// the names: every place but the minor biomes, and any place a crew has business at (2026-09-16)
	var _named = __map_named(_rg, _d), _nkey = "";
	for (var _i = 0; _i < array_length(_named); _i++) _nkey += _named[_i] ? "1" : "0";
	var _lkey = string(_rg.seed) + ":" + string(map_rgi) + ":" + string(_mr.w) + "x" + string(_mr.h) + ":" + _nkey;
	var _lab = __map_labels(_rg, _mr, _lkey, _named);
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
	// THE REGION'S OWN GROUND (q288): the territory's cut of the world's terrain under the roads, in the frame the places
	// stand in (region_place's); a world without territories keeps the circle
	// (from the zoom tier when it stands - the page's world's, the keeper's; the map's own texels until then - q311)
	var _gpn = planet_get(_d.seed, exped_planet_hint(_d));
	var _gsh = region_map_sheet(_d, _rg, is_struct(_gpn) ? tiers.pick(_gpn, true) : undefined), _tmp = _rg[$ "tmap"];
	if (!is_undefined(_gsh) && surface_exists(_gsh) && is_struct(_tmp)) {
		var _msc = (min(_mr.w, _mr.h) * .5 - 10) / (_rg[$ "radius"] ?? .46), _mcx = _rg[$ "cx"] ?? .5, _mcy = _rg[$ "cy"] ?? .5;
		var _tk = _tmp[$ "k"] ?? .84, _mks = _rg[$ "mks"] ?? 1;
		var _txs = _tmp.cl / _tmp.span * _tk * _msc / _mks, _tys = 1 / _tmp.span * _tk * _msc / _mks;
		var _ulx = .5 + (_tmp.x0 * _tmp.cl - _tmp.cxm) / _tmp.span * _tk, _uly = .5 + (_tmp.y0 - _tmp.cym) / _tmp.span * _tk;
		var _gx0 = _mr.x + _mr.w * .5 + (_ulx - _mcx) * _msc, _gy0 = _mr.y + _mr.h * .5 + (_uly - _mcy) * _msc;
		draw_surface_ext(_gsh, _gx0, _gy0, _txs, _tys, 0, c_white, 1);
		draw_sprite_ext(spr_pixel_1x1, 0, _mr.x, _mr.y, _mr.w, _mr.h, 0, c_black, .06);   // (the faintest shade - the ground carries its own light now; q311)
	} else for (var _a = 0; _a < 360; _a += 6) draw_sprite_ext(spr_pixel_1x1, 0, floor(_ccx + lengthdir_x(_crad + 6, _a)), floor(_ccy + lengthdir_y(_crad + 6, _a)), 1, 1, 0, _bb.col2, .35);
	// THE PLOP (q289, his ask): the places fall into their spots from above when the map opens - a wave out from the centre
	// (the delay by the distance from it), each a fall (PLOP_DUR) from PLOP_LIFT above that lands with a little hop; a
	// road is drawn once both its ends are down, a name once its place has settled; a soft tick a landing
	var _pkey = string(_d.seed) + ":" + string(map_rgi);
	if (map_plop_key != _pkey) { map_plop_key = _pkey; map_plop_t0 = current_time; map_plop_n = 0; }
	var _pt = (current_time - map_plop_t0) / 1000, _pn = array_length(_rg.nodes);
	var _pu = array_create(_pn, 2), _poff = array_create(_pn, 0), _pal = array_create(_pn, 1), _landed = 0;
	for (var _i = 0; _i < _pn; _i++) {
		var _pdl = clamp(point_distance(_rg.nodes[_i].x, _rg.nodes[_i].y, _rg[$ "cx"] ?? .5, _rg[$ "cy"] ?? .5) / max(.01, _rg[$ "radius"] ?? .46), 0, 1.2) * PLOP_WAVE;
		var _u = (_pt - _pdl) / PLOP_DUR;
		if (_u < 0) { _pu[_i] = 0; _poff[_i] = -PLOP_LIFT; _pal[_i] = 0; continue; }
		if (_u < 1) { _pu[_i] = _u; _poff[_i] = -PLOP_LIFT * sqr(1 - _u); _pal[_i] = min(1, _u * 3); continue; }
		_landed++;
		if (_u < 1.4) { _pu[_i] = _u; _poff[_i] = -PLOP_HOP * sin(pi * (_u - 1) / .4); _pal[_i] = 1; continue; }
		_pu[_i] = 2; _poff[_i] = 0; _pal[_i] = 1;
	}
	if (_landed > map_plop_n) { play_sound_ext(snd_matclick2, .9 + .35 * (_landed / max(1, _pn)), 1.0 + .35 * (_landed / max(1, _pn)), .22, 0); map_plop_n = _landed; }
	// the roads: the bent lines, the hours at the middle point - each once both its ends are down
	for (var _ei = 0; _ei < array_length(_rg.edges); _ei++) {
		var _ed = _rg.edges[_ei];
		var _ra = clamp((min(_pu[_ed.a], _pu[_ed.b]) - 1) * 4 + 1, 0, 1);
		if (_ra <= 0) continue;
		var _pts = _ed[$ "pts"];
		if (!is_array(_pts) || array_length(_pts) < 2) _pts = [ _rg.nodes[_ed.a], _rg.nodes[_ed.b] ];
		var _boat = (_ed[$ "boat"] ?? false), _rsp = [];
		for (var _k = 0; _k < array_length(_pts); _k++) array_push(_rsp, __map_xy(_pts[_k], _rg, _mr));
		// (the world's ink - q311: a dark band under, the parchment line over; a boat dashed and blue)
		for (var _k = 1; _k < array_length(_rsp); _k++) { if (_boat && (_k mod 2 == 0)) continue; __px_band(_rsp[_k - 1].x, _rsp[_k - 1].y, _rsp[_k].x, _rsp[_k].y, c_black, .45 * _ra); }
		for (var _k = 1; _k < array_length(_rsp); _k++) { if (_boat && (_k mod 2 == 0)) continue; draw_px_line(_rsp[_k - 1].x, _rsp[_k - 1].y, _rsp[_k].x, _rsp[_k].y, _boat ? rgb(120, 190, 210) : rgb(236, 226, 200), (_boat ? .8 : .8) * _ra); }
		var _mid = region_road_point(_rg, _ed.a, _ed.b, .5);
		var _mp = __map_xy(_mid, _rg, _mr);
		draw_set_font(fnt_outline);
		draw_set_alpha(.7 * _ra); draw_set_color(_dim);
		draw_set_halign(fa_center);
		draw_text(_mp.x, _mp.y - 4, string(_ed.d) + "h");
		draw_set_font(fnt);
	}
	// the places: an icon by kind, the label where it fits
	draw_set_halign(fa_left);
	for (var _i = 0; _i < array_length(_rg.nodes); _i++) {
		var _nd = _rg.nodes[_i];
		var _kd = _kk[$ _nd.kind] ?? _kk.field;
		var _np = __map_xy(_nd, _rg, _mr);
		if (_pal[_i] <= 0) continue;   // (not fallen yet - q289)
		var _nx = floor(_np.x), _ny = floor(_np.y + _poff[_i]);   // (the fall's offset - q289)
		var _lz = (_nd[$ "landing"] ?? false);
		if (_lz && _nd.kind != "landing") __wm_icon(_nd.kind, false, _nx, _ny, _kd.col, _pal[_i]);   // (a settled place with the landing zone inside: the house, the flag ON it - the pole up the roof, his call 2026-09-16; outlined - q311)
		__wm_icon(_nd.kind, _lz, _nx + ((_lz && _nd.kind != "landing") ? 6 : 0), _ny - ((_lz && _nd.kind != "landing") ? 6 : 0), _lz ? c_white : _kd.col, _pal[_i]);
		if (!_named[_i]) continue;   // (a minor biome no crew is bound for: the dot alone)
		var _la = clamp((_pu[_i] - 1) * 3, 0, 1);   // (the name once the place has settled - q289)
		if (_la <= 0) continue;
		var _lp = is_undefined(_lab[_i]) ? { x : _nx + 7, y : _ny - 4 } : _lab[_i];
		draw_set_font(fnt_outline);   // (every name outlined over the ground - q311)
		if (_kd.wild) { draw_set_color(merge_colour(_kd.col, _dim, .3)); draw_set_alpha(.8 * _la); }
		else { draw_set_color(_lz ? c_white : _kd.col); draw_set_alpha(.95 * _la); }
		draw_text(floor(_lp.x), floor(_lp.y), _nd.name);
		draw_set_font(fnt);
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
		if (array_length(_pp) == 0 && _tr2.stage == 1 && is_struct(_tr2[$ "quest"]) && _tr2.quest.done < _tr2.quest.n && !(_tr2[$ "recall"] ?? false) && !(_tr2[$ "aborted"] ?? false)) { _pp = region_path(_rg, _from, exped_quest_target(_tr2.quest)); _hlal = .28; }
		for (var _k = 0; _k < array_length(_pp); _k++) {
			var _to = clamp(_pp[_k], 0, array_length(_rg.nodes) - 1);
			if (_to != _from) __map_road_hl(_rg, _mr, _from, _to, 0, _tc, _hlal);
			_from = _to;
		}
		// the objective: a pulsing square in the crew's colour
		if (_tr2.stage == 1 && is_struct(_tr2[$ "quest"]) && _tr2.quest.done < _tr2.quest.n) {
			var _qn = __map_xy(_rg.nodes[clamp(exped_quest_target(_tr2.quest), 0, array_length(_rg.nodes) - 1)], _rg, _mr);   // (the stop the crew heads for now)
			var _qs = 7 + floor(_br * 2);
			draw_px_rect(floor(_qn.x) - _qs, floor(_qn.y) - _qs, _qs * 2, _qs * 2, _tc, .5 + .4 * _br);
		}
		if (_tr2.stage != 1) { var _lzp = __map_xy(_rg.nodes[_rg.landing], _rg, _mr); _cx = _lzp.x - 12; _cy = _lzp.y; }
		for (var _k = 0; _k < array_length(_tr2.sids); _k++) __dot(_cx - 6 + _k * 6, _cy + 8, 3, _tr2.cols[_k], (_tr2.hp[_k] > 0) ? .95 : .3);
		draw_set_font(fnt_outline);
		draw_set_color(_tc); draw_set_alpha(.9);
		draw_text(_cx - 6, _cy + 12, exped_crew_txt(_tr2.names) + ": " + ((_tr2.stage == 1) ? exped_where(_tr2) : ((_tr2.stage == 0) ? "on the way" : "gone home")));
		draw_set_font(fnt);
	}
	// the place's card (tap a node), over the crews, under the legend
	if (!map_legend && map_pop >= 0 && map_pop < array_length(_rg.nodes)) __map_node_card(_d, _rg, _mr, map_pop);
	// [legend], and the note
	var _lgr = __legend_r();
	draw_ui_button(_lgr.x, _lgr.y, _lgr.w, _lgr.h, "legend", c_steelblue, true, false);
	draw_set_color(_dim); draw_set_alpha(.4);
	draw_set_halign(fa_right);
	draw_text(room_width - (land ? 14 : 4), _mr.y + _mr.h + 3, "roads: hours  -  routes: crew colours");   // (short: [legend] sits on the left of this row)
	draw_set_halign(fa_left);
	if (map_legend) {
		// THE LEGEND (his ask): every kind, its icon or dot, its name; two columns
		var _lgk = ["landing", "settlement", "village", "town", "city", "camp", "dungeon", "crypt", "sewer", "ruin", "shrine", "mine", "field", "forest", "hills", "marsh", "mountains", "desert", "tundra", "coast", "isle"];
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
	return true;
}
