/// @description faction_pack() -> "seed:ri:kind=hp|..." the hit factions for the save (q283; a whole one has no record)
function faction_pack() {
	exped_init();
	var _fs = g.exped[$ "fac"];
	if (!is_struct(_fs)) return "";
	var _out = "", _ks = variable_struct_get_names(_fs);
	for (var _i = 0; _i < array_length(_ks); _i++) _out += ((_out != "") ? "|" : "") + _ks[_i] + "=" + string_format(_fs[$ _ks[_i]].hp, 1, 2);
	return _out;
}
