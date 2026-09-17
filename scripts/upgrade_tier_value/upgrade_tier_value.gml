/// @description upgrade_tier_value(val, tier, cap, rarity) - what a slot
/// bought to `tier` contributes in total: the sum of its tiers, each
/// through DE's tier law (upgrade_tier_add). A tier-0 offer is 0.
/// @param val     the rolled base value (percent a tier before the law)
/// @param tier    tiers bought
/// @param cap     how deep the offer goes
/// @param rarity  the slot's rung - the law ramps per rarity
///
/// DE accumulates this on the way in (`g.u_tapprofit += u_val` per
/// purchase); RX derives it from what is held, so the sum is recomputed
/// here - the same numbers, reached from the other side.
function upgrade_tier_value(_val, _tier, _cap, _rar = 0) {
	if (_tier <= 0) return 0;
	var _sum = 0;
	for (var _n = 0; _n < _tier; _n++) _sum += upgrade_tier_add(_rar, _n, _cap);
	return _val * _sum;
}
