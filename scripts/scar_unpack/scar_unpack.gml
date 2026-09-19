/// @description scar_unpack(s) - the scars rebuilt from scar_pack's string (q260)
function scar_unpack(_s) {
	exped_init();
	g.exped.scars = {}; g.exped.scar_order = [];
	if (!is_string(_s) || _s == "") return;
	var _recs = string_split(_s, "|");
	for (var _i = 0; _i < array_length(_recs); _i++) {
		var _eq = string_pos("=", _recs[_i]);
		if (_eq < 2) continue;
		var _k = string_copy(_recs[_i], 1, _eq - 1), _items = string_split(string_delete(_recs[_i], 1, _eq), ";"), _l = [];
		for (var _j = 0; _j < array_length(_items); _j++) {
			var _f = string_split(_items[_j], ":");
			if (array_length(_f) < 2) continue;
			array_push(_l, { n : real(_f[0]), k : _f[1], was : (array_length(_f) > 2) ? _f[2] : "" });
		}
		if (array_length(_l) == 0) continue;
		g.exped.scars[$ _k] = _l;
		array_push(g.exped.scar_order, _k);
	}
}
