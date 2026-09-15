/// @description exped_recall(trip) - an exploring crew is told to come home
function exped_recall(_tr) {
	if (_tr[$ "recall"] ?? false) return;
	_tr.recall = true;
	array_push(_tr.log, "the recall came through. " + exped_crew_txt(_tr.names) + ((array_length(_tr.names) > 1) ? " turn" : " turns") + " for the landing zone");
	save_mark_dirty();
}
