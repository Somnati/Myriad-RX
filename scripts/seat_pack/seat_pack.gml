/// @description seat_pack() -> the seats as one string (the save's "ex_seat"): key=left:n|... (q260)
function seat_pack() {
	exped_init();
	var _ss = g.exped[$ "seat"];
	if (!is_struct(_ss)) return "";
	var _out = "", _ks = variable_struct_get_names(_ss);
	for (var _i = 0; _i < array_length(_ks); _i++) { var _s = _ss[$ _ks[_i]]; _out += ((_out != "") ? "|" : "") + _ks[_i] + "=" + string(max(0, round(_s.left))) + ":" + string(_s.n) + ":" + string(_s[$ "foe"] ?? ""); }   // (the faction's kind rides along - q262)
	return _out;
}
