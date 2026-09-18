/// @description dims_cost(i or "tick") -> the next unit's dark matter price,
/// as a LOG10 value (the whole bench speaks log10 - see dims_init).
/// BALANCE ROUND 2 (his "beat it in 10min" report): AD-SHAPED curves
/// now - bases are AD's real dimension ladder (10^1 .. 10^24) and the
/// per-buy log steps are AD's cost multipliers x0.85. tuned by
/// SIMULATION (scratchpad dimsim.ps1, greedy max-buy player on the
/// same closed form): x0.85 crosses the e308 wall in ~3.2-4.6h of
/// play; x0.7 took 15min, x1.0 stalled forever - the curve is a
/// knife edge, treat these numbers as one coupled set with the x1.15
/// tickspeed payoff in dims_tick. tickspeed still costs a decade per
/// buy, the original's rhythm.
function dims_cost(_i) {
	static _base = [1, 2, 4, 6, 9, 13, 18, 24];
	static _step = [.255, .34, .425, .51, .68, .85, 1.02, 1.275];
	var _d = g.dims;
	if (_i == "tick") return 3 + _d.tick_bought;
	return _base[_i] + _d.bought[_i] * _step[_i];
}
