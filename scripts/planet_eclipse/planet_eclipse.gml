/// @description planet_eclipse(dest) -> undefined, or { moon, dir, ang, depth, off } - the moon whose shadow falls on the world NOW
/// The universal clock's geometry, nothing rolled: a moon on the sun's
/// side of the world (planet_moons' orbit maths, the same the render's
/// shadow casters use) whose line to the sun passes within a world radius
/// (plus its own) casts its shadow on the day side. dir = the shadow's
/// centre on the sphere (world space, unit), ang = the umbra's angular
/// radius (radians, about the moon's size in radii), depth = 1 at a
/// central pass and 0 at a grazing one, off = the moon's offset off the
/// sun's line (radii). The orbit view dims the sun's glow when a moon
/// covers it from the camera (galaxy_sky_draw's occluders); the diary
/// (exped_agent) marks the crew standing under one (2026-09-16).
function planet_eclipse(_d) {
	var _pn = planet_get(_d.seed, exped_planet_hint(_d));
	var _lw = galaxy_sun_dir(0, _d);
	var _mns = planet_moons(_d.seed), _n = min(4, planet_props(_d).moons);
	var _best = undefined;
	for (var _i = 0; _i < _n; _i++) {
		var _mo = _mns[_i];
		var _ang = (_mo.ang + _mo.spd * 60 * universal_now()) mod 360;
		var _om = mat3_mul(mat3_rot(0, 0, 1, _pn.tilt), mat3_rot(1, 0, 0, _mo.incl));
		var _m = mat3_apply(_om, dcos(_ang) * _mo.dist, 0, dsin(_ang) * _mo.dist);
		var _along = _m[0] * _lw[0] + _m[1] * _lw[1] + _m[2] * _lw[2];
		if (_along <= 0) continue;   // (the moon is on the night side: no shadow to cast)
		var _px = _m[0] - _lw[0] * _along, _py = _m[1] - _lw[1] * _along, _pz = _m[2] - _lw[2] * _along;
		var _off = sqrt(_px * _px + _py * _py + _pz * _pz);
		if (_off >= 1 + _mo.size) continue;   // (the shadow misses the world)
		var _oc = min(_off, .999), _sc = (_off > 0) ? _oc / _off : 0;
		var _sz = sqrt(max(0, 1 - _oc * _oc));   // (the day side's height along the sun's line under the moon)
		var _dir = [_px * _sc + _lw[0] * _sz, _py * _sc + _lw[1] * _sz, _pz * _sc + _lw[2] * _sz];
		var _dl = max(.0001, sqrt(_dir[0] * _dir[0] + _dir[1] * _dir[1] + _dir[2] * _dir[2]));
		var _depth = 1 - _off / (1 + _mo.size);
		if (is_undefined(_best) || _depth > _best.depth) _best = { moon : _i, dir : [_dir[0] / _dl, _dir[1] / _dl, _dir[2] / _dl], ang : _mo.size, depth : _depth, off : _off };
	}
	return _best;
}
