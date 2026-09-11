// ---- THE OPEN/CLOSE EASE (the overlay contract) ----
oa = move_to(oa, closing ? 0 : 1, closing ? UI_OUT_SPD : UI_IN_SPD);
if (abs(oa - (closing ? 0 : 1)) < .004) oa = closing ? 0 : 1;
if (closing && oa <= 0) { instance_destroy(); exit; }

qtic -= delta;
if (qtic <= 0) {
	qtic = 15;
	q_cap  = battery_upg("cap",  false);
	q_rate = battery_upg("rate", false);
}

// ---- THE CRANK'S PHYSICS, every step (even while the panel is arriving) ----
if (held) {
	if (!mouse_check_button(mb_left)) {
		held = false;   // the momentum is whatever the last frames gave it
	} else {
		var _a  = point_direction(crank_cx, crank_cy, mouse_x, mouse_y);
		var _da = angle_difference(_a, grab_a);
		grab_a  = _a;
		// a jump through the centre is not a sweep
		if (abs(_da) < 90) {
			ang += _da;
			vel  = lerp(vel, _da / max(.05, delta), .5);   // the hand's speed, for the release
			__crank_add(_da);
		}
	}
} else if (abs(vel) > .05) {
	// free-spinning on its momentum, charging as it goes, friction
	// bleeding it down - power() so it winds down the same at 144
	var _d = vel * delta;
	ang += _d;
	__crank_add(_d);
	vel *= power(.955, delta);
	if (abs(vel) < .05) vel = 0;
}
if (ang >= 360 || ang < 0) ang -= 360 * floor(ang / 360);
crank_glow = trickle(crank_glow, (held || abs(vel) > .5) ? 1 : 0, 6, 0);

// ---- the live drag on a rate track: it owns the pointer until released ----
if (drag_row >= 0) {
	if (!mouse_check_button(mb_left)) { drag_row = -1; save_mark_dirty(); }
	else {
		var _t = __trk_r(drag_row);
		var _v = round(lerp(5, 100, clamp((mouse_x - _t.x) / max(1, _t.w), 0, 1)));
		g.battery.rate[$ rates[drag_row]] = _v;
		exit;
	}
}

// ---- input: only once the panel has fully arrived, and only while
// nothing sits over it (a dropdown, the menu) ----
if (oa < .999 || closing) exit;
if (!input_free(ui_layer_overlay)) exit;
if (keyboard_check_pressed(vk_escape)) { battery_close(); exit; }
if (variable_global_exists("click_owner") && g.click_owner != noone) exit;
if (!mouse_check_button_pressed(mb_left)) exit;

// ---- the crank: grab anywhere on the wheel ----
if (point_distance(mouse_x, mouse_y, crank_cx, crank_cy) <= crank_r + 8) {
	held   = true;
	grab_a = point_direction(crank_cx, crank_cy, mouse_x, mouse_y);
	vel    = 0;
	exit;
}

// ---- the rate tracks (a fat grab zone: this is a touch build) ----
for (var _i = 0; _i < 3; _i++) {
	var _t = __trk_r(_i);
	if (point_in_rectangle(mouse_x, mouse_y, _t.x - 3, _t.y - 6, _t.x + _t.w + 3, _t.y + _t.h + 6)) {
		drag_row = _i;
		var _v = round(lerp(5, 100, clamp((mouse_x - _t.x) / max(1, _t.w), 0, 1)));
		g.battery.rate[$ rates[_i]] = _v;
		exit;
	}
}

// ---- the two upgrade buttons ----
for (var _r = 0; _r < 2; _r++) {
	var _br = __btn_r(_r);
	if (!point_in_rectangle(mouse_x, mouse_y, _br.x, _br.y, _br.x + _br.w, _br.y + _br.h)) continue;
	var _q = battery_upg((_r == 0) ? "cap" : "rate", true);
	if (_q.ok) {
		qtic = 0;   // requote at once - the price just moved
		play_sound_ext(snd_matclick2, 1.05, 1.25, .5, 1);
		float_text(_br.x + _br.w * .5, _br.y - 6,
			(_r == 0) ? "capacity up" : "charges faster", c_sgreen, fnt_outline);
	} else play_sound_ext(snd_matclick, .7, .8, .35, 1);
	exit;
}
