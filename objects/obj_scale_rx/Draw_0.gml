if (!variable_global_exists("game_started") || !g.game_started) exit;
if (by > room_height + 7) exit;

var _sx = W / SW;   // the bar sprite stretched to the width
var _fill = merge_colour_smooth(cprev, cnext, clamp((income - prevxp) / max(.0001, maxxp - prevxp), 0, 1));
if (cel > 0) _fill = merge_colour(_fill, c_white, cel * cel);

// ---- the bar ----
draw_sprite_ext(spr_scale_bar, 0, x0, by, _sx, 1, 0, c_white, 1);
draw_sprite_part_ext(spr_scale_bar, 1, 0, 0, SW * perc, BH, x0, by, _sx, 1, _fill, 1);
draw_sprite_ext(spr_scale_bracket, 0, x0 - 1, by - 2, 1, 1, 0, c_white, 1);
draw_sprite_ext(spr_scale_bracket, 0, x0 + W, by - 2, 1, 1, 0, c_white, 1);

// ---- the ticks: one an order; labelled every order when there is room,
// every third when there is not (DE's rule) ----
var _every = (ppo >= 30) ? 1 : 3;
draw_set_font(fnt);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
var _ms_px = -1, _ms_a = 0;
for (var xx = floor(lo); xx <= ceil(hi); xx++) {
	var _px = __px(xx);
	if (_px <= 0 || _px >= W) continue;
	var _ms = (xx == maxxp);
	var _a  = __edge(_px, _ms ? 4 : 2);
	var _lbl = _ms || ((xx mod _every) == 0);
	var _img = _ms ? 2 : (_lbl ? 1 : 0);
	var _c   = _ms ? merge_colour_smooth(c_dkgray, cnext, _a) : c_white;
	var _ix  = x0 + floor(_px);
	if (_ms) {
		_ms_px = _ix; _ms_a = _a;
		// the beacon: a breath, flaring on the crossing
		var _gs = 18 / max(1, sprite_get_width(spr_vis_glow_soft));
		draw_sprite_ext(spr_vis_glow_soft, 0, _ix, by + 1, _gs, _gs, 0, cnext, (.22 + .1 * sin(t * 3) + .6 * cel) * _a);
	}
	draw_sprite_ext(spr_scale_bracket, _img, _ix, by - 2, 1, 1, 0, _c, _ms ? 1 : _a);
	if (_lbl) {
		// the arc: DE's 2 -> -2 drift across the bar, glyphs at 1x
		var _ys = round(lerp(2, -2, _px / W));
		draw_set_alpha(_a);
		if (_ms) { draw_set_font(fnt_outline); draw_set_color(cnext); }
		else     { draw_set_font(fnt);         draw_set_color(c_white); }
		draw_text(_ix, by - 9 + _ys, crunch_arb(xx + .1));
	}
}
draw_set_alpha(1);

// ---- the eta, under the milestone ----
if (_ms_px >= 0 && eta >= 0) {
	draw_set_font(fnt);
	draw_set_halign(fa_center);
	draw_set_color(merge_colour(c_white, cnext, .5));
	draw_set_alpha(_ms_a * .9);
	draw_text(_ms_px, by + BH + 2, "~" + crunch_time(eta * 60));
	draw_set_alpha(1);
}

// ---- the pennants: the best run (dim) behind the run before ----
if (variable_global_exists("rebirth")) {
	var _last = (g.rebirth.prev_profit >= arb(1)) ? g.rebirth.prev_profit : 0;
	var _best = (g.rebirth.best_profit >= arb(1)) ? g.rebirth.best_profit : 0;
	if (_best > 0 && _best != _last) __pennant(_best, 1, true);
	__pennant(_last, 1, false);
}

// ---- the rebirth readout, under the bar's left end ----
if (units_txt != "") {
	draw_set_font(fnt);
	draw_set_halign(fa_left);
	draw_set_color(c_hred);
	draw_set_alpha(.9);
	draw_text(x0, by + BH + 2, units_txt);
	draw_set_alpha(1);
}

// the comparison tag (goes with the loser)
if (SCALE_COMPARE) {
	draw_set_font(fnt);
	draw_set_alpha(.45);
	draw_set_color(c_white);
	draw_set_halign(fa_right);
	draw_text(x0 - 4, by - 2, "rx");
}
draw_set_halign(fa_left);
draw_set_alpha(1);
draw_set_color(c_white);
