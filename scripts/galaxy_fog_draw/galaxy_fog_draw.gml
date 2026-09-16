/// @description galaxy_fog_draw(sky, cam, cx, cy, w, h, canvas) - the milky way over the current target
/// sh_sky_fog, additive: every pixel of the canvas surface (w x h - its
/// contents are never read, its texcoords are the rays) becomes a view
/// ray through the same projection the stars use, rotated into world
/// space by the camera; the band is fbm density about the galactic
/// plane, warm toward the core's bearing. The caller owns the canvas
/// (surface_create(w, h), freed with the page). The nebulae (galaxy_nebulae,
/// the sky's brightest eight) are painted here too, per pixel on the sphere
/// (a billboard swung round the camera when one was near - 2026-09-16).
function galaxy_fog_draw(_sky, _cam, _cx, _cy, _w, _h, _canvas, _sun = true) {   // (_sun: the system's star is on this sky - the inside pass spares it; false on the system page)
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
		corein : shader_get_uniform(sh_sky_fog, "u_corein"),
		dith : shader_get_uniform(sh_sky_fog, "u_dither"),
		nebn : shader_get_uniform(sh_sky_fog, "u_nebn"),
		nebd : shader_get_uniform(sh_sky_fog, "u_nebd"),
		nebp : shader_get_uniform(sh_sky_fog, "u_nebp"),
		nebc : shader_get_uniform(sh_sky_fog, "u_nebc"),
		nebc2 : shader_get_uniform(sh_sky_fog, "u_nebc2"),
	};
	static _ui = undefined;
	if (is_undefined(_ui)) _ui = {
		cam : shader_get_uniform(sh_sky_inside, "u_cam"), geom : shader_get_uniform(sh_sky_inside, "u_geom"), ctr : shader_get_uniform(sh_sky_inside, "u_ctr"),
		cell : shader_get_uniform(sh_sky_inside, "u_cell"), s : shader_get_uniform(sh_sky_inside, "u_s"), t : shader_get_uniform(sh_sky_inside, "u_t"),
		col : shader_get_uniform(sh_sky_inside, "u_col"), col2 : shader_get_uniform(sh_sky_inside, "u_col2"), seed : shader_get_uniform(sh_sky_inside, "u_seed"),
		amp : shader_get_uniform(sh_sky_inside, "u_amp"), ext : shader_get_uniform(sh_sky_inside, "u_ext"), mode : shader_get_uniform(sh_sky_inside, "u_mode"),
		time : shader_get_uniform(sh_sky_inside, "u_time"), dith : shader_get_uniform(sh_sky_inside, "u_dither"),
		sun : shader_get_uniform(sh_sky_inside, "u_sun"), sunon : shader_get_uniform(sh_sky_inside, "u_sunon"),
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
	shader_set_uniform_f(_u.amp, _cfg.sky_fog_amp * (_sky[$ "fog_boost"] ?? 1));   // (brighter in a rich neighbourhood, brightest in the core - 2026-09-16)
	shader_set_uniform_f(_u.corein, _sky[$ "core_in"] ?? 0);
	shader_set_uniform_f(_u.cell, planet_config().px_size);
	shader_set_uniform_f(_u.edge, _sky.fog_edge);
	shader_set_uniform_f(_u.dith, page_float() ? 0 : 1);   // (a float page dithers once, at its blit)
	// THE NEBULAE (2026-09-16): the brightest eight in reach (galaxy_sky_build's nebs, sorted there), on the sphere - the
	// shader's arrays are eight; a pixel outside a cloud's cone pays one dot product for it, no more
	var _nbs = _sky[$ "nebs"] ?? [], _nn = min(8, array_length(_nbs)), _nas = _cfg[$ "neb_alpha_sky"] ?? .3;
	var _nd = array_create(24, 0), _np = array_create(32, 0), _nc = array_create(24, 0), _nc2 = array_create(24, 0);
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
	// INSIDE A NEBULA (2026-09-16): the sky through the cloud - what lies beyond dims by the path out along each ray
	// (a multiply pass), then the cloud's own glow by the same path (an add pass); softened toward the cloud's edge
	var _in = _sky[$ "inside"];
	if (is_struct(_in) && shader_is_compiled(sh_sky_inside)) {
		var _soft = 1 - power(_in.edge, 3);   // (the edge fraction: 1 at the centre, 0 at the wall - no pop entering or leaving)
		var _nb = _in.nb;
		shader_set(sh_sky_inside);
		shader_set_uniform_f_array(_ui.cam, _cam);
		shader_set_uniform_f(_ui.geom, _w, _h);
		shader_set_uniform_f(_ui.ctr, _cx, _cy);
		shader_set_uniform_f(_ui.cell, planet_config().px_size);
		shader_set_uniform_f(_ui.s, _in.s[0], _in.s[1], _in.s[2]);
		shader_set_uniform_f(_ui.t, _in.t);
		shader_set_uniform_f(_ui.col, colour_get_red(_nb.col) / 255, colour_get_green(_nb.col) / 255, colour_get_blue(_nb.col) / 255);
		shader_set_uniform_f(_ui.col2, colour_get_red(_nb.col2) / 255, colour_get_green(_nb.col2) / 255, colour_get_blue(_nb.col2) / 255);
		shader_set_uniform_f(_ui.seed, _nb.seed);
		shader_set_uniform_f(_ui.amp, (_cfg[$ "neb_in_amp"] ?? .55) * _soft);
		shader_set_uniform_f(_ui.ext, (_cfg[$ "neb_in_ext"] ?? 1.2) * _soft);
		shader_set_uniform_f(_ui.time, (current_time mod 100000) / 1000);
		shader_set_uniform_f(_ui.dith, page_float() ? 0 : 1);
		var _lw = _sky.light_w;
		shader_set_uniform_f(_ui.sun, _lw[0], _lw[1], _lw[2]);
		shader_set_uniform_f(_ui.sunon, _sun ? 1 : 0);
		shader_set_uniform_f(_ui.mode, 0);
		gpu_set_blendmode_ext(bm_dest_colour, bm_zero);   // (multiply: the sky so far, dimmed by the cloud)
		draw_surface(_canvas, 0, 0);
		shader_set_uniform_f(_ui.mode, 1);
		gpu_set_blendmode(bm_add);
		draw_surface(_canvas, 0, 0);
		shader_reset();
	}
	gpu_set_blendmode(bm_normal);
}
