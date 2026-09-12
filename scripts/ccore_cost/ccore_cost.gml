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
	return CCORE_COST0 + (1 + floor(.05 * _lv)) * _lv;
}
