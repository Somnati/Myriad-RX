/// @description exped_weather(trip) -> the sky over the region now: "clear" / "rain" / "snow" / "fog" / "wind" / "storm"
/// Ten-minute slots of the universal clock, hashed with the region's
/// seed so it is the same weather for everyone looking, and it does
/// not flicker: clear half the time, rain (snow on an ice world) a
/// fifth, the rest wind, fog, a storm now and then.
function exped_weather(_tr) {
	var _rg = exped_region(_tr);
	var _slot = floor((date_current_datetime() * 86400) / 600);
	var _h = ((_rg.seed ^ (_slot * 2654435761)) * 1103515245 + 12345) & $7fffffff;
	_h = ((_h ^ (_h >> 13)) * 1274126177) & $7fffffff;
	var _r = (_h mod 1000) / 10;   // 0..100
	var _ice = (exped_biomes()[_tr.dest.biome].name == "ice");
	if (_r < 50) return "clear";
	if (_r < 70) return _ice ? "snow" : "rain";
	if (_r < 82) return "wind";
	if (_r < 92) return "fog";
	return "storm";
}
