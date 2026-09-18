/// @description hole_draw(x, y, r, col, seed, [fade], [cam]) - a BLACK HOLE through sh_hole where a star would be, centred on x / y, r the star's nominal radius (the horizon half of it, the disc to 2.2 r); the sky already on the page is bent round it
/// THE LENS needs the page under the hole: the current render target is
/// copied (a scratch surface, sized to the quad) and drawn back as the
/// quad's own texture, so the shader reads the sky at bent coordinates.
/// The copy is taken with the target let go and set again (a copy from
/// the live target is not to be trusted). Drawing to the screen itself
/// (no target) draws the hole without the lens. A shader that failed to
/// compile draws a plain black disc with a ring
function hole_draw(_x, _y, _r, _col, _seed, _fade = 1, _cam = undefined) {
	static _u = undefined;
	static _lens = -1;
	if (is_undefined(_u)) _u = { col : shader_get_uniform(sh_hole, "u_col"), seed : shader_get_uniform(sh_hole, "u_seed"), time : shader_get_uniform(sh_hole, "u_time"),
	                             rh : shader_get_uniform(sh_hole, "u_rh"), fade : shader_get_uniform(sh_hole, "u_fade"), dith : shader_get_uniform(sh_hole, "u_dither"), cam : shader_get_uniform(sh_hole, "u_cam") };
	if (_r < .5 || _fade <= 0) return;
	var _hq = max(4, ceil(_r * 2.2)), _qw = _hq * 2;
	if (!shader_is_compiled(sh_hole)) {
		draw_sprite_ext(spr_star_glow, 5, _x, _y, _r * .5 / 6, _r * .5 / 6, 0, _col, .9 * _fade);
		draw_circle_colour(_x, _y, _r * .5, c_black, c_black, false);
		return;
	}
	var _tg = surface_get_target();
	if (!surface_exists(_lens) || surface_get_width(_lens) != _qw || surface_get_height(_lens) != _qw) { if (surface_exists(_lens)) surface_free(_lens); _lens = surface_create(_qw, _qw); }
	var _x0 = floor(_x - _hq), _y0 = floor(_y - _hq);
	if (_tg >= 0 && surface_exists(_tg)) {
		surface_reset_target();
		surface_copy_part(_lens, 0, 0, _tg, _x0, _y0, _qw, _qw);
		surface_set_target(_tg);
	} else {
		surface_set_target(_lens); draw_clear_alpha(c_black, 1); surface_reset_target();
	}
	shader_set(sh_hole);
	shader_set_uniform_f(_u.col, colour_get_red(_col) / 255, colour_get_green(_col) / 255, colour_get_blue(_col) / 255);
	shader_set_uniform_f(_u.seed, _seed);
	shader_set_uniform_f(_u.time, (current_time mod 10000000) / 1000);
	shader_set_uniform_f(_u.rh, (_r * .5) / _hq);
	shader_set_uniform_f(_u.fade, _fade);
	shader_set_uniform_f(_u.dith, page_float() ? 0 : 1);
	shader_set_uniform_f_array(_u.cam, is_array(_cam) ? _cam : [1, 0, 0, 0, 1, 0, 0, 0, 1]);
	draw_surface_ext(_lens, _x0, _y0, 1, 1, 0, c_white, 1);
	shader_reset();
}
