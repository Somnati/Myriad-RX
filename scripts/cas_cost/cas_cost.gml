/// @description cas_cost(c, i, [stepk]) -> tier i's next unit, LOG10: AD's dimension ladder (10^1 .. 10^24) with AD's per-buy steps x0.85 (the framework's balance round 2 - a coupled set with the x1.15 field) x stepk (the collider's residue: crunches shave it)
function cas_cost(_c, _i, _stepk = 1) {
	static _base = [1, 2, 4, 6, 9, 13, 18, 24];
	static _step = [.255, .34, .425, .51, .68, .85, 1.02, 1.275];
	return _base[_i] + _c.bought[_i] * _step[_i] * _stepk;
}
