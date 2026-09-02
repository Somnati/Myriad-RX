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

// ============================ TRAPS =================================
//   - Lower depth draws on top. Draw Begin is painted over by the
//     room's background; Draw End paints over the open menu. Stack by
//     depth instead.
//   - fnt is a sprite font: integer scale only, or glyphs shimmer.
//     Anchor text with floor().
