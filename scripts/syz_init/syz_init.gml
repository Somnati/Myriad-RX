/// @description syz_init([force]) -> g.syz: SYZYGY's state (q315) - the cycles, the flux, the tokens, the clocks, the log
/// A cycle: { per (whole seconds), t (its phase, 0..per), lv, anchor, fired (the flash), k (aligned last fire) }. Two
/// to start, at 6 and 9 - they meet every eighteen seconds, so the first conjunction comes on its own
function syz_init(_force = false) {
	if (!_force && variable_global_exists("syz") && is_struct(g.syz)) return g.syz;
	var _s = {
		flux : 0, life : 0, tokens : 0, harm : 1,   // (harm: the conjunction's multiplier - k aligned pays 1 + (k - 1) x harm)
		cycles : [ { per : 6, t : 0, lv : 1, anchor : false, fired : 0, k : 1 }, { per : 9, t : 0, lv : 1, anchor : false, fired : 0, k : 1 } ],
		cap : SYZ_CYCLES_MAX,
		drift_t : SYZ_DRIFT_EVERY, sync_cd : 0, wobbles : 0, syncs : 0,
		conj : [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],   // (conjunctions by size, 2..9 - the stats)
		grand : 0, best : 0,
		log : [],   // (the last lines: fires and wobbles)
		last : universal_now(), rate : 0, rate_acc : 0, rate_t : 0, next : undefined,
	};
	g.syz = _s;
	return _s;
}
