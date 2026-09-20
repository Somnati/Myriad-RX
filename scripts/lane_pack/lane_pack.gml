/// @description lane_pack() -> the disturbed regions as one string (the save's "ex_lanes"): key=o:w:t:f:e:d:weight|... two decimals, quiet ones left out (q259)
function lane_pack() {
	exped_init();
	var _ls = g.exped[$ "lanes"];
	if (!is_struct(_ls)) return "";
	var _out = "", _ks = variable_struct_get_names(_ls), _nm = lane_names();
	for (var _i = 0; _i < array_length(_ks); _i++) {
		var _r = _ls[$ _ks[_i]], _any = false, _s = "";
		for (var _j = 0; _j < array_length(_nm); _j++) { var _v = _r[$ _nm[_j]] ?? 0; if (abs(_v) >= LANE_QUIET) _any = true; _s += ((_j > 0) ? ":" : "") + string_format(_v, 1, 2); }
		var _oh = _r[$ "oh"] ?? 0, _th = _r[$ "th"] ?? 0, _fl = _r[$ "fl"] ?? 0;
		if (!_any && _oh <= 0 && _th <= 0 && _fl <= 0) continue;
		_out += ((_out != "") ? "|" : "") + _ks[_i] + "=" + _s + ":" + string_format(_r[$ "w"] ?? 1, 1, 2) + ":" + string(round(_oh)) + ":" + string(round(_th)) + ":" + string(round(_fl));   // (the scars' hold counters ride along - q282; a save mid-hold lost them)
	}
	return _out;
}
