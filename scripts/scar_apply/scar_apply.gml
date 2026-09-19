/// @description scar_apply(dest, ri, region) - the region's scars laid over the generator's nodes (region_get, every build; scar_land, at once) (q260)
function scar_apply(_d, _ri, _rg) {
	var _sc = scar_get(_d, _ri);
	for (var _i = 0; _i < array_length(_sc); _i++) {
		var _s = _sc[_i];
		if (_s.n < 0 || _s.n >= array_length(_rg.nodes)) continue;
		_rg.nodes[_s.n].kind = _s.k;
		_rg.nodes[_s.n].scar = true;
	}
	if (array_length(_sc) > 0) _rg.villain_c = false;   // (a hold taken from the faction, or given to the dead: the villain reads the nodes afresh)
}
