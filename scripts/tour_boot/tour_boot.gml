/// tour_boot - WHAT RUNS FIRST  (engine/boot)
/// A TOUR SCRIPT: comments only, nothing runs.

// ========================== THE FILES ===============================
//   main_macros   the macro table. g = global, delta, kill, pair,
//                 fnt, the c_* colours (c_gold, c_sgreen, the thirteen
//                 c_dial* identity colours), tsec/tmin/thour, sv_save/
//                 sv_load, the touch_* aliases, the sett_kind_* row
//                 kinds. A script that only DEFINES macros - nothing
//                 calls it, GM reads it at compile time.
//   system        the engine's own globals and its heartbeat. Create:
//                 the sprite fonts (font_add_sprite), the delta chain,
//                 and the BOOT DEFAULT of every setting (volumes,
//                 autosave, bit_pick, profit_color, trans_kind).
//                 Step_1 (begin step): fps cap, master audio gain,
//                 the 5-frame delta mean, escape -> scr_escape, F1 ->
//                 obj_debug_pro, R restarts the room in debug.
//   setgame       the GAME's globals: profit / total_profit,
//                 difficulty, the four profile names+colours (rolled
//                 fresh, a first save locks them), create_dials(),
//                 g.game_started = false, the room history.
//   rm_gameload   the boot room. It seats every PERSISTENT system so
//                 they exist in all rooms after: system, setgame,
//                 syst_input, syst_touchscreen, syst_handle_save,
//                 syst_display, syst_roomtrans, syst_banner,
//                 syst_production, obj_clicker, obj_dialogue, plus
//                 ui_fadein (the black cover) and obj_background.

// ========================== THE ORDER ===============================
//   1. main_macros is compiled in - macros exist everywhere.
//   2. rm_gameload creates its instances. system must exist before
//      anything reads `delta` (it is system.syst_delta).
//   3. setgame declares game globals and builds the dial layer.
//   4. syst_handle_save's first Step LOADS the active profile's save
//      (or writes a fresh one), then settings.ini. So from step 1
//      every global holds the saved value, not the boot default.
//   5. scr_display1 holds fire while this room is up (no window
//      flap behind the black cover), then the room hands off to
//      rm_titlescreen.

// ============================ DELTA =================================
// The game runs at MONITOR refresh (144 hz machines run frame-locked
// code fast). `delta` is a smoothed multiplier, 1.0 at 60 fps: every
// per-frame motion or timer multiplies by it. pre_delta is the raw
// instantaneous one. For sims that must be deterministic, use a
// fixed-tick accumulator instead - one style per system, never both.

// ========================= HOW DE DID IT ============================
// DE boots through rm_load -> rm_load_ui, and rm_load_ui IS the
// persistent HUD layer (ui_header, obj_clicker, the syst_* runners
// all live there). RX moves that job to rm_gameload and keeps the
// header per room. Same idea: one room that seats the persistents.

// ============================ TRAPS =================================
//   - A NEW GLOBAL is declared in system (a setting) or setgame (game
//     state) BEFORE any room reads it. Rooms never lazy-declare.
//   - Never goto_room() then `exit` early in a Create: the switch
//     happens at frame end, so Step and Draw still run once.
//   - Two copies of a persistent object = two heartbeats. rm_gameload
//     is the ONLY room that places them.
