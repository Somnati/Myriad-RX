/// @description belt_sys(star_seed, sys, stations) -> the star's ASTEROID BELTS: an array (0..2) of
/// { seed, name, orbit, width, n, col, lanes[], rocks : [[r, a0, y, b, spd, size], ...], bigs : [{ r, a0, y, spd, st }, ...] }
/// THE POLISH (his pick, 2026-09-17): STRUCTURE - one or two LANES cleared
/// out of the band (a radius the rocks avoid, the next world's doing) and
/// two or three FAMILIES (a knot of rocks sharing one angle and one pace,
/// drifting together); SIZES - most rocks a pixel, some 2x2, a few 3x3,
/// and two or three BIG ONES (`bigs`: a tumbling solid through the
/// station shader, lit from the star; their own slow spin); the size rides
/// each rock as its sixth number.
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
		// the gap: between two worlds (never the innermost gap - too close to the star), or past the last; not a station's.
		// THE GAP LAW (his report, 2026-09-17: "the adjacent rings next to the asteroid belts are too close"): the belt sits
		// at the gap's CENTRE and is two fifths of the gap wide, so three tenths of the gap stays clear on either side
		var _orbit = 0, _gap = 12, _tries = 0;
		while (_orbit <= 0 && _tries < 8) {
			_tries++;
			var _slot = (_np > 1) ? irandom_range(1, _np) : _np;
			var _o = 0, _g = 12;
			if (_np == 0) { _o = 40 + random(30); _g = 14; }
			else if (_slot >= _np) { _g = 13; _o = _pls[_np - 1].orbit + _g; }
			else { _g = _pls[_slot].orbit - _pls[_slot - 1].orbit; _o = (_pls[_slot - 1].orbit + _pls[_slot].orbit) * .5; }
			if (_g < 9) continue;   // (a tight gap keeps no belt)
			var _ok = true;
			for (var _j = 0; _j < array_length(_stns); _j++) if (abs(_stns[_j].orbit - _o) < _g * .5) _ok = false;
			for (var _j = 0; _j < array_length(_out); _j++) if (abs(_out[_j].orbit - _o) < _g) _ok = false;
			if (_ok) { _orbit = _o; _gap = _g; }
		}
		if (_orbit <= 0) break;
		var _width = _gap * .4, _nr = irandom_range(150, 240), _dir = choose(1, -1);
		var _base = merge_colour(rgb(160, 152, 145), _sys.star.col, .12);
		// THE LANES: one or two radii the rocks keep clear of (a fifth of the band each)
		var _lanes = [];
		repeat (irandom_range(1, 2)) array_push(_lanes, _orbit + (random(1) - .5) * _width * .7);
		// THE FAMILIES: two or three knots - a shared angle, a shared pace
		var _fams = [];
		repeat (irandom_range(2, 3)) array_push(_fams, { a : random(360), r : _orbit + (random(1) - .5) * _width * .5, spd : _dir * random_range(.7, 1.3) / _orbit / 600, n : irandom_range(10, 22) });
		var _rocks = [];
		for (var _k = 0; _k < _nr; _k++) {
			var _rr = _orbit + (random(1) - random(1)) * _width * .5;   // (a triangular spread: thick in the middle, thin at the edges)
			var _lane = false;
			for (var _li = 0; _li < array_length(_lanes); _li++) if (abs(_rr - _lanes[_li]) < _width * .1) _lane = true;
			if (_lane && random(1) < .85) continue;   // (a lane: nearly empty, not quite)
			var _szr = random(1), _sz = (_szr < .9) ? 1 : ((_szr < .98) ? 2 : 3);
			array_push(_rocks, [_rr, random(360), (random(1) - random(1)) * 1.1, random_range(.35, 1), _dir * random_range(.7, 1.3) / _rr / 600, _sz]);
		}
		for (var _fi = 0; _fi < array_length(_fams); _fi++) {
			var _fm = _fams[_fi];
			repeat (_fm.n) array_push(_rocks, [_fm.r + (random(1) - random(1)) * _width * .12, _fm.a + (random(1) - random(1)) * 9, (random(1) - random(1)) * .6, random_range(.5, 1), _fm.spd, (random(1) < .85) ? 1 : 2]);
		}
		// THE BIG ONES: two or three solids (the station shader's), each its own tumble
		var _bigs = [];
		repeat (irandom_range(2, 3)) {
			var _br = _orbit + (random(1) - random(1)) * _width * .4;
			var _bst = { shape : choose(0, 3, 3, 1, 6), prm : [random_range(.8, 1.2), random_range(.7, 1.3), 0, 0], lean : random_range(-60, 60), spin : random_range(.05, .12) * choose(1, -1),
			             hull : merge_colour(_base, rgb(95, 90, 88), random_range(.2, .5)), glow : _base, sseed : random(6.28) };
			array_push(_bigs, { r : _br, a0 : random(360), y : (random(1) - random(1)) * .8, spd : _dir * random_range(.7, 1.3) / _br / 600, size : random_range(.55, .95), st : _bst });
		}
		// THE DUST: scattered across the band (a haze, not rings - his report 2026-09-17), turning at the belt's mean pace
		var _dust = [];
		repeat (320) array_push(_dust, [_orbit + (random(1) - random(1)) * _width * .55, random(360), (random(1) - random(1)) * .8, random_range(.3, 1)]);
		array_push(_out, { seed : _s, name : _name, orbit : _orbit, width : _width, n : array_length(_rocks), col : _base, lanes : _lanes, rocks : _rocks, bigs : _bigs, dust : _dust, dspd : _dir * 1 / _orbit / 600 });
	}
	rng_release(_old);
	_c[$ _key] = _out;
	return _out;
}
