/// @description upgrade_cap(slot);
/// @param slot
/// The tier ceiling for what is in this slot. The roster's `cap` is the
/// common-rarity ceiling; rarity widens it, so a legendary roll is
/// deeper as well as stronger and a scarce slot spent on one is worth
/// more over the whole run rather than only at the moment of buying.
function upgrade_cap(_slot) {
	upgrade_init();
	var _s = g.upg.slot[_slot];
	if (!is_struct(_s)) return 0;
	var _e = upgrade_entry(_s.id);
	if (_e == -1) return 0;
	return max(1, round(_e.cap * (1 + _s.rar * 0.25)));
}
