/// tour_visualizer - THE BLOCK VISUALISER  (engine/visualizer)
/// A TOUR SCRIPT: comments only, nothing runs.
/// Profit drawn as nested grids of coloured blocks, one order of
/// magnitude per nesting level, with an endless zoom. Built in the
/// techdemo, ported INTO DE and tuned there for the 144-wide portrait
/// room, then ported back to RX - so DE holds the newest version.

// ========================== THE FILES ===============================
//   obj_bignum5      the HOST in rm_clicker: seats the vis at the
//                    room's centre / third, feeds it the header's
//                    held-back figure each step, turns swipe-up/down
//                    into zoom, wires MYRIAD's tier palette, fades in.
//                    Display only: reads, never writes, game state.
//   bignum_visualizer_create()   the factory. Returns a struct with
//                    three parts and the small API a host calls
//                    (set_position, set_display_value, set_zoom_input,
//                    update, draw). Its header shows the full usage.
//   DigitWindow      which digits of the number are on screen at the
//                    current zoom. fake_digits is OFF: nothing draws
//                    smaller than one unit (his report - no squares
//                    below the white tier).
//   LODController    the continuous camera: which two fields are
//                    visible and how they cross-fade at a handoff.
//   BignumVisRenderer   the painter. A field is a 10x10 arrangement
//                    of flush squares; 100 squares of one field are
//                    pixel-identical to one square of the field above,
//                    which is what makes the zoom handoff invisible.
//                    Two grids per field (spr_vis_grid2), tinted the
//                    colour of the square they are becoming.
//   bignum_vis_magnitude / bignum_vis_mantissa_string   number helpers.
//   port_log_to_arb / port_vis_line / port_vis_square   the shims that
//                    let the renderer draw with the house primitives.
//   vis_tier_color   the tier -> colour lookup.
//   spr_line_10, spr_vis_grid2, spr_glow_sw   its art.

// ============================ PARKED ================================
// THE GLOW IS OFF (his call, twice confirmed): the additive
// spr_glow_sw pass BANDS on the 8-bit surface into a ringed halo.
// Bringing it back needs a dithered pass, not a toggle.
