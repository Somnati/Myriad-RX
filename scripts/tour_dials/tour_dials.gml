/// tour_dials - THE DIALS  (game/dials)
/// A TOUR SCRIPT: comments only, nothing runs.
/// Each script here names its DE source in its own header. This page
/// is the map; the laws live in the files.

// ========================== THE DATA ================================
//   create_dials     builds g.dial[0..12], one STRUCT per dial (DE
//                    spread a dial across ~40 parallel global arrays).
//                    Owned state: level, cycle, auto. Everything else
//                    (gps, gpc, cps, cycle_t) is DERIVED and never
//                    saved.
//   dial_config(i)   the roster as data: name letter, base cycle
//                    (3 s doubling a..m, x2 past h, x4 past k), the
//                    wind-up fraction autoeff (.3).
//   dial_color(i)    the thirteen hand-picked identity colours
//                    (c_dial0a..). Irregular on purpose - never
//                    regenerate them as an even hue wheel.

// ========================== THE CURVES ==============================
//   dial_gps(tier, level)   THE output curve (DE's get_gps): +.0255
//                    log10 per level, plus a flat +1/level under 1e10.
//   dial_cost(tier, from, to)   THE price (DE's get_cost_v3): +.05
//                    log10 per level, price(B) - price(A) as one
//                    closed form. Cost outruns output ~2:1 in the
//                    exponent BY DESIGN - one dial always decays, the
//                    next dial up is the way forward.
//   dial_lvdiv(tier)   the tier's level HEAD START (dial m is born
//                    ~1080 levels along). This is where depth lives.
//   update_dial(i)   re-derive one dial: base -> level ramp (full
//                    strength at 50) -> timer stretched by autoeff ->
//                    gpc and gps. Per-second output is nearly
//                    independent of cycle length: length is PACING.
//   update_dials()   all of them, then the fleet totals, then
//                    update_click. THE resync - every load and buy
//                    ends here.

// ========================== THE RUNNER ==============================
//   prod_dials([secs])   advance every running dial by a SECONDS
//                    BUDGET (bare = this frame's delta) and pay
//                    completed cycles in bulk. One code path for live
//                    play AND the offline catch-up when it is rebuilt:
//                    never fork an offline-only formula.
//   syst_production  persistent heartbeat that calls it every step.
//   dial_buy(i, [n]) THE one place a dial gains levels: quote, spend,
//                    resync, mark dirty. Level 0 is dormant; the first
//                    level is the purchase.
//   buy_resolve(i, from, mode)   THE BUY-MODE LADDER (DE's law): x10 /
//                    x100 / x1000 buy UP TO THE NEXT ROUND LEVEL (level
//                    37, x10 -> 40), "max" is the largest affordable
//                    target snapped down to a round level, "next" will
//                    be the next milestone. g.buy_lv holds the live
//                    mode, session-only like DE's.
//   dial_buy_ext(i, mode, [commit])   quote {ok, n, to, cost} for a
//                    mode, or commit it through dial_buy.

// ========================== THE VIEW ================================
//   syst_dials       THE DRAWER in rm_clicker, DE's obj_dial look
//                    rebuilt: three stages (docked dot column / 140px
//                    bars / 93px bars + buy buttons), swipe left or D
//                    to pull out, swipe right or A or tap outside to
//                    put away, live drag past a 6px budget, ease-out
//                    on release. Bars are DE's composition: endcaps,
//                    the letter glyph, lv, the progress bar with the
//                    countdown centred and the accruing take at its
//                    end; "..." during the wind-up; the docked dot is
//                    DE's two filled circles whose radius IS the
//                    progress. The buy stage carries DE's "buy bulk"
//                    mode button at the top (hidden until 3m lifetime
//                    profit, DE's gate) and a "+N" beside each level
//                    saying how many levels the mode buys. Answers obj_clicker's __consumes(x, y)
//                    so a press on a bar or button is a UI action while
//                    the dimmed space beside them still pays a tap.
//   spr_dial, spr_dial_endcaps, spr_dial_name (a-z glyphs),
//   spr_progressbar (track / cap / comet / glow), spr_dial_bubble,
//   spr_dial_stripe   DE's own art.

// ============================ TRAPS =================================
//   - autoeff lives in dial_config and is READ by both update_dial
//     and the drawer, so the sim and the view can't disagree.
//   - The level is the only owned number. Never store a rate.
