/// @description log_to_arb(lg) - EXACT packed arb from a log10 value:
/// exp = floor(lg), coe = 10^frac(lg). exists because dig_to_arb's
/// lerp curve is a cheap APPROXIMATION of 10^frac that undershoots
/// mid-range coefficients - packing 15.6 through it came out 14, so a
/// x1.04 profit core read as a LOSS (his first core-math bug report).
/// use THIS wherever the number must be right; dig_to_arb stays for
/// the legacy call sites tuned around its curve.
/// negative logs (sub-1 values) return 0: the arb library doesn't do
/// those - see do_scale for why.
function log_to_arb(_lg) {
	if (_lg < 0) return 0;
	var _e = floor(_lg);
	return _e + power(10, _lg - _e) / 10;
}
