/// @description exped_mem_set(dest, ri, node, kind, hours, [pay]) - a memory written (or rewritten) for hours of the expedition clock (exped_mem_get)
function exped_mem_set(_d, _ri, _ni, _kind, _hours, _pay = "") {
	exped_init();
	if (!is_struct(g.exped[$ "mem"])) g.exped.mem = {};
	g.exped.mem[$ string(_d.seed) + ":" + string(_ri) + ":" + string(_ni) + ":" + _kind] = { left : _hours * EXPED_HOUR, pay : _pay };
	save_mark_dirty();
}
