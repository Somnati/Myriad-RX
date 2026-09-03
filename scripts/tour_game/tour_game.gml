/// tour_game - THE GAME SIDE  (game/)
/// A TOUR SCRIPT: comments only, nothing runs.
/// game/ is Myriad DE rebuilt, one folder per DE system as it lands.
/// The rule for the whole side: DE is the design authority - read
/// DE's implementation first, port its LAWS (curve shapes, timings,
/// feel), rebuild the code clean. Nothing gets reworked silently in
/// a faithful pass.

// ========================== WHAT EXISTS =============================
//   dials/   the thirteen dials a..m, their economy, the drawer
//   tap/     the tap and the one place profit is earned
//   offline/ the away-time calculator (one call to prod_dials)
//   rebirth/ units for profit held, +100% dial output each
//   rooms/   rm_clicker, DE's money room (144x296 portrait)
// Read tour_dials, tour_tap, tour_offline and tour_rebirth.

// ========================== THE LOOP ================================
//   setgame            create_dials() builds g.dial[] and the tap's
//                      globals at boot.
//   syst_production    (persistent, in dials/) calls prod_dials()
//                      every step: cycles advance, completed cycles
//                      pay through give_profit.
//   obj_clicker        (persistent, in tap/) a tap pays g.click_gps
//                      through give_profit.
//   give_profit        banks it, registers it in flight, marks the
//                      save dirty.
//   obj_ui_header      shows it (held back until the motes land).
//   syst_dials         the drawer: view + the buy taps -> dial_buy ->
//                      update_dials (THE resync).

// ========================= WHAT IS MISSING ==========================
// DE's remaining layers - upgrades, milestones, crit, abilities,
// gear, refinery, tiles, chests, credits, goals, daily gift,
// tutorial, autobuy. Each lands as its own game/ folder
// with its own tour_* page. Until they do, pacing is DE's base curve
// alone: slow by design, not a bug.

// ========================== THE TWIN ================================
// datafiles/dial_twin.py simulates the economy in plain floats and
// prints HOLDS on its invariants. Tune numbers THERE, then port them
// back - never the other way round.
