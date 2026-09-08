/// @description upgrade_keep_rarity();
/// The rarity rung the upgrade autosell keeps: anything BELOW this is
/// sold, anything at or above it is kept.
///
/// IT IS DERIVED FROM A PERCENTAGE, NOT SET AS A RARITY, and that is
/// the entire design of the control. "sell anything below rare" is a
/// setting that rots: the moment the roll distribution shifts upward -
/// a luck stat, a rarity bonus, a deeper ladder - commons stop
/// appearing, the rule stops matching anything, and the automation
/// quietly does nothing while the player believes it is filtering.
///
/// So the knob is "keep the best N% of rolls" and the rung is worked
/// out from the LIVE odds every time it is read. Walk down from the top
/// accumulating the tail probability; the answer is the lowest rung
/// whose tail still fits inside N%. At today's cube law and 25%, that
/// is legendary and above - about one roll in five. Change the curve,
/// raise g.upgrade_rarity, add rungs, or reshape the band ladder
/// entirely, and the same 25% still means "the best fifth of what you
/// actually see". That is not hypothetical: the luck rate slides the
/// window so the bottom rung stops being offered at all, which is
/// exactly the case a fixed rung could not survive.
///
/// 100% keeps everything (the autosell is off in all but name), and 1%
/// keeps only the top rung.
function upgrade_keep_rarity() {
	autom_init();
	var _p = clamp(g.autom.upg.keep, 1, 100) / 100;
	var _o = upgrade_rarity_odds();
	var _n = array_length(_o);
	var _tail = 0;
	for (var _r = _n - 1; _r >= 0; _r--) {
		_tail += _o[_r];
		if (_tail > _p) return min(_n - 1, _r + 1);
	}
	return 0;   // the whole distribution fits - keep everything
}
