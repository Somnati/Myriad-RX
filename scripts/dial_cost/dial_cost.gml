/// @description dial_cost(tier, from_level, to_level) - the price of a
/// RANGE of levels, as one closed form (Myriad DE's get_cost_v3).
/// The law: price is exponential in level at .05 log10 per level
/// (x1.122), measured from a per-tier purchase point, and the cost of
/// levels from A to B is simply price(B) - price(A) - a geometric
/// series solved by subtraction instead of a loop, so buying a hundred
/// levels costs one calculation.
/// PRICE CLIMBS FASTER THAN OUTPUT (.05 vs dial_gps' .0255 per level)
/// BY DESIGN: levelling one dial always decays, and the way forward is
/// the next dial up the tier ladder. Never "fix" this asymmetry.
/// Dial a's very first level is the fixed opening price of 100.
/// THE MILESTONE PREMIUM (his spec, 2026-09-02 - DE never managed it,
/// its milestone levels sold at vanilla price): every rung inside the
/// range adds (g.milestone_cost_mult - 1) x that level's own price,
/// so the level that crosses a rung costs cost_mult times normal and
/// a bulk buy that rolls through one pays the premium in its quote.
/// raw = true is the price WITHOUT premiums - the premium calls it
/// for the single level's base, nothing else should.
/// THE BULK LAW (his check, 2026-09-02): x1 buys must cost exactly
/// what their bulk equivalent costs. The price POINTS are rounded to
/// whole units and THEN subtracted, so cost(A,B) = P(B) - P(A) with
/// integer P, and a chain of singles telescopes to the same sum by
/// construction. (Rounding the difference instead - DE's way - made
/// ten singles a few units dearer than one x10.) The premium rounds
/// to whole units too, for the same reason.
function dial_cost(_tier, _from, _to, _raw = false) {
	if (_to <= _from) return 0;

	var _lvdiv = dial_lvdiv(_tier);
	var _lv    = _from + _lvdiv;
	var _des   = _to   + _lvdiv;

	// the purchase point: DE's get_purchase_point, whose scale term is
	// zero in the shipped game - dig 3 for a dormant slot, 4 once it
	// has run. Its exponent minus one (floored at 2) is where the
	// per-level climb starts from.
	var _pp   = (_from > 0) ? 4 : 3;
	var _base = max(2, _pp - 1);

	var _gth = 5 / 100;                      // .05 log10 per level
	_gth *= lerp(1, 1000, _tier / 1000000);  // DE's far-tier ramp (~1 here)

	// DE's deep-level surcharge: past 700 real levels the climb doubles
	var _a = _base + _gth * _lv  + _gth * max(0, _from - 700);
	var _b = _base + _gth * _des + _gth * max(0, _to   - 700);

	var _pt = log_to_arb(_pp);
	var _ca = do_ceil((_from <= 0) ? _pt : do_add(_pt, log_to_arb(_a)));
	var _cb = do_ceil(do_add(_pt, log_to_arb(_b)));

	var _cost = (_cb > _ca) ? do_subtract(_cb, _ca) : arb(1);

	// the opening price: dial a's first level is always 100 (DE's own
	// special case - the bootstrap the first taps are paying toward)
	if (_from <= 0 && _tier == 0) _cost = arb(100);

	// the milestone premium, rung by rung inside (from, to]
	if (!_raw && variable_global_exists("milestones") && g.milestone_cost_mult > 1) {
		var _ms = g.milestones;
		for (var _k = 0; _k < array_length(_ms); _k++) {
			var _m = _ms[_k].level;
			if (_m > _from && _m <= _to) {
				var _one = dial_cost(_tier, _m - 1, _m, true);
				if (_one >= arb(1))
					_cost = do_add(_cost, do_ceil(do_scale(_one, g.milestone_cost_mult - 1)));
			}
		}
	}

	// ---- UPGRADES: the discount, result-side and LAST ----
	// After the milestone premium on purpose, so a discount reduces the
	// whole bill rather than only its base - and the raw quotes the
	// milestone loop takes above are untouched by it, which is what
	// keeps that recursion from discounting itself twice.
	if (!_raw) {
		var _ub = upgrade_bonus_live();
		if (_ub.dial_cost > 0)
			_cost = do_scale(_cost, 1 - _ub.dial_cost / 100);
	}

	return do_ceil(_cost);
}
