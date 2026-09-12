/// @description luck_rate(rate) -> a rarity RATE with luck applied
/// DE's shape for every rarity roll (roll_upgrade, generate_item, the
/// chests): the rate is multiplied by luck_mod AND the excess of
/// luck_mod over one is added as points - so luck lifts a low rate off
/// the floor rather than only scaling it. rate x m + (m - 1) x 100.
/// @param rate   the rarity rate as the roll would otherwise take it
function luck_rate(_rate) {
	var _m = luck_mod();
	return _rate * _m + (_m - 1) * 100;
}
