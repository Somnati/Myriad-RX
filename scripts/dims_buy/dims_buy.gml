/// @description dims_buy(i or "tick", [qty]) -> units bought. spends
/// DARK MATTER (the cascade buys itself, like antimatter did). a bought unit
/// raises count AND bought - the per-10 doubling milestone rides
/// bought alone, so produced copies snowball counts without cheapening
/// the milestone (AD's split). tier i unlocks once tier i-1 has ever
/// been bought. qty "max" buys until the dark matter runs out - the costs
/// ramp geometrically, so the wallet bounds the loop itself (the big
/// repeat count is just a runaway guard). dark matter/count/cost are all
/// LOG10 values (see dims_init): compares work as-is, spend routes
/// through lsub, +1 unit is ladd(count, 0) [log10(1) = 0].
function dims_buy(_i, _q = 1) {
	var _d = g.dims;
	if (_d.inf) return 0; // the run is over - big crunch first
	if (_i != "tick" && _i > 0 && _d.bought[_i - 1] <= 0) return 0;
	if (_q == "max") _q = 100000;
	var _did = 0;
	repeat (_q) {
		var _c = dims_cost(_i);
		if (_d.dark < _c) break;
		_d.dark = _d.lsub(_d.dark, _c);
		if (_i == "tick") _d.tick_bought++;
		else {
			_d.bought[_i]++;
			_d.count[_i] = _d.ladd(_d.count[_i], 0);
		}
		_did++;
	}
	if (_did > 0) save_mark_dirty();
	return _did;
}
