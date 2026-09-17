/// @description station_sys(star_seed, sys) -> the star's SPACE STATIONS: an array (0..2) of
/// { seed, name, kind, line, shape, prm[4], orbit, ang, spd, size, lean, spin, hull, glow, sseed }
/// SPACE STATIONS, THE SECOND TAKE (his call, 2026-09-17: "in orbit of the
/// star, not the planet ... click on one like I do a planet to zoom in ...
/// simple shapes like pyramids, cubes, spheres"): a hash of the star's seed
/// decides how many (none / one / two), each on its own orbit ring between
/// two worlds' rings (or past the last, or inside the first), a plain
/// solid - cube, sphere, pyramid, octahedron, cylinder, ring, cone - its
/// proportions seeded, turning slowly on a leaned axis, a warm-windowed
/// hull grey-blue or grey-warm. Named by the planet generator plus a
/// word for what it is. Nothing rolled on the ambient stream, nothing
/// saved; cached by the star's seed for the session.
function station_sys(_seed, _sys) {
	static _c = {};
	static _shapes = ["cube", "sphere", "pyramid", "octahedron", "cylinder", "ring", "cone"];
	static _kinds = [
		{ k : "a trading post",  l : ["ships come and go. nobody asks where from.", "everything is for sale, including the chairs.", "the docks never close. the bar never opens."] },
		{ k : "a listening post", l : ["it hears everything. it says nothing.", "the dishes turn to face things that are not there.", "quiet inside. quieter outside."] },
		{ k : "a shipyard",       l : ["half-built hulls hang off it like fruit.", "sparks, day and night. there is no day or night.", "they will build you anything. they will not tell you when."] },
		{ k : "a lighthouse",     l : ["a light that turns, for ships that do not come.", "one keeper, one lamp, one long shift.", "it has saved nobody yet. it is ready."] },
		{ k : "a monastery",      l : ["they keep a silence you can hear from orbit.", "bells, once an hour. nobody knows why.", "the gardens are the best in the system. there are no other gardens."] },
		{ k : "a customs house",  l : ["forms. stamps. a queue with no one in it.", "declare everything. they already know.", "the inspector is asleep. this is by design."] },
		{ k : "a relay",          l : ["messages pass through it and are not read. mostly.", "a hum you feel in your teeth.", "it points at a star that went out."] },
		{ k : "a waystation",     l : ["beds by the hour. soup by the bowl.", "everyone here is on the way somewhere else.", "the guestbook goes back centuries. the pens do not."] },
		{ k : "an observatory",   l : ["a very large eye, and someone to close it at night.", "they have seen the edge. they will not say what is past it.", "charts on every wall, and one wall left for the next one."] },
		{ k : "a refinery",       l : ["it takes rock in and lets something else out.", "the smell reaches you before the dock does.", "profitable, and proud of the noise."] },
		{ k : "a tollhouse",      l : ["a gate across nothing, and a fee for it.", "the barrier is painted. the fee is not.", "exact change only. there is no change."] },
		{ k : "a beacon",         l : ["it blinks. it has always blinked.", "a lamp for the lost, kept by the found.", "you can see it from the next star. they say."] },
	];
	var _key = string(_seed);
	if (variable_struct_exists(_c, _key)) return _c[$ _key];
	var _out = [];
	var _h = hash_mix(_seed, 71) mod 100;
	var _n = (_h < 15) ? 0 : ((_h < 65) ? 1 : 2);
	var _pls = _sys.planets, _np = array_length(_pls);
	var _old = random_get_seed();
	for (var _i = 0; _i < _n; _i++) {
		var _s = hash_mix(_seed, 700 + _i * 13);
		random_set_seed(_s & $7fffffff);
		var _name = gen_name_planet() + " station";
		var _kind = _kinds[irandom(array_length(_kinds) - 1)];
		var _line = _kind.l[irandom(array_length(_kind.l) - 1)];
		var _shape = irandom(array_length(_shapes) - 1);
		var _prm = [random_range(.8, 1.2), random_range(.7, 1.3), random_range(0, 1), random_range(0, 1)];
		// the ring: a slot between two worlds, past the last, or inside the first (each station its own slot)
		var _slot = irandom(_np), _orbit = 20;
		if (_np == 0) _orbit = 30 + random(30);
		else if (_slot >= _np) _orbit = _pls[_np - 1].orbit * random_range(1.15, 1.3);
		else if (_slot == 0) _orbit = _pls[0].orbit * random_range(.55, .75);
		else _orbit = lerp(_pls[_slot - 1].orbit, _pls[_slot].orbit, random_range(.4, .6));
		if (_i > 0 && abs(_orbit - _out[0].orbit) < 5) _orbit += 6;
		var _hull = (random(1) < .5) ? merge_colour(rgb(150, 160, 185), rgb(120, 125, 140), random(1)) : merge_colour(rgb(175, 165, 150), rgb(130, 122, 112), random(1));
		array_push(_out, { seed : _s, name : _name, kind : _kind.k, line : _line, shape : _shape, shape_name : _shapes[_shape], prm : _prm,
			orbit : _orbit, ang : random(360), spd : random_range(.5, 1.6) / _orbit * choose(1, -1) / 600,   // (a planet's law: a year is days)
			size : random_range(1.3, 2.1), lean : random_range(-30, 30), spin : random_range(.02, .05) * choose(1, -1),
			hull : _hull, glow : rgb(255, 214, 150), sseed : random(6.28) });
	}
	rng_release(_old);
	_c[$ _key] = _out;
	return _out;
}
