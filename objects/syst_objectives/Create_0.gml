/// syst_objectives - THE OBJECTIVE CARD (his spec, 2026-09-13: "a list
/// of objectives you have to complete 1 by 1 with some sort of text
/// based popup active in the clicker room... docked somewhere in the
/// top left"). Persistent, spawned by syst_handle_save's Create; draws
/// only in the money room, only once the veil has lifted, only while
/// the chain has an objective left. The card is the CURRENT objective
/// (objective_cur): its name, and its steps each behind a checkbox -
/// ticked ones filled green and dimmed, the rest waiting. Steps are
/// LIVE: a tick flashes its box (his "future sound"); a step that
/// stops holding empties again with a red flash (his ask). The last
/// tick holds the card a moment in green ("complete"), the card goes
/// away for THE BREATH (OBJ_GAP seconds, objective_tick), and the next
/// objective slides in from the left with its notification sound.
/// A tap on the card opens the panel (syst_objectives_panel) - the
/// detailed list. Draw-only over g.obj; objective_tick is the runner.
///
/// Depth -1100: over the drawer (-20) and the toys, under the veil
/// (-1500) and the overlays' furniture. Hidden while an overlay or the
/// menu is up (the panel IS the detailed version; a card under it
/// would be the same words twice).

if (instance_number(syst_objectives) > 1) { kill; exit; }
depth = -1100;
persistent = true;

a     = 0;      // presence, eased
slide = 1;      // the arrival, 0 -> 1 (from the left)
okey   = "";     // the objective the card shows (held through the celebration)
cel   = 0;      // seconds of celebration left after a completion
se    = [];     // per-step ease toward ticked, 0..1
sf    = [];     // per-step flash on the tick (green), 1 -> 0
sr    = [];     // per-step flash on a FALL-OFF (red), 1 -> 0
st    = [];     // per-step truth last frame (a tick that happens vs one already there)
heard = "";     // the objective the announcement sound has played for

// ---- THE COLLAPSE (his ask, 2026-09-13: "collapses after it's been open
// for a bit to only show the checkmarks. hovering over it should push it
// out slightly and clicking it should expand it until i click it again")
//   op      the open ease, 0 collapsed (the boxes in a row) .. 1 the card
//   open_t  seconds the card has been open this time; past OBJ_CARD_HOLD
//           it folds. Anything that changes the card - a new objective,
//           a tick, a fall-off, the celebration - re-opens it
//   pin     clicked open: it stays until clicked again
//   hov     the pointer is on it; peek eases toward 1 and pushes the
//           folded strip out a few px
op     = 1;
open_t = 0;
pin    = false;
hov    = false;
peek   = 0;

// ---- the seat: top left, under the per-tap readout and the credit
// chip (both live at y 28..56); as wide as the room allows ----
__cw = function() { return (room_width > 300) ? 172 : (room_width - 6); };
__cx = function() { return 3; };
__cy = function() { return 62 + (variable_global_exists("profit") ? ui_wordline_h() : 0); };

/// @func __lines(o)
/// @desc the card's rows for an objective: [{ txt, h, done, i }] - each
///       step's text wrapped to the card, its height from the wrap
__lines = function(_o) {
	var _out = [];
	if (is_undefined(_o)) return _out;
	draw_set_font(fnt);
	var _tw = __cw() - 24;
	for (var _i = 0; _i < array_length(_o.steps); _i++) {
		var _t = _o.steps[_i].txt;
		array_push(_out, { txt : _t, h : string_height_ext(_t, 9, _tw) + 3, done : objective_step_done(_o, _i), i : _i });
	}
	return _out;
};

/// @func __rect_full()
/// @desc the card, open
__rect_full = function() {
	var _o = objective_by_key(okey);
	var _ls = __lines(_o);
	var _h = 16;
	for (var _i = 0; _i < array_length(_ls); _i++) _h += _ls[_i].h;
	return { x : __cx(), y : __cy(), w : __cw(), h : _h + 3 };
};
/// @func __rect_mini()
/// @desc the strip: the boxes in a row behind the rule, nothing else
__rect_mini = function() {
	var _o = objective_by_key(okey);
	var _n = is_undefined(_o) ? 0 : array_length(_o.steps);
	return { x : __cx(), y : __cy(), w : 10 + _n * 9 + 2, h : 12 };
};
/// @func __rect()
/// @desc the card's rectangle NOW, between the two on the open ease (the
///       region law: the Step's hit and the Draw share it; obj_clicker
///       asks __consumes off it). The hover peek pushes it out
__rect = function() {
	var _f = __rect_full(), _m = __rect_mini();
	var _e = op * op * (3 - 2 * op);
	return { x : _f.x + peek * 5, y : _f.y, w : lerp(_m.w, _f.w, _e), h : lerp(_m.h, _f.h, _e) };
};

/// @func __consumes(mx, my)
/// @desc a press on the card is the card's, never a paid tap
__consumes = function(_mx, _my) {
	if (a < .5 || okey == "") return false;
	var _r = __rect();
	return point_in_rectangle(_mx, _my, _r.x, _r.y, _r.x + _r.w, _r.y + _r.h);
};
