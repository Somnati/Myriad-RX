/// the profit-spitter (round 8: Myriad's obj_emit_part_bezier ported
/// onto obj_bezier_bit): one emitter drives a BURST - either ALL AT
/// ONCE (tic -1, the dial payout style) or BACK-TO-BACK one per tick
/// (tic 0+, the tap style; tic is frames between spawns). count is
/// the burst size - callers scale it with the event's YIELD (a 1-resin
/// tap spits exactly 1). spawn through bezier_bits(); it resolves the
/// target once and hands everything here. dies when spent.

count  = 1;      // bits left to spit
count_ = 1;      // the burst's original size (Myriad kept it for pacing)
tic    = 0;      // countdown to the next spit, frames
tic_   = -1;     // -1 = all at once / 0+ = frames between spits
col    = c_seagreen;
tx     = 48;
ty     = 12;
