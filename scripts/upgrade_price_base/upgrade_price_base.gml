/// @description upgrade_price_base(slot, tier);
/// @param slot
/// @param tier
/// THE UN-INFLATED PRICE OF ONE TIER, and the single owner of the
/// curve's shape:
///
///     entry.cost  x  rarity multiplier  x  (1 + (0.2 + 0.1t) * t)
///
/// times difficulty. DE's curve, with DE's acceleration.
///
/// Two callers, and the split between them is the whole point.
/// upgrade_cost multiplies this by upgrade_inflation to quote a price;
/// upgrade_sell_value sums it RAW to work out what a slot has absorbed.
/// Because the refund side never sees the inflation the quote side does,
/// a refund is provably a fraction of what was actually paid - no matter
/// how long the slot sat there or how much the economy drifted while it
/// did. That guarantee is the reason this function exists instead of the
/// formula being written twice.
function upgrade_price_base(_slot, _tier) {
	var _s = g.upg.slot[_slot];
	if (!is_struct(_s)) return 0;
	var _e = upgrade_entry(_s.id);
	if (_e == -1) return 0;
	var _t = max(0, _tier);
	// DE's rarity price curve (set_ucost: `_cost *= 1 + (.2 + .1(r-1)) r`)
	// - x1 / 1.2 / 1.6 / 2.2 / 3 / 4 / 5.2 / 6.6 - against a VALUE ladder
	// that reaches x25 (upgrade_rarity_mult). Ported 2026-09-17; before
	// it the price took the value multiplier and a rung bought nothing
	var _r = clamp(floor(_s.rar), 0, UPG_RARITY_N - 1);
	return _e.cost * (1 + (0.2 + 0.1 * (_r - 1)) * _r) * (1 + (0.2 + 0.1 * _t) * _t)
		* upgrade_diff_mult();
}
