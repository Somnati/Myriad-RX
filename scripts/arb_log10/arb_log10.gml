/// @description arb_log10(a) - log10 of a packed arb, exact. THE one
/// place that knows the pack layout (floor = exponent, frac x 10 =
/// coefficient); log_to_arb is its inverse. callers: do_scale,
/// dial_cost_range's base-cost unpack, the header profit glide.
/// requires a >= arb(1) (the library doesn't do sub-1 values anyway);
/// callers keep their own zero sentinels.
function arb_log10(_a) {
	return floor(_a) + log10(max(frac(_a) * 10, 1));
}
