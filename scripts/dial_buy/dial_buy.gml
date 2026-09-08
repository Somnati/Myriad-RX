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
	if (!(profit_spendable() >= _cost)) return false;   // the reserve is not spendable

	g.profit  = do_subtract(g.profit, _cost);
	var _was = milestone_get(_i, _d.level);
	_d.level += _n;

	// a rung crossed by this buy: say so (DE's "speed up" / "profit up"
	// banner), in the dial's own colour
	var _now = milestone_get(_i, _d.level);
	for (var _k = 0; _k < array_length(_now.earned); _k++)
		if (_now.earned[_k] && !_was.earned[_k]) {
			var _m = g.milestones[_k];
			assign_banner("dial " + dial_config(_i).name + " " + _m.kind
				+ " x" + string(_m.mult), dial_color(_i), c_black);
			play_sound_ext(snd_pop, .7, .9, .6, 1);
		}

	// a dial that just woke starts its first cycle with DE's autoeff
	// head start rather than from cold
	if (_d.level == _n) _d.cycle = .3;

	update_dials();
	save_mark_dirty();
	return true;
}
