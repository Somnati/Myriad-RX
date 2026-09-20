/// @description lane_unpack(s) - the disturbed regions rebuilt from lane_pack's string (a record that will not parse is dropped) (q259)
function lane_unpack(_s) {
	exped_init();
	g.exped.lanes = {};
	if (!is_string(_s) || _s == "") return;
	var _recs = string_split(_s, "|"), _nm = lane_names();
	for (var _i = 0; _i < array_length(_recs); _i++) {
		var _eq = string_pos("=", _recs[_i]);
		if (_eq < 2) continue;
		var _k = string_copy(_recs[_i], 1, _eq - 1), _vs = string_split(string_delete(_recs[_i], 1, _eq), ":");
		if (array_length(_vs) < 7) continue;
		var _r = { w : max(.1, real(_vs[6])), oh : (array_length(_vs) > 9) ? max(0, real(_vs[7])) : 0, th : (array_length(_vs) > 9) ? max(0, real(_vs[8])) : 0, fl : (array_length(_vs) > 9) ? max(0, real(_vs[9])) : 0 };   // (the hold counters, when the save has them - q282)
		for (var _j = 0; _j < array_length(_nm); _j++) _r[$ _nm[_j]] = clamp(real(_vs[_j]), -1, 1);
		g.exped.lanes[$ _k] = _r;
	}
}
