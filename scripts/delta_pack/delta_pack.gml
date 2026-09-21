/// @description delta_pack() -> the delta as one string for the save (q314): the ledger's numbers, then the grids as hex - heights two digits, the rest one
function delta_pack() {
	var _d = delta_init();
	var _n = _d.w * _d.h, _s0 = "";
	for (var _i = 0; _i < _n; _i++) _s0 += _d.sea0[_i] ? "1" : "0";
	var _lv = "";
	for (var _i = 0; _i < _n; _i++) _lv += string(_d.lev[_i]);
	return "1|" + string(_d.w) + "|" + string(_d.h) + "|" + string(_d.grain) + "|" + string(_d.life) + "|" + string(_d.rain) + "|" + string(_d.springs) + "|" + string(_d.rich) + "|" + string(_d.seed)
		+ "|" + string(_d.nlev) + "|" + string(_d.nchan) + "|" + string(_d.floods) + "|" + string(_d.flood_t) + "|" + string(_d.flood) + "|" + string(_d.harvests) + "|" + string(_d.silted) + "|" + string(_d.last) + "|" + string(_d.seedid)
		+ "|" + delta_hex(_d.hgt, -.1, 1, 2) + "|" + delta_hex(_d.silt, 0, 1, 1) + "|" + delta_hex(_d.wet, 0, 1, 1) + "|" + delta_hex(_d.crop, 0, 1, 1) + "|" + _lv + "|" + _s0 + "|" + string(_d.valley);
}
