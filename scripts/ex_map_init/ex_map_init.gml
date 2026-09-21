/// @description ex_map_init() - THE REGION MAP of syst_exped_panel: its rectangles, the nodes' placement, the roads, the labels, the icons, a place's card, the legend - and the planet page's INFO BOX and WORLD BOX, the crew's banner rows; defined on the panel (self = the panel; called from its Create). q221, the deconvolution
function ex_map_init() {
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
	var _rgc = region_col(_d, _rg[$ "ri"] ?? 0);   // (the region's own colour on its box - q296)
	draw_sprite_ext(spr_pixel_1x1, 0, _bn.x, _bn.y, 2, _bn.h, 0, _rgc, .95);
	draw_set_font(fnt_large); draw_set_color(_rgc); draw_set_alpha(.95);
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
__map_node_card = function(_d, _rg, _mr, _ni, _at = undefined) {   // (at: the place's screen point when the card is the WORLD's - q303; else the map's frame places it)
	var _nd = _rg.nodes[_ni], _kk = region_kinds(), _kd = _kk[$ _nd.kind] ?? _kk.field, _e = g.exped;
	var _np = is_struct(_at) ? _at : __map_xy(_nd, _rg, _mr);
	var _cw = 168, _iw = _cw - 12;
	var _pp = region_node_info(_d, _rg, _ni);
	var _rows = [], _lpp = region_pop(_d, _rg, _ni);   // (the population LIVE - the card's row is the baseline; q284)
	for (var _ri = 0; _ri < array_length(_pp.rows); _ri++) {
		if (_pp.rows[_ri].k == "population" && is_struct(_lpp)) { var _pw = pop_word(_lpp); array_push(_rows, { k : "population", v : _pw.txt, col : _pw.col }); continue; }
		array_push(_rows, _pp.rows[_ri]);
	}
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
	for (var _mi = 0; _mi < array_length(_mks); _mi++) { var _mm = exped_mem_get(_d, _rg[$ "ri"] ?? map_rgi, _ni, _mks[_mi][0]); if (is_struct(_mm)) array_push(_rows, { k : "memory", v : _mks[_mi][1] + string(ceil(_mm.left / EXPED_HOUR)) + "h", col : c_gold }); }
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
__map_icon = function(_kind, _lz, _x, _y, _col, _am = 1) {   // (am: an alpha over the icon's own - the world's dim regions, q303)
	if (_lz) {
		// the flag: a pole and a pennant, white
		draw_sprite_ext(spr_pixel_1x1, 0, _x - 3, _y - 7, 1, 10, 0, c_white, .95 * _am);
		draw_sprite_ext(spr_pixel_1x1, 0, _x - 2, _y - 7, 5, 2, 0, c_white, .95 * _am);
		draw_sprite_ext(spr_pixel_1x1, 0, _x - 2, _y - 5, 3, 1, 0, c_white, .95 * _am);
		return;
	}
	switch (_kind) {
		case "pass": {
			// the gate (q291): two posts and a bar
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 3, _y - 3, 1, 6, 0, _col, .95 * _am);
			draw_sprite_ext(spr_pixel_1x1, 0, _x + 2, _y - 3, 1, 6, 0, _col, .95 * _am);
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 3, _y - 4, 6, 1, 0, _col, .95 * _am);
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 1, _y - 1, 2, 1, 0, _col, .6 * _am);
			break;
		}
		case "settlement": case "village": case "town": case "city": {
			// the house: a roof stepping in, a body, a door
			var _big = (_kind == "town" || _kind == "city") ? 1 : 0;
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 4 - _big, _y - 1, 8 + _big * 2, 5 + _big, 0, _col, .95 * _am);
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 3 - _big, _y - 3, 6 + _big * 2, 2, 0, _col, .95 * _am);
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 1, _y - 5 - _big, 2, 2 + _big, 0, _col, .95 * _am);
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 1, _y + 2, 2, 2 + _big, 0, c_black, .8 * _am);
			if (_kind == "city") draw_sprite_ext(spr_pixel_1x1, 0, _x + 3, _y - 6, 2, 4, 0, _col, .95 * _am);
			return;
		}
		case "camp": {
			// the tent: rows widening down, a dark flap
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 1, _y - 5, 2, 2, 0, _col, .95 * _am);
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 2, _y - 3, 4, 2, 0, _col, .95 * _am);
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 3, _y - 1, 6, 2, 0, _col, .95 * _am);
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 4, _y + 1, 8, 2, 0, _col, .95 * _am);
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 1, _y, 2, 3, 0, c_black, .8 * _am);
			return;
		}
		case "dungeon": case "crypt": {
			// the doorway: a dark arch in a block
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 4, _y - 4, 8, 8, 0, _col, .95 * _am);
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 2, _y - 2, 4, 6, 0, c_black, .85 * _am);
			return;
		}
		case "sewer": {
			// the grate: a dark square with three bars (2026-09-16)
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 4, _y - 3, 8, 7, 0, c_black, .9 * _am);
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 4, _y - 3, 8, 1, 0, _col, .95 * _am);
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 4, _y + 3, 8, 1, 0, _col, .95 * _am);
			for (var _gb = -3; _gb <= 3; _gb += 3) draw_sprite_ext(spr_pixel_1x1, 0, _x + _gb - 1, _y - 2, 1, 5, 0, _col, .95 * _am);
			return;
		}
	}
	__dot(_x, _y, 2, _col, .95 * _am);
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
}
