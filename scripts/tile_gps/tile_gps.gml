/// @description tile_gps(tier) -> arb income for one tile of that tier.
/// ported from Myriad's mod_generate_gps, made pure (no globals, no
/// side channel through a bare `gps` variable). growth is exponential:
/// the DIGIT COUNT climbs .36 per tier and a polynomial multiplier
/// rides on top, so merging up always beats hoarding. the early tiers
/// are hand-tuned (Myriad shipped with these exact numbers).
function tile_gps(_tier) {
	if (_tier <= 1) return arb(1); // Myriad gave tier 1 nothing; a demo tile should tick
	if (_tier == 2) return arb(3);
	if (_tier == 3) return arb(7);
	var _g = dig_to_arb(.36 * (_tier - 1));
	return do_multi(_g, arb(1 + (.26 + .08 * max(_tier - 2, 0)) * (_tier - 1)));
}
