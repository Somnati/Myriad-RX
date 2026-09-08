/// tour_tap - THE TAP  (game/tap)
/// A TOUR SCRIPT: comments only, nothing runs.

// ========================== THE FILES ===============================
//   obj_clicker      PERSISTENT (seated in rm_gameload - DE keeps its
//                    obj_clicker on the persistent HUD room too), so
//                    the thumb earns in every game room. Live only
//                    once g.game_started, never in the title / boot /
//                    quit rooms. Owns nothing but the tap surface:
//                    everything under the header, minus the dial
//                    drawer's bars and buttons (syst_dials answers
//                    __consumes(x, y)) - taps pay with the drawer open.
//                    A tap: give_profit(g.click_gps), count it, float
//                    the "+N", click sound, spit motes that CARRY the
//                    tap's profit (a tiny tap spits exactly as many
//                    motes as it earned).
//   tap_fire(n,x,y)  THE ONE PAYOUT, and it takes a COUNT (DE's
//                    give_click(feed)). Press and hold both arrive
//                    here, so a tap is worth the same whichever made
//                    it. One crit roll per batch (DE's law - same
//                    expectation, larger rarer lumps).
//   tap_rate()       taps a second while HELD (DE's get_tps). Base
//                    macro x upgrades, result-side; ability, gear and
//                    goal seats are named in its header, unbuilt.
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

// ====================== THE RATE, AND WHY ===========================
// A HOLD IS A RATE, NOT A SECOND BUTTON, and the rate is allowed to go
// far past the frame rate - DE's reached the thousands. That breaks the
// obvious implementation: a game at 60fps can fire at most 60 discrete
// taps a second, so "one tap per frame while held" silently caps, and
// caps the tap COUNT with it - stat page, milestones and every ability
// that reads lifetime taps all wrong together, consistently, which is
// how a bug like that survives shipping.
//
// DE's answer, ported whole:
//     tap_acc += (tap_rate() / 60) * delta     // fractional taps
//     if (tap_acc >= 1) { feed = floor(tap_acc); tap_acc -= feed;
//                         tap_fire(feed, ...); }
// The whole part is paid in ONE call carrying a count, the remainder
// carries to the next frame. The rate is exact at any value on any
// machine, the arb math packs once a frame instead of once a tap, and
// the frame rate never enters the economy.
// datafiles/tap_twin.py holds this across 30-240fps and rates 0.5 to
// 12345, and prints what the naive version would have paid: 6% at a
// rate of 1000.
//
// A HOLD IS ONLY A HOLD WHERE IT STARTED, AND ONLY WHILE STILL. Every
// gesture here is also a held button (drawer swipe, tile drag, zoom
// swipe), so the PRESS decides once whether this is a tap surface and
// travel past TAP_HOLD_DRAG hands the press to the gesture. The
// ceremony is rationed on its own clock (TAP_FX_TIC) so floats stay
// readable at rate; the money never is.
//
// THE READOUT is DE's two halves added: obj_tps counted MANUAL presses
// by spawning a one-second token instance per press, which RX keeps as
// tap_log (remaining life in delta units, no instances), and the hold
// rate is added on top. obj_clicker's Draw shows it in the money room
// only, eased and faded like DE's obj_draw_clickgps.

// ========================= HOW DE DID IT ============================
// obj_clicker + click_v2 + give_click + give_gold, with five touch
// devices read at once and a crit roll at the tap site. RX starts
// with the single pointer; crits, credits and the rest re-enter at
// obj_clicker's one tap site as those layers are rebuilt.
