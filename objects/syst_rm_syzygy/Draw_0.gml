draw_set_font(fnt);
draw_set_halign(fa_left); draw_set_valign(fa_top);
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby - 2, room_width, room_height, 0, c_hsv(169, 186, 5), 1);
// the strip: the name, the flux, the rate, the tokens
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby, room_width, 16, 0, c_hsv(169, 186, 5), 1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby + 15, room_width, 1, 0, rgb(170, 190, 230), .25);
draw_set_color(c_hpurple); draw_set_alpha(.95); draw_text(6, bby + 4, "syzygy");
draw_set_color(c_gold); draw_set_alpha(.95); draw_text(60, bby + 4, syz_num(s.flux) + " flux");
draw_set_color(sett_ink); draw_set_alpha(.7); draw_text(150, bby + 4, "+" + string_format(s.rate, 1, 1) + "/s");
draw_set_color(c_sblue); draw_set_alpha(.9); draw_text(220, bby + 4, string(s.tokens) + " token" + ((s.tokens == 1) ? "" : "s"));
draw_set_color(sett_ink); draw_set_alpha(.7); draw_text(300, bby + 4, "harmonic x" + string_format(s.harm, 1, 1));
var _bk = __back_r(); draw_ui_button(_bk.x, _bk.y, _bk.w, _bk.h, "back", rgb(170, 190, 230), true, false);

