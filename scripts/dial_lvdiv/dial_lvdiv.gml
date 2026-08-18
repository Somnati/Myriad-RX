/// @description dial_lvdiv(tier) - the LEVEL HEAD START a dial's tier is
/// born with (Myriad DE's get_lvdiv, rebuilt as a pure function of the
/// tier instead of a script that wrote outer-scope variables).
/// THE TIER LADDER LIVES HERE: dial a starts at its true level, while
/// dial m is treated as though it were ~1080 levels along. Since output
/// grows with level (dial_gps) and so does price (dial_cost), a fresh
/// high dial is simultaneously far stronger and far more expensive than
/// a fresh low one - that IS the progression.
///   tier 0 -> 0 | 1 -> 12 | 5 -> 300 | 6 -> 387 | 12 -> 1080
/// The lerp ceilings (1000 at tier/1000000) only bite at tiers this
/// game will never reach; they are kept so the curve stays DE's.
function dial_lvdiv(_tier) {
	var _mn = lerp(0, 60, clamp(_tier / 5, 0, 1));
	var _mx = lerp(160, 1000, _tier / 1000000);
	var _d  = floor(lerp(_mn, _mx, clamp((_tier - 5) / 23, 0, 1)));
	_d *= _tier;
	_d += 100 * floor(_tier / 20); // DE's step-ups past the 13-dial
	_d -= 20  * floor(_tier / 27); // roster, kept for future evolutions
	return _d;
}
