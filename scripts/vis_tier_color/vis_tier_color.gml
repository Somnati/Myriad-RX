/// @description vis_tier_color(tier) - THE tier palette: one colour per
/// rung, for the visualiser's magnitude tiers, the tiles, the
/// overcharger, the title's drift, the FAQ. tile_color is this.
///
/// Tier 1 is white and 2..8 walk Myriad's rarity ladder - THE TILE
/// LADDER'S values (his call, 2026-09-10: "i believe the tile tier
/// color system would be better right?"). The visualiser used to read
/// the c_rarity_* macros for 5..8, and there elite is ORANGE - so
/// legendary gold sat next to elite orange and two adjacent magnitudes
/// read as two yellow squares side by side (his report). The tile
/// ladder puts DE's red at elite instead: gold, red, salmon, ice.
///
/// PAST 8, THE GOLDEN ANGLE - NOT DE's HUE WHEEL. DE picked a hue
/// spoke per ones-digit and advanced 36 degrees a tier, with two of
/// the ten spokes ROLLED at random (ones-digits 5 and 8). The spokes
/// repeat every ten tiers and a rolled one can land beside anything,
/// which is how neighbours came out near-twins. Stepping the hue by
/// 137.508 degrees a tier instead (the golden angle - sunflower seeds,
/// the same trick) guarantees every consecutive pair is ~137 degrees
/// apart, no hue repeats for dozens of tiers, and nothing is random:
/// a tier's colour is a formula of the tier and that is all. Value
/// alternates by parity so even a hue-cousin five tiers on reads as a
/// different rung. The 30-degree phase seats tier 9 at orange, well
/// away from ultimate's ice.
///
/// No RNG, no cache, no seed dance: this is arithmetic.
function vis_tier_color(_tier) {
	if (_tier <= 1) return c_white;
	if (_tier == 2) return rgb(60, 255, 69);    // uncommon
	if (_tier == 3) return rgb(65, 122, 255);   // rare
	if (_tier == 4) return rgb(160, 32, 255);   // epic
	if (_tier == 5) return rgb(255, 167, 10);   // legendary
	if (_tier == 6) return rgb(253, 14, 53);    // elite (red - the tile ladder's)
	if (_tier == 7) return rgb(248, 131, 121);  // divine
	if (_tier == 8) return rgb(185, 242, 255);  // ultimate

	var _h = ((_tier - 9) * 137.508 + 30) mod 360;
	var _odd = (_tier mod 2) == 1;
	return make_colour_hsv(round(_h / 360 * 255),
		_odd ? 235 : 200,      // punchy, and a shade less on the even rungs
		_odd ? 255 : 215);     // ...which also sit a step darker
}
