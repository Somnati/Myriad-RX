/// @description exped_daylight(trip) -> -1..1: how much sun where the crew stands (< 0 = night)
/// The region's spot on the world (its direction, turned by the world's
/// spin NOW - planet_spin_now, the same matrix the render uses) against
/// the sun's bearing (galaxy_sun_dir). Positive = day, about zero = dusk
/// or dawn, negative = night. The agent reads it (exped_agent: slow going,
/// wrong turns, a bed when there is coin), the diary marks the crossings.
function exped_daylight(_tr) {
	var _pn = planet_get(_tr.dest.seed, exped_planet_hint(_tr.dest));
	var _rg = exped_region(_tr);
	var _spin = planet_spin_now(_pn);
	var _t = [dcos(_rg.spot.lat) * dcos(_rg.spot.lon), dsin(_rg.spot.lat), dcos(_rg.spot.lat) * dsin(_rg.spot.lon)];
	var _w = mat3_mul(mat3_rot(0, 0, 1, _pn.tilt), mat3_rot(0, 1, 0, _spin));
	var _n = mat3_apply(_w, _t[0], _t[1], _t[2]);
	var _s = galaxy_sun_dir();
	return _n[0] * _s[0] + _n[1] * _s[1] + _n[2] * _s[2];
}
