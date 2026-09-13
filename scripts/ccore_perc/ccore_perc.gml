/// @description ccore_perc(lv) -> the percent a split-level lands
/// DE's cc_perc, verbatim: 100 + 50 x lv / (1 + .05 (lv - 1)) + 10 per
/// level past ten. Steep early (a level is nearly +50%), then the
/// division flattens it to a floor of +10 a level - the curve he liked.
/// @param lv
function ccore_perc(_lv) {
	// ⚖️ REBALANCED (his ask, 2026-09-13). DE's curve front-loaded the first
	// ten levels (+50% falling to +25%) and then went flat at +10% a level
	// for ever - the same numbers it lands near (444 at 10, 894 at 29,
	// 1078 at 40) come from a plainer shape with a tail that GROWS: +40 a
	// level to ten, then +20 a level plus a slow square (500 at 10, 1060 at
	// 29, 1550 at 40, 2750 at 60), so a late level is worth buying
	var _a = min(_lv, 10), _b = max(_lv - 10, 0);
	return floor(100 + 40 * _a + 20 * _b + .5 * _b * _b);
}
