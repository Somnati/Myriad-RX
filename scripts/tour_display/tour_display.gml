/// tour_display - THE WINDOW  (engine/display)
/// A TOUR SCRIPT: comments only, nothing runs.

// ========================== THE FILES ===============================
//   syst_display     persistent. Declares the display globals
//                    (g.fullscreen, g.screen_size, g.screen_size_user,
//                    borderless, vsync), spawns the three window
//                    buttons on desktop only, arms the throwable.
//   scr_display1     THE DRIVER, run every step. During rm_gameload it
//                    HOLDS FIRE (the game starts fullscreen behind the
//                    black cover; applying a saved windowed mode there
//                    is silent). After boot: the minimise slide, the
//                    fit swap when g.screen_size goes negative (the
//                    "re-arm" convention), the portrait park.
//   scr_res_list     THE resolution table, built live: the display's
//                    native size first, then the 16:9 ladder that fits.
//                    Width-keyed because the save stores width only.
//                    The settings dropdown and the swap both read it,
//                    so the picker can never offer a size the swap
//                    can't apply.
//   obj_set_landscape   placed in every LANDSCAPE room: sets
//                    g.screen_size = -abs(g.screen_size_user), i.e.
//                    re-arms the swap with the player's choice.
//                    Portrait rooms park the size at 144 instead.
//   obj_display_fullscreen / _minimize / _quit   the window chrome
//                    (top-right), persistent, pin themselves per room.
//   do_throwable / set_throwable   the THROWABLE WINDOW: grab the
//                    window, fling it, it slides with momentum. DE's
//                    toy (DE has obj_throwable in rm_clicker); RX runs
//                    it inside syst_display.

// ========================= "FIT" MODE ===============================
// A portrait room (rm_clicker, 144x296) parks g.screen_size at 144 and
// scr_display1 scales the window to the display HEIGHT. It cannot use
// the height RAW: a windowed game also needs room for the title bar
// above and the taskbar below, and GML has no work-area call. So
// g.fit_margin (a PERCENT of screen height, settings > display,
// default 12) is reserved, and the window centres in the display -
// half the reserve above, half below.
// Kept as a percent, not pixels, because window chrome scales with
// DPI: title + taskbar are ~7% of the screen height at 100% and at
// 200% alike, so one number holds on any monitor.

// ======================= THE TWO SIZE GLOBALS =======================
//   g.screen_size_user   what the player CHOSE. Saved. Never touched
//                        by rooms.
//   g.screen_size        the LIVE size. Portrait rooms park it at
//                        144; a negative value means "swap to abs()
//                        now". Splitting them fixed a bug where a trip
//                        through a portrait room overwrote the choice.

// ============================ TRAPS =================================
//   - NEVER size a windowed portrait fit to display_get_height() and
//     pin it at y 0. That is what it did until 2026-09-04: the title
//     bar went off the top (the window could not be dragged) and the
//     last ~13 of the room's 296 rows sat behind the taskbar, which
//     is where the menu's foot band keeps its numbers. Reserve
//     g.fit_margin and centre.
//   - Instance sprite_width is ALREADY scaled by image_xscale.
//   - Everything is 8-bit: wide dark gradients band. The fix in this
//     project is temporal dither (sh_fog_dither), not more bits.
