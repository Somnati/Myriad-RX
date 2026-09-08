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
	if (!variable_global_exists("tile_rarity")) g.tile_rarity = 0;
	var _rate = g.tile_rarity;
	// Refined Alloys (ability deck, LIVE): +400 tile rarity while on.
	// guarded so the tile framework stays independent of the deck
	if (variable_global_exists("ad_tilerarity") && g.ad_tilerarity == 1)
		_rate += 400;
	var _r = calculate_rarity(_rate, .3, .03, 800);
	return 1 + _base_rarity + _r;
}
