/// @description bezier_bits(x, y, n, col, [tx], [ty], [tic]) - burst n
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
function bezier_bits(_x, _y, _n, _col, _tx = undefined, _ty = undefined,
	_tic = -1, _amt = 0) {
	if (!variable_global_exists("bez_n")) g.bez_n = 0;
	if (_n <= 0) return;
	if (_tx == undefined) {
		// (the rm_dials / rm_production strip seats retired round 29
		// with their rooms - every room targets the header corner now)
		_tx = 24; _ty = 12;
	}
	var _e = instance_create_depth(_x, _y, -90, obj_bezier_emit);
	_e.count  = _n;
	_e.count_ = _n;
	_e.tic    = 0;
	_e.tic_   = _tic;
	_e.col    = _col;
	_e.tx     = _tx;
	_e.ty     = _ty;
	_e.amt    = _amt;                                  // the whole burst
	// one mote's cut, in WHOLE UNITS: a fractional share left the
	// counter's held-back figure fractional mid-flight, and the
	// visualiser drew the fraction as sub-unit squares. The remainder
	// rides the last mote (the emitter hands it over on the final spawn)
	_e.share  = (_amt > 0) ? do_floor(do_scale(_amt, 1 / _n)) : 0;
}
