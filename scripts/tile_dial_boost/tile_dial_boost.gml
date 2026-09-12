/// @description tile_dial_boost([lv]) - what the tile table is worth to
/// the DIALS, as a PACKED ARB multiplier (arb(1) = no boost).
/// @param [lv]  a profit-upgrade level to quote INSTEAD of the one held
///              (the drawer's "now > next" readout). Omit for the live one.
///
/// ⚖️ MYRIAD DE'S REAL TILE MECHANIC, PORTED INTO THE UPGRADE (his ask,
/// 2026-09-09, restated the same day when my first port kept DE's
/// shape: "i didnt want dials to have the bonus from the combined tile
/// amount like DE... instead i wanted that mechanic ported to the profit
/// upgrade"). In DE, update_auto ends the dial payout with
///
///     if g.mod_gps > 0  give = do_multi(give, g.mod_gps - 2);
///
/// where the `- 2` is the arb encoding doing division: arb() packs a
/// value as (digits - 1) + value/10^digits, so subtracting 2 from the
/// exponent divides by 100, and get_allmodgps builds mod_gps as (the
/// board's summed output + 100). The line reads
///
///     dial payout x (1 + board total / 100)
///
/// and every DE player got it for free the moment a tile existed. That
/// is the part he did NOT want. Here the chain is the same but the
/// board's share of it is GATED BY THE UPGRADE:
///
///     dial payout x (1 + board total x f(level) / 100),   f(0) = 0
///
/// so an unbought upgrade is an unconnected board - the tiles pay
/// shards and nothing else - and the first level is what wires the
/// table into the main game. It reads as a profit upgrade, and it IS
/// one; it just happens to be the whole mechanic.
///
/// ⚖️ f COMPOUNDS: (1 + STEP)^level - 1, not STEP x level. His point
/// (message on the +25%): the board's total is exponential in tier and
/// climbs by itself, so a linear share "falls off quickly" - fifty
/// linear levels are x13.5 of the board, which the merge loop delivers
/// on its own inside an afternoon. Compounding gives each level the
/// same PROPORTIONAL bite of the level before it, and fifty of them are
/// ~x70,000 - still small against the board's own growth, which is the
/// right size for a purchased multiplier on a lane that grows for free.
/// TILE_PROFIT_STEP is the ratio, and he said the exact figure is not
/// the point; the shape is.
///
/// ⚖️ AND WHY THE COST MUST OUTRUN IT (his point). The board's total
/// climbs every second on its own, so this boost grows without anyone
/// buying anything past level 1. The upgrade cannot be priced against
/// its own increment; it is priced against the whole compounding lane
/// it sits in - the curve to 1e308 plus the modelled flux inflation in
/// tile_upg. See tile_upg_config.
///
/// ⚖️ IT STAYS IN ARB. Coming out through unarb() to do the arithmetic
/// in plain reals reads easier and dies at 1e308 - and this is a number
/// whose entire job is to become enormous. DE never leaves arb here
/// either, for exactly that reason. The share f is a plain real (it
/// tops out near 1e5), and do_scale carries it into the packed value in
/// log space, fractions included.
function tile_dial_boost(_lv = undefined) {
	if (!TILES_LIVE) return arb(1);
	if (!variable_global_exists("tiles")) return arb(1);
	// THE REPLAY'S MEAN (offline_replay, 2026-09-10): while an absence
	// is being paid, the boost is the logarithmic mean of the board you
	// left and the board you came back to - set there, cleared there.
	// A quote for a specific level (the drawer's now > next) ignores it.
	if (_lv == undefined && variable_global_exists("tile_boost_override")
	&& g.tile_boost_override != undefined) return g.tile_boost_override;

	var _t = g.tiles;
	if (_lv == undefined) _lv = _t.fupg[$ "profit"] ?? 0;   // the flux ladder's, permanent (2026-09-12)
	if (_lv <= 0) return arb(1);              // unbought: the board is not wired in
	if (!(_t.gps >= arb(1))) return arb(1);   // an empty board boosts nothing

	// the board's share, compounding per level - see the header. A
	// share under 1 (level 1 is .25) is exactly what do_scale exists
	// for; a contribution that would fall under one whole unit is noise
	// and clamps to arb(1), which the divisor then makes a rounding
	// error rather than a boost.
	var _f = power(1 + TILE_PROFIT_STEP, _lv) - 1;
	var _c = do_scale(_t.gps, _f);

	// + the divisor, then shift the packed exponent down by its digit
	// count. TILE_DIAL_DIV is 100 and TILE_DIAL_SHIFT is its 2 - one
	// number said twice, and the macro says so, because getting the pair
	// out of step would silently rescale every dial in the game.
	return do_add(_c, arb(TILE_DIAL_DIV)) - TILE_DIAL_SHIFT;
}
