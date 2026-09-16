/// @description planet_bake(pn) - the world's three textures from its
/// maps (once, and again whenever a surface is lost): the terrain (rgb
/// = the biome's colour, alpha = 1 - glow, the emissive mask), the
/// cloud cover (alpha), and THE HEIGHT (red = elevation above the sea,
/// 0..1 - sh_planet marches it for the mountains on the limb). Uploads
/// are per-texel stamps on purpose (buffer byte order is platform-
/// dependent; draws are not).
function planet_bake(_pn) {
	if (_pn.row < _pn.th) return false;
	if (surface_exists(_pn.tsurf) && surface_exists(_pn.csurf) && surface_exists(_pn.hsurf)) return true;
	planet_rivers(_pn);   // (once a world, before the first bake - 2026-09-16)
	// a bake under a shader someone left set (the ui fade) would keep its
	// tint for good: the stamps go through the plain pipeline (bug hunt 2026-09-15)
	var _sh = shader_current();
	if (_sh != -1) shader_reset();
	var _tw = _pn.tw, _th = _pn.th;
	if (!surface_exists(_pn.tsurf)) {
		_pn.tsurf = surface_create(_tw, _th);
		surface_set_target(_pn.tsurf);
		draw_clear_alpha(c_black, 1);
		gpu_set_blendmode_ext(bm_one, bm_zero);
		for (var _ty = 0; _ty < _th; _ty++)
		for (var _tx = 0; _tx < _tw; _tx++) {
			var _b3 = _pn.biome[_tx + _ty * _tw];
			draw_sprite_ext(spr_pixel_1x1, 0, _tx, _ty, 1, 1, 0, _pn.pal[_b3], 1 - _pn.glow[_b3]);
		}
		gpu_set_blendmode(bm_normal);
		surface_reset_target();
	}
	if (!surface_exists(_pn.csurf)) {
		_pn.csurf = surface_create(_tw, _th);
		surface_set_target(_pn.csurf);
		draw_clear_alpha(c_black, 0);
		for (var _ty = 0; _ty < _th; _ty++)
		for (var _tx = 0; _tx < _tw; _tx++) {
			var _ca2 = _pn.carr[_tx + _ty * _tw];
			if (_ca2 > 0) draw_sprite_ext(spr_pixel_1x1, 0, _tx, _ty, 1, 1, 0, c_white, _ca2);
		}
		surface_reset_target();
	}
	if (!surface_exists(_pn.hsurf)) {
		// height above the sea (or the world's base level), 0..1 in red:
		// water is flat, the land climbs, peaks reach 1
		_pn.hsurf = surface_create(_tw, _th);
		surface_set_target(_pn.hsurf);
		draw_clear_alpha(c_black, 1);
		gpu_set_blendmode_ext(bm_one, bm_zero);
		var _base = (_pn.kind == "gas") ? 1 : max(_pn.sea, .34);
		for (var _ty = 0; _ty < _th; _ty++)
		for (var _tx = 0; _tx < _tw; _tx++) {
			var _i = _tx + _ty * _tw;
			var _h = (_pn.kind == "gas") ? 0 : clamp((_pn.elev[_i] - _base) / max(.001, 1 - _base), 0, 1);
			// the gradient rides a curve so lowlands stay low and the
			// peaks stand up (the tallest 20% carries half the relief)
			_h = power(_h, 1.6);
			var _v = floor(_h * 255);
			// (green marks WATER - deep ocean, ocean, shallows - for the shader's glint, 2026-09-15)
			var _bw = _pn.biome[_i];
			var _wat = (_pn.kind != "gas" && (_bw == 0 || _bw == 1 || _bw == 11)) ? 255 : 0;
			draw_sprite_ext(spr_pixel_1x1, 0, _tx, _ty, 1, 1, 0, make_colour_rgb(_v, _wat, 0), 1);
		}
		gpu_set_blendmode(bm_normal);
		surface_reset_target();
	}
	if (_sh != -1) shader_set(_sh);
	return true;
}
