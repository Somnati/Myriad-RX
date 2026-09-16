/// @description nebula_draw(neb, x, y, r, alpha) - a nebula (galaxy_nebulae's) as a procedural cloud, centred on x / y, r px its radius
/// sh_nebula on the white quad, additive (the caller sets bm_add): the
/// disc's edge is bent by two noise fields, its body mottled and shot with
/// filaments, its two colours mixed by the noise - never a circle. A
/// shader that failed to compile draws nothing, so the soft glow stands in
/// and the page (the galaxy's) names the failure.
function nebula_draw(_nb, _x, _y, _r, _a) {
	static _u = undefined;
	if (is_undefined(_u)) _u = { seed : shader_get_uniform(sh_nebula, "u_seed"), col : shader_get_uniform(sh_nebula, "u_col"), col2 : shader_get_uniform(sh_nebula, "u_col2") };
	if (_r < 1 || _a <= 0) return;
	if (!shader_is_compiled(sh_nebula)) {
		var _gs = _r * 2 / max(1, sprite_get_width(spr_vis_glow_soft));
		draw_sprite_ext(spr_vis_glow_soft, 0, _x, _y, _gs, _gs, 0, _nb.col, _a * .5);
		return;
	}
	var _q = nebula_quad();
	shader_set(sh_nebula);
	shader_set_uniform_f(_u.seed, _nb.seed);
	shader_set_uniform_f(_u.col, colour_get_red(_nb.col) / 255, colour_get_green(_nb.col) / 255, colour_get_blue(_nb.col) / 255);
	shader_set_uniform_f(_u.col2, colour_get_red(_nb.col2) / 255, colour_get_green(_nb.col2) / 255, colour_get_blue(_nb.col2) / 255);
	draw_surface_ext(_q, _x - _r, _y - _r, _r, _r, 0, c_white, _a);   // (2 px wide: a scale of r is a cloud 2r across)
	shader_reset();
}
