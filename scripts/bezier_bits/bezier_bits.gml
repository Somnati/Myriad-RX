/// @description bezier_bits(x, y, n, col, [tx], [ty], [tic], [amt],
///              [swing], [spd], [lane], [depth], [chime]) - burst n
/// currency bits from (x, y) toward the target (the Myriad DE
/// profit-particle framework: obj_bezier_emit paces the burst,
/// obj_bezier_bit is the mote). tic = the burst style (round 8, the
/// original's two modes): -1 = ALL AT ONCE (dial payouts), 0+ = BACK-
/// TO-BACK one bit per tic frames (taps use 0 - rapid succession).
/// omit the target and bits fly to the room's RESIN counter - the
/// strip counter in the dial hall / refinery, the header corner
/// anywhere else. callers scale n with the event's YIELD (a 1-resin
/// tap = exactly 1 bit); the population cap (~48) gates spawns inside
/// the emitter so payout floods stay cheap.
/// AMOUNT (round 2, his ask): a burst can carry the profit it
/// represents. The profit is already banked the moment it is earned -
/// what the amount does is let the COUNTER hold that much back until
/// the motes actually land, so the number climbs as they arrive
/// instead of jumping ahead of them (Myriad DE's emit_gold). Carrying
/// it rather than paying on arrival matters: the population cap can
/// swallow a spawn, and a mote that never existed must not swallow
/// profit with it.
/// THE CURVE AND THE PACE (2026-09-10, the tile fountain): swing < 0 =
/// Myriad's throw, the control point flung across the room's width
/// (the lazy swoop every payout has always had); swing >= 0 = the
/// control sits on the straight line's midpoint pushed sideways by up
/// to that many px - nearly straight, a hint of curve. spd multiplies
/// the mote's per-step advance (1 = Myriad's). Both default to the
/// original, so every existing caller flies exactly as before.
/// THE LANE (same day): which settings pill dresses these motes -
/// "profit" (the default: dials + the tap), "credit", "unit", "tile".
/// bit_look resolves it to a bit_config row; the emitter stamps the
/// look on every mote it spawns.
/// THE DEPTH (same day): -90 by default, over the room and under the
/// floats, as always. The tile fountain passes the board's depth + 1
/// so its motes leave from UNDER the tiles (his ask: "pop out at a
/// depth behind the tiles so they arent in front").
/// THE CHIME (2026-09-14): a paced burst (tic 0+) with chime on plays
/// DE's per-mote note as each leaves (obj_bezier_emit) - the credit
/// core's collect cascade.
function bezier_bits(_x, _y, _n, _col, _tx = undefined, _ty = undefined,
	_tic = -1, _amt = 0, _swing = -1, _spd = 1, _lane = "profit", _dep = -90, _chime = false) {
	if (!variable_global_exists("bez_n")) g.bez_n = 0;
	if (_n <= 0) return;
	// ⚖️ NEVER MORE MOTES THAN THE MONEY (his law, 2026-09-14: "if i make 1
	// per tap only 1 bit should spawn; 3 per tap i shouldn't see 5"). A
	// burst that carries its amount is clamped to it here, once, for every
	// caller - the tap's crit handful, the gift's fistful, all of them.
	// (a burst carrying nothing - a chest, a ceremony - keeps its count)
	if (_amt >= arb(1) && arb(_n) > _amt) _n = max(1, floor(unarb(_amt)));
	if (_tx == undefined) {
		// (the rm_dials / rm_production strip seats retired round 29
		// with their rooms - every room targets the header corner now)
		_tx = 24; _ty = 12;
	}
	var _e = instance_create_depth(_x, _y, _dep, obj_bezier_emit);
	_e.dep    = _dep;
	_e.count  = _n;
	_e.count_ = _n;
	_e.tic    = 0;
	_e.tic_   = _tic;
	_e.col    = _col;
	_e.tx     = _tx;
	_e.ty     = _ty;
	_e.swing  = _swing;
	_e.spdm   = _spd;
	_e.lane   = _lane;
	_e.chime  = _chime;
	_e.amt    = _amt;                                  // the whole burst
	// one mote's cut, in WHOLE UNITS: a fractional share left the
	// counter's held-back figure fractional mid-flight, and the
	// visualiser drew the fraction as sub-unit squares. The remainder
	// rides the last mote (the emitter hands it over on the final spawn)
	_e.share  = (_amt > 0) ? do_floor(do_scale(_amt, 1 / _n)) : 0;
}
