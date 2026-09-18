/// @description star_draw(x, y, r, col, seed, [fade], [cam]) - a star through sh_star, centred on x / y, its disc r px in radius (the corona to 2.4 r), additive; cam = the view's camera (view -> world) so the face and the rays are the world's
/// The one star painter (2026-09-16): the system page's star and every
/// sky's sun. A shader that failed to compile draws nothing, so the old
/// glow frames stand in (and the galaxy page names the failure).
function star_draw(_x, _y, _r, _col, _seed, _fade = 1, _cam = undefined) {
	static _u = undefined;
	if (is_undefined(_u)) _u = { col : shader_get_uniform(sh_star, "u_col"), seed : shader_get_uniform(sh_star, "u_seed"), time : shader_get_uniform(sh_star, "u_time"),
	                             rad : shader_get_uniform(sh_star, "u_rad"), fade : shader_get_uniform(sh_star, "u_fade"), dith : shader_get_uniform(sh_star, "u_dither"), cam : shader_get_uniform(sh_star, "u_cam") };
	if (_r < .5 || _fade <= 0) return;
	if (!shader_is_compiled(sh_star)) {
		var _ss = _r / 6;
		draw_sprite_ext(spr_star_glow, 5, _x, _y, 2.4 * _ss, 2.4 * _ss, 0, _col, .9 * _fade);
		draw_sprite_ext(spr_star_glow, 5, _x, _y, 1.2 * _ss, 1.2 * _ss, 0, merge_colour(_col, c_white, .5), .9 * _fade);
		draw_sprite_ext(spr_star_glow, 3, _x, _y, max(1, _ss * .9), max(1, _ss * .9), 0, c_white, _fade);
		return;
	}
	var _q = nebula_quad(), _hq = _r * 2.4;
	// (one, inv_src_alpha) on the colour, the page's alpha untouched (zero, one): the shader's alpha is the DISC's coverage,
	// so inside the disc the star REPLACES the page - a world behind a giant showed through its additive disc (his report
	// 2026-09-17) - and outside it, alpha 0, the corona ADDS (true one/one: GameMaker's bm_add is src_alpha/one, which with
	// an alpha of 0 added nothing at all - "my star is invisible"; and an alpha of 1 stamped the square into the page's
	// alpha, q188's faint box - hence the untouched alpha)
	gpu_set_blendmode_ext_sepalpha(bm_one, bm_inv_src_alpha, bm_zero, bm_one);
	shader_set(sh_star);
	shader_set_uniform_f(_u.col, colour_get_red(_col) / 255, colour_get_green(_col) / 255, colour_get_blue(_col) / 255);
	shader_set_uniform_f(_u.seed, _seed);
	shader_set_uniform_f(_u.time, (current_time mod 10000000) / 1000);
	shader_set_uniform_f(_u.rad, 1 / 2.4);
	shader_set_uniform_f(_u.fade, _fade);
	shader_set_uniform_f(_u.dith, page_float() ? 0 : 1);
	shader_set_uniform_f_array(_u.cam, is_array(_cam) ? _cam : [1, 0, 0, 0, 1, 0, 0, 0, 1]);
	draw_surface_ext(_q, _x - _hq, _y - _hq, _hq, _hq, 0, c_white, 1);   // (the 2 px quad at a scale of hq: 2 hq across)
	shader_reset();
	gpu_set_blendmode(bm_normal);
}
