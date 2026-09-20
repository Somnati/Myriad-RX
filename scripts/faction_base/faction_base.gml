/// @description faction_base(region, kind) -> the kind's BASELINE heads in this region (q283): from the region's weight (a city's bandits are many, a wilderness camp's few); the organised kinds a third more
function faction_base(_rg, _kind) {
	var _w = region_weight(_rg), _b = 6 + 8 * _w;
	if (_kind == "bandit" || _kind == "goblin" || _kind == "kobold") _b *= 1.3;
	return max(4, round(_b));
}
