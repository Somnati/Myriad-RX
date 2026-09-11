
function main_macros() {

#macro arg0 argument[0]
#macro arg1 argument[1]
#macro arg2 argument[2]
#macro arg3 argument[3]
#macro arg4 argument[4]

#macro pre_delta (delta_time/1000000)*60
#macro delta system.syst_delta
#macro g global
#macro pair event_inherited()
#macro kill instance_destroy()
#macro key_p keyboard_check_pressed  
#macro key keyboard_check 
#macro key_r keyboard_check_released
#macro swdiv sprite_width/2
#macro shdiv sprite_height/2
#macro fnt g.font
#macro fnt_large g.font_large
// outline variants (Myriad DE port 2026-07-10; aliases 2026-07-14)
#macro fnt_outline g.font_outline
#macro fnt_large_outline g.font_large_outline

// THE version string (2026-07-14): the title screen wears it bottom-
// left; bumping a release is this one line
#macro game_version "beta v0.01"

#macro overflow 308.1797693134862231
// log-space ZERO sentinel for the lg_* helpers (dims' lz, promoted to
// a house constant by the stock market): 10^lg_zero is 0 in any world.
// "does this exist" checks compare against lg_zero/2. plain digits -
// GML has no 1e9 literals
#macro lg_zero -1000000000
#macro tsec 60
#macro tmin (60*60)
#macro thour ((60*60)*60)
#macro tday (((60*60)*60)*24)
#macro sv_save 0
#macro sv_load 1

#macro c_sgreen rgb(136,245,99)
#macro c_hred rgb(252,57,116)
#macro c_gold rgb(255,220,130)
#macro c_horange rgb(255, 90*.9, 30*.9)
#macro c_hpurple #9f00ff 
#macro c_lavender #ad7bfa
#macro c_pink rgb(255,20,147)
#macro c_sblue rgb(89,89,255)
#macro c_salmon rgb(250, 128, 114)
#macro c_seagreen rgb(19,232,152)
#macro c_steelblue rgb(75,146,184)
#macro c_dkblue #00008b
// compound's universal currency color (his call 2026-07-14, joins
// profit = c_gold / resin = c_seagreen): soft orange, defined ONCE -
// chips, counters and the production stockpile row all read this
#macro c_compound rgb(240,166,96)

// dial identity palette (myriad's letter colors, read by dial_get_color)
#macro c_dial0a rgb(128,128,255)
#macro c_dial1b rgb(250,29,51)
#macro c_dial2c rgb(252,209,42)
#macro c_dial3d rgb(87,238,70)
#macro c_dial4e rgb(185,253,255)
#macro c_dial5f rgb(228,105,255)
#macro c_dial6g rgb(255,116,23)
#macro c_dial7h rgb(138,154,91)
#macro c_dial8i rgb(144,133,165)
#macro c_dial9j rgb(255,66,122)
#macro c_dial10k rgb(252,244,163)
#macro c_dial11l rgb(0,128,129)
#macro c_dial12m rgb(114,160,177)
#macro c_dial13n rgb(251,164,134)

#macro c_rarity_basic #a99a86
#macro c_rarity_common c_hsv(75,0,255)
#macro c_rarity_uncommon #7FFF00
#macro c_rarity_rare rgb(65,122,255)
#macro c_rarity_epic rgb(160,32,255)
#macro c_rarity_elite rgb(255, 128, 0)
#macro c_rarity_master rgb(253,14,53)
#macro c_rarity_exotic #4fffdf 
#macro c_rarity_legendary rgb(255,220,130)
#macro c_rarity_ancient #4B75A7
#macro c_rarity_cosmic rgb(150,151,255)
#macro c_rarity_mythic #ff50c3
#macro c_rarity_divine rgb(255,131,121)
#macro c_rarity_ultimate #b9f2ff

#macro mouse_x_prev syst_touchscreen.x_prev
#macro mouse_y_prev syst_touchscreen.y_prev
#macro mousex syst_touchscreen.wmx
#macro mousey syst_touchscreen.wmy
#macro touch_x_ syst_touchscreen.x_
#macro touch_y_ syst_touchscreen.y_
#macro touch_x syst_touchscreen.x
#macro touch_y syst_touchscreen.y
#macro touching_screen syst_touchscreen.on_screen
#macro touch_dragdist syst_touchscreen.drag_dist
#macro touch_dir syst_touchscreen.dir
#macro touch_dragspd syst_touchscreen.dragspdlerp
#macro touch_time syst_touchscreen.time
#macro touch_count syst_touchscreen.touches
#macro touch_pinch syst_touchscreen.pinching
#macro touch_pinch_scale syst_touchscreen.pinch_scale
#macro touch_pinch_delta syst_touchscreen.pinch_delta
#macro touch_pinch_x syst_touchscreen.pinch_cx
#macro touch_pinch_y syst_touchscreen.pinch_cy
#macro touch_jump syst_touchscreen.jump   // frames left of the window-jump hold (see syst_touchscreen)
#macro touch_time_min 45
#macro touch_dragdist_min 50
#macro touch_dragspd_min 7

#macro scrl_test_equipstats 0
#macro scrl_test_statistics 1
#macro scrl_abilitydeck 2
#macro scrl_statistics 3
#macro scrl_settings 4
// (5 was scrl_batstation - retired with the station room, 2026-07-12;
// 6/7 were scrl_dials/scrl_prod - retired round 29 with their rooms)
#macro scrl_goals 8
#macro MENU_HERE_TRIM 6  // px every menu row gives up from its left
                         // edge so the room you are IN can keep the
                         // full width and read as wider than the rest
#macro scrl_menu2 9   // the hamburger drawer. PIXEL mode (slot_height 1)
#macro scrl_stats_rail 10   // statistics' TAB RAIL, pixel mode (his ask: the house bar, left of the tabs)
#macro scrl_faq 11          // the faq's cards, pixel mode
                      // like the old stats lanes - the menu scrolls a
                      // content HEIGHT, not a row index.

// settings framework (syst_settings + settings_* scripts) row kinds
#macro sett_kind_section 0
#macro sett_kind_toggle 1
#macro sett_kind_radio 2
#macro sett_kind_slider 3
#macro sett_kind_info 4
#macro sett_kind_action 5
#macro sett_kind_pill 6
#macro sett_ink rgb(195,205,235)

#macro c_ap rgb(120,190,255)

// ---- upgrades (game/upgrades) ----
// EIGHT TO START (his call, so an end-game table can be looked at
// now). The design wants 3 and the other five bought through the
// "another slot" grant - put this back to 3 to restore that, and the
// grant re-enters the roll pool by itself the moment it does, because
// its avail closure is `upgrade_slots() < UPG_SLOT_MAX`.
#macro UPG_SLOT_BASE 8     // slots you start with
// EIGHT. It was cut to five when a row was 38px tall and eight ran off
// the bottom of a 270-tall room; at 19px a row they all fit with space
// to spare, so this is the original intent restored rather than a new
// decision. One number if you want it tighter.
#macro UPG_SLOT_MAX  8     // and the most the "another slot" grant can reach

// ⚖️ WIRED, NOT LIVE (his call, while the screen is being polished).
// Every consumer reads upgrade_bonus_live(), which returns zeros while
// this is false - so the seats stay written and the economy is
// untouched. upgrade_bonus() itself stays truthful, so the screen shows
// what the slots WOULD do. Flip this to turn the whole system on.
#macro UPG_LIVE false

// THE SPARK POOL's size - see syst_sparks. DE runs to 200 instances;
// this is 200 preallocated structs in one object, and the number is a
// hard ceiling rather than a target: the population cull means the
// count settles well under it on its own.
// ---- THE TAP RATE (DE's get_tps + click_v2's accumulator) ----
#macro TAP_HOLD_BASE  6   // ⚖️ THIS IS ALSO THE TAP/HOLD SEPARATOR. DE
                          // starts at 6, which makes the hold interval
                          // 167ms - longer than a human tap (80-150ms),
                          // so an ordinary press finishes before the
                          // hold has earned anything and a tap is one
                          // tap for free. At 8 the interval is 125ms and
                          // a lingering press earns two, exactly as DE
                          // does once you have bought a faster thumb.
                          // SET TO DE'S 6 (2026-09-08) because it is
                          // the number that answers both of his reports
                          // at once: no lead to feel, and a slow press
                          // still worth exactly one tap. Raising it
                          // trades the second for a faster hold, which
                          // is the trade an upgrade is supposed to make.
                          // taps a second while the button is HELD, before
                          // upgrades. DE's base is 6 and an ability grants
                          // it; RX hands it over from the start because
                          // there is no deck to draw it from yet.
#macro SFX_DIAL_TIC  14   // frames between DIAL CYCLE sounds. A late fleet
                          // lands several cycles a second across every
                          // dial at once; the feedback wanted is "the
                          // fleet paid", not "dial D paid".
// ---- THE OVERCHARGER (DE's obj_click_multi, ported 2026-09-10) ----
#macro OC_MAX_LV      5   // x5 at the top (the charger-cap ability adds 5)
#macro OC_XP_BASE    40   // xp to fill x1 -> x2 (DE's 40)
#macro OC_XP_STEP    30   // ...and 30 more each level after (DE's)
#macro OC_XP_TAP      1   // xp a tap (DE's overcharge_xp_add; +1 with an ability, later)
#macro OC_HOLD      300   // frames a tap keeps the charge from draining (DE's 5s)
#macro OC_DRAIN_SEC   4   // once draining, a level empties in this many seconds (DE's tsec*4)
#macro OC_DISC_R      4   // the charge disc's full radius (DE's des_size)
#macro OC_RING_R      6   // the circular bar's radius: DE's des_size + 2, hugging the disc, one px thin
#macro TAP_FX_TIC     5   // frames between tap floats while holding. The
                          // money is never rationed, only the show.
#macro TPS_WINDOW    60   // delta units a manual tap counts toward the
                          // shown rate. DE's tsec: one second.

#macro SPARK_MAX 200

// WHERE THE PROFIT COUNTER STOPS SPELLING ITSELF OUT. Below this
// exponent it draws every digit with thousands separators (DE's
// behaviour); at and above it, crunch_arb takes over. 8 = full digits
// to 99,999,999 and crunched from a hundred million, which is roughly
// where the low digits stop meaning anything.
#macro PROFIT_DIGIT_MAX 8

// The backstop on stats_hist_offline's fill loop. The loop's real exit
// is the cursor reaching the end of the absence, and because the
// interval doubles every time the buffer fills, that is 861 pushes for
// a month away and 1277 for ten years (measured - see that script).
// This is here for a corrupt step, not for the normal case.
#macro HIST_FILL_MAX 4000
#macro UPG_RARITY_N  8     // common .. ultimate, see upgrade_rarity_info
// THE STAKE. What one roll into an empty slot costs in credits, before
// difficulty and upgrade_inflation. It is what stops "sell instead of
// discard" from being a credit printer, and what stops free rerolling
// from making rarity meaningless - see upgrade_roll_cost.
// FREE (his call). Everything the stake was protecting still holds,
// because the protection was never the price itself - it was that a
// refund can only ever be a fraction of what was actually paid in. At
// zero, an offer you never bought has had nothing paid into it and so
// refunds nothing, which is arithmetic rather than a special case.
// The cost of free rolling is that rerolling is unlimited, so rarity
// only matters as long as you cannot be bothered to press the button
// again; if that turns out to hurt, the honest fix is DE's - upgrades
// arrive on a timer instead of on demand - rather than a price.
#macro UPG_ROLL_COST 0
// THE RARITY LADDER's shape (upgrade_rarity_odds - Techdemo II's
// calculate_rarity). SCALE is how wide a band is against the one below
// it, GROW steepens that per rung and stops at rung 5 (the tech demo's
// fix - unclamped, DE's top rungs collapse to unreachable), CUT is the
// luck rate at which the bottom rung has fallen off entirely.
#macro UPG_RARITY_SCALE .3
#macro UPG_RARITY_GROW  .03
#macro UPG_RARITY_CUT   800

// THE TIER CURVE (upgrade_tier_value). RAMP is how much more each tier
// is worth than the one before it - gentle compounding, so a slot you
// keep feeding gets better rather than merely bigger. LAST is what the
// FINAL tier is multiplied by, and it is deliberately large: it makes
// finishing a slot an event rather than an increment, which is the
// whole reason a cap is interesting.
// ⚖️ WIRED, NOT TIED IN (his call, while the table is being finalised).
// The tiles work completely - fabricate, merge, earn shards, buy their
// four upgrades - but they touch NOTHING the base game depends on:
//
//   the SAVE           no tiles section is written or read, so the
//                      board is a session and an iteration on its
//                      shape cannot churn or corrupt a real savefile
//   OFFLINE            offline_replay does not call tiles_fastforward,
//                      so a bug in the tile replay cannot break a load
//   the ECONOMY        already separate by design: the table earns
//                      SHARDS and is not in all_gps, so profit and
//                      rebirth never see it (see tiles_init)
//   BOOT               nothing spawns the engine until you open the
//                      room; leave it alone and it does not exist
//
// Flip this to true to tie it in - that is the whole switch, and the
// tile screen says out loud which side of it we are on.
// ---- THE OVERLAY OPEN ANIMATION (settings / statistics) ----
// His report: they "just pop in". Read ui_anim_in for the shape; these
// are the five numbers that govern it.
#macro UI_IN_SPD      8    // move_to divisor for the master ease. 8 is
                           // ~35 frames, a little over half a second
                           // (his ask: the rows should move into place
                           // SLOWER). Raised from 5 once the rows began
                           // fading as well - a dissolve reads as slow
                           // at a speed a slide reads as sluggish at
// ⚖️ THE GROUND UNDER THE MENU AND EVERY OVERLAY (his report, three
// times, 2026-09-10: no menu blur behind settings / statistics /
// automation / rebirth / time bank). The blur layer WAS riding every
// overlay's oa - but the menu's look is its BACKING drawn under the
// blur (obj_menu2_bck: this plate + the edge gradients, softened with
// the room), and the overlays painted a sharper, darker .72 sheet
// above the blur instead. obj_menu2_bck is the one backing now, for
// the menu and the panels alike, and this is its plate's alpha.
#macro UI_GROUND_A    .48
#macro UI_OUT_SPD     3    // ...and the divisor on the way OUT (his
                           // ask: speed the fade-out up). CLOSING IS
                           // NOT OPENING PLAYED BACKWARDS. An entrance
                           // is worth watching once - it tells you a
                           // screen arrived and roughly what is on it.
                           // An exit is a thing standing between you
                           // and the room you asked to get back to, and
                           // every frame of it is a frame of waiting.
                           // ~13 frames against the entrance's 35
#macro UI_IN_STAGGER .05   // how far behind the previous part each one
                           // starts, as a fraction of the whole ease
#macro UI_IN_STEPS    7    // ...and how many parts deep the stagger
                           // goes before they all share the last delay
#macro UI_IN_DEAL    14    // px a list row rises into its seat. SHORT
                           // (his ask: "just a smooth move into place
                           // as it fades in"). It was 150 - a deal from
                           // off-screen - which the opacity has now
                           // made unnecessary and, next to a fade, read
                           // as the list being thrown rather than
                           // settling. A row now barely moves: the
                           // dissolve is the arrival, the drift is only
                           // what stops it being a cross-fade
#macro UI_IN_SLIDE   17    // px the title strip drops out from behind
                           // the header, and the rail slides in by

// ---- SPRITES (his idea, 2026-09-11: little blob helpers) ----
// Read sprites_init. Free (no RAM, off the battery), passive, stacking.
#macro SPRITE_TAP_T      3  // seconds between one sprite's taps while it WORKS
#macro SPRITE_ATTN    7200  // attention: offline work decays as 1/(1+t/T),
                            // T seconds - 8h away yields T ln(1+8h/T) of work
#macro SPRITE_NAP     3600  // away longer than this and they are found asleep

// ---- THE BATTERY (the OFFLINE budget, his design 2026-09-11) ----
// Read battery_init. Charge is seconds of absence the machines can run;
// it fills ONLINE (your attention, banked) and offline machines drain
// it; empty, every machine stops for the rest of the absence.
#macro BAT_CAP0       10800 // seconds of charge at capacity level 0 (3h)
#macro BAT_FILL0        120 // seconds to fill from empty at level 0/0
                            // (2 minutes - "recharge fast", his call)
#macro BAT_CAP_STEP      .5 // capacity x(1 + STEP x level)...
#macro BAT_RATE_STEP     .5 // ...and the charge rate x(1 + STEP x level)
                            // - the SAME factor, so equal levels fill in
                            // BAT_FILL0 and a capacity ahead of its rate
                            // takes proportionally longer (his law)
#macro BAT_COST0          5 // credits, the first level of either ladder
#macro BAT_COST_MULT    1.5 // x per level
#macro BAT_CRANK_REV     60 // crank revolutions from empty to full
#macro BAT_W_RUN          1 // draw weights: the dials' cycling...
#macro BAT_W_FAB         .5 // ...the fabricator...
#macro BAT_W_MERGE        1 // ...and the automerger (the compounders cost)

// ---- RAM (the automation budget, his design 2026-09-11) ----
// Every automation costs sticks; the budget is ram_cap, the bill is
// ram_used, and over budget NOTHING switches off - every clock runs at
// cap/used instead (ram_throttle). Read ram_cost for the prices.
#macro RAM_BASE        16  // sticks a fresh game holds. The two things
                            // that are ON by default - the dials' own
                            // cycling and the fabricator, 5 each at
                            // full speed - fit with room for one fast
                            // autobuy or several slow ones
#macro RAM_REB          2  // sticks per rebirth banked (g.rebirth.total).
                            // No capacity purchase (his call, 2026-09-11:
                            // "remove the upgrade for ram") - the budget
                            // grows with rebirths, and whatever else
                            // earns it later
#macro RAM_REBIRTH      4  // sticks the autorebirth costs, switched on
#macro RAM_TIMER_MIN    1  // the fastest an autobuy may pulse, seconds
#macro RAM_TIMER_MAX   30

// ---- THE PUCK (obj_puck - Myriad DE's throwable, rebuilt) ----
// Read obj_puck's Create for what each mechanic is FOR; these are the
// numbers that shape it. Everything is in room px and 60hz frames.
#macro PUCK_D           19  // diameter. Odd, so the disc has a true
                            // centre row and reads symmetrical
#macro PUCK_FOLLOW       5  // trickle divisor toward the cursor while
                            // DOCKED (the magnet's own grip; the free
                            // hold is the mass-spring below)
#macro PUCK_HOLD_K    .030  // THE WEIGHT. The held puck is a mass on a
                            // spring to the pointer: this is the spring
                            // (px/frame^2 per px of stretch). Lower =
                            // heavier: it lags further, swings wider,
                            // takes longer to catch up. .03 puts its
                            // natural period near half a second, which
                            // is about the pace a wrist swings at - so
                            // a circle with the pointer swings the puck
                            // round WIDER than the hand, the trebuchet
#macro PUCK_HOLD_DAMP  .89  // velocity kept per frame on the tether.
                            // Under critical (.71 at this K) on
                            // purpose: it overshoots a little and
                            // settles, the way a weight on a string
                            // does, and a swing at its own pace goes
                            // about half again as wide as the hand
#macro PUCK_CANNON_LOCK 22  // frames the cannon locks in hard before it
                            // switches to slow aiming (arming should
                            // feel decisive, aiming deliberate)
#macro PUCK_SNAP_R      50  // a dock only speaks if the puck was at
                            // least this far from it - or sitting in a
                            // corner retriggers the sound every frame
#macro PUCK_MIN_PULL     3  // under this, a release is a place-down
#macro PUCK_TIER_SPD    .5  // launch speed per power tier
#macro PUCK_TIER_RESIST  2  // ...and combo bounces per tier. A stronger
                            // shot is also a LONGER one, which is what
                            // makes charging worth the wait
#macro PUCK_TIERS        2  // aim tiers above zero (deck cards raise it)
#macro PUCK_FRIC_SLOW  .975 // per-frame speed decay when crawling...
#macro PUCK_FRIC_FAST   .98 // ...and when flying. Fast keeps more, so a
                            // throw decays gently then falls off a
                            // cliff - the last bounces are the tense
                            // ones
#macro PUCK_BNC_SLOW   .972 // restitution, same split
#macro PUCK_BNC_FAST   .985
#macro PUCK_STUN         3  // frames of impact freeze at full speed.
                            // Friction is OFF for the duration - that
                            // is what makes a bounce punch instead of
                            // squelch
#macro PUCK_RESIST       3  // near-frictionless bounces a throw banks
#macro PUCK_STOP        .4  // below this it has stopped
#macro PUCK_CATCH        3  // a mid-air catch pays this many bounces
#macro PUCK_PAY_MIN     .8  // a bounce pays between these multiples of
#macro PUCK_QP         1.3  // draw-quad half-extent in puck RADII. Room
                            // for the rounded rim plus a margin; too
                            // tight and the SDF clips its own silhouette
#macro PUCK_SPIN         14 // deg/frame of yaw at full-speed release.
                            // The knurled edge is what makes rotation
                            // visible at all, and this is what makes
                            // the knurl move
#macro PUCK_PAY_MAX      2  // tap_rate(). See puck_pay - the puck has
                            // no scale of its own BY DESIGN

// ⚖️ THE TABLE IS LIVE (his call, 2026-09-09: "allow the tiles to run
// like normal instead of starting when i enter the room"). This flag
// was the reason it did not: with it false, setgame SKIPS tiles_init at
// boot, so the persistent syst_tiletimer that ticks fabrication and
// automerge in every room did not exist until syst_tiles' Create built
// it - which is to say, until you opened the room. The board was not
// paused; it had not been created.
//
// Flipping it turns on four things at once, and they belong together:
//   setgame        tiles_init at boot -> the engine exists from launch
//   handle_save    the "tiles" section is written and read for real
//   offline_replay the board catches up on time spent away
//   syst_tiles     the "preview - not saved yet" banner stops drawing
//
// PERSISTENCE IS THE ONE THAT MATTERS. A board that runs everywhere but
// forgets itself at every launch is worse than one that only runs while
// watched, so "run like normal" has to include being saved. Old saves
// have no tiles section and load their defaults through handle() - no
// migration, nothing to convert.
#macro TILES_LIVE true

// THE TILE TABLE's base shape and what one upgrade level moves. Every
// one of these is read by tiles_sync and by datafiles/tiles_twin.py -
// keep the two in step, and tune in the twin.
// the last pixel of the tile value's vertical seat - see syst_tiles'
// __val_y. Sprite-font glyphs rarely fill their cell evenly, so this is
// the one thing the arithmetic cannot derive.
#macro TILE_TEXT_NUDGE   2

// ⚖️ PARKED (his call): the double tier-up on merge. It is Myriad's
// merge_tierrate and the code is intact below the flag - this is a
// switch, not a deletion, and it changes NO saved state (bonus_rate
// stays in the save, the roll simply never runs). Flip it back to true
// when the frontier mechanic is ready to be part of the design.
//
// It also silences the +2 ding by construction: syst_tiles only plays
// snd_tierup on the bonus, and the bonus can no longer fire.
// THE TILE'S DRESS (tile_shape_draw): false = accretion + size (one
// rectangle that gains rim, studs, frame, band and pips as it climbs,
// and grows a px a tier to TILE_GROW) - 2026-09-10's trial, his call
// to judge; true = the six-shape cycle it replaced
#macro TILE_SHAPES       false
#macro TILE_GROW         3   // px of growth over the first tiers (each way: w and h)
#macro TILE_BONUS_TIER   false

// ⚖️ THE BOARD IS AN UPGRADE NOW (his spec, 2026-09-10): twelve slots
// to start, +1 a level, 32 at the cap - the "slots" row in
// tile_upg_config, priced so the first four land before 100m and the
// rest ride the shared curve to e308. tiles_sync lays the board out
// from these three; the roster's cap derives from them too.
#macro TILE_SLOTS_BASE   12   // (16 before the upgrade existed)
#macro TILE_SLOTS_MAX    32
#macro TILE_FAB_T        600    // frames: 10 seconds
// ⚖️ ZERO BY DEFAULT (his call, 2026-09-09). A board that ships with a
// ten-tile reserve has already solved the only problem the reserve
// exists for, so the upgrade could never feel like anything. At 0 a
// finished tile with nowhere to go is simply LOST, and buying the first
// level is the moment that stops being true.
//
// It is not a stall: see tiles_tick. The fabricator's primary
// destination is the BOARD - the hopper is what catches overflow, not a
// conveyor everything has to pass through.
#macro TILE_BANK_BASE     0
// ⚖️ THE TILE TABLE'S DIVISOR INTO DIAL PROFIT (DE's get_allmodgps).
// 100 points of board output = +100% = every dial pays double. The SHIFT
// is that number's digit count, because arb subtracts exponents to
// divide - they are one quantity said twice, and out of step they would
// silently rescale every dial in the game. See tile_dial_boost.
// ⚖️ THE TABLE'S OWN PRESTIGE pays FLUX, a currency (his call - not
// units). A rebirth pays earned / FLUX_DIV, so the amount is literally a
// share of the shards the board produced, and the pile held multiplies
// board output through tile_rebirth_boost:
//
//     output x (1 + FLUX_STEP x flux ^ FLUX_POW)
//
// ⚖️ +1% PER FLUX, LINEAR (his call, 2026-09-09). I shipped this with a
// square-root brake first, because flux is proportional to earned and
// earned to output, and a linear read closes that into a loop that
// compounds across rebirths. He wants the plain version - a flux is a
// percent, full stop, and a player can do that sum in their head. So
// POW is 1 and the brake is gone. What holds the loop now is the
// DIVISOR: it decides how many flux a run's earnings become, and it is
// the one number to raise if the twin's six-rebirth ladder starts
// climbing faster than the game can hold.
#macro TILE_RB_GATE       8   // 1e8 earned before the first reset -
                              // THE DIVISOR'S DECADE, and it must stay
                              // so: below it earned/DIV floors to zero
                              // flux, and a gate the reset can pass
                              // while paying nothing is a button that
                              // says "ready" and does nothing
// ⚖️ 1e8, NOT 1e6, and the twin is why. With +1% a flux LINEAR, a
// run's boost is proportional to the previous run's earnings, so the
// loop across rebirths is QUADRATIC - at 1e6 the sixth rebirth earned
// 1e12 times the first, output x5e11, and it was still accelerating.
// The divisor cannot make a quadratic loop bounded; what it does is
// set how many rebirths it takes to matter. At 1e8: a six-hour first
// rebirth is x1.8, a full day's is x4, and six of them stacked are x138
// over thirty-six hours of play, which is a prestige with teeth rather
// than a rocket. If it runs away past that, raise this - it is the ONE
// number in this loop that is not a design choice he made out loud.
#macro TILE_FLUX_DIV 100000000  // flux paid = earned / this (a plain
                                // literal: GML will not parse 1e8)
#macro TILE_FLUX_STEP   .01   // output x (1 + STEP x flux^POW): +1% each
#macro TILE_FLUX_POW      1   // linear - his call

#macro TILE_DIAL_DIV    100
#macro TILE_DIAL_SHIFT    2

#macro TILE_PROFIT_STEP .25  // profit boost: the board's share of the
                             // dial multiplier is (1 + STEP)^lv - 1,
                             // COMPOUNDING, and ZERO at level 0 - the
                             // upgrade IS the tile-into-dial chain (his
                             // call; the exact figure does not matter,
                             // the shape does). See tile_dial_boost.
// ⚖️ THE FABRICATOR'S SECONDS ARE A BUDGET, and he set it out loud: ten
// seconds base, FIVE of them removable by tile upgrades alone, three
// more by abilities that do not exist yet (three of them, a second
// each), and what is left is the floor.
//
//   TILE_FAB_T    600  10.0s   the base
//   TILE_FAB_CAP  300   5.0s   the most UPGRADES may ever remove
//   (abilities)   180   3.0s   reserved, unbuilt
//   TILE_FAB_MIN  120   2.0s   the floor when everything has landed
//
// THE CAP IS THE NEW IDEA and it is what makes the reservation real. A
// floor alone cannot hold three seconds open: with only MIN to stop
// them, upgrades would take the fabricator to 2.0s by themselves and
// every future ability would be worth precisely nothing. The cap says
// what UPGRADES may take; MIN says where EVERYTHING stops.
//
// ⚖️ THE STEP IS HIS, THE EXPONENT IS SOLVED FROM IT (his call: keep
// -0.1s increments, move the cost to suit). Those two numbers are not
// independent - the budget fixes the total at -5.0s, so the step fixes
// the LEVEL COUNT, and the level count is what decides how steep each
// one has to be to reach the ceiling:
//
//     -0.05s  ->  100 levels  ->  +3.0 decades each  ->  1e304
//     -0.10s  ->   50 levels  ->  +6.0 decades each  ->  1e304
//
// Same ladder, same top, half as many rungs and each worth twice as
// much. Fifty chunky steps beat a hundred imperceptible ones: -0.05s
// off ten seconds is a change nobody can feel landing, and an upgrade
// you cannot feel is an upgrade you stop buying on purpose.
// ⚖️ AND THE PRICE CURVES (his ask). The straight line spent its 304
// decades evenly, which put the SECOND level at 1e10 and dropped the
// fabricator out of the first day entirely - a fifty-rung ladder whose
// early half nobody would ever climb. CURVE 2 spends the same span
// unevenly: level 5 at 1e7, level 10 at 1e16, level 50 still exactly on
// TOP. The budget does not move; only who can reach which part of it.
#macro TILE_UPG_CURVE     2  // every upgrade's price curve (his call):
                             // 1 = a straight line, higher = a slower
                             // start and a steeper finish
#macro TILE_PROFIT_CURVE 1.25 // ...except profit's, which must NOT
                             // start slow: at curve 2 five levels cost
                             // 36k shards all told and paid x10 on
                             // every dial (his report: x6 at 300/s is
                             // too cheap). See tile_upg_config.
#macro TILE_FAB_TOP     308  // log10 of the LAST level's cost (his e308)
#macro TILE_FAB_STEP      6  // -0.1s a level, in FRAMES at 60hz
#macro TILE_FAB_CAP     300  // ...to -5.0s total, and no further
#macro TILE_FAB_MIN     120  // the floor after abilities too
#macro TILE_SPEED_FACTOR .88    // fab period x this a level
// ⚖️ DE'S BASE RATE, and it is not zero (his correction: check DE).
// indiv.gml opens the rarity chain with mod_rarity_rate = 100 before a
// single modifier touches it, and that base is what makes a PERCENTAGE
// upgrade mean anything - x1.2 of nothing is nothing. RX started this
// at 0, which is why my first reading of "+20%" had to invent a flat
// addition instead of a multiply.
#macro TILE_RARITY_BASE 100
// ⚖️ 400, NOT DE's 800 (his call). The cutoff is what one full tier
// of spawn floor COSTS in rate, so halving it halves the distance to
// every threshold - the rarity upgrade reaches its first floor shift
// in single-digit levels instead of at level 35, which is the whole
// reason it was inert.
#macro TILE_RARITY_CUT  400

// ⚖️ NOT "LUCK" (his correction, 2026-09-09): luck was its own
// separate stat in DE - g.luck_mod, a different number doing a
// different job - and borrowing the word here would collide with it
// the day that lands. This is RARITY and nothing else.
//
// PERCENTAGE POINTS a level (his +50%), summed and applied as ONE
// multiply - DE's u_rarityrate exactly. See tile_rarity_rate.
#macro TILE_RARITY_STEP  50
#macro TILE_SLOT_STEP    1   // slots a level (was 2 when the row was retired)
// THE CHANCE UPGRADES - duplication and tier up share these (his spec,
// 2026-09-10: 1% to start, +1% a level, 50% at the cap). The cap is
// where the ladder ENDS: levels = (CAP - BASE) / STEP = 49, and the
// roster's max reads that. See tile_chance_rate.
#macro TILE_CHANCE_BASE   1  // percent at level 0 - the free trickle
#macro TILE_CHANCE_STEP   1  // percent a level
#macro TILE_CHANCE_CAP   50  // percent, and the last level
#macro TILE_BANK_STEP     1  // hopper tiles a level (his number).
                             // ONE, against a price climbing 2.5
                             // orders of magnitude a level - the
                             // reserve is earned a slot at a time,
                             // never bought in blocks

#macro UPG_TIER_RAMP .15
#macro UPG_TIER_LAST 3
#macro UPG_SELL_BACK .45   // fraction of what was paid in, returned on a sale

#macro eid_crit_rate 0
#macro eid_luck 1
#macro eid_mod_rarity 2
#macro eid_fabrication 3
#macro eid_crit_multi 4
#macro eid_tps 5
#macro eid_creditdrop 6
#macro eid_dup 7
#macro eid_tiermerge 8
#macro eid_mergecharge 9
#macro eid_urarity 10
#macro eid_upgradelevel 11
#macro eid_equiptier 12
#macro eid_equip_rarity 13
#macro eid_chest_rarity 14
#macro eid_chest_delay 15
#macro eid_chest_boost 16
#macro eid_burst 17
#macro eid_chest_multi 18
#macro eid_perk 19

}