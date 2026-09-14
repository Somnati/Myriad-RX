/// @description tile_chance_rate(id) - the live PERCENT chance one of
/// the table's two chance upgrades gives: "dup" (a finished tile spawns
/// another) or "tierup" (a merge climbs an extra tier).
/// @param id  "dup" / "tierup"
///
/// ⚖️ TWO UPGRADES, ONE LAW (his spec, 2026-09-10): "start out at 1% and
/// climb by 1% per upgrade capping at 50% by e308" - and tier up "does
/// the same thing as the duplication regarding bonus/cost". So they
/// share the three macros and this one reader, and their roster rows
/// differ only in id, name and what the chance is rolled against:
///
///   chance = TILE_CHANCE_BASE + TILE_CHANCE_STEP x level, in percent
///   levels = (TILE_CHANCE_CAP - TILE_CHANCE_BASE) / TILE_CHANCE_STEP
///
/// 1 + 1 x 49 = 50. The 1% at level 0 is his "start out at 1%": an
/// unbought upgrade already trickles, so the first time a second tile
/// drops out of the fabricator - or a merge jumps two tiers - is a
/// thing the player SEES before they can buy it, and the row explains
/// what they saw. That is a better tutorial than help text.
///
/// WHERE THEY ROLL: tiles_tick's fabricator (dup) and tiles_merge
/// (tierup) - both the manual merge and the automerger go through
/// tiles_merge, so one roll site covers both. tiles_fastforward rolls
/// the same rates over its bulk counts, so offline == online.
function tile_chance_rate(_id) {
	if (!variable_global_exists("tiles")) return TILE_CHANCE_BASE;
	var _lv = g.tiles.upg[$ _id] ?? 0;
	var _r = min(TILE_CHANCE_CAP, TILE_CHANCE_BASE + TILE_CHANCE_STEP * _lv);
	// THE DECK (DE's, 2026-09-13), on top of the capped upgrade: duplicator
	// / + (+15 / +20 points), tier merger / + / ++ (+5 / +5 / +8 points)
	if (_id == "dup") {
		if (abi_on("ad_duplicator"))  _r += 15;
		if (abi_on("ad_duplicator2")) _r += 20;
	} else if (_id == "tierup") {
		if (abi_on("ad_tiermerger1")) _r += 5;
		if (abi_on("ad_tiermerger2")) _r += 5;
		if (abi_on("ad_tiermerger3")) _r += 8;
	}
	return _r;
}
