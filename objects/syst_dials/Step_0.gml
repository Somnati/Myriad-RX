// ---- the eased slide (skipped while a finger owns the drawer) ----
// a new target restarts the clock FROM WHERE IT IS, so reversing
// mid-slide is smooth rather than a jump back to the start
if (!drag_on) {
	if (sp_to != stage) {
		sp_from = sp; sp_to = stage; sp_t = 0;
		sp_ease_out = false;                  // key/tap: starts at rest
	}
	if (sp_t < 1) {
		sp_t = min(1, sp_t + (delta / 60) / SP_TIME);
		// ease-out for a release (already moving), smoothstep for a
		// key or tap (starting from rest)
		var _e = sp_ease_out
			? 1 - (1 - sp_t) * (1 - sp_t)
			: sp_t * sp_t * (3 - 2 * sp_t);
		sp = lerp(sp_from, sp_to, _e);
	} else sp = sp_to;                            // exact arrival, no snap
}

// republish the face so obj_clicker's tap surface tracks it exactly
var _dp = clamp(sp, 0, 1);
face = lerp(room_width - dock_w, row_x, _dp);


// DE's two top-right buttons ride in from off the right edge: the view
// button with the list, the buy-bulk button with the buy layer (and the
// view button tucks left to make room, DE's parking)
var _bp0 = clamp(sp - 1, 0, 1);
bb_cx = lerp(room_width + 3, bb_x, _bp0);
vb_cx = lerp(room_width + 2, lerp(vb_x1, vb_x2, _bp0), _dp);

// ---- the view pick: the pillbox hands it back on this instance ----
if (_pselid != -1) {
	g.display_gps = _pselval;
	_pselid = -1;
	save_mark_dirty();
}

if (!variable_global_exists("dial")) exit;

// the docked dot's spring: the radius chases the cycle (DE's des_size
// = progress SQUARED) and gets a kick on payout, then settles
var _n = __rows();
for (var _i = 0; _i < _n; _i++) {
	var _d = g.dial[_i];
	var _t = (_d.level > 0) ? sqr(__perc(_i, _d)) * (row_h * .5) : 0;
	if (_d.paid) {
		rv[_i] += WIG_PUSH;   // a KICK, not a jump - see the Create

		// THE SPIT (DE's obj_dial do_spit): a completed cycle throws
		// profit motes at the counter. They wear THE PROFIT COLOUR, not
		// the dial's - every mote in the game is the same money (his
		// call), and the dot they leave from already says which dial
		// paid. tic -1 = the whole burst at once, the payout style; the
		// count rides the size of the payout the way DE's does.
		var _sx = room_width - dock_w * .5;         // docked: the dot
		var _sy = __dot_y(_i);
		// out: the bar. Only the X moves now - the dot and the bar
		// share one seat, so a payout leaves from the same height
		// whichever face the drawer is wearing.
		if (sp >= .5) _sx = face + 39;
		var _nb = 1;
		if (_d.gpc >= arb(2)) _nb = choose(1, 2);
		if (_d.gpc >= arb(5)) _nb = round(random_range(1, 5));
		bezier_bits(_sx, _sy, _nb, g.profit_color, undefined, undefined, -1,
			_d.paid_amt);

		// AND DE'S SPARKS (obj_eff_shardspark): one to three pixels
		// thrown out of the same seat, wearing THE DIAL'S colour rather
		// than the profit colour. That split is the whole point of
		// having both - the motes are the money leaving, the sparks are
		// the machine that made it.
		spark_burst(_sx, _sy, choose(1, 2, 3), dial_color(_i));
	}
	// the spring, both terms delta-correct
	rv[_i] += (_t - rd[_i]) * WIG_K * delta;
	rv[_i] *= power(WIG_DAMP, delta);
	rv[_i]  = clamp(rv[_i], -10, 10);
	rd[_i] += rv[_i] * delta;
	// the floor absorbs rather than bounces: a dot resting at zero with
	// a bounce in it would jitter forever
	if (rd[_i] < 0) { rd[_i] = 0; rv[_i] = max(0, rv[_i]); }
	rd[_i] = min(rd[_i], row_h);
}

