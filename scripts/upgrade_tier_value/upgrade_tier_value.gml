/// @description upgrade_tier_value(val, tier, cap, rarity, lv) - what a
/// slot bought to `tier` contributes in total: the sum of its tiers,
/// each through DE's tier law (upgrade_tier_add) and the upgrade level
/// it was rolled at (upgrade_level_mult), plus DE's flat .004 (lv - 1)
/// a tier. A tier-0 offer is 0. NOT in here: the +1%-of-the-type's-
/// total each purchase adds (DE's `u_val += u_profit / 100`) - that is
/// history, so the slot stores it as it is earned (slot.xtra, see
/// upgrade_buy) and upgrade_bonus adds it beside this.
/// @param val     the rolled base value (percent a tier before the law)
/// @param tier    tiers bought
/// @param cap     how deep the offer goes
/// @param rarity  the slot's rung - the law ramps per rarity
/// @param lv      the upgrade level the offer was rolled at
///
/// DE accumulates this on the way in (`g.u_tapprofit += u_val` per
/// purchase); RX derives it from what is held, so the sum is recomputed
/// here - the same numbers, reached from the other side.
function upgrade_tier_value(_val, _tier, _cap, _rar = 0, _lv = 1) {
	if (_tier <= 0) return 0;
	var _lm = upgrade_level_mult(_lv);
	var _sum = 0;
	for (var _n = 0; _n < _tier; _n++)
		_sum += _val * upgrade_tier_add(_rar, _n, _cap) * _lm + .004 * (max(1, _lv) - 1);
	return _sum;
}
