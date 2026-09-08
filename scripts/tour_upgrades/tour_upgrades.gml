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
//   upgrade_roll       fills an empty slot: pay the stake, pick an
//                      available kind, roll a rarity, a value in the
//                      band, and how DEEP the offer goes.
//   upgrade_roll_cost  THE STAKE. What a roll costs.
//   upgrade_roll_tiers DE's per-rarity table for how many tiers an
//                      offer can take, plus DE's wealth bonus rolls.
//                      This is what the dots under a row count.
//   upgrade_buy/_sell  the two transactions.
//   upgrade_complete   the last tier CLEARS THE SLOT (DE's behaviour)
//                      and files the upgrade in g.upg.done, which
//                      upgrade_bonus reads alongside the slots.
//   upgrade_price_base ONE tier's price, UN-INFLATED - the single owner
//                      of DE's curve base x rarity x (1 + (.2+.1t)*t).
//   upgrade_cost       that, times upgrade_inflation.
//   upgrade_inflation  DE's drift: +3% per hundred upgrades bought,
//                      ceiling 3x. QUOTES ONLY.
//   upgrade_sell_value SELL_BACK x (the stake + every tier bought), all
//                      of it un-inflated.
//   upgrade_cap        how many tiers this offer can take - ROLLED with
//                      it now, not derived from the rarity.
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
//   depth / tier and nothing else - all of which is what the offer IS,
//   never what it does; every effective number comes from
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
//   A FINISHED UPGRADE LEAVES ITS SLOT BUT NOT THE GAME. DE clears the
//   slot on the last tier and loses nothing, because buy_upgrade
//   already added the effect into a global on the way in - the slot was
//   only ever a receipt. We derive from the slots, so clearing one
//   would delete the upgrade you just finished paying for. The finished
//   thing moves to a LEDGER instead (g.upg.done), which upgrade_bonus
//   walks beside the slots. This is the one place where deriving costs
//   an extra moving part, and it is worth it: the alternative is DE's,
//   where every number depends on the history of purchases.
//
//   THE LEDGER IS TOTALLED PER ID, NOT LISTED PER UPGRADE, and that is
//   a savefile decision. As a list it grew forever - about 26 bytes per
//   completed upgrade, all of it inside ONE ini value, so a thousand
//   completions was a 25KB string bigger than the whole rest of the
//   file. Per id it is bounded by the roster at roughly 200 bytes
//   however long the account runs. Nothing is lost: upgrade_bonus only
//   ever wanted the sum of val x tier, and `val` was already frozen at
//   roll time, so the per-entry detail was never feeding derivation.
//   handle_save migrates the old four-field rows as it reads them.
//
//   SELLING IS A HOLD, BUYING IS A CLICK. DE gates both behind a bar
//   that fills over 40 frames while the pointer is down. We keep it for
//   the sale only: a commitment gate on a destructive, irreversible
//   action is protection, and the same gate on the screen's main verb
//   is friction. The fill is squared (DE squares the sell fill and not
//   the buy fill), so a mis-tap barely moves it.
//
//   ROLLING IS ONE BUTTON, not one per row. A roll does not care which
//   empty slot receives it, so eight identical buttons were asking a
//   question with no answer. The button takes the first free slot, top
//   down.
//
//   ROLLING COSTS CREDITS, and two separate things depend on it.
//   Without a stake there is no reason to keep a common - you press the
//   button again - so the entire rarity ladder collapses into "reroll
//   until ultimate". And once an unwanted offer can be SOLD instead of
//   discarded (his call), a free roll is a credit printer: roll, sell,
//   repeat. The stake is the gamble's price and the sell value is the
//   recovery, which is what keeps the second one honest.
//
//   A SELL CAN NEVER PAY OUT MORE THAN WENT IN, and this is provable
//   rather than tuned. Both terms of upgrade_sell_value are quoted off
//   upgrade_price_base, which never sees upgrade_inflation, while every
//   price actually PAID was that same base times an inflation factor
//   that only ever grows. So sell <= SELL_BACK x paid < paid, for every
//   rarity, every depth and every moment in a run. That has to hold at
//   the MAXIMUM and not merely on average: the player sees the roll
//   before deciding whether to sell it, so a distribution that merely
//   leans negative would still be farmable by only selling the good
//   ones. It is also why the difficulty multiplier appears on both
//   sides - it has to cancel.
//
//   GRANTS ROLL AT COMMON. Rarity scales an upgrade's value and its
//   price together, and a grant has no value to scale: "one more slot"
//   is one more slot at every rung, so an ultimate one would be the
//   identical thing at sixteen times the price.
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
