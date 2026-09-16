/// @description galaxy_sky_build([dest]) -> the sky over a board world (the home planet without one), from the REAL neighbourhood of ITS star
/// obj_planet_sky's rules, ported 2026-09-15: the map's stars within
/// sky_range of the home star, sorted by distance, the nearest sky_max
/// kept; bearings map 1:1 to azimuth, elevation scatter scales with
/// each star's height off the plane over its distance (far ones hug the
/// galactic band, near ones stand off it), apparent size = class size over distance. Plus a full-sphere
/// dust fill (seeded by the planet), the siblings as dots on the
/// ecliptic (the galactic plane, y = 0, x = cos / z = sin bearing - the
/// shared frame), the sun's bearing (the star seen from the planet's
/// orbital spot, NOW by the universal clock), the galactic core's
/// bearing for the fog's warm side, and how far out we sit (the rim
/// sees the band pile up one way).
///   { stars[] {x,y,z,col,b,s}, sibs[] {x,y,z,col,s}, nebs[] {x,y,z,ar,b,nb}, inside {nb,s,t,edge} | undefined, light_w, core_dir,
///     fog_seed, fog_edge, sun_col, sun_size, name }
function galaxy_sky_build(_dw = undefined) {
	var _cfg = starmap_config();
	var _sm  = starmap_get();
	var _hm  = is_struct(_dw) ? galaxy_world_sys(_dw) : galaxy_home();   // (the world's own star, 2026-09-16)
	var _me  = _sm.stars[_hm.star];
	var _out = { stars : [], sibs : [], light_w : [-.52, -.38, .77], core_dir : [1, 0, 0], fog_seed : 0, fog_edge : 0,
	             sun_col : merge_colour(c_white, c_gold, .4), sun_size : 12, name : _hm.name, star : _hm.star };
	// THE RICHNESS (2026-09-16): the local density off the map's grid (0..1 of the galaxy's densest cell) and how deep
	// in the core this star sits (0..1 over the inner third of the disc) - the star count, the clouds and the band all
	// scale with them (his report: the centre's brightest spot had a sky like any other)
	var _lcx = clamp(floor(_me.x / _sm.ncell), 0, _sm.ngw - 1), _lcy = clamp(floor(_me.y / _sm.ncell), 0, _sm.ngw - 1);
	var _ld = clamp(_sm.ngrid[_lcx + _lcy * _sm.ngw] / max(1, _sm.nmax), 0, 1);
	var _cd = clamp(1 - point_distance(_me.x, _me.y, _sm.cx, _sm.cy) / (_cfg.gal_r * .33), 0, 1);
	_out.rich = _ld; _out.core_in = _cd;
	_out.fog_boost = 1 + (_cfg[$ "sky_core_fog"] ?? 1.6) * _cd + (_cfg[$ "sky_rich_fog"] ?? .6) * _ld;
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
	var _n = min(array_length(_near), _cfg.sky_max + round((_cfg[$ "sky_rich_max"] ?? 480) * _ld));   // (a rich neighbourhood keeps more of its stars)
	for (var _i = 0; _i < _n; _i++) {
		var _st = _near[_i].st, _d = _near[_i].d;
		var _az = point_direction(_me.x, _me.y, _st.x, _st.y);
		var _sc = clamp((_st.d - .85) / .3, 0, 1);
		var _hh = (_st.seed * 2654435761) & $7fffffff;
		_hh = (_hh ^ (_hh >> 13)) & $7fffffff;
		// THE REAL ELEVATION (2026-09-16 - he took it for granted, and it was a hash): the neighbour's height off the plane against
		// ours (the parallax depth read as plane px, the nebulae's law), over its distance
		var _el = clamp(darctan2((_st.d - _me.d) * (_cfg[$ "star_height"] ?? 900), max(_d, 1)), -75, 75);
		var _ap = _st.props.size * (90 / max(_d, 55));
		array_push(_out.stars, { x : dcos(_el) * dcos(_az), y : -dsin(_el), z : dcos(_el) * dsin(_az),
		                         col : _st.props.color, b : .4 + .6 * clamp(_ap * .8, 0, 1), s : clamp(1 + _ap * 2, 1, 9), ph : (_hh mod 360), near : true });   // (ph: the twinkle's phase; near: a real neighbour - a halo when big, 2026-09-16)
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
		// THE PHASE (2026-09-16): how much of the sibling's lit half faces us - the sun from it against us from it (the system's own geometry)
		var _sl = max(.001, point_distance(0, 0, _p2x, _p2z)), _sdx = -_p2x / _sl, _sdz = -_p2z / _sl;
		var _ul = max(.001, _dd), _udx = (_p1x - _p2x) / _ul, _udz = (_p1z - _p2z) / _ul;
		array_push(_out.sibs, { x : dcos(_b), y : 0, z : dsin(_b), col : _sp.col, s : clamp(_sp.size * 22 / max(_dd, 12), 1.5, 6), lit : clamp((1 + (_sdx * _udx + _sdz * _udz)) * .5, 0, 1), gas : (_sp.kind == "gas") });
	}
	_out.light_w = galaxy_sun_dir(0, _dw);   // (the one bearing the agent's daylight reads too)
	_out.sun_col  = _sys.star.col;
	// THE SUN'S SIZE BY THE ORBIT (his pick, 2026-09-16): the star's size over the world's orbit against a middling one -
	// an inner world's sun is big in the sky, an outer world's a bright point (the same law sizes the shadows' sun)
	_out.sun_size = _sys.star.size * clamp((_cfg[$ "sun_orbit_ref"] ?? 70) / max(20, _me3.orbit), _cfg[$ "sun_size_min"] ?? .45, _cfg[$ "sun_size_max"] ?? 2.2);
	// the dust
	var _oldsd = random_get_seed();
	random_set_seed(_hm.planet_seed & $7fffffff);
	repeat (_cfg.dust_count) {
		var _az2 = random(360);
		var _el2 = radtodeg(arcsin(random_range(-1, 1)));
		array_push(_out.stars, { x : dcos(_el2) * dcos(_az2), y : -dsin(_el2), z : dcos(_el2) * dsin(_az2),
		                         col : choose(rgb(150, 160, 190), rgb(150, 160, 190), rgb(190, 170, 150)),
		                         b : random_range(.12, .4), s : (random(1) < .15 ? 2 : 1), ph : irandom(359), near : false });
	}
	// THE STAR CLOUDS (his pick, 2026-09-16): the milky way's grain - faint points packed along the band (a
	// triangular scatter about the galactic plane, twelve degrees wide), warm toward the core's bearing and
	// cool away like the fog, and on a rim world piled toward the core as the fog is (the same bias law)
	var _core_az0 = point_direction(_me.x, _me.y, _sm.cx, _sm.cy);
	var _edge0 = clamp(point_distance(_me.x, _me.y, _sm.cx, _sm.cy) / _cfg.gal_r, 0, 1);
	var _ncl = round((_cfg[$ "sky_cloud"] ?? 520) * (1 + (_cfg[$ "sky_rich_cloud"] ?? 2) * _ld)), _tries = 0;   // (the grain thickens with the neighbourhood)
	while (_ncl > 0 && _tries < 20000) {
		_tries += 1;
		var _az3 = random(360);
		var _dc = abs(angle_difference(_az3, _core_az0)) / 180;
		var _bias = lerp(1, .15 + 1.7 * power(1 - _dc, 1.8), _edge0);
		if (random(1) > clamp(_bias, 0, 1)) continue;
		_ncl -= 1;
		var _el3 = (random(1) - .5 + random(1) - .5) * 12;   // (triangular: most within a few degrees of the plane)
		var _cc = merge_colour(rgb(255, 205, 165), rgb(150, 170, 235), _dc);
		array_push(_out.stars, { x : dcos(_el3) * dcos(_az3), y : -dsin(_el3), z : dcos(_el3) * dsin(_az3),
		                         col : merge_colour(_cc, c_white, .35), b : random_range(.08, .32) * (1 - .5 * abs(_el3) / 12), s : 1, ph : irandom(359), near : false, cl : true });   // (cl: drawn at its raw brightness - grain, not stars; bug hunt 2026-09-16)
	}
	rng_release(_oldsd);
	// THE NEBULAE (2026-09-16): the galaxy's clouds within reach, at their bearings - a near one wide and bright, a far
	// one a small patch; each at ITS HEIGHT off the plane seen from here (a near high one stands high in the sky, a far
	// one hugs the band - his ask: the sky's top and bottom were black with them all on the band)
	_out.nebs = [];
	var _nbs = galaxy_nebulae(), _nrng = _cfg[$ "neb_range"] ?? 1500;
	for (var _i = 0; _i < array_length(_nbs); _i++) {
		var _nb = _nbs[_i];
		var _nd2 = point_distance(_me.x, _me.y, _nb.x, _nb.y), _nhg = _nb[$ "h"] ?? 0;
		var _nd = sqrt(_nd2 * _nd2 + _nhg * _nhg);   // (the true distance, height and all)
		if (_nd > _nrng + _nb.r) continue;
		var _naz = point_direction(_me.x, _me.y, _nb.x, _nb.y);
		var _nar = clamp(darctan(_nb.r / max(_nd, 1)), 4, 55);   // the apparent radius, degrees
		var _nel = clamp(darctan2(_nhg, max(_nd2, 1)), -72, 72);   // its height seen from here (never the zenith: the frame needs a side)
		var _nbr = clamp(_nb.r / max(_nd, 1) * 1.4, .12, 1) * clamp((_nrng + _nb.r - _nd) / (_nrng * .35), 0, 1);   // (fading out at the edge of reach)
		array_push(_out.nebs, { x : dcos(_nel) * dcos(_naz), y : -dsin(_nel), z : dcos(_nel) * dsin(_naz), ar : _nar, b : _nbr, nb : _nb });
	}
	array_sort(_out.nebs, function(_a, _b) { return (_b.b > _a.b) ? 1 : ((_b.b < _a.b) ? -1 : 0); });   // (the brightest first: the fog shader paints eight)
	// INSIDE A NEBULA (his ask, 2026-09-16): a star's HEIGHT is its parallax depth read as plane px (d .85..1.15 about the
	// plane); within a cloud's radius and its thickness about the cloud's height, the star is in it - the deepest one
	// (least of the two edge fractions) is the sky's: sh_sky_inside washes the sky by the path out of the cloud along
	// every ray (long along the plane, short out the thin axis) and dims what lies beyond by the same path
	// (2026-09-16: NEAR counts too - within 1.6 radii and 1.4 thicknesses; the march clips every ray to the body's bounds, so a
	// star just outside sees the cloud where it is and its own sky clear - it took the whole colour before, his report)
	_out.inside = undefined;
	var _hz = (_me.d - 1) * (_cfg[$ "star_height"] ?? 900), _best = 1;
	for (var _i = 0; _i < array_length(_nbs); _i++) {
		var _nb = _nbs[_i], _nt = _nb[$ "t"] ?? (_nb.r * .5), _nhh = _nb[$ "h"] ?? 0;
		var _exy = point_distance(_me.x, _me.y, _nb.x, _nb.y) / _nb.r, _ev = abs(_hz - _nhh) / _nt;
		if (_exy >= 1.6 || _ev >= 1.4) continue;
		var _edge = max(_exy / 1.6, _ev / 1.4);
		if (_edge >= _best) continue;
		_best = _edge;
		// the star relative to the cloud's centre in the sky's frame (x = east on the map, y down the sky, z = the map's south), in radii
		_out.inside = { nb : _nb, s : [ (_me.x - _nb.x) / _nb.r, (_nhh - _hz) / _nb.r, (_nb.y - _me.y) / _nb.r ], t : _nt / _nb.r, edge : _edge };
	}
	// the fog's bearings
	var _core_az = point_direction(_me.x, _me.y, _sm.cx, _sm.cy);
	_out.core_dir = [dcos(_core_az), 0, dsin(_core_az)];
	_out.fog_seed = (_hm.planet_seed mod 4096) / 61.7;
	_out.fog_edge = clamp(point_distance(_me.x, _me.y, _sm.cx, _sm.cy) / _cfg.gal_r, 0, 1);
	return _out;
}
