/// @description dial_buy(i, [levels]) - THE one place a dial gains
/// levels (Myriad DE's click_dial / auto_buy_dial share this job).
/// Quotes through dial_cost, spends profit, then resyncs the whole
/// layer so every derived number and the tap's own power are correct
/// again. Returns true if the purchase landed.
/// Buying a dial that has never run is what UNLOCKS it - level 0 means
/// dormant, and its first level is its purchase price.
function dial_buy(_i, _n = 1) {
	if (!variable_global_exists("dial")) return false;
	if (_i < 0 || _i >= g.dial_total) return false;
	if (_n < 1) return false;

	var _d    = g.dial[_i];
	var _cost = dial_cost(_i, _d.level, _d.level + _n);
	if (!(g.profit >= _cost)) return false;

	g.profit  = do_subtract(g.profit, _cost);
	_d.level += _n;

	// a dial that just woke starts its first cycle with DE's autoeff
	// head start rather than from cold
	if (_d.level == _n) _d.cycle = .3;

	update_dials();
	save_mark_dirty();
	return true;
}
