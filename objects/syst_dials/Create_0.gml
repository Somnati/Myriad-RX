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
// THE SEATS DERIVE FROM THE ROOM (2026-09-06), because the money room
// now exists in two shapes: rm_clicker 144x296 and rm_clicker_landscape
// 480x270. Every constant below reproduces DE's portrait number
// EXACTLY at 144x296 - they are the same seats written as offsets from
// the edges they were always measured against - and they follow the
// room when it is the wide one.
//   row_x  = where the open drawer's face lands. In portrait that is
//            2 (the column fills the room); in landscape it parks the
//            same 140px column against the RIGHT edge instead of
//            stranding it at the far left of a 480px room. 142 = the
//            bar (140) + its 2px gap; the stage-2 buy button needs
//            93 + 2 + 43 = 138, so it fits inside the same seat.
//   row_y1 = dial a's row, 40 up from the floor - the column still
//            grows UPWARD from under the thumb (DE's law). 296-40=256
//            portrait, 230 landscape, which keeps the fleet's two
//            headline numbers (row_y1 + 16 and + 26) on screen in a
//            270-tall room.
row_x  = max(2, room_width - 142);
row_y1 = room_height - 40;

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

// ---- THE BUY BULK BUTTON (Myriad DE's obj_ui_buylv) ----
// DE seats it TOP-RIGHT at (119, 31) and slides it in from off the
// right edge when the buy layer opens. spr_buylv (24x12) carries the
// look as frames: 0 face, 1 pressed face, 2..7 the mode glyphs
// x1 x10 x100 x1000 next max. Tap cycles g.buy_lv in DE's order.
// DE hid it until 3m lifetime profit; g.buylv_unlock (setgame) holds
// that gate and 0 switches it off (his ask 2026-09-03: he wants to
// see it).
// y 37, not DE's 31: the burger sits at (room_width - 15, 22) with its
// lower bar at y 26, and these buttons carry their labels ABOVE them at
// y - 4 - which put the text straight through the menu icon (his report
// 2026-09-06). Six pixels down clears the burger and drops the labels
// below the 29px header band as well.
bb_x  = room_width - 25; bb_y = 37;   // 119 in the 144 room
bb_w  = sprite_get_width(spr_buylv);
bb_h  = sprite_get_height(spr_buylv);
bb_cx = room_width + 3;          // live x, eased in Step
bb_down = false;                 // pressed face while held
__mode_gate = function() {
	if (!variable_global_exists("buylv_unlock") || g.buylv_unlock <= 0) return true;
	return (g.total_profit >= arb(g.buylv_unlock));
};
__mode_frame = function() {                  // spr_buylv's glyph frames
	if (g.buy_lv == 10)     return 3;
	if (g.buy_lv == 100)    return 4;
	if (g.buy_lv == 1000)   return 5;
	if (g.buy_lv == "next") return 6;
	if (g.buy_lv == "max")  return 7;
	return 2;
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
	var _seq = [1, 10, 100, 1000, "next", "max"];   // DE's order
	var _ix = 0;
	for (var _k = 0; _k < array_length(_seq); _k++)
		if (g.buy_lv == _seq[_k]) _ix = _k;
	g.buy_lv = _seq[(_ix + 1) mod array_length(_seq)];
};

// ---- THE VIEW BUTTON (Myriad DE's obj_hud_toggle_persecond) ----
// beside the buy button: x 122 at the list stage, tucking left to 98
// when the buy layer opens (DE parks it left of buylv). It picks what
// every row's rate readout shows - g.display_gps: 0 profit per CYCLE,
// 1 profit per SECOND (DE's other views belong to systems RX lacks).
// spr_hud_toggle_ps (18x12): 0 face, 1 pressed, 2 per cycle, 3 per
// second. Tap opens the house pillbox; the pick lands in _pselval.
vb_x1 = room_width - 22; vb_x2 = room_width - 46; vb_y = 36; // 122 / 98
vb_w  = sprite_get_width(spr_hud_toggle_ps);
vb_h  = sprite_get_height(spr_hud_toggle_ps);
vb_cx = room_width + 2;
vb_down = false;
pillbox_init();

