/// @description planet_props(dest) -> the world's PROPERTIES: { dayh, grav, gravw, airw, wet, wetw, moons, moonw, young, agew, seasw, ncity, peoplew, price, odd, oddw, lines }
/// THE PLANET-PROPERTIES PASS (2026-09-15): what a world IS, beyond its
/// biome - hashed off its seed (hash_mix: no random stream touched, so it
/// is safe to read anywhere) and read off the render's own planet
/// (planet_get: the day's length is its spin, the skies its wetness,
/// the seas its sea level, the people its cities). The words are the
/// world box's; the numbers are the mechanics':
///   grav    the roads' pace (x1.15 light / 1 / .85 heavy - exped_agent, exped_eta)
///   wet     region_weather's bands lean on it (dry skies, stormy skies)
///   moons   the dark: a moonless night doubles the wrong turns, two moons halve them
///   young   the ground quakes now and then on the road (exped_road_beat)
///   price   the shops' prices (+1 few and far / 0 / -1 settled)
///   odd     the oddity (0..13) - the diary's lines are gated on it
/// lines = [{ k, v, t, [col] }] the box's rows (the info box's shape).
/// Cached on the dest struct (pp) - a world is asked about every frame.
function planet_props(_d) {
	if (is_struct(_d[$ "pp"])) return _d.pp;
	var _pn = planet_get(_d.seed, exped_planet_hint(_d));
	var _s = _d.seed;
	static _h = function(_s2, _salt) { return hash_mix(_s2, 9001 + _salt) mod 100; };
	var _dayh = 360 / max(.0001, abs(_pn.spin) * 60 * 3600);
	var _gr = _h(_s, 1);
	var _grav = (_gr < 20) ? 1.15 : ((_gr < 75) ? 1 : .85), _gravw = (_gr < 20) ? "light" : ((_gr < 75) ? "normal" : "heavy");
	var _ar = _h(_s, 2);
	var _airw = (_ar < 20) ? "thin" : ((_ar < 65) ? "fair" : ((_ar < 85) ? "thick" : "sweet"));
	var _mr = _h(_s, 3);
	var _moons = (_mr < 30) ? 0 : ((_mr < 75) ? 1 : ((_mr < 95) ? 2 : 3));
	var _moonw = ["none", "one", "two", "three"][_moons];
	var _ag = _h(_s, 4);
	var _young = (_ag < 30), _agew = _young ? "young and restless" : ((_ag < 75) ? "settled" : "old and worn");
	var _odd = hash_mix(_s, 9005 + 77) mod 14;
	static _odds = ["upward rain", "two shadows", "backward birds", "a hum at night", "two sunsets", "uphill water", "watchful trees",
	                "sandwich compasses", "a square moon", "early echoes", "warm ground", "moving stars", "numbered rocks", "bread wind"];
	var _wet = clamp(_pn[$ "wet"] ?? .5, 0, 1);
	var _wetw = (_wet < .2) ? "dry" : ((_wet < .5) ? "fair" : ((_wet < .75) ? "wet" : "stormy"));
	var _sea = clamp(_pn[$ "sea"] ?? .3, 0, 1);
	var _seasw = (_sea < .15) ? "landlocked" : ((_sea < .4) ? "lakes" : ((_sea < .7) ? "seas" : "an ocean world"));
	var _ncity = (is_struct(_pn[$ "civ"]) && is_array(_pn.civ[$ "cities"])) ? array_length(_pn.civ.cities) : 0;
	var _peoplew = (_ncity == 0) ? "few and far" : ((_ncity <= 3) ? "villages" : "settled");
	var _price = (_ncity == 0) ? 1 : ((_ncity > 3) ? -1 : 0);
	var _lines = [
		{ k : "day",     v : string_format(_dayh, 1, 1) + " hours", t : (_dayh < 2 || _dayh > 5) ? 1 : 0 },
		{ k : "gravity", v : _gravw, t : (_gravw == "heavy") ? 2 : 0 },
		{ k : "air",     v : _airw, t : (_airw == "thin") ? 1 : 0 },
		{ k : "skies",   v : _wetw, t : (_wetw == "stormy") ? 2 : ((_wetw == "wet") ? 1 : 0) },
		{ k : "moons",   v : (_moons == 0) ? "none - dark nights" : _moonw, t : (_moons == 0) ? 1 : 0 },
		{ k : "ground",  v : _agew, t : _young ? 2 : 0 },
		{ k : "seas",    v : _seasw, t : 0 },
		{ k : "people",  v : _peoplew, t : (_ncity == 0) ? 1 : 0 },
		{ k : "oddity",  v : _odds[_odd], t : 0, col : c_lavender },
	];
	_d.pp = { dayh : _dayh, grav : _grav, gravw : _gravw, airw : _airw, wet : _wet, wetw : _wetw, moons : _moons, moonw : _moonw,
	          young : _young, agew : _agew, seasw : _seasw, ncity : _ncity, peoplew : _peoplew, price : _price, odd : _odd, oddw : _odds[_odd], lines : _lines };
	return _d.pp;
}
