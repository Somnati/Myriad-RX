/// @description region_weather(dest, region) -> the sky over the region now: "clear" / "rain" / "snow" / "fog" / "wind" / "storm"
/// Ten-minute slots of the universal clock, hashed with the region's
/// seed (hash_mix) so it is the same weather for everyone looking and
/// it does not flicker: clear half the time, rain (snow on an ice
/// world) a fifth, the rest wind, fog, a storm now and then. The agent
/// reads it through exped_weather; the info box says it. The SEASON
/// (region_season, 2026-09-16) leans the bands.
function region_weather(_d, _rg) {
	var _slot = floor(universal_now() / 600);
	var _r = (hash_mix(_rg.seed, _slot) mod 1000) / 10;   // 0..100
	var _bn = exped_biomes()[_d.biome].name, _ice = (_bn == "ice");
	// THE WORLD'S SKIES (the planet-properties pass, 2026-09-15): the bands
	// lean on its wetness - a dry world is clear two thirds of the time and
	// hardly storms; a stormy one rains a third of it
	var _wet = planet_props(_d).wet;
	var _bc = lerp(66, 34, _wet), _br = lerp(8, 32, _wet), _bw = lerp(14, 10, _wet), _bf = lerp(6, 14, _wet), _bs = lerp(2, 10, _wet);
	// THE SEASON (2026-09-16): summer clears the sky and brews the storms, winter clouds it and, where it is cold enough, turns the rain to snow; spring rains, autumn fogs
	var _ss = region_season(_d, _rg);
	if (_ss.on) {
		_bc += 12 * _ss.lean; _bs *= 1 + max(0, _ss.lean) * .8;
		if (_ss.idx == 0) _br *= 1.3;
		if (_ss.idx == 2) _bf *= 1.6;
		var _pnw = planet_get(_d.seed, exped_planet_hint(_d));
		if (clamp(_pnw.clim + abs(_rg.spot.lat) / 90 * .25 - .06 - _ss.warm, 0, 1) > .58) _ice = true;   // (region_info's cold, shifted by the season: cool or colder = snow)
	}
	_r *= (_bc + _br + _bw + _bf + _bs) / 100;
	if (_r < _bc) return "clear";
	if (_r < _bc + _br) return _ice ? "snow" : "rain";
	if (_r < _bc + _br + _bw) return "wind";
	if (_r < _bc + _br + _bw + _bf) return "fog";
	return "storm";
}
