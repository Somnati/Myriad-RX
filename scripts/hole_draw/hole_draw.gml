/// @description hole_draw(x, y, r, col, seed, [fade], [cam]) - a BLACK HOLE through sh_hole where a star would be, centred on x / y, r the star's nominal radius (the shadow half of it, the disc to 2.2 r); the sky already on the page is bent round it
/// THE LENS needs the page under the hole: the current render target is
/// let go, the square under the quad DRAWN into a scratch sheet (one
/// sheet for every hole - the quad's share of it goes to the shader as
/// u_uv), the target set again, and the sheet's part drawn back as the
/// quad's own texture, so the shader reads the sky at bent coordinates.
/// A draw, not surface_copy_part: the page is a float surface and the
/// copy into an 8-bit scratch came out as garbage - a grey disc with
/// bands round every hole, "a subtle black outline" at its edge (his
/// report 2026-09-17, q195). The sheet takes the page's own format.
/// Drawing to the screen itself (no target) draws the hole on black. A
/// shader that failed to compile draws a plain black disc with a ring.
/// The blend is (one, inv_src_alpha) with the page's alpha untouched:
/// the shader's output is premultiplied - the bent sky replaces the
/// page, the disc lies over it, the photon ring adds
/// src / srcx / srcy (q196): read the sky from THAT surface (the page) round (srcx, srcy) instead of the current
/// target - a frozen render of a neighbour bakes into its own sheet this way; bake = true writes the premultiplied
/// result and its alpha into a cleared sheet (one, inv_src_alpha on both), for a blit later
function hole_draw(_x, _y, _r, _col, _seed, _fade = 1, _cam = undefined, _src = undefined, _srcx = 0, _srcy = 0, _bake = false) {
	static _u = undefined;
	static _lens = -1;
	if (is_undefined(_u)) _u = { col : shader_get_uniform(sh_hole, "u_col"), seed : shader_get_uniform(sh_hole, "u_seed"), time : shader_get_uniform(sh_hole, "u_time"),
	                             rh : shader_get_uniform(sh_hole, "u_rh"), fade : shader_get_uniform(sh_hole, "u_fade"), dith : shader_get_uniform(sh_hole, "u_dither"), cam : shader_get_uniform(sh_hole, "u_cam"),
	                             uv : shader_get_uniform(sh_hole, "u_uv") };
	if (_r < .5 || _fade <= 0) return;
	var _hq = max(4, ceil(_r * 2.2)), _qw = _hq * 2;
	if (!shader_is_compiled(sh_hole)) {
		draw_sprite_ext(spr_star_glow, 5, _x, _y, _r * .5 / 6, _r * .5 / 6, 0, _col, .9 * _fade);
		draw_circle_colour(_x, _y, _r * .5, c_black, c_black, false);
		return;
	}
	var _tg = surface_get_target();
	var _has = (_tg >= 0 && surface_exists(_tg));
	var _fmt = _has ? surface_get_format(_tg) : surface_rgba8unorm;
	var _lw = max(256, _qw);
	if (!surface_exists(_lens) || surface_get_width(_lens) < _qw || surface_get_format(_lens) != _fmt) { if (surface_exists(_lens)) surface_free(_lens); _lens = surface_create(_lw, _lw, _fmt); }
	_lw = surface_get_width(_lens);
	var _x0 = floor(_x - _hq), _y0 = floor(_y - _hq);
	var _use_src = !is_undefined(_src) && surface_exists(_src);
	var _pg = _use_src ? _src : _tg, _pg_ok = _use_src || _has;
	var _ox = _use_src ? floor(_srcx - _hq) : _x0, _oy = _use_src ? floor(_srcy - _hq) : _y0;
	if (_has) surface_reset_target();
	surface_set_target(_lens);
	gpu_set_blendmode_ext(bm_one, bm_zero);   // (an exact overwrite: the square black first, then the page's part where it lies on the page)
	draw_sprite_ext(spr_pixel_1x1, 0, 0, 0, _qw, _qw, 0, c_black, 1);
	if (_pg_ok) {
		var _pw = surface_get_width(_pg), _ph = surface_get_height(_pg);
		var _sx0 = max(_ox, 0), _sy0 = max(_oy, 0), _sx1 = min(_ox + _qw, _pw), _sy1 = min(_oy + _qw, _ph);
		if (_sx1 > _sx0 && _sy1 > _sy0) draw_surface_part_ext(_pg, _sx0, _sy0, _sx1 - _sx0, _sy1 - _sy0, _sx0 - _ox, _sy0 - _oy, 1, 1, c_white, 1);
	}
	surface_reset_target();
	if (_has) surface_set_target(_tg);
	if (_bake) gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);   // (into a cleared sheet: the alpha lands too)
	else gpu_set_blendmode_ext_sepalpha(bm_one, bm_inv_src_alpha, bm_zero, bm_one);
	shader_set(sh_hole);
	shader_set_uniform_f(_u.col, colour_get_red(_col) / 255, colour_get_green(_col) / 255, colour_get_blue(_col) / 255);
	shader_set_uniform_f(_u.seed, _seed);
	shader_set_uniform_f(_u.time, (current_time mod 10000000) / 1000);
	shader_set_uniform_f(_u.rh, (_r * .5) / _hq);
	shader_set_uniform_f(_u.fade, _fade);
	shader_set_uniform_f(_u.dith, page_float() ? 0 : 1);
	shader_set_uniform_f_array(_u.cam, is_array(_cam) ? _cam : [1, 0, 0, 0, 1, 0, 0, 0, 1]);
	shader_set_uniform_f(_u.uv, _qw / _lw, _qw / _lw);
	draw_surface_part_ext(_lens, 0, 0, _qw, _qw, _x0, _y0, 1, 1, c_white, 1);
	shader_reset();
	gpu_set_blendmode(bm_normal);
}
