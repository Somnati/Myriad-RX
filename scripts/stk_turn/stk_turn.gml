/// @description stk_turn(s) -> true when turned: THE TURN, the stack's prestige - the cinders banked (HELD: each +6% every speed, +3% spark; SPENT on the tree they're perks instead), the spark, the caps and every level let go (THE KEEP holds 10% a rank; HEADSTART seats the well), the veins re-rolled. Wants quintessence open and at least one cinder to give
function stk_turn(_s) {
	var _c = stk_cinders(_s);
	if (_c < 1 || stk_cap(_s, 2) < 1) return false;
	var _cin = _s.cinders + _c, _turns = _s.turns + 1, _life = _s.life, _spent = _s.spent, _perks = _s.perks, _old = _s.layers;
	var _n = stk_init(true);
	_n.cinders = _cin; _n.turns = _turns; _n.life = _life; _n.spent = _spent; _n.perks = _perks;
	var _keep = .1 * stk_perk(_n, "keep");
	if (_keep > 0) for (var _l = 0; _l < 3; _l++) for (var _i = 0; _i < array_length(_old[_l].sinks); _i++) _n.layers[_l].sinks[_i].level = floor(_old[_l].sinks[_i].level * _keep);
	var _hs = stk_perk(_n, "headstart");
	if (_hs > 0) { var _w = _n.layers[0].sinks[3]; _w.level = max(_w.level, 3 * _hs); }
	stk_veins_roll(_n);
	save_mark_dirty();
	return true;
}
