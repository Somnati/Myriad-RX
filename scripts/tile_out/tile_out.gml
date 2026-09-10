/// @description tile_out(tier) - what ONE tile of this tier pays a
/// second, LIVE: tile_gps(tier) x the flux boost, floored to a whole
/// shard. A packed arb.
///
/// ⚖️ THE FLUX SHOWS ON THE TILE (his ask, 2026-09-10: "flux output to
/// also reflect on the tiles and their output p/s... rounded down").
/// tile_gps is the tier's BASE - the ladder the twin is tuned on and
/// the upgrade prices are solved against - and it must stay that. This
/// is the number the player actually sees: the face of the tile, the
/// board's +N/s, and, because the tick sums THESE, the shards that
/// land. One function so the three cannot disagree: a tile that reads
/// +2 pays 2, and two of them read +4/s.
///
/// FLOORED PER TILE, not on the total. x2.35 on a tier-1 tile is 2.35
/// shards a second and a tile cannot show that, so it shows 2 and pays
/// 2 - the honest reading of "rounded down". Flooring the total
/// instead would let the faces add up to less than the rate beside
/// them. The fraction the floor drops is the cost of a face you can
/// read; a boost worth having is worth whole shards on a tier-1 tile
/// within a few rebirths anyway.
///
/// THE FLOOR IS DONE IN PLAIN REALS below 1e12, deliberately.
/// do_scale packs through log space and 2 x 1.5 comes back as
/// 2.9999999999999996; do_floor on that is 2, and the tile lies by a
/// shard. So the product is taken as a real, nudged past its own dust,
/// floored, and packed exactly. Past 1e12 a whole shard is below the
/// mantissa's notice and the floor is moot - the log-space product is
/// returned as it is.
function tile_out(_tier) {
	var _g = tile_gps(_tier);
	var _b = tile_rebirth_boost();
	if (_b <= 1) return _g;
	var _lg = arb_log10(_g) + log10(_b);
	if (_lg >= 12) return log_to_arb(_lg);
	return arb(floor(power(10, _lg) + .000001));
}
