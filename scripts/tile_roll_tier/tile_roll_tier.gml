/// @description tile_roll_tier() -> the tier of a freshly fabricated
/// tile, rolled through the HOUSE rarity system: calculate_rarity
/// with the modules curve (.3 scale, .03 growth, 800 cutoff - the
/// exact call the rarity bar test tunes), fed by g.tile_rarity.
/// at zero rarity this mostly lands tier 1 with a thin tail of lucky
/// spawns; modifiers raise g.tile_rarity, which shifts the whole
/// distribution up AND (past each 800) raises the window floor via
/// calculate_rarity's _base_rarity side channel.
/// banked (stored) tiles are just a count - their tier is rolled at
/// the moment they materialize onto the board.
function tile_roll_tier() {
	// the whole modifier chain lives in ONE place now (DE's order: flat
	// adders, then the upgrade as a multiply) - see tile_rarity_rate
	var _r = calculate_rarity(luck_rate(tile_rarity_rate()), .3, .03, 800);   // luck leans the tier (DE's gear/chest shape)
	return 1 + _base_rarity + _r;
}
