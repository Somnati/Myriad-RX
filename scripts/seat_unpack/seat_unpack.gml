/// @description seat_unpack(s) - the seats rebuilt from seat_pack's string (q260)
function seat_unpack(_s) {
	exped_init();
	g.exped.seat = {};
	if (!is_string(_s) || _s == "") return;
	var _recs = string_split(_s, "|");
	for (var _i = 0; _i < array_length(_recs); _i++) {
		var _eq = string_pos("=", _recs[_i]);
		if (_eq < 2) continue;
		var _k = string_copy(_recs[_i], 1, _eq - 1), _f = string_split(string_delete(_recs[_i], 1, _eq), ":");
		if (array_length(_f) < 2) continue;
		var _kk = string_split(_k, ":");
		g.exped.seat[$ _k] = { left : max(0, real(_f[0])), n : max(0, real(_f[1])), foe : (array_length(_f) > 2) ? _f[2] : "", kind : (array_length(_kk) >= 3) ? _kk[2] : "" };
	}
}
