// ---- the eased slide (skipped while a finger owns the drawer) ----
// a new target restarts the clock FROM WHERE IT IS, so reversing
// mid-slide is smooth rather than a jump back to the start
if (!drag_on) {
	if (sp_to != stage) { sp_from = sp; sp_to = stage; sp_t = 0; }
	if (sp_t < 1) {
		sp_t = min(1, sp_t + (delta / 60) / SP_TIME);
		var _e = sp_t * sp_t * (3 - 2 * sp_t);   // smoothstep
		sp = lerp(sp_from, sp_to, _e);
	} else sp = sp_to;                            // exact arrival, no snap
}

// republish the face so obj_clicker's tap surface tracks it exactly
var _dp = clamp(sp, 0, 1);
face = lerp(room_width - dock_w, row_x, _dp);

if (!variable_global_exists("dial")) exit;

// the docked dot's spring: the radius chases the cycle (DE's des_size
// = progress SQUARED) and gets a kick on payout, then settles
var _n = __rows();
for (var _i = 0; _i < _n; _i++) {
	var _d = g.dial[_i];
	var _t = (_d.level > 0) ? sqr(__perc(_i, _d)) * (row_h * .5) : 0;
	if (_d.paid) {
		rd[_i] = row_h * .5 + 2;   // the pop

		// THE SPIT (DE's obj_dial do_spit): a completed cycle throws
		// profit motes at the counter. They wear THE PROFIT COLOUR, not
		// the dial's - every mote in the game is the same money (his
		// call), and the dot they leave from already says which dial
		// paid. tic -1 = the whole burst at once, the payout style; the
		// count rides the size of the payout the way DE's does.
		var _sx = room_width - dock_w * .5;         // docked: the dot
		var _sy = row_y1 - _i * 11 + 5;
		if (sp >= .5) {                              // out: the bar
			_sx = face + 39;
			_sy = row_y1 - _i * row_p + row_h * .5;
		}
		var _nb = 1;
		if (_d.gpc >= arb(2)) _nb = choose(1, 2);
		if (_d.gpc >= arb(5)) _nb = round(random_range(1, 5));
		bezier_bits(_sx, _sy, _nb, g.profit_color, undefined, undefined, -1,
			_d.paid_amt);
	}
	rd[_i] = min(trickle(rd[_i], _t, 4), row_h);
}

// ---- keys: D walks the drawer out, A walks it back ----
if (input_free()) {
	if (keyboard_check_pressed(ord("D"))) stage = min(2, stage + 1);
	if (keyboard_check_pressed(ord("A"))) stage = max(0, stage - 1);
}

// ---- pointer ----
if (!input_free()) { press_x = -1; drag_on = false; exit; }

if (mouse_check_button_pressed(mb_left)) {
	press_x   = mouse_x;
	press_y   = mouse_y;
	drag_from = sp;
	drag_on   = false;
}

// LIVE DRAG: once the press clears the budget the drawer tracks the
// finger, so the pull has weight in the hand instead of happening
// after the fact
if (press_x >= 0 && mouse_check_button(mb_left)) {
	var _tr = press_x - mouse_x;             // pulling LEFT opens
	if (!drag_on && abs(_tr) > BUDGET) drag_on = true;
	if (drag_on) sp = clamp(drag_from + _tr / DRAG_PX, 0, 2);
}

if (!mouse_check_button_released(mb_left)) exit;
if (press_x < 0) exit;
var _px = press_x, _py = press_y;
press_x = -1;

var _dx = mouse_x - _px;

// RELEASING A DRAG: a decisive flick throws it a whole stage from
// where the drag STARTED; anything gentler settles at the nearest
// stage to where the finger left it. Either way the ease takes over
// from the drawer's current position, so nothing jumps.
if (drag_on) {
	drag_on = false;
	if (abs(_dx) >= SWIPE)
		stage = clamp(drag_from + ((_dx < 0) ? 1 : -1), 0, 2);
	else
		stage = clamp(round(sp), 0, 2);
	sp_from = sp; sp_to = stage; sp_t = 0;
	exit;                                    // a drag is never a tap
}

// a flick that never became a drag still throws the drawer
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
