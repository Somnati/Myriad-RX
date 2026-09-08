/// @description profit_reserved();
/// The part of the pile the reserve is holding back, as a packed arb.
/// Derived from the same one rule profit_spendable uses, so the two can
/// never disagree about where the line is - which they would within a
/// week if each did its own arithmetic.
/// Zero when the reserve is off, which is the default.
function profit_reserved() {
	if (!variable_global_exists("autom")) return 0;
	var _p = clamp(g.autom.lock_pct, 0, 90);
	if (_p <= 0) return 0;
	if (!(g.profit >= arb(1))) return 0;
	// derived from the same one rule profit_spendable uses, so the two
	// can never disagree about where the line is - which they would
	// within a week if each did its own arithmetic. Clamped to the pile:
	// the watermark can outrun what you actually hold (spend to the
	// floor and the two meet), and a reserve larger than the money is a
	// number nobody can act on.
	var _s = profit_spendable();
	if (!(_s >= arb(1))) return g.profit;
	return do_subtract(g.profit, _s);
}
