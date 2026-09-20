/// @description pop_unpack(s) - the pushed places back from the save (q284)
function pop_unpack(_s) {
	exped_init();
	g.exped.pop = {};
	if (!is_string(_s) || _s == "") return;
	var _recs = string_split(_s, "|");
	for (var _i = 0; _i < array_length(_recs); _i++) {
		var _eq = string_pos("=", _recs[_i]);
		if (_eq < 2) continue;
		g.exped.pop[$ string_copy(_recs[_i], 1, _eq - 1)] = { d : clamp(real(string_delete(_recs[_i], 1, _eq)), -POP_DEV_MAX, POP_DEV_MAX) };
	}
}
