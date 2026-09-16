/// @description planet_props(dest) -> the world's properties, worded: { dayh, dayw, climw, wet, wetw, seasw, moons, moonw, ring, ringw, lines }
/// THE PLANET-PROPERTIES PASS (take two, 2026-09-15 - his correction: not
/// new kinds of property, the EXISTING ones with more words, and the tech
/// demo's moons and rings): everything here is read off the render's own
/// planet (planet_get) - the day is its spin, the climate its clim, the
/// skies its wetness, the seas its sea level, the ring its own flag - and
/// the moons are planet_moons' count. Each word is picked from a pool by
/// the world's seed (hash_mix - no random stream touched), so two worlds
/// with the same reading do not read the same. The numbers the mechanics
/// use: wet (region_weather's bands lean on it), moons (a moonless night
/// is darker on the roads - exped_agent). lines = the world box's rows.
/// Cached on the dest struct (pp) - a world is asked about every frame.
function planet_props(_d) {
	if (is_struct(_d[$ "pp"])) return _d.pp;
	var _pn = planet_get(_d.seed, exped_planet_hint(_d));
	var _s = _d.seed;
	static _pick = function(_s2, _salt, _pool) { return _pool[hash_mix(_s2, 9001 + _salt) mod array_length(_pool)]; };
	// the day, in hours, and a word for its length
	var _dayh = 360 / max(.0001, abs(_pn.spin) * 60 * 3600);
	var _dp = (_dayh < 2.2) ? ["short days", "quick days", "days that hurry", "brief days"] : ((_dayh > 4.5) ? ["long days", "slow days", "days that linger", "lazy days"] : ["fair days", "even days", "steady days", "ordinary days"]);
	var _dayw = string_format(_dayh, 1, 1) + " hours  -  " + _pick(_s, 1, _dp);
	// the climate: the render's clim (0 hot .. 1 frozen)
	var _cl = clamp(_pn[$ "clim"] ?? .5, 0, 1), _cp, _ct;
	if (_cl < .18)      { _cp = ["scorching", "blistering", "searing", "a furnace", "sun-hammered"]; _ct = 3; }
	else if (_cl < .32) { _cp = ["hot", "sweltering", "baking", "sultry", "close and hot"]; _ct = 2; }
	else if (_cl < .45) { _cp = ["warm", "balmy", "kindly", "soft and warm", "summery"]; _ct = 0; }
	else if (_cl < .58) { _cp = ["mild", "temperate", "fair", "gentle", "even-tempered", "clement"]; _ct = 0; }
	else if (_cl < .70) { _cp = ["cool", "brisk", "fresh", "crisp", "autumnal"]; _ct = 1; }
	else if (_cl < .84) { _cp = ["cold", "chill", "raw", "bleak", "hard-frosted"]; _ct = 2; }
	else                { _cp = ["freezing", "bitter", "arctic", "iron-cold", "a deep freeze"]; _ct = 3; }
	var _climw = _pick(_s, 2, _cp);
	// the skies: the render's wetness (the weather bands lean on it - region_weather)
	var _wet = clamp(_pn[$ "wet"] ?? .5, 0, 1), _wp, _wt;
	if (_wet < .2)      { _wp = ["dry", "parched", "cloudless", "clear and dry", "rainless"]; _wt = 1; }
	else if (_wet < .5) { _wp = ["fair", "changeable", "mixed", "fair, mostly", "sun and cloud"]; _wt = 0; }
	else if (_wet < .75) { _wp = ["wet", "damp", "rainy", "drizzly", "grey and wet"]; _wt = 1; }
	else                { _wp = ["stormy", "wild", "thunderous", "storm-ridden", "always raining somewhere"]; _wt = 2; }
	var _wetw = _pick(_s, 3, _wp);
	// the seas: the render's sea level
	var _sea = clamp(_pn[$ "sea"] ?? .3, 0, 1), _sp;
	if (_sea < .15)     _sp = ["landlocked", "sea-less", "dry-shored", "no sea to speak of"];
	else if (_sea < .4) _sp = ["lakes", "meres and lakes", "inland waters", "lakes and rivers"];
	else if (_sea < .7) _sp = ["seas", "coasts and seas", "island seas", "wide seas"];
	else                _sp = ["an ocean world", "mostly water", "all sea and a little shore", "one great ocean"];
	var _seasw = _pick(_s, 4, _sp);
	// THE MOONS (the tech demo's, back): the home world's count is the galaxy's; a rolled world's is hashed - none / one / two / three
	var _hint = exped_planet_hint(_d);
	var _mv = hash_mix(_s, 9001 + 5) mod 100;
	var _moons = is_real(_hint[$ "moon_n"]) ? clamp(_hint.moon_n, 0, 4) : ((_mv < 35) ? 0 : ((_mv < 75) ? 1 : ((_mv < 95) ? 2 : 3)));
	var _mp = [["no moon", "moonless", "none at all", "no moon to speak of"], ["one moon", "a single moon", "one moon, and it is enough", "a lone moon"], ["two moons", "a pair of moons", "two moons, chasing each other", "twin moons"], ["three moons", "three moons, one of them shy", "a crowd of moons", "three, in a row some nights"], ["four moons", "a busy sky", "four moons, and counting", "a lot of moons"]];
	var _moonw = _pick(_s, 6, _mp[clamp(_moons, 0, 4)]);
	// THE RING: the render's own
	var _ring = _pn[$ "ring"] ?? false;
	var _ringw = _ring ? _pick(_s, 7, ["a ring", "ringed", "a bright ring", "a ring, thin and wide", "a ring you can see from the ground"]) : _pick(_s, 7, ["none", "no ring", "bare", "none - clean skies"]);
	var _lines = [
		{ k : "day",     v : _dayw, t : (_dayh < 2.2 || _dayh > 4.5) ? 1 : 0 },
		{ k : "climate", v : _climw, t : _ct },
		{ k : "skies",   v : _wetw, t : _wt },
		{ k : "seas",    v : _seasw, t : 0 },
		{ k : "moons",   v : _moonw, t : (_moons == 0) ? 1 : 0 },
		{ k : "ring",    v : _ringw, t : 0, col : _ring ? _pn.ring_col : undefined },
	];
	_d.pp = { dayh : _dayh, dayw : _dayw, climw : _climw, wet : _wet, wetw : _wetw, seasw : _seasw, moons : _moons, moonw : _moonw, ring : _ring, ringw : _ringw, lines : _lines,
	          grav : 1 };   // (gravity is normal everywhere - his call; the pace lane reads this)
	return _d.pp;
}
