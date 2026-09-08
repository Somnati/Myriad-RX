/// @description upgrade_bonus();
/// THE ONE READ POINT. Walks the owned slots and returns every
/// accumulator fresh, as a struct keyed by the roster's `stat` field.
/// Nothing here is stored and nothing is saved - see upgrade_init for
/// why that matters, and for what Myriad DE's incremental version cost.
///
/// Every value is a PERCENT and every consumer applies it RESULT-SIDE:
/// multiply the number you just derived, never the inputs you derived
/// it from. That is the adapter contract the whole economy runs on -
/// bake a bonus into a stored level or a base stat and it compounds
/// with itself the next time something resyncs.
///
/// A slot's contribution is `val * tier`, so an offer sitting unbought
/// (tier 0) contributes exactly nothing and needs no special case.
function upgrade_bonus() {
	upgrade_init();

	var _b = {
		tap_profit    : 0,
		crit_rate     : 0,
		crit_multi    : 0,
		dial_profit   : 0,
		dial_speed    : 0,
		dial_cost     : 0,
		credit_rate   : 0,
		credit_luck   : 0,
		rebirth_units : 0,
	};

	// ---- THE SLOTS ----
	var _n = array_length(g.upg.slot);
	for (var _i = 0; _i < _n; _i++) {
		var _s = g.upg.slot[_i];
		if (!is_struct(_s)) continue;
		if (_s.tier <= 0) continue;          // an offer, not yet bought
		if (_s.stat == "") continue;         // a grant; it has no accumulator
		if (!variable_struct_exists(_b, _s.stat)) continue;
		// the tier curve, not a flat multiply - see upgrade_tier_value
		_b[$ _s.stat] += upgrade_tier_value(_s.val, _s.tier, upgrade_cap(_i));
	}

	// ---- THEN THE COMPLETED LEDGER ----
	// One rule for both: an upgrade contributes value x tier whether it
	// is still sitting in a slot or was finished and filed. A completed
	// upgrade leaves its slot (DE clears it) but not the game. The
	// ledger arrives pre-summed per id - see upgrade_init for why.
	var _dn = variable_struct_get_names(g.upg.done);
	for (var _i = 0; _i < array_length(_dn); _i++) {
		var _d = g.upg.done[$ _dn[_i]];
		if (!is_struct(_d)) continue;
		if (_d.stat == "") continue;
		if (!variable_struct_exists(_b, _d.stat)) continue;
		_b[$ _d.stat] += _d.sum;
	}

	// ⚖️ THE ONE CAPPED STAT. Everything else is happy to run away -
	// more profit is always just more - but a crit CHANCE past 100 is
	// meaningless, and a dial DISCOUNT at 100 makes levels free and the
	// economy stops. DE gated these in its roster (it refused to offer
	// crit rate past 500), which hides the ceiling somewhere the player
	// can never see it; capping the effect keeps the offer honest and
	// the number readable.
	_b.crit_rate = min(_b.crit_rate, 60);
	_b.dial_cost = min(_b.dial_cost, 75);

	return _b;
}
