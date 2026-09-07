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

if (!input_free()) exit;
if (g.click_owner != noone) exit;

var _mx = mouse_x;
var _my = mouse_y;

// ---- zoom toward the cursor ----
// Keep the complex point under the pointer FIXED across the zoom. The
// centre has to move to compensate, and this is that compensation:
//   new_centre = p - (p - old_centre) * (new_scale / old_scale)
// Without it every zoom step drifts whatever you aimed at off toward
// the edge, and you spend the whole time dragging it back.
var _w = mouse_wheel_up() - mouse_wheel_down();
if (_w != 0) {
	var _p  = __at(_mx, _my);
	var _ns = clamp(scale_to * power(0.78, _w), SCALE_MIN, SCALE_MAX);
	var _k  = _ns / scale_to;
	cx = _p.x - (_p.x - cx) * _k;
	cy = _p.y - (_p.y - cy) * _k;
	scale_to = _ns;
}

// ---- drag to pan ----
if (mouse_check_button_pressed(mb_left)) {
	drag    = true;
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
