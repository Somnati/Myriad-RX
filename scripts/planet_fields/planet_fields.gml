/// @description planet_fields(ps, u, v) - the terrain's noise FIELDS at a map coordinate: ps.oe (elevation; a giant's swirl), ps.od (detail; a giant's warp), ps.om (moisture)
/// The half of planet_texel that costs (seven octaves of value noise on
/// the sphere); planet_biome reads what it writes. Split 2026-09-17
function planet_fields(_ps, _u, _v) {
	var _sl  = sin(_v * pi);
	var _py  = cos(_v * pi);
	var _lon = _u * 2 * pi;
	var _px  = _sl * cos(_lon);
	var _pz  = _sl * sin(_lon);
	if (_ps.kind == "gas") {
		_ps.od = (_ps.ctx.fbm3(_px * 2.6, _py * 2.6, _pz * 2.6, _ps.o1, 2) - .5) * .14;
		_ps.oe = _ps.ctx.fbm3(_px * 5.2, _py * 5.2, _pz * 5.2, _ps.o2, 2);
		_ps.om = 0;
		return;
	}
	// THE WARP (his pick, 2026-09-17: "warped coasts"): the point every field is read at is bent by a slow noise -
	// two fields, east and south - so the continents' edges fold into fjords, bays, peninsulas and island arcs
	// instead of the noise's soft blobs. Every field reads the bent point, so the land's shape and its climate agree
	// THE GRAMMAR (q247): the temper's numbers where constants stood - the defaults ARE the old constants, so a sampler
	// without a temper reads exactly as before
	var _tt = _ps[$ "tt"];
	var _cs = 2.3, _rlf = .65, _rdg = .13, _wpa = .30, _rgh = 1;
	if (is_struct(_tt)) { _cs = _tt.cscale; _rlf = .65 * _tt.relief / .78; _rdg = _tt.ridge; _wpa = _tt.warp; _rgh = _tt.rough; }
	var _wx = (_ps.ctx.fbm3(_px * 1.7, _py * 1.7, _pz * 1.7, _ps.o1 + 577, 2) - .5) * _wpa;
	var _wz = (_ps.ctx.fbm3(_px * 1.7 + 3.1, _py * 1.7, _pz * 1.7 + 1.7, _ps.o1 + 911, 2) - .5) * _wpa;
	var _qx = _px + _wx, _qz = _pz + _wz;
	var _e = _ps.ctx.fbm3(_qx * _cs, _py * _cs, _qz * _cs, _ps.o1, 3);
	// THE LAND'S SHAPE and the hemisphere's lean (q247): a smooth field laid on the noise before the sea decides -
	// pangaea (land toward one point of the sphere), twins (land at both ends of an axis), a belt (the equator), polar
	// continents, a ring of islands (the temper's fine scale did that); zero-mean, so the sea level keeps its meaning
	if (is_struct(_tt)) {
		var _sd = _tt.sdir, _dm = _px * _sd[0] + _py * _sd[1] + _pz * _sd[2];
		switch (_tt.shape) {
			case 1: _e += .10 * _dm; break;
			case 2: _e += .09 * (abs(_dm) - .5); break;
			case 3: _e += .16 * (.5 - abs(_py)); break;
			case 4: _e += .15 * (abs(_py) - .5); break;
			case 5: _e -= .02; break;
		}
		var _hx = _tt.hax;
		_e += _tt.hemi * (_px * _hx[0] + _py * _hx[1] + _pz * _hx[2]);
	}
	// THE RANGES (his pick: "mountain ranges instead of mountain blobs"): a RIDGED noise - a crest wherever a second
	// noise crosses its own middle (a band .06 wide about .5: this value noise keeps within a tenth of its middle,
	// so the band must be that narrow to be lines and not a plateau - tuned on a stand-in, 2026-09-17) - raised
	// over the land (a mask from the sea level up: the coast keeps its place, the ocean floor is untouched), while
	// the old noise's highs are pressed down to seven tenths so the crests are the mountains and the lumps are
	// hills. Chains, not lumps; the drainage finds the valleys between them on its own
	var _n = _ps.ctx.fbm3(_qx * 3.4, _py * 3.4, _qz * 3.4, _ps.o1 + 313, 2);
	var _rg = power(clamp(1 - abs(_n - .5) / .06, 0, 1), 1.3);
	var _lm = clamp((_e - _ps.sea) / .10, 0, 1);
	_lm = _lm * _lm * (3 - 2 * _lm);
	if (_e > _ps.sea) _e = _ps.sea + (_e - _ps.sea) * _rlf;   // (the noise's lumps are hills - the temper's relief says how tall; the ranges are planet_ranges' skeleton + the ridge noise's mass)
	_ps.oe = _e + _rg * _rdg * _lm;   // (a massif's irregular mass under the skeleton's branches - the temper's ridged mass; .13 was the one number)
	_ps.od = _ps.ctx.fbm3(_qx * 6.1 * _rgh, _py * 6.1 * _rgh, _qz * 6.1 * _rgh, _ps.o2, 2);
	_ps.om = _ps.ctx.fbm3(_qx * 3.2, _py * 3.2, _qz * 3.2, _ps.o3, 2);
}
