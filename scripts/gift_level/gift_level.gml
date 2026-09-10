/// @description gift_level() -> { lv, into, need, mult } - the gift
/// level DERIVED from total claims (never stored; the one counter is
/// g.gift.claims - house law). A level costs lvl_base + lv * lvl_step
/// claims (3, 5, 7, ...); the loop is bounded tiny by construction
/// (claims grow at most one per real day). mult is the reward output
/// multiplier the level buys - gift_reward reads it, so levelling
/// raises every future gift (his spec).
function gift_level() {
	gift_init();
	var _c = g.gift_cfg;
	var _lv = 0;
	var _left = g.gift.claims;
	var _need = _c.lvl_base;
	while (_left >= _need) {
		_left -= _need;
		_lv++;
		_need = _c.lvl_base + _lv * _c.lvl_step;
	}
	return { lv : _lv, into : _left, need : _need,
		mult : 1 + _lv * _c.lvl_out };
}
