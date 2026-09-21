/// @description delta_buy(d, what, [cx, cy]) -> true when bought: the upgrades, and the hand tools on a cell (a levee raises it, a channel digs it)
function delta_buy(_d, _what, _cx = -1, _cy = -1) {
	var _c = delta_cost(_d, _what);
	if (_c < 0 || _d.grain < _c) return false;
	switch (_what) {
		case "rain":    _d.rain += 1; break;
		case "springs": _d.springs += 1; break;
		case "rich":    _d.rich += 1; break;
		case "seed":    _d.seed += 1; break;
		case "flood":   _d.flood_t = 0; _d.floods += 1; break;
		case "valley": {
			// THE NEXT VALLEY: a fresh land off a new seed, the ledger back to the start, the valleys counted (a quarter more grain
			// a harvest each) and the lifetime kept. The caller reads g.alluv again after
			var _v = _d.valley + 1, _life = _d.life, _hv = _d.harvests;
			var _nd = delta_init(true);
			_nd.valley = _v; _nd.life = _life; _nd.harvests = _hv;
			save_mark_dirty();
			return true;
		}
		case "levee": case "channel": {
			if (_cx < 0 || _cy < 0 || _cx >= _d.w || _cy >= _d.h) return false;
			var _i = _cx + _cy * _d.w;
			if (_d.hgt[_i] < _d.sea && _what == "channel") return false;   // (nothing to dig under the sea)
			if (_what == "levee") { _d.hgt[_i] = min(1, _d.hgt[_i] + .16); _d.lev[_i] = 1; _d.crop[_i] = 0; _d.nlev += 1; }
			else { _d.hgt[_i] = max(_d.sea + .005, _d.hgt[_i] - .14); _d.lev[_i] = 2; _d.crop[_i] = 0; _d.nchan += 1; }
			break;
		}
	}
	_d.grain -= _c;
	save_mark_dirty();
	return true;
}
