/// @description exped_mem_pack() -> the memories as one string (the save's "ex_mem"): key=left~pay|key=left~pay (a shelf's pay: price:sold:pack;...)
function exped_mem_pack() {
	exped_init();
	var _m = g.exped[$ "mem"];
	if (!is_struct(_m)) return "";
	var _out = "", _ks = variable_struct_get_names(_m);
	for (var _i = 0; _i < array_length(_ks); _i++) {
		var _e = _m[$ _ks[_i]];
		if (_e.left <= 0) continue;
		var _pay = string_replace_all(string_replace_all(string(_e[$ "pay"] ?? ""), "|", " "), "~", " ");
		_out += ((_out != "") ? "|" : "") + _ks[_i] + "=" + string(max(1, round(_e.left))) + "~" + _pay;
	}
	return _out;
}
