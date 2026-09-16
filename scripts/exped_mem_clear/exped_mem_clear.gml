/// @description exped_mem_clear(dest, ri, node, kind) - a memory forgotten (a rout quest's bandits are back at their camp)
function exped_mem_clear(_d, _ri, _ni, _kind) {
	exped_init();
	var _m = g.exped[$ "mem"];
	if (!is_struct(_m)) return;
	var _k = string(_d.seed) + ":" + string(_ri) + ":" + string(_ni) + ":" + _kind;
	if (variable_struct_exists(_m, _k)) { variable_struct_remove(_m, _k); save_mark_dirty(); }
}
