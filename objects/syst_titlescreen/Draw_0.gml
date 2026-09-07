/// the title: a deep-space gradient, a faint star sprinkle (seeded,
/// static - the real starfield lives in the space rooms), the game
/// name in the sprite font scaled up, and the five-button column.
/// CONTINUE grays out until a save exists.

draw_set_font(fnt);

// backdrop: black into the house teal, bottom-lit. a 270px-wide dark
// gradient bands hard in the 8-bit pipeline - sh_fog_dither's temporal
// IGN shimmers the steps flat (the house fix; luminance gate keeps the
// black top untouched)
shader_set(sh_fog_dither);
shader_set_uniform_f(dith_u_time, (current_time mod 100000) / 1000);
draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, 0, 0, room_width,
	room_height, 0, c_black, c_black, c_hsv(169, 186, 14), c_hsv(169, 186, 14), 1);
shader_reset();

// a static star sprinkle (guarded seed - never disturbs a stream) -
// stays as the FARTHEST depth layer under the drift
var _seed = random_get_seed();
random_set_seed(133742);
repeat (70) {
	var _sx = irandom(room_width);
	var _sy = irandom(room_height);
	var _tw = .25 + .3 * abs(dsin(tt * .7 + _sx * 13 + _sy * 7));
	draw_sprite_ext(spr_pixel_1x1, 0, _sx, _sy, 1, 1, 0, c_white, _tw);
}
random_set_seed(_seed);

// ---- parallax star drift (2026-07-14, his ask: background depth):
// three layers falling at a shallow angle; speed, count and
// brightness carry the depth. positions are pure HASH math off the
// clock (tt, delta-fed in Step) - stateless, deterministic, wraps
// forever. draw positions floor to whole pixels (house crisp); the
// motion still reads smooth because the RATE is fractional. the near
// layer drags a dim 1px tail against the fall so speed reads as a
// streak, and every 4th near star sits on a small spr_star_glow.
var _dxa = .38; // fall angle: x drift per y (down-right)
var _spds = [.14, .34, .72]; // px per 60hz step, far -> near
var _cnts = [34, 24, 14];
var _alps = [.2, .38, .6];
for (var _l = 0; _l < 3; _l++) {
	var _spd = _spds[_l];
	for (var _i2 = 0; _i2 < _cnts[_l]; _i2++) {
		var _hx = frac(sin((_i2 + 1) * 127.1 + _l * 311.7) * 43758.5453);
		var _hy = frac(sin((_i2 + 1) * 269.5 + _l * 183.3) * 28001.83);
		var _px = (_hx * room_width  + tt * _spd * _dxa) mod room_width;
		var _py = (_hy * room_height + tt * _spd) mod room_height;
		_px = floor(_px); _py = floor(_py);
		var _tw2 = _alps[_l] * (.75 + .25 * dsin(tt * 1.3 + _i2 * 47 + _l * 90));
		if (_l == 2) {
			// near: glow underlay on a few, then star + tail
			if ((_i2 & 3) == 0)
				draw_sprite_ext(spr_star_glow, _i2 mod 6, _px, _py,
					.35, .35, 0, c_white, .28);
			draw_sprite_ext(spr_pixel_1x1, 0,
				_px - sign(_dxa), _py - 1, 1, 1, 0, c_white, _tw2 * .4);
		}
		draw_sprite_ext(spr_pixel_1x1, 0, _px, _py, 1, 1, 0, c_white, _tw2);
	}
}

// the name, big: the LARGE OUTLINE font (his ask 2026-07-14; Myriad
// DE port) at 2x integer scale - the baked outline replaces the old
// hand-drawn drop shadow, one draw
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_font(fnt_large_outline);
draw_set_color(merge_colour(c_gold, c_white, .55));
draw_set_alpha(1);
draw_text_transformed(room_width div 2, 52, "myriad rx", 2, 2, 0);
draw_set_font(fnt);
draw_set_color(sett_ink);
draw_set_alpha(.55);
draw_text(room_width div 2, 84, "remix edition");
draw_set_alpha(1);

// THE CONTINUE CARD. It sits ABOVE the column, not under the continue
// button: the gaps between buttons are 6px and this needs a line of its
// own. (The old "no save yet" note lived below the column and clipped
// the load button by a pixel; one seat serves both states now.)
// Two-tone and still centred - measure both halves, then draw the line
// left-aligned from the computed start, because a sprite font has no
// business being scaled to fit.
var _cy = btn_y0 - 16;
draw_set_valign(fa_top);
if (has_save && cont.valid) {
	var _cn = (cont.name != "") ? cont.name : g.profile_name[g.profile];
	var _cc = (cont.color >= 0) ? cont.color : g.profile_color[g.profile];
	var _ago = crunch_time_ago(cont.datetime);
	var _rest = " - " + crunch_arb(cont.profit);
	if (_ago != "") _rest += " - " + _ago;
	draw_set_halign(fa_left);
	var _lx = (room_width - (string_width(_cn) + string_width(_rest))) div 2;
	draw_set_color(_cc);
	draw_set_alpha(.9);
	draw_text(_lx, _cy, _cn);
	draw_set_color(sett_ink);
	draw_set_alpha(.55);
	draw_text(_lx + string_width(_cn), _cy, _rest);
	draw_set_alpha(1);
} else {
	draw_set_halign(fa_center);
	draw_set_color(c_gray);
	draw_set_alpha(.4);
	draw_text(room_width div 2, _cy, "no save yet");
	draw_set_alpha(1);
}

// the button column. hover BOUNCES the chrome up ~12% (spring in
// Step: overshoot-settle in, bounce-back out), rounded to whole
// pixels. the LABEL is pinned to the resting rect's anchor via
// draw_ui_button's lx/ly override - glyphs never move a pixel while
// the frame dances (re-centering them on the animated rect made the
// text shimmer, his report). hit rects stay the static ones in Step.
for (var _i = 0; _i < 5; _i++) {
	var _by = btn_y0 + _i * btn_p;
	var _en = (_i != 1) || has_save;
	var _col = c_gold;
	if (_i == 3) _col = c_sblue;
	if (_i == 4) _col = c_gray;
	// chrome geometry stays FLOAT all the way (his 2026-07-14 note:
	// the bounce was snapping pixel to pixel) - the gpu rasterizes
	// fractional rects smoothly; only the LABEL stays integer-pinned
	// (the lx/ly override), holding last round's no-shimmer fix too
	var _sc = 1 + hov[_i] * .12;
	var _bw = btn_w * _sc;
	var _bh = btn_h * _sc;
	var _bx = (room_width - _bw) * .5;
	var _by2 = _by - (_bh - btn_h) * .5;
	draw_ui_button(_bx, _by2, _bw, _bh, labels[_i], _col, _en, _i <= 1,
		btn_x + (btn_w div 2) + 1, _by + (btn_h - 7) div 2);
}
// version tag, bottom-left (game_version = THE string, main_macros -
// a release bump is one line there) + the footnote under it
draw_set_halign(fa_left);
draw_set_color(sett_ink);
draw_set_alpha(.6);
draw_text(6, room_height - 22, game_version);
draw_set_alpha(.35);
draw_text(6, room_height - 12, "somnati - engine build");
draw_set_halign(fa_left);
draw_set_color(c_white);
draw_set_alpha(1);
