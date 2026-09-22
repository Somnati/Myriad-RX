draw_set_font(fnt);
draw_set_halign(fa_left); draw_set_valign(fa_top);
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby - 2, room_width, room_height, 0, c_hsv(169, 186, 5), 1);
var _nm = stk_names(), _cfg = stk_config(), _l = s.tab, _lc = (_l < 3) ? _nm[_l].col : c_hred, _tide = stk_tide(universal_now()), _pw = .5 + .5 * sin(pulse * 4);
// the strip: the name, the spark, its pace, the cinders
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby, room_width, 16, 0, c_hsv(169, 186, 5), 1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby + 15, room_width, 1, 0, rgb(170, 190, 230), .25);
draw_set_color(c_gold); draw_set_alpha(.95); draw_text(6, bby + 4, "the stack");
draw_set_color(c_gold); draw_set_alpha(.95); draw_text(70, bby + 4, stk_num(s.spark) + " spark");
draw_set_color(sett_ink); draw_set_alpha(.7); draw_text(160, bby + 4, "+" + string_format(stk_spark_rate(s), 1, 2) + "/s");
draw_set_color(c_hred); draw_set_alpha(.85); draw_text(240, bby + 4, string(s.cinders) + " cinder" + ((s.cinders == 1) ? "" : "s") + ((s.turns > 0) ? ("  -  turn " + string(s.turns)) : ""));
var _bk = __back_r(); draw_ui_button(_bk.x, _bk.y, _bk.w, _bk.h, "back", rgb(170, 190, 230), true, false);
// THE TABS: the layers' pills (the open ones lit, a shut one says so, the flooded one breathes) + the cinder tree
for (var _t = 0; _t < 4; _t++) {
	var _tr = __tab_r(_t), _on = (_t == _l), _op = __open(_t), _tc = (_t < 3) ? _nm[_t].col : c_hred, _fl = (_t < 3 && _tide.layer == _t && _op);
	draw_sprite_ext(spr_pixel_1x1, 0, _tr.x, _tr.y, _tr.w, _tr.h, 0, _on ? _tc : c_black, _on ? .9 : .7);
	draw_px_rect(_tr.x, _tr.y, _tr.w, _tr.h, _tc, _fl ? (.5 + .5 * _pw) : (_op ? .9 : .3));
	draw_set_color(_on ? c_black : (_op ? _tc : c_gray)); draw_set_alpha(.95);
	var _lbl = (_t < 3) ? (_nm[_t].name + ((_t == 0) ? "" : (_op ? (" " + string(stk_cap(s, _t))) : " shut")) + (_fl ? " ~" : "")) : ("cinders " + string(s.cinders));
	draw_text(_tr.x + 5, _tr.y + 2, _lbl);
}
var _tip = "";
if (_l == 3) {
	// ================================================================ THE CINDER TREE
	draw_set_color(c_hred); draw_set_alpha(.95);
	draw_text(6, band_y + 2, string(s.cinders) + " held: every speed x" + string_format(1 + STK_CINDER_SPD * s.cinders, 1, 2) + ", spark x" + string_format(1 + STK_CINDER_SPK * s.cinders, 1, 2) + "   -   " + string(s.spent) + " spent on the tree");
	draw_set_color(sett_ink); draw_set_alpha(.55);
	draw_text(6, band_y + 12, "a spent cinder loses its passive - the tree costs the run's pace");
	var _pk = stk_perks();
	for (var _p = 0; _p < array_length(_pk); _p++) {
		var _r = __perk_r(_p), _d = _pk[_p], _rk = stk_perk(s, _d.key), _c = stk_perk_cost(s, _d.key), _b = __perk_b(_p);
		draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, _r.w, _r.h, 0, c_hsv(168, 140, 12), 1);
		draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, 2, _r.h, 0, (_rk > 0) ? c_hred : c_gray, .9);
		draw_set_color((_rk > 0) ? c_white : c_hred); draw_set_alpha(.95);
		draw_text(_r.x + 5, _r.y + 3, _d.name);
		draw_set_color(c_gold); draw_set_alpha(.9);
		draw_text(_r.x + 100, _r.y + 3, string(_rk) + "/" + string(_d.max));
		draw_set_color(sett_ink); draw_set_alpha(.7);
		draw_text(_r.x + 126, _r.y + 3, _d.what);
		draw_ui_button(_b.x, _b.y, _b.w, _b.h, (_c < 0) ? "at the top" : ("buy  " + string(_c)), c_hred, _c >= 0 && s.cinders >= _c, _c >= 0 && s.cinders >= _c);
		if (_tip == "" && __hit(_r)) {
			var _long = _d.what;
			switch (_d.key) {
				case "headstart": _long = "every run (and now) seats the well at lv 3 a rank - aether opens at once"; break;
				case "hand":      _long = "while you are away the catch-up re-runs [chase] on every open layer each ten minutes"; break;
				case "seventh":   _long = "a seventh sink opens on every layer: the siphon (energy feeds aether), the mirror (doubles down on aether's focus), the crucible (more cinders a turn)"; break;
				case "keep":      _long = "the turn keeps 10% of every level a rank instead of letting them all go"; break;
			}
			_tip = _d.name + ": " + _long + ((_c >= 0) ? ("; the next rank costs " + string(_c) + " cinders held") : "; at its top");
		}
	}
	var _tr2 = __turn_r(), _cin = stk_cinders(s), _canturn = (_cin >= 1 && stk_cap(s, 2) >= 1);
	draw_ui_button(_tr2.x, _tr2.y, _tr2.w, _tr2.h, _canturn ? ("the turn  +" + string(_cin) + " cinder" + ((_cin == 1) ? "" : "s")) : ((stk_cap(s, 2) < 1) ? "the turn: quintessence first" : ("the turn  +" + string(_cin))), c_hred, _canturn, _canturn);
	if (__hit(_tr2)) _tip = "THE TURN: spark, caps and levels let go for cinders - sqrt(levels; aether x3, quintessence x5) / 4, x the crucible; the keep holds a share, the veins move";
} else {
	// ================================================================ A LAYER
	var _sk = s.layers[_l].sinks, _ly = s.layers[_l], _cap = stk_cap(s, _l), _tot = 0, _n = rows_n;
	for (var _i = 0; _i < array_length(_sk); _i++) _tot += _sk[_i].alloc;
	draw_set_color(_lc); draw_set_alpha(.95);
	var _parts = [_nm[_l].name + " " + string(_tot) + "/" + string(_cap), "x" + string_format(stk_speed(s, _l), 1, 2)];
	if (_tide.layer == _l && _cap > 0) array_push(_parts, "flood x" + string_format(stk_tide_mult(s), 1, 1) + " " + __mmss(_tide.left));
	if (_ly.burn_t > 0) array_push(_parts, "burn +" + string(_ly.burn_add) + " " + __mmss(_ly.burn_t));
	if (_ly.focus >= 0) array_push(_parts, "focus: " + _cfg[_l][_ly.focus].name);
	draw_text(6, band_y + 2, __fit(_parts, __burn_r().x - 10));
	draw_sprite_ext(spr_pixel_1x1, 0, 6, band_y + 14, room_width - 12, 6, 0, c_black, .6);
	if (_cap > 0) {
		draw_sprite_ext(spr_pixel_1x1, 0, 6, band_y + 14, (room_width - 12) * clamp(_tot / _cap, 0, 1), 6, 0, _lc, .8);
		if (_ly.burn_t > 0) { var _bw = (room_width - 12) * _ly.burn_add / _cap; draw_px_rect(6 + (room_width - 12) - _bw, band_y + 14, _bw, 6, c_horange, .5 + .4 * _pw); }
	}
	if (flash > 0) draw_sprite_ext(spr_pixel_1x1, 0, 6, band_y + 14, room_width - 12, 6, 0, c_white, .5 * flash);
	if (_l == 0) { var _br = __buy_r(), _cc = stk_cap_cost(s); draw_ui_button(_br.x, _br.y, _br.w, _br.h, "cap +" + string(STK_CAP_STEP) + "  " + stk_num(_cc), c_gold, true, s.spark >= _cc); }
	var _bn = __burn_r(), _bc = stk_burn_cost(s);
	if (_ly.burn_t > 0) draw_ui_button(_bn.x, _bn.y, _bn.w, _bn.h, "burning " + __mmss(_ly.burn_t), c_horange, false, false);
	else draw_ui_button(_bn.x, _bn.y, _bn.w, _bn.h, (_l == 0) ? ("burn " + stk_num(_bc)) : ("burn +" + string(floor(_cap * STK_BURN_PCT)) + "  " + stk_num(_bc)), c_horange, _cap > 0, s.spark >= _bc && _cap > 0);
	// THE ROWS: the name (tap = focus; the stars; the vein), the level, the bonus, the bar, the eta, the cluster
	for (var _i = 0; _i < _n; _i++) {
		var _r = __row_r(_i), _k = _sk[_i], _c = _cfg[_l][_i], _foc = (_ly.focus == _i), _vn = (_ly.vein == _i || (_ly.vein2 == _i && stk_perk(s, "veins") > 0));
		draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, _r.w, _r.h, 0, _foc ? merge_colour(c_hsv(168, 140, 15), _c.col, .18) : c_hsv(168, 140, 12), 1);
		draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, 2, _r.h, 0, _vn ? c_gold : _c.col, .9);
		var _stars = "", _ms = [10, 25, 50, 100, 200];
		for (var _m = 0; _m < array_length(_ms); _m++) if (_k.level >= _ms[_m]) _stars += "*";
		// line one: the name (gold and breathing on a vein; white when focused) in the name column, the bonus in words at the bar's x
		draw_set_color(_vn ? merge_colour(c_gold, c_white, .3 * _pw) : (_foc ? c_white : _c.col)); draw_set_alpha(.95);
		draw_text(_r.x + 5, _r.y + 2, _c.name);
		draw_set_color(_foc ? c_white : sett_ink); draw_set_alpha(.8);
		draw_text(bar_x, _r.y + 2, __bonus_txt(_l, _i) + (_foc ? "   focus" : ""));
		// line two: the level (+ the stars) under the name, the bar beside it
		var _by = _r.y + row_h - 11;
		draw_set_color(sett_ink); draw_set_alpha(.75);
		draw_text(_r.x + 5, _by, "lv " + string(_k.level) + ((_stars != "") ? (" " + _stars) : ""));
		var _thr = stk_thr(s, _l, _i, _k.level), _fl = clamp(_k.prog / max(.0001, _thr), 0, 1);
		draw_sprite_ext(spr_pixel_1x1, 0, bar_x, _by, bar_w, 8, 0, c_black, .6);
		draw_sprite_ext(spr_pixel_1x1, 0, bar_x, _by, bar_w * _fl, 8, 0, _c.col, (_k.alloc > 0) ? .85 : .35);
		draw_px_rect(bar_x, _by, bar_w, 8, _c.col, .3);
		var _eta = stk_eta(s, _l, _i);
		draw_set_halign(fa_center); draw_set_color(c_white); draw_set_alpha(.8);
		draw_text(bar_x + bar_w * .5, _by, string(floor(_fl * 100)) + "%" + ((_eta >= 0) ? ("  " + ((_eta < 60) ? (string(ceil(_eta)) + "s") : ((_eta < 3600) ? (string(floor(_eta / 60)) + "m") : (string(floor(_eta / 3600)) + "h")))) : ""));
		draw_set_halign(fa_left);
		// the cluster
		var _bt = __btn(_i, bx_minus, 13);
		draw_ui_button(bx_minus, _bt.y, 13, 13, "-", _c.col, _k.alloc > 0, false);
		draw_set_halign(fa_center); draw_set_color(c_white); draw_set_alpha(.95); draw_text(bx_num + 15, _bt.y + 2, string(_k.alloc)); draw_set_halign(fa_left);
		draw_ui_button(bx_plus, _bt.y, 13, 13, "+", _c.col, _tot < _cap, false);
		draw_ui_button(bx_max, _bt.y, 30, 13, "max", _c.col, _tot < _cap, false);
		draw_ui_button(bx_clear, _bt.y, 18, 13, "0", _c.col, _k.alloc > 0, false);
		if (_tip == "" && __hit(_r)) {
			_tip = _c.name + ": " + _c.what + " - per " + string_format(stk_per(s, _l, _i), 1, 1) + "% a level^" + string(STK_BONUS_POW) + "; the next level needs " + stk_num(_thr) + " energy-seconds" + ((_stars != "") ? ("; " + string(string_length(_stars)) + " milestone" + ((string_length(_stars) == 1) ? "" : "s") + " (per x1.5 each)") : "") + (_vn ? "; A VEIN this run (per x2)" : "");
			if (_c.kind == "siphon") _tip = "siphon: its energy also feeds aether - energy speed x " + string(STK_SIPHON) + " x its bonus, split over aether's working sinks; it levels too";
			else if (_c.kind == "mirror") _tip = "mirror: multiplies the effect of aether's FOCUSED sink (speeds, spark, thresholds - not a well)" + ((_ly.focus < 0) ? "; nothing is focused" : "");
			else if (_c.kind == "cinders") _tip = "crucible: the turn gives x" + string_format(stk_bonus(s, 2, 6), 1, 2) + " cinders";
			else _tip += ". tap the name to focus it";
		}
	}
	// THE FOOT: the presets, the turn
	var _er = __even_r(), _hr = __chase_r(), _zr = __clear_r(), _tr2 = __turn_r();
	draw_ui_button(_er.x, _er.y, _er.w, _er.h, "even", _lc, _cap > 0, false);
	draw_ui_button(_hr.x, _hr.y, _hr.w, _hr.h, "chase", _lc, _cap > 0, false);
	draw_ui_button(_zr.x, _zr.y, _zr.w, _zr.h, "0", _lc, _tot > 0, false);
	var _cin = stk_cinders(s), _canturn = (_cin >= 1 && stk_cap(s, 2) >= 1);
	draw_ui_button(_tr2.x, _tr2.y, _tr2.w, _tr2.h, _canturn ? ("the turn  +" + string(_cin) + " cinder" + ((_cin == 1) ? "" : "s")) : ((stk_cap(s, 2) < 1) ? "the turn: quintessence first" : ("the turn  +" + string(_cin))), c_hred, _canturn, _canturn);
	if (__hit(_er)) _tip = "even: the cap spread over the open sinks"; else if (__hit(_hr)) _tip = "chase: all of it to the sink nearest its next level"; else if (__hit(_zr)) _tip = "every allocation of this layer back";
	else if (__hit(_tr2)) _tip = "THE TURN: spark, caps and levels let go for cinders - sqrt(levels; aether x3, quintessence x5) / 4; a cinder HELD is +6% every speed, +3% spark; the cinders tab spends them";
	else if (__hit(__buy_r()) && _l == 0) _tip = "energy's cap, +" + string(STK_CAP_STEP) + " a buy - the price doubles each; the ballast lowers it";
	else if (__hit(__burn_r())) _tip = (_ly.burn_t > 0) ? ("burning: +" + string(_ly.burn_add) + " cap for " + __mmss(_ly.burn_t) + " more; when it dies the overflow drains back") : ("BURN: " + string(STK_BURN_PRICE * 100) + "% of the next cap buy's spark lifts this cap +" + string(STK_BURN_PCT * 100) + "% for " + __mmss(STK_BURN_LEN * (1 + .5 * stk_perk(s, "burn"))) + " - a permanent +4 or a temporary +half");
	else if (_tide.layer == _l && _cap > 0 && __hit({ x : 6, y : band_y, w : room_width - 12, h : 12 })) _tip = "THE TIDE: a flood walks the layers on the clock, " + string(STK_TIDE_LEN / 60) + " min each - the flooded layer runs x" + string_format(stk_tide_mult(s), 1, 1) + "; feed it while it lasts";
}
draw_set_color((note_t > 0) ? c_white : c_gray); draw_set_alpha(.8);
var _foot = (note_t > 0) ? note : ((_tip != "") ? _tip : (tut ? "first words: put energy in the generator - it levels on energy-seconds and makes spark; spark buys cap. the well's level IS aether's cap; aether's sinks reach back down." : "energy is a budget: divide it, move it freely; a sink levels on the energy-seconds it gets. tap a name to focus it; the tide's ~ marks the flooded layer"));
if (tut && note_t <= 0 && _tip == "") draw_set_color(c_white);
draw_text_ext(6, foot_y + 16, _foot, 9, room_width - 12);
ui_fade_set(1);
