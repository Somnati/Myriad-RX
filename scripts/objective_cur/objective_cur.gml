/// @description objective_cur() -> the objective being worked (a row of
/// objective_config), or undefined once the chain is complete
function objective_cur() {
	objective_init();
	var _c = objective_config();
	if (g.obj.i < 0 || g.obj.i >= array_length(_c)) return undefined;
	return _c[g.obj.i];
}
