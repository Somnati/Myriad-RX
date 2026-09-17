/// @description planet_draw(pn, cx, cy, pr, [spin_deg]) - the world, one
/// quad through sh_planet: the terrain texture on a raycast sphere,
/// clouds in two shells, the atmosphere, a ring on some, the city
/// lights by night, and THE MOUNTAINS - the shader marches the height
/// texture so the peaks stand out of the silhouette as it turns (his
/// wish from the tech demo). The sun is fixed to the upper left.
/// Bakes the textures if they are missing. pr = the radius in px; cam /
/// light_w = the orbit camera and the world-space sun (undefined = the
/// fixed view: a spinning world lit from upper left); cfade
/// 0..1 thins the clouds (the region zoom, his ask 2026-09-15). Uniforms
/// persist between draws, so every one is set every call.
/// msh (2026-09-16) = the moons' view-space casters [[x, y, z, size], ...] (moon_view_pos); storms = the storm regions' spots in texture space [[x, y, z], ...]
function planet_draw(_pn, _cx, _cy, _pr, _spin = undefined, _cfade = 1, _cam = undefined, _light_w = undefined, _msh = undefined, _storms = undefined) {
	if (!planet_bake(_pn)) return false;
	var _cfg = planet_config();
	if (is_undefined(_spin)) _spin = planet_spin_now(_pn);   // the universal clock (the agent's day / night agrees with it)
	static _u = undefined;
	if (is_undefined(_u)) _u = {
		rot   : shader_get_uniform(sh_planet, "u_rot"),
		crot  : shader_get_uniform(sh_planet, "u_crot"),
		light : shader_get_uniform(sh_planet, "u_light"),
		atmo  : shader_get_uniform(sh_planet, "u_atmo"),
		tsize : shader_get_uniform(sh_planet, "u_tsize"),
		pad   : shader_get_uniform(sh_planet, "u_pad"),
		time  : shader_get_uniform(sh_planet, "u_time"),
		dither : shader_get_uniform(sh_planet, "u_dither"),
		cells : shader_get_uniform(sh_planet, "u_cells"),
		ring  : shader_get_uniform(sh_planet, "u_ring"),
		raxis : shader_get_uniform(sh_planet, "u_raxis"),
		rcol  : shader_get_uniform(sh_planet, "u_ringcol"),
		city  : shader_get_uniform(sh_planet, "u_city"),
		cityn : shader_get_uniform(sh_planet, "u_cityn"),
		relief : shader_get_uniform(sh_planet, "u_relief"),
		bump  : shader_get_uniform(sh_planet, "u_bump"),
		cfade : shader_get_uniform(sh_planet, "u_cfade"),
		crelief : shader_get_uniform(sh_planet, "u_crelief"),
		moonsh : shader_get_uniform(sh_planet, "u_moonsh"), moonn : shader_get_uniform(sh_planet, "u_moonn"),
		storm : shader_get_uniform(sh_planet, "u_storm"), stormn : shader_get_uniform(sh_planet, "u_stormn"),
		aurora : shader_get_uniform(sh_planet, "u_aurora"),
		cloud : shader_get_sampler_index(sh_planet, "u_cloud"),
		height : shader_get_sampler_index(sh_planet, "u_height"),
	};
	// the camera looks down -z at the world; the world turns about its
	// tilted axis; the shader wants texture-from-view rows. With a CAMERA
	// (the orbit view, 2026-09-15: cam = view -> world, the tech demo's
	// obj_planet) the sun is a WORLD vector (light_w: the system's star at
	// its real bearing) rotated into view space, so orbiting behind the
	// world puts you over its night; without one the sun sits upper left
	if (is_undefined(_cam)) _cam = [1, 0, 0, 0, 1, 0, 0, 0, 1];
	var _ct = mat3_transpose(_cam);
	var _w  = mat3_mul(mat3_rot(0, 0, 1, _pn.tilt), mat3_rot(0, 1, 0, _spin));
	var _wc = mat3_mul(mat3_rot(0, 0, 1, _pn.tilt), mat3_rot(0, 1, 0, _spin * 1.16 + 31));
	var _m  = mat3_mul(mat3_transpose(_w), _cam);
	var _mc = mat3_mul(mat3_transpose(_wc), _cam);
	var _lv = is_array(_light_w) ? mat3_apply(_ct, _light_w[0], _light_w[1], _light_w[2]) : [-.55, -.5, .67];
	var _ll = max(.001, sqrt(_lv[0] * _lv[0] + _lv[1] * _lv[1] + _lv[2] * _lv[2]));
	_lv = [_lv[0] / _ll, _lv[1] / _ll, _lv[2] / _ll];
	var _ax = mat3_apply(mat3_rot(0, 0, 1, _pn.tilt), 0, 1, 0);
	_ax = mat3_apply(_ct, _ax[0], _ax[1], _ax[2]);
	var _pad = _pn.ring ? 2.35 : _cfg.pad;
	var _q = _pr * _pad;
	// THE QUAD ON THE PIXEL GRID (his report, 2026-09-15: "higher res while
	// zooming, hard pixels when it settles"): the shader's cells are px_size
	// room px anchored at the quad's corner - a fractional corner or extent
	// slid the cells over the screen pixels every frame of the zoom, and the
	// eye read the shimmer as detail. Whole cells, a corner on the grid
	var _qx = _cx - _q, _qy = _cy - _q;
	if (_cfg.px_size > 0) {
		var _pxs = _cfg.px_size;
		_q = max(_pxs, round(_q / _pxs) * _pxs);
		_qx = round((_cx - _q) / _pxs) * _pxs; _qy = round((_cy - _q) / _pxs) * _pxs;
	}
	shader_set(sh_planet);
	shader_set_uniform_f_array(_u.rot, _m);
	shader_set_uniform_f_array(_u.crot, _mc);
	shader_set_uniform_f(_u.light, _lv[0], _lv[1], _lv[2]);
	shader_set_uniform_f(_u.atmo, colour_get_red(_pn.atmo) / 255, colour_get_green(_pn.atmo) / 255, colour_get_blue(_pn.atmo) / 255);
	shader_set_uniform_f(_u.tsize, _pn.tw, _pn.th);
	shader_set_uniform_f(_u.pad, _pad);
	shader_set_uniform_f(_u.time, (current_time mod 100000) / 1000);
	shader_set_uniform_f(_u.cells, (_cfg.px_size > 0) ? (2 * _q) / _cfg.px_size : 0);
	shader_set_uniform_f(_u.ring, _pn.ring ? .85 : 0);
	shader_set_uniform_f(_u.raxis, _ax[0], _ax[1], _ax[2]);
	shader_set_uniform_f(_u.rcol, colour_get_red(_pn.ring_col) / 255, colour_get_green(_pn.ring_col) / 255, colour_get_blue(_pn.ring_col) / 255);
	var _bump = (variable_global_exists("planet_relief_pct") ? g.planet_relief_pct : 140) / 100;   // settings > visuals: mountain relief
	shader_set_uniform_f(_u.relief, (_pn.kind == "gas") ? 0 : _cfg.relief * max(.4, _bump));   // (the silhouette rides the knob too, gently)
	shader_set_uniform_f(_u.bump, (_pn.kind == "gas") ? 0 : _bump);
	shader_set_uniform_f(_u.cfade, clamp(_cfade, 0, 1));
	shader_set_uniform_f(_u.crelief, (_cfg[$ "crelief"] ?? .05) * ((_pn.kind == "gas") ? .5 : 1));   // (the cloud relief - 2026-09-17; a giant's deck lower)
	// the moons' shadows, the storms' lightning, the aurora (2026-09-16)
	var _mshv = array_create(16, 0), _mshn = 0;
	if (is_array(_msh)) { _mshn = min(4, array_length(_msh)); for (var _i = 0; _i < _mshn; _i++) { _mshv[_i * 4] = _msh[_i][0]; _mshv[_i * 4 + 1] = _msh[_i][1]; _mshv[_i * 4 + 2] = _msh[_i][2]; _mshv[_i * 4 + 3] = _msh[_i][3]; } }
	shader_set_uniform_f_array(_u.moonsh, _mshv);
	shader_set_uniform_f(_u.moonn, _mshn);
	var _stv = array_create(12, 0), _stn = 0;
	if (is_array(_storms)) { _stn = min(3, array_length(_storms)); for (var _i = 0; _i < _stn; _i++) { _stv[_i * 4] = _storms[_i][0]; _stv[_i * 4 + 1] = _storms[_i][1]; _stv[_i * 4 + 2] = _storms[_i][2]; _stv[_i * 4 + 3] = 1; } }
	shader_set_uniform_f_array(_u.storm, _stv);
	shader_set_uniform_f(_u.stormn, _stn);
	shader_set_uniform_f(_u.aurora, (_pn.kind != "gas" && ((_pn.clim > .6) || (hash_mix(_pn.seed, 4242) mod 100 < 35))) ? 1 : 0);   // (cold worlds, and a third of the rest)
	shader_set_uniform_f(_u.dither, (variable_global_exists("dither_off") && g.dither_off) ? 0 : 1);   // (into a float page: the page dithers once at its blit)
	var _cty = array_create(24, 0);
	var _ctn = 0;
	if (!is_undefined(_pn.civ)) {
		var _cts = _pn.civ.cities;
		_ctn = 0;   // (city lights are the tech demo's, unused here - gone, his call 2026-09-15)
		for (var _i = 0; _i < _ctn; _i++) {
			_cty[_i * 4] = _cts[_i].x; _cty[_i * 4 + 1] = _cts[_i].y; _cty[_i * 4 + 2] = _cts[_i].z; _cty[_i * 4 + 3] = _cts[_i].r;
		}
	}
	shader_set_uniform_f_array(_u.city, _cty);
	shader_set_uniform_f(_u.cityn, _ctn);
	texture_set_stage(_u.cloud, surface_get_texture(_pn.csurf));
	texture_set_stage(_u.height, surface_get_texture(_pn.hsurf));
	draw_surface_ext(_pn.tsurf, _qx, _qy, (2 * _q) / _pn.tw, (2 * _q) / _pn.th, 0, c_white, 1);
	shader_reset();
	return true;
}
