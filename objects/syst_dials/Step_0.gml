// the eased slide (trickle is the house motion idiom, and DE animates
// its own dial drawer the same way), then republish the face so
// obj_clicker's tap surface tracks it exactly
dpos = trickle(dpos, target, 5);
face = lerp(room_width - dock_w, row_x, dpos);

if (!variable_global_exists("dial")) exit;

// ---- keys: D pulls the drawer out, A sends it back ----
if (input_free()) {
	if (keyboard_check_pressed(ord("D"))) target = 1;
	if (keyboard_check_pressed(ord("A"))) target = 0;
}

// ---- pointer ----
if (!input_free()) { press_x = -1; exit; }

if (mouse_check_button_pressed(mb_left)) {
	press_x = mouse_x;
	press_y = mouse_y;
}

if (!mouse_check_button_released(mb_left)) exit;
if (press_x < 0) exit;
var _px = press_x, _py = press_y;
press_x = -1;

var _dx = mouse_x - _px;

// A SWIPE: left pulls the drawer out, right puts it away. Room-wide,
// so the gesture works from the tap surface too - the drawer's own
// physical direction, exactly like pulling a handle.
if (_dx <= -SWIPE) { target = 1; exit; }
if (_dx >=  SWIPE) { target = 0; exit; }

// under the drag budget it was a TAP
if (point_distance(_px, _py, mouse_x, mouse_y) > BUDGET) exit;

// docked: tapping the dot column pulls the drawer out
if (dpos < .5) {
	if (_px >= room_width - dock_w) target = 1;
	exit;
}

// out: a tap left of the drawer face puts it away
if (_px < face) { target = 0; exit; }

// out: a tap on a row buys it a level. DE splits these jobs (tapping a
// dial restarts its cycle, a separate button buys) which only matters
// once autonomy is an upgrade you earn - until then buying IS the
// interaction.
var _n = __rows();
for (var _i = 0; _i < _n; _i++) {
	var _ry = col_y0 + _i * row_p;
	if (_py < _ry || _py >= _ry + row_h) continue;
	if (dial_buy(_i, 1)) play_sound_ext(snd_matclick2, 1.05, 1.25, .5, 1);
	else                 play_sound_ext(snd_matclick, .6, .75, .35, 1);
	break;
}
