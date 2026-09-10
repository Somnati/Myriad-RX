// DE's seat: three in from the right edge, four under the header bar
var _hh = instance_exists(obj_ui_header) ? obj_ui_header.bar_h : 16;
desy = _hh + 4;                              // DE's 26+4, under our bar
desx = room_width - sprite_width - 3;        // rooms differ in width

// the chevrons walk - DE's ani_step(true) over four frames
ani_tic -= delta;
if (ani_tic <= 0) { ani_tic = 30; ani = (ani + 1) mod 4; }

// up while a speed runs. DE dimmed it to a quarter under its autos
// drawer; ours dims under the dial drawer the same way, since the
// drawer's face slides across this corner
if (__live()) {
	var _dim = instance_exists(syst_dials) && syst_dials.stage > 0;
	alpha = trickle(alpha, _dim ? .25 : 1, _dim ? 4 : 5);
	y = trickle(y, desy, 5);
} else {
	alpha = trickle(alpha, 0, 5);
	y = trickle(y, 5, 5);   // DE: it slips up under the header as it fades
}
x = trickle(x, desx, 3);
