/// tour_credits - CREDITS  (game/credits)
/// A TOUR SCRIPT: comments only, nothing runs.

// ========================== THE IDEA ================================
// The SECOND currency. Profit buys dial levels; credits will buy
// upgrades. They trickle in from PLAY, not from production: a pool
// refills slowly over time, and every tap has a small chance to pull
// a few credits out of it. So credits reward being present and
// tapping, which is DE's design. They survive rebirth.

// ========================== THE FILES ===============================
//   setgame (Create)   THE KNOBS, yours to edit:
//                        credit_cap        the pool's ceiling (7)
//                        credit_refill     credits per HOUR into it (12)
//                        credit_maxpull    most one drop can pay (3)
//                        credit_tap_chance percent per tap (2)
//                        credit_cool_min/max  seconds between drops
//                                          (5..8, halved one in ten)
//   credits_init       the state: g.credits, g.total_credits (arbs),
//                      g.credit_pool, g.credit_cool.
//   credit_tick(secs)  the clock: refill + cooldown on a seconds
//                      budget. syst_production calls it every step,
//                      offline_replay with the whole absence - one
//                      code path, like production.
//   credit_drop(x, y, [amount])   THE ONE SITE credits are earned.
//                      -1 pulls from the pool (cooldown, floor,
//                      maxpull, DE's rolls); a number is an explicit
//                      grant. Pays, marks the save dirty, plays the
//                      diamond, and sends lavender motes to the panel.
//   obj_clicker        the tap rolls credit_tap_chance after paying
//                      profit (DE's give_click site).
//   obj_display_credits   THE PANEL sliding in from the LEFT edge at
//                      y 46 (DE's own draw: pixel strip, end-cap from
//                      spr_display_units, spr_particon icon, lavender
//                      text). Out for 3 s after a drop, while the
//                      menu is open, and always in the money room with
//                      "always show popups" on (settings > gameplay,
//                      DE's persist_popups); away while the dial drawer
//                      is out and under the rebirth overlay - DE's
//                      rules. Display only, never tappable.
//                      Persistent, spawned by syst_handle_save.
//   spr_display_units, spr_particon, snd_diamond, snd_orb   DE's assets.

// ========================== SAVE + RESET ============================
// handle_save section "credits" (balance, lifetime, pool, cooldown);
// game_reset -> credits_init(true); rebirth_do never touches them.

// ========================= HOW DE DID IT ============================
// syst_creditdropper (a per-frame pool + a cooldown that was a string
// and a number by turns), drop_credits, a five-source balancer for
// merges / gear / chests / upgrades that RX has no sources for yet,
// and the same left-edge panel. Same numbers, one runner.

// ============================ TRAPS =================================
//   - The pool floor is 1 once live: a pull needs pool > 1, so the
//     very first credit takes a few minutes of refill. DE's feel.
//   - Never add motes that CARRY credits: credits land on the drop,
//     the panel's "+N" is the only delivery animation.
