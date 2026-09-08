// THE CREDIT PANEL IS PINNED HERE (his call, DE's obj_display_credits).
// Every price on this screen is in credits, so the balance has to be
// visible the whole time rather than for three seconds after a drop.
// desy is DE's protocol: a REQUEST, consumed and cleared by the panel
// each frame, so a screen that stops asking releases it without having
// to remember to. It sits under the table rather than at its default
// y 46, where it would land on top of the second row.
if (instance_exists(obj_display_credits)) {
	obj_display_credits.pin  = true;
	obj_display_credits.desy = room_height - 24;
}

// region UI by syst_input's rules: input free, nothing else owns the
// pointer. Every action here is a credit transaction, so none of it may
// fire under a menu or a dialogue.
sel = -1;
if (!input_free() || g.click_owner != noone) { hold_hp = 0; hold_i = -1; exit; }

var _mx = mouse_x, _my = mouse_y;
var _n  = upgrade_slots();

// hover, for the wash the Draw paints
for (var _i = 0; _i < _n; _i++) {
	var _ry = __row_y(_i);
	if (point_in_rectangle(_mx, _my, row_x, _ry, row_x + row_w, _ry + row_h)) sel = _i;
}

// ---- THE HOLD-TO-SELL FILL (DE's rate: 100 units in 40 frames) ----
// It runs BEFORE the press tests, because it is driven by the button
// being DOWN rather than by the frame it went down.
var _held = mouse_check_button(mb_left);
if (!_held) hold_lock = false;

var _want = -1;
if (mode == 1 && _held && !hold_lock)
for (var _i = 0; _i < _n; _i++) {
	if (!is_struct(g.upg.slot[_i])) continue;
	var _r = __btn(_i);
	if (point_in_rectangle(_mx, _my, _r.x, _r.y, _r.x + _r.w, _r.y + _r.h)) _want = _i;
}

if (_want != hold_i) { hold_i = _want; hold_hp = 0; }
if (hold_i == -1) {
	// DE trickles it home rather than snapping, so letting go early
	// reads as the bar draining instead of the bar vanishing
	hold_hp = trickle(hold_hp, 0, 5);
} else {
	hold_hp += (100 / 40) * delta;
	if (hold_hp >= 100) {
		var _pay = upgrade_sell(hold_i);
		assign_banner("sold for " + string(_pay) + " credits", c_lavender, c_black);
		hold_hp = 0;
		hold_i  = -1;
		// DE's hp = -1: the hold is spent until the button comes up, so
		// one press is one sale however long it is held
		hold_lock = true;
		exit;
	}
}

if (!mouse_check_button_pressed(mb_left)) exit;

var _bk = __back_rect();
if (point_in_rectangle(_mx, _my, _bk.x1, _bk.y1, _bk.x2, _bk.y2)) {
	play_sound_ext(snd_matclick2, .8, .9, .5, 1);
	back_room();
	exit;
}

// ---- the mode toggle ----
for (var _m = 0; _m < 2; _m++) {
	var _r = __mode_rect(_m);
	if (!point_in_rectangle(_mx, _my, _r.x, _r.y, _r.x + _r.w, _r.y + _r.h)) continue;
	if (mode != _m) {
		mode = _m;
		play_sound_ext(snd_softclick, 1, 1.1, .45, 0);
	}
	exit;
}

// ---- THE ONE ROLL BUTTON ----
var _rr = __roll_rect();
if (point_in_rectangle(_mx, _my, _rr.x, _rr.y, _rr.x + _rr.w, _rr.y + _rr.h)) {
	var _fs = __free_slot();
	if (_fs == -1) {
		assign_banner("no free slot", c_gray, c_black);
		exit;
	}
	var _r0 = upgrade_roll(_fs);
	if (_r0 == -1)
		assign_banner("nothing to offer yet", c_gray, c_black);
	else if (_r0 == -2)
		assign_banner("not enough credits to roll", c_hred, c_black);
	else
		play_sound_ext(snd_softclick, 1, 1.1, .5, 1);
	exit;
}

// ---- the rows ----
for (var _i = 0; _i < _n; _i++) {
	var _r = __btn(_i);
	if (!point_in_rectangle(_mx, _my, _r.x, _r.y, _r.x + _r.w, _r.y + _r.h)) continue;
	var _s = g.upg.slot[_i];
	if (!is_struct(_s)) continue;   // an empty row has no button now

	if (mode == 0) {
		// BUY - one more tier
		if (!upgrade_buy(_i)) play_sound_ext(snd_matclick2, .7, .8, .35, 0);
		exit;
	}

	// SELL is not a click - it is the HOLD above, which fires as the bar
	// lands. A press here does nothing on purpose: a destructive action
	// should never happen on the frame a finger touches down.
	exit;
}
