/// @description objective_step_done(objective, i) -> is step i of this
/// objective ticked RIGHT NOW? LIVE, never sticky (his call, 2026-09-13:
/// steps decomplete when their state stops holding, so a player who
/// closed the drawer is asked to open it again). The rule: a step is
/// ticked while its own done() holds OR any LATER step's does - progress
/// implies what came before it ("roll an upgrade" keeps "open the menu"
/// ticked after the menu has folded). An objective already done as a
/// whole is all ticks. The runner and both views read this and nothing
/// else, so they can never disagree.
function objective_step_done(_o, _i) {
	objective_init();
	if (g.obj.done[$ _o.key] ?? false) return true;
	var _n = array_length(_o.steps);
	for (var _j = _i; _j < _n; _j++) if (_o.steps[_j].done()) return true;
	return false;
}
