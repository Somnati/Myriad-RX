/// @description upgrade_dial_hot(i) - may a per-dial profit boost for
/// dial i be offered right now?
/// @param i  the dial's index
///
/// THE TWO HIGHEST DIALS YOU OWN (2026-09-16). The run's money is in the
/// newest dials - by the time dial c opens, a is a rounding error - so a
/// boost offered for a is a dead roll, and one for a dial not yet
/// opened does nothing until it is. The two at the top are the ones
/// carrying the stretch to the next opening, which is what the upgrade
/// layer is for ("that stretch to get to dial C is long").
function upgrade_dial_hot(_i) {
	if (!variable_global_exists("dial")) return false;
	if (_i < 0 || _i >= g.dial_total) return false;
	if (g.dial[_i].level <= 0) return false;
	var _above = 0;
	for (var _k = _i + 1; _k < g.dial_total; _k++)
		if (g.dial[_k].level > 0) _above++;
	return _above < 2;
}
