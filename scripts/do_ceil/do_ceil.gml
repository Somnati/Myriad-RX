function do_ceil(argument0) {

	_acoe = frac(argument0);
	_aexp = floor(argument0);

	_hardpoint = 10;
	if _aexp <= _hardpoint{
	_acoe = _acoe*power(10,_aexp+1);
	// ⚖️ THE EPSILON (his report, 2026-09-13: "dial a needs to cost exactly
	// 100" - it read 101). arb(100) packs as 2.1, and 2.1 is not exactly
	// representable: frac() gives .10000000000000009, x1000 is
	// 100.00000000000009, and ceil of that is 101. Every EXACT arb that
	// lands on a mantissa like .1 / .3 / .7 was one unit out through here
	// (1000 read 1001, 700 read 701). Nothing the arb can represent lives
	// within 1e-4 of a whole unit at any scale this branch handles (the
	// mantissa's own resolution at exp 10 is ~1e-5), so the nudge is safe
	_acoe = ceil(_acoe - 1e-4);
	_acoe = _acoe/power(10,_aexp+1);

	//overflow_correction
	if _acoe >= 1{
	_acoe /= 10;
	_aexp += 1;}

	}

	return _acoe+_aexp;







}
