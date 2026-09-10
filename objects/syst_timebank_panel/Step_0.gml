/// the panel's pulse: the open ease, the quotes on the slow tick, then
/// the taps. Region law - every hit here mirrors Draw's geometry exactly.

// ---- THE OPEN/CLOSE EASE (the overlay contract) ----
oa = move_to(oa, closing ? 0 : 1, closing ? UI_OUT_SPD : UI_IN_SPD);
if (abs(oa - (closing ? 0 : 1)) < .004) oa = closing ? 0 : 1;
if (closing && oa <= 0) { instance_destroy(); exit; }

burn_hp = max(0, burn_hp - delta);

qtic -= delta;
if (qtic <= 0) {
	qtic = 15;
	var _qc = timebank_upg("cap", false);
	q_cap  = { ok : _qc.ok, cost : _qc.cost, maxed : false,
		txt : crunch_time_long(_qc.cost * 60) };
	var _qr = timebank_upg("rate", false);
	q_rate = { ok : _qr.ok, cost : _qr.cost, maxed : _qr.maxed,
		txt : _qr.maxed ? "max" : crunch_time_long(_qr.cost * 60) };
}

// ---- input: only once the panel has fully arrived, and only while
// nothing sits over it (a dropdown, the menu) ----
if (oa < .999 || closing) exit;
if (!input_free(ui_layer_popup)) exit;
if (keyboard_check_pressed(vk_escape)) { timebank_close(); exit; }
if (variable_global_exists("click_owner") && g.click_owner != noone) exit;
if (!mouse_check_button_pressed(mb_left)) exit;

// ---- the speed pills ----
// Engaging a speed with an empty bank would be dropped by
// timebank_spend on the very next frame, so it buzzes instead of
// pretending to work.
if (mouse_y >= spd_y && mouse_y < spd_y + 16)
for (var _k = 0; _k < NSPD; _k++) {
	var _px = spd_x0 + _k * (spd_w + spd_gap);
	if (mouse_x < _px || mouse_x >= _px + spd_w) continue;
	if (g.timebank.spd == spds[_k]) exit;
	if (_k > 0 && g.timebank.bank <= 0) {
		play_sound_ext(snd_matclick, .6, .75, .35, 1);
		float_text(_px + spd_w * .5, spd_y - 8, "bank empty", c_hred);
		exit;
	}
	g.timebank.spd = spds[_k];
	save_mark_dirty();
	play_sound_ext(snd_softclick, 1 + _k * .05, 1.1 + _k * .05, .4, 1);
	exit;
}

// ---- THE BURN BUTTONS ----
// Each spends its own length of bank at once. One you cannot afford
// refuses with the buzz rather than paying a partial amount: half of
// ten minutes is not what the button said.
if (mouse_y >= burn_y && mouse_y < burn_y + 16)
for (var _k = 0; _k < NBURN; _k++) {
	var _bx = burn_x0 + _k * (burn_w + burn_gap);
	if (mouse_x < _bx || mouse_x >= _bx + burn_w) continue;
	var _want = burns[_k];
	if (g.timebank.bank < _want) {
		play_sound_ext(snd_matclick, .6, .75, .35, 1);
		float_text(_bx + burn_w * .5, burn_y - 8, "not banked", c_hred);
		exit;
	}
	var _got = timebank_burn(_want);
	play_sound_ext(snd_matclick2, 1.05, 1.25, .5, 1);
	float_text(_bx + burn_w * .5, burn_y - 8,
		"+" + ((_got > 0) ? crunch_arb(_got) : "0"), g.profit_color,
		fnt_outline);
	burn_msg = "burned " + crunch_time_long(_want * 60) + " for "
		+ ((_got > 0) ? crunch_arb(_got) : "0") + " profit";
	burn_hp = 240;
	exit;
}

// ---- the two upgrade buttons ----
for (var _r = 0; _r < 2; _r++) {
	var _ry = upg_y + _r * upg_h;
	if (point_in_rectangle(mouse_x, mouse_y, upg_x + upg_w - 62, _ry + 1,
		upg_x + upg_w - 2, _ry + 15)) {
		var _q = timebank_upg((_r == 0) ? "cap" : "rate", true);
		if (_q.ok) {
			qtic = 0;   // requote at once - the price just moved
			play_sound_ext(snd_matclick2, 1.05, 1.25, .5, 1);
			float_text(upg_x + upg_w - 32, _ry - 6,
				(_r == 0) ? "capacity up"
				          : ("+" + string(g.tb_rate_step) + "m/hr"),
				c_sgreen, fnt_outline);
		} else play_sound_ext(snd_matclick, .7, .8, .35, 1);
		exit;
	}
}
