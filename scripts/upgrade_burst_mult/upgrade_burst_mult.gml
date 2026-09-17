/// @description upgrade_burst_mult(kind) - what the running bursts of
/// this kind multiply the payout by right now. 1 when none are running.
/// @param kind  "tap" (tap_fire's pay) or "dial" (prod_dials' payout)
///
/// THE ONE READ POINT for bursts, result-side like every other bonus:
/// the caller multiplies the number it just derived, never a stored
/// rate - so a burst cannot compound into a dial's own curve or the
/// cost of levelling it, and its end needs no resync anywhere.
///
/// ADDITIVE PARTS (his rule): 1 + the sum of every running burst's
/// (mult - 1), so x1.6 and x1.4 together are x2.0, and when the first
/// clock runs out the total steps to x1.4 on its own.
///
/// ⚖️ ONE DURING THE OFFLINE REPLAY. The replay bulk-pays whole stretches
/// of absence; a two-minute burst applied to a coarse eight-hour step
/// would pay it for eight hours. A burst is a thing you are here for.
///
/// Prunes what has run out as it reads, so nothing else needs a tick.
function upgrade_burst_mult(_kind) {
	if (!variable_global_exists("upg")) return 1;
	if (variable_global_exists("offline_replaying") && g.offline_replaying) return 1;
	var _bl = g.upg[$ "bursts"];
	if (!is_array(_bl)) return 1;
	var _now = universal_now();
	var _m = 1;
	for (var _i = array_length(_bl) - 1; _i >= 0; _i--) {
		var _b = _bl[_i];
		if (_b.ends <= _now) { array_delete(_bl, _i, 1); continue; }
		if (_b.kind == _kind) _m += max(0, _b.mult - 1);
	}
	return _m;
}
