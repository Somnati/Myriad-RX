/// @description dial_gps(tier, level) - THE BASE OUTPUT CURVE, and the
/// single most important formula in the game (Myriad DE's get_gps).
/// Two lanes, added:
///   EXPONENTIAL - every level adds .0255 to the value's LOG10, i.e.
///     multiplies output by 10^.0255 = x1.0605. Compounding, so it
///     owns the late game but is nearly flat at low levels.
///   ADDITIVE EARLY - while output is under 1e10 each level ALSO pays
///     one flat unit. This is what makes the first hundred levels feel
///     like progress at all; it switches itself off exactly when the
///     exponential lane overtakes it.
/// The seed is DE's arb(1), which packs to 0.1 - so a level-1 dial
/// starts near 1/cycle rather than 10. Kept deliberately: it is the
/// shipped feel, and the whole curve is anchored to it.
/// IMPROVED vs DE: the final pack goes through log_to_arb (exact)
/// rather than dig_to_arb (a lerp approximation of 10^frac that
/// undershoots mid-range coefficients). Same law, honest numbers.
function dial_gps(_tier, _level) {
	if (_level <= 0) return 0;

	// the tier's head start rides along as though it were real levels
	var _lv = _level + dial_lvdiv(_tier);

	var _gth = (1.7 / 100) * 1.5;            // = .0255 log10 per level
	_gth *= lerp(1, 1000, _tier / 1000000);  // DE's far-tier ramp (~1 here)

	var _val = log_to_arb(arb(1) + _gth * (_lv - 1));

	// the additive early lane (packed exponent < 10 == under 1e10)
	if (_val < 10 && _lv > 1) _val = do_add(_val, arb(_lv - 1));

	return _val;
}
