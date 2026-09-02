/// tour_tap - THE TAP  (game/tap)
/// A TOUR SCRIPT: comments only, nothing runs.

// ========================== THE FILES ===============================
//   obj_clicker      PERSISTENT (seated in rm_gameload - DE keeps its
//                    obj_clicker on the persistent HUD room too), so
//                    the thumb earns in every game room. Live only
//                    once g.game_started, never in the title / boot /
//                    quit rooms. Owns nothing but the tap surface:
//                    everything under the header, minus the dial
//                    drawer's face (read from syst_dials each frame).
//                    A tap: give_profit(g.click_gps), count it, float
//                    the "+N", click sound, spit motes that CARRY the
//                    tap's profit (a tiny tap spits exactly as many
//                    motes as it earned).
//   create_clicker   the tap's globals (click_gps, tapsyphon, totals).
//   update_click     what one tap is WORTH (DE's update_clicker):
//                    1 + every dial level, PLUS the SYPHON = 1% of the
//                    fleet's per-second rate once it clears 100/s.
//                    Dials make the thumb stronger; late game the
//                    syphon is the whole tap. update_dials ends by
//                    calling this.
//   give_profit(amt)   THE ONE SITE profit is earned, for taps, dials
//                    and every future source: adds to g.profit and
//                    g.total_profit, registers the amount in flight
//                    (the counter's hold-back), marks the save dirty.

// ========================= HOW DE DID IT ============================
// obj_clicker + click_v2 + give_click + give_gold, with five touch
// devices read at once and a crit roll at the tap site. RX starts
// with the single pointer; crits, credits and the rest re-enter at
// obj_clicker's one tap site as those layers are rebuilt.
