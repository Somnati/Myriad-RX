/// @description faction_mean(dest, ri, kinds, [region]) -> the mean strength of these kinds here (q283): the road's own kinds, for the encounter's lean
function faction_mean(_d, _ri, _kinds, _rg = undefined) {
	if (!is_array(_kinds) || array_length(_kinds) == 0) return 1;
	if (is_undefined(_rg)) _rg = region_get(_d, _ri);
	var _s = 0;
	for (var _i = 0; _i < array_length(_kinds); _i++) _s += faction_get(_d, _ri, _kinds[_i], _rg).str;
	return _s / array_length(_kinds);
}
