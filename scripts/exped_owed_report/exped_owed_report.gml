/// @description exped_owed_report() - THE ABSENCE'S EXPEDITION SECTION, WRITTEN LATE (q230): the hours the boot's replay owed (the chart was not there) have now been walked - the log's entry for that absence (offline_replay left it in g.exped_owed_rep, by reference) gets its expedition section again, true this time: where every crew got to, what the diaries added, who came home
function exped_owed_report() {
	var _rep = g[$ "exped_owed_rep"];
	if (!is_struct(_rep)) return;
	g.exped_owed_rep = undefined;
	if (!is_struct(_rep[$ "L"]) || !is_struct(_rep.L[$ "exped"])) return;
	_rep.L.exped.after = exped_away_after(_rep.logn);
}
