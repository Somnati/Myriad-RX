// region UI by syst_input's rules: input free, nothing else owns the
// pointer. Every action here is a credit transaction, so none of it may
// fire under a menu or a dialogue.
sel = -1;
if (!input_free()) exit;
if (g.click_owner != noone) exit;

var _mx = mouse_x, _my = mouse_y;
var _n  = upgrade_slots();

// hover, for the wash the Draw paints
for (var _i = 0; _i < _n; _i++) {
	var _ry = __row_y(_i);
	if (point_in_rectangle(_mx, _my, row_x, _ry, row_x + row_w, _ry + row_h)) sel = _i;
}

if (!mouse_check_button_pressed(mb_left)) exit;

var _bk = __back_rect();
if (point_in_rectangle(_mx, _my, _bk.x1, _bk.y1, _bk.x2, _bk.y2)) {
	play_sound_ext(snd_matclick2, .8, .9, .5, 1);
	back_room();
	exit;
}

for (var _i = 0; _i < _n; _i++) {
	var _ry = __row_y(_i);
	var _s  = g.upg.slot[_i];
	// two buttons on a filled slot (buy + sell/discard), one on an empty
	// one (roll). The count drives the seat, so both must agree.
	var _bn = is_struct(_s) ? 2 : 1;
	for (var _b = 0; _b < _bn; _b++) {
		var _r = __btn(_b, _bn);
		if (!point_in_rectangle(_mx, _my, _r.x, _ry + 16, _r.x + _r.w, _ry + 16 + _r.h))
			continue;

		if (!is_struct(_s)) {
			// EMPTY: roll an offer into it
			if (upgrade_roll(_i) == -1)
				assign_banner("nothing to offer yet", c_gray, c_black);
			else
				play_sound_ext(snd_softclick, 1, 1.1, .5, 1);
			exit;
		}
		if (_b == 0) {
			// BUY - level it by one tier
			if (!upgrade_buy(_i))
				play_sound_ext(snd_matclick2, .7, .8, .35, 0);
			exit;
		}
		// SELL - refund part and free the slot. An unbought offer sells
		// for nothing, so this is also how you discard a roll you do not
		// want: DE's own answer to a bad offer, and the reason the table
		// never stalls on one.
		var _pay = upgrade_sell(_i);
		assign_banner(_pay > 0 ? "sold for " + string(_pay) + " credits"
		                       : "offer discarded", c_lavender, c_black);
		exit;
	}
}
