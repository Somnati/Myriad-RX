/// @description autom_upgrades();
/// The upgrade table's automation pulse. Three switches, and the ORDER
/// they run in is the design: SELL, then ROLL, then BUY.
///
/// Selling first frees the slots that the roll then fills, so one pulse
/// can turn a table of rejects into a table of fresh offers instead of
/// taking three. Buying last means it only ever spends on what survived
/// the filter this same pulse - never on something about to be sold.
///
/// SELL asks upgrade_autosell_wants, which is the one place the rule
/// lives - two filters, rarity and kind, either of which is enough. It
/// never sells a slot with tiers bought into it.
///
/// BUY spends credits while the bill is at most pct% of the CURRENT
/// balance, cheapest slot first - cheapest maximises tiers per credit,
/// and tiers are what the bonus actually counts.
/// @param buy_due   this call may BUY (the buy row's own clock fired)
/// @param pulse     this call may SELL and ROLL (the base pulse)
function autom_upgrades(_buy_due = true, _pulse = true) {
	autom_init();
	if (!variable_global_exists("upg")) return;
	var _u = g.autom.upg;
	if (!(_u.roll || _u.buy || _u.sell)) { _u.st = 0; return; }
	if (_pulse) _u.st = 1;

	var _n = upgrade_slots();

	// ---- SELL what the filter rejects (upgrade_autosell_wants is the
	// ---- one rule; the room previews it through the same call) ----
	if (_u.sell && _pulse)
	for (var _i = 0; _i < _n; _i++) {
		if (!upgrade_autosell_wants(_i)) continue;
		upgrade_sell(_i);
		_u.st = 2;
	}

	// ---- ROLL into what is empty ----
	if (_u.roll && _pulse)
	for (var _i = 0; _i < _n; _i++) {
		if (is_struct(g.upg.slot[_i])) continue;
		var _r = upgrade_roll(_i);
		if (_r == -2) break;              // out of credits; stop trying
		if (_r != -1) _u.st = 2;
	}

	// ---- BUY, cheapest first, inside the budget ----
	// NO RARITY FILTER HERE, deliberately. The keep percentage decides
	// what gets SOLD, and if the autosell is on it already emptied
	// those slots two loops ago. Applying it again here would mean that
	// with the autosell OFF, autobuy silently refused to level a common
	// the player had chosen to keep - a filter doing a job nobody asked
	// it to do.
	if (_u.buy && _buy_due) {
		// gather what is buyable, then take them in price order:
		// cheapest first maximises tiers per credit, and tiers are what
		// the bonus actually counts
		var _cand = [];
		for (var _i = 0; _i < _n; _i++) {
			if (!is_struct(g.upg.slot[_i])) continue;
			var _c = upgrade_cost(_i);
			if (_c <= 0) continue;                       // empty or maxed
			array_push(_cand, { i : _i, c : _c });
		}
		array_sort(_cand, function(_a, _b) { return _a.c - _b.c; });

		// ⚖️ BUY MAX WITHIN THE CAP (his call, 2026-09-12): the share is
		// taken ONCE at the top of the pulse - it is the pulse's budget -
		// and tiers are bought cheapest-first until it is spent: every
		// tier's price is re-quoted after the one before it (a slot's
		// price climbs with its tier), so the walk stops exactly where
		// the budget does. Re-reading the share per buy (the old rule)
		// was the one-tier-a-pulse law; a max buy wants the whole share
		var _budget = do_scale(g.credits, _u.pct / 100);
		var _spent  = 0;
		var _guard  = 0;
		while (_guard++ < 200) {
			// the cheapest tier on the table right now
			var _bi = -1, _bc = 0;
			for (var _i = 0; _i < _n; _i++) {
				if (!is_struct(g.upg.slot[_i])) continue;
				var _c = upgrade_cost(_i);
				if (_c <= 0) continue;
				if (_bi == -1 || _c < _bc) { _bi = _i; _bc = _c; }
			}
			if (_bi == -1) break;
			if (!(g.credits >= arb(_bc))) break;
			if (!(_budget >= arb(_spent + _bc))) break;
			if (!upgrade_buy(_bi)) break;
			_spent += _bc;
			_u.st = 2;
		}
	}
}