// ---- the buy quotes (slow tick, and at once when the mode changes) ----
qtic -= delta;
if (sp > .9 && (qtic <= 0 || qmode != g.buy_lv)) {
	qtic  = 6;
	qmode = g.buy_lv;
	for (var _i = 0; _i < _n; _i++)
		quote[_i] = (g.dial[_i].level > 0) ? dial_buy_ext(_i, g.buy_lv, false) : undefined;
}

// ---- keys: D walks the drawer out, A walks it back ----
if (input_free()) {
	if (keyboard_check_pressed(ord("D"))) stage = min(2, stage + 1);
	if (keyboard_check_pressed(ord("A"))) stage = max(0, stage - 1);
}

// ---- pointer ----
if (!input_free()) { press_x = -1; drag_on = false; exit; }

if (mouse_check_button_pressed(mb_left)) {
	// ARMED ONLY FROM THE RIGHT EDGE BAND, unless the drawer is already
	// out - then a press anywhere may push it back, so it can never be
	// stuck open. Gating the ARMING rather than the whole event matters:
	// an early exit here would also skip the row taps, the core picker
	// and the buy buttons that the rest of this Step owns.
	if (mouse_x >= room_width - SW_EDGE || stage > 0) {
		press_x    = mouse_x;
		press_y    = mouse_y;
		drag_from  = sp;
		drag_on    = false;
		hold_fired = false;
	} else press_x = -1;
}

// pressed faces for the two buttons (DE's frame 1 while held)
var _held = (press_x >= 0 && mouse_check_button(mb_left) && !drag_on);
bb_down = _held && stage >= 2 && point_in_rectangle(mouse_x, mouse_y, bb_cx, bb_y, bb_cx + bb_w, bb_y + bb_h);
vb_down = _held && point_in_rectangle(mouse_x, mouse_y, vb_cx, vb_y, vb_cx + vb_w, vb_y + vb_h);

// ---- THE MANUAL START (Myriad DE's click_dial): the pointer HELD on a
// dial that is still winding up skips the wind-up - its cycle jumps to
// the end of the spin-up and the bar starts filling now, with DE's
// autostart sound (softer the deeper the drawer is out). Held rather
// than tapped, so a finger dragged down the column starts every dial
// it crosses - DE's feel. Fires once per dial: after the jump the
// cycle is no longer under autoeff.
if (_held && sp >= .5) {
	var _bw0 = lerp(row_w, row_w2, clamp(sp - 1, 0, 1));
	if (mouse_x >= face && mouse_x < face + _bw0)
	for (var _i = 0; _i < _n; _i++) {
		var _ry = row_y1 - _i * row_p;
		if (mouse_y < _ry - 2 || mouse_y >= _ry + row_h + 2) continue;
		var _d = g.dial[_i];
		var _ae = dial_config(_i).autoeff;
		if (_d.level > 0 && _d.cycle < _ae) {
			_d.cycle = _ae;
			_d.glow  = max(_d.glow, .5);
			play_sound_ext(snd_autostart, .8, 1.2, (stage >= 2) ? .1 : .2, 0);
		}
		break;
	}
}

