/// @description do_scale(arbval, factor) - multiply a packed arb by a
/// PLAIN REAL factor of any size, fractions included. exists because
/// the arb library does not survive sub-1 values: arb(0.15) packs a
/// malformed coefficient, and do_subtract/do_div's normalize loops
/// spin FOREVER on the negative coefficients that fall out (the
/// "About to startroom" boot freeze, found the hard way). this stays
/// in log space the whole way, so any factor is safe:
///   log10(a * f) = exp(a) + log10(coe(a)) + log10(f)
/// results under 1 clamp to arb(1) - resin/costs are whole-unit
/// currencies here, and sub-1 packed values are exactly the poison
/// this script exists to avoid.
function do_scale(_a, _f) {
	if (_f <= 0 || _a <= 0) return 0;
	if (_f == 1) return _a;
	var _lg = arb_log10(_a) + log10(_f);
	if (_lg < 0) return arb(1);
	return log_to_arb(_lg); // EXACT pack (dig_to_arb's curve turned a
		// x1.04 profit core into a visible loss)
}
