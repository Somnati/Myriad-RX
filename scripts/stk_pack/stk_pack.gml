/// @description stk_pack() -> the stack as one string for the save (v2): the ledger, the perks (k=r,...), then every layer as focus:vein:vein2:burn_t:burn_add / sinks as alloc:prog:level:ups by comma, layers by semicolon
function stk_pack() {
	var _s = stk_init(), _ly = "", _pk = "";
	var _keys = variable_struct_get_names(_s.perks);
	for (var _p = 0; _p < array_length(_keys); _p++) _pk += ((_p > 0) ? "," : "") + _keys[_p] + "=" + string(_s.perks[$ _keys[_p]]);
	if (_pk == "") _pk = "-";
	for (var _l = 0; _l < array_length(_s.layers); _l++) {
		var _row = "", _y = _s.layers[_l];
		for (var _i = 0; _i < array_length(_y.sinks); _i++) { var _k = _y.sinks[_i]; _row += ((_i > 0) ? "," : "") + string(_k.alloc) + ":" + string(_k.prog) + ":" + string(_k.level) + ":" + string(_k.ups); }
		_ly += ((_l > 0) ? ";" : "") + string(_y.focus) + ":" + string(_y.vein) + ":" + string(_y.vein2) + ":" + string(_y.burn_t) + ":" + string(_y.burn_add) + "/" + _row;
	}
	return "2|" + string(_s.spark) + "|" + string(_s.life) + "|" + string(_s.cap_lv) + "|" + string(_s.cinders) + "|" + string(_s.turns) + "|" + string(_s.last) + "|" + string(_s.tab) + "|" + string(_s.spent) + "|" + _pk + "|" + _ly;
}
