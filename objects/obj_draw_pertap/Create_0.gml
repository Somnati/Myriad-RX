/// Myriad DE's obj_draw_pertap, ported (his ask, 2026-09-09: "port it
/// as is"). It sits top-left of the tap room and says what one tap is
/// worth at BASE - the number the whole game multiplies.
///
/// Every variable here is DE's. text_width is published rather than
/// used: DE kept it so something else could sit beside the readout
/// without measuring it again, and that is worth keeping even while
/// nothing reads it yet.
text_width = 0;
c_glow     = c_white;   // what the gradient's low end drifts toward
v_glow     = 0;         // ...and how far. DE never moved it off 0, so
                        // the number reads white-to-gray; a future
                        // crit/boost pulse has a lane to use
alpha      = 0;
