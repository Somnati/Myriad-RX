/// @description tile_rebirth_calc() - what a tile rebirth would pay,
/// derived fresh and never stored. { units, can, have, need, lack_oom }
///
/// ⚖️ EARNED, NOT HELD, and that is the one real difference from the
/// game's rebirth (his spec: "based off its earned currency"). g.tiles
/// .earned is LIFETIME shards the board has produced, so spending them
/// on upgrades costs you nothing here - the two sinks do not fight. A
/// held-pile measure would have made every upgrade purchase a step
/// BACKWARDS toward the reset, which is the sort of tension that reads
/// as a bug rather than as a decision.
///
/// The ladder is the house shape (rebirth_calc's): a gate in orders of
/// magnitude, then one unit per TILE_RB_RATE decades past it. Nothing
/// is stored, so a tuning change is retroactive by construction.
function tile_rebirth_calc() {
	var _out = { units : 0, can : false, have : 0, need : TILE_RB_GATE,
	             lack_oom : TILE_RB_GATE };
	if (!variable_global_exists("tiles")) return _out;
	var _e = g.tiles[$ "earned"] ?? 0;
	if (!(_e >= arb(1))) return _out;

	// the arb's packed integer part IS its decade count - no unarb, so
	// this stays honest at any size
	var _oom = floor(_e);
	_out.have = _oom;
	if (_oom < TILE_RB_GATE) {
		_out.lack_oom = TILE_RB_GATE - _oom;
		return _out;
	}
	// crossing the gate is worth one unit immediately (the house rule),
	// then one per RATE decades beyond it
	_out.units = 1 + floor((_oom - TILE_RB_GATE) / TILE_RB_RATE);
	_out.can = true;
	_out.lack_oom = 0;
	return _out;
}
