// ---- the stage fade ----
// fading out (leaving >= 0): t falls to 0, then the stage flips and t
// rises again. 99 = the last answer landed: pull the trigger at black.
if (leaving >= 0) {
	t = max(0, t - .09 * delta);
	if (t <= 0) {
		if (leaving == 99) {
			// THE BEAT (his report, 2026-09-13: "after i answer the last
			// question it kinda feels off beat"): the answer fades, and the
			// black HOLDS - most of a second of nothing - before the trigger
			// pulls. The questions were a walk; the run does not start on
			// the same footstep. (The veil's word fades in on its own clock
			// after that - syst_unfold - so the whole hand-off is dark.)
			hold += delta / 60;
			if (hold < .8) exit;
			leaving = -1;
			newgame_start(prof, diff, g.persona);
			exit;
		}
		stage = leaving;
		leaving = -1;
	}
	exit;
}
t = min(1, t + .07 * delta);

// ---- hover ----
hov = -1;
var _rows = __rows();
for (var _i = 0; _i < array_length(_rows); _i++) {
	var _r = _rows[_i];
	if (point_in_rectangle(mouse_x, mouse_y, _r.x, _r.y, _r.x + _r.w, _r.y + _r.h)) hov = _i;
}

// ---- input: only once the stage has fully arrived ----
if (t < .999) exit;
if (!input_free()) exit;
if (variable_global_exists("click_owner") && g.click_owner != noone) exit;

// escape / a press outside the list on the first stage: back to the
// profiles, nothing has been touched yet
if (keyboard_check_pressed(vk_escape)) {
	play_sound_ext(snd_matclick2, .8, .9, .5, 1);
	if (stage == 0) { g.saves_mode = "newgame"; goto_room(rm_saves); }
	else leaving = stage - 1;
	exit;
}

if (!mouse_check_button_pressed(mb_left)) exit;
if (hov < 0) exit;

play_sound_ext(snd_matclick2, 1 + stage * .05, 1.1 + stage * .05, .5, 1);
if (stage == 0) {
	diff = hov;
	leaving = 1;
} else {
	g.persona[stage - 1] = hov;
	leaving = (stage < 3) ? stage + 1 : 99;
}
