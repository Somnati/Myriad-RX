/// @description stk_turn(s) -> true when turned: THE TURN, the stack's prestige - the cinders banked (each +6% every speed, +3% spark, for ever), the spark, the caps and every level let go, the roster fresh. Wants quintessence open and at least one cinder to give
function stk_turn(_s) {
	var _c = stk_cinders(_s);
	if (_c < 1 || stk_cap(_s, 2) < 1) return false;
	var _cin = _s.cinders + _c, _turns = _s.turns + 1, _life = _s.life;
	var _n = stk_init(true);
	_n.cinders = _cin; _n.turns = _turns; _n.life = _life;
	save_mark_dirty();
	return true;
}
