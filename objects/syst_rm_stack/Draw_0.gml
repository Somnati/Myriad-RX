draw_set_font(fnt);
draw_set_halign(fa_left); draw_set_valign(fa_top);
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby - 2, room_width, room_height, 0, c_hsv(169, 186, 5), 1);
var _nm = stk_names(), _cfg = stk_config(), _l = s.tab, _lc = _nm[_l].col;
// the strip: the name, the spark, its pace, the cinders
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby, room_width, 16, 0, c_hsv(169, 186, 5), 1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby + 15, room_width, 1, 0, rgb(170, 190, 230), .25);
draw_set_color(c_gold); draw_set_alpha(.95); draw_text(6, bby + 4, "the stack");
draw_set_color(c_gold); draw_set_alpha(.95); draw_text(70, bby + 4, stk_num(s.spark) + " spark");
draw_set_color(sett_ink); draw_set_alpha(.7); draw_text(160, bby + 4, "+" + string_format(stk_spark_rate(s), 1, 2) + "/s");
draw_set_color(c_hred); draw_set_alpha(.85); draw_text(240, bby + 4, string(s.cinders) + " cinder" + ((s.cinders == 1) ? "" : "s") + ((s.turns > 0) ? ("  -  turn " + string(s.turns)) : ""));
var _bk = __back_r(); draw_ui_button(_bk.x, _bk.y, _bk.w, _bk.h, "back", rgb(170, 190, 230), true, false);
// THE LAYERS' PILLS: the open ones lit, a shut one says what opens it
for (var _t = 0; _t < 3; _t++) {
	var _tr = __tab_r(_t), _on = (_t == _l), _op = __open(_t);
	draw_sprite_ext(spr_pixel_1x1, 0, _tr.x, _tr.y, _tr.w, _tr.h, 0, _on ? _nm[_t].col : c_black, _on ? .9 : .7);
	draw_px_rect(_tr.x, _tr.y, _tr.w, _tr.h, _nm[_t].col, _op ? .9 : .3);
	draw_set_color(_on ? c_black : (_op ? _nm[_t].col : c_gray)); draw_set_alpha(.95);
	draw_text(_tr.x + 5, _tr.y + 2, _nm[_t].name + "  " + ((_t == 0) ? "" : (_op ? ("cap " + string(stk_cap(s, _t))) : "shut")));
}
// THE BAND: the cap bar (allocated of the cap), the speed, energy's cap buy or a layer's source
var _sk = s.layers[_l].sinks, _cap = stk_cap(s, _l), _tot = 0;
for (var _i = 0; _i < array_length(_sk); _i++) _tot += _sk[_i].alloc;
draw_set_color(_lc); draw_set_alpha(.95);
draw_text(6, band_y + 2, _nm[_l].name + "  " + string(_tot) + " / " + string(_cap) + "   speed x" + string_format(stk_speed(s, _l), 1, 2) + ((s.layers[_l].focus >= 0) ? ("   focus: " + _cfg[_l][s.layers[_l].focus].name) : ""));
draw_sprite_ext(spr_pixel_1x1, 0, 6, band_y + 14, room_width - 12, 6, 0, c_black, .6);
if (_cap > 0) draw_sprite_ext(spr_pixel_1x1, 0, 6, band_y + 14, (room_width - 12) * clamp(_tot / _cap, 0, 1), 6, 0, _lc, .8);
if (flash > 0) draw_sprite_ext(spr_pixel_1x1, 0, 6, band_y + 14, room_width - 12, 6, 0, c_white, .5 * flash);
if (_l == 0) { var _br = __buy_r(), _cc = stk_cap_cost(s); draw_ui_button(_br.x, _br.y, _br.w, _br.h, "cap +" + string(STK_CAP_STEP) + "  " + stk_num(_cc), c_gold, true, s.spark >= _cc); }
else { draw_set_halign(fa_right); draw_set_color(sett_ink); draw_set_alpha(.6); draw_text(room_width - 6, band_y + 2, (_l == 1) ? "the cap is the well's level (+ the ember)" : "the cap is the deep well's level"); draw_set_halign(fa_left); }
// THE ROWS: the name (tap = focus; the stars), the level, the bonus, the bar, the eta, the cluster
var _tip = "";
for (var _i = 0; _i < array_length(_sk); _i++) {
	var _r = __row_r(_i), _k = _sk[_i], _c = _cfg[_l][_i], _foc = (s.layers[_l].focus == _i);
	draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, _r.w, _r.h, 0, _foc ? merge_colour(c_hsv(168, 140, 15), _c.col, .18) : c_hsv(168, 140, 12), 1);
	draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, 2, _r.h, 0, _c.col, .9);
	var _stars = "", _ms = [10, 25, 50, 100, 200];
	for (var _m = 0; _m < array_length(_ms); _m++) if (_k.level >= _ms[_m]) _stars += "*";
	draw_set_color(_foc ? c_white : _c.col); draw_set_alpha(.95);
	draw_text(_r.x + 5, _r.y + 2, _c.name + (_foc ? "  focus" : "") + ((_stars != "") ? ("  " + _stars) : ""));
	draw_set_color(sett_ink); draw_set_alpha(.75);
	draw_text(_r.x + 5, _r.y + 12, "lv " + string(_k.level) + "   " + __bonus_txt(_l, _i));
	// the bar toward the next level
	var _thr = stk_thr(s, _l, _i, _k.level), _fl = clamp(_k.prog / max(.0001, _thr), 0, 1);
	draw_sprite_ext(spr_pixel_1x1, 0, bar_x, _r.y + 8, bar_w, 8, 0, c_black, .6);
	draw_sprite_ext(spr_pixel_1x1, 0, bar_x, _r.y + 8, bar_w * _fl, 8, 0, _c.col, (_k.alloc > 0) ? .85 : .35);
	draw_px_rect(bar_x, _r.y + 8, bar_w, 8, _c.col, .3);
	var _eta = stk_eta(s, _l, _i);
	draw_set_halign(fa_center); draw_set_color(c_white); draw_set_alpha(.8);
	draw_text(bar_x + bar_w * .5, _r.y + 8, string(floor(_fl * 100)) + "%" + ((_eta >= 0) ? ("  " + ((_eta < 60) ? (string(ceil(_eta)) + "s") : ((_eta < 3600) ? (string(floor(_eta / 60)) + "m") : (string(floor(_eta / 3600)) + "h")))) : ""));
	draw_set_halign(fa_left);
	// the cluster
	draw_ui_button(bx_minus, _r.y + 6, 13, 13, "-", _c.col, _k.alloc > 0, false);
	draw_set_halign(fa_center); draw_set_color(c_white); draw_set_alpha(.95); draw_text(bx_num + 15, _r.y + 8, string(_k.alloc)); draw_set_halign(fa_left);
	draw_ui_button(bx_plus, _r.y + 6, 13, 13, "+", _c.col, _tot < _cap, false);
	draw_ui_button(bx_max, _r.y + 6, 30, 13, "max", _c.col, _tot < _cap, false);
	draw_ui_button(bx_clear, _r.y + 6, 18, 13, "0", _c.col, _k.alloc > 0, false);
	if (_tip == "" && __hit(_r)) {
		var _next = stk_bonus(s, _l, _i);
		_tip = _c.name + ": " + _c.what + " - per " + string_format(stk_per(s, _l, _i), 1, 1) + "% a level^" + string(STK_BONUS_POW) + "; the next level needs " + stk_num(_thr) + " energy-seconds" + ((_stars != "") ? ("; " + string(string_length(_stars)) + " milestone" + ((string_length(_stars) == 1) ? "" : "s") + " (per x1.5 each)") : "") + ". tap the name to focus it";
	}
}
// THE FOOT: the presets, the turn, the line
var _er = __even_r(), _hr = __chase_r(), _zr = __clear_r(), _tr2 = __turn_r();
draw_ui_button(_er.x, _er.y, _er.w, _er.h, "even", _lc, _cap > 0, false);
draw_ui_button(_hr.x, _hr.y, _hr.w, _hr.h, "chase", _lc, _cap > 0, false);
draw_ui_button(_zr.x, _zr.y, _zr.w, _zr.h, "0", _lc, _tot > 0, false);
var _cin = stk_cinders(s), _canturn = (_cin >= 1 && stk_cap(s, 2) >= 1);
draw_ui_button(_tr2.x, _tr2.y, _tr2.w, _tr2.h, _canturn ? ("the turn  +" + string(_cin) + " cinder" + ((_cin == 1) ? "" : "s")) : ((stk_cap(s, 2) < 1) ? "the turn: quintessence first" : ("the turn  +" + string(_cin))), c_hred, _canturn, _canturn);
if (__hit(_er)) _tip = "even: the cap spread over the six"; else if (__hit(_hr)) _tip = "chase: all of it to the sink nearest its next level"; else if (__hit(_zr)) _tip = "every allocation of this layer back";
else if (__hit(_tr2)) _tip = "THE TURN: the stack reset - spark, caps, every level - for cinders, the square root of the levels held over four (aether's count three times, quintessence's five); a cinder is +6% every speed and +3% spark, for ever";
else if (__hit(__buy_r()) && _l == 0) _tip = "energy's cap, +" + string(STK_CAP_STEP) + " a buy - the price doubles each; the ballast lowers it";
draw_set_color((note_t > 0) ? c_white : c_gray); draw_set_alpha(.8);
var _foot = (note_t > 0) ? note : ((_tip != "") ? _tip : (tut ? "first words: put energy in the generator - it levels on energy-seconds and makes spark; spark buys cap. the well's level IS aether's cap; aether's sinks reach back down." : "energy is a budget: divide it, move it freely; a sink levels on the energy-seconds it gets. tap a name to focus it"));
if (tut && note_t <= 0 && _tip == "") draw_set_color(c_white);
draw_text_ext(6, foot_y + 16, _foot, 9, room_width - 12);
ui_fade_set(1);
