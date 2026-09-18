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
	// THE GREAT ONES (his ask, 2026-09-17: a giant or a hole "much larger than all the surrounding planets ... the distance
	// from the first ring onward much higher"): their first ring starts far out and the system may reach further
	var _skd0 = is_struct(_star) ? (_star[$ "skind"] ?? "main") : "main", _great = (_skd0 == "giant" || _skd0 == "hole");
	var _r  = _great ? 96 : 34, _rmax = _great ? 210 : 112;
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
	if (_r > _rmax) { var _sc = _rmax / _r; for (var _i = 0; _i < _pc; _i++) _pl[_i].orbit *= _sc; }
	var _st = { col : color_set_random(), size : random_range(9, 16) };
	if (is_struct(_star)) {
		_st = { col : _star.color, size : 8 + _star.size * 1.4, hole : (_star[$ "hole"] ?? false), skind : _skd0, spin : (_star[$ "spin"] ?? 1), tilt : (_star[$ "tilt"] ?? 40) };   // (hole: a black hole; skind: giant / dwarf / pulsar / main - 2026-09-17)
		if (_skd0 == "giant") _st.size = 50 + _star.size * 4;        // (62-68: three times the biggest world across)
		else if (_skd0 == "hole") _st.size = 44 + _star.size * 6;    // (53-60; the core 75-83)
	}
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
	// DEBUG_HOME (q210): the home star (its props carry dbg_home = the home planet's index) holds every kind of world - the
	// kinds it lacks are given to its other planets in place: the DESERT (the "dust" family: a rock at clim .27) to the
	// next planet inward from home, else outward; the LAVA world (clim .10) to the innermost still free; the GAS GIANT
	// to the outermost still free. The rolls above stand; only kind, clim and size move - deterministic, so every
	// generation of the system agrees
	if (DEBUG_HOME && is_struct(_star) && !is_undefined(_star[$ "dbg_home"]) && array_length(_pl) >= 4) {
		var _hp = clamp(_star.dbg_home, 0, array_length(_pl) - 1), _npl = array_length(_pl);
		var _used = array_create(_npl, false); _used[_hp] = true;
		var _hd = false, _hl = false, _hg = false;
		for (var _i = 0; _i < _npl; _i++) { if (_i == _hp) continue; var _p2 = _pl[_i];
			if (_p2.kind == "gas") { if (!_hg) { _hg = true; _used[_i] = true; } }
			else if (_p2.clim < .2) { if (!_hl) { _hl = true; _used[_i] = true; } }
			else if (_p2.clim < .35) { if (!_hd) { _hd = true; _used[_i] = true; } } }
		if (!_hd) { var _di = -1; for (var _i = _hp - 1; _i >= 0 && _di < 0; _i--) if (!_used[_i]) _di = _i; for (var _i = _hp + 1; _i < _npl && _di < 0; _i++) if (!_used[_i]) _di = _i;
			if (_di >= 0) { _pl[_di].kind = "rock"; _pl[_di].clim = .27; _pl[_di].size = clamp(_pl[_di].size, 2.5, 4.6); _used[_di] = true; } }
		if (!_hl) { var _li = -1; for (var _i = 0; _i < _npl && _li < 0; _i++) if (!_used[_i]) _li = _i;
			if (_li >= 0) { _pl[_li].kind = "rock"; _pl[_li].clim = .10; _pl[_li].size = clamp(_pl[_li].size, 2.5, 4.6); _used[_li] = true; } }
		if (!_hg) { var _gi = -1; for (var _i = _npl - 1; _i >= 0 && _gi < 0; _i--) if (!_used[_i]) _gi = _i;
			if (_gi >= 0) { _pl[_gi].kind = "gas"; _pl[_gi].size = max(_pl[_gi].size, 5 + 3 * ((hash_mix(_pl[_gi].seed, 9) mod 1000) / 1000)); _pl[_gi].moon_n = max(_pl[_gi].moon_n, 2); _used[_gi] = true; } }
	}
	var _sr2 = colour_get_red(_st.col), _sb2 = colour_get_blue(_st.col);
	_st.temp_k = round(lerp(2600, 21000, clamp((_sb2 - _sr2 + 255) / 510, 0, 1)) / 100) * 100 + irandom_range(-2, 2) * 100;
	_st.age = round(random_range(.4, 12) * 10) / 10;
	rng_release(_old);
	return { seed : _seed, star : _st, planets : _pl };
}
