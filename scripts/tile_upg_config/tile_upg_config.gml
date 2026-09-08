/// @description tile_upg_config() - THE TILE UPGRADE ROSTER, as data.
///
/// >>> TO ADD ONE: add an entry. tile_upg prices it, tiles_sync applies
/// >>> it, and the tile room draws whatever is here.
///
/// FIELDS: id (the save key - never change one), name, base cost in
/// SHARDS, mult (cost x this a level), help.
///
/// ⚖️ THE COSTS ARE TUNED IN datafiles/tiles_twin.py AND NOWHERE ELSE.
/// This is a closed positive-feedback loop - the table earns shards,
/// shards buy upgrades, upgrades make the table earn more - so the cost
/// curve is the only brake there is. The twin's first pass had bases in
/// the tens and multipliers under 2.5, and the table bought every
/// upgrade it could reach in SIX MINUTES. Shards accrue at tile_gps
/// rates, which reach hundreds a second within minutes and climb like
/// t^1.5, so the bases belong in the hundreds of thousands and the
/// multipliers above 3. Run the twin before touching a number here; it
/// prints HOLDS or FAILS and it has been wrong about this once already.
function tile_upg_config() {
	if (variable_global_exists("tile_upg_cfg")) return g.tile_upg_cfg;
	g.tile_upg_cfg = [
		{
			id : "speed", name : "fabricator", base : 500000, mult : 3.4,
			help : "a tile every " + string(TILE_SPEED_FACTOR * 100)
			     + "% of the time - and the auto-merger rides the same "
			     + "clock, so this speeds both",
		},
		{
			id : "luck", name : "alloy quality", base : 1200000, mult : 3.9,
			help : "+" + string(TILE_LUCK_STEP) + " fabricator luck. it "
			     + "shifts the whole spread up, and past each 800 the "
			     + "bottom tier stops spawning at all",
		},
		{
			id : "slots", name : "board size", base : 4000000, mult : 4.4,
			help : "+" + string(TILE_SLOT_STEP) + " slots. more room is "
			     + "more pairs in play, which is the merge rate itself",
		},
		{
			id : "bank", name : "hopper", base : 800000, mult : 3.6,
			help : "+" + string(TILE_BANK_STEP) + " banked tiles. at the "
			     + "cap the fabricator WAITS rather than losing output, "
			     + "so this is how long a full board can coast",
		},
	];
	return g.tile_upg_cfg;
}
