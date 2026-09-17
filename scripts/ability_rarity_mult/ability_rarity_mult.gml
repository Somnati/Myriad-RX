/// @description ability_rarity_mult(rarity) - what a rung multiplies an
/// ability's number by, fourteen deep. Gentler than the upgrades' ladder:
/// a passive that is always on wants a ceiling. x.8 (basic) .. x3.6.
function ability_rarity_mult(_r) {
	var _t = [.8, 1, 1.2, 1.4, 1.6, 1.8, 2, 2.2, 2.4, 2.6, 2.8, 3, 3.3, 3.6];
	return _t[clamp(floor(_r), 0, array_length(_t) - 1)];
}
