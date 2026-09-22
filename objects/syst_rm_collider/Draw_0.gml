draw_set_font(fnt);
draw_set_halign(fa_left); draw_set_valign(fa_top);
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby - 2, room_width, room_height, 0, c_hsv(169, 186, 5), 1);
var _lf = coll_lfield(c), _stepk = coll_stepk(c), _rates = [cas_rates(c.m, _lf), cas_rates(c.a, _lf)], _sides = [c.m, c.a], _tip = "";
// ---- the strip: energy, the field, the run clock, best ----
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby, room_width, 16, 0, c_hsv(169, 186, 5), 1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby + 15, room_width, 1, 0, rgb(170, 190, 230), .25);
draw_set_color(sett_ink); draw_set_alpha(.85); draw_text(6, bby + 4, "the collider");
draw_set_color(c_gold); draw_set_alpha(.95); draw_text(84, bby + 4, coll_fmt(c.energy) + " energy");
var _rt = c.inf ? c.run : (universal_now() - c.start);
draw_set_color(sett_ink); draw_set_alpha(.6);
draw_text_transformed(210, bby + 5, "run " + __hms(_rt) + ((c.best >= 0) ? ("   best " + __hms(c.best)) : "") + ((c.crunches > 0) ? ("   crunch " + string(c.crunches) + " (steps x" + string_format(_stepk, 1, 2) + ")") : ""), .85, .85, 0);
var _bk = __back_r(); draw_ui_button(_bk.x, _bk.y, _bk.w, _bk.h, "back", rgb(170, 190, 230), true, false);
// ---- the band: the two stocks either side of THE BEAM (the balance: pointer = log10 matter - log10 antimatter, the clean window marked) ----
draw_set_color(side_col[0]); draw_set_alpha(.95); draw_text(6, band_y + 2, "matter");
draw_set_color(c_white); draw_text(6, band_y + 12, coll_fmt(c.m.stock));
draw_set_halign(fa_right);
draw_set_color(side_col[1]); draw_text(room_width - 6, band_y + 2, "antimatter");
draw_set_color(c_white); draw_text(room_width - 6, band_y + 12, coll_fmt(c.a.stock));
draw_set_halign(fa_left);
var _clean = coll_clean(c), _d = (c.m.stock > COLL_LZ * .5 && c.a.stock > COLL_LZ * .5) ? clamp((c.m.stock - c.a.stock) / 3, -1, 1) : 0;
draw_sprite_ext(spr_pixel_1x1, 0, beam_x, beam_y, beam_w, 4, 0, c_black, .7);
draw_sprite_ext(spr_pixel_1x1, 0, beam_x, beam_y, beam_w * .5, 4, 0, side_col[0], .35);
draw_sprite_ext(spr_pixel_1x1, 0, beam_x + beam_w * .5, beam_y, beam_w * .5, 4, 0, side_col[1], .35);
var _cw = beam_w * .5 * min(1, coll_window(c) / 3);   // the clean window's half-width in beam px (the magnet widens it)
draw_sprite_ext(spr_pixel_1x1, 0, beam_x + beam_w * .5 - _cw, beam_y - 1, _cw * 2, 6, 0, c_sgreen, .25 + .25 * (_clean - 1));
draw_sprite_ext(spr_pixel_1x1, 0, beam_x + beam_w * .5 + _d * beam_w * .5 - 1, beam_y - 3, 3, 10, 0, c_white, .95);
draw_set_halign(fa_center); draw_set_color((_clean > 1.05) ? c_sgreen : sett_ink); draw_set_alpha(.85);
draw_text(beam_x + beam_w * .5, band_y + 12, (_clean > 1.05) ? ("clean x" + string_format(_clean, 1, 2)) : ((_d < 0) ? "matter light" : "antimatter light"));
draw_set_halign(fa_left);
// ---- the controls: buy qty, collide + pct ----
var _bq = __buyq_r(), _lbl = (buy_q == "max") ? "buy max" : ("buy x" + string(buy_q));
draw_sprite_ext(spr_pixel_1x1, 0, _bq.x, _bq.y, _bq.w, _bq.h, 0, c_black, .8); draw_px_rect(_bq.x, _bq.y, _bq.w, _bq.h, c_gold, .45);
draw_set_color(c_gold); draw_set_alpha(.95); draw_text(_bq.x + 5, _bq.y + 4, _lbl); draw_set_color(sett_ink); draw_set_alpha(.7); draw_text(_bq.x + _bq.w - 8, _bq.y + 4, "v");
var _cr = __coll_r(), _pr = __pct_r(), _mn = min(c.m.stock, c.a.stock), _can = (!c.inf && _mn >= 0 && _mn + log10(c.pct / 100) >= 0);
draw_ui_button(_cr.x, _cr.y, _cr.w, _cr.h, "collide", c_gold, _can, _can);
draw_sprite_ext(spr_pixel_1x1, 0, _pr.x, _pr.y, _pr.w, _pr.h, 0, c_black, .8); draw_px_rect(_pr.x, _pr.y, _pr.w, _pr.h, c_gold, .45);
draw_set_color(c_gold); draw_set_alpha(.95); draw_text(_pr.x + 4, _pr.y + 4, string(c.pct) + "%"); draw_set_color(sett_ink); draw_set_alpha(.7); draw_text(_pr.x + _pr.w - 8, _pr.y + 4, "v");
if (_can) { draw_set_color(sett_ink); draw_set_alpha(.6); draw_text_transformed(_pr.x + _pr.w + 6, _cr.y + 4, "+" + coll_fmt(_mn + log10(c.pct / 100) + log10(COLL_PAIR_E) + log10(_clean)), .85, .85, 0); }
if (c.auto_lv > 0) { draw_set_halign(fa_right); draw_set_color(c_gold); draw_set_alpha(.6); draw_text_transformed(_cr.x - 6, _cr.y + 4, "auto " + string(coll_auto_every(c.auto_lv)) + "s  " + string(ceil(max(0, coll_auto_every(c.auto_lv) - c.auto_t))), .85, .85, 0); draw_set_halign(fa_left); }
// ---- the tiers: matter left, antimatter right; a tier's buy button wears the PAYING side's colour ----
for (var _s = 0; _s < 2; _s++) {
	var _cs = _sides[_s], _pay = _sides[1 - _s];
	for (var _i = 0; _i < 8; _i++) {
		var _r = __row_r(_s, _i), _col = tier_col[_i], _locked = (_i > 0 && _cs.bought[_i - 1] <= 0);
		if (_locked) { draw_row_collapsed(_r.x, _r.y, _r.w, _r.h, tier_name[_i] + " " + side_name[_s], "a " + tier_name[_i - 1] + " first", _col); continue; }
		draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, _r.w, _r.h, 0, c_hsv(168, 140, 14), 1);
		draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, 2, _r.h, 0, _col, .9);
		draw_set_color(_col); draw_set_alpha(.95); draw_text(_r.x + 6, _r.y + 5, tier_name[_i]);
		draw_set_color(merge_colour(_col, c_white, .5)); draw_set_alpha(.75);
		draw_text_transformed(_r.x + 28, _r.y + 6, "x" + coll_fmt((_cs.bought[_i] div 10) * log10(2)) + " " + string(_cs.bought[_i] mod 10) + "/10", .8, .8, 0);
		var _cnt = coll_fmt(_cs.count[_i]);
		draw_set_color(c_white); draw_set_alpha(.95); draw_text(_r.x + 88, _r.y + 5, _cnt);
		var _b = __tbuy_r(_s, _i), _cost = cas_cost(_cs, _i, _stepk);
		if (_i < 7 && _cs.count[_i + 1] > COLL_LZ * .5 && _cs.count[_i] > COLL_LZ * .5) {
			var _pt = "+" + coll_fmt(_cs.count[_i + 1] + _rates[_s][_i + 1] - _cs.count[_i] + 2) + "%", _px = _r.x + 88 + string_width(_cnt) + 4;
			if (_px + string_width(_pt) * .8 < _b.x - 2) { draw_set_color(c_sgreen); draw_set_alpha(.65); draw_text_transformed(_px, _r.y + 6, _pt, .8, .8, 0); }
		}
		draw_ui_button(_b.x, _b.y, _b.w, _b.h, coll_fmt(_cost), side_col[1 - _s], !c.inf && _pay.stock >= _cost, true);
		if (_tip == "" && __hit(_r)) _tip = tier_name[_i] + " " + side_name[_s] + ": makes " + ((_i == 0) ? (side_name[_s] + " stock") : (tier_name[_i - 1] + " " + side_name[_s])) + " at x" + coll_fmt(_rates[_s][_i]) + "/s each; paid in " + side_name[1 - _s] + " (" + coll_fmt(_cost) + "); every 10 bought doubles its rate";
	}
}
// ---- the energy upgrades ----
var _up = ["field", "auto", "magnet"], _ul = ["field x" + string_format(power(COLL_FIELD_MULT, c.field), 1, 2), (c.auto_lv > 0) ? ("auto " + string(coll_auto_every(c.auto_lv)) + "s") : "auto-collider", "magnet " + string(c.magnet_lv) + "/4"];
for (var _k = 0; _k < 3; _k++) {
	var _u = __upg_r(_k), _cost = coll_cost(c, _up[_k]);
	draw_ui_button(_u.x, _u.y, _u.w, _u.h, _ul[_k] + ((_cost < 0) ? "  (top)" : ("  " + coll_fmt(_cost))), c_gold, _cost >= 0 && !c.inf && c.energy >= _cost, _cost >= 0 && c.energy >= _cost);
	if (__hit(_u)) _tip = (_k == 0) ? "the field: every tier on both sides x1.15 a level (tickspeed's twin) - a decade of energy each" : ((_k == 1) ? "the auto-collider: fires at the pct set, every 60 / 30 / 15 s - the idle lane, replayed while you are away" : "the magnet: the clean window x1.5 a level - a collision counts as clean within a factor of " + string_format(power(2, power(COLL_MAGNET_MULT, c.magnet_lv)), 1, 1));
}
if (__hit(__coll_r())) _tip = "ANNIHILATION: min(matter, antimatter) x " + string(c.pct) + "% leaves both stocks, " + string(COLL_PAIR_E) + " energy a pair, x" + string(COLL_CLEAN) + " when the beam is balanced - the same stocks buy tiers";
else if (__hit({ x : beam_x - 10, y : band_y, w : beam_w + 20, h : 22 })) _tip = "THE BEAM: matter vs antimatter stock, log scale; the green window is a clean collision (x" + string(COLL_CLEAN) + ")";
// ---- the horizon banner ----
if (c.inf) {
	draw_sprite_ext(spr_pixel_1x1, 0, inf_bx, inf_by, inf_bw, inf_bh, 0, c_black, .95); draw_px_rect(inf_bx, inf_by, inf_bw, inf_bh, c_gold, .9);
	draw_set_halign(fa_center); draw_set_color(c_gold); draw_set_alpha(.95); draw_text(inf_bx + inf_bw * .5, inf_by + 8, "the horizon");
	draw_set_color(merge_colour(c_gold, c_white, .4)); draw_set_alpha(.85);
	draw_text_transformed(inf_bx + inf_bw * .5, inf_by + 22, "1.80e308 energy in " + __hms(c.run) + ((c.best >= 0 && c.best < c.run) ? ("  (best " + __hms(c.best) + ")") : ""), .85, .85, 0);
	var _cx = __crunch_r(); draw_ui_button(_cx.x, _cx.y, _cx.w, _cx.h, "big crunch", c_gold, true, true);
	draw_set_halign(fa_left);
}
// ---- the line ----
draw_set_color((note_t > 0) ? c_white : c_gray); draw_set_alpha(.8);
var _foot = (note_t > 0) ? note : ((_tip != "") ? _tip : (tut ? "matter tiers are paid in antimatter, antimatter tiers in matter - buy a 1st of each, let the stocks grow, then [collide]: the pairs become energy" : "two cascades, each the other's fuel; energy only from annihilation - grow, or score"));
if (tut && note_t <= 0 && _tip == "") draw_set_color(c_white);
draw_text_ext(6, foot_y, _foot, 9, room_width - 12);
ui_fade_set(1);
