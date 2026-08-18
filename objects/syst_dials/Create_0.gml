/// syst_dials - THE DIAL DRAWER. Docked off the right edge; swipe LEFT
/// (or press D) pulls it out, swipe right (or A) sends it back.
/// This is Myriad DE's own shape: DE keeps the dial column collapsed at
/// the right of rm_clicker as a stack of coloured dots (obj_dial's
/// Draw_72 circles) and obj_dragautos expands them into full-width
/// rows. The dots are not decoration - each one BREATHES with its
/// dial's cycle and flashes on payout, so the closed drawer is still
/// the production readout.
/// THE REVEAL RULE (DE's): you see the dials you own plus the NEXT one,
/// so the ladder unfolds as you climb it rather than showing thirteen
/// locked rows on a fresh save.

// rm_clicker depth plan (LOWER DRAWS ON TOP): header -1000 |
// syst_dials -20 | obj_clicker 0 | obj_bignum5 50 | the room's opaque
// Background layer 100. Anything deeper than 100 is behind the black
// fill and never appears.
depth = -20;

// ---- the drawer ----
dpos   = 0;   // eased 0 (docked) .. 1 (out)
target = 0;   // where it is heading
dock_w = 12;  // the docked strip: the dot column, and the grab handle.
              // set to 0 for a drawer that hides completely.

// ---- the rows: Myriad DE's own geometry ----
// spr_dial is 140x11 and DE seats its column LOW in the room
// (obj_dial y 270, obj_dial_position y 256, pitch sprite_height+5).
// The stack grows UPWARD from the bottom, so a fresh save's one row
// sits where your thumb already is and thirteen dials still clear the
// header - it can never crawl up behind it.
row_w  = 140;
row_h  = 11;  // spr_dial's height
row_p  = 16;  // DE's pitch: sprite_height + 5
row_x  = 2;   // resting x once fully out
row_y1 = 256; // DE's anchor: dial a's row, everything else stacks up

// ---- gesture state (menu2's rule: taps land on RELEASE under a drag
// budget, so a swipe never doubles as a tap) ----
press_x = -1;
press_y = -1;
SWIPE   = 40; // release distance that counts as a swipe
BUDGET  = 7;  // a press that travels less than this is a tap

// the drawer face's left edge, republished every Step. obj_clicker
// READS this rather than recomputing the geometry, so the tap surface
// and the drawer can never disagree about where the edge is (a plain
// variable, not a method - reading one across objects is unambiguous).
face = room_width - dock_w;

/// how many rows to draw: every owned dial, plus one unbought
__rows = function() {
	if (!variable_global_exists("dial")) return 0;
	var _n = 0;
	for (var _i = 0; _i < g.dial_total; _i++)
		if (g.dial[_i].level > 0) _n = _i + 1;
	return min(g.dial_total, _n + 1);
};
