/// @description upgrade_cap(slot);
/// @param slot
/// The tier ceiling for what is in this slot - the number of dots the
/// row draws.
///
/// IT IS ROLLED WITH THE OFFER NOW (DE's model), not derived from the
/// rarity by formula. Two legendary offers of the same upgrade can take
/// four tiers and five, and that difference is the reason a roll is
/// interesting after you already know its rarity: the ladder says how
/// STRONG each tier is, the dots say how MANY there are, and a deep
/// common can outlast a shallow elite. See upgrade_roll_tiers.
///
/// The roster's own `cap` still has the final word (min at roll time),
/// so a grant stays one tier however the dice fall.
///
/// Offers rolled before the cap existed have no field: they fall back
/// to the old rarity-widened formula, which is what they were built
/// against, so an old save reads exactly as it always did.
function upgrade_cap(_slot) {
	upgrade_init();
	var _s = g.upg.slot[_slot];
	if (!is_struct(_s)) return 0;
	var _e = upgrade_entry(_s.id);
	if (_e == -1) return 0;
	var _c = _s[$ "cap"];
	if (is_undefined(_c)) return max(1, round(_e.cap * (1 + _s.rar * 0.25)));
	return clamp(floor(_c), 1, _e.cap + (abi_on("ad_upgradetier") ? 2 : 0));   // (upgrade tier+: two more)
}
