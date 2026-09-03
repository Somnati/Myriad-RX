/// tour_offline - THE OFFLINE CALCULATOR  (game/offline)
/// A TOUR SCRIPT: comments only, nothing runs.

// ========================== THE IDEA ================================
// While you are away the dials keep earning at their full online
// rate: no cap on time, no efficiency fraction, no minimum, and the
// tapper earns nothing (all of it DE's law). DE computed that by
// simulating the absence in chunks across a loading room, because its
// production tick was per-frame. RX's prod_dials takes a SECONDS
// BUDGET and pays whole cycles in bulk, so the whole absence is ONE
// call to the SAME code that runs live. Offline is online; there is
// no second formula that could drift.

// ========================== THE FILES ===============================
//   offline_replay(secs)   the calculator: prod_dials(secs), then the
//                    report {secs, gain, rate} queued in
//                    g.offline_report. Profit lands immediately.
//   syst_offline     persistent watcher, spawned by syst_handle_save.
//                    Step 1: a gap of 5 s or more between two steps
//                    means the app was suspended (phone background,
//                    laptop sleep) - replayed like any absence.
//                    Step 2: shows the queued report as DE's stacked
//                    banners (welcome back / time away / idle rate /
//                    earned) the next time rm_clicker is up with a
//                    run started. Absences under a minute replay
//                    silently.
//   syst_handle_save (engine/save) after a LOAD: away time = now
//                    minus the save's datetime stamp -> offline_replay.
//                    A stamp in the FUTURE (clock rolled back) replays
//                    nothing and says "times off..." - DE's guard.

// ========================= HOW DE DID IT ============================
// calculate_offline_gain in chunks, rm_offline as a spinner room,
// gold banked in offline_gold behind a tap-to-claim coin button
// (obj_offlinegold), obj_idletime firing the banners. Same numbers,
// four objects and a room fewer.

// ============================ TRAPS =================================
//   - Never write an offline-only formula. If offline is wrong, live
//     play is wrong the same way - fix prod_dials.
//   - The report is session state, not saved: quit before visiting
//     the money room and the banners are simply skipped. The profit
//     was already paid.
