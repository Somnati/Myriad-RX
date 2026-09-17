/// @description ability_rarity_mult(rarity) - what a rung multiplies an
/// ability's number by. Gentler than the upgrades' ladder: a passive that
/// is always on wants a ceiling. x1 .. x3.6.
function ability_rarity_mult(_r) {
	var _t = [1, 1.3, 1.6, 2, 2.4, 2.8, 3.2, 3.6];
	return _t[clamp(floor(_r), 0, array_length(_t) - 1)];
}
