// the view: pan by drag, zoom by wheel toward the cursor, ease both.

// ---- the eased zoom ----
// geometric, not linear: scale is a multiplicative quantity, so easing
// it additively makes a dive start fast and crawl at the end. Working
// in the ratio keeps every wheel notch feeling the same size at every
// depth, which is the whole trick to a fractal zoom feeling right.
if (scale != scale_to) {
	var _r = scale_to / scale;
	scale *= power(_r, min(1, .22 * delta));
	if (abs(scale_to / scale - 1) < .0005) scale = scale_to;
}

// ---- hold the anchor under the cursor ----
// Derived, not corrected: solve __at(anch_px, anch_py) == (anch_x,
// anch_y) for the centre, at whatever the scale currently is. Because
// it is re-solved every frame the point is pinned for the WHOLE
// animation instead of only at the end of it, and nothing accumulates.
// This runs before the input guards on purpose - a zoom already in
// flight must keep tracking even if a popup opens mid-glide.
if (anch_on) {
	var _aa = room_width / room_height;
	cx = anch_x - ((anch_px / room_width)  - .5) * 2 * scale * _aa;
	cy = anch_y - ((anch_py / room_height) - .5) * 2 * scale;
}

if (!input_free()) exit;
if (g.click_owner != noone) exit;

var _mx = mouse_x;
var _my = mouse_y;

// ---- zoom toward the cursor ----
// A notch only RE-ANCHORS and sets a new target; the block above does
// the work. Note the anchor is read at the LIVE scale, which is the
// view actually on screen - reading it at scale_to would anchor to a
// view that does not exist yet, which is half of what was wrong before.
var _w = mouse_wheel_up() - mouse_wheel_down();
if (_w != 0) {
	var _p  = __at(_mx, _my);
	anch_on = true;
	anch_x  = _p.x;
	anch_y  = _p.y;
	anch_px = _mx;
	anch_py = _my;
	scale_to = clamp(scale_to * power(0.78, _w), SCALE_MIN, SCALE_MAX);
}

// ---- drag to pan ----
if (mouse_check_button_pressed(mb_left)) {
	drag    = true;
	anch_on = false;   // the drag owns the centre from here
	scale_to = scale;  // and a pan should not fight a zoom still in flight
	moved   = 0;
	drag_mx = _mx;
	drag_my = _my;
	drag_cx = cx;
	drag_cy = cy;
}
if (drag && mouse_check_button(mb_left)) {
	moved = max(moved, point_distance(drag_mx, drag_my, _mx, _my));
	// pan in COMPLEX units, derived from the live scale, so a drag
	// moves the image the same distance under your finger no matter how
	// deep you are
	var _ar = room_width / room_height;
	cx = drag_cx - ((_mx - drag_mx) / room_width)  * 2 * scale * _ar;
	cy = drag_cy - ((_my - drag_my) / room_height) * 2 * scale;
}
if (mouse_check_button_released(mb_left)) drag = false;

// ---- keys ----
if (keyboard_check_pressed(ord("C"))) {
	pal_set = (pal_set + 1) mod array_length(pal_list);
	play_sound_ext(snd_softclick, 1, 1.1, .4, 0);
}
if (keyboard_check_pressed(ord("G"))) {
	glow = (glow > 0) ? 0 : .55;
	play_sound_ext(snd_softclick, 1, 1.1, .4, 0);
}
if (keyboard_check_pressed(ord("H"))) show_hud = !show_hud;
if (keyboard_check_pressed(vk_space)) {
	// step the tour. Jumping the centre outright and letting only the
	// SCALE ease reads as a cut followed by a dive, which is exactly
	// what you want here - easing the centre too would swing the view
	// across the plane through a lot of uninteresting black.
	tour_i = (tour_i + 1) mod array_length(tour);
	var _t = tour[tour_i];
	anch_on = false;   // the jump sets the centre outright
	cx = _t.x; cy = _t.y;
	scale_to = clamp(_t.s, SCALE_MIN, SCALE_MAX);
	play_sound_ext(snd_matclick2, 1, 1.1, .5, 1);
}
if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("Q")))
	back_room();

// the palette drifts on its own, very slowly - a still image that is
// never quite still. delta-scaled, so it drifts at the same rate on a
// 60hz laptop and his 144hz monitor.
pal_shift += .00035 * delta;
