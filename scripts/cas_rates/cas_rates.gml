/// @description cas_rates(c, lfield) -> the per-second rates of a cascade's tiers, LOG10: the per-10 doubling on bought units x the field (x1.15 a level, both sides)
function cas_rates(_c, _lfield) {
	var _la = array_create(COLL_N);
	for (var _i = 0; _i < COLL_N; _i++) _la[_i] = (_c.bought[_i] div 10) * log10(2) + _lfield;
	return _la;
}
