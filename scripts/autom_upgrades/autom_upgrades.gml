/// @description autom_upgrades();
/// The upgrade table's automation pulse. Three switches, and the ORDER
/// they run in is the design: SELL, then ROLL, then BUY.
///
/// Selling first frees the slots that the roll then fills, so one pulse
/// can turn a table of rejects into a table of fresh offers instead of
/// taking three. Buying last means it only ever spends on what survived
/// the filter this same pulse - never on something about to be sold.
///
/// SELL uses upgrade_keep_rarity, which is a PERCENTAGE of the live
/// distribution rather than a fixed rung - read that script for why
/// that matters more than it sounds. It never sells a slot with tiers
/// bought into it: that is an investment the player made deliberately,
/// and a filter that liquidates it is a filter that stole something.
///
/// BUY spends credits while the bill is at most pct% of the CURRENT
/// balance, cheapest slot first - cheapest maximises tiers per credit,
/// and tiers are what the bonus actually counts.
function autom_upgrades() {
	autom_init();
	if (!variable_global_exists("upg")) return;
	var _u = g.autom.upg;
	if (!(_u.roll || _u.buy || _u.sell)) { _u.st = 0; return; }
	_u.st = 1;

	var _n     = upgrade_slots();
	var _floor = upgrade_keep_rarity();

	// ---- SELL what the filter rejects ----
	if (_u.sell)
	for (var _i = 0; _i < _n; _i++) {
		var _s = g.upg.slot[_i];
		if (!is_struct(_s)) continue;
		if (_s.tier > 0) continue;        // bought into: not ours to sell
		if (_s.rar >= _floor) continue;
		upgrade_sell(_i);
		_u.st = 2;
	}

	// ---- ROLL into what is empty ----
	if (_u.roll)
	for (var _i = 0; _i < _n; _i++) {
		if (is_struct(g.upg.slot[_i])) continue;
		var _r = upgrade_roll(_i);
		if (_r == -2) break;              // out of credits; stop trying
		if (_r != -1) _u.st = 2;
	}

	// ---- BUY, cheapest first, inside the budget ----
	if (_u.buy) {
		if (!(g.credits >= arb(1))) return;
		var _budget = do_scale(g.credits, _u.pct / 100);

		// gather what is buyable, then take them in price order
		var _cand = [];
		for (var _i = 0; _i < _n; _i++) {
			if (!is_struct(g.upg.slot[_i])) continue;
			if (g.upg.slot[_i].rar < _floor) continue;   // filtered out
			var _c = upgrade_cost(_i);
			if (_c <= 0) continue;                       // empty or maxed
			array_push(_cand, { i : _i, c : _c });
		}
		array_sort(_cand, function(_a, _b) { return _a.c - _b.c; });

		for (var _k = 0; _k < array_length(_cand); _k++) {
			var _c = _cand[_k].c;
			if (!(_budget >= arb(_c))) continue;
			if (!(g.credits >= arb(_c))) break;
			if (upgrade_buy(_cand[_k].i)) _u.st = 2;
		}
	}
}
