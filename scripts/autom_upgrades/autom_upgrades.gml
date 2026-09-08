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
function autom_upgrades() {
	autom_init();
	if (!variable_global_exists("upg")) return;
	var _u = g.autom.upg;
	if (!(_u.roll || _u.buy || _u.sell)) { _u.st = 0; return; }
	_u.st = 1;

	var _n = upgrade_slots();

	// ---- SELL what the filter rejects (upgrade_autosell_wants is the
	// ---- one rule; the room previews it through the same call) ----
	if (_u.sell)
	for (var _i = 0; _i < _n; _i++) {
		if (!upgrade_autosell_wants(_i)) continue;
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
	// NO RARITY FILTER HERE, deliberately. The keep percentage decides
	// what gets SOLD, and if the autosell is on it already emptied
	// those slots two loops ago. Applying it again here would mean that
	// with the autosell OFF, autobuy silently refused to level a common
	// the player had chosen to keep - a filter doing a job nobody asked
	// it to do.
	if (_u.buy) {
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

		for (var _k = 0; _k < array_length(_cand); _k++) {
			var _c = _cand[_k].c;
			// THE BUDGET IS RE-READ EVERY TIME, off the live balance -
			// the same semantics the dials use. Taking it once at the
			// top of the loop would let one pulse spend several times
			// the share the player set, because each purchase lowers
			// the balance the next share should have been measured
			// against.
			if (!(g.credits >= arb(1))) break;
			if (!(do_scale(g.credits, _u.pct / 100) >= arb(_c))) continue;
			if (upgrade_buy(_cand[_k].i)) _u.st = 2;
		}
	}
}
