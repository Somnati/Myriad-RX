/// @description tile_base_tier() - the fabricator's spawn FLOOR right
/// now: the lowest tier a fresh tile can be (tile_roll_tier's base).
/// Every TILE_RARITY_CUT of the luck-leaned rarity rate lifts it a step.
function tile_base_tier() {
	return 1 + floor(luck_rate(tile_rarity_rate()) / TILE_RARITY_CUT);
}
