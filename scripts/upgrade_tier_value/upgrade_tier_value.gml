/// @description upgrade_tier_value(val, tier, cap);
/// @param val   the value rolled onto the offer
/// @param tier  how many tiers are owned
/// @param cap   how many it can ever take
/// WHAT A SLOT IS ACTUALLY CONTRIBUTING, and the one place the tier
/// curve lives. It used to be a flat val x tier, which made every tier
/// identical and the last one no more interesting than the first.
///
/// TWO THINGS SHAPE IT (his call, Myriad DE's feel):
///   EACH TIER IS WORTH SLIGHTLY MORE than the one before -
///   weight(t) = 1 + RAMP x (t-1) - so pouring into a slot compounds
///   gently instead of paying the same rent forever.
///   THE LAST TIER IS WORTH A GREAT DEAL MORE, x UPG_TIER_LAST. That
///   is what turns "should I finish this" into a decision: a
///   nearly-complete slot is worth far more than the fraction of it
///   suggests, and completing it is the moment the slot pays off.
///
/// At the shipped 0.15 ramp and x3 finish, a five-tier upgrade earns
/// 1.00 / 2.15 / 3.45 / 4.90 / 9.70 times its rolled value as it fills:
/// the last tier alone nearly doubles the whole thing.
///
/// A cap of 0 or less means "no ceiling known" (a retired roster entry,
/// a save from before offers had a depth) - the ramp still applies and
/// nothing gets the completion bonus, which is the safe direction.
function upgrade_tier_value(_val, _tier, _cap) {
	if (_tier <= 0) return 0;
	var _sum = 0;
	for (var _t = 1; _t <= _tier; _t++) {
		var _w = 1 + UPG_TIER_RAMP * (_t - 1);
		if (_cap > 0 && _t >= _cap) _w *= UPG_TIER_LAST;
		_sum += _w;
	}
	return _val * _sum;
}
