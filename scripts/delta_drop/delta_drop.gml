/// @description delta_drop(d, sx, sy, [water], [spark]) - ONE DROPLET's life (q314): it walks downhill with a little inertia, cuts where it runs fast, drops silt where it slows, and everything it still carries goes down where it meets the sea - the delta. spark = keep its path for the draw
/// The classic droplet erosion (Beyer's), on the cell grid: the capacity
/// is slope x speed x water x the richness; over it, it deposits; under
/// it, it erodes (a levee resists, and nothing cuts below sea level). A
/// flood's droplet carries twice the water and drowns the crops it
/// touches unless a levee stands within one cell.
function delta_drop(_d, _sx, _sy, _water = 1, _spark = false) {
	var _w = _d.w, _h = _d.h, _hg = _d.hgt, _sea = _d.sea, _lv = _d.lev;
	var _px = _sx + random_range(-.6, .6), _py = _sy + random_range(-.4, .4), _dx = 0, _dy = 0, _vel = 1, _sed = 0;
	var _capk = DELTA_CAP * (1 + .35 * (_d.rich - 1)) * ((_d.flood > 0) ? 1.5 : 1), _path = _spark ? [] : undefined, _flood = (_d.flood > 0);
	repeat (DELTA_LIFE) {
		var _cx = clamp(floor(_px), 0, _w - 1), _cy = clamp(floor(_py), 0, _h - 1), _ci = _cx + _cy * _w;
		var _gx = _hg[min(_w - 1, _cx + 1) + _cy * _w] - _hg[max(0, _cx - 1) + _cy * _w];
		var _gy = _hg[_cx + min(_h - 1, _cy + 1) * _w] - _hg[_cx + max(0, _cy - 1) * _w];
		_dx = _dx * DELTA_INERTIA - _gx * (1 - DELTA_INERTIA); _dy = _dy * DELTA_INERTIA - _gy * (1 - DELTA_INERTIA);
		var _len = sqrt(_dx * _dx + _dy * _dy);
		if (_len < .0001) { var _a = random(2 * pi); _dx = cos(_a); _dy = sin(_a); } else { _dx /= _len; _dy /= _len; }
		var _nx = _px + _dx, _ny = _py + _dy;
		if (_nx < 0 || _nx >= _w || _ny < 0 || _ny >= _h) break;
		var _ncx = floor(_nx), _ncy = floor(_ny), _ni = _ncx + _ncy * _w;
		var _hold = _hg[_ci], _hnew = _hg[_ni], _dh = _hnew - _hold;
		if (_spark) array_push(_path, _ni);
		_d.wet[_ni] = min(1, _d.wet[_ni] + DELTA_WET_GAIN);
		if (_flood && _d.crop[_ni] > 0 && _lv[_ni] != 1) {
			// THE FLOOD DROWNS what stands in its way - unless a levee stands within one cell
			var _guard = false;
			for (var _oy = -1; _oy <= 1 && !_guard; _oy++) for (var _ox = -1; _ox <= 1; _ox++) { var _qx = _ncx + _ox, _qy = _ncy + _oy; if (_qx < 0 || _qy < 0 || _qx >= _w || _qy >= _h) continue; if (_lv[_qx + _qy * _w] == 1) { _guard = true; break; } }
			if (!_guard) _d.crop[_ni] = 0;
		}
		if (_hnew < _sea) {
			// THE SEA: everything goes down here - the mud the river always carries, and what it picked up. Most on the cell it
			// meets, the rest on a sea neighbour, so the delta fans out instead of pushing one finger
			var _amt = _sed + DELTA_SEA_GIFT * _water;
			_hg[_ni] = min(_sea + .02, _hg[_ni] + _amt * .65);
			var _qi = _ncx + choose(-1, 0, 1), _qj = _ncy + choose(0, 1);
			if (_qi >= 0 && _qi < _w && _qj >= 0 && _qj < _h && _hg[_qi + _qj * _w] < _sea) _hg[_qi + _qj * _w] = min(_sea + .01, _hg[_qi + _qj * _w] + _amt * .35);
			_d.silt[_ni] = min(1, _d.silt[_ni] + _amt * DELTA_SILT_K);
			_d.silted += _amt;
			break;
		}
		var _cap = max(-_dh, DELTA_MINSLOPE) * _vel * _water * _capk;
		if (_sed > _cap || _dh > 0) {
			var _dep = (_dh > 0) ? min(_dh, _sed) : (_sed - _cap) * DELTA_DEPOSIT;
			_dep = clamp(_dep, 0, _sed);
			_hg[_ci] += _dep; _d.silt[_ci] = min(1, _d.silt[_ci] + _dep * DELTA_SILT_K); _sed -= _dep;
		} else {
			var _ero = min((_cap - _sed) * DELTA_ERODE, -_dh);
			if (_lv[_ci] == 1) _ero *= .1;   // (a levee holds)
			_ero = max(0, min(_ero, _hg[_ci] - (_sea + .005)));   // (nothing cuts below the sea)
			_hg[_ci] -= _ero; _sed += _ero;
		}
		_vel = sqrt(max(.05, _vel * _vel - _dh * DELTA_GRAV));
		_water *= (1 - DELTA_EVAP);
		if (_water < .06) { _hg[_ci] += _sed; _d.silt[_ci] = min(1, _d.silt[_ci] + _sed * DELTA_SILT_K); break; }   // (dried up: its load stays)
		_px = _nx; _py = _ny;
	}
	if (_spark && array_length(_path) > 1) { array_push(_d.drops, { p : _path, t : 1 }); if (array_length(_d.drops) > 48) array_delete(_d.drops, 0, 1); }
}
