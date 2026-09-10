/// @description tile_rebirth_calc() - what a tile rebirth would pay,
/// derived fresh and never stored. { flux, can, have, lack_oom }
///
/// ⚖️ IT PAYS A CURRENCY, NOT UNITS (his call, 2026-09-09: "we need it
/// to give us a different currency that directly affects tile output").
/// The first version counted decades past a gate and handed back a
/// small integer, the game rebirth's shape. He wants a pile - something
/// with a number on it that grows with what you earned and that the
/// board's output reads directly. That is FLUX.
///
/// FLUX IS EARNED, DIVIDED. A rebirth pays earned / TILE_FLUX_DIV, so
/// the amount is literally a share of the shards the board produced -
/// 1e7 earned at a divisor of 1e6 is ten flux, 1e10 is ten thousand.
/// It reads as a currency because it IS one: proportional, additive,
/// and a bigger run pays proportionally more rather than one more tick
/// on a ladder.
///
/// ⚖️ EARNED, NOT HELD, still. g.tiles.earned is lifetime shards, so
/// spending shards on upgrades costs nothing toward the reset and the
/// two sinks do not fight. A held measure would make every purchase a
/// step backwards, which reads as a bug rather than a decision.
///
/// Nothing is stored, so a tuning change is retroactive by construction.
function tile_rebirth_calc() {
	var _out = { flux : 0, can : false, have : 0, lack_oom : TILE_RB_GATE };
	if (!variable_global_exists("tiles")) return _out;
	var _e = g.tiles[$ "earned"] ?? 0;
	if (!(_e >= arb(1))) return _out;

	// the arb's packed integer part IS its decade count - no unarb, so
	// the gate test stays honest at any size
	var _oom = floor(_e);
	_out.have = _oom;
	if (_oom < TILE_RB_GATE) {
		_out.lack_oom = TILE_RB_GATE - _oom;
		return _out;
	}

	// earned / DIV, in log space, packed once. Flux is a plain real -
	// earned is bounded by the game's own 1e308 and the divisor pulls
	// it well under that, so it never needs to be an arb.
	var _lg = arb_log10(_e) - log10(TILE_FLUX_DIV);
	_out.flux = floor(power(10, max(0, _lg)));
	_out.can = (_out.flux >= 1);
	_out.lack_oom = 0;
	return _out;
}
