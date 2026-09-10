// the fades (DE's trickles)
alpha  = trickle(alpha,  open ? 1 : 0, 4);
balpha = trickle(balpha, open ? 1 : 0, 6);
scale  = trickle(scale,  open ? 1 : 0, 5);
ts     = trickle(ts, 1, 6);
glow   = max(0, glow - .05 * delta);

// the overlay contract's two names for the same facts
oa      = alpha;
closing = !open;

// closed and faded out: invisible, so the input families skip it - and
// a guest (opened outside the money room) leaves entirely
if (!open && alpha < .01) {
	if (guest) { instance_destroy(); exit; }
	visible = false; hp = 0; exit;
}
if (!open) { hp = trickle(hp, 0, 5); exit; }
if (fired) exit;

calc = rebirth_calc();

// ---- closing: a press anywhere but the banner, or escape ----
if (mouse_check_button_pressed(mb_left) && !mouse_over()) { open = false; exit; }
if (keyboard_check_pressed(vk_escape)) { open = false; exit; }

// ---- the hold (DE's hp ramp: fast to 10, half speed after) ----
var _go = (calc.can && calc.cool <= 0);
if (!_go) hp = 0;
if (_go && mouse_over() && mouse_check_button(mb_left)) {
	if (hp < 10) hp += (100 / 60) * delta;
	else         hp += (100 / 60) * delta * .5;
} else hp = trickle(hp, 0, 5);

// ---- the fire ----
if (hp >= 100) {
	hp = 0;
	if (rebirth_do()) {
		fired = true;
		open  = false;
		// DE's ceremony: profit motes from the banner, both sounds, the
		// banner line, and the money room restarts behind a wipe - the
		// fresh run
		bezier_bits(bx + bw * .5, by + 8, 12, c_hred, undefined, undefined, -1,
			0, -1, 1, "unit");
		play_sound_ext(snd_rebirthcollect, .9, 1.1, .5, 1);
		play_sound_ext(snd_rebirth, .9, 1.1, .5, 2);
		assign_banner("units +" + crunch_arb(g.rebirth.prev_units), c_hred, c_black);
		goto_room(rm_clicker);
	}
}
