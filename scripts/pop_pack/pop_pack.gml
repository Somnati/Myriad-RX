/// @description pop_pack() -> "seed:ri:ni=d|..." the pushed places for the save (q284)
function pop_pack() {
	exped_init();
	var _ps = g.exped[$ "pop"];
	if (!is_struct(_ps)) return "";
	var _out = "", _ks = variable_struct_get_names(_ps);
	for (var _i = 0; _i < array_length(_ks); _i++) _out += ((_out != "") ? "|" : "") + _ks[_i] + "=" + string_format(_ps[$ _ks[_i]].d, 1, 3);
	return _out;
}
