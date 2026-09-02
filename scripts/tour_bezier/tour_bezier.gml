/// tour_bezier - THE PROFIT MOTES  (engine/bezier)
/// A TOUR SCRIPT: comments only, nothing runs.
/// Your DE bezier library (restored whole on 2026-08-26; bezier_get_y
/// had drifted from bezier_get_x and was matched back), plus the
/// emitter and mote objects rebuilt from DE's obj_bezier_profit.

// ========================== THE FILES ===============================
//   bezier_create / bezier_set_point / bezier_find / bezier_get_x /
//   bezier_get_y / bezier_approach
//                    the library. A curve is control points on the
//                    instance; get_x/get_y evaluate de Casteljau for
//                    the point count you pass (3 today, 4 when a
//                    cubic is wanted); approach advances _zero (the
//                    0..1 clock) by the library's own _move_scale.
//   bezier_bits(x, y, n, col, [tx], [ty], [tic], [amt])
//                    THE ONE ENTRY POINT. Burst n motes from (x,y)
//                    toward the target (default: the header counter's
//                    seat, so taps and dials can't aim at different
//                    places). tic = -1 all at once (dial payouts),
//                    0+ = one mote per tic frames (taps use 0, the
//                    rapid-fire feel). amt = the profit this burst
//                    CARRIES (see the hold-back).
//   obj_bezier_emit  paces one burst: spawns motes under a population
//                    cap of 48 (a capped spawn is skipped, the burst
//                    still drains), hands each mote its share of amt.
//   obj_bezier_bit   one mote: flies the 3-point curve, accelerating
//                    1.5x over its length, shrinks as it closes, spins,
//                    arrival bloom, then dies. Skin by g.part_style:
//                    glowing square (spr_pixel_2x2) / circle / coin /
//                    munny (spr_coin*, spr_munny, spr_part_profit).
//                    All motes wear g.profit_color - every mote is the
//                    same money (his call); the dot they leave from
//                    already says which dial paid.

// ========================== THE HOLD-BACK ===========================
// Profit is BANKED the instant it is earned (give_profit) - that must
// never depend on a particle surviving. But the same amount is also
// registered in g.profit_flight, and the header counter subtracts
// whatever is still in flight, so the NUMBER climbs as the motes
// land (DE's emit_gold feel). Every way profit can stop flying pays
// it back: a mote that arrives, a mote culled before arriving
// (CleanUp), an emitter whose spawn the cap swallowed (its CleanUp),
// and the header zeroes the ledger outright when nothing is airborne.
// Registering at the EARN site rather than counting live motes is
// what makes it order-proof: the hold starts before any view has had
// a chance to spawn anything.

// ========================= HOW DE DID IT ============================
// obj_bezier_profit / obj_bezier_profit_v2 + emit_gold: the same
// idea, with the counter summing live particles.
