/// @description bestiary_note(kind, what, [variant], [boss]) - THE BESTIARY'S LEDGER (his ask, 2026-09-16): g.exped.best[kind] = { seen, slain, vars, boss }
/// Credited at a FIGHT'S END (exped_tick_one) - every foe that stood in it
/// is "seen", every one that fell "slain", the variant word kept, a boss
/// counted - and not at the fight's making, because a fight in progress
/// replays its room on load and would be counted twice. Saved as "ex_best"
/// (handle_save); the bestiary page (syst_exped_panel) reads it, and the
/// map's card names only the foes you have met.
function bestiary_note(_kind, _what, _var = "", _boss = false) {
	if (_kind == "") return;
	exped_init();
	var _e = g.exped;
	if (!is_struct(_e[$ "best"])) _e.best = {};
	if (!is_struct(_e.best[$ _kind])) _e.best[$ _kind] = { seen : 0, slain : 0, vars : [], boss : 0 };
	var _b = _e.best[$ _kind];
	if (_what == "seen") _b.seen += 1; else if (_what == "slain") _b.slain += 1;
	if (_var != "" && !array_contains(_b.vars, _var)) array_push(_b.vars, _var);
	if (_boss && _what == "seen") _b.boss += 1;
}
