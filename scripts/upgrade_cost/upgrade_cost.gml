/// @description upgrade_cost(slot);
/// @param slot
/// What the NEXT tier of this slot costs, in credits. Myriad DE's own
/// curve: base x (1 + (0.2 + 0.1*tier) * tier), so the price accelerates
/// rather than merely rising - a slot you have poured into is a real
/// commitment, which is what gives selling it any weight.
/// Rarity multiplies the price by exactly what it multiplied the value
/// by, so rarity buys POWER DENSITY per slot, never efficiency per
/// credit. A scarce slot is the thing rarity is really worth.
/// Returns -1 when the slot is empty or already at its ceiling.
function upgrade_cost(_slot) {
	upgrade_init();
	var _s = g.upg.slot[_slot];
	if (!is_struct(_s)) return -1;
	var _e = upgrade_entry(_s.id);
	if (_e == -1) return -1;
	if (_s.tier >= upgrade_cap(_slot)) return -1;

	var _t = _s.tier;
	var _c = _e.cost * upgrade_rarity_mult(_s.rar) * (1 + (0.2 + 0.1 * _t) * _t);
	// difficulty rides here, DE's seat: hard pays more, easy pays less
	_c *= upgrade_diff_mult();
	return max(1, round(_c));
}
