/// @description exped_mem_tick(dt) - every memory's clock runs down by dt seconds; at zero it is forgotten (exped_tick, x the debug speed, offline too)
function exped_mem_tick(_dt) {
	var _m = g.exped[$ "mem"];
	if (!is_struct(_m)) return;
	var _ks = variable_struct_get_names(_m);
	for (var _i = 0; _i < array_length(_ks); _i++) {
		var _e = _m[$ _ks[_i]];
		_e.left -= _dt;
		if (_e.left <= 0) variable_struct_remove(_m, _ks[_i]);
	}
}
