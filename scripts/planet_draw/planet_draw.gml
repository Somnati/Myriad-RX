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
/// lod (2026-09-17) = the ZOOM PATCH (syst_exped_panel's lod_show): { k, u0, v0, uw, vh, tsurf, hsurf } - the window of the map under the view sampled k times finer; undefined = none
function planet_draw(_pn, _cx, _cy, _pr, _spin = undefined, _cfade = 1, _cam = undefined, _light_w = undefined, _msh = undefined, _storms = undefined, _lod = undefined, _pfade = 1) {   // (pfade: the volcanoes' plumes' own fade, 2026-09-17)
	if (!planet_bake(_pn)) return false;
	var _cfg = planet_config();
	if (is_undefined(_spin)) _spin = planet_spin_now(_pn);   // the universal clock (the agent's day / night agrees with it)
	static _u = undefined;
	if (is_undefined(_u)) _u = {
		rot   : shader_get_uniform(sh_planet, "u_rot"),
		crot  : shader_get_uniform(sh_planet, "u_crot"),
		crot2 : shader_get_uniform(sh_planet, "u_crot2"),
		wt    : shader_get_uniform(sh_planet, "u_wt"),
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
		rcol2 : shader_get_uniform(sh_planet, "u_ringcol2"), rkind : shader_get_uniform(sh_planet, "u_rkind"), rin : shader_get_uniform(sh_planet, "u_rin"), rout : shader_get_uniform(sh_planet, "u_rout"),
		rseed : shader_get_uniform(sh_planet, "u_rseed"), rgap : shader_get_uniform(sh_planet, "u_rgap"),
		city  : shader_get_uniform(sh_planet, "u_city"),
		cityn : shader_get_uniform(sh_planet, "u_cityn"),
		relief : shader_get_uniform(sh_planet, "u_relief"),
		bump  : shader_get_uniform(sh_planet, "u_bump"),
		cfade : shader_get_uniform(sh_planet, "u_cfade"), pfade : shader_get_uniform(sh_planet, "u_pfade"),
		crelief : shader_get_uniform(sh_planet, "u_crelief"),
		cvol : shader_get_uniform(sh_planet, "u_cvol"),
		canopy : shader_get_uniform(sh_planet, "u_canopy"), grass : shader_get_uniform(sh_planet, "u_grass"),
		pwin : shader_get_uniform(sh_planet, "u_pwin"), pk : shader_get_uniform(sh_planet, "u_pk"),
		sea0 : shader_get_uniform(sh_planet, "u_sea0"), sea1 : shader_get_uniform(sh_planet, "u_sea1"),
		season : shader_get_uniform(sh_planet, "u_season"), snowb : shader_get_uniform(sh_planet, "u_snowb"),
		ptex : shader_get_sampler_index(sh_planet, "u_ptex"), pheight : shader_get_sampler_index(sh_planet, "u_pheight"),
		moonsh : shader_get_uniform(sh_planet, "u_moonsh"), moonn : shader_get_uniform(sh_planet, "u_moonn"),
		vent : shader_get_uniform(sh_planet, "u_vent"), ventn : shader_get_uniform(sh_planet, "u_ventn"),
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
	// THE WIND (his report, 2026-09-17: "clouds look as if they don't move" - the decks rode the spin, a hair
	// faster, and a world turns once in hours): the decks SAIL over the land. The top deck laps the world in
	// wind_lap minutes (a giant's faster), the prevailing direction with the spin two times in three, and a slow
	// VEER north and south (two beats that never meet) so the drift is never a wheel; the base deck on its own
	// frame (u_crot2) at a little over half the pace, so the surface path's two shells slide past each other.
	// Off the universal clock like the spin - a world's weather is where you left it. The pace is hashed off the
	// seed (nothing rolled - the generator's stream is a save format) and kept on the struct
	if (is_undefined(_pn[$ "wind"])) {
		var _wh = hash_mix(_pn.seed, 7331), _wl = _cfg[$ "wind_lap"] ?? [6, 16];
		var _lap = lerp(_wl[0], _wl[1], (_wh mod 1000) / 1000) * 60;
		var _wdir = (((_wh div 1000) mod 3) == 0) ? -1 : 1;
		if (_pn.spin < 0) _wdir = -_wdir;
		_pn.wind = _wdir * 360 / _lap * ((_pn.kind == "gas") ? 1.6 : 1);   // degrees a second, over the ground
	}
	var _now = universal_now();
	var _drift = (_now * _pn.wind) mod 360;
	var _veer = 5 * dsin(360 * ((_now mod 407) / 407)) + 3 * dsin(360 * ((_now mod 233) / 233));
	var _wc  = mat3_mul(mat3_mul(mat3_rot(0, 0, 1, _pn.tilt), mat3_rot(0, 1, 0, _spin + _drift + 31)), mat3_rot(1, 0, 0, _veer));
	var _wc2 = mat3_mul(mat3_mul(mat3_rot(0, 0, 1, _pn.tilt), mat3_rot(0, 1, 0, _spin + _drift * .55 + 137)), mat3_rot(1, 0, 0, -_veer * .6));
	var _m  = mat3_mul(mat3_transpose(_w), _cam);
	var _mc = mat3_mul(mat3_transpose(_wc), _cam);
	var _mc2 = mat3_mul(mat3_transpose(_wc2), _cam);
	var _lv = is_array(_light_w) ? mat3_apply(_ct, _light_w[0], _light_w[1], _light_w[2]) : [-.55, -.5, .67];
	var _ll = max(.001, sqrt(_lv[0] * _lv[0] + _lv[1] * _lv[1] + _lv[2] * _lv[2]));
	_lv = [_lv[0] / _ll, _lv[1] / _ll, _lv[2] / _ll];
	var _ax = mat3_apply(mat3_rot(0, 0, 1, _pn.tilt), 0, 1, 0);
	_ax = mat3_apply(_ct, _ax[0], _ax[1], _ax[2]);
	var _rout = _pn[$ "ring_out"] ?? 2.25;
	var _pad = _pn.ring ? (_rout + .12) : _cfg.pad;   // (room for the ring's reach - a dust ring is wide)
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
	shader_set_uniform_f_array(_u.crot2, _mc2);
	// THE WEATHER (2026-09-17): a slow swell over the decks - two phases, each periodic in its own window, so neither
	// ever jumps at the clock's wrap and together they never repeat in a sitting
	shader_set_uniform_f(_u.wt, 2 * pi * ((_now mod 240) / 240), 2 * pi * ((_now mod 341) / 341));
	shader_set_uniform_f(_u.light, _lv[0], _lv[1], _lv[2]);
	shader_set_uniform_f(_u.atmo, colour_get_red(_pn.atmo) / 255, colour_get_green(_pn.atmo) / 255, colour_get_blue(_pn.atmo) / 255);
	shader_set_uniform_f(_u.tsize, _pn.tw, _pn.th);
	shader_set_uniform_f(_u.pad, _pad);
	shader_set_uniform_f(_u.time, (current_time mod 100000) / 1000);
	shader_set_uniform_f(_u.cells, (_cfg.px_size > 0) ? (2 * _q) / _cfg.px_size : 0);
	shader_set_uniform_f(_u.ring, _pn.ring ? .85 : 0);
	shader_set_uniform_f(_u.raxis, _ax[0], _ax[1], _ax[2]);
	shader_set_uniform_f(_u.rcol, colour_get_red(_pn.ring_col) / 255, colour_get_green(_pn.ring_col) / 255, colour_get_blue(_pn.ring_col) / 255);
	// THE RING'S MAKE (2026-09-17): its kind, reach, second colour and band seed; and a gap where a moon rides inside it
	// (the casters carry the moons' view positions - a moon's distance is their length)
	var _rc2 = _pn[$ "ring_col2"] ?? _pn.ring_col, _rin = _pn[$ "ring_in"] ?? 1.55;
	shader_set_uniform_f(_u.rcol2, colour_get_red(_rc2) / 255, colour_get_green(_rc2) / 255, colour_get_blue(_rc2) / 255);
	shader_set_uniform_f(_u.rkind, _pn[$ "ring_kind"] ?? 0);
	shader_set_uniform_f(_u.rin, _rin); shader_set_uniform_f(_u.rout, _rout);
	shader_set_uniform_f(_u.rseed, _pn[$ "ring_seed"] ?? .5);
	var _g1 = 0, _g2 = 0;
	if (_pn.ring && is_array(_msh)) for (var _gi = 0; _gi < array_length(_msh); _gi++) {
		var _gm = _msh[_gi], _gd = sqrt(_gm[0] * _gm[0] + _gm[1] * _gm[1] + _gm[2] * _gm[2]);
		if (_gd > _rin + .05 && _gd < _rout - .05) { if (_g1 == 0) _g1 = _gd; else if (_g2 == 0) _g2 = _gd; }
	}
	shader_set_uniform_f(_u.rgap, _g1, _g2);
	var _bump = (variable_global_exists("planet_relief_pct") ? g.planet_relief_pct : 140) / 100;   // settings > visuals: mountain relief
	shader_set_uniform_f(_u.relief, (_pn.kind == "gas") ? 0 : _cfg.relief * max(.4, _bump));   // (the silhouette rides the knob too, gently)
	shader_set_uniform_f(_u.bump, (_pn.kind == "gas") ? 0 : _bump);
	shader_set_uniform_f(_u.cfade, clamp(_cfade, 0, 1));
	shader_set_uniform_f(_u.pfade, clamp(_pfade, 0, 1));
	shader_set_uniform_f(_u.crelief, (_cfg[$ "crelief"] ?? .05) * ((_pn.kind == "gas") ? .5 : 1));   // (the cloud relief - 2026-09-17; a giant's deck lower)
	shader_set_uniform_f(_u.cvol, (variable_global_exists("cloud_volume") && g.cloud_volume) ? 1 : 0);   // (the volume, or the surface - settings > visuals)
	// THE SEASON (2026-09-17): the world's year, four to twelve hours of the wall clock (hashed off the seed, kept on
	// the struct), its phase on the universal clock - the snow line breathes with it
	if (is_undefined(_pn[$ "year"])) { _pn.year = 14400 + (hash_mix(_pn.seed, 8181) mod 28800); _pn.year_ph = (hash_mix(_pn.seed, 8182) mod 1000) / 1000; }
	shader_set_uniform_f(_u.season, sin(2 * pi * ((universal_now() mod _pn.year) / _pn.year + _pn.year_ph)));
	// THE SNOW BIAS: a lava world never; a hot world only its highest crowns; a cold one lower than the line
	shader_set_uniform_f(_u.snowb, (_pn.arch == "lava") ? 3 : lerp(.55, -.12, clamp(_pn.clim, 0, 1)));
	// THE CANOPY (2026-09-17): the woods' deck height, and the world's grass (the floor under the trees, darkened)
	shader_set_uniform_f(_u.canopy, _cfg[$ "canopy"] ?? .015);
	var _gc = (_pn.kind == "gas" || array_length(_pn.pal) < 5) ? c_gray : _pn.pal[4];
	shader_set_uniform_f(_u.grass, colour_get_red(_gc) / 255, colour_get_green(_gc) / 255, colour_get_blue(_gc) / 255);
	// THE SEA'S DEPTH (2026-09-17): the deep and the open ocean - the shader grades the water between the shore's own colour and these
	var _s0 = (_pn.kind == "gas" || array_length(_pn.pal) < 2) ? c_navy : _pn.pal[0], _s1 = (_pn.kind == "gas" || array_length(_pn.pal) < 2) ? c_blue : _pn.pal[1];
	shader_set_uniform_f(_u.sea0, colour_get_red(_s0) / 255, colour_get_green(_s0) / 255, colour_get_blue(_s0) / 255);
	shader_set_uniform_f(_u.sea1, colour_get_red(_s1) / 255, colour_get_green(_s1) / 255, colour_get_blue(_s1) / 255);
	// the moons' shadows, the storms' lightning, the aurora (2026-09-16)
	var _mshv = array_create(16, 0), _mshn = 0;
	if (is_array(_msh)) { _mshn = min(4, array_length(_msh)); for (var _i = 0; _i < _mshn; _i++) { _mshv[_i * 4] = _msh[_i][0]; _mshv[_i * 4 + 1] = _msh[_i][1]; _mshv[_i * 4 + 2] = _msh[_i][2]; _mshv[_i * 4 + 3] = _msh[_i][3]; } }
	shader_set_uniform_f_array(_u.moonsh, _mshv);
	shader_set_uniform_f(_u.moonn, _mshn);
	// THE VOLCANOES' PLUMES (2026-09-17): the live vents, in texture space (x, y, z, the ring's reach in radians)
	var _vnt = _pn[$ "vents"], _vv = array_create(24, 0), _vn = 0;
	if (is_array(_vnt)) { _vn = min(6, array_length(_vnt)); for (var _i = 0; _i < _vn; _i++) { _vv[_i * 4] = _vnt[_i][0]; _vv[_i * 4 + 1] = _vnt[_i][1]; _vv[_i * 4 + 2] = _vnt[_i][2]; _vv[_i * 4 + 3] = _vnt[_i][3]; } }
	shader_set_uniform_f_array(_u.vent, _vv);
	shader_set_uniform_f(_u.ventn, _vn);
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
	// THE ZOOM PATCH (2026-09-17): its window and textures, or none
	if (is_struct(_lod) && surface_exists(_lod.tsurf) && surface_exists(_lod.hsurf)) {
		shader_set_uniform_f(_u.pwin, _lod.u0 / _pn.tw, _lod.v0 / _pn.th, (_lod.u0 + _lod.uw) / _pn.tw, (_lod.v0 + _lod.vh) / _pn.th);
		shader_set_uniform_f(_u.pk, _lod.k);
		texture_set_stage(_u.ptex, surface_get_texture(_lod.tsurf));
		texture_set_stage(_u.pheight, surface_get_texture(_lod.hsurf));
	} else shader_set_uniform_f(_u.pk, 0);
	draw_surface_ext(_pn.tsurf, _qx, _qy, (2 * _q) / _pn.tw, (2 * _q) / _pn.th, 0, c_white, 1);
	shader_reset();
	return true;
}
