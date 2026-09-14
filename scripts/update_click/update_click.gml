/// @description update_click() - re-derive what one tap pays (Myriad
/// DE's update_clicker). Call it whenever anything about the dials
/// changes; update_dials already ends with it.
/// THE TWO LANES, both from the dial fleet - this is the whole reason
/// tapping stays relevant a thousand levels in:
///   1. BASE = 1 + the SUM of every dial's level. Buying levels
///      anywhere makes your thumb stronger.
///   2. THE SYPHON = tapsyphon (1%) of the fleet's per-second output,
///      but only once the fleet is actually producing (DE's guard:
///      all_gps past a packed exponent of 2, i.e. 100/sec). Late game
///      this term is the whole tap. THE OUTPUT AS PAID: g.all_gps
///      carries the tile table's dial boost (fleet_total) - DE's
///      pre_os_gps did too, being set after update_auto's mod_gps
///      multiply - so a x4000 table is a x4000 tap (his report,
///      2026-09-10: the tap was syphoning the raw curve).
/// DE's further multipliers (overcharge, crit boost, gear, abilities)
/// re-enter here result-side as those layers get rebuilt.
/// ARB NOTE: DE wrote do_multi(all_gps, arb(.01)) - and arb() cannot
/// represent sub-1 values (arb(.01) packs malformed). RX runs the same
/// percentage through do_scale, which does it in log space. Same law,
/// no malformed pack.
function update_click() {
	if (!variable_global_exists("all_level")) { g.all_level = 0; g.all_gps = 0; g.all_gps_raw = 0; }

	g.click_gps      = arb(1 + g.all_level);
	// DE's tap absorbs the rebirth units directly (click_gps += units)
	// rather than taking the dial boost - its boost line is commented
	// out in update_clicker, and this one is live
	rebirth_init();
	if (g.rebirth.units >= arb(1)) g.click_gps = do_add(g.click_gps, g.rebirth.units);
	// THE DECK (Myriad DE's tapper abilities, 2026-09-13): the syphon is 1%
	// of the fleet's rate, + tapper syphon's 1% / 10% / 50%
	g.tapsyphon = .01;
	if (abi_on("ad_tappersyphon1")) g.tapsyphon += .01;
	if (abi_on("ad_tappersyphon2")) g.tapsyphon += .1;
	if (abi_on("ad_tappersyphon3")) g.tapsyphon += .5;
	g.tapsyphon_pull = 0;

	if (g.tapsyphon > 0 && g.all_gps > 2)
		g.tapsyphon_pull = do_scale(g.all_gps, g.tapsyphon);

	if (g.tapsyphon_pull >= arb(1))
		g.click_gps = do_add(g.click_gps, g.tapsyphon_pull);

	// ---- UPGRADES, RESULT-SIDE ----
	// The adapter contract: multiply what was just derived, never the
	// inputs it was derived from. Folded into all_level or tapsyphon
	// instead, this would compound with itself on the next resync.
	var _ub = upgrade_bonus_live();
	if (_ub.tap_profit > 0)
		g.click_gps = do_scale(g.click_gps, 1 + _ub.tap_profit / 100);

	// THE OVERCHARGER, result-side (DE: click_gps = do_multi(click_gps,
	// overcharge_multi) at the end of update_clicker). obj_overcharge
	// calls this the moment its level changes, so the per-tap readout
	// shows the charged figure the way DE's did.
	// profitable tapper: +1% for every 2,500 taps ever made (DE's)
	var _taps = variable_global_exists("total_taps") ? g.total_taps : 0;
	if (abi_on("ad_profitabletapper") && _taps >= 2500)
		g.click_gps = do_scale(g.click_gps, 1 + .01 * floor(_taps / 2500));

	// ---- THE CRIT FIGURES, DE's update_clicker: base 5% and x1.5..x5,
	// then the deck - rate+ doubles the base, rate++ / +++ x3 / x4, every
	// critical cut halves the rate and doubles the multiplier, the
	// critical tapper adds 1% of multiplier per 7,500 taps. Stored here
	// (create_clicker's bases are the constants) - the roll in tap_fire
	// reads these and adds the upgrade table's own on top ----
	var _cr = 5, _cm = 1;
	if (abi_on("ad_critrate1")) _cr *= 2;
	if (abi_on("ad_critrate2")) _cr *= 3;
	if (abi_on("ad_critrate3")) _cr *= 4;
	var _cuts = (abi_on("ad_critcut1") ? 1 : 0) + (abi_on("ad_critcut2") ? 1 : 0) + (abi_on("ad_critcut3") ? 1 : 0);
	_cr /= power(2, _cuts);
	_cm *= power(2, _cuts);
	if (abi_on("ad_criticaltapper")) _cm *= 1 + .01 * floor(_taps / 7500);
	g.click_crit      = _cr;
	g.click_critx_min = 1.5 * _cm;
	g.click_critx_max = 5 * _cm;

	var _oc = overcharge_multi();
	if (_oc > 1) g.click_gps = do_scale(g.click_gps, _oc);
}
