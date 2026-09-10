// ---- the stage fade ----
// fading out (leaving >= 0): t falls to 0, then the stage flips and t
// rises again. 99 = the last answer landed: pull the trigger at black.
if (leaving >= 0) {
	t = max(0, t - .09 * delta);
	if (t <= 0) {
		if (leaving == 99) {
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
