/// @description timebank_upg(kind, [commit]);
/// @param kind    "cap" (bank capacity) or "rate" (conversion rate)
/// @param [commit]
/// The time bank's ONE upgrade lawyer. PAID IN BANKED TIME (his call),
/// not in profit - so the bank is a currency with two uses, spend it as
/// speed now or invest it in banking more later, and every purchase is
/// a real decision rather than another line on the profit sink pile.
///
/// ⚖️ TWO LADDERS, EACH OFF ITS OWN LEVEL (his report, 2026-09-10: "the
/// costs seem shared" - they were, both 80% of the current capacity).
/// A capacity fee is priced off the capacity levels held, a rate fee
/// off the rate levels held, both linear in minutes of banked time
/// (setgame's tb_*_cost / tb_*_cost_step). The cap is linear too now
/// (+tb_cap_step a level), so a capacity fee always fits the capacity
/// it buys; a rate fee can outgrow a small cap, and then the row reads
/// unaffordable until the cap is raised - the one coupling left, and
/// the honest one. datafiles/timebank_twin.py walks it.
///
/// "rate" REFUSES at the ceiling rather than selling a level that buys
/// nothing - see timebank_rate's invariant. Nothing may break causality,
/// least of all a purchase.
///
/// commit = false returns a dry quote { ok, cost, maxed }; cost is in
/// SECONDS.
function timebank_upg(_kind, _commit = true) {
	timebank_init();
	var _tb    = g.timebank;
	var _iscap = (_kind == "cap");

	if (!_iscap)
	if (g.tb_rate + _tb.rate_lv * g.tb_rate_step >= min(g.tb_rate_cap, 55))
		return { ok : false, cost : 0, maxed : true };

	var _cost = _iscap
		? (g.tb_cap_cost  + g.tb_cap_cost_step  * _tb.cap_lv)  * 60
		: (g.tb_rate_cost + g.tb_rate_cost_step * _tb.rate_lv) * 60;

	if (!_commit) return { ok : (_tb.bank >= _cost), cost : _cost, maxed : false };
	if (_tb.bank < _cost) return { ok : false, cost : _cost, maxed : false };

	_tb.bank -= _cost;
	if (_iscap) _tb.cap_lv  += 1;
	else        _tb.rate_lv += 1;
	save_mark_dirty();
	return { ok : true, cost : _cost, maxed : false };
}
