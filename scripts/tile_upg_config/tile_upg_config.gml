/// @description tile_upg_config() - THE TILE UPGRADE ROSTER, as data.
///
/// >>> TO ADD ONE: add an entry. tile_upg prices it, tiles_sync applies
/// >>> it, and the tile room draws whatever is here.
///
/// FIELDS: id (the save key - never change one), name, base cost in
/// SHARDS, mult (cost x this a level), help.
///
/// ⚖️ CUT TO TWO (his call, 2026-09-08). The roster was fabricator /
/// alloy quality / board size / hopper, tuned in tiles_twin against a
/// board that is not finalised - four knobs on a system whose feel is
/// still being decided is four things to re-tune every time the feel
/// changes. These two are the ones he wants to steer with while the
/// board settles: what it earns, and how fast it fills.
///
/// The retired ids (speed, luck, slots, bank) are NOT reused. A save
/// holding levels in them keeps them harmlessly - tiles_sync simply
/// stops reading them, so the board falls back to its base shape rather
/// than to a level meaning something new.
///
/// COST GROWTH IS x3 A LEVEL, and the twin picked it rather than I did.
/// Both effects are LINEAR in the level (+10% each, -0.1s each) against
/// a geometric price, which made x1.5 look obviously safe - it is not.
/// The LOOP compounds even when the effect does not: more shards buy
/// more upgrades which earn more shards. tiles_twin swept 1.5 / 1.8 /
/// 2.2 / 2.6 / 3.0 and everything under 3 left the next purchase costing
/// well under an hour of current income, which is a formality rather
/// than a decision. x3 is the first that holds all five invariants.
///
/// The BASES are his and deliberately low - a knob you cannot reach
/// teaches nothing about how the board feels - so the multiplier is
/// carrying the whole brake. Run the twin before touching either.
function tile_upg_config() {
	if (variable_global_exists("tile_upg_cfg")) return g.tile_upg_cfg;
	g.tile_upg_cfg = [
		{
			id : "profit", name : "profit boost", base : 1000, mult : 3,
			// WHAT A LEVEL IS WORTH, as a string (his ask: show the
			// current bonus and what the next buy gains). It lives here
			// because only the roster knows an upgrade's units - the
			// drawer just prints fmt(lv) and fmt(lv + 1) and stays
			// ignorant of percentages and seconds alike.
			fmt : function(_lv) {
				return "+" + string(round(TILE_PROFIT_STEP * 100 * _lv)) + "%";
			},
			help : "+10% shards a second, per level. it multiplies what "
			     + "the whole board earns, so it is worth more the more "
			     + "tiles are on it",
		},
		{
			id : "fab", name : "fabrication speed", base : 10000, mult : 3,
			fmt : function(_lv) {
				return string_format(
					max(TILE_FAB_MIN, TILE_FAB_T - TILE_FAB_STEP * _lv) / 60,
					1, 1) + "s";
			},
			help : "-0.1s off the fabricator, per level. the auto-merger "
			     + "rides the same clock, so this speeds both - it floors "
			     + "at " + string(TILE_FAB_MIN / 60) + "s",
		},
	];
	return g.tile_upg_cfg;
}
