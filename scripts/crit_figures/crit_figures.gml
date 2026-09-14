/// @description crit_figures() -> { rate, mn, mx } - the tapper's crit
/// chance (percent, before luck and the upgrade table) and the range
/// of its multiplier, DE's update_clicker with the deck on top: base 5%
/// and x1.5..x5; critical rate+ doubles the base, rate++ x3, rate+++ x4;
/// every critical cut halves the rate and doubles the multiplier. ONE
/// reader: update_click stores these for tap_fire's roll, and critical
/// syphon reads them for the dials (update_dial) - the dials are
/// derived BEFORE the tap, so the tap's stored copy would be stale there.
function crit_figures() {
	var _cr = 5, _cm = 1;
	if (abi_on("ad_critrate1")) _cr *= 2;
	if (abi_on("ad_critrate2")) _cr *= 3;
	if (abi_on("ad_critrate3")) _cr *= 4;
	var _cuts = (abi_on("ad_critcut1") ? 1 : 0) + (abi_on("ad_critcut2") ? 1 : 0) + (abi_on("ad_critcut3") ? 1 : 0);
	_cr /= power(2, _cuts);
	_cm *= power(2, _cuts);
	return { rate : _cr, mn : 1.5 * _cm, mx : 5 * _cm };
}
