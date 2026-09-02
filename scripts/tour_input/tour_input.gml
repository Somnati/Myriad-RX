/// tour_input - WHO OWNS A CLICK  (engine/input)
/// A TOUR SCRIPT: comments only, nothing runs.

// ========================== THE PROBLEM =============================
// Two buttons overlap: both fire. A menu is open over the room: the
// click that closes it also lands on the button underneath. DE
// handled this per object (each Step checked the mouse itself, plus
// guards). RX decides ONCE per frame, before anything reads input.

// ========================== THE FILES ===============================
//   syst_input     persistent. BEGIN STEP computes two globals:
//                    g.input_block  the layer a clickable needs to be
//                                   allowed right now. 0 = anything.
//                                   Raised by blockers: pillbox open
//                                   -> popup (200), menu open -> menu
//                                   (500), dialogue -> modal (1000).
//                    g.click_owner  THE one instance allowed to react
//                                   to the pointer: the topmost
//                                   (lowest depth) visible member of
//                                   the FAMILIES array under the
//                                   cursor whose ui_layer clears the
//                                   block. Everything else: noone.
//   input_free(layer)   "may I take clicks?" - true if layer >= block.
//   mouse_over()        ARBITRATED hover: am I g.click_owner. This is
//                       what every button calls.
//   mouse_over_raw()    pure geometry, what syst_input uses to pick.
//   mouse_over_ext()    geometry with a custom rect.
//   check_touch_bounds  touch-friendly hit test helper.
//   syst_touchscreen    persistent touch bookkeeping: drag distance,
//                       direction, speed, two-finger pinch. Read via
//                       the macros mousex/mousey/touch_dragdist/... in
//                       main_macros.
//   scr_escape          THE escape router: transitions swallow it,
//                       local consumers (menu, search, debug edit)
//                       own it, popups own it, else BACK one room,
//                       and the title screen is the only place it
//                       quits.

// ========================== THE PATTERN =============================
// Instance UI (par_button children etc.) just calls mouse_over().
// REGION UI - anything that isn't an instance (the dial drawer's
// rows, the save menu's cards, the tap surface) - follows two lines:
//     if (input_free()) if (g.click_owner == noone) { ...take it }
// That is the whole contract. A new clickable FAMILY is one entry in
// syst_input's _fams array; a new BLOCKER is one line in its Step_1;
// a new escape consumer is one stand-down line in scr_escape.

// ============================ TRAPS =================================
//   - Begin Step is not depth order: syst_input runs before every
//     Step regardless of depth, which is the point.
//   - A modal room-owner (DE's offline card, the rebirth overlay)
//     must add its blocker line or taps go through it.
