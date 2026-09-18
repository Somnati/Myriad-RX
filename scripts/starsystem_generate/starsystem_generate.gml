/// @description starsystem_generate(seed, [star props]) -> { seed, star, planets }
/// The tech demo's scr_starsystem_generate, returning the struct instead
/// of setting a global: the star plus 2-7 planets on orbit rings, every
/// planet's seed derived from the star's (the house per-child pattern),
/// archetypes by orbit (inner hot and dry, outer frozen, gas giants in
/// the middle-outer). The home planet's seed is one of these
/// (galaxy_home), so the expedition world IS a star's planet.
function starsystem_generate(_seed, _star = undefined) {
	var _old = random_get_seed();
	random_set_seed(_seed);
	var _pc = irandom_range(2, 7);
	var _pl = [];
	var _r  = 34;
	for (var _i = 0; _i < _pc; _i++) {
		_r += random_range(11, 16) * (1 + .14 * _i);   // (the gaps grow outward, a seventh a ring - his report 2026-09-17: "outer rings are still dense"; the same rolls)
		var _fr   = (_pc > 1) ? _i / (_pc - 1) : .5;
		var _clim = clamp(_fr + random_range(-.18, .18), 0, 1);
		var _gasp = (_fr < .3) ? .04 : lerp(.18, .55, _fr);
		var _kind = (random(1) < _gasp) ? "gas" : "rock";
		array_push(_pl, {
			seed     : (_seed ^ ((_i + 1) * 2654435761)) & $7fffffff,
			orbit    : _r,
			kind     : _kind,
			clim     : _clim,
			size     : (_kind == "gas") ? random_range(5, 8) : random_range(2.5, 4.6),
			col      : color_set_random(),
			ang      : random(360),
			spd      : random_range(.5, 1.6) / _r * choose(1, -1) / 600,   // (a YEAR IS DAYS, 2026-09-15: it was minutes - the sun swept round faster than the day; the same rolls)
			has_ring : (random(1) < ((_kind == "gas") ? .5 : .15)),
			moon_n   : (_kind == "gas") ? irandom_range(2, 4) : irandom_range(0, 2),
		});
	}
	if (_r > 112) { var _sc = 112 / _r; for (var _i = 0; _i < _pc; _i++) _pl[_i].orbit *= _sc; }
	var _st = { col : color_set_random(), size : random_range(9, 16) };
	if (is_struct(_star)) _st = { col : _star.color, size : 8 + _star.size * 1.4, hole : (_star[$ "hole"] ?? false), skind : (_star[$ "skind"] ?? "main"), spin : (_star[$ "spin"] ?? 1), tilt : (_star[$ "tilt"] ?? 40) };   // (hole: a black hole; skind: giant / dwarf / pulsar / main - 2026-09-17)
	// THE KIND'S WORLDS (2026-09-17): a red giant scorches its inner three rings (hot: ash and dust), a white dwarf
	// leaves its worlds cold (toward ice), a pulsar's are dead and frozen. The rolls above stand; only clim moves
	if (is_struct(_star)) {
		var _skd = _star[$ "skind"] ?? "main";
		for (var _i = 0; _i < array_length(_pl); _i++) {
			if (_skd == "giant")       { if (_i < 3) _pl[_i].clim = clamp(_pl[_i].clim - .45 + .1 * _i, 0, 1); }
			else if (_skd == "dwarf")  _pl[_i].clim = clamp(_pl[_i].clim + .30, 0, 1);
			else if (_skd == "pulsar") _pl[_i].clim = clamp(_pl[_i].clim + .55, 0, 1);
		}
	}
	var _sr2 = colour_get_red(_st.col), _sb2 = colour_get_blue(_st.col);
	_st.temp_k = round(lerp(2600, 21000, clamp((_sb2 - _sr2 + 255) / 510, 0, 1)) / 100) * 100 + irandom_range(-2, 2) * 100;
	_st.age = round(random_range(.4, 12) * 10) / 10;
	rng_release(_old);
	return { seed : _seed, star : _st, planets : _pl };
}