// THE CYCLES: a row each - the period with its steps, the bar (its fill, the fire's flash, the conjunction's count), the level, the anchor
var _n = array_length(s.cycles), _tip = "";
for (var _i = 0; _i < _n; _i++) {
	var _c = s.cycles[_i], _y = __row_y(_i);
	var _pm = __per_m(_i), _pp = __per_p(_i), _br = __bar_r(_i), _lr = __lv_r(_i), _ar = __anc_r(_i);
	var _hue = (37 * _i + 190) mod 256, _col = make_colour_hsv(_hue, 150, 235);
	draw_sprite_ext(spr_pixel_1x1, 0, 2, _y + 1, room_width - 4, rh - 2, 0, c_hsv(168, 140, 12), 1);
	draw_sprite_ext(spr_pixel_1x1, 0, 2, _y + 1, 2, rh - 2, 0, _col, .9);
	// the period
	draw_ui_button(_pm.x, _pm.y, _pm.w, _pm.h, "-", _col, _c.per > SYZ_PER_MIN, false);
	draw_set_halign(fa_center); draw_set_color(_col); draw_set_alpha(.95); draw_text(32, _y + 6, string(_c.per) + "s"); draw_set_halign(fa_left);
	draw_ui_button(_pp.x, _pp.y, _pp.w, _pp.h, "+", _col, _c.per < SYZ_PER_MAX, false);
	// the bar: the fill, the flash, the yield inside
	var _fl = clamp(_c.t / _c.per, 0, 1), _fa = clamp(_c.fired / .6, 0, 1);
	draw_sprite_ext(spr_pixel_1x1, 0, _br.x, _br.y, _br.w, _br.h, 0, c_black, .6);
	draw_sprite_ext(spr_pixel_1x1, 0, _br.x, _br.y, _br.w * _fl, _br.h, 0, _col, .55 + .45 * _fa);
	if (_fa > 0) draw_sprite_ext(spr_pixel_1x1, 0, _br.x, _br.y, _br.w, _br.h, 0, (_c.k >= 2) ? c_white : _col, .35 * _fa);
	draw_px_rect(_br.x, _br.y, _br.w, _br.h, _col, .35);
	var _yl = syz_yield(s, _i), _tune = (_yl > power(_c.per, SYZ_PER_POW) * power(1.18, _c.lv - 1) * 1.01);
	draw_set_color(c_white); draw_set_alpha(.85);
	draw_text(_br.x + 4, _br.y + 3, syz_num(_yl) + " a fire" + (_tune ? "  in tune" : "") + ((_c.k >= 2 && _fa > 0) ? ("   x" + string(_c.k)) : ""));
	draw_set_halign(fa_right); draw_set_color(sett_ink); draw_set_alpha(.6); draw_text(_br.x + _br.w - 4, _br.y + 3, string(ceil(_c.per - _c.t)) + "s"); draw_set_halign(fa_left);
	// the level, the anchor
	var _lc = syz_cost(s, "lv", _i);
	draw_ui_button(_lr.x, _lr.y, _lr.w, _lr.h, "lv " + string(_c.lv) + "  " + syz_num(_lc), c_gold, true, s.flux >= _lc);
	var _ac = syz_cost(s, "anchor", _i);
	if (_c.anchor) draw_ui_button(_ar.x, _ar.y, _ar.w, _ar.h, "anchored", c_sblue, false, false);
	else draw_ui_button(_ar.x, _ar.y, _ar.w, _ar.h, "anchor " + syz_num(_ac), c_sblue, true, s.flux >= _ac);
	if (_tip == "") _tip = __tip(_i);
}
// the bottom: the four buttons, the readouts, the log
var _sr = __sync_r(), _cr = __cyc_r(), _hr = __harm_r(), _nr = __nin_r();
var _sc = syz_cost(s, "sync"), _cc = syz_cost(s, "cycle"), _hc = syz_cost(s, "harm"), _nc = syz_cost(s, "ninth");
draw_ui_button(_sr.x, _sr.y, _sr.w, _sr.h, (s.sync_cd > 0) ? ("sync in " + string(ceil(s.sync_cd)) + "s") : ("sync  " + syz_num(_sc)), c_hpurple, s.sync_cd <= 0, s.sync_cd <= 0 && s.flux >= _sc);
draw_ui_button(_cr.x, _cr.y, _cr.w, _cr.h, (_cc < 0) ? "cycles full" : ("new cycle  " + syz_num(_cc)), c_sgreen, _cc >= 0, _cc >= 0 && s.flux >= _cc);
draw_ui_button(_hr.x, _hr.y, _hr.w, _hr.h, "harmonic +.5  " + string(_hc) + " token" + ((_hc == 1) ? "" : "s"), c_sblue, true, s.tokens >= _hc);
draw_ui_button(_nr.x, _nr.y, _nr.w, _nr.h, (_nc < 0) ? "ninth: bought" : "ninth cycle  3 tokens", c_sblue, _nc >= 0, _nc >= 0 && s.tokens >= _nc);
// the readouts: the grand cycle, the next conjunction, the counts
var _lcm = syz_lcm(s.cycles), _nx = s.next;
draw_set_color(sett_ink); draw_set_alpha(.75);
var _line = "grand cycle " + ((_lcm >= 1000000) ? "never" : (string(_lcm) + "s")) + "   -   next: " + (is_struct(_nx) ? (string(_nx.k) + " meet in " + string(ceil(_nx.at)) + "s") : "none in sight") + "   -   grand conjunctions " + string(s.grand) + "   -   best " + string(s.best) + " as one";
draw_text(6, room_height - 26, _line);
if (__hit(_sr)) _tip = "every cycle fires together one second from now - a grand conjunction on demand; a minute's flux, then a three-minute wait";
else if (__hit(_cr)) _tip = "another cycle, at the first free period from eleven; a fire pays by the period, and a grand conjunction wants them all";
else if (__hit(_hr)) _tip = "the harmonic: k cycles aligned pay 1 + (k - 1) x this, each - a half a step, each step a token dearer";
else if (__hit(_nr)) _tip = "room for a ninth cycle - three tokens";
draw_set_color((note_t > 0) ? c_white : c_gray); draw_set_alpha(.8);
var _foot = (note_t > 0) ? note : ((_tip != "") ? _tip : ((array_length(s.log) > 0) ? s.log[array_length(s.log) - 1] : "tune the periods so the cycles meet"));
draw_text_ext(6, room_height - 14, _foot, 9, room_width - 12);
// THE FIRST WORDS, until the first flux
if (tut) {
	draw_set_color(c_white); draw_set_alpha(.85);
	draw_text_ext(70, __row_y(_n) + 8, "two cycles, at six and nine seconds. each fires when its bar fills and pays flux by its period. when two fire in the same moment they are in conjunction, and each pays double. six and nine meet every eighteen seconds - watch. then tune the periods: shared factors meet often, long lone periods pay more and meet nothing. the drift will knock a cycle off its phase now and then; sync it back, or anchor it.", 9, 330);
}
ui_fade_set(1);
