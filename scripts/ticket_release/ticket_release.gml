/// @description ticket_release() - the tickets owed from the tutorial
/// land on the desk, once the objective chain is complete. Idempotent;
/// objective_tick calls it as the last objective closes.
function ticket_release() {
	ticket_init();
	if (objective_cur() != undefined) return;
	var _o = g.tickets[$ "owed"];
	if (!is_array(_o) || array_length(_o) == 0) return;
	g.tickets.owed = [];
	for (var _i = 0; _i < array_length(_o); _i++)
		ticket_grant(_o[_i], _i > 0, true);   // the first says so, the rest are quiet
}
