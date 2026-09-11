/// @description ram_upg([commit]) - the capacity ladder: +RAM_STEP
/// sticks a level, PROFIT-priced, geometric in log space (10^(LG0 +
/// lv x STEP)) and packed once - the ngu cap's shape. Paid through
/// spend_profit, so the reserve binds it like every other purchase.
/// commit = false is a dry quote { ok, cost, lv }.
/// @param [commit]
function ram_upg(_commit = false) {
	autom_init();
	var _lv   = g.autom.ram_lv;
	var _cost = do_ceil(log_to_arb(RAM_COST_LG0 + _lv * RAM_COST_STEP));
	if (!_commit) return { ok : (profit_spendable() >= _cost), cost : _cost, lv : _lv };
	if (!spend_profit(_cost)) return { ok : false, cost : _cost, lv : _lv };
	g.autom.ram_lv = _lv + 1;
	save_mark_dirty();
	return { ok : true, cost : _cost, lv : _lv + 1 };
}
