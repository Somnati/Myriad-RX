if (!__live()) { glows = []; shocks = []; fxs = []; pops = []; exit; }

// ---- the effects tick ----
for (var _i = array_length(glows) - 1; _i >= 0; _i--) {
	glows[_i].t += delta;
	if (glows[_i].t >= 10) array_delete(glows, _i, 1);
}
for (var _i = array_length(shocks) - 1; _i >= 0; _i--) {
	shocks[_i].r += 1.6 * delta;   // (was 1.1 to 16: smaller and faster, his call)
	if (shocks[_i].r > (shocks[_i].crit ? 16 : 12)) array_delete(shocks, _i, 1);
}
// the second batch: each kind has its own clock
for (var _i = array_length(fxs) - 1; _i >= 0; _i--) {
	var _e = fxs[_i];
	_e.t += delta;
	var _dead = false;
	switch (_e.kind) {
		case "star":    _dead = (_e.t >= 8); break;
		case "square":  _e.r += 1.6 * delta; _dead = (_e.r > (_e.crit ? 16 : 12)); break;
		case "implode": _e.r -= 1.7 * delta; _dead = (_e.r < -3); break;
		case "bolt":    _dead = (_e.t >= 5); break;
		default:        _dead = true;
	}
	if (_dead) array_delete(fxs, _i, 1);
}
// DE's crit pop: five frames, two steps each (ani_set(image_max, 2)),
// gone when the clock runs past the last
for (var _i = array_length(pops) - 1; _i >= 0; _i--) {
	pops[_i].t += delta;
	if (pops[_i].t >= 10) array_delete(pops, _i, 1);
}
