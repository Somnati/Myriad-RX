/// tour_rebirth - REBIRTH  (game/rebirth)
/// A TOUR SCRIPT: comments only, nothing runs.

// ========================== THE IDEA ================================
// Give up the run - profit and every dial level - for UNITS, and
// every unit is +100% dial output from then on. Units come from the
// PROFIT HELD at the moment of rebirth, not lifetime profit: spend it
// on levels and it is not there to count. That tension is DE's
// design, kept whole.

// ========================== THE FILES ===============================
//   rebirth_init     the meta struct g.rebirth (units, total, the run
//                    clock's origin, the last run's card). Survives
//                    rebirths; only a new game wipes it.
//   rebirth_calc     THE EARN LAWYER (DE's update_rebirth): a pure
//                    read. Hard gate 1m held; origin at 10m; a flat
//                    1..6 unit ladder between; above it units grow
//                    TIMES TEN per 3.75 orders of magnitude (DE packs
//                    the depth as an exponent - Techdemo II's port had
//                    flattened this by accident); +1 per 10 orders
//                    past 1e16; under 300 s into a run the award
//                    scales by (run/300)^2, first rebirth exempt; the
//                    button refuses before 600 s into any run.
//   rebirth_boost    1 + units, a packed arb. update_dial multiplies
//                    every dial's per-cycle pay by it. The tap does
//                    NOT take it: update_click adds the units flat
//                    (DE's shape - its tap line is commented out).
//   rebirth_do       THE COMMIT: backup to save slot 4 (the "rebirth
//                    save" in the saves menu), award, then the clean
//                    slate - profit 0, every dial level 0, the tap
//                    re-derived. Lifetime profit and playtime, the
//                    profile, settings and pins survive untouched.
//   rebirth_open     the menu's [rebirth] line: opens the overlay,
//                    hopping to rm_clicker first if needed.
//   syst_rebirth     THE OVERLAY, placed in rm_clicker, dormant until
//                    opened. DE's collect banner: spr_rebirth_btn (DE's
//                    own 144-wide button art) at DE's y 172, HOLD to
//                    fill it centre-out, at 100 it fires. Flavor names
//                    are DE's, seeded by the rebirth count. Modal
//                    while open (syst_input's blocker line + family
//                    entry), tap outside or escape closes.
//   snd_rebirth, snd_rebirthcollect   DE's sounds.

// ========================== SAVE + RESET ============================
// handle_save section "rebirth"; game_reset -> rebirth_init(true).

// ============================ TRAPS =================================
//   - Never store the award or the boost - both derive at read time.
//   - The bank is plain 0 until it holds a unit; never do_add onto a
//     zero (the arb rule).
//   - Same-room goto_room(rm_clicker) after the commit IS the
//     restart: the wipe covers the reset and the fresh room is the
//     fresh run.
