
// ---- arrival bloom: a brief glow at the counter, then gone ----
if (pop_t >= 0) {
	pop_t += delta;
	if (pop_t > 10) kill;
	exit;
}

// ---- progress: accelerates over the flight (the original lerped its
// step up 1.5x by progress) ----
t += spd * (1 + .5 * t) * delta;
if (t >= 1) { t = 1; pop_t = 0; }

// quadratic de Casteljau on the 3-point path (the original's evaluator,
// minus the unused 4-point branches)
var _ax = lerp(p0x, cx, t), _ay = lerp(p0y, cy, t);
var _bx = lerp(cx, tx, t),  _by = lerp(cy, ty, t);
x = lerp(_ax, _bx, t);
y = lerp(_ay, _by, t);

// shrink as it closes (Myriad's 1.7 - t, clamped) + the idle spin;
// coins also roll through their frames (coin_image_speed)
size = min(1, 1.7 - t);
rot += rot_spd * delta;
frame += fspd * delta;
