/// @description tile_upg_config() - THE TILE UPGRADE ROSTER, as data.
///
/// >>> TO ADD ONE: add an entry. tile_upg prices it, tiles_sync applies
/// >>> it, and the tile room draws whatever is here.
///
/// FIELDS: id (the save key - never change one), name, base cost in
/// SHARDS, fmt, help, max (the level the price reaches the ceiling),
/// and the pricing shape: curve + top - the cost accelerates from base
/// to 10^top across the whole ladder. tile_upg still accepts a straight
/// `e` for a row that wants one; none does today.
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
		// (the dial profit boost moved to the FLUX LADDER - tile_flux_config,
		// 2026-09-12: the table's export is permanent now, and the reset
		// wipes only the engine below)
		{
			// ⚖️ CURVED, NOT STRAIGHT (his ask: start small and rise to
			// the ceiling, so more levels fit early and they slow down
			// approaching it). The straight version put six decades on
			// every rung, which meant the SECOND level already cost 1e10
			// and the fabricator simply fell out of the first day - it
			// was a fifty-rung ladder whose first half nobody would ever
			// climb.
			//
			// The curve spends the same 304 decades unevenly: level 5
			// costs 1e7, level 10 costs 1e16, level 20 costs 1e53, and
			// the fiftieth still lands on the 1e308 he named. Early
			// seconds are affordable, late ones are the endgame, and the
			// budget is untouched - it is the same -5.0s either way.
			//
			// TILE_UPG_CURVE is the shape, shared by the whole roster now:
			// 1 would be the old straight line, 2 puts a quarter of the
			// levels inside a hundredth of the span, 3 makes the first
			// ten nearly free.
			id : "fab", name : "fabrication speed", base : 10000,
			curve : TILE_UPG_CURVE, top : TILE_FAB_TOP,
			max : TILE_FAB_CAP div TILE_FAB_STEP,
			fmt : function(_lv) {
				return string_format(
					max(TILE_FAB_MIN, TILE_FAB_T - TILE_FAB_STEP * _lv) / 60,
					1, 1) + "s";
			},
			help : "-" + string_format(TILE_FAB_STEP / 60, 1, 2) + "s off the "
			     + "fabricator, per level, to -"
			     + string_format(TILE_FAB_CAP / 60, 1, 1) + "s. the "
			     + "auto-merger rides the same clock, so this speeds both",
		},
		{
			// ⚖️ A MULTIPLIER ON THE RATE, which is DE's own answer (his
			// correction: check DE - it has an upgrade by this exact
			// name). indiv.gml ends its rarity chain with
			//     mod_rarity_rate *= 1 + (u_rarityrate / 100)
			// off a base of 100, so the percentage multiplies the whole
			// accumulated rate rather than adding to it. tile_rarity_rate
			// is that chain, in that order; TILE_RARITY_STEP is the 20.
			//
			// My first pass read "+20%" as a share of the 800 cutoff and
			// added a flat 160 a level. That is a fair reading of the
			// words and the wrong reading of the game - and it could
			// never have worked as a multiply either, because RX based
			// this rate at 0 and x1.2 of nothing is nothing. DE's 100 is
			// what makes a percentage upgrade possible at all.
			//
			// ⚖️ THE WORD IS RARITY, NOT LUCK (his correction). The key
			// was "luck" because tiles_sync had always driven this from
			// upg.luck, and I kept it rather than rewire working code
			// for a caption. That was the wrong call for a reason I did
			// not know: LUCK IS ITS OWN STAT IN DE - g.luck_mod, a
			// separate number doing a separate job - so the borrowed
			// name was not just imprecise, it was reserved. Renaming the
			// save key is free here because he reset the tile levels
			// this session and nothing else has ever held one.
			// sixty rungs to the ceiling: coarser than profit on purpose,
			// because each one is +50% of a rate whose thresholds are
			// 400 apart - a rarity level is a bigger event than a profit
			// level and should be spaced like one
			id : "rarity", name : "tile rarity", base : 5000,
			curve : TILE_UPG_CURVE, top : 308, max : 60,
			fmt : function(_lv) {
				return "+" + string(TILE_RARITY_STEP * _lv) + "%";
			},
			help : "+" + string(TILE_RARITY_STEP) + "% fabricator rarity, "
			     + "per level - a multiplier on the whole rate, so it "
			     + "compounds with anything else raising it. every "
			     + string(TILE_RARITY_CUT) + " of rate lifts the spawn "
			     + "floor a full tier, so fresh tiles start higher rather "
			     + "than merely varying more",
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
			// top 150, NOT 308: the hopper is a convenience and its last
			// tile should be a mid-game purchase, not the last thing in
			// the game. Thirty rungs to 1e150 still curves the same way.
			// base x10 (his call: pricier early). The curve is untouched
			// - the same thirty rungs to the same 1e150 - so only the
			// FLOOR moved, and a first hopper tile now costs what a
			// fourth profit level does rather than a second.
			id : "bank", name : "hopper", base : 25000,
			curve : TILE_UPG_CURVE, top : 150, max : 30,
			fmt : function(_lv) {
				return string(TILE_BANK_BASE + TILE_BANK_STEP * _lv);
			},
			help : "+" + string(TILE_BANK_STEP) + " tile of reserve, per "
			     + "level, to " + string(TILE_BANK_BASE + TILE_BANK_STEP * 30)
			     + ". with none, a tile finished while the board is full "
			     + "is lost - the reserve holds it until a slot opens",
		},
		{
			// ⚖️ THE BOARD ITSELF (his spec, 2026-09-10: "default 12
			// slots, the first 4 slot upgrades affordable before 100m,
			// then the typical cost curve, capping at 32 total by e308").
			// The first four are HAND-PRICED - a decade apart, the fourth
			// at 10m - so the table grows to the sixteen it used to start
			// with inside the first session; from the fifth the shared
			// curve takes over and runs from that 10m to e308 at the last
			// buy (tile_upg's `pre` lane), so a 32-slot table is the
			// endgame's, not the afternoon's. The cap derives from the
			// three macros: the row can never quote a slot the board
			// would not lay out.
			//
			// It is the one row whose value is a whole unit of BOARD
			// rather than a rate - more tiles paying at once, more pairs
			// for the automerger, a longer fabricator queue before the
			// hopper matters - which is why it earns a curve of its own
			// opening rather than the hopper's low flat base.
			id : "slots", name : "tile slots", base : 10000,
			pre : [10000, 100000, 1000000, 10000000],
			curve : TILE_UPG_CURVE, top : 308,
			max : (TILE_SLOTS_MAX - TILE_SLOTS_BASE) div TILE_SLOT_STEP,
			fmt : function(_lv) {
				return string(TILE_SLOTS_BASE + TILE_SLOT_STEP * _lv);
			},
			help : "+" + string(TILE_SLOT_STEP) + " slot on the board, per "
			     + "level, to " + string(TILE_SLOTS_MAX) + ". more room is "
			     + "more tiles paying at once, and more pairs for the "
			     + "automerger to find",
		},
		{
			// ⚖️ THE TWO CHANCE ROWS (his spec, 2026-09-10): duplication
			// and tier up share one law - 1% at level 0, +1% a level,
			// 50% at the cap, e308 at the cap - see tile_chance_rate.
			// Priced on the shared curve like fab and rarity: a chance
			// is a multiplier on the whole fabricator (or on every
			// merge), but a slow one - +1% a level is a nudge, and 49
			// nudges to the ceiling is the fab row's shape exactly.
			// The cap is DERIVED from the three macros so the row can
			// never quote a level the rate would clamp.
			id : "dup", name : "duplication", base : 50000,
			curve : TILE_UPG_CURVE, top : 308,
			max : (TILE_CHANCE_CAP - TILE_CHANCE_BASE) div TILE_CHANCE_STEP,
			fmt : function(_lv) {
				return string(min(TILE_CHANCE_CAP,
					TILE_CHANCE_BASE + TILE_CHANCE_STEP * _lv)) + "%";
			},
			help : "the chance a tile the fabricator finishes comes out "
			     + "as two. " + string(TILE_CHANCE_BASE) + "% to start, +"
			     + string(TILE_CHANCE_STEP) + "% a level, to "
			     + string(TILE_CHANCE_CAP) + "%. the second tile needs "
			     + "room - a full board and hopper drop it",
		},
		{
			id : "tierup", name : "tier up", base : 50000,
			curve : TILE_UPG_CURVE, top : 308,
			max : (TILE_CHANCE_CAP - TILE_CHANCE_BASE) div TILE_CHANCE_STEP,
			fmt : function(_lv) {
				return string(min(TILE_CHANCE_CAP,
					TILE_CHANCE_BASE + TILE_CHANCE_STEP * _lv)) + "%";
			},
			help : "the chance a merge climbs one tier further than it "
			     + "should. " + string(TILE_CHANCE_BASE) + "% to start, +"
			     + string(TILE_CHANCE_STEP) + "% a level, to "
			     + string(TILE_CHANCE_CAP) + "%. the automerger rolls it "
			     + "too",
		},
	];
	return g.tile_upg_cfg;
}
