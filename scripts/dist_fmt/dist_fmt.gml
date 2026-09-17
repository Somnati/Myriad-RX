/// @description dist_fmt(km) - a distance for a readout, in the units the
/// setting picks: imperial (miles, feet under a tenth of a mile) or
/// metric (km, metres under 100 m). Kept in KM everywhere underneath
/// (the expedition ledger's road_km); only the readout converts. A
/// fresh save reads "0 ft" / "0 m".
function dist_fmt(_km) {
	_km = max(0, _km);
	var _imp = (!variable_global_exists("units_imperial")) || g.units_imperial;
	if (_imp) {
		var _mi = _km * 0.621371;
		if (_mi < 0.1) return string(round(_mi * 5280)) + " ft";
		if (_mi < 100) return string_format(_mi, 1, 1) + " mi";
		return string(round(_mi)) + " mi";
	}
	if (_km < 0.1) return string(round(_km * 1000)) + " m";
	if (_km < 100) return string_format(_km, 1, 1) + " km";
	return string(round(_km)) + " km";
}
