/// @description galaxy_sky_build([dest]) -> the sky over a board world (the home planet without one), from the REAL neighbourhood of ITS star
/// obj_planet_sky's rules, ported 2026-09-15: the map's stars within
/// sky_range of the home star, sorted by distance, the nearest sky_max
/// kept; bearings map 1:1 to azimuth, elevation scatter scales with
/// each star's parallax depth (far ones hug the galactic band, near ones
/// roam), apparent size = class size over distance. Plus a full-sphere
/// dust fill (seeded by the planet), the siblings as dots on the
/// ecliptic (the galactic plane, y = 0, x = cos / z = sin bearing - the
/// shared frame), the sun's bearing (the star seen from the planet's
/// orbital spot, NOW by the universal clock), the galactic core's
/// bearing for the fog's warm side, and how far out we sit (the rim
/// sees the band pile up one way).
///   { stars[] {x,y,z,col,b,s}, sibs[] {x,y,z,col,s}, light_w, core_dir,
///     fog_seed, fog_edge, sun_col, sun_size, name }
function galaxy_sky_build(_dw = undefined) {
	var _cfg = starmap_config();
	var _sm  = starmap_get();
	var _hm  = is_struct(_dw) ? galaxy_world_sys(_dw) : galaxy_home();   // (the world's own star, 2026-09-16)
	var _me  = _sm.stars[_hm.star];
	var _out = { stars : [], sibs : [], light_w : [-.52, -.38, .77], core_dir : [1, 0, 0], fog_seed : 0, fog_edge : 0,
	             sun_col : merge_colour(c_white, c_gold, .4), sun_size : 12, name : _hm.name, star : _hm.star };
	// the neighbourhood
	var _rng = _cfg.sky_range;
	var _cand = star_visible(_me.x - _rng, _me.y - _rng, 1, _rng * 2, _rng * 2);
	var _near = [];
	for (var _i = 0; _i < array_length(_cand); _i++) {
		if (_cand[_i] == _hm.star) continue;
		var _st = _sm.stars[_cand[_i]];
		var _d = point_distance(_me.x, _me.y, _st.x, _st.y);
		if (_d > _rng) continue;
		array_push(_near, { st : _st, d : _d });
	}
	array_sort(_near, function(_a, _b) { return _a.d - _b.d; });
	var _n = min(array_length(_near), _cfg.sky_max);
	for (var _i = 0; _i < _n; _i++) {
		var _st = _near[_i].st, _d = _near[_i].d;
		var _az = point_direction(_me.x, _me.y, _st.x, _st.y);
		var _sc = clamp((_st.d - .85) / .3, 0, 1);
		var _hh = (_st.seed * 2654435761) & $7fffffff;
		_hh = (_hh ^ (_hh >> 13)) & $7fffffff;
		var _el = ((_hh mod 997) / 997 - .5) * lerp(_cfg.sky_el_far, _cfg.sky_el_near, _sc);
		var _ap = _st.props.size * (90 / max(_d, 55));
		array_push(_out.stars, { x : dcos(_el) * dcos(_az), y : -dsin(_el), z : dcos(_el) * dsin(_az),
		                         col : _st.props.color, b : .4 + .6 * clamp(_ap * .8, 0, 1), s : clamp(1 + _ap * 2, 1, 9) });
	}
	// the system: where everything is NOW (the universal clock), the
	// siblings as dots along the ecliptic, the sun at the star's bearing
	var _now = universal_now();
	var _sys = _hm.sys;
	var _me3 = _sys.planets[_hm.planet];
	var _ang1 = (_me3.ang + _me3.spd * 60 * _now) mod 360;
	var _p1x = dcos(_ang1) * _me3.orbit, _p1z = dsin(_ang1) * _me3.orbit;
	for (var _i = 0; _i < array_length(_sys.planets); _i++) {
		var _sp = _sys.planets[_i];
		if (_sp.seed == _me3.seed) continue;
		var _ang2 = (_sp.ang + _sp.spd * 60 * _now) mod 360;
		var _p2x = dcos(_ang2) * _sp.orbit, _p2z = dsin(_ang2) * _sp.orbit;
		var _dd  = point_distance(_p1x, _p1z, _p2x, _p2z);
		var _b   = darctan2(_p2z - _p1z, _p2x - _p1x);
		array_push(_out.sibs, { x : dcos(_b), y : 0, z : dsin(_b), col : _sp.col, s : clamp(_sp.size * 22 / max(_dd, 12), 1.5, 6) });
	}
	_out.light_w = galaxy_sun_dir(0, _dw);   // (the one bearing the agent's daylight reads too)
	_out.sun_col  = _sys.star.col;
	_out.sun_size = _sys.star.size;
	// the dust
	var _oldsd = random_get_seed();
	random_set_seed(_hm.planet_seed & $7fffffff);
	repeat (_cfg.dust_count) {
		var _az2 = random(360);
		var _el2 = radtodeg(arcsin(random_range(-1, 1)));
		array_push(_out.stars, { x : dcos(_el2) * dcos(_az2), y : -dsin(_el2), z : dcos(_el2) * dsin(_az2),
		                         col : choose(rgb(150, 160, 190), rgb(150, 160, 190), rgb(190, 170, 150)),
		                         b : random_range(.12, .4), s : (random(1) < .15 ? 2 : 1) });
	}
	rng_release(_oldsd);
	// the fog's bearings
	var _core_az = point_direction(_me.x, _me.y, _sm.cx, _sm.cy);
	_out.core_dir = [dcos(_core_az), 0, dsin(_core_az)];
	_out.fog_seed = (_hm.planet_seed mod 4096) / 61.7;
	_out.fog_edge = clamp(point_distance(_me.x, _me.y, _sm.cx, _sm.cy) / _cfg.gal_r, 0, 1);
	return _out;
}
