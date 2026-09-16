/// @description foe_kinds_at(land, [season]) -> the kinds that haunt a place of that kind (foe_roster's lands); the road's four when none do
/// THE SEASON (his pick, 2026-09-16; region_season's idx, -1 = none): in
/// WINTER (3) the snow kinds come down into the open lands - nivalis and
/// the snow lupus in the fields, woods, hills and marsh - and the wasps
/// and flies are gone from them; in SUMMER (1) the flies are everywhere
/// open, the wasps take the marsh and the coast, the vipera the hills.
/// Only a FIGHT asks with the season (exped_fight_new): the deals, the
/// bounties and the bestiary's land sets read the base list.
function foe_kinds_at(_land, _season = -1) {
	static _open = ["field", "forest", "hills", "marsh", "coast"];
	var _ros = foe_roster(), _out = [];
	for (var _i = 0; _i < array_length(_ros); _i++) if (array_contains(_ros[_i].lands, _land)) array_push(_out, _ros[_i].name);
	if (array_length(_out) == 0) _out = ["goblin", "bandit", "lupus", "rat"];
	if (_season == 3 && array_contains(_open, _land)) {
		var _w = [];
		for (var _i = 0; _i < array_length(_out); _i++) if (_out[_i] != "vespae" && _out[_i] != "musca") array_push(_w, _out[_i]);
		if (_land != "coast") { array_push(_w, "nivalis"); array_push(_w, "snow lupus"); }
		_out = _w;
	} else if (_season == 1 && array_contains(_open, _land)) {
		if (!array_contains(_out, "musca")) array_push(_out, "musca");
		if ((_land == "marsh" || _land == "coast") && !array_contains(_out, "vespae")) array_push(_out, "vespae");
		if (_land == "hills" && !array_contains(_out, "vipera")) array_push(_out, "vipera");
	}
	return _out;
}
