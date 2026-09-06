/// tour_ui - THE HEADER, THE DRAW KIT, BANNERS, FLOATS  (engine/ui)
/// A TOUR SCRIPT: comments only, nothing runs.

// ========================== THE HEADER ==============================
//   obj_ui_header    placed per room (not persistent, so each room
//                    sizes it). Draws the strip, spawns obj_ui_menu2,
//                    and owns THE PROFIT COUNTER top-left:
//                      - the shown number GLIDES to the real one in
//                        LOG space (packed arbs can't be lerped)
//                      - the HOLD-BACK: profit still riding bezier
//                        motes (g.profit_flight) is subtracted, so the
//                        number climbs as motes land. Computed in
//                        DRAW, not Step - every Step finishes before
//                        any Draw, so the motes always exist by then
//                        whatever the room's instance order
//                      - DE's RATCHET: do_add/do_subtract round
//                        differently either side of a decade, so the
//                        shown target never falls while real profit
//                        hasn't
//                      - the "+N" gain float when profit lands
//                    prof_shown is what the visualiser reads too, so
//                    blocks and number tell one story.

// ========================== THE DRAW KIT ============================
// DRAW-ONLY helpers. They paint; the OWNER keeps the hit region and
// must use the same rectangle (the region law - geometry drifts
// otherwise).
//   draw_ui_button(x,y,w,h,label,col,[enabled],[primary])   every
//                    button's chrome. primary = the row's ONE action.
//   draw_status_pill(x,y,label,uist.*,[fa_right])   the ONE shape for
//                    states: neutral / warning / critical / positive.
//   draw_row_collapsed(x,y,w,h,label,[tag],[col])   a dormant row.
//   draw_px_rect / draw_px_line   stretches of spr_pixel_1x1.
//   draw_sprite_color   a sprite in one flat colour.
//   spr_pixel_1x1    THE primitive: a white pixel, top-left origin,
//                    stretched into every rectangle in the game.
//   spr_pixel_2x2    the same with a CENTRED origin (integer centre
//                    at 1,1) for anything that rotates or sits in a
//                    glow - the profit mote uses it.
//   spr_vis_glow_soft   a soft radial glow (motes, the burger's
//                    ripple). spr_button / spr_button_bevel (DE's) /
//                    spr_button_bevel_long, spr_ui_header,
//                    spr_scrollbar, spr_banner_endcap: the chrome art.

// ========================== FLOATS + BANNERS ========================
//   float_text(x,y,text,col,[font]) + obj_float   the rising "+12"
//                    pop: tilts, drifts up, fades. Rebuilt from DE's
//                    obj_float with the two-tone gradient derived from
//                    one colour.
//   syst_banner + assign_banner(text,c_text,c_back) / free_banner
//                    the persistent toast stack under the header
//                    ("progress saved", "autosaved", "welcome").
//                    DE's banner, ported whole.

// ========================== THE REST ================================
//   par_button       the instance button family (mouse_over-
//                    arbitrated): the save menu's buttons are its
//                    children. A room's own BACK goes through
//                    back_room() (engine/rooms).
//   obj_scrollbar   the shared scrollbar; a LANE per screen
//                    (scrl_statistics, scrl_settings in main_macros)
//                    picks which page global it drives.
//   obj_draw_proxy   an extra draw slot at a depth of the owner's
//                    choosing - an instance gets one Draw at one depth,
//                    and a screen with rows < widgets < strip < menu
//                    needs four.

// ====================== THE REGION SNAPSHOTS ========================
// Two pairs, same shape: a CAPTURE that copies the application surface
// into a reduced one, and a DRAW that paints a piece of it back into a
// rectangle. Both give a panel something to sit on that is made of
// whatever it is covering.
//
//   pixel_snap([cell])             capture, POINT sampled
//   draw_pixel_region(x,y,w,h,[a]) draw it back in hard blocks
//   -- IN USE: the dial drawer's backdrop, 3 room pixels a block.
//
//   blur_snap([room_px])           capture, bilinear, halved down and
//                                  doubled back up
//   draw_blur_region(x,y,w,h,[a])  draw it back soft
//   -- PARKED. It works; it just was not what this screen wanted. The
//      visualiser's grid lines survived every radius as soft
//      rectangles, and the glow layer had already spread the light
//      before the capture saw it, so blurring smeared a smear. Kept
//      for the next panel that wants glass.
//
// ⚖️ THE TWO ARE OPPOSITES AND MUST NOT SHARE CODE. Pixelation takes
// ONE EXACT SAMPLE PER CELL and never averages (house law - it is why
// GameMaker's _filter_pixelate is banned here); blur is nothing BUT
// averaging. One wants the texture filter off, the other on.

// ========================= THE REGION BLUR ==========================
//   blur_snap([down])            capture: the application surface into
//                                g.blur_small at 1/down.
//   draw_blur_region(x,y,w,h,[a])  draw: the blurred copy of whatever
//                                was behind that rectangle, back into
//                                it. Draw-only, like every helper here.
// Frosted glass behind a panel, without a shader. First customer: the
// dial drawer's backdrop.
//
// ⚖️ WHERE THE CAPTURE IS CALLED IS THE WHOLE DESIGN. Everything drawn
// BEFORE it is in the blur; everything after is not. So it goes in an
// obj_draw_proxy slot seated between the content and the UI - depth 0
// in rm_clicker: after the room, the visualiser and the fx stack, and
// before the drawer (-20) and the header (-1000). Shallower than that
// and the UI starts frosting itself.
//
// ⚖️ READING application_surface THERE IS SAFE, though it looks wrong:
// surface_set_target() moves the render target away from it and
// flushes, so it is an ordinary texture by the time we draw it. The
// manual's warning is about drawing a surface ONTO ITSELF.
//
// ⚖️ THE BLUR IS THE FILTERING - no shader anywhere - but it has to be
// done in HALVES, DOWN AND BACK UP. Bilinear samples four texels
// however far you scale, so one big downscale reads a 2x2 and skips
// everything else: aliasing, not blur. Halving is the only ratio that
// averages honestly. The way DOWN sets the blur's WIDTH; the way back
// UP restores its RESOLUTION, because the bottom of the chain is a
// thirtieth of the window and blowing that straight to full size is
// mushy. That is the dual-filter (Kawase) shape, and both halves are
// needed - his two reports, "barely visible" then "feels low res",
// were exactly these two mistakes in turn.
// The radius is asked for in ROOM pixels: the app surface is the
// WINDOW's size, so a surface-space radius would change with the
// monitor. The project runs with interpolation OFF
// (options_windows), so both helpers restore gpu_set_tex_filter.
//
// ⚖️ SURFACES ARE VOLATILE: alt-tab, a resolution change or a device
// loss frees them. Every use re-checks surface_exists and rebuilds -
// never cache the handle.
// Room coords are not surface coords: the app surface is the WINDOW's
// size, so rectangles scale through the snap's own size. No hardcoded
// scale belongs in either script.

// ============================ TRAPS =================================
//   - Lower depth draws on top. Draw Begin is painted over by the
//     room's background; Draw End paints over the open menu. Stack by
//     depth instead.
//   - fnt is a sprite font: integer scale only, or glyphs shimmer.
//     Anchor text with floor().
