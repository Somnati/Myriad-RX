/// @description galaxy_fog_draw(sky, cam, cx, cy, w, h, canvas) - the milky way over the current target
/// sh_sky_fog, additive: every pixel of the canvas surface (w x h - its
/// contents are never read, its texcoords are the rays) becomes a view
/// ray through the same projection the stars use, rotated into world
/// space by the camera; the band is fbm density about the galactic
/// plane, warm toward the core's bearing. The caller owns the canvas
/// (surface_create(w, h), freed with the page). The nebulae (galaxy_nebulae,
/// the sky's nearest four) are painted here too, per pixel on the sphere
/// (a billboard swung round the camera when one was near - 2026-09-16).
function galaxy_fog_draw(_sky, _cam, _cx, _cy, _w, _h, _canvas) {
	static _u = undefined;
	if (is_undefined(_u)) _u = {
		cam  : shader_get_uniform(sh_sky_fog, "u_cam"),
		core : shader_get_uniform(sh_sky_fog, "u_core"),
		geom : shader_get_uniform(sh_sky_fog, "u_geom"),
		ctr  : shader_get_uniform(sh_sky_fog, "u_ctr"),
		seed : shader_get_uniform(sh_sky_fog, "u_seed"),
		time : shader_get_uniform(sh_sky_fog, "u_time"),
		amp  : shader_get_uniform(sh_sky_fog, "u_amp"),
		cell : shader_get_uniform(sh_sky_fog, "u_cell"),
		edge : shader_get_uniform(sh_sky_fog, "u_edge"),
		dith : shader_get_uniform(sh_sky_fog, "u_dither"),
		nebn : shader_get_uniform(sh_sky_fog, "u_nebn"),
		nebd : shader_get_uniform(sh_sky_fog, "u_nebd"),
		nebp : shader_get_uniform(sh_sky_fog, "u_nebp"),
		nebc : shader_get_uniform(sh_sky_fog, "u_nebc"),
		nebc2 : shader_get_uniform(sh_sky_fog, "u_nebc2"),
	};
	var _cfg = starmap_config();
	if (!surface_exists(_canvas)) return;
	if (!shader_is_compiled(sh_sky_fog)) { draw_set_font(fnt); draw_set_halign(fa_left); draw_set_color(c_hred); draw_set_alpha(.95); draw_text(4, _h - 12, "sh_sky_fog failed to compile"); draw_set_alpha(1); return; }   // (2026-09-16: a failed shader draws nothing - the page says so)
	draw_set_alpha(1);
	gpu_set_blendmode(bm_add);
	shader_set(sh_sky_fog);
	shader_set_uniform_f_array(_u.cam, _cam);
	shader_set_uniform_f(_u.core, _sky.core_dir[0], _sky.core_dir[1], _sky.core_dir[2]);
	shader_set_uniform_f(_u.geom, _w, _h);
	shader_set_uniform_f(_u.ctr, _cx, _cy);
	shader_set_uniform_f(_u.seed, _sky.fog_seed);
	shader_set_uniform_f(_u.time, (current_time mod 100000) / 1000);
	shader_set_uniform_f(_u.amp, _cfg.sky_fog_amp);
	shader_set_uniform_f(_u.cell, planet_config().px_size);
	shader_set_uniform_f(_u.edge, _sky.fog_edge);
	shader_set_uniform_f(_u.dith, page_float() ? 0 : 1);   // (a float page dithers once, at its blit)
	// THE NEBULAE (2026-09-16): the brightest four in reach (galaxy_sky_build's nebs, sorted there), on the sphere
	var _nbs = _sky[$ "nebs"] ?? [], _nn = min(4, array_length(_nbs)), _nas = _cfg[$ "neb_alpha_sky"] ?? .3;
	var _nd = array_create(12, 0), _np = array_create(16, 0), _nc = array_create(12, 0), _nc2 = array_create(12, 0);
	for (var _i = 0; _i < _nn; _i++) {
		var _n = _nbs[_i];
		_nd[_i * 3] = _n.x; _nd[_i * 3 + 1] = _n.y; _nd[_i * 3 + 2] = _n.z;
		_np[_i * 4] = dsin(_n.ar); _np[_i * 4 + 1] = dcos(_n.ar); _np[_i * 4 + 2] = _n.b * _nas; _np[_i * 4 + 3] = _n.nb.seed;
		_nc[_i * 3] = colour_get_red(_n.nb.col) / 255; _nc[_i * 3 + 1] = colour_get_green(_n.nb.col) / 255; _nc[_i * 3 + 2] = colour_get_blue(_n.nb.col) / 255;
		_nc2[_i * 3] = colour_get_red(_n.nb.col2) / 255; _nc2[_i * 3 + 1] = colour_get_green(_n.nb.col2) / 255; _nc2[_i * 3 + 2] = colour_get_blue(_n.nb.col2) / 255;
	}
	shader_set_uniform_f(_u.nebn, _nn);
	shader_set_uniform_f_array(_u.nebd, _nd); shader_set_uniform_f_array(_u.nebp, _np);
	shader_set_uniform_f_array(_u.nebc, _nc); shader_set_uniform_f_array(_u.nebc2, _nc2);
	draw_surface(_canvas, 0, 0);
	shader_reset();
	gpu_set_blendmode(bm_normal);
}
