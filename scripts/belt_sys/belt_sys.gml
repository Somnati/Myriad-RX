/// @description belt_sys(star_seed, sys, stations) -> the star's ASTEROID BELTS: an array (0..2) of
/// { seed, name, orbit, width, n, col, rocks : [[r, a0, y, b, spd], ...] }
/// ASTEROID BELTS (his ask, 2026-09-17): a hash of the star's seed decides
/// how many (none / one / two); each takes a gap between two worlds' rings
/// (or past the last) that no station holds, a band a few units wide, and
/// a few hundred ROCKS - each its own radius, start angle, a little lift
/// off the plane, a brightness and a Keplerish pace (slower further out,
/// the planets' law), so the belt turns as a crowd, not a wheel. Greys
/// with a breath of the star's colour. Nothing rolled on the ambient
/// stream, nothing saved; cached by the star's seed for the session.
function belt_sys(_seed, _sys, _stns = []) {
	static _c = {};
	var _key = string(_seed);
	if (variable_struct_exists(_c, _key)) return _c[$ _key];
	var _out = [];
	var _h = hash_mix(_seed, 131) mod 100;
	var _n = (_h < 30) ? 0 : ((_h < 78) ? 1 : 2);
	var _pls = _sys.planets, _np = array_length(_pls);
	var _old = random_get_seed();
	for (var _i = 0; _i < _n; _i++) {
		var _s = hash_mix(_seed, 900 + _i * 17);
		random_set_seed(_s & $7fffffff);
		var _name = "the " + gen_name_planet() + " belt";
		// the gap: between two worlds (never the innermost gap - too close to the star), or past the last; not a station's
		var _orbit = 0, _tries = 0;
		while (_orbit <= 0 && _tries < 8) {
			_tries++;
			var _slot = (_np > 1) ? irandom_range(1, _np) : _np;
			var _o = (_np == 0) ? 40 + random(30) : ((_slot >= _np) ? _pls[_np - 1].orbit * random_range(1.2, 1.4) : lerp(_pls[_slot - 1].orbit, _pls[_slot].orbit, random_range(.45, .55)));
			var _ok = true;
			for (var _j = 0; _j < array_length(_stns); _j++) if (abs(_stns[_j].orbit - _o) < 7) _ok = false;
			for (var _j = 0; _j < array_length(_out); _j++) if (abs(_out[_j].orbit - _o) < 9) _ok = false;
			if (_ok) _orbit = _o;
		}
		if (_orbit <= 0) break;
		var _width = random_range(3.5, 7), _nr = irandom_range(150, 240), _dir = choose(1, -1);
		var _base = merge_colour(rgb(160, 152, 145), _sys.star.col, .12);
		var _rocks = [];
		for (var _k = 0; _k < _nr; _k++) {
			var _rr = _orbit + (random(1) - random(1)) * _width * .5;   // (a triangular spread: thick in the middle, thin at the edges)
			array_push(_rocks, [_rr, random(360), (random(1) - random(1)) * 1.1, random_range(.35, 1), _dir * random_range(.7, 1.3) / _rr / 600]);
		}
		array_push(_out, { seed : _s, name : _name, orbit : _orbit, width : _width, n : _nr, col : _base, rocks : _rocks });
	}
	rng_release(_old);
	_c[$ _key] = _out;
	return _out;
}
