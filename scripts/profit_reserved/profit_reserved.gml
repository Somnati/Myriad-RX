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
	var _s = profit_spendable();
	if (!(g.profit > _s)) return 0;
	return do_subtract(g.profit, _s);
}
