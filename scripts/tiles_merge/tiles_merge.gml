/// @description tiles_merge(a, b) - resolve dropping slot a onto slot b.
/// returns 0 nothing happened / 1 moved (b was empty) / 2 merged /
/// 3 merged with a bonus tier. pure board logic - the controller owns
/// all sounds, glow and floats, so this stays reusable anywhere the
/// table shows up later.
function tiles_merge(_a, _b) {
	var _t = g.tiles;
	if (_a == _b) return 0;
	if (_t.tier[_a] == 0) return 0;

	// empty target: a move
	if (_t.tier[_b] == 0) {
		_t.tier[_b] = _t.tier[_a];
		_t.tier[_a] = 0;
		_t.dirty = true;
		save_mark_dirty(); // save-on-mutation law (board layout persists)
		return 1;
	}

	if (_t.tier[_b] != _t.tier[_a]) return 0;

	// merge: b absorbs a and tiers up. the step scales at absurd tiers
	// (Myriad's floor(1 + tier/10000)). the bonus roll is Myriad's
	// merge_tierrate (g.tiles.bonus_rate, a plain % - fabrication luck
	// lives in g.tile_rarity instead), and a merge that lands ON the
	// board's highest tier always pushes past it - the frontier moves
	var _step = floor(1 + _t.tier[_b] / 10000);
	var _r = 2;
	_t.tier[_b] += _step;
	if (random(100) < _t.bonus_rate
	|| (_t.bonus_rate > 0 && _t.tier[_b] == _t.highest)) {
		_t.tier[_b] += _step;
		_r = 3;
	}
	_t.tier[_a] = 0;

	_t.merges++;
	if (_t.tier[_b] > _t.highest) _t.highest = _t.tier[_b];
	_t.dirty = true;
	save_mark_dirty(); // save-on-mutation law
	return _r;
}
