/// @description ccore_cost() -> credits the next level costs
/// DE's ladder for the credit core - 5 + (1 + floor(lv / 20)) x lv -
/// but in CREDITS, not DE's gold: RX's rebirth units ARE the rebirth
/// boost (rebirth_boost), and spending them would sell the boost. A
/// well of credits that costs credits to deepen is the honest loop
/// (and the ladder is gentle: the well pays for itself in an hour or
/// so at every level - tune CCORE_COST0 if it should not).
function ccore_cost() {
	ccore_init();
	var _lv = g.ccore.lv;
	// ⚖️ REBALANCED (his ask, 2026-09-13): DE's 5 + (1 + lv/20) x lv reached
	// 76 credits at level 29 against a dropper that pays ~12 an hour, for a
	// level worth +10% of the base - a sixty-hour payback. Linear with a
	// gentle square: 34 at 29, 65 at 60, 130 at 100; with ccore_perc's
	// steeper tail a level pays itself back in three to twelve hours
	// across the ladder (the twin-in-a-comment: cost / (dperc x .12/h))
	return CCORE_COST0 + _lv + floor(_lv * _lv / 80);
}
