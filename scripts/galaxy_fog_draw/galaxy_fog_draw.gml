/// @description galaxy_fog_draw(sky, cam, cx, cy, w, h, canvas) - the milky way over the current target
/// sh_sky_fog, additive: every pixel of the canvas surface (w x h - its
/// contents are never read, its texcoords are the rays) becomes a view
/// ray through the same projection the stars use, rotated into world
/// space by the camera; the band is fbm density about the galactic
/// plane, warm toward the core's bearing. The caller owns the canvas
/// (surface_create(w, h), freed with the page). The nebulae: the map's
/// sheet (galaxy_neb_sheet) marched along the plane from this star's spot
/// - the same clouds as the map, at their bearings and distances (2026-09-16).
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
		neb  : shader_get_sampler_index(sh_sky_fog, "u_neb"),
		npos : shader_get_uniform(sh_sky_fog, "u_npos"),
		nprm : shader_get_uniform(sh_sky_fog, "u_nprm"),
	};
	if (!surface_exists(_canvas)) return;
	var _cfg = starmap_config();
	// THE NEBULAE (2026-09-16): the map's sheet and this star's place on it - the shader marches the plane from there
	var _sheet = galaxy_neb_sheet();
	var _sm = starmap_get(), _me = _sm.stars[_sky.star];
	draw_set_alpha(1);
	gpu_set_blendmode(bm_add);
	shader_set(sh_sky_fog);
	texture_set_stage(_u.neb, surface_get_texture(_sheet));
	gpu_set_tex_filter_ext(_u.neb, true);
	gpu_set_tex_repeat_ext(_u.neb, false);
	shader_set_uniform_f(_u.npos, _me.x / _sm.width, _me.y / _sm.width);
	shader_set_uniform_f(_u.nprm, (_cfg[$ "sky_neb_range"] ?? 1400) / _sm.width, (_cfg[$ "sky_neb_thick"] ?? 90) / _sm.width, _cfg[$ "sky_neb_amp"] ?? 1, 0);
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
