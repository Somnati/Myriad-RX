/// @description tile_mat_draw(kind, x, y, w, h, col, alpha, [seed]) -
/// a tile body through sh_tile_mat: one stretched pixel with the
/// material's uniforms set around it. The rims, studs and pips draw
/// over it afterwards as plain spans (tile_shape_draw). The colour
/// handed in IS the output's mean (the colour law - read the shader).
/// @param kind   sh_tile_mat's u_kind (1 sheen 2 liquid 3 hole 4 stars)
/// @param x      the body rect, room px
/// @param y
/// @param w
/// @param h
/// @param col
/// @param alpha
/// @param [seed] per-tile phase (a liquid's own drift, the floor's grain)
/// @param [sprite] true = spr_tile frame 2 (DE's rounded slab) is the quad:
///                the shader samples it, so its alpha is the outline
function tile_mat_draw(_kind, _x, _y, _w, _h, _col, _a, _seed = 0, _sprite = false) {
	static u_quad  = shader_get_uniform(sh_tile_mat, "u_quad");
	static u_kind  = shader_get_uniform(sh_tile_mat, "u_kind");
	static u_col   = shader_get_uniform(sh_tile_mat, "u_col");
	static u_alpha = shader_get_uniform(sh_tile_mat, "u_alpha");
	static u_time  = shader_get_uniform(sh_tile_mat, "u_time");
	static u_amp   = shader_get_uniform(sh_tile_mat, "u_amp");
	static u_view  = shader_get_uniform(sh_tile_mat, "u_view");
	static u_par   = shader_get_uniform(sh_tile_mat, "u_par");
	static u_seed  = shader_get_uniform(sh_tile_mat, "u_seed");

	// ⚖️ INSIDE A PANEL'S FADE (his report, 2026-09-13: "the tiles room fade
	// out effect doesn't have an alpha"): the board dissolves through
	// sh_ui_fade, set once in front of every draw - and this used to
	// shader_reset() on its way out, dropping the fade for everything drawn
	// after the first material tile. The fade's value folds into this
	// draw's alpha, and the fade shader is put back afterwards
	var _prev = shader_current();
	var _fade = (_prev == sh_ui_fade && variable_global_exists("ui_fade_a")) ? g.ui_fade_a : 1;
	shader_set(sh_tile_mat);
	shader_set_uniform_f(u_quad, _x, _y, _w, _h);
	shader_set_uniform_f(u_kind, _kind);
	shader_set_uniform_f(u_col, colour_get_red(_col) / 255, colour_get_green(_col) / 255, colour_get_blue(_col) / 255);
	shader_set_uniform_f(u_alpha, _a * _fade);
	shader_set_uniform_f(u_time, (current_time mod 3600000) / 1000);
	shader_set_uniform_f(u_amp, TILE_MAT_AMP);
	// THE EYE for the hole's parallax: the room's centre. The floor may
	// shift at most TILE_MAT_PAR px at the room's edge
	shader_set_uniform_f(u_view, room_width * .5, room_height * .5);
	shader_set_uniform_f(u_par, TILE_MAT_PAR / max(1, room_width * .5));
	shader_set_uniform_f(u_seed, _seed);
	// the shader multiplies by the sampled texel: a stretched white pixel
	// is the plain rectangle, the slab sprite is DE's outline
	if (_sprite)
		draw_sprite_ext(spr_tile, 2, _x, _y, _w / sprite_get_width(spr_tile), _h / sprite_get_height(spr_tile), 0, c_white, 1);
	else
		draw_sprite_ext(spr_pixel_1x1, 0, _x, _y, _w, _h, 0, c_white, 1);
	if (_prev == sh_ui_fade) { shader_set(sh_ui_fade); shader_set_uniform_f(g.ui_fade_u, _fade); }
	else shader_reset();
}
