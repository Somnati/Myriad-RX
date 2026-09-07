// the view: pan by drag, zoom by wheel toward the cursor, ease both.
// The centre is a double-double pair throughout (see Create) - scale is
// not, and does not need to be.

// the live floor follows the precision in use. Evaluated before the
// clamp below, so a wheel notch that crosses into a deeper tier is
// allowed through in the same frame it unlocks it.
if (scale <= DD_AT) SCALE_MIN = __pert_on() ? SCALE_MIN_PERT : SCALE_MIN_DD;
else                SCALE_MIN = SCALE_MIN_F32;

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
// Derived, not corrected: solve __at(anch_px, anch_py) == the anchor,
// for the centre, at whatever the scale currently is. Re-solved every
// frame, so the point is pinned for the WHOLE animation rather than
// only at the end of it, and nothing accumulates. Runs before the input
// guards on purpose - a zoom in flight must keep tracking even if
// something else takes the input mid-glide.
if (anch_on) {
	var _aa = room_width / room_height;
	cx = __ddsub(anch_x, [((anch_px / room_width)  - .5) * 2 * scale * _aa, 0]);
	cy = __ddsub(anch_y, [((anch_py / room_height) - .5) * 2 * scale, 0]);
}

// the reference orbit, rebuilt only when it has stopped being useful.
// After the centre has settled for this frame, so it is never built
// against a view that is already stale.
__ref_check();

if (!input_free()) exit;
if (g.click_owner != noone) exit;

var _mx = mouse_x;
var _my = mouse_y;

// ---- zoom toward the cursor ----
// A notch only RE-ANCHORS and sets a new target; the block above does
// the work. The anchor is read at the LIVE scale - the view actually on
// screen - because reading it at scale_to would anchor to a view that
// does not exist yet.
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
	// pan in COMPLEX units off the live scale, so the image tracks your
	// finger at any depth. The offset is a small number - a fraction of
	// the view span - so it is exact as a plain real; only its SUM with
	// the centre needs the dd add.
	var _ar = room_width / room_height;
	cx = __ddsub(drag_cx, [((_mx - drag_mx) / room_width)  * 2 * scale * _ar, 0]);
	cy = __ddsub(drag_cy, [((_my - drag_my) / room_height) * 2 * scale, 0]);
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
if (keyboard_check_pressed(ord("V"))) {
	dbg = !dbg;
	play_sound_ext(snd_softclick, 1, 1.1, .4, 0);
}
if (keyboard_check_pressed(vk_space)) {
	// step the tour. Jumping the centre outright and easing only the
	// SCALE reads as a cut followed by a dive, which is what you want -
	// easing the centre would swing the view across a lot of
	// uninteresting black on the way.
	tour_i = (tour_i + 1) mod array_length(tour);
	var _t = tour[tour_i];
	anch_on   = false;   // the jump sets the centre outright
	ref_valid = false;   // and invalidates any reference from elsewhere
	cx = [_t.x, 0];
	cy = [_t.y, 0];
	scale_to = clamp(_t.s, SCALE_MIN, SCALE_MAX);
	play_sound_ext(snd_matclick2, 1, 1.1, .5, 1);
}
if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("Q")))
	back_room();

// the palette drifts on its own, very slowly - a still image that is
// never quite still. delta-scaled, so it drifts at the same rate on a
// 60hz laptop and his 144hz monitor.
pal_shift += .00035 * delta;
