var _dt = delta_time / 1000000;

salpha = trickle(salpha, 1, 5);
vis.alpha = salpha;

// display AND camera focus ride the counter's DISPLAYED value, not the
// raw pile: profit still riding bezier motes is held back, so a payout
// only grows the blocks when its motes actually arrive. The header owns
// that figure (obj_ui_header.prof_shown) so the number and the blocks
// can never tell different stories.
var _g = g.profit;
if (instance_exists(obj_ui_header)) _g = obj_ui_header.prof_shown;
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
