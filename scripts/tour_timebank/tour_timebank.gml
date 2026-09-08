/// tour_timebank - THE TIME BANK  (game/timebank)
/// A TOUR SCRIPT: comments only, nothing runs.

// ========================== THE IDEA ================================
// Ported from Techdemo II, where it replaced the offline system. In RX
// it does NOT replace anything - it is the HYBRID his design settled
// on. While you are away, production RUNS exactly as it always did
// (offline_replay pays every dial for the whole absence), and the bank
// accrues ON TOP.
//
// What the bank buys is not catch-up. It is SPEED: a multiplier you
// engage deliberately, which makes the live game simulate faster and
// spends banked seconds to do it. Being away earns you the right to
// play fast later.
//
// THE INVARIANT, and everything else follows from it: BANKED MINUTES
// PER REAL HOUR STAY UNDER 60. The conversion factor is always below 1
// - five minutes an hour by default, forty at the tuned ceiling, and a
// hard 55 above that no matter how the knobs are set. An hour away can
// never bank an hour of play. Rate upgrades raise availability; they
// cannot break causality.
//
// It double-counts on purpose (the absence pays as production AND
// banks), and that is safe precisely because of the invariant.

// ========================== THE FILES ===============================
//   timebank_init    g.timebank: bank / cap_lv / rate_lv / spd. THE
//                    WHOLE SAVED STATE - the cap and the rate DERIVE.
//   timebank_rate    banked seconds per away second. Holds the invariant.
//   timebank_cap     the ceiling, in seconds. Past it, away time is LOST
//                    rather than queued - which is what stops a month
//                    away arriving as a month of x10, and what makes the
//                    capacity upgrade worth buying.
//   timebank_add     THE ONE banking site. offline_replay calls it as it
//                    measures the absence, so a suspend and a closed app
//                    come through one door and neither double-counts.
//   timebank_spend   THE ONE spending site, once a frame from
//                    syst_production, BEFORE anything ticks.
//   timebank_upg     the two purchases, priced in PROFIT.
//   syst_rm_timebank rm_timebank, [time bank] on the menu. A view.
//   syst_timebank    the cockpit chip - the burn indicator.

// ======================= THE LAWS THAT MATTER =======================
//
//   ONE CODE PATH FOR LIVE AND OFFLINE. timebank_spend hands its
//   seconds to prod_dials and credit_tick - the SAME lanes
//   offline_replay drives. So x10 for a minute is, by construction, the
//   replay of ten minutes. There is no second formula that could drift,
//   and there never can be one, because the acceleration IS the budget
//   the offline path already takes.
//
//   DELIBERATELY NOT MULTIPLIED: anything on the wall clock, render and
//   delta, and the REBIRTH RUN CLOCK. That last one matters - the
//   timeclamp measures the PLAYER'S attention, not the simulation's, and
//   letting banked time accelerate it would sell a way past the penalty
//   the clamp exists to impose.
//
//   THE BANK EMPTIES ITSELF HONESTLY. timebank_spend pays out whatever
//   is left on the last frame and then settles at x1, rather than
//   stopping a frame early and stranding a sliver the player bought.
//
//   SURVIVES REBIRTH, dies with a new game. Meta, like credits and
//   upgrades: rebirth_do never touches g.timebank, game_reset wipes it.

// ============================ TRAPS =================================
//   - The knobs live in setgame's Create (g.tb_*), beside the credit
//     knobs. timebank_cap and timebank_rate read them, so anything that
//     calls those before setgame has run will fail loudly - which is
//     the right failure. Do not paper over it with defaults in two
//     places.
//   - g.tb_rate_cap is a TUNING ceiling. The 55 inside timebank_rate is
//     the LAW. Never raise the law to match a knob.
//   - The bank is a plain real in seconds, not an arb. Thirty days is
//     2.6 million; a float carries that with room to spare, and arb
//     cannot represent the sub-1 values a partial frame produces.
