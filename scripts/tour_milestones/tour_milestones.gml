/// tour_milestones - DIAL MILESTONES  (game/milestones)
/// A TOUR SCRIPT: comments only, nothing runs.
/// Rebuilt from the ground up (his call, 2026-09-02: "DE's milestone
/// system was ancient"). Two things DE never had: the milestone LEVEL
/// COSTS MORE, and the ladder is one editable table.

// ========================== THE IDEA ================================
// A dial that reaches a milestone level earns a permanent bonus:
// speed (its cycle runs that many times faster) or profit (each
// cycle pays that many times more). Bonuses DERIVE from the level -
// nothing is stored, nothing is saved, a loaded level already has
// its rungs.
// THE PRICE: the ONE level that crosses a rung costs
// g.milestone_cost_mult times its normal price. At level 24, buying
// 25 costs ten times what dial_cost would otherwise charge for that
// level. Bulk buys that roll through a rung pay the premium inside
// their quoted price; the "next" buy mode stops exactly on the rung.

// ========================== THE FILES ===============================
//   setgame (Create)   THE TABLE, yours to edit:
//                        g.milestone_cost_mult   the premium (10)
//                        g.milestones            [{level, kind, mult}]
//                          25 speed x2 / 50 profit x2 / 75 profit x2
//                          / 100 speed x2
//   milestone_get(i, level)   the one lawyer: earned rungs -> {speed,
//                      profit, next, earned[]}. Pure; every consumer
//                      calls it fresh.
//   milestone_next(level)     the next rung's level (-1 past the top).
//   dial_cost          adds (mult - 1) x that level's own price for
//                      every rung inside the range - the premium.
//                      dial_cost(..., true) is the raw price, used
//                      only by the premium itself.
//   update_dial        speed DIVIDES the stretched cycle time, profit
//                      MULTIPLIES the per-cycle pay - DE's two seats.
//   dial_buy           announces a rung the buy just crossed (banner
//                      in the dial's colour + a pop).
//   buy_resolve        "next" = milestone_next(level); the drawer's
//                      mode cycle includes it now.
//   syst_dials (Draw)  a buy that reaches the next rung wears green
//                      (DE's signal that this press is the milestone).
//   stats_v2_content   the DEBUG LIST (his ask): statistics >
//                      milestones > one folder per dial, every rung
//                      with earned / locked, the live speed + profit
//                      totals, and the next rung's premium price.

// ========================= HOW DE DID IT ============================
// update_milestone: a hand-written list of get_milestone(level, type,
// value) calls (19 rungs from 50 to a billion), replayed into ~10
// per-dial global arrays on every level change; automatic, vanilla
// price. Clicker milestones existed but were disconnected. RX keeps
// the two seats (timer divide, give multiply) and nothing else.

// ============================ TRAPS =================================
//   - Keep g.milestones sorted by level; milestone_get finds the next
//     rung by the smallest unearned level either way, but the
//     statistics list prints in table order.
//   - mult must be > 1 or the rung does nothing; cost_mult <= 1 means
//     no premium (the price code guards the zero).
