if (!__live()) exit;

// ---- glow (DE) ----
for (var _i = 0; _i < array_length(glows); _i++) {
	var _g = glows[_i];
	var _f = 1 - _g.t / 10;
	var _s = (_g.crit ? .30 : .20) * (1.2 - _f * .4);
	draw_sprite_ext(spr_vis_glow_soft, 0, _g.x, _g.y, _s, _s, 0,
		_g.crit ? c_gold : g.profit_color, .55 * _f);
}

// ---- shockwave: a one-cell ring, chromatic split closing as it fades ----
for (var _i = 0; _i < array_length(shocks); _i++) {
	var _sh = shocks[_i];
	var _rmax = _sh.crit ? 22 : 16;
	var _f = 1 - _sh.r / _rmax;
	var _split = round(2 * _f);
	var _steps = 12 + floor(_sh.r * 4);
	gpu_set_blendmode(bm_add);
	for (var _k = 0; _k < _steps; _k++) {
		var _a = _k * 360 / _steps;
		var _px = floor(_sh.x + lengthdir_x(_sh.r, _a));
		var _py = floor(_sh.y + lengthdir_y(_sh.r, _a));
		draw_sprite_ext(spr_pixel_1x1, 0, _px - _split, _py, 1, 1, 0, c_red,  .55 * _f);
		draw_sprite_ext(spr_pixel_1x1, 0, _px + _split, _py, 1, 1, 0, c_blue, .55 * _f);
	}
	gpu_set_blendmode(bm_normal);
	for (var _k = 0; _k < _steps; _k++) {
		var _a = _k * 360 / _steps;
		var _px = floor(_sh.x + lengthdir_x(_sh.r, _a));
		var _py = floor(_sh.y + lengthdir_y(_sh.r, _a));
		draw_sprite_ext(spr_pixel_1x1, 0, _px, _py, 1, 1, 0, c_white, .8 * _f);
	}
}

// ---- the [fx] chip ----
var _r = __chip_r();
draw_set_font(fnt);
draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, _r.w, _r.h, 0, c_black, .6);
draw_px_rect(_r.x, _r.y, _r.w, _r.h, c_white, .25);
draw_set_halign(fa_left);
draw_set_color(rgb(120, 130, 150));
draw_set_alpha(.8);
draw_text(_r.x + 4, _r.y + 2, "fx");
draw_set_color(c_gold);
draw_text(_r.x + 4 + string_width("fx  "), _r.y + 2, fx_names[__fx()]);
draw_set_alpha(1);
draw_set_color(c_white);
