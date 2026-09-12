/// @description luck_points() -> the flat luck stat, DE's g.luck
/// LUCK IS ONE NUMBER THAT LEANS EVERY ROLL YOUR WAY (Myriad DE's, his
/// ask 2026-09-12: "I liked it"). It is FLAT POINTS, summed from
/// everything that grants luck, and luck_mod turns the points into the
/// multiplier every chance in the game takes. Sources today:
///   - the upgrade table's "luck" kind (upgrade_bonus's luck stat -
///     value x tier, like every other stat)
///   - the daily gift: every gift ever collected is a point (DE's
///     dg_collect, without the ability gate)
/// Gear and abilities plug in here when they exist. Derived every read,
/// never stored.
function luck_points() {
	var _l = 0;
	if (variable_global_exists("upg")) _l += upgrade_bonus_live().luck;   // the gated reader: preview upgrades do not lean the game
	if (variable_global_exists("gift")) _l += g.gift.claims;
	return max(0, _l);
}
