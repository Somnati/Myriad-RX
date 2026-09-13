// ---- THE OPEN/CLOSE EASE (the overlay contract) ----
oa = move_to(oa, closing ? 0 : 1, closing ? UI_OUT_SPD : UI_IN_SPD);
if (abs(oa - (closing ? 0 : 1)) < .004) oa = closing ? 0 : 1;
if (closing && oa <= 0) { instance_destroy(); exit; }
// the modifiers list eases too
// (move_to's third argument is a DIVISOR - .12 sent it past 8 and the
// sheet flickered, his "broken visually")
mod_a = clamp(move_to(mod_a, mod_open ? 1 : 0, 4), 0, 1);
if (abs(mod_a - (mod_open ? 1 : 0)) < .01) mod_a = mod_open ? 1 : 0;

// THE CREDIT PANEL IS PINNED HERE (his call, DE's obj_display_credits).
// Every price on this screen is in credits, so the balance has to be
// visible the whole time rather than for three seconds after a drop.
// desy is DE's protocol: a REQUEST, consumed and cleared by the panel
// each frame, so a screen that stops asking releases it without having
// to remember to. It sits in the BOTTOM-LEFT CORNER under the totals
// band (the overhaul) rather than at its default y 46, where it would
// land on top of the second row.
// ...on the strip's bottom line, above the table (his ask, 2026-09-12)
// ⚖️ AFTER THE PANEL HAS ARRIVED (his report, 2026-09-13: the upgrades'
// entrance felt off). The purse used to be pinned from the first frame:
// it slid in from the left edge on its own trickle and glided its y
// from 46 down to the strip - a second animation on a different clock
// laid over the panel's fade. It is seated at the strip BEFORE it is
// visible now, and asked for only once the panel has settled, so it
// slides in once, level, as its own small arrival
if (instance_exists(obj_display_credits) && !closing) {
	if (obj_display_credits.move <= 0) obj_display_credits.y = purse_y;   // seated while unseen
	if (oa >= .999) {
		obj_display_credits.pin  = true;
		obj_display_credits.desy = purse_y;
	}
}

msg_hp = max(0, msg_hp - delta);

// region UI by syst_input's rules: input free, nothing else owns the
// pointer. Every action here is a credit transaction, so none of it may
// fire under a menu or a dialogue.
sel = -1;
// only once the panel has fully arrived, and only while nothing sits
// over it (a pillbox, a popup, the menu) - the overlay's own rung
if (oa < .999 || closing || !input_free(ui_layer_overlay)
|| (variable_global_exists("click_owner") && g.click_owner != noone)) {
	hold_hp = 0; hold_i = -1; hold_spd = 1; exit;
}
if (keyboard_check_pressed(vk_escape)) {
	if (mod_open) mod_open = false; else upgrades_close();
	exit;
}
// THE MODIFIERS LIST owns the pointer while it is up: any tap folds it
if (mod_open || mod_a > .01) {
	hold_hp = 0; hold_i = -1;
	if (mouse_check_button_pressed(mb_left)) {
		mod_open = false;
		play_sound_ext(snd_softclick, .95, 1.05, .4, 1);
	}
	exit;
}

var _mx = mouse_x, _my = mouse_y;
var _n  = upgrade_slots();

// hover, for the wash the Draw paints
for (var _i = 0; _i < _n; _i++) {
	var _ry = __row_y(_i);
	if (point_in_rectangle(_mx, _my, row_x, _ry, row_x + row_w, _ry + row_h)) sel = _i;
}

// ---- THE HOLD FILL (DE's rate: 100 units in 40 frames) ----
// It runs BEFORE the press tests, because it is driven by the button
// being DOWN rather than by the frame it went down.
var _held = mouse_check_button(mb_left);
if (!_held) { hold_lock = false; hold_spd = 1; }

var _want = -1;
if (_held && !hold_lock)
for (var _i = 0; _i < _n; _i++) {
	if (!is_struct(g.upg.slot[_i])) continue;
	// a slot that cannot be bought does not fill: an unaffordable or
	// finished row should refuse at a glance, not after two thirds of
	// a second of holding
	if (mode == 0) {
		var _c0 = upgrade_cost(_i);
		if (_c0 < 0 || !(g.credits >= arb(_c0))) continue;
	}
	var _r = __btn(_i);
	if (point_in_rectangle(_mx, _my, _r.x, _r.y, _r.x + _r.w, _r.y + _r.h)) _want = _i;
}

