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

// THE SLIDE, on a timed smoothstep rather than trickle. trickle is an
// exponential chase: it decelerates forever and never actually
// arrives, so it carries a hardpoint that snaps the last 1% to the
// target - which at this travel is the visible pop at the end of the
// slide. A normalised clock through smoothstep eases in AND out and
// lands exactly, with no hardpoint to snap.
sp_from = 0;   // where the slide started
sp_to   = 0;   // where it is going
sp_t    = 1;   // 0..1 through the move (1 = settled)
SP_TIME = .26; // seconds end to end
// A RELEASED DRAG IS ALREADY MOVING. smoothstep eases IN from a dead
// stop, so settling a flick with it stalled the drawer for an instant
// before it resumed - the stutter he felt. Releases ease OUT only:
// they start at speed and decelerate into the stage.
sp_ease_out = false;

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
SWIPE   = 26;   // a flick this far throws the drawer a whole stage
BUDGET  = 6;    // under this, the press was a tap

// THE DRAWER FOLLOWS THE FINGER. Waiting for release before moving is
// what made it feel sticky - you pulled and nothing happened until you
// let go. Past the drag budget it tracks 1:1, and the release just
// decides which stage to settle into.
drag_on   = false;
drag_from = 0;
DRAG_PX   = 110; // pixels of travel per stage

// ---- THE BUY MODE BUTTON (Myriad DE's obj_ui_buylv, "buy bulk") ----
// lives at the top of the buy stage, above the highest possible row
// (thirteen rows stack up from 256 to 64; this sits at 20). Tap cycles
// g.buy_lv through DE's order x1 -> x10 -> x100 -> x1000 -> max -> x1
// ("next" rejoins when milestones land). DE's own gate, kept: the
// button stays hidden until 3 million lifetime profit, so the early
// game is one dial, one level, one tap.
mb_y = 20;
mb_w = sprite_get_width(spr_button_bevel);   // 43, the buy buttons' width
mb_h = sprite_get_height(spr_button_bevel);  // 15
__mode_gate  = function() { return (g.total_profit >= arb(3000000)); };
__mode_label = function() {
	if (g.buy_lv == "max")  return "max";
	if (g.buy_lv == "next") return "next";
	return "x" + string(g.buy_lv);
};
__mode_color = function() {                  // DE's tints per mode
	if (g.buy_lv == 10)     return c_rarity_uncommon;
	if (g.buy_lv == 100)    return c_rarity_rare;
	if (g.buy_lv == 1000)   return c_rarity_epic;
	if (g.buy_lv == "next") return c_sgreen;
	if (g.buy_lv == "max")  return c_gold;
	return c_white;
};
__mode_cycle = function() {
	var _seq = [1, 10, 100, 1000, "max"];     // >>> MILESTONES: add "next" before "max"
	var _ix = 0;
	for (var _k = 0; _k < array_length(_seq); _k++)
		if (g.buy_lv == _seq[_k]) _ix = _k;
	g.buy_lv = _seq[(_ix + 1) mod array_length(_seq)];
};

// THE QUOTE CACHE: what the current mode would buy per row, as
// dial_buy_ext dry runs - refreshed on a slow tick because "max"
// bisects dial_cost per row, which is cheap once but not 13 x 144 hz.
quote = array_create(variable_global_exists("dial_total") ? g.dial_total : 13, undefined);
qtic  = 0;
qmode = -1;

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

/// does a PRESS at (px, py) land on something the drawer OWNS - a live
/// row, its buy button, or the docked grab strip? obj_clicker asks this
/// before paying a tap. HIS RULE (2026-09-02): the thumb earns on every
/// screen, dials open or not - so the drawer only claims the bars and
/// buttons themselves, and the dimmed space around them still pays.
/// Same rectangles as the tap handling in Step, so the two can't drift.
__consumes = function(_px, _py) {
	if (!variable_global_exists("dial")) return false;
	if (sp < .5) return (_px >= room_width - dock_w);   // the dot strip
	var _n  = __rows();
	var _bw = lerp(row_w, row_w2, clamp(sp - 1, 0, 1));
	var _x2 = face + _bw;
	if (stage >= 2) _x2 += 2 + sprite_get_width(spr_button_bevel);
	if (stage >= 2 && __mode_gate())            // the buy-mode button
		if (point_in_rectangle(_px, _py, face + 2, mb_y, face + 2 + mb_w, mb_y + mb_h))
			return true;
	if (_px < face || _px >= _x2) return false;
	for (var _i = 0; _i < _n; _i++) {
		var _ry = row_y1 - _i * row_p;
		if (_py >= _ry - 2 && _py < _ry + row_h + 2) return true;
	}
	return false;
};
