// ---- THE WARP PASS: the ripple and the hold heat bend the room ----
if (array_length(rings) > 0 || heat > .003) {
	if (surface_exists(application_surface)) {
		var _aw = surface_get_width(application_surface);
		var _ah = surface_get_height(application_surface);
		if (!surface_exists(scratch) || surface_get_width(scratch) != _aw
		|| surface_get_height(scratch) != _ah) {
			if (surface_exists(scratch)) surface_free(scratch);
			scratch = surface_create(_aw, _ah);
		}
		surface_copy(scratch, 0, 0, application_surface);

		// the affected box, room px: the rings' reach and the haze's
		var _x0 = room_width, _y0 = room_height, _x1 = 0, _y1 = 0;
		var _rr = array_create(32, 0);
		var _n = min(8, array_length(rings));
		for (var _i = 0; _i < _n; _i++) {
			var _rg = rings[_i];
			_rr[_i * 4] = _rg.x; _rr[_i * 4 + 1] = _rg.y; _rr[_i * 4 + 2] = _rg.r; _rr[_i * 4 + 3] = _rg.amp;
			var _reach = _rg.r + 12;
			_x0 = min(_x0, _rg.x - _reach); _y0 = min(_y0, _rg.y - _reach);
			_x1 = max(_x1, _rg.x + _reach); _y1 = max(_y1, _rg.y + _reach);
		}
		var _hr = 22;
		if (heat > .003) {
			_x0 = min(_x0, hx - _hr); _y0 = min(_y0, hy - _hr);
			_x1 = max(_x1, hx + _hr); _y1 = max(_y1, hy + _hr);
		}
		_x0 = clamp(floor(_x0), 0, room_width);  _y0 = clamp(floor(_y0), 0, room_height);
		_x1 = clamp(ceil(_x1), 0, room_width);   _y1 = clamp(ceil(_y1), 0, room_height);
		if (_x1 > _x0 && _y1 > _y0) {
			var _sx = _aw / room_width, _sy = _ah / room_height;
			shader_set(sh_tapwarp);
			shader_set_uniform_f(shader_get_uniform(sh_tapwarp, "u_room"), room_width, room_height);
			shader_set_uniform_f(shader_get_uniform(sh_tapwarp, "u_n"), _n);
			shader_set_uniform_f_array(shader_get_uniform(sh_tapwarp, "u_ring"), _rr);
			shader_set_uniform_f(shader_get_uniform(sh_tapwarp, "u_haze"), hx, hy, _hr, heat);
			shader_set_uniform_f(shader_get_uniform(sh_tapwarp, "u_time"), tm);
			draw_surface_part_ext(scratch, _x0 * _sx, _y0 * _sy, (_x1 - _x0) * _sx, (_y1 - _y0) * _sy,
				_x0, _y0, 1 / _sx, 1 / _sy, c_white, 1);
			shader_reset();
		}
	}
}

// ---- glow (DE) ----
for (var _i = 0; _i < array_length(glows); _i++) {
	var _g = glows[_i];
	var _f = 1 - _g.t / 10;
	var _s = (_g.crit ? .30 : .20) * (1.2 - _f * .4);
	draw_sprite_ext(spr_vis_glow_soft, 0, _g.x, _g.y, _s, _s, 0,
		_g.crit ? c_gold : g.profit_color, .55 * _f);
}

// ---- crater ----
for (var _i = 0; _i < array_length(craters); _i++) {
	var _c = craters[_i];
	var _cr = 13;
	var _qs = _cr * 2 + 2;
	shader_set(sh_tapcrater);
	shader_set_uniform_f(shader_get_uniform(sh_tapcrater, "u_quad"), _c.x - _qs * .5, _c.y - _qs * .5, _qs, _qs);
	shader_set_uniform_f(shader_get_uniform(sh_tapcrater, "u_c"), _c.x, _c.y);
	shader_set_uniform_f(shader_get_uniform(sh_tapcrater, "u_r"), _cr);
	shader_set_uniform_f(shader_get_uniform(sh_tapcrater, "u_depth"), _c.d);
	shader_set_uniform_f(shader_get_uniform(sh_tapcrater, "u_light"), -.42, -.62, .66);
	shader_set_uniform_f(shader_get_uniform(sh_tapcrater, "u_cells"), _qs);
	draw_sprite_ext(spr_pixel_1x1, 0, _c.x - _qs * .5, _c.y - _qs * .5, _qs, _qs, 0, c_white, 1);
	shader_reset();
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

// ---- hold heat: the glow at the finger ----
if (heat > .003) {
	var _lvf = variable_global_exists("overcharge_lv")
		? clamp((g.overcharge_lv - 1) / max(1, overcharge_maxlv() - 1), 0, 1) : 0;
	var _hc = merge_colour(g.profit_color, c_white, _lvf);
	var _hs = .22 + .10 * heat + .02 * dsin(current_time * .6);
	draw_sprite_ext(spr_vis_glow_soft, 0, hx, hy, _hs, _hs, 0, _hc, .5 * heat);
	draw_sprite_ext(spr_vis_glow_soft, 0, hx, hy, _hs * .45, _hs * .45, 0, c_white, .35 * heat);
}

// ---- crit slash ----
for (var _i = 0; _i < array_length(slashes); _i++) {
	var _sl = slashes[_i];
	var _f = 1 - _sl.t / 7;
	var _len = 46 + 30 * (1 - _f);
	draw_sprite_ext(spr_vis_glow_soft, 0, _sl.x, _sl.y, _len / 144 * 2.2, .09, _sl.ang, c_gold, .85 * _f);
	draw_sprite_ext(spr_pixel_1x1, 0,
		_sl.x - lengthdir_x(_len * .5, _sl.ang), _sl.y - lengthdir_y(_len * .5, _sl.ang),
		_len, 1, _sl.ang, c_white, .9 * _f);
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
draw_text(_r.x + 4 + string_width("fx  "), _r.y + 2, fx_names[g.tap_fx]);
draw_set_alpha(1);
draw_set_color(c_white);
