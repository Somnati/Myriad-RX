/// @description tile_flux_config() - THE FLUX LADDER: the table's
/// permanent shop (his design, 2026-09-12 - "splitting it up").
///
/// THE SPLIT: shards buy the board's ENGINE (tile_upg_config - the
/// fabricator, the slots, the rarity, the hopper, the merges) and a
/// table rebirth wipes it: that is run progress, and losing it is what
/// a reset costs. Flux buys the table's EXPORT - what the rest of the
/// game feels - and it is PERMANENT: the dial profit boost lives here
/// now, with a slot that survives resets and a rarity floor beside it.
/// A reset can never take these, so the reset's timing is a real
/// decision (has this board flattened?) rather than "always at the
/// start, before you have bought the boost".
///
/// AND HELD FLUX STILL PAYS +1% A POINT (his call: "subtle growth", and
/// the decision it makes - "do I buy the upgrade and lose tile
/// strength?"). Spending flux here lowers the pile tile_rebirth_boost
/// reads, so every rung on this ladder is bought out of the table's own
/// output. Units and flux: the same shape, a different flavour - the
/// table is an idle game inside the idle game.
///
/// A row: id (the fupg key), name, base flux, curve (x per level), max,
/// fmt(lv) for the bar, help. Prices are plain reals - flux is
/// earned / 1e8, a number a person can hold in their head.
function tile_flux_config() {
	static _cfg = [
		{
			// the export itself. Level 1 wires the table into the dials
			// (nothing at 0 - tile_dial_boost); each level after
			// compounds the board's share by TILE_PROFIT_STEP
			id : "profit", name : "dial profit boost", base : 1, curve : 1.6, max : 50,
			fmt : function(_lv) {
				var _b = tile_dial_boost(_lv);
				var _lg = arb_log10(_b);
				return "x" + ((_lg < 3) ? string_format(power(10, _lg), 1, 2) : crunch_arb(_b));
			},
			help : "wires the tile table into dial profit - permanent, a reset never "
			     + "touches it. each level compounds +" + string(round(TILE_PROFIT_STEP * 100))
			     + "% of the board's output into a multiplier on every dial",
		},
		{
			id : "slots", name : "permanent slots", base : 8, curve : 2, max : 4,
			fmt : function(_lv) { return "+" + string(_lv) + " slot" + ((_lv == 1) ? "" : "s"); },
			help : "a slot the table keeps through every reset, on top of the base board",
		},
		{
			id : "rarity", name : "rarity floor", base : 4, curve : 1.8, max : 10,
			fmt : function(_lv) { return "+" + string(TILE_FLUX_RAR * _lv) + " rate"; },
			help : "+" + string(TILE_FLUX_RAR) + " fabricator rarity rate a level, permanent - "
			     + "added before the shard row multiplies it",
		},
	];
	return _cfg;
}
