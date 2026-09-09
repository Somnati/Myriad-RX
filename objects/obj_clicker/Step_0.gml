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
	tap_acc = 0;
	if (hold_on) {
		// ⚖️ DE'S SHAPE, EXACTLY (his ask - the lead was still a wind-up).
		// click_v2 does not special-case the press at all: it adds ONE
		// WHOLE TAP to the same accumulator the hold rate feeds, and the
		// single payout below sees it cross 1 on that very frame. So the
		// press pays instantly and the first hold tap lands exactly one
		// interval later - which is the soonest it can land without
		// charging twice for the same instant. There is no lead left to
		// feel, because there is no lead.
		//
		// What DE relies on to keep an ordinary tap worth one tap is its
		// RATE: cc starts at 6, so the interval is 167ms and a human tap
		// (80-150ms) finishes inside it. TAP_HOLD_BASE is the same knob
		// here. Above about 7 a second the interval drops under a slow
		// tap and a lingering press earns two - which is what DE does
		// too, once you have bought a faster thumb.
		tap_acc  += 1;
		tap_press = true;
		array_push(tap_log, TPS_WINDOW);
	}
}

// ---- THE HOLD ----
// ⚖️ NO DRAG BUDGET (his report: "my hold to tap turns off when i move
// the mouse"). It used to cancel the hold once the pointer travelled
// 12px, because a held button was ALSO the visualiser's swipe-zoom. The
// zoom gesture is gone, and the only thing left in this room that wants
// a held drag is the dial drawer, which arms ONLY from its own
// right-edge band - a press that starts on the tap surface can never
// reach it. So a hold survives the pointer wandering, which is what a
// hold is.
if (!mouse_check_button(mb_left)) {
	hold_on = false;
	tap_acc = 0;   // DE's `if released tap[dev] = 0`
} else if (hold_on) {
	// THE CEREMONY CLOCK TICKS ON FRAMES, NOT ON BATCHES. It used to be
	// decremented inside the payout branch, so it counted batches: one
	// effect every six, which at 8 taps a second is 1.3 floats a second.
	fx_tic -= delta;
	tap_acc += (tap_rate() / 60) * delta;
}

// ---- ONE PAYOUT, press and hold alike ----
// DE's click_v2 has a single `if (tap[dev] >= 1)` and so does this. The
// press reaches it with a whole tap already banked; the hold reaches it
// whenever the rate has earned one. Same call, same crit roll, same
// batching - and nothing has to decide which kind of tap it was except
// the SHOW.
if (hold_on && tap_acc >= 1) {
	var _feed = floor(tap_acc);
	tap_acc -= _feed;

	// THE CEREMONY IS RATIONED, THE MONEY IS NOT - except a press, which
	// always performs. It is the one tap the player actually made.
	var _fx = tap_press;
	if (!_fx && fx_tic <= 0) {
		_fx = true;
		fx_tic = TAP_FX_TIC;
	}
	tap_fire(_feed, mouse_x, mouse_y, _fx, !tap_press);
	tap_press = false;
	pop = 1;
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
