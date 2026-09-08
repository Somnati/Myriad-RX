/// tour_upgrades - UPGRADES  (game/upgrades)
/// A TOUR SCRIPT: comments only, nothing runs.

// ========================== THE IDEA ================================
// Credits buy upgrades. That sentence was already written in
// tour_credits, in the future tense, while credits accumulated with
// nothing at all to spend them on - this is the other half.
//
// It is NOT a shop. Myriad DE's model, kept because it is the best idea
// in their version: SLOTS ARE SCARCE, and each slot holds one ROLLED
// offer that you can keep LEVELLING. Buying raises its tier and its
// price; selling refunds part of what went in and frees the slot for a
// different roll. A slot is therefore a standing investment with a real
// sunk cost - which is a decision. A list of everything at a fixed
// price is a chore you work down.
//
// You start with 3 slots and can buy up to 8.

// ========================== THE FILES ===============================
//   upgrade_config     EDIT HERE, and only here, to add an upgrade.
//                      One entry: id / name / stat / value band / tier
//                      cap / base cost / colour / help / avail.
//                      DE spread each upgrade across FOUR files - the
//                      roster, a 25-branch `if name = "..."` chain in
//                      buy_upgrade, the display, and an accumulator
//                      reset - where a typo in any one string silently
//                      did nothing.
//   upgrade_init       g.upg: the slots, how many extra were bought,
//                      lifetime totals. THE WHOLE SAVED STATE.
//   upgrade_bonus      THE ONE READ POINT. Walks the slots and returns
//                      every accumulator fresh.
//   upgrade_roll       fills an empty slot: an available kind, a
//                      weighted rarity, a value rolled in the band.
//   upgrade_buy/_sell  the two transactions.
//   upgrade_cost       DE's curve: base x rarity x (1 + (.2+.1t)*t).
//   upgrade_sell_value re-derives what was PAID from that same curve
//                      and returns a fraction of it, so the refund can
//                      never quote a price that no longer exists.
//   upgrade_cap        rarity widens the tier ceiling as well as the
//                      value, so a good roll is deeper AND stronger.
//   upgrade_diff_mult  THE DIFFICULTY SEAT - see below.
//   syst_upgrades      the screen. One row per slot, ONE LINE each; a
//                      row is EMPTY, an OFFER (tier 0) or OWNED
//                      (tier 1+), and it has ONE button whose meaning
//                      comes from the [buy]/[sell] toggle above.
//                      His call, and DE's shape: a buy AND a sell
//                      button on every line is two controls competing
//                      for the same glance on eight rows, and the
//                      second is used once an hour. The toggle moves
//                      that decision up a level - the row does one
//                      thing, and the rare action is a mode you enter
//                      deliberately rather than a button beside the one
//                      you meant to press.
//   upgrade_bonus_live THE GATE. Every consumer reads this, and it
//                      returns zeros while UPG_LIVE is false.

// ======================= THE LAWS THAT MATTER =======================
//
//   WIRED, NOT LIVE, while the screen is being polished (his call).
//   UPG_LIVE in main_macros is the whole switch: every consumer seat
//   reads upgrade_bonus_live(), which returns a zeroed struct while it
//   is false, so the seats stay written and reviewed and the economy is
//   untouched. upgrade_bonus() itself stays truthful - the screen and
//   the statistics page read that, so you can see exactly what the
//   slots WOULD be doing, and the screen says out loud that they are
//   not doing it.
//
//   DERIVED, NEVER ACCUMULATED. A slot stores id / rarity / value /
//   tier and nothing else; every effective number comes from
//   upgrade_bonus at read time. DE does `g.u_tapprofit += val` inside
//   buy_upgrade instead, so its live numbers depend on the HISTORY of
//   purchases. Three things follow from deriving that do not follow
//   from accumulating:
//     - selling is a plain deletion, with no accumulator to unwind
//     - rebalancing a value reaches saves that already exist
//     - a bug in one purchase cannot corrupt the total permanently
//   This is the same law the dials follow, and the one place DE breaks
//   it.
//
//   RESULT-SIDE, ALWAYS. Every consumer multiplies the number it just
//   derived, never the inputs it derived it from. Fold a bonus into a
//   stored level or a base stat and it compounds with itself on the
//   next resync. The seats: update_click (tap), update_dial (dial
//   profit and speed), dial_cost (the discount, applied LAST so it
//   reduces the milestone premium too), credit_tick (refill),
//   obj_clicker (crit chance and payout, credit luck), rebirth_calc
//   (units, AFTER the timeclamp - before it, an upgrade would buy back
//   the penalty the clamp exists to impose).
//
//   GRANTS ARE NOT MODIFIERS. "another slot" changes state once and
//   consumes itself; it has no accumulator and cannot be re-derived.
//   Mixing the two kinds is what forces DE's effects to be
//   incremental, so they are kept apart here - `stat : ""` marks one.
//
//   SURVIVES REBIRTH, dies with a new game. Credits and upgrades are
//   the PRESENCE layer - earned by being here and tapping - running
//   parallel to rebirth's PROGRESS layer. game_reset wipes it;
//   rebirth_do never touches it.
//
//   AVAILABILITY IS A GATE ON THE DRAW. A kind whose `avail` is false
//   is not in the roll at all, so the roster can name upgrades for
//   systems that do not exist yet. This is also where the feature
//   unlock spine will hook when it lands - one more condition per
//   entry, in the file that already describes the entry.

// ========================== DIFFICULTY ==============================
// upgrade_diff_mult is the FIRST thing in RX that g.difficulty actually
// does. It was picked at new game, given flavour text that promises
// something, stored on the save, and read by nothing at all. DE's
// equivalent is real: hardmode raises upgrade prices and cuts sell
// value, classicmode does the reverse, and the same two flags also
// reach dial cost growth (get_cost_v3 doubles the exponent), rarity
// rolls (calculate_rarity), ability costs and the pace features unlock
// at (check_unfolding). This is one seat of several; the rest can
// follow the same shape as each system lands.

// ============================ TRAPS =================================
//   - NEVER change an `id`. It is what a save stores. An id the roster
//     no longer carries loses its SLOT on load, not the savefile.
//   - crit rate and dial discount are CAPPED in upgrade_bonus. A crit
//     chance past 100 is meaningless and a 100% discount makes levels
//     free and stops the economy. DE hid these limits in its roster
//     (refusing to offer crit rate past 500), where the player can
//     never see them; capping the effect keeps the offer honest.
//   - costs are plain reals turned into arbs at the comparison. Keep
//     them >= 1: the arb library does not do sub-1 values.
