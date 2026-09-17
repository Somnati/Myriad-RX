/// @description upgrade_level_mult(lv) - what an offer rolled at upgrade
/// level `lv` multiplies its tiers by. DE's update_upgrade `_add2`:
///     g = .2 + .04 max(lv - 2, 0);   mult = 1 + g (lv - 1)
/// x1 at level 1, x1.2 at 2, x1.48 at 3, x2.28 at 5, x5.7 at 10,
/// x18.5 at 20 - the level is what makes a late offer worth more than
/// an early one of the same rung (his worry, 2026-09-17: "they will
/// have the same value no matter how much i earn"). An offer keeps the
/// level it was rolled at (DE's u_lv), so levelling up is a reason to
/// want the NEXT offer, not a retroactive raise.
function upgrade_level_mult(_lv) {
	_lv = max(1, _lv);
	var _g = .2 + .04 * max(_lv - 2, 0);
	return 1 + _g * (_lv - 1);
}
