
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
#macro UPG_SLOT_BASE 3     // slots you start with
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
#macro UPG_RARITY_N  7     // common .. ultimate, see upgrade_rarity_mult
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