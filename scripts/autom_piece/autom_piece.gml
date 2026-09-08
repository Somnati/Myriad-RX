/// @description autom_piece(p, i);
/// @param p   the dial's automation struct
/// @param i   the dial index
/// ONE DIAL'S AUTOBUY PULSE, carrying Myriad DE's dynamic-quantity law
/// out of auto_buy_dial (evo_lv / elvtic) as law rather than as code -
/// the original is archaeology, the behaviour is the point:
///
///   - the step size q GROWS on every landed buy: q += max(1 + h, 1),
///     and past q 50 the ramp itself accelerates (h += 1). Buys
///     compound while income comfortably outpaces cost, so autobuy
///     consumes income at whatever rate income arrives - no fixed
///     x10 / x100 mode to pick, and none to outgrow.
///   - the moment a buy cannot be afforded the ramp COLLAPSES HARD:
///     q = 1, h = -50. It re-grows one per landed buy, so it walks back
///     through the cooldown and only starts accelerating again once the
///     heat climbs past zero. That asymmetry is what stops it
///     oscillating between "buy 400" and "buy nothing".
///
/// THE BUDGET is the spend threshold: the bill must be at most pct% of
/// the CURRENT wallet. Set 50 and this dial never takes profit below
/// half of whatever it happens to be holding.
///
/// Every purchase routes through dial_buy_ext, the pricing lawyer.
/// Autobuy owns no cost math of its own and must never grow any.
function autom_piece(_p, _i) {
	// no wallet, no shopping (this also keeps do_scale off sub-1 arbs).
	// THE WALLET IS THE SPENDABLE PILE, never the whole one - budgeting
	// against g.profit would let autobuy spend the reserve, which is
	// the exact thing the reserve exists to stop.
	var _wallet = profit_spendable();
	if (!(_wallet >= arb(1))) { _p.st = 1; return; }
	var _budget = do_scale(_wallet, _p.pct / 100);

	var _q     = max(1, _p.q);
	var _quote = dial_buy_ext(_i, _q, false);
	var _fits  = _quote.ok && (_budget >= _quote.cost);

	// too rich a step: collapse the ramp and retry a single level on
	// THIS pulse, so a starved ramp still trickles +1s rather than
	// standing still for a second
	if (!_fits && _q > 1) {
		_p.q = 1;
		_p.h = -50;
		_q   = 1;
		_quote = dial_buy_ext(_i, 1, false);
		_fits  = _quote.ok && (_budget >= _quote.cost);
	}

	if (!_fits) {
		_p.h  = -50;   // keep the heat floored so recovery starts gentle
		_p.st = 1;
		return;
	}

	dial_buy_ext(_i, _q, true);

	_p.q += max(1 + _p.h, 1);
	if (_p.q > 50) _p.h += 1;
	_p.q  = min(_p.q, 100000);   // one pulse, one planet
	_p.st = 2;
}
