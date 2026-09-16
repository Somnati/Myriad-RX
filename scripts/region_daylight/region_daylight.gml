/// @description region_daylight(dest, region, [ahead]) -> -1..1: how much sun over the region now (< 0 = night); ahead = seconds from now
/// The region's spot on the world (its direction, turned by the world's
/// spin - planet_spin_now's clock, the same matrix the render uses)
/// against the sun's bearing (galaxy_sun_dir). Positive = day, about
/// zero = dusk or dawn, negative = night. The agent reads it through
/// exped_daylight; the info box reads it twice (now and a little ahead)
/// to tell morning from afternoon.
function region_daylight(_d, _rg, _ahead = 0) {
	var _pn = planet_get(_d.seed, exped_planet_hint(_d));
	var _spin = ((universal_now() + _ahead) * 60 * _pn.spin) mod 360;
	var _t = [dcos(_rg.spot.lat) * dcos(_rg.spot.lon), dsin(_rg.spot.lat), dcos(_rg.spot.lat) * dsin(_rg.spot.lon)];
	var _w = mat3_mul(mat3_rot(0, 0, 1, _pn.tilt), mat3_rot(0, 1, 0, _spin));
	var _n = mat3_apply(_w, _t[0], _t[1], _t[2]);
	var _s = galaxy_sun_dir(0, _d);   // (the world's own sun, 2026-09-16)
	return _n[0] * _s[0] + _n[1] * _s[1] + _n[2] * _s[2];
}
