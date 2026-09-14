/// @description autom_strategy(s, n) - one pulse of THE MASTER ROW
/// The cap share of the spendable pile is the pulse's budget; the
/// dials in the FILTER (g.autom.dial[i].on, owned ones only) are walked
/// in the target's order and each buys MAX out of what is left
/// (buy_resolve's wallet), so the first in line takes the lion's share
/// and the remainder trickles down the list. Round-robin moves its
/// cursor one dial a pulse, so every dial gets a turn at the front.
/// The dials that bought wear the verdict (their chips); the row does too.
/// @param s   g.autom.dial_all
/// @param n   how many dials
function autom_strategy(_s, _n) {
	for (var _i = 0; _i < _n; _i++) g.autom.dial[_i].st = 0;   // last pulse's marks
	var _wallet = profit_spendable();
	if (!(_wallet >= arb(1))) { _s.st = 1; return; }
	var _budget = do_scale(_wallet, _s.pct / 100);
	var _order  = autom_order(_n);
	var _any = false;
	for (var _k = 0; _k < array_length(_order); _k++) {
		var _i = _order[_k];
		if (!(_budget >= arb(1))) break;
		if (!g.autom.dial[_i].on || g.dial[_i].level <= 0) continue;   // the filter; a dial you do not own is yours to buy
		var _q = dial_buy_ext(_i, "max", false, _budget);
		if (!_q.ok || !(_budget >= _q.cost)) continue;
		var _r = dial_buy_ext(_i, "max", true, _budget);
		if (!_r.ok) continue;
		_any = true;
		g.autom.dial[_i].st = 2;
		autom_log("dial " + dial_config(_i).name + "  +" + string(_r.n) + " lv  -  " + crunch_arb(_r.cost),
			dial_color(_i), "dial", _r.cost);
		var _d = g.dial[_i];
		_d.auto_n = (_d[$ "auto_n"] ?? 0) + _r.n;
		_d.glow = max(_d.glow, .6);
		_budget = (_budget > _r.cost) ? do_subtract(_budget, _r.cost) : 0;
		if (!(_budget >= arb(1))) break;
	}
	if (g.autom.strat == 3) _s.cur = (_s.cur + 1) mod max(1, _n);
	_s.st = _any ? 2 : 1;
}
