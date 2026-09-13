// ---- the eased slide (skipped while a finger owns the drawer) ----
// a new target restarts the clock FROM WHERE IT IS, so reversing
// mid-slide is smooth rather than a jump back to the start
// sp is the eased animation toward stage and NOTHING else writes it
// (the live drag that used to is gone - see the swipe block below), so
// the drawer can never be left sitting between stages.
if (!unfold_has("dials")) { stage = 0; face = room_width; exit; }   // the drawer arrives with the first dial (the unfold)
{
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
sfx_tic -= delta;

var _n = __rows();
for (var _i = 0; _i < _n; _i++) {
	var _d = g.dial[_i];
	var _t = (_d.level > 0) ? sqr(__perc(_i, _d)) * (row_h * .5) : 0;
	if (_d.paid) {
		rv[_i] += WIG_PUSH;   // a KICK, not a jump - see the Create

		// ⚖️ THE CYCLE SOUND, RATE LIMITED (his ask, 2026-09-08). Chosen
		// in settings > audio, OFF by default, and throttled here rather
		// than in sfx_play because the limit belongs to the EVENT and not
		// to the roster: a late fleet finishes several cycles a second
		// across every dial at once, so without a clock this is six
		// samples stacking per frame and the mix disappears under it.
		// One sound per window however many dials landed in it - the
		// feedback is "the fleet paid", not "dial D paid".
		if (sfx_tic <= 0) {
			sfx_tic = SFX_DIAL_TIC;
			sfx_play("dial");
		}

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
	// AN AUTOBUY LANDED (his list, 2026-09-12: automation should be
	// visible where you play): sparks in the dial's colour from the
	// same seat, and the count floats off the bar - the hand-buy's
	// ceremony, so the game reads as working for you
	if ((_d[$ "auto_n"] ?? 0) > 0) {
		var _ax = (sp >= .5) ? (face + 39) : (room_width - dock_w * .5);
		var _ay = __dot_y(_i);
		spark_burst(_ax, _ay, choose(2, 3, 4), dial_color(_i));
		if (sp >= .5) float_text(_ax + 30, _ay - 6, "auto +" + string(_d.auto_n), dial_color(_i), fnt_outline);
		_d.auto_n = 0;
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

// ⚖️ THE TILE TABLE'S MULTIPLIER, once a frame (his question,
// 2026-09-10: "why am i making billions p/s when my tapper and dials
// only show to be in the k's/m's?"). Because the dial profit boost
// multiplies every dial payout by (1 + board output x f(level) / 100)
// - see tile_dial_boost - and the rows were quoting the RAW gpc/gps,
// the figure before that multiply. A 200k/s board at profit level 5
// is a x4000 on the fleet; the row said 1m and the bank took 4b. The
// rows read the boosted figure now - what the dial actually pays -
// the same honesty the tapper's readout got.
tb = tile_dial_boost();

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
if (!input_free()) { press_x = -1; exit; }

if (mouse_check_button_pressed(mb_left)) {
	// ARMED ONLY FROM THE RIGHT EDGE BAND, unless the drawer is already
	// out - then a press anywhere may push it back, so it can never be
	// stuck open. Gating the ARMING rather than the whole event matters:
	// an early exit here would also skip the row taps, the core picker
	// and the buy buttons that the rest of this Step owns.
	// ...and never a press a clickable owns: the fullscreen button
	// sits in this very band (syst_input's owner - the tile board's
	// rule, which this drawer lacked)
	var _owned = variable_global_exists("click_owner") && g.click_owner != noone;
	// SWIPE PROTECTION (settings > input, DE's): with it on, the close
	// swipe has to START on the drawer's own side too - a press on the
	// room's far half is the room's, drawer open or not
	var _near = !(variable_global_exists("swipe_protect") && g.swipe_protect)
		|| mouse_x >= face - 24;
	if ((mouse_x >= room_width - SW_EDGE || (stage > 0 && _near)) && !_owned) {
		press_x    = mouse_x;
		press_y    = mouse_y;
		hold_fired = false;
	} else press_x = -1;
}

// pressed faces for the two buttons (DE's frame 1 while held)
var _held = (press_x >= 0 && mouse_check_button(mb_left));
bb_down = _held && stage >= 2 && point_in_rectangle(mouse_x, mouse_y, bb_cx, bb_y, bb_cx + bb_w, bb_y + bb_h);
vb_down = _held && point_in_rectangle(mouse_x, mouse_y, vb_cx, vb_y, vb_cx + vb_w, vb_y + vb_h);

// ---- THE HAND-CRANK (his ask, 2026-09-11): which dial the pointer is
// held on, for prod_dials - with the cycling switched off that dial
// runs at full rate while held and freezes when released ----
g.dial_hold = -1;
if (_held && sp >= .5) {
	var _bwh = lerp(row_w, row_w2, clamp(sp - 1, 0, 1));
	if (mouse_x >= face && mouse_x < face + _bwh)
	for (var _i = 0; _i < _n; _i++) {
		var _ry = row_y1 - _i * row_p;
		if (mouse_y < _ry - 2 || mouse_y >= _ry + row_h + 2) continue;
		if (g.dial[_i].level > 0) g.dial_hold = _i;
		break;
	}
}

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

// ⚖️ THE LIVE DRAG IS GONE (his call, 2026-09-09: "i dont want the dial
// dock to open when i click and drag it open... only be a swipe").
// Dragging it out was the whole problem: it meant ANY press that moved
// sideways was a partial open, and once the drawer was partly out it
// settled to the nearest stage on release. A click-drag and an
// accidental hand movement are the same gesture at different speeds,
// and no distance threshold separates them.
//
// It is a SWIPE OR NOTHING now. sp is purely the eased animation toward
// stage - nothing else writes it - which also means the drawer can no
// longer be left sitting between stages.

// ================= THE SWIPE, MYRIAD DE'S GATE =================
// ⚖️ FIVE CONDITIONS, AND EVERY ONE OF THEM REJECTS SOMETHING REAL. This
// is DE's obj_dragupgrades test, ported whole (his ask: look at how DE
// does it), off the touch tracker RX already had - syst_touchscreen has
// been measuring all five since the port and nothing was reading them.
//
//   DISTANCE FLOOR    a twitch is not a swipe
//   DISTANCE CEILING  and neither is a long haul. THIS is the one I did
//                     not have and the one that matters most for him: a
//                     hand that travels half the room is doing
//                     something else, however fast it got there.
//   TIME CEILING      held too long is not a swipe either - his exact
//                     ask. A swipe is a FLICK OF THE WRIST, and a wrist
//                     takes well under 45 frames.
//   SPEED FLOOR       slow is not a swipe.
//   DIRECTION CONE    +/-45 degrees of the axis. A diagonal drag past
//                     the edge is not a request to open a side drawer.
//
// No single one of these separates intent from accident. Together they
// describe a gesture a hand does on purpose and essentially never does
// by mistake, which is why DE shipped all five rather than tuning one.
//
// It fires WHILE HELD, like DE's - the drawer answers the moment the
// gesture qualifies rather than waiting for the finger to come up, and
// sw_tic keeps it from re-firing for the rest of the press.
//
// ⚖️ A HAND ON THE PUCK OR A DIE IS NOT A HAND ON THE DRAWER (his ask,
// 2026-09-10 - the tile drawer's rule for a held tile). Throwing the
// puck is a fast horizontal drag from wherever it sits, which is the
// exact shape of an open swipe; scooping a die is a press that moves.
// While either has the pointer the press stops being the drawer's for
// the rest of the press - the arm is dropped, not merely skipped.
if (press_x >= 0) {
	if (instance_exists(obj_puck) && obj_puck.held) press_x = -1;
	if (variable_global_exists("dice_scoop") && g.dice_scoop) press_x = -1;
	// and a window that just moved or resized under the pointer is not
	// a hand on the drawer either (syst_touchscreen's hold)
	if (touch_jump > 0) press_x = -1;
}
sw_tic = max(0, sw_tic - delta);
if (sw_tic <= 0)
if (touching_screen || mouse_check_button_released(mb_left))
if (press_x >= 0)
if (touch_dragdist > SW_DIST_MIN)
if (touch_dragdist < touch_dragdist_min)
if (touch_time    < touch_time_min)
if (touch_dragspd > touch_dragspd_min) {
	// the drawer lives on the RIGHT, so opening it is a swipe LEFT
	// (direction 180) and closing it is a swipe RIGHT (0/360).
	var _d = touch_dir;
	if (_d >= 135 && _d <= 225) {
		stage = min(2, stage + 1);
		sw_tic = SW_COOL;
		press_x = -1;
		exit;
	}
	if (_d <= 45 || _d >= 315) {
		stage = max(0, stage - 1);
		sw_tic = SW_COOL;
		press_x = -1;
		exit;
	}
}

if (!mouse_check_button_released(mb_left)) exit;
if (press_x < 0) exit;
var _px = press_x, _py = press_y;
press_x = -1;

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
