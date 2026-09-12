/// @description autom_log(txt, col, [section]) - a line in the ledger
/// AUTOMATION SHOWS ITS WORK (his list, 2026-09-12): every landed
/// action writes one line - what, how much, when - to g.autom.ledger,
/// which the overview lists newest first with "Ns ago". Session-only
/// (a ledger is a thing you read now, not a save). The section tallies
/// (spent / count) ride the same call.
/// @param txt      the line
/// @param col      its colour
/// @param [sec]    "dial" / "tile" / "upg" / "reb" - the tally it counts toward
/// @param [spent]  what it spent (an arb or a real), added to the tally
function autom_log(_txt, _col, _sec = "", _spent = 0) {
	autom_init();
	var _a = g.autom;
	if (!variable_struct_exists(_a, "ledger")) { _a.ledger = []; _a.stat = autom_stat_new(); }
	array_insert(_a.ledger, 0, { txt : _txt, col : _col, at : current_time });
	if (array_length(_a.ledger) > 40) array_resize(_a.ledger, 40);
	if (_sec == "") return;
	var _s = _a.stat;
	_s[$ _sec + "_n"] += 1;
	if (is_array(_spent) || (is_real(_spent) && _spent > 0)) {
		var _cur = _s[$ _sec + "_spent"];
		if (is_real(_spent)) _spent = arb(_spent);
		_s[$ _sec + "_spent"] = (_cur >= arb(1)) ? do_add(_cur, _spent) : _spent;
	}
}
