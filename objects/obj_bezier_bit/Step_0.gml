
// ---- arrival bloom: a brief glow at the counter, then gone ----
if (pop_t >= 0) {
	pop_t += delta;
	if (pop_t > 10) kill;
	exit;
}

// ---- progress, through his library ----
// the flight ACCELERATES 1.5x over its length (the original's feel);
// _move_scale is bezier_approach's own multiplier, so the acceleration
// rides the library's knob instead of a second speed variable.
if (_bpoints >= 3) {
	_move_scale = 1 + .5 * _zero;
	bezier_approach();
}
t = _zero;
if (t >= 1 && pop_t < 0) pop_t = 0;

// evaluate the 3-point curve (bezier_get_x/y run de Casteljau for the
// point count you pass - 3 here, and the library goes to 4 when a
// future curve wants a cubic)
x = bezier_get_x(3);
y = bezier_get_y(3);

// shrink as it closes (Myriad's 1.7 - t, clamped) + the idle spin;
// coins also roll through their frames (coin_image_speed)
size = min(1, 1.7 - t);
rot += rot_spd * delta;
frame += fspd * delta;
