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
// NOTE, since it looks like an omission: settings is NOT excluded. He
// wants the tapper live in there too (2026-09-08) - it is only pillbox
// presses that must not pay, and syst_input already handles those by
// raising g.input_block to ui_layer_popup for as long as a box exists.
// input_free() above is that guard; nothing extra is needed here.

// ---- THE PRESS ----
if (mouse_check_button_pressed(mb_left)) {
	hold_on = _ok;
	fx_tic  = 0;
	// ⚖️ THE LEAD, not a debt (his report: the hold has "a wind up after
	// the first tap"). The previous version seeded the accumulator at -1
	// so the press tap paid for the interval it started; that scales
	// with the rate, but at 8 a second it means the second tap lands two
	// intervals out - a quarter second of nothing, which is exactly the
	// wind-up he can feel.
	//
	// Now the accumulator starts at ZERO and RUNS from the press, but
	// payment is held for TAP_HOLD_LEAD frames. When the lead expires it
	// pays everything banked in one go, so:
	//   - the rhythm starts at ~183ms instead of 250ms, and the first
	//     hold tap arrives with a full interval already behind it
	//   - nothing is lost at any rate: at 1000/s the lead banks 183 taps
	//     and pays all of them the frame it ends
	//   - a tap still stays one tap, because 183ms clears a slow one
	// Some threshold is unavoidable here: the tap interval at 8/s is
	// 125ms and a human tap lasts 80-150, so the two genuinely overlap
	// and only a floor above both can separate them.
	tap_acc   = 0;
	hold_lead = TAP_HOLD_LEAD;
	if (hold_on) {
		array_push(tap_log, TPS_WINDOW);
		tap_fire(1, mouse_x, mouse_y, true);
		pop = 1;
	}
}

// ---- THE HOLD ----
// ⚖️ NO DRAG BUDGET (his report: "my hold to tap turns off when i move
// the mouse"). It used to cancel the hold once the pointer travelled
// 12px, because a held button was ALSO the visualiser's swipe-zoom -
// the tap surface is the whole room, so holding to tap and swiping to
// zoom were the same input and the tapper had to defend itself. The
// zoom gesture is gone now, and the only thing left in this room that
// wants a held drag is the dial drawer, which arms ONLY from its own
// right-edge band (syst_dials' press gate) - a press that starts on the
// tap surface can never reach it. So a hold survives the pointer
// wandering, which is what a hold is.
//
// The press still decides ONCE whether this is a tap surface (hold_on,
// above), so a press that began on a widget never becomes a hold.
if (!mouse_check_button(mb_left)) {
	hold_on = false;
	tap_acc = 0;
} else if (hold_on) {
	// ⚖️ THE CEREMONY CLOCK TICKS ON FRAMES, NOT ON BATCHES, which was
	// the other half of an earlier report ("it says 8tps but it's closer
	// to 1tps"). It used to be decremented inside the payout branch, so
	// it counted BATCHES: one effect every six, which at 8 taps a second
	// is 1.3 floats a second. The money was always right; the show was
	// rationed eight times too hard, and the show is the only part you
	// can see.
	fx_tic -= delta;

	// DE's click_v2 accumulator, verbatim in law: fractional taps at
	// rate/60 a frame, and the whole part paid in ONE call. This is the
	// entire reason a rate of 1000 is exact on a 60fps machine instead
	// of being silently clipped to 60 - see tap_fire. The press seeded
	// this at -1, so the first hold tap lands one interval after the tap
	// you already got, and a tap that never lasts that long stays a tap.
	tap_acc += (tap_rate() / 60) * delta;
	hold_lead -= delta;
	if (hold_lead <= 0 && tap_acc >= 1) {
		var _feed = floor(tap_acc);
		tap_acc -= _feed;

		// THE CEREMONY IS RATIONED, THE MONEY IS NOT. Past a dozen taps
		// a second the floats stop being readable and the motes only
		// fight the population cap, so the show runs on its own clock
		// while every tap is paid in full.
		var _fx = (fx_tic <= 0);
		if (_fx) fx_tic = TAP_FX_TIC;

		tap_fire(_feed, mouse_x, mouse_y, _fx);
		pop = 1;
	}
}

// ---- THE READOUT ----
// DE's obj_clicker: the shown rate EASES toward the true one, and eases
// faster while the button is down so a burst reads as a burst. What it
// eases toward is the manual count PLUS whatever the hold is
// contributing - one number for "how fast is this earning right now",
// however the taps are being produced.
var _target = _manual;
if (hold_on) _target += tap_rate();
var _sc = 3;
if (mouse_check_button(mb_left)) _sc = 1.5;
tps = trickle(tps, _target, _sc);
if (_target <= 0 && tps < 1) tps = 0;