// ---- HOLD TO KEEP BUYING (DE's ctic; see the Create for why the
// trigger differs). Two laws, both DE's:
//   SPEED  five frames between buys to start, one fewer for every two
//          seconds held, down to every frame at ten seconds
//   FADE   volume and haptic ease to 5% over six seconds, so holding
//          settles into a quiet rattle instead of a jackhammer
if (_held && stage >= 2) {
	var _bw3 = lerp(row_w, row_w2, clamp(sp - 1, 0, 1));
	var _hr  = -1;
	if (mouse_x >= face + _bw3 + 2)
		for (var _i = 0; _i < _n; _i++) {
			var _hy = row_y1 - _i * row_p;
			if (mouse_y >= _hy - 2 && mouse_y < _hy + row_h + 2)
			if (g.dial[_i].level > 0) { _hr = _i; break; }
		}
	// sliding onto a different button restarts the clock, so the
	// acceleration can never carry over to a row you just arrived at
	if (_hr != hold_row) { hold_row = _hr; hold_t = 0; hold_ct = HOLD_LEAD; }
	if (_hr != -1) {
		hold_t  += delta;
		hold_ct -= delta;
		if (hold_ct <= 0) {
			hold_ct = max(0, 5 - floor(hold_t / 120));
			var _hq = dial_buy_ext(_hr, g.buy_lv, true);
			qtic = 0;
			if (_hq.ok) {
				hold_fired = true;
				var _dm = lerp(1, .05, clamp(hold_t / 120, 0, 3) / 3);
				play_sound_ext(snd_matclick2, 1.05, 1.25, .5 * _dm, round(_dm));
			}
			else hold_row = -1;   // ran out of money: stop, silently
		}
	}
}
else { hold_row = -1; hold_t = 0; hold_ct = HOLD_LEAD; }

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
	sp_ease_out = true;                      // carry the finger's speed
	// a shorter settle for a release: the finger did most of the
	// travel, so a full-length ease reads as sluggish
	exit;                                    // a drag is never a tap
}

// a flick that never became a drag still throws the drawer
if (_dx <= -SWIPE) { stage = min(2, stage + 1); exit; }
if (_dx >=  SWIPE) { stage = max(0, stage - 1); exit; }

// under the drag budget it was a TAP
if (point_distance(_px, _py, mouse_x, mouse_y) > BUDGET) exit;

// DOCKED: THE DRAWER OPENS BY SWIPE ONLY (his call, 2026-09-04).
// Tapping the dot column used to pull it out, so a thumb earning near
// the right edge kept opening the dials on him. The flick tests above
// (and D) are the only way out now; a tap here is just a tap, and
// obj_clicker pays it.
if (sp < .5) exit;

// a tap left of the drawer face puts it away
if (_px < face) { stage = 0; exit; }

// ---- the buy bulk button (buy stage) ----
if (stage >= 2 && __mode_gate())
if (point_in_rectangle(_px, _py, bb_cx, bb_y, bb_cx + bb_w, bb_y + bb_h)) {
	__mode_cycle();
	qtic = 0;                               // requote every row now
	play_sound_ext(snd_softclick, .9, 1.1, .4, 1);
	exit;
}

// ---- the view button: DE's pillbox of views ----
if (point_in_rectangle(_px, _py, vb_cx, vb_y, vb_cx + vb_w, vb_y + vb_h)) {
	pillbox_init();
	// DE's three views, abbreviated as he asked. "%" is DE's third
	// (obj_hud_toggle_persecond's mode 2, "per centage"): the dial's
	// share of the whole fleet's output
	set_pill("p/c", { val : 0, col : c_rarity_common, enabled : (g.display_gps == 0) });
	set_pill("p/s", { val : 1, col : c_steelblue,     enabled : (g.display_gps == 1) });
	set_pill("%",   { val : 2, col : c_gold,          enabled : (g.display_gps == 2) });
	do_pillbox(room_width, vb_y + vb_h * .5);
	play_sound_ext(snd_softclick, .9, 1.1, .4, 1);
	exit;
}

// ---- a tap on a row ----
var _bw = lerp(row_w, row_w2, clamp(sp - 1, 0, 1));
for (var _i = 0; _i < _n; _i++) {
	var _ry = row_y1 - _i * row_p;         // dial a lowest, stacking up
	if (_py < _ry - 2 || _py >= _ry + row_h + 2) continue;
	var _d = g.dial[_i];

	// STAGE 2: the buy button to the right of the narrowed bar
	if (stage >= 2 && _d.level > 0) {
		// a hold already bought - the release must not buy once more
		if (hold_fired) { hold_fired = false; break; }
		if (_px >= face + _bw + 2) {
			// the buy in the LIVE MODE (x1 buys one; x10 buys up to the
			// next ten; max buys the pile's worth) - see buy_resolve
			var _q = dial_buy_ext(_i, g.buy_lv, true);
			qtic = 0;                           // requote after a buy
			if (_q.ok) play_sound_ext(snd_matclick2, 1.05, 1.25, .5, 1);
			else       play_sound_ext(snd_matclick, .6, .75, .35, 1);
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
