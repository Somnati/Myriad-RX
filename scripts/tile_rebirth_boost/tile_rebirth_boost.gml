/// @description tile_rebirth_boost() - the multiplier the table's held
/// FLUX puts on its output, as a plain real (1 = none).
///
/// ⚖️ FLUX AFFECTS OUTPUT DIRECTLY (his spec) - and "directly" has to
/// be read with a brake, because flux is proportional to earned and
/// earned is proportional to output. A LINEAR read - output x (1 +
/// flux/k) - closes that loop into a runaway: each run earns more,
/// pays more flux, multiplies the next run more, forever, and the
/// arithmetic never hits a wall the player can feel. The house answer
/// to exactly this is ngu_bonus's diminishing law, and it is what this
/// does: the boost rides flux to a POWER under 1. TILE_FLUX_POW .5
/// means doubling your flux is worth x1.41, not x2 - still direct, still
/// monotonic, still a pile you watch grow, but a pile whose next
/// thousand is worth less than its first.
///
/// Applied to the board's OUTPUT in tiles_tick, so it reaches both
/// lanes output feeds: the shard income that buys upgrades, and the
/// board's contribution to dial profit. One multiplier, both lanes,
/// because "the output of the tiles" is one quantity.
function tile_rebirth_boost() {
	if (!variable_global_exists("tiles")) return 1;
	var _f = g.tiles[$ "flux"] ?? 0;
	if (_f <= 0) return 1;
	return 1 + TILE_FLUX_STEP * power(_f, TILE_FLUX_POW);
}
