/// @description galaxy_fog_draw(sky, cam, cx, cy, w, h, canvas) - the milky way over the current target
/// sh_sky_fog, additive: every pixel of the canvas surface (w x h - its
/// contents are never read, its texcoords are the rays) becomes a view
/// ray through the same projection the stars use, rotated into world
/// space by the camera; the band is fbm density about the galactic
/// plane, warm toward the core's bearing. The caller owns the canvas
/// (surface_create(w, h), freed with the page). The nebulae are things
/// of their own (galaxy_nebulae), drawn by galaxy_sky_draw (2026-09-16).
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
	draw_surface(_canvas, 0, 0);
	shader_reset();
	gpu_set_blendmode(bm_normal);
}
