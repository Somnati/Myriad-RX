/// @description tile_rarity_rate() - THE fabricator's live rarity rate,
/// as calculate_rarity wants it. Myriad DE's chain, in DE's order.
///
/// ⚖️ "+20% RARITY" IS A MULTIPLIER, NOT AN ADDITION (his correction:
/// check DE). I had read the percentage as a share of the 800 cutoff and
/// added a flat 160 a level, which is a defensible reading of the words
/// and simply is not what DE does. indiv.gml is unambiguous:
///
///     g.mod_rarity_rate = 100;                        // THE BASE
///     if rush   g.mod_rarity_rate += 50;              // flat adders
///     if deck   g.mod_rarity_rate += ad_get_rarityrate(lv);
///     g.mod_rarity_rate *= 1 + (g.u_rarityrate / 100);// the UPGRADE
///
/// Three things fall out of that, and the first two are why the flat
/// reading could never have worked:
///
///   THE BASE IS 100, not 0. A multiplier needs something to multiply,
///   and RX started this rate at zero - so DE's own formula applied to
///   RX's base would have left the upgrade doing precisely nothing at
///   every level. The base is what makes a percentage mean anything.
///
///   THE ORDER MATTERS. Flat adders land BEFORE the multiply, so the
///   ability deck's Refined Alloys is itself amplified by the upgrade.
///   Applying the multiplier in tiles_sync (where the level is known)
///   and the deck bonus at the roll (where the flag is known) would
///   have silently reversed that, and the deck card would have been
///   worth a flat 400 forever instead of 400 x whatever you had bought.
///
///   IT IS ONE FUNCTION. tile_roll_tier and tile_tier_odds both need
///   this number - the roll and the statistics bar that reports the
///   roll - and they were each rebuilding the chain from g.tile_rarity.
///   Two copies of an order-sensitive formula is two chances to get the
///   order wrong, and the bar disagreeing with the generator is a bug
///   that looks like bad luck.
///
/// g.tile_rarity stays the FLAT part (base + any future flat knob);
/// everything conditional lives here.
function tile_rarity_rate() {
	var _r = variable_global_exists("tile_rarity")
		? g.tile_rarity : TILE_RARITY_BASE;

	// ---- flat adders, first ----
	// Refined Alloys (ability deck, LIVE): +400. Guarded so the tile
	// framework stays independent of the deck.
	if (variable_global_exists("ad_tilerarity") && g.ad_tilerarity == 1)
		_r += 400;

	// ---- then the upgrade, as a multiplier ----
	// TILE_RARITY_STEP is PERCENTAGE POINTS a level (his +20%), summed the
	// way DE sums u_rarityrate and applied as one multiply - so ten
	// levels is x3, not ten separate x1.2 compoundings.
	if (variable_global_exists("tiles")) {
		var _lv = g.tiles.upg[$ "rarity"] ?? 0;
		if (_lv > 0) _r *= 1 + (TILE_RARITY_STEP * _lv) / 100;
	}

	return max(0, _r);
}
