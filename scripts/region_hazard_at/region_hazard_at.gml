/// @description region_hazard_at(dest, region, kind, [road]) -> the hazard at a place of that kind NOW (cbt_hazard_at, then the season's word)
/// THE SEASON'S HAZARDS (his pick, 2026-09-16): in winter the marsh is
/// frozen - the damp is the cold; in the dead of winter (the lean past
/// -.8) the cold reaches the open fields, woods and hills; in high summer
/// (past .8) the heat reaches the fields and the hills. Everything that
/// reads a hazard reads this (the trip, the preparation page, the cards,
/// the odds, the map's card, the notes) so nothing surprises the crew.
function region_hazard_at(_d, _rg, _kind, _road = false) {
	var _hz = cbt_hazard_at(_kind, _road);
	var _all = cbt_hazards(), _cold = undefined, _heat = undefined;
	for (var _i = 0; _i < array_length(_all); _i++) { if (_all[_i].key == "cold") _cold = _all[_i]; if (_all[_i].key == "heat") _heat = _all[_i]; }
	// A HARD FROST (region_event, 2026-09-16): the cold on the open lands, whatever the season
	var _ev = region_event(_d, _rg[$ "ri"] ?? 0);
	if (is_struct(_ev) && _ev.kind == "frost" && (_kind == "field" || _kind == "forest" || _kind == "hills" || _kind == "marsh") && is_struct(_cold)) return _cold;
	var _ss = region_season(_d, _rg);
	if (!_ss.on) return _hz;
	if (_ss.lean < -.5 && _kind == "marsh" && is_struct(_cold)) return _cold;
	if (_ss.lean < -.8 && (_kind == "field" || _kind == "forest" || _kind == "hills") && is_struct(_cold)) return _cold;
	if (_ss.lean > .8 && (_kind == "field" || _kind == "hills") && is_struct(_heat)) return _heat;
	return _hz;
}
