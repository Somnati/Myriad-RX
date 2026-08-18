var _dt = delta_time / 1000000;

salpha = trickle(salpha, 1, 5);
vis.alpha = salpha;

// display AND camera focus ride the profit counter. DE feeds this the
// counter's DISPLAYED value instead of the true one, so earnings only
// land on the visualiser when their bezier particle arrives at the
// header - when that particle layer is rebuilt, this is its hook.
var _g = g.profit;
vis.set_display_value(_g);
vis.set_focus_value(_g);

// endless zoom, both directions. desktop: wheel.
if mouse_wheel_up() vis.set_zoom_input(-0.5);
if mouse_wheel_down() vis.set_zoom_input(0.5);

// mobile swipe zoom, round 2 (his device report: the old flick
// detector re-fired through one flick and read the tail's direction
// flip - double zooms, opposite zooms, missed slow swipes). now
// CONTINUOUS: after 12px of vertical travel from the press (the
// drag budget - taps and tap-holds stay taps) the zoom follows the
// finger frame by frame. up = in, down = out, matching the old
// grammar; direction can reverse mid-drag; nothing re-fires.
// swipe_sens = OOMs per px of finger travel (the feel knob).
if mouse_check_button(mb_left) {
	if swipe_oy = -1 { swipe_oy = mouse_y; swipe_py = mouse_y; }
	if abs(mouse_y - swipe_oy) > 12 swipe_on = true;
	if swipe_on vis.set_zoom_input((mouse_y - swipe_py) * swipe_sens);
	swipe_py = mouse_y;
} else { swipe_oy = -1; swipe_on = false; }

// parent the vis to this object: the assembling square centers on x/y
vis.set_position(x, y);

vis.update(_dt);
