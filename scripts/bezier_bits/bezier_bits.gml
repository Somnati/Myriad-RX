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
function bezier_bits(_x, _y, _n, _col, _tx = undefined, _ty = undefined,
	_tic = -1) {
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
}
