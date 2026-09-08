/// @description spark_burst(x, y, count, [colour]);
/// @param x
/// @param y
/// @param count
/// @param [colour]
/// Throw a handful of DE's pixel sparks out of a point. THE ONE ENTRY
/// POINT - callers never touch the pool.
///
/// Every number here is Myriad DE's obj_eff_shardspark Create, verbatim:
/// a leftward-upward burst impulse that decays, a slow persistent drift
/// on top of it, a wandering wind, a scale of 2 easing down to .65-1,
/// and a life of one to three seconds weighted so most are short and a
/// few linger.
///
/// WHEN THE POOL IS FULL nothing is refused and nothing is allocated -
/// an existing spark is recycled round-robin. A burst that silently
/// did not happen is a worse failure than one that costs an older
/// pixel, and at the cap the drain is already 4x so they are dying
/// fast anyway.
function spark_burst(_x, _y, _count, _col = c_white) {
	if (!instance_exists(syst_sparks)) return;
	with (syst_sparks) {
		repeat (_count) {
			var _i;
			if (n < SPARK_MAX) { _i = n; n += 1; }
			else { wr = (wr + 1) % SPARK_MAX; _i = wr; }
			var _s = p[_i];

			_s.x  = _x;
			_s.y  = _y;
			_s.bx = random_range(0, -5);      // the burst, DE's numbers
			_s.by = random_range(0, -2);
			_s.vx = random_range(0, -.6);     // the drift under it
			_s.vy = random_range(-.02, -.4);
			_s.wd  = random(360);
			_s.wdc = random_range(-3, 3);
			_s.wt  = random(.9);              // how fast the wind wanders
			_s.ws  = random_range(.2, .5);
			_s.sc   = 2;
			_s.smin = random_range(.65, 1);
			// DE's weighting: most are short, half are longer, one in
			// fourteen hangs around for three seconds
			var _hp = 60 * random_range(1, 1.5);
			if (roll_perc(50)) _hp = 60 * random_range(1.5, 2);
			if (roll_perc(7))  _hp = 60 * random_range(2, 3);
			_s.hp  = _hp;
			_s.hp0 = _hp;
			_s.col = _col;
		}
	}
}
