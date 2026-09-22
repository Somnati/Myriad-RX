/// @description syz_buy(s, what, [i], [dir]) -> true when bought: a level, a period's step (dir -1 / +1), a new cycle, the sync (every cycle fires together in one second), an anchor, the harmonic (a token), the ninth cycle (three tokens)
function syz_buy(_s, _what, _i = -1, _dir = 1) {
	var _c = syz_cost(_s, _what, _i), _n = array_length(_s.cycles);
	if (_c < 0) return false;
	var _tok = (_what == "harm" || _what == "ninth");
	if (_tok ? (_s.tokens < _c) : (_s.flux < _c)) return false;
	switch (_what) {
		case "lv":     _s.cycles[_i].lv += 1; break;
		case "per": {
			var _cy = _s.cycles[_i], _np = clamp(_cy.per + _dir, SYZ_PER_MIN, SYZ_PER_MAX);
			if (_np == _cy.per) return false;
			_cy.per = _np; if (_cy.t >= _np) _cy.t = _cy.t mod _np;
			break;
		}
		case "cycle": {
			// the new cycle's period: the first whole number from eleven up that no cycle holds
			var _p = 11;
			while (true) { var _held = false; for (var _j = 0; _j < _n; _j++) if (_s.cycles[_j].per == _p) _held = true; if (!_held || _p >= SYZ_PER_MAX) break; _p += 1; }
			array_push(_s.cycles, { per : _p, t : 0, lv : 1, anchor : false, fired : 0, k : 1 });
			break;
		}
		case "sync": {
			for (var _j = 0; _j < _n; _j++) _s.cycles[_j].t = _s.cycles[_j].per - 1;
			_s.sync_cd = SYZ_SYNC_CD; _s.syncs += 1;
			syz_log(_s, "SYNC  -  every cycle fires in one second");
			break;
		}
		case "anchor": _s.cycles[_i].anchor = true; break;
		case "harm":   _s.harm += .5; break;
		case "ninth":  _s.cap = 9; break;
	}
	if (_tok) _s.tokens -= _c; else _s.flux -= _c;
	save_mark_dirty();
	return true;
}
