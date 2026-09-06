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
//                    strength at 50) -> timer stretched by autoeff and
//                    divided by speed milestones -> gpc (x profit
//                    milestones, x the rebirth boost) and gps. Per-second output is nearly
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
//                    37, x10 -> 40) while settings > gameplay "rounded
//                    bulk buys" is on (g.buy_round, DE's default), flat
//                    +10 off; "max" is EVERY level the pile can pay
//                    for (exact, no snap); "next" the next milestone.
//                    g.buy_lv holds the live mode, session-only.
//   dial_buy_ext(i, mode, [commit])   quote {ok, n, to, cost} for a
//                    mode, or commit it through dial_buy.

// ========================== THE VIEW ================================
//   syst_dials       THE DRAWER in rm_clicker, DE's obj_dial look
//                    rebuilt: three stages (docked dot column / 140px
//                    bars / 93px bars + buy buttons), SWIPE LEFT or D
//                    to pull out - swiping is the ONLY way out (his
//                    call 2026-09-04: tapping the dot column opened it,
//                    which fought a thumb earning near the right edge)
//                    - swipe right or A or tap outside to put away,
//                    live drag past a 6px budget, ease-out on release. Bars are DE's composition: endcaps,
//                    the letter glyph, lv, the progress bar with the
//                    countdown centred and the accruing take at its
//                    end; "..." during the wind-up; the docked dot is
//                    DE's two filled circles whose radius IS the
//                    progress, seated by __dot_y at the exact y of the
//                    BAR it becomes, so opening the drawer widens the
//                    column instead of re-shuffling it. DE's two top-right buttons ride in from
//                    the right edge: VIEW (with the list; a pillbox
//                    picking the rate readout, profit per cycle or per
//                    second - g.display_gps) and BUY BULK (with the
//                    buy layer; cycles the mode, g.buylv_unlock gates
//                    it, 0 = always). Each row's rate sits right-
//                    aligned past DE's 70-wide bar; "+N" beside the
//                    level says how many levels the mode buys.
//                    THE MANUAL START (DE's click_dial): holding the
//                    pointer on a dial still winding up jumps its cycle
//                    to the end of the wind-up, with snd_autostart. Answers obj_clicker's __consumes(x, y)
//                    so a press on a bar or button is a UI action while
//                    the dimmed space beside them still pays a tap.
//   spr_dial, spr_dial_endcaps, spr_dial_name (a-z glyphs),
//   spr_progressbar (track / cap / comet / glow), spr_dial_bubble,
//   spr_dial_stripe   DE's own art.

// ============================ TRAPS =================================
//   - autoeff lives in dial_config and is READ by both update_dial
//     and the drawer, so the sim and the view can't disagree.
//   - THE VIEW BUTTON has THREE modes (g.display_gps, settings.ini):
//     0 p/c per cycle, 1 p/s per second, 2 "%" = this dial's share of
//     the whole fleet's output, graded by DE's rarity thresholds. The
//     button draws its mode as TEXT, not a sprite frame - which is what
//     let the third one land without a new glyph (spr_hud_toggle_ps
//     frames 2 and 3 are now unused).
//     The share is computed in LOG SPACE, never through do_div: a share
//     is <= 1 by definition and the arb library does not do sub-1
//     values - dividing into one packs malformed and hangs a normalize
//     loop. See the block in Draw_0.
//   - THE BACKDROP IS THE DRAWER'S WIDTH, not the room's: it starts at
//     `face`, so in portrait it is the screen and in landscape it is a
//     strip at the right edge. The BLUR behind it is a runtime effect
//     layer ("dial_blur", depth 10) created ONLY when row_x <= 4 -
//     i.e. only where full screen IS the drawer's width - because GM
//     effect layers have no region form. A landscape strip-blur needs
//     an application-surface snapshot. THAT JOB IS NOW DONE: the
//     backdrop uses pixel_snap / draw_pixel_region (see tour_ui), which
//     paints a blurred copy of the scene into the strip's rectangle and
//     so works in BOTH shapes. The gaussian fx layer it replaced is
//     gone. The capture rides an obj_draw_proxy at depth 0 - between
//     the content and the drawer - and only runs while sp > 0.
//   - THE SEATS ARE DERIVED, not typed. row_x / row_y1 / bb_x / vb_x*
//     are offsets from the room's edges because the money room has two
//     shapes (rm_clicker 144x296, rm_clicker_landscape 480x270). Each
//     one reproduces DE's portrait number EXACTLY at 144x296 - check
//     that if you ever change one (row_x 2, row_y1 256, bb_x 119,
//     vb_x1 122, vb_x2 98). Never write a raw 144 or 296 in here.
//   - ONE PITCH for the column. The docked dots once had their own
//     (11 against the rows' row_p of 16) and the error grew with the
//     index - dial m's dot sat sixty pixels from its bar. Everything
//     vertical in the column goes through __dot_y or row_p; never
//     write a second spacing.
//   - The level is the only owned number. Never store a rate.
