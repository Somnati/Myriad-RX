/// @description num_exp_short(x) - an EXPONENT in the short form (k m b),
/// whatever the game's own format is: what scientific and logarithmic
/// print past an exponent of 100,000 (see the E1M note in crunch_arb).
/// Swaps the pick to short for one call and puts it back.
function num_exp_short(_x) {
	var _keep = g.num_format;
	g.num_format = 0;
	var _s = crunch_arb(arb(_x));
	g.num_format = _keep;
	return _s;
}
