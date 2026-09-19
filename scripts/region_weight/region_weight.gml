/// @description region_weight(region) -> the region's WEIGHT, its population as the lanes' physics (q259): wilderness ~.6 .. a city region ~3.5
/// The biggest place there is (a settlement .5, a village 1, a town
/// 1.6, a city 2.6) plus a fifth per civilised node, on a floor of .6.
/// Every push on a lane is divided by it and every recovery multiplied
/// by it - one crew is a legend in a hamlet region and a drop in the
/// ocean of a city, which repairs itself in a week
function region_weight(_rg) {
	var _top = 0, _nciv = 0, _kk = region_kinds();
	for (var _i = 0; _i < array_length(_rg.nodes); _i++) {
		var _k = _rg.nodes[_i].kind, _kd = _kk[$ _k];
		if (is_struct(_kd) && _kd.civ) _nciv++;
		switch (_k) { case "settlement": _top = max(_top, .5); break; case "village": _top = max(_top, 1); break; case "town": _top = max(_top, 1.6); break; case "city": _top = max(_top, 2.6); break; }
	}
	return max(.6, .4 + _top + .2 * _nciv);
}
