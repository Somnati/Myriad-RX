/// @description delta_tick(d, dt, [spark]) - THE SIM for dt seconds (q314): the rain's droplets, the wet's fade, the crops' growth and reaping, the flood's season. Any dt: the catch-up hands it thirty seconds a call, the room a frame
function delta_tick(_d, _dt, _spark = false) {
	var _w = _d.w, _h = _d.h, _n = _w * _h, _hg = _d.hgt, _sea = _d.sea;
	// THE SEASON: the flood comes round, runs its days, and the clock is set again (a little off, never a metronome)
	if (_d.flood > 0) { _d.flood = max(0, _d.flood - _dt); }
	else { _d.flood_t -= _dt; if (_d.flood_t <= 0) { _d.flood = DELTA_FLOOD_LEN; _d.flood_t = DELTA_FLOOD_EVERY * random_range(.8, 1.25); } }
	// THE RAIN: droplets a second by the rain's level, six times over in a flood; the fraction carries
	var _rate = (1.6 + .8 * (_d.rain - 1)) * ((_d.flood > 0) ? 6 : 1);
	_d.acc += _rate * _dt;
	var _nd = floor(_d.acc); _d.acc -= _nd;
	var _sp = delta_springs(_d);
	for (var _k = 0; _k < _nd; _k++) {
		var _s = _sp[irandom(array_length(_sp) - 1)];
		delta_drop(_d, _s[0], _s[1], (_d.flood > 0) ? 2 : 1, _spark);
	}
	// THE GROUND: the wet fades, the crops grow where the ground is wet and silted (the seed's asks), ripen and are reaped
	var _sd = delta_seeds()[_d.seed], _decay = exp(-DELTA_WET_DECAY * _dt), _got = 0;
	for (var _i = 0; _i < _n; _i++) {
		_d.wet[_i] *= _decay;
		if (_hg[_i] < _sea || _hg[_i] > DELTA_CROP_MAXH || _d.lev[_i] != 0) { _d.crop[_i] = 0; continue; }
		var _wt = _d.wet[_i], _si = _d.silt[_i];
		if (_wt >= _sd.wet && _si >= _sd.silt) {
			_d.crop[_i] += _dt / _sd.ripen * (.6 + _si) * min(1, _wt * 2.5);
			while (_d.crop[_i] >= 1) {
				_d.crop[_i] -= 1;
				// THE SALT: low new land by the sea yields half - unless the silt runs deep
				var _x = _i mod _w, _y = _i div _w, _bysea = false;
				if (_hg[_i] < _sea + .04) {
					if (_x > 0 && _hg[_i - 1] < _sea) _bysea = true; if (_x < _w - 1 && _hg[_i + 1] < _sea) _bysea = true;
					if (_y > 0 && _hg[_i - _w] < _sea) _bysea = true; if (_y < _h - 1 && _hg[_i + _w] < _sea) _bysea = true;
				}
				var _salt = (_bysea && _si < .5) ? .5 : 1;
				_got += _sd.yield * (1 + _si) * _salt;
				_d.harvests += 1;
			}
		} else if (_wt < .05) _d.crop[_i] = max(0, _d.crop[_i] - _dt * .01);   // (a dry field withers, slowly)
	}
	_got *= 1 + .25 * ((_d[$ "valley"] ?? 1) - 1);   // (the valleys settled before this one: a quarter each)
	if (_got > 0) { _d.grain += _got; _d.life += _got; }
	// the readout: grain a second over the last ten
	_d.rate_acc += _got; _d.rate_t += _dt;
	if (_d.rate_t >= 10) { _d.rate = _d.rate_acc / _d.rate_t; _d.rate_acc = 0; _d.rate_t = 0; }
	// the sparks fade
	for (var _k = array_length(_d.drops) - 1; _k >= 0; _k--) { _d.drops[_k].t -= _dt * 1.6; if (_d.drops[_k].t <= 0) array_delete(_d.drops, _k, 1); }
	_d.last = universal_now();
}
