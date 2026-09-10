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
swing  = -1;     // the motes' curve: -1 Myriad's room-wide throw, else px
spdm   = 1;      // the motes' pace multiplier (see bezier_bits)
lane   = "profit"; // which settings pill dresses the motes (bit_look)
dep    = -90;    // the motes' depth (bezier_bits; the tiles spawn under the board)

// the profit this burst still owes the counter: bezier_bits sets amt
// to the whole payout and share to one mote's cut. amt drains as motes
// spawn and each mote carries its share onward, so the total in flight
// is always (this emitter's amt) + (every live mote's amt).
amt    = 0;
share  = 0;
