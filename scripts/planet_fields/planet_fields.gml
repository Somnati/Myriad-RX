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
	var _wx = (_ps.ctx.fbm3(_px * 1.7, _py * 1.7, _pz * 1.7, _ps.o1 + 577, 2) - .5) * .30;
	var _wz = (_ps.ctx.fbm3(_px * 1.7 + 3.1, _py * 1.7, _pz * 1.7 + 1.7, _ps.o1 + 911, 2) - .5) * .30;
	var _qx = _px + _wx, _qz = _pz + _wz;
	var _e = _ps.ctx.fbm3(_qx * 2.3, _py * 2.3, _qz * 2.3, _ps.o1, 3);
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
	if (_e > _ps.sea) _e = _ps.sea + (_e - _ps.sea) * .7;
	_ps.oe = _e + _rg * .22 * _lm;
	_ps.od = _ps.ctx.fbm3(_qx * 6.1, _py * 6.1, _qz * 6.1, _ps.o2, 2);
	_ps.om = _ps.ctx.fbm3(_qx * 3.2, _py * 3.2, _qz * 3.2, _ps.o3, 2);
}
