/// syst_dials - THE DIAL DRAWER, in Myriad DE's own shape.
/// THREE STAGES, each a swipe LEFT (or D) further out; swipe right or A
/// walks back:
///   0 DOCKED  the collapsed dot column at the right edge
///   1 LIST    the full 140px dial bars
///   2 BUY     the bars narrow to 93px and DE's buy buttons appear
/// DE does exactly this with obj_dragautos (the bars) and
/// obj_dragautoupgrades (the second layer, where it sets width to
/// 79+14 = 93 to make room) - the widths here are its widths.
/// THE REVEAL RULE (DE's): you see the dials you own plus the NEXT one,
/// so the ladder unfolds as you climb it.

// rm_clicker depth plan (LOWER DRAWS ON TOP): header -1000 |
// syst_dials -20 | obj_clicker 0 | obj_bignum5 50 | Background 100.
depth = -20;

// ---- the drawer ----
stage  = 0;   // 0 docked / 1 list / 2 buy
sp     = 0;   // the eased position between stages
dock_w = 12;  // the docked strip: the dot column and the grab handle

// ---- the rows: DE's geometry ----
// spr_dial is 140x11 and DE seats its column LOW (obj_dial y 270,
// obj_dial_position y 256, pitch sprite_height+5), the stack growing
// UPWARD - so one row sits under your thumb and thirteen still clear
// the header.
row_w  = 140; // stage 1
row_w2 = 93;  // stage 2, DE's narrowed width
row_h  = 11;  // spr_dial's height
row_p  = 16;  // DE's pitch
row_x  = 2;
row_y1 = 256; // dial a's row; everything else stacks up from here

// THE WIND-UP is dial_config's `autoeff` - read, never redeclared, so
// this view and update_dial's timer maths cannot drift apart. It is a
// VIEW transform, not a second timer: update_dial already stretches the
// cycle by the same fraction, so the sim never forks.
//   gps_perc = (cycle - autoeff) / (1 - autoeff)

// per-dial spring radius for the docked dot (DE runs its own wiggle
// spring on des_size; this is the same overshoot, kept view-side)
rd = [];
for (var _i = 0; _i < (variable_global_exists("dial_total") ? g.dial_total : 13); _i++)
	rd[_i] = 0;

// ---- gesture state (menu2's rule: taps land on RELEASE under a drag
// budget, so a swipe never doubles as a tap) ----
press_x = -1;
press_y = -1;
SWIPE   = 40;
BUDGET  = 7;

// the drawer face's left edge, republished every Step. obj_clicker
// READS this rather than recomputing it, so the tap surface and the
// drawer can never disagree about where the edge is.
face = room_width - dock_w;

/// how many rows to draw: every owned dial, plus one unbought
__rows = function() {
	if (!variable_global_exists("dial")) return 0;
	var _n = 0;
	for (var _i = 0; _i < g.dial_total; _i++)
		if (g.dial[_i].level > 0) _n = _i + 1;
	return min(g.dial_total, _n + 1);
};

/// a dial's VISIBLE progress: zero through the wind-up, then 0..1
__perc = function(_i, _d) {
	var _a = dial_config(_i).autoeff;
	return clamp((_d.cycle - _a) / (1 - _a), 0, 1);
};

/// is this dial still winding up? (the "..." on its timer)
__wind = function(_i, _d) {
	return (_d.cycle < dial_config(_i).autoeff);
};
