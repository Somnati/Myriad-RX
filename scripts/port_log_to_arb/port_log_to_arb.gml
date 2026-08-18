/// port_log_to_arb(lg) (techdemo II port - private copy, myriad has no
/// log_to_arb) - EXACT packed arb from a log10 value: exp = floor(lg),
/// coe = 10^frac(lg). used by the block visualizer's label callback to
/// hand crunch_arb a block's magnitude (count x 10^tier) as an arb.
/// negative logs (sub-1 values) return 0: the arb library doesn't do
/// those.
function port_log_to_arb(_lg) {
	if (_lg < 0) return 0;
	var _e = floor(_lg);
	return _e + power(10, _lg - _e) / 10;
}
