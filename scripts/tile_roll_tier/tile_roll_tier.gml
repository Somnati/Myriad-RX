/// @description tile_roll_tier() -> the tier of a freshly fabricated
/// tile, rolled through the HOUSE rarity system: calculate_rarity
/// with the modules curve (.3 scale, .03 growth, TILE_RARITY_CUT as
/// the cutoff), fed by tile_rarity_rate through luck_rate.
/// at zero rarity this mostly lands tier 1 with a thin tail of lucky
/// spawns; modifiers raise the rate, which shifts the whole
/// distribution up AND (past each TILE_RARITY_CUT) raises the window
/// floor via calculate_rarity's _base_rarity side channel.
/// ⚖️ THE CUTOFF IS THE MACRO (the twins' consistency pass, 2026-09-12):
/// TILE_RARITY_CUT was declared at 400 - his call, "not DE's 800" - and
/// the upgrade's help text quoted it, but both this roll and the odds
/// bar still passed DE's literal 800. The twin modelled 400 the whole
/// time. One number, three readers, now.
/// banked (stored) tiles are just a count - their tier is rolled at
/// the moment they materialize onto the board.
function tile_roll_tier() {
	// the whole modifier chain lives in ONE place now (DE's order: flat
	// adders, then the upgrade as a multiply) - see tile_rarity_rate
	var _r = calculate_rarity(luck_rate(tile_rarity_rate()), .3, .03, TILE_RARITY_CUT);   // luck leans the tier (DE's gear/chest shape)
	return 1 + _base_rarity + _r;
}
