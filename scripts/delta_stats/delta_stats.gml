/// @description delta_stats(d) -> { land, newland, wet, fields, sea0n } the counts the page shows: land cells, the delta (sea at the start, land now), wet land, fields growing
function delta_stats(_d) {
	var _n = _d.w * _d.h, _land = 0, _dl = 0, _wet = 0, _fld = 0, _s0 = 0;
	for (var _i = 0; _i < _n; _i++) {
		if (_d.sea0[_i]) _s0++;
		if (_d.hgt[_i] < _d.sea) continue;
		_land++;
		if (_d.sea0[_i]) _dl++;
		if (_d.wet[_i] > .12) _wet++;
		if (_d.crop[_i] > 0) _fld++;
	}
	return { land : _land, newland : _dl, wet : _wet, fields : _fld, sea0n : _s0 };
}
