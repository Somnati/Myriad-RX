/// @description timebank_upg(kind, [commit]);
/// @param kind    "cap" (bank capacity) or "rate" (conversion rate)
/// @param [commit]
/// The time bank's ONE upgrade lawyer. PRICED IN PROFIT, not credits -
/// credits buy upgrades, and this is a sink for the currency that grows
/// without bound. The house closed form, entirely in log space and
/// packed exactly once:
///     cost(level) = base x mult^level
/// base 50k for capacity, 250k for rate (the stronger lever), mult
/// tb_cost_mult - steeper than the production curves on purpose,
/// because a late-game sink that keeps pace with production is not a
/// sink.
///
/// "rate" REFUSES at the ceiling rather than selling a level that buys
/// nothing - see timebank_rate's invariant. Money must not break
/// causality.
///
/// commit = false returns a dry quote { ok, cost, maxed }.
function timebank_upg(_kind, _commit = true) {
	timebank_init();
	var _tb    = g.timebank;
	var _iscap = (_kind == "cap");

	if (!_iscap)
	if (g.tb_rate + _tb.rate_lv * g.tb_rate_step >= min(g.tb_rate_cap, 55))
		return { ok : false, cost : arb(1), maxed : true };

	var _lv   = _iscap ? _tb.cap_lv : _tb.rate_lv;
	var _base = _iscap ? 50000 * max(.01, g.tb_cap_cost  / 100)
	                   : 250000 * max(.01, g.tb_rate_cost / 100);
	var _m    = max(1.1, g.tb_cost_mult / 100);
	var _cost = do_ceil(log_to_arb(log10(_base) + _lv * log10(_m)));

	if (!_commit) return { ok : (g.profit >= _cost), cost : _cost, maxed : false };
	if (!spend_profit(_cost)) return { ok : false, cost : _cost, maxed : false };
	if (_iscap) _tb.cap_lv  += 1;
	else        _tb.rate_lv += 1;
	return { ok : true, cost : _cost, maxed : false };
}
