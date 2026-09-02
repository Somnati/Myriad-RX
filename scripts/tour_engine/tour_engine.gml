/// tour_engine - THE FRONT DOOR OF THE ENGINE TOUR  (engine/)
/// A TOUR SCRIPT: comments only, nothing runs. Read it like a page.
/// Every engine part has one at the top of its folder. This one says
/// what "engine" means, the ONE pattern you need to recognise, and
/// the order to read the rest in.

// ===================== WHAT "ENGINE" MEANS ==========================
// Everything that is not the game. Booting, saving, the menu, the
// settings screen, input, the window, the big-number library. It was
// ported from Techdemo II on 2026-08-14 by dependency closure (every
// file a ported file mentions came along, nothing else). Nothing in
// engine/ knows what a dial is - except the SEAMS listed below, which
// exist precisely so game systems can plug in.
//
// game/ is Myriad DE rebuilt, one folder per DE system as it lands.
// Read tour_game for that side.

// ============ THE ONE PATTERN: CONTROLLER + CONTENT =================
// Four engine parts share a shape you did not write DE in, and it is
// the thing that makes them look foreign:
//
//   part        CONTENT (you edit)      CONTROLLER (you don't)
//   menu        menu2_content           syst_menu2 + obj_ui_menu2
//   settings    settings_content        syst_settings
//   statistics  stats_v2_content        syst_statistics_v2
//   save        handle_save             syst_handle_save
//
// The content script is a plain LIST written as calls:
//     menu2_section("game");
//     menu2_button("clicker", rm_clicker, c_horange);
// The controller runs that script INSIDE ITS OWN SCOPE, so each call
// pushes an entry into the controller's arrays (btns, rows...). The
// controller then draws and hit-tests those arrays generically.
//
// WHY: adding a row is one line, and there is no object per row to
// place, size, colour and wire. DE did it the other way - one placed
// object per button (obj_button_suboptions x10, one obj_options_*
// per setting, obj_stattab per stat tab) and each object worked out
// its own name, colour and target in its Step. That is fine at ten
// buttons and painful at fifty.
//
// THE RULE: edit the content script. Open the controller only when
// the framework itself is wrong.

// ========================== NAMING ==================================
//   syst_*   a system / controller object, usually persistent or one
//            per room, owns the logic of its part
//   obj_*    a placed or spawned thing (a button, a mote, the header)
//   par_*    a parent object; children call `pair` (event_inherited)
//   scr_*    older prefix, plain scripts (scr_display1, scr_escape)
//   one FUNCTION per script asset, file name == function name
//   g        is `global` (main_macros). delta = frame multiplier
//            (1 == 60fps). fnt = the sprite font. kill = destroy.

// ========================== THE SEAMS ===============================
// Where a rebuilt DE system plugs in - each carries a "systems add
// their block HERE" comment:
//   setgame (Create)        its globals + create_ call
//   handle_save             its save section
//   game_reset              its fresh-run reset
//   settings_content        its knobs (+ system Create default,
//                           settings_defaults, handle_settings)
//   stats_v2_content        its statistics lines
//   menu2_content           its menu line
//   syst_input (Step_1)     a blocker line if it owns the room
//   scr_escape              a stand-down line if it eats escape

// ======================== READING ORDER =============================
//   tour_boot      what runs first and where globals are born
//   tour_rooms     how rooms switch, the back stack
//   tour_input     who owns a click
//   tour_save      the ini, autosaves, profiles
//   tour_settings  the settings screen and its widgets
//   tour_menu      the burger and the drawer
//   tour_ui        the header, the draw kit, banners, floats
//   tour_arb       the big-number library and its one big rule
// then as needed: tour_bezier, tour_visualizer, tour_display,
// tour_gamepad, tour_statistics, tour_services, tour_util,
// tour_namegen, tour_debug. Then tour_game.
