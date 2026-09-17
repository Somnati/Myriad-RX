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
	_ps.oe = _ps.ctx.fbm3(_px * 2.3, _py * 2.3, _pz * 2.3, _ps.o1, 3);
	_ps.od = _ps.ctx.fbm3(_px * 6.1, _py * 6.1, _pz * 6.1, _ps.o2, 2);
	_ps.om = _ps.ctx.fbm3(_px * 3.2, _py * 3.2, _pz * 3.2, _ps.o3, 2);
}
