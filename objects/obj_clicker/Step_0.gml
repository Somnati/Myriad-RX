/// @description the tap - one press, or a held rate

// the press decay (feedback only)
pop = max(0, pop - .08 * delta);

// persistent now, so the surface re-reads whichever room it is
// standing in (rooms differ in size)
tap_y1 = room_height;

// ---- THE TAP LOG (Myriad DE's obj_tps) ----
// DE measures the MANUAL rate by spawning a token instance per press
// that lives exactly one second, then counting the population. Same
// law, no instances: each press pushes its remaining life here and the
// log ages by delta, so the count is always "presses in the last
// second" at any frame rate. It stays a handful of entries - a thumb
// cannot out-tap an array - and it is the half of the readout the hold
// rate cannot know about, because a person tapping fast is not the same
// event as a rate being applied.
for (var _i = array_length(tap_log) - 1; _i >= 0; _i--) {
	tap_log[_i] -= delta;
	if (tap_log[_i] <= 0) array_delete(tap_log, _i, 1);
}
var _manual = array_length(tap_log);

// tapping is live only inside a running game (see __live)
if (!__live()) {
	hold_on = false;
	tap_acc = 0;
	tps     = 0;
	exit;
}

// ---- IS THE POINTER SOMEWHERE THAT PAYS? ----
// arbitrated region pattern: a press the menu, a popup or any clickable
// widget already claimed is not ours
var _ok = input_free()
	&& (g.click_owner == noone)
	&& (mouse_y >= tap_y0)
	&& (mouse_y <= tap_y1)
	&& variable_global_exists("click_gps");
// the dial drawer claims ONLY its bars, buy buttons and docked strip
// (his rule: profit taps fire even with the dials open). It answers
// from the same rectangles its own tap handling uses, so a press on a
// bar is a UI action and a press beside it is a paid tap - never both.
if (_ok)
if (instance_exists(syst_dials))
	if (syst_dials.__consumes(mouse_x, mouse_y)) _ok = false;

// ---- THE PRESS ----
if (mouse_check_button_pressed(mb_left)) {
	hold_on = _ok;
	hold_x  = mouse_x;
	hold_y  = mouse_y;
	tap_acc = 0;
	fx_tic  = 0;
	hold_wait = TAP_HOLD_WAIT;
	if (hold_on) {
		array_push(tap_log, TPS_WINDOW);
		tap_fire(1, mouse_x, mouse_y, true);
		pop = 1;
	}
}

// ---- THE HOLD ----
// ⚖️ A HOLD IS ONLY A HOLD WHERE IT STARTED, AND ONLY WHILE IT STAYS
// STILL. Every gesture in this game is also a held button - the dial
// drawer's swipe, the tile drag, the visualiser's zoom swipe - so a
// hold that paid wherever the finger happened to be would charge the
// player's own gestures back at them as taps, and would open a drawer
// while paying for the privilege. The PRESS decides once whether this
// is a tap surface (hold_on, above); travelling past the drag budget
// hands the press over to whatever gesture wanted it. It is the same
// law the drawers were given on 2026-09-07, for the same reason.
if (!mouse_check_button(mb_left)) {
	hold_on = false;
	tap_acc = 0;
} else if (hold_on) {
	if (point_distance(hold_x, hold_y, mouse_x, mouse_y) > TAP_HOLD_DRAG) {
		hold_on = false;
		tap_acc = 0;
	} else {
		// ⚖️ A TAP IS NOT A SHORT HOLD (his report: "it does two taps
		// when i tap"). A human tap holds the button for 80-150ms, and
		// at 8 a second the accumulator crosses 1 inside 125ms - so an
		// ordinary tap paid the press tap AND its first hold tap. The
		// button has to be down past TAP_HOLD_WAIT before the hold means
		// anything, which is longer than any tap and shorter than any
		// deliberate hold.
		hold_wait -= delta;

		// ⚖️ THE CEREMONY CLOCK TICKS ON FRAMES, NOT ON BATCHES, and
		// that was the other half of his report ("it says 8tps but it's
		// closer to 1tps"). It used to be decremented inside the payout
		// branch, so it counted BATCHES: one effect every six batches,
		// which at 8 taps a second is 1.3 floats a second. The money was
		// always right - the show was rationed eight times too hard, and
		// the show is the only thing you can see.
		fx_tic -= delta;

		if (hold_wait <= 0) {
			// DE's click_v2 accumulator, verbatim in law: fractional
			// taps at rate/60 a frame, and the whole part paid in ONE
			// call. This is the entire reason a rate of 1000 is exact on
			// a 60fps machine instead of being silently clipped to 60.
			tap_acc += (tap_rate() / 60) * delta;
			if (tap_acc >= 1) {
				var _feed = floor(tap_acc);
				tap_acc -= _feed;

				// THE CEREMONY IS RATIONED, THE MONEY IS NOT. Past a
				// dozen taps a second the floats stop being readable and
				// the motes only fight the population cap, so the show
				// runs on its own clock while every tap is paid in full.
				var _fx = (fx_tic <= 0);
				if (_fx) fx_tic = TAP_FX_TIC;

				tap_fire(_feed, mouse_x, mouse_y, _fx);
				pop = 1;
			}
		}
	}
}

// ---- THE READOUT ----
// DE's obj_clicker: the shown rate EASES toward the true one, and eases
// faster while the button is down so a burst reads as a burst. What it
// eases toward is the manual count PLUS whatever the hold is
// contributing - one number for "how fast is this earning right now",
// however the taps are being produced.
var _target = _manual;
// only once the hold is actually paying - reporting a rate during the
// wait would be the readout lying about money that is not being earned
if (hold_on && hold_wait <= 0) _target += tap_rate();
var _sc = 3;
if (mouse_check_button(mb_left)) _sc = 1.5;
tps = trickle(tps, _target, _sc);
if (_target <= 0 && tps < 1) tps = 0;
