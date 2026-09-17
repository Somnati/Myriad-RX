/// @description upgrade_burst_start(kind, mult, dur);
/// @param kind  "tap" or "dial" - the lane the burst multiplies
/// @param mult  the multiplier rolled on the offer (x1.58)
/// @param dur   its clock in seconds
/// A burst has just been bought (upgrade_buy's grant path): put it on
/// the running list with a WALL-CLOCK end (universal_now), so it runs
/// through a room change, a save and a menu the same way a wheel or a
/// gift timer does.
///
/// ⚖️ STACKING (his rule, 2026-09-16 - "what if they added together but
/// stayed seperate timers?"): bursts of one kind ADD THEIR BONUS PARTS
/// (x1.6 + x1.4 = x2.0, see upgrade_burst_mult) and each keeps its OWN
/// clock, so the total steps down as each one ends rather than one
/// winner overwriting the rest. Past UPG_BURST_MAX of a kind the new one
/// folds into the one ending soonest - its bonus part joins, the later
/// clock wins - so nothing bought is lost and the header's chip row
/// stays readable.
function upgrade_burst_start(_kind, _mult, _dur) {
	upgrade_init();
	if (!is_array(g.upg[$ "bursts"])) g.upg.bursts = [];
	var _now = universal_now();
	var _bl  = g.upg.bursts;
	// the dead ones go first
	for (var _i = array_length(_bl) - 1; _i >= 0; _i--)
		if (_bl[_i].ends <= _now) array_delete(_bl, _i, 1);

	var _n = 0, _soon = -1;
	for (var _i = 0; _i < array_length(_bl); _i++) {
		if (_bl[_i].kind != _kind) continue;
		_n++;
		if (_soon < 0 || _bl[_i].ends < _bl[_soon].ends) _soon = _i;
	}
	if (_n >= UPG_BURST_MAX && _soon >= 0) {
		var _b = _bl[_soon];
		_b.mult += max(0, _mult - 1);
		_b.ends = max(_b.ends, _now + _dur);
		_b.dur   = _b.ends - _now;   // the chip's bar reads full again
	} else {
		array_push(_bl, { kind : _kind, mult : _mult, ends : _now + _dur, dur : _dur });
	}
	save_mark_dirty();
}
