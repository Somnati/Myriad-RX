/// @description tile_tier_odds([n]);
/// @param [n]  how many tiers to report (default 14, the ladder's own)
/// WHAT THE FABRICATOR ACTUALLY ROLLS - the odds of each TIER coming
/// off a fresh tile, as an array indexed from tier 1.
///
/// It runs the same rarity_odds ladder tile_roll_tier samples, with the
/// same knobs (.3 scale, .03 growth, TILE_RARITY_CUT) and the same
/// rate - tile_rarity_rate through luck_rate, exactly as the roll feeds
/// it, Refined Alloys and the luck stat included. So the bar on the
/// statistics screen is the generator's own arithmetic read a second
/// time, not a second model of it. (2026-09-12: it had drifted twice -
/// DE's literal 800 for the cutoff, and no luck_rate - so the bar
/// understated what the fabricator actually rolled.)
///
/// Index 0 is TIER 1. tile_roll_tier returns 1 + shift + rung, and the
/// shift is already inside rarity_odds' answer, so the array lines up
/// with the tiers directly.
function tile_tier_odds(_n = 14) {
	// the SAME rate the roll uses, from the same function - the bar
	// disagreeing with the generator is a bug that looks like bad luck
	return rarity_odds(luck_rate(tile_rarity_rate()), .3, .03, TILE_RARITY_CUT, _n);
}
