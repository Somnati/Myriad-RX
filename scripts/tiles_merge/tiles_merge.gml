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
		_t.skin[_b] = _t.skin[_a];   // the surface travels with the tile
		_t.skin[_a] = 0;
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
	//
	// ⚖️ THE BONUS IS PARKED behind TILE_BONUS_TIER (his call: "park the
	// tier up+2 on merge temporarily"). Worth knowing before it comes
	// back: the frontier clause fires on EVERY merge that lands on the
	// board's highest tier, which early on is most of them - the roll's
	// 10% was never the real rate, and that is why the ding felt
	// constant. Decide what the frontier rule is worth before unparking.
	var _step = floor(1 + _t.tier[_b] / 10000);
	var _r = 2;
	_t.tier[_b] += _step;
	// ⚖️ TIER UP (his upgrade, 2026-09-10): the merge climbs one tier
	// further, at tile_chance_rate("tierup") percent. Rolled HERE and
	// nowhere else, so the hand and the automerger cannot disagree
	// about the odds. _r 3 is the "bonus merge" signal the view already
	// celebrates - it was DE's +2 merge bonus's, which is parked behind
	// TILE_BONUS_TIER and folds in beside this if it ever returns.
	var _up = (random(100) < tile_chance_rate("tierup"));
	if (TILE_BONUS_TIER)
	if (random(100) < _t.bonus_rate
	|| (_t.bonus_rate > 0 && _t.tier[_b] == _t.highest)) _up = true;
	if (_up) {
		_t.tier[_b] += _step;
		_r = 3;
	}
	_t.tier[_a] = 0;
	// a merge makes a NEW tile: it rolls its surface from the bigger pool
	_t.skin[_b] = tile_skin_roll(_t.tier[_b]);
	_t.skin[_a] = 0;

	_t.merges++;
	if (_t.tier[_b] > _t.highest) _t.highest = _t.tier[_b];
	_t.dirty = true;
	save_mark_dirty(); // save-on-mutation law
	return _r;
}
