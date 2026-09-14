/// @description settings_action(label, fn, [help], [col]) - a tappable
/// row that just RUNS something (save now, open a room, reset). draws
/// with a chevron at the value column; the whole row is the button.
/// `fn` runs in whatever scope it was declared in (settings_content =
/// syst_settings' scope, so it can reach controller vars).
/// runs in syst_settings' scope.
/// [hold] true = HOLD TO EXECUTE (his ask, 2026-09-14, the resets: "i
///        dont want a player accidently fat fingering it"): the row fills
///        while the pointer is held on it and fires at full - a tap does
///        nothing. syst_settings' Step runs the clock, its Draw the fill
function settings_action(_label, _fn, _help = "", _col = -1, _hold = false) {
	array_push(rows, {
		kind : sett_kind_action, name : _label, val : "",
		col : (_col == -1) ? sett_ink : _col,
		help : _help, ind : 0, inst : noone, data : _fn, hold : _hold,
	});
}
