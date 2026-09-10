/// @description tile_rebirth_boost() - the permanent multiplier the
/// table's own rebirths have bought, as a plain real (1 = none).
///
/// ⚖️ THE TABLE HAS ITS OWN PRESTIGE (his ask, 2026-09-09: "a separate
/// rebirth for the tiles based off its earned currency... resetting
/// increases the output of the tiles"). It is deliberately NOT the
/// game's rebirth wearing a hat: that one prices off PROFIT HELD and
/// resets the run, this one prices off SHARDS EARNED and resets only
/// the board. They can be sitting at completely different points and
/// neither cares, which is the whole reason to have two.
///
/// Applied to the board's OUTPUT in tiles_tick, which means it reaches
/// both things output feeds - the shard income that buys tile upgrades,
/// and the contribution to dial profit (tile_dial_boost). One
/// multiplier, both lanes, because "the output of the tiles" is one
/// quantity and splitting it would be inventing a distinction the
/// player was never told about.
function tile_rebirth_boost() {
	if (!variable_global_exists("tiles")) return 1;
	var _u = g.tiles[$ "rb_units"] ?? 0;
	if (_u <= 0) return 1;
	return 1 + TILE_RB_STEP * _u;
}
