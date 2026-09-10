/// @description tile_dial_boost() - what the tile table is worth to the
/// DIALS, as a PACKED ARB multiplier (arb(1) = no boost).
///
/// ⚖️ MYRIAD DE'S REAL TILE MECHANIC (his ask, 2026-09-09: "the combined
/// tile additive contributed to a percentage boost to dial profit").
/// update_auto ends the dial payout with
///
///     if g.mod_gps > 0  give = do_multi(give, g.mod_gps - 2);
///
/// and that `- 2` is not a fudge, it is the arb encoding doing division.
/// arb() packs a value as (digits - 1) + value/10^digits, so subtracting
/// 2 from the exponent divides by 100 - and get_allmodgps builds mod_gps
/// as (the board's summed output + 100). The whole line therefore reads:
///
///     dial payout x (1 + board total / 100)
///
/// A hundred points of tile output doubles what every dial pays. THAT is
/// what the tile table is for in DE: it is not a side currency, it is a
/// multiplier on the main game, and the board is how you raise it.
///
/// ⚖️ DISGUISED AS AN UPGRADE, which is also DE's (his word). DE has
/// u_moduleboost scaling the board's total BEFORE it becomes the boost -
/// get_allmodgps does the multiply, so the upgrade is worth more the
/// bigger the board already is. The tile roster's "profit boost" is that
/// upgrade now. It reads as "+10% board output" and it is really "+10%
/// of a number that multiplies your entire dial income", which is why it
/// can be priced far above what it appears to give.
///
/// ⚖️ AND WHY THE COST MUST OUTRUN IT (his point). The board's total
/// climbs every second on its own - the merge loop is exponential in
/// tier - so this boost grows without anyone buying anything. The
/// upgrade on top of it cannot be priced against its own increment; it
/// has to be priced against the whole compounding lane it sits in, which
/// is what +2.5 decades a level is for. See tile_upg_config.
///
/// ⚖️ IT STAYS IN ARB, unlike my first draft. Coming out through unarb()
/// to do the arithmetic in plain reals reads easier and dies at 1e308 -
/// and this is a number whose entire job is to become enormous. DE never
/// leaves arb here either, for exactly that reason.
function tile_dial_boost() {
	if (!TILES_LIVE) return arb(1);
	if (!variable_global_exists("tiles")) return arb(1);

	var _t = g.tiles;
	if (!(_t.gps >= arb(1))) return arb(1);   // an empty board boosts nothing

	// the upgrade multiplies the CONTRIBUTION, DE's order - so a level
	// is worth more the bigger the board already is
	var _lv = _t.upg[$ "profit"] ?? 0;
	var _c = (_lv > 0) ? do_scale(_t.gps, 1 + TILE_PROFIT_STEP * _lv) : _t.gps;

	// + the divisor, then shift the packed exponent down by its digit
	// count. TILE_DIAL_DIV is 100 and TILE_DIAL_SHIFT is its 2 - one
	// number said twice, and the macro says so, because getting the pair
	// out of step would silently rescale every dial in the game.
	return do_add(_c, arb(TILE_DIAL_DIV)) - TILE_DIAL_SHIFT;
}