if (_want != hold_i) { hold_i = _want; hold_hp = 0; hold_spd = 1; }
if (hold_i == -1) {
	// DE trickles it home rather than snapping, so letting go early
	// reads as the bar draining instead of the bar vanishing
	hold_hp = trickle(hold_hp, 0, 5);
} else {
	hold_hp += (100 / 40) * hold_spd * delta;
	if (hold_hp >= 100) {
		hold_hp = 0;
		if (mode == 0) {
			// BUY, and KEEP GOING. DE's hp_spd climbs by half a step per
			// landed purchase to a ceiling of 7, so a held row buys
			// faster the longer you hold it. The hold survives; it ends
			// by itself when the slot completes, empties or runs out of
			// credits, because the scan above stops offering it.
			var _was = hold_i;
			if (upgrade_buy(hold_i)) {
				hold_spd = min(7, hold_spd + .5);
				pick = _was;
				// the last tier files the upgrade and frees the slot
				// (upgrade_complete). The banner that used to announce
				// that is refused in this room, so say it here.
				if (!is_struct(g.upg.slot[_was])) {
					__say("complete - slot freed", c_gold);
					pick   = -1;
					hold_i = -1;
				}
			} else { hold_i = -1; hold_lock = true; }
		} else {
			var _pay = upgrade_sell(hold_i);
			__say("sold for " + string(_pay) + " credits", c_lavender);
			if (pick == hold_i) pick = -1;
			hold_i = -1;
			// DE's hp = -1: spent until the button comes up, so one
			// press is one sale however long it is held
			hold_lock = true;
		}
		exit;
	}
}

if (!mouse_check_button_pressed(mb_left)) exit;

// ---- [modifiers]: the totals, as a list over the panel ----
var _md = __mod_rect();
if (point_in_rectangle(_mx, _my, _md.x, _md.y, _md.x + _md.w, _md.y + _md.h)) {
	mod_open = true;
	play_sound_ext(snd_softclick, 1, 1.1, .45, 1);
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

// ---- THE ROLL ROW (the first empty row IS the roll control) ----
// Before the pick loop, because it is an empty row and the pick loop
// would otherwise swallow the tap as "nothing to describe"
var _rr = __roll_rect();
if (_rr.w > 0 && point_in_rectangle(_mx, _my, _rr.x, _rr.y, _rr.x + _rr.w, _rr.y + _rr.h)) {
	var _fs = __free_slot();
	var _r0 = upgrade_roll(_fs);
	if (_r0 == -1)
		__say("nothing to offer yet", c_gray);
	else if (_r0 == -2)
		__say("not enough credits to roll", c_hred);
	else {
		play_sound_ext(snd_softclick, 1, 1.1, .5, 1);
		pick = _fs;   // a fresh roll is the thing you want to read about
	}
	exit;
}

// ---- PICKING A ROW for the inspector ----
// Before the buttons, and it does not consume the press: a tap on a
// row's body picks it, a tap on its button still acts. An EMPTY row
// picks nothing - there is nothing to describe - but it clears the
// panel, which is the honest answer to "what is in this slot".
for (var _i = 0; _i < _n; _i++) {
	var _bd = __body(_i);
	if (!point_in_rectangle(_mx, _my, _bd.x, _bd.y, _bd.x + _bd.w, _bd.y + _bd.h))
		continue;
	pick = is_struct(g.upg.slot[_i]) ? _i : -1;
	play_sound_ext(snd_softclick, 1.1, 1.2, .3, 0);
	exit;
}

// ---- the rows ----
for (var _i = 0; _i < _n; _i++) {
	var _r = __btn(_i);
	if (!point_in_rectangle(_mx, _my, _r.x, _r.y, _r.x + _r.w, _r.y + _r.h)) continue;
	var _s = g.upg.slot[_i];
	if (!is_struct(_s)) continue;   // an empty row has no button now

	// NEITHER MODE ACTS ON A PRESS any more - both are the HOLD above,
	// which fires as its bar lands. The one thing a press still does is
	// complain when the row could never fill: the scan above silently
	// skips an unaffordable or finished slot, and silence on a button
	// you are pressing reads as the screen being broken.
	pick = _i;   // the button is part of the row - reading it too
	if (mode == 0) {
		var _c1 = upgrade_cost(_i);
		if (_c1 < 0 || !(g.credits >= arb(_c1))) {
			play_sound_ext(snd_matclick2, .7, .8, .35, 0);
			__say((_c1 < 0) ? "already at its last tier"
			                : "not enough credits", c_hred);
		}
	}
	exit;
}
