/// @description region_season(dest, region) -> { on, idx, name, lean, rising, warm } - the season over the region now
/// SEASONS (his question, 2026-09-16: "considering the planets rotate
/// around the sun in real time is seasons viable?" - they were already
/// there in the geometry): region_daylight turns a spot by the world's
/// TILT (a fixed axis in world space) and the sun's bearing walks the
/// orbit (galaxy_sun_dir), so the hemisphere leaning at the sun changes
/// through the year - long days one half of the orbit, long nights the
/// other. This names it: the LEAN is the axis against the sun for the
/// region's hemisphere, -1 (its deepest winter) .. 1 (its high summer),
/// scaled by the tilt so every tilted world gets the full range; RISING
/// is a look a fraction of the year ahead. idx 0 spring / 1 summer /
/// 2 autumn / 3 winter; name the word. WARM is the shift the season puts
/// on the region's cold (region_info's temperature, region_weather's
/// snow line): a big tilt swings it more. A world tilted under four
/// degrees has no seasons (on = false). A year is the home orbit's (the
/// sun's bearing is one for every world - region_daylight's shortcut).
function region_season(_d, _rg) {
	static _nm = ["spring", "summer", "autumn", "winter"];
	var _pn = planet_get(_d.seed, exped_planet_hint(_d));
	var _tilt = _pn[$ "tilt"] ?? 0;
	if (abs(_tilt) < 4) return { on : false, idx : 1, name : "", lean : 0, rising : false, warm : 0 };
	// the world's axis: the pole turned by the same matrix region_daylight turns a spot by
	var _ax = mat3_apply(mat3_rot(0, 0, 1, _tilt), 0, 1, 0);
	var _hm = galaxy_home(), _pl = _hm.sys.planets[_hm.planet];
	var _yr = 360 / max(.000000001, abs(_pl.spd) * 60);   // the year in seconds
	var _s0 = galaxy_sun_dir(), _s1 = galaxy_sun_dir(_yr / 48);
	var _hemi = (_rg.spot.lat >= 0) ? 1 : -1;
	var _sc = _hemi / max(.05, dsin(abs(_tilt)));
	var _l0 = clamp((_ax[0] * _s0[0] + _ax[1] * _s0[1] + _ax[2] * _s0[2]) * _sc, -1, 1);
	var _l1 = clamp((_ax[0] * _s1[0] + _ax[1] * _s1[1] + _ax[2] * _s1[2]) * _sc, -1, 1);
	var _rising = (_l1 > _l0);
	var _idx = (_l0 > .5) ? 1 : ((_l0 < -.5) ? 3 : (_rising ? 0 : 2));
	return { on : true, idx : _idx, name : _nm[_idx], lean : _l0, rising : _rising, warm : _l0 * abs(_tilt) / 28 * .12 };
}
