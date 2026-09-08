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

// ⚖️ SWIPE-ZOOM IS GONE (his call, 2026-09-08). It read a held button
// as a zoom gesture, which put it in direct competition with the thing
// the room is FOR: the tap surface is the whole room, so holding to tap
// and swiping to zoom were the same input. The tapper had to defend
// itself with a drag budget - move the mouse and the hold died - and
// that was the worse bug of the two, because the hold is a mechanic and
// the zoom was a convenience.
//
// The wheel still zooms, and the camera still follows the value on its
// own. WHAT THIS COSTS: a touch device now has no manual zoom at all.
// If that matters, it wants a gesture that cannot be confused with a
// hold - two fingers, or a pinch - not a one-finger drag.

// parent the vis to this object: the assembling square centers on x/y
vis.set_position(x, y);

vis.update(_dt);
