/// @description exped_mem_unpack(s) - the memories rebuilt from exped_mem_pack's string (a record that will not parse is dropped)
function exped_mem_unpack(_s) {
	exped_init();
	g.exped.mem = {};
	if (!is_string(_s) || _s == "") return;
	var _recs = string_split(_s, "|");
	for (var _i = 0; _i < array_length(_recs); _i++) {
		var _eq = string_pos("=", _recs[_i]);
		if (_eq < 2) continue;
		var _k = string_copy(_recs[_i], 1, _eq - 1), _v = string_delete(_recs[_i], 1, _eq);
		var _tl = string_pos("~", _v);
		var _left = real((_tl > 0) ? string_copy(_v, 1, _tl - 1) : _v);
		if (_left <= 0) continue;
		g.exped.mem[$ _k] = { left : _left, pay : (_tl > 0) ? string_delete(_v, 1, _tl) : "" };
	}
}
