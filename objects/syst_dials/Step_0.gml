// the eased slide between stages, then republish the face so
// obj_clicker's tap surface tracks it exactly
sp   = trickle(sp, stage, 5);
var _dp = clamp(sp, 0, 1);
face = lerp(room_width - dock_w, row_x, _dp);

if (!variable_global_exists("dial")) exit;

// the docked dot's spring: the radius chases the cycle (DE's des_size
// = progress SQUARED) and gets a kick on payout, then settles
var _n = __rows();
for (var _i = 0; _i < _n; _i++) {
	var _d = g.dial[_i];
	var _t = (_d.level > 0) ? sqr(__perc(_d)) * (row_h * .5) : 0;
	if (_d.paid) rd[_i] = row_h * .5 + 2;   // the pop
	rd[_i] = min(trickle(rd[_i], _t, 4), row_h);
}

// ---- keys: D walks the drawer out, A walks it back ----
if (input_free()) {
	if (keyboard_check_pressed(ord("D"))) stage = min(2, stage + 1);
	if (keyboard_check_pressed(ord("A"))) stage = max(0, stage - 1);
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

// A SWIPE: left pulls the drawer further out, right walks it back.
// Room-wide, so it works from the tap surface too - the drawer's own
// physical direction, like pulling a handle.
if (_dx <= -SWIPE) { stage = min(2, stage + 1); exit; }
if (_dx >=  SWIPE) { stage = max(0, stage - 1); exit; }

// under the drag budget it was a TAP
if (point_distance(_px, _py, mouse_x, mouse_y) > BUDGET) exit;

// docked: tapping the dot column pulls the drawer out
if (sp < .5) {
	if (_px >= room_width - dock_w) stage = 1;
	exit;
}

// a tap left of the drawer face puts it away
if (_px < face) { stage = 0; exit; }

// ---- a tap on a row ----
var _bw = lerp(row_w, row_w2, clamp(sp - 1, 0, 1));
for (var _i = 0; _i < _n; _i++) {
	var _ry = row_y1 - _i * row_p;         // dial a lowest, stacking up
	if (_py < _ry - 2 || _py >= _ry + row_h + 2) continue;
	var _d = g.dial[_i];

	// STAGE 2: the buy button to the right of the narrowed bar
	if (stage >= 2 && _d.level > 0) {
		if (_px >= face + _bw + 2) {
			if (dial_buy(_i, 1)) play_sound_ext(snd_matclick2, 1.05, 1.25, .5, 1);
			else                 play_sound_ext(snd_matclick, .6, .75, .35, 1);
		}
		break;
	}

	// A DORMANT DIAL BUYS FROM ITS OWN BAR at any stage - DE's rule:
	// tapping an unpurchased dial is how you purchase it
	if (_d.level <= 0) {
		if (dial_buy(_i, 1)) play_sound_ext(snd_matclick2, 1.05, 1.25, .5, 1);
		else                 play_sound_ext(snd_matclick, .6, .75, .35, 1);
	}
	break;
}
