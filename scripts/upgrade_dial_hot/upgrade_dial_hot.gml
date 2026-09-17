/// @description upgrade_dial_hot(i) - may a per-dial profit boost for
/// dial i be offered right now?
/// @param i  the dial's index
///
/// MYRIAD DE'S RULE (fetch_new_upgrade + unlock_upgrade_auto, his call
/// 2026-09-17: "do the dial offer average thing... it helps with game
/// balance"): a dial is offered a boost while its own boost is AT OR
/// UNDER THE AVERAGE + 10 across every dial you own - so the offers
/// keep pulling the dials level and no one dial runs away with the
/// table. Every owned dial qualifies while less than 10 points have
/// been bought in all, or while only one dial is owned; and ONE ROLL IN
/// FIVE IGNORES THE AVERAGE (DE's `if roll_perc(20) avg_boost =
/// total_boost`, "there should also be a chance it ignores it") -
/// rolled once per offer in upgrade_roll, so all thirteen closures see
/// the same answer. DE's u_profit[s] is the per-dial lane here
/// (upgrade_bonus().dial_one, the completed ledger included).
function upgrade_dial_hot(_i) {
	if (!variable_global_exists("dial")) return false;
	if (_i < 0 || _i >= g.dial_total) return false;
	if (g.dial[_i].level <= 0) return false;
	var _b = upgrade_bonus().dial_one;
	var _tot = 0, _n = 0;
	for (var _k = 0; _k < g.dial_total; _k++) {
		if (g.dial[_k].level <= 0) continue;
		_tot += _b[_k];
		_n++;
	}
	if (_n <= 1) return true;      // one dial: it is the one
	if (_tot < 10) return true;    // nothing bought yet: anyone
	// the one-in-five that ignores the average (rolled per offer)
	if (variable_global_exists("upg_dial_ignore") && g.upg_dial_ignore) return true;
	return _b[_i] <= _tot / _n + 10;
}
