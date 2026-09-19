/// @description star_pulse(seed, period) -> .70 .. 1.30: A CEPHEID'S BREATH now (q253) on the universal clock - a period of twenty to ninety minutes (the star's own), the swell a steep rise and a slow fall (the real light curve's shape), and NEVER A METRONOME: the period wobbles a seventh on a slow hashed drift and the amplitude drifts too (the house's rule against beats)
function star_pulse(_seed, _period) {
	var _t = universal_now() + (_seed mod 100000) * 7.3;
	var _drift = sin(_t / (_period * 6.1) * 2 * pi + (_seed mod 360) * pi / 180);
	var _p = _period * (1 + .14 * _drift);
	var _ph = frac(_t / _p);
	// the curve: up fast (a fifth of the period), down slow
	var _s = (_ph < .2) ? (_ph / .2) : (1 - (_ph - .2) / .8);
	_s = _s * _s * (3 - 2 * _s);
	var _amp = .22 + .08 * sin(_t / (_period * 3.7) * 2 * pi + (_seed mod 100) * .1);
	return 1 - _amp + 2 * _amp * _s;
}
