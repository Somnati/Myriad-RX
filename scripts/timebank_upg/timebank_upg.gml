/// @description timebank_upg(kind, [commit]);
/// @param kind    "cap" (bank capacity) or "rate" (conversion rate)
/// @param [commit]
/// The time bank's ONE upgrade lawyer. PAID IN BANKED TIME (his call),
/// not in profit - so the bank is a currency with two uses, spend it as
/// speed now or invest it in banking more later, and every purchase is
/// a real decision rather than another line on the profit sink pile.
///
/// THE PRICE IS A FRACTION OF THE CURRENT CAPACITY, and that is forced
/// rather than chosen. You can never hold more than the cap, so a price
/// above it is a price you could never save for: a geometric cost
/// against a linear cap goes unbuyable two or three levels in and the
/// whole ladder dies. Pricing off the cap makes every level affordable
/// with a full bank and with not much less, and moves the curve onto
/// the cap itself, which grows geometrically (timebank_cap).
///
/// WHAT ACTUALLY DECELERATES is the wall clock. The price in HOURS OF
/// ABSENCE is cost/rate, and while the cap compounds the rate is
/// linear and stops at 45 min an hour - so each level costs more real
/// absence than the last, forever. datafiles/timebank_twin.py walks it.
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

	var _pc   = _iscap ? g.tb_cap_cost : g.tb_rate_cost;
	var _cost = ceil(timebank_cap() * clamp(_pc, 1, 99) / 100);

	if (!_commit) return { ok : (_tb.bank >= _cost), cost : _cost, maxed : false };
	if (_tb.bank < _cost) return { ok : false, cost : _cost, maxed : false };

	_tb.bank -= _cost;
	if (_iscap) _tb.cap_lv  += 1;
	else        _tb.rate_lv += 1;
	save_mark_dirty();
	return { ok : true, cost : _cost, maxed : false };
}
