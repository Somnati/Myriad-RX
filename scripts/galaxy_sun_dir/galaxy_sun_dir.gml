/// @description galaxy_sun_dir() -> the home star's direction from the home planet NOW, world space [x, y, z]
/// The sun in the sky (galaxy_sky_build) and the agent's daylight
/// (exped_daylight) read this one bearing: the planet's orbit angle by
/// the universal clock, plus 180 (the star seen from the planet), in the
/// galactic plane (y = 0, x = cos / z = sin - the shared frame).
function galaxy_sun_dir(_ahead = 0, _d = undefined) {   // (ahead = seconds from now - the season's look along the orbit; d = a board world: ITS star, else the home's - 2026-09-16)
	var _hm = is_struct(_d) ? galaxy_world_sys(_d) : galaxy_home();
	var _pl = _hm.sys.planets[_hm.planet];
	var _now = universal_now() + _ahead;
	var _ang = (_pl.ang + _pl.spd * 60 * _now) mod 360;
	var _sb = _ang + 180;
	return [dcos(_sb), 0, dsin(_sb)];
}
