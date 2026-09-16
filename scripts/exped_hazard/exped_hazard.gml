/// @description exped_hazard(trip) -> { hz, ni } the hazard where the crew stands (hz undefined = none) and the place it belongs to
/// At a place: its own. On a road: the far end's, else the near end's -
/// the terrain kinds only (a road to a crypt is not dark, cbt_hazard_at).
function exped_hazard(_tr) {
	var _rg = exped_region(_tr);
	var _n = array_length(_rg.nodes);
	if (is_struct(_tr[$ "road"])) {
		var _b = clamp(_tr.road.b, 0, _n - 1), _a = clamp(_tr.road.a, 0, _n - 1);
		var _hb = region_hazard_at(_tr.dest, _rg, _rg.nodes[_b].kind, true);   // (the season's word too - 2026-09-16)
		if (is_struct(_hb)) return { hz : _hb, ni : _b };
		return { hz : region_hazard_at(_tr.dest, _rg, _rg.nodes[_a].kind, true), ni : _a };
	}
	var _p = clamp(_tr.pos, 0, _n - 1);
	return { hz : region_hazard_at(_tr.dest, _rg, _rg.nodes[_p].kind), ni : _p };
}
