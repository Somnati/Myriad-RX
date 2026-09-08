if (n <= 0) exit;

var _dt = delta;

// DE'S POPULATION CULL, and the reason the system needs no other budget:
// the more sparks are alive, the faster every one of them dies
// (lerp(1, 4, count/200) on the drain). A quiet moment gets long lazy
// pixels; a wall of payouts gets short sharp ones and the count settles
// itself. It is a self-limiting effect rather than a hard cutoff, so
// nothing ever visibly stops spawning.
var _drain = lerp(1, 4, n / SPARK_MAX) * _dt;

var _i = 0;
while (_i < n) {
	var _s = p[_i];

	// scale eases toward its resting size; the burst impulse decays
	_s.sc += (_s.smin - _s.sc) / (5 / _dt);
	_s.bx += (0 - _s.bx) / (8 / _dt);
	_s.by += (0 - _s.by) / (8 / _dt);

	// the wind's direction random-walks, which is what stops a burst
	// reading as a fan of straight lines
	_s.wdc += (random_range(-3, 3) - _s.wdc) / (_s.wt / _dt);
	_s.wd  += _s.wdc * _dt;

	_s.x += (lengthdir_x(_s.ws, _s.wd) + _s.vx + _s.bx) * _dt;
	_s.y += (lengthdir_y(_s.ws, _s.wd) + _s.vy + _s.by) * _dt;

	_s.hp -= _drain;
	if (_s.hp <= 0) {
		// SWAP-REMOVE: the dead one trades places with the last live
		// one and the count drops. O(1), no shuffling, and the struct
		// it was using stays in the array to be filled again.
		n -= 1;
		p[_i] = p[n];
		p[n]  = _s;
		continue;      // the swapped-in spark now occupies _i
	}
	_i += 1;
}
