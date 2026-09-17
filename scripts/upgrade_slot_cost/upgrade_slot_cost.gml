/// @description upgrade_slot_cost() - what the NEXT upgrade slot costs,
/// in credits. -1 when every slot is bought.
///
/// THE NEW-SLOT ROW (his call, 2026-09-17): the next locked slot shows a
/// "new slot" upgrade sitting in it and buying that frees the slot -
/// "weird hack to making new slots unlockable". DE priced its slots
/// 25 / 35 / 35 / 50 for four; five here, climbing. Through the
/// difficulty and the price drift like any upgrade.
function upgrade_slot_cost() {
	upgrade_init();
	if (upgrade_slots() >= UPG_SLOT_MAX) return -1;
	var _lad = [25, 35, 50, 70, 100];
	var _n = clamp(g.upg.bought, 0, array_length(_lad) - 1);
	return max(1, round(_lad[_n] * upgrade_diff_mult() * upgrade_inflation()));
}
