/// @description region_weather(dest, region) -> the sky over the region now: "clear" / "rain" / "snow" / "fog" / "wind" / "storm"
/// Ten-minute slots of the universal clock, hashed with the region's
/// seed (hash_mix) so it is the same weather for everyone looking and
/// it does not flicker: clear half the time, rain (snow on an ice
/// world) a fifth, the rest wind, fog, a storm now and then. The agent
/// reads it through exped_weather; the info box says it.
function region_weather(_d, _rg) {
	var _slot = floor(universal_now() / 600);
	var _r = (hash_mix(_rg.seed, _slot) mod 1000) / 10;   // 0..100
	var _bn = exped_biomes()[_d.biome].name, _ice = (_bn == "ice");
	// THE WORLD'S SKIES (the planet-properties pass, 2026-09-15): the bands
	// lean on its wetness - a dry world is clear two thirds of the time and
	// hardly storms; a stormy one rains a third of it
	var _wet = planet_props(_d).wet;
	var _bc = lerp(66, 34, _wet), _br = lerp(8, 32, _wet), _bw = lerp(14, 10, _wet), _bf = lerp(6, 14, _wet), _bs = lerp(2, 10, _wet);
	_r *= (_bc + _br + _bw + _bf + _bs) / 100;
	if (_r < _bc) return "clear";
	if (_r < _bc + _br) return _ice ? "snow" : "rain";
	if (_r < _bc + _br + _bw) return "wind";
	if (_r < _bc + _br + _bw + _bf) return "fog";
	return "storm";
}