// THE QUOTE CACHE: what the current mode would buy per row, as
// dial_buy_ext dry runs - refreshed on a slow tick because "max"
// bisects dial_cost per row, which is cheap once but not 13 x 144 hz.
quote = array_create(variable_global_exists("dial_total") ? g.dial_total : 13, undefined);
qtic  = 0;
qmode = -1;

// THE DRAWER'S BACKDROP, third attempt and the one that fits.
//   1. a gaussian EFFECT LAYER - always full screen, so it could only
//      be switched on in portrait, where full screen happens to be the
//      drawer's width.
//   2. a region BLUR - worked in both shapes, but read as a smear
//      rather than as glass: the visualiser's grid lines survived every
//      radius as soft rectangles, and the glow layer had already spread
//      the light before the capture saw it, so it blurred a blur.
//   3. a region PIXELATION, his call. It suits the game: this is a
//      pixel-art screen, and blocks read as deliberate where a soft
//      wash reads as a mistake. 3 ROOM pixels a block.
// blur_snap / draw_blur_region are PARKED, not deleted - they work, and
// the next panel that wants glass can have them.
//
// ⚖️ THE PROXY'S DEPTH IS THE WHOLE DESIGN: everything drawn before it
// is in the snapshot, everything after is not. 0 sits after the room,
// the visualiser and the entire fx stack (40/30/20), and before the
// drawer (-20) and the header (-1000) - so the drawer pixelates the
// room and never itself.
// Only while the drawer is out: a full-surface capture every frame to
// feed a panel nobody can see is pure cost. The proxy is at depth 0 and
// the drawer at -20, so on the frame the slide starts the capture still
// runs FIRST and the snapshot is ready in time.
__snap_cap = function() { if (sp > 0) pixel_snap(3); };
snap_px = create_obj(0, 0, obj_draw_proxy);
snap_px.owner = id;
snap_px.depth = 0;
snap_px.fn    = __snap_cap;

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

/// THE DOCKED DOT'S SEAT. His report (2026-09-04): the dots did not
/// line up with the bars they turn into. They had their own tighter
/// pitch of 11 against the rows' 16, so the error grew with the index -
/// dial a was close, dial m sat sixty pixels from its row, and opening
/// the drawer slid every dot to a different place. ONE PITCH now: the
/// dot is centred on exactly the row it becomes, so the drawer opens
/// as a widening, not a re-shuffle.
__dot_y = function(_i) {
	return row_y1 - _i * row_p + row_h * .5;
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
	// DOCKED: nothing here answers a tap any more - the drawer opens by
	// swipe only (his call, 2026-09-04) - so the strip must not swallow
	// one either. His standing rule: the thumb earns anywhere the
	// drawer is not actually using the pixels. A swipe still STARTS
	// here; the drag budget is what tells the two apart.
	if (sp < .5) return false;
	var _n  = __rows();
	var _bw = lerp(row_w, row_w2, clamp(sp - 1, 0, 1));
	var _x2 = face + _bw;
	if (stage >= 2) _x2 += 2 + sprite_get_width(spr_button_bevel);
	// DE's two top-right buttons
	if (stage >= 2 && __mode_gate())
		if (point_in_rectangle(_px, _py, bb_cx, bb_y, bb_cx + bb_w, bb_y + bb_h)) return true;
	if (point_in_rectangle(_px, _py, vb_cx, vb_y, vb_cx + vb_w, vb_y + vb_h)) return true;
	if (_px < face || _px >= _x2) return false;
	for (var _i = 0; _i < _n; _i++) {
		var _ry = row_y1 - _i * row_p;
		if (_py >= _ry - 2 && _py < _ry + row_h + 2) return true;
	}
	return false;
};
