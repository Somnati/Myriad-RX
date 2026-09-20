/// @description faction_unpack(s) - the hit factions back from the save (q283)
function faction_unpack(_s) {
	exped_init();
	g.exped.fac = {};
	if (!is_string(_s) || _s == "") return;
	var _recs = string_split(_s, "|");
	for (var _i = 0; _i < array_length(_recs); _i++) {
		var _eq = string_pos("=", _recs[_i]);
		if (_eq < 2) continue;
		g.exped.fac[$ string_copy(_recs[_i], 1, _eq - 1)] = { hp : max(0, real(string_delete(_recs[_i], 1, _eq))) };
	}
}
