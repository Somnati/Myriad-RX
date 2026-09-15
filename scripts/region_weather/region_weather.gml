/// @description region_weather(dest, region) -> the sky over the region now: "clear" / "rain" / "snow" / "fog" / "wind" / "storm"
/// Ten-minute slots of the universal clock, hashed with the region's
/// seed (hash_mix) so it is the same weather for everyone looking and
/// it does not flicker: clear half the time, rain (snow on an ice
/// world) a fifth, the rest wind, fog, a storm now and then. The agent
/// reads it through exped_weather; the info box says it.
function region_weather(_d, _rg) {
	var _slot = floor(universal_now() / 600);
	var _r = (hash_mix(_rg.seed, _slot) mod 1000) / 10;   // 0..100
	var _ice = (exped_biomes()[_d.biome].name == "ice");
	if (_r < 50) return "clear";
	if (_r < 70) return _ice ? "snow" : "rain";
	if (_r < 82) return "wind";
	if (_r < 92) return "fog";
	return "storm";
}
