/// @description tile_upg(id, [commit]);
/// @param id       "profit" / "fab" / "bank"
/// @param [commit]
/// The tile table's ONE upgrade lawyer, priced in SHARDS. TWO SHAPES:
///
///     straight   cost = base x 10^(e x level)
///     curved     cost = base x 10^(span x (level / max)^curve)
///
/// ⚖️ THE CURVED ONE IS FOR CAPPED LADDERS (his ask: start small, rise
/// to a ceiling, so more levels land early and they slow as they
/// approach it). A straight line in log space spends its decades evenly,
/// which on a fifty-rung ladder means the FIRST rung already costs a
/// fiftieth of the whole game - and the early half of the ladder is
/// unreachable for no reason except arithmetic.
///
/// The curve spends them unevenly on purpose. `top` is where the LAST
/// level lands (a log10, so 308 is the ceiling) and `curve` is how hard
/// the price accelerates toward it - 1 would be the straight line, 2
/// puts a quarter of the levels inside a hundredth of the span. The span
/// derives from base and top, so moving either moves the whole ladder
/// and neither can drift from the other.
///
/// A curved entry needs `max`: without a last level there is nothing to
/// normalise against, which is why the uncapped rows stay straight.
///
/// ⚖️ INFLATION (his design, 2026-09-09) - a third thing a row may ask
/// for, with `inflate : true`. The problem it solves: the profit
/// upgrade's value compounds with FLUX (flux lifts board output, output
/// feeds the dials, the upgrade scales that feed), so a price curve that
/// ignores flux is a curve a rebirthed player walks straight up. The
/// obvious fix - read the player's actual flux into the price - makes
/// the number jump the instant they reset, which is honest and feels
/// like a fine.
///
/// His answer is to MODEL it instead. For each level:
///
///     raw   = the curve's price
///     c     = calc_flux(raw)      - the flux a player who had EARNED raw
///                                   would hold (raw / TILE_FLUX_DIV)
///     cost  = raw x (1 + c x STEP) - what that flux lets them pay
///
/// A pure function of level. The real pile is never read, so nothing
/// moves when you rebirth - the ladder was already priced for the flux
/// you were about to have. Early levels are untouched (their implied
/// flux rounds to nothing); the top of the ladder is priced for a
/// veteran, because only a veteran is there.
///
/// THE TOP HAS TO BE RE-SOLVED. Inflation is quadratic in the price past
/// DIV/STEP, so a raw curve to 1e308 would land its last level near
/// 1e600. The raw curve runs to (top + k) / 2 instead, k being
/// log10(DIV / STEP), which puts the INFLATED last level on the stated
/// top - derived, so a change to either knob re-solves it.
///
/// ⚖️ `e` IS ORDERS OF MAGNITUDE A LEVEL, not a multiplier (his call:
/// "make the other upgrades increase by E's as well"). The formula was
/// always log10(base) + lv * log10(mult) - it has been in log space
/// since it was written, because that is the only way a level-40 price
/// costs the same to quote as a level-1 one. Carrying log10(mult) in
/// the roster instead of mult removes the conversion, and with it the
/// last place a decimal could round: `e : 2.5` is exactly two and a
/// half decades a level, where mult : 316.227766 was 2.4999999...
/// commit = false gives a dry quote { ok, cost, lv, max }; cost is a
/// packed arb, because shards outgrow a plain real about as fast as
/// profit does.
///
/// A roster entry may carry `max` - the level it stops at (the hopper's
/// is 30, his number). A capped upgrade AT its cap quotes ok:false and
/// max:true, and the drawer prints that rather than a price nobody can
/// pay. Entries without the field are uncapped, so the two that always
/// were are untouched by its existence.
///
/// The closed form lives in log space and packs exactly once - the
/// house rule for anything geometric, and the reason a level-40 price
/// costs the same to quote as a level-1 one.
function tile_upg(_id, _commit = true) {
	tiles_init();
	var _cfg = tile_upg_config();
	var _e = -1;
	for (var _i = 0; _i < array_length(_cfg); _i++)
		if (_cfg[_i].id == _id) _e = _cfg[_i];
	if (_e == -1) return { ok : false, cost : arb(1), lv : 0, max : false };

	var _lv  = g.tiles.upg[$ _id] ?? 0;
	var _cap = _e[$ "max"] ?? -1;

	// AT THE CAP THERE IS NO PRICE, so none is quoted. Handing back the
	// next level's cost and then refusing to sell it is how a screen
	// ends up showing an affordable-looking button that does nothing.
	if (_cap >= 0 && _lv >= _cap)
		return { ok : false, cost : arb(1), lv : _lv, max : true };

	var _lg = log10(_e.base);
	var _infl = _e[$ "inflate"] ?? false;
	// ⚖️ A HAND-SET OPENING (the slots row, 2026-09-10: "the first 4
	// affordable before 100m, then the typical curve"): `pre` lists the
	// first levels' costs outright, and the curve then runs from the
	// LAST of them to the ceiling over the rungs that remain - landing
	// exactly on top at the final buy, so the cap is where e308 IS
	// rather than where it is approached. A row without `pre` prices as
	// it always did.
	var _pre = _e[$ "pre"] ?? undefined;
	var _np  = is_array(_pre) ? array_length(_pre) : 0;
	if (_np > 0 && _lv < _np) {
		_lg = log10(_pre[_lv]);
	}
	else if (variable_struct_exists(_e, "curve") && _cap > 0) {
		// curved: the span from base to top, spent unevenly across the
		// ladder. power() rather than a table, because the shape has to
		// stay right if the cap or the ceiling ever move.
		var _top = _e.top;
		if (_infl) {
			// the raw curve stops short so the inflated one lands on
			// the stated top - see the header
			var _k = log10(TILE_FLUX_DIV / TILE_FLUX_STEP);
			_top = (_e.top + _k) * .5;
		}
		if (_np > 0) {
			var _lg0 = log10(_pre[_np - 1]);
			_lg = _lg0 + (_top - _lg0) * power((_lv - _np + 1) / (_cap - _np), _e.curve);
		} else
			_lg += (_top - _lg) * power(_lv / _cap, _e.curve);
	} else {
		_lg += _lv * _e.e;
	}
	if (_infl) {
		// log10 of the flux a player who had earned `raw` would hold,
		// then log10 of the output bonus that flux gives - added, since
		// the price is raw x bonus. Past 1e6 the +1 is noise and the
		// power() would overflow, so the log is taken directly.
		var _lb = (_lg - log10(TILE_FLUX_DIV)) + log10(TILE_FLUX_STEP);
		_lg += (_lb > 6) ? _lb : log10(1 + power(10, _lb));
	}
	var _cost = do_ceil(log_to_arb(_lg));

	if (!_commit)
		return { ok : (g.tiles.shards >= _cost), cost : _cost, lv : _lv,
		         max : false };
	if (!(g.tiles.shards >= _cost))
		return { ok : false, cost : _cost, lv : _lv, max : false };

	g.tiles.shards = do_subtract(g.tiles.shards, _cost);
	g.tiles.upg[$ _id] = _lv + 1;
	tiles_sync();          // the board takes its new shape at once
	save_mark_dirty();
	return { ok : true, cost : _cost, lv : _lv + 1, max : false };
}
