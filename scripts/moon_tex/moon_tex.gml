/// @description moon_tex() -> { t, c, h } the moons' shared textures: a cratered gray (MOON_TEX_W x MOON_TEX_H), a blank cloud, a flat height
/// Baked once (kept in g.moon_tex_c - NOT g.moon_tex: a script function IS a global, so that name is the method itself; rebuilt when the gpu loses them): every
/// moon wears the same rock, tinted its own colour at the draw (moon_draw),
/// the tech demo's way. The craters are a few darker rings on value noise.
function moon_tex() {
	if (variable_global_exists("moon_tex_c") && is_struct(g.moon_tex_c) && surface_exists(g.moon_tex_c.t) && surface_exists(g.moon_tex_c.c) && surface_exists(g.moon_tex_c.h)) return g.moon_tex_c;
	var _w = MOON_TEX_W, _h = MOON_TEX_H;
	var _t = surface_create(_w, _h), _c = surface_create(1, 1), _hs = surface_create(1, 1);
	var _sh = shader_current();
	if (_sh != -1) shader_reset();
	surface_set_target(_c); draw_clear_alpha(c_black, 0); surface_reset_target();
	surface_set_target(_hs); draw_clear_alpha(c_black, 1); surface_reset_target();
	surface_set_target(_t);
	draw_clear_alpha(c_black, 1);
	gpu_set_blendmode(bm_normal);
	// craters: a handful, seeded flat (the tint carries the identity)
	var _cr = [];
	for (var _i = 0; _i < 9; _i++) array_push(_cr, { x : (hash_mix(77, _i * 3) mod _w), y : (hash_mix(77, _i * 3 + 1) mod _h), r : 1.5 + (hash_mix(77, _i * 3 + 2) mod 30) / 10 });
	for (var _y = 0; _y < _h; _y++) for (var _x = 0; _x < _w; _x++) {
		var _n = (hash_mix(_x * 7 + 1, _y * 13 + 3) mod 1000) / 1000;
		var _v = 150 + (_n - .5) * 50;
		for (var _i = 0; _i < array_length(_cr); _i++) {
			var _dx = _x - _cr[_i].x, _dy = (_y - _cr[_i].y) * 2;
			var _dd = sqrt(_dx * _dx + _dy * _dy) / _cr[_i].r;
			if (_dd < 1) _v -= 28 * (1 - _dd);          // the bowl
			else if (_dd < 1.35) _v += 14 * (1.35 - _dd) / .35;   // the rim
		}
		_v = clamp(round(_v), 40, 230);
		draw_sprite_ext(spr_pixel_1x1, 0, _x, _y, 1, 1, 0, make_colour_rgb(_v, _v, _v), 1);
	}
	surface_reset_target();
	if (_sh != -1) shader_set(_sh);
	g.moon_tex_c = { t : _t, c : _c, h : _hs };
	return g.moon_tex_c;
}
