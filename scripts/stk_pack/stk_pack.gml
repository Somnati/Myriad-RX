/// @description stk_pack() -> the stack as one string for the save: the ledger, then every sink as alloc:prog:level:ups, layers by semicolon, sinks by comma
function stk_pack() {
	var _s = stk_init(), _ly = "";
	for (var _l = 0; _l < array_length(_s.layers); _l++) {
		var _row = "";
		for (var _i = 0; _i < array_length(_s.layers[_l].sinks); _i++) { var _k = _s.layers[_l].sinks[_i]; _row += ((_i > 0) ? "," : "") + string(_k.alloc) + ":" + string(_k.prog) + ":" + string(_k.level) + ":" + string(_k.ups); }
		_ly += ((_l > 0) ? ";" : "") + string(_s.layers[_l].focus) + "/" + _row;
	}
	return "1|" + string(_s.spark) + "|" + string(_s.life) + "|" + string(_s.cap_lv) + "|" + string(_s.cinders) + "|" + string(_s.turns) + "|" + string(_s.last) + "|" + string(_s.tab) + "|" + _ly;
}
