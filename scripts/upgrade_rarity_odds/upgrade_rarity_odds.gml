/// @description upgrade_rarity_odds();
/// THE RARITY DISTRIBUTION, as an array of probabilities summing to 1.
///
/// This is what upgrade_roll actually rolls against, which is the whole
/// point of it existing: the bar on the statistics page draws THIS, so
/// the picture is the game's own odds rather than a second model of
/// them that can quietly drift away from the roll it claims to
/// describe. A distribution chart that is maintained separately from
/// the generator is a chart that will be wrong eventually.
///
/// THE CURVE. A roll is floor(u^POW * N) for u uniform on [0,1): the
/// power crushes the mass toward the common end without ever closing
/// the top rung off. Its closed form is what this returns, because
/// floor(u^POW * N) lands on r exactly when u falls between two roots:
///
///     p(r) = ((r+1)/N)^(1/POW) - (r/N)^(1/POW)
///
/// So the shape has ONE owner. Raise UPG_RARITY_POW to steepen the
/// tail and the roll and the bar move together, by construction.
///
/// AT POW 3 THE TAIL IS FAT: common 52%, and everything above it lands
/// between 5% and 14% - ultimate is about 1 in 20. That is visible on
/// the bar now, which is what the bar is for; it is a tuning question,
/// not a bug, and this macro is where the answer goes.
function upgrade_rarity_odds() {
	var _n   = UPG_RARITY_N;
	var _inv = 1 / UPG_RARITY_POW;
	var _out = array_create(_n, 0);
	var _lo  = 0;
	for (var _r = 0; _r < _n; _r++) {
		var _hi = power((_r + 1) / _n, _inv);
		_out[_r] = _hi - _lo;
		_lo = _hi;
	}
	return _out;
}
