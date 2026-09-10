/// @description tile_upg_config() - THE TILE UPGRADE ROSTER, as data.
///
/// >>> TO ADD ONE: add an entry. tile_upg prices it, tiles_sync applies
/// >>> it, and the tile room draws whatever is here.
///
/// FIELDS: id (the save key - never change one), name, base cost in
/// SHARDS, e (ORDERS OF MAGNITUDE the cost gains a level), fmt, help,
/// and optionally max (the level it stops at).
///
/// ⚖️ CUT TO TWO (his call, 2026-09-08). The roster was fabricator /
/// alloy quality / board size / hopper, tuned in tiles_twin against a
/// board that is not finalised - four knobs on a system whose feel is
/// still being decided is four things to re-tune every time the feel
/// changes. These two are the ones he wants to steer with while the
/// board settles: what it earns, and how fast it fills.
///
/// The retired ids (speed, luck, slots) are NOT reused. A save holding
/// levels in them keeps them harmlessly - tiles_sync simply stops
/// reading them, so the board falls back to its base shape rather than
/// to a level meaning something new.
///
/// "bank" CAME BACK (his call, 2026-09-09) and reusing that id is safe
/// for exactly one reason: TILES_LIVE was false until 2026-09-08, so no
/// savefile has ever held a tile upgrade level at all. It means the same
/// thing it always meant - tiles_sync has been reading upg.bank for
/// stored_max the whole time - so there is nothing to migrate and
/// nothing that could mean something new.
///
/// COST GROWTH IS +2.5 DECADES A LEVEL, on every row (his call). It was
/// x3 - about +0.48 decades - which the twin picked over 1.5 / 1.8 /
/// 2.2 / 2.6 because everything under it left the next purchase costing
/// well under an hour of current income. +2.5 is five times steeper
/// again, and the reasoning that made x3 the floor makes this safe at
/// the top: every effect here is LINEAR in the level (+10%, -0.1s, +1
/// tile, +20% rarity) while the price is geometric, so the only failure
/// mode a steeper curve can have is upgrades going UNREACHABLE - never
/// a runaway.
///
/// ⚠️ AND THAT IS THE THING TO WATCH. At +2.5 the tenth level of
/// anything costs ~1e28 shards. Whether the board's own income ever
/// reaches that is a question tiles_twin answers and this comment
/// cannot - run it before treating these numbers as settled.
///
/// The BASES are his and deliberately low - a knob you cannot reach
/// teaches nothing about how the board feels - so the multiplier is
/// carrying the whole brake. Run the twin before touching either.
function tile_upg_config() {
	if (variable_global_exists("tile_upg_cfg")) return g.tile_upg_cfg;
	g.tile_upg_cfg = [
		{
			id : "profit", name : "profit boost", base : 1000, e : 2.5,
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
			id : "fab", name : "fabrication speed", base : 10000, e : 2.5,
			max : (TILE_FAB_T - TILE_FAB_MIN) div TILE_FAB_STEP,
			fmt : function(_lv) {
				return string_format(
					max(TILE_FAB_MIN, TILE_FAB_T - TILE_FAB_STEP * _lv) / 60,
					1, 1) + "s";
			},
			help : "-0.1s off the fabricator, per level. the auto-merger "
			     + "rides the same clock, so this speeds both - it floors "
			     + "at " + string(TILE_FAB_MIN / 60) + "s",
		},
		{
			// ⚖️ RARITY IS A RATE, AND "20% OF WHAT" IS THE REAL
			// QUESTION. g.tile_rarity is a raw number fed to
			// calculate_rarity with an 800 cutoff, and each 800 raises
			// the distribution's whole window FLOOR - which is the only
			// quantity in the system a percentage can honestly be OF. So
			// a level is 20% of 800 = 160 rarity, and five levels lift
			// the floor by exactly one full tier. The fmt prints his
			// percentage; TILE_LUCK_STEP carries the mapping, and it is
			// the one number to change if that cutoff ever moves.
			//
			// The id is "luck", not "rarity", because tiles_sync has
			// ALWAYS written g.tile_rarity from upg.luck - the plumbing
			// predates this roster entry, and renaming a save key to
			// agree with a caption is rewiring working code for nothing.
			id : "luck", name : "tile rarity", base : 5000, e : 2.5,
			fmt : function(_lv) {
				return "+" + string(20 * _lv) + "%";
			},
			help : "+20% fabricator rarity, per level. it shifts the whole "
			     + "spawn distribution up, and every fifth level raises "
			     + "the floor a full tier - so fresh tiles start higher "
			     + "rather than merely varying more",
		},
		{
			// THE RESERVE, and the cheapest row on purpose: it is a
			// convenience, not a multiplier. It cannot earn a shard on
			// its own - it only stops the fabricator idling while the
			// board is full, and with the automerger running that is
			// rare. Pricing it beside the rows that DO compound would be
			// charging for the wrong thing.
			//
			// It is also the one row whose reward is a WHOLE UNIT rather
			// than a percentage, which is why 30 levels is a real cap
			// rather than a formality: +1 tile against +2.5 decades runs
			// out of meaning long before it runs out of arithmetic.
			id : "bank", name : "hopper", base : 2500, e : 2.5, max : 30,
			fmt : function(_lv) {
				return string(TILE_BANK_BASE + TILE_BANK_STEP * _lv);
			},
			help : "+" + string(TILE_BANK_STEP) + " tile of reserve, per "
			     + "level, to " + string(TILE_BANK_BASE + TILE_BANK_STEP * 30)
			     + ". with none, a tile finished while the board is full "
			     + "is lost - the reserve holds it until a slot opens",
		},
	];
	return g.tile_upg_cfg;
}
