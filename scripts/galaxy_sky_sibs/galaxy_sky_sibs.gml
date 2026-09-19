/// @description galaxy_sky_sibs(sky) - THE SIBLINGS PLACED NOW (q240): every sibling planet of the sky's system - its bearing on the ecliptic from where we are this second (the universal clock), its phase (the sun from it against us from it), its apparent size by the geometry compressed (2.5..14 px across), the sun's direction from it (its own light), its brightness by its distance from the sun, and whether it stands between us and the sun (a transit). In place, on sky.sibs; the draw calls it a frame
/// The frame is the system's own (the shared frame: x = cos, z = sin of the
/// orbit angle, the plane y = 0) - the sun sits at the origin, we at our orbit
function galaxy_sky_sibs(_sky) {
	var _sys = _sky[$ "sys"];
	if (!is_struct(_sys)) return;
	var _now = universal_now();
	var _me = _sys.planets[_sky.me];
	var _ang1 = (_me.ang + _me.spd * 60 * _now) mod 360;
	var _p1x = dcos(_ang1) * _me.orbit, _p1z = dsin(_ang1) * _me.orbit, _d1 = _me.orbit;
	var _sibs = _sky.sibs;
	for (var _k = 0; _k < array_length(_sibs); _k++) {
		var _sb = _sibs[_k];
		if (is_undefined(_sb[$ "i"])) continue;   // (an old sky's dot: left as it was)
		var _sp = _sys.planets[_sb.i];
		var _ang2 = (_sp.ang + _sp.spd * 60 * _now) mod 360;
		var _p2x = dcos(_ang2) * _sp.orbit, _p2z = dsin(_ang2) * _sp.orbit;
		var _dd = max(.001, point_distance(_p1x, _p1z, _p2x, _p2z));
		var _b = darctan2(_p2z - _p1z, _p2x - _p1x);
		_sb.x = dcos(_b); _sb.y = 0; _sb.z = dsin(_b); _sb.d = _dd;
		// the phase: the sun from the sibling against us from the sibling
		var _sl = max(.001, point_distance(0, 0, _p2x, _p2z)), _sdx = -_p2x / _sl, _sdz = -_p2z / _sl;
		var _udx = (_p1x - _p2x) / _dd, _udz = (_p1z - _p2z) / _dd;
		_sb.lit = clamp((1 + (_sdx * _udx + _sdz * _udz)) * .5, 0, 1);
		_sb.sunl = [_sdx, 0, _sdz];   // (the light on its face: the sun's direction from it, in the shared frame)
		// THE SIZE by the geometry, compressed: the system's scale is a toy's (worlds 2.5-8 across, orbits 34-210), so the
		// pure ratio makes a near neighbour a thirty-pixel moon and a far one nothing - the shape of that is kept (the
		// close pass IS the big planet in the sky), capped at fourteen and floored at two and a half
		_sb.s = clamp(_sp.size * 26 / max(_dd, 8), 2.5, 14);
		// the brightness by the sun's distance (inverse square, compressed): an outer giant is a dim disc, an inner rock bright
		_sb.bri = clamp(power(55 / max(_sl, 25), .7), .35, 1);
		// between us and the sun (a transit if it also lies on the sun's disc - the draw checks the disc)
		_sb.near = (_sl < _d1) && (_sdx * _udx + _sdz * _udz < -.9);
	}
}
