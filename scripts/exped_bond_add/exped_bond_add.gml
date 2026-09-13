/// @description exped_bond_add(a, b, n) - move a pair's bond by n,
/// clamped 0..100 (exped_tick's home: a trip together, fights won
/// together; a rout costs). Marks the save.
function exped_bond_add(_a, _b, _n) {
	if (!variable_global_exists("bonds")) g.bonds = {};
	if (_a == _b) return;
	var _k = string(min(_a, _b)) + ":" + string(max(_a, _b));
	g.bonds[$ _k] = clamp((g.bonds[$ _k] ?? 0) + _n, 0, 100);
	save_mark_dirty();
}
