
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
#macro TAP_HOLD_BASE  8   // taps a second while the button is HELD, before
                          // upgrades. DE's base is 6 and an ability grants
                          // it; RX hands it over from the start because
                          // there is no deck to draw it from yet.
#macro SFX_DIAL_TIC  14   // frames between DIAL CYCLE sounds. A late fleet
                          // lands several cycles a second across every
                          // dial at once; the feedback wanted is "the
                          // fleet paid", not "dial D paid".
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
#macro TILES_LIVE false

// THE TILE TABLE's base shape and what one upgrade level moves. Every
// one of these is read by tiles_sync and by datafiles/tiles_twin.py -
// keep the two in step, and tune in the twin.
// the last pixel of the tile value's vertical seat - see syst_tiles'
// __val_y. Sprite-font glyphs rarely fill their cell evenly, so this is
// the one thing the arithmetic cannot derive.
#macro TILE_TEXT_NUDGE   2

#macro TILE_SLOTS_BASE   16
#macro TILE_FAB_T        600    // frames: 10 seconds
#macro TILE_BANK_BASE    10
#macro TILE_SPEED_FACTOR .88    // fab period x this a level
#macro TILE_LUCK_STEP    60
#macro TILE_SLOT_STEP    2
#macro TILE_BANK_STEP    8

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