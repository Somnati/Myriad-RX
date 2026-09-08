/// the room's pulse: refresh the quotes on the slow tick, then the
/// taps. Region law - every hit here mirrors Draw's geometry exactly.

qtic -= delta;
if (qtic <= 0) {
	qtic = 15;
	var _qc = timebank_upg("cap", false);
	q_cap  = { ok : _qc.ok, cost : _qc.cost, maxed : false,
		txt : crunch_arb(_qc.cost) };
	var _qr = timebank_upg("rate", false);
	q_rate = { ok : _qr.ok, cost : _qr.cost, maxed : _qr.maxed,
		txt : _qr.maxed ? "max" : crunch_arb(_qr.cost) };
}

if (!input_free()) exit;
if (g.click_owner != noone) exit;
if (!mouse_check_button_pressed(mb_left)) exit;

var _bk = __back_rect();
if (point_in_rectangle(mouse_x, mouse_y, _bk.x1, _bk.y1, _bk.x2, _bk.y2)) {
	play_sound_ext(snd_matclick2, .8, .9, .5, 1);
	back_room();
	exit;
}

// ---- the speed pills ----
// Engaging a speed with an empty bank would be dropped by
// timebank_spend on the very next frame, so it buzzes instead of
// pretending to work.
if (mouse_y >= spd_y && mouse_y < spd_y + 16)
for (var _k = 0; _k < 6; _k++) {
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
				(_r == 0) ? "+" + string(g.tb_cap_step) + "m cap"
				          : "+" + string(g.tb_rate_step) + "m/hr",
				c_sgreen, fnt_outline);
		} else play_sound_ext(snd_matclick, .7, .8, .35, 1);
		exit;
	}
}
