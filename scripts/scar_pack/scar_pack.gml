/// @description scar_pack() -> the scars as one string (the save's "ex_scars"): key=n:k:was;n:k:was|... in the galaxy's order (q260)
function scar_pack() {
	exped_init();
	var _sc = g.exped[$ "scars"];
	if (!is_struct(_sc)) return "";
	var _ord = is_array(g.exped[$ "scar_order"]) ? g.exped.scar_order : variable_struct_get_names(_sc);
	var _out = "";
	for (var _i = 0; _i < array_length(_ord); _i++) {
		var _l = _sc[$ _ord[_i]];
		if (!is_array(_l) || array_length(_l) == 0) continue;
		var _s = "";
		for (var _j = 0; _j < array_length(_l); _j++) _s += ((_j > 0) ? ";" : "") + string(_l[_j].n) + ":" + _l[_j].k + ":" + (_l[_j][$ "was"] ?? "");
		_out += ((_out != "") ? "|" : "") + _ord[_i] + "=" + _s;
	}
	return _out;
}
