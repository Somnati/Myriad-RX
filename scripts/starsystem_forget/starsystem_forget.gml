/// @description starsystem_forget(seed) - the kept system of a star let go (starsystem_get's keep): its props changed, the next starsystem_get generates it afresh. q212
function starsystem_forget(_seed) {
	if (!variable_global_exists("starsys_c")) return;
	var _k = string(_seed);
	if (variable_struct_exists(g.starsys_c, _k)) variable_struct_remove(g.starsys_c, _k);
}
