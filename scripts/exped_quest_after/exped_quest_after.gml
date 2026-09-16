/// @description exped_quest_after(trip) - the moment a quest is done, once: THE TOWN'S GRATITUDE and THE FOLLOW-UP CARD (2026-09-16)
/// Called a step (exped_act_step) and after a fight (exped_tick_one);
/// trip.after_done (saved "qaf") keeps it to once. A quest done FOR a
/// town (defend / well / cellars / shop / rescue / escort / parcel /
/// goat) makes the town grateful for a week (exped_mem_set: a bed on
/// the house, a credit off the shelf); then exped_quest_personal deals
/// the follow-up where one follows.
function exped_quest_after(_tr) {
	var _q = _tr[$ "quest"];
	if (!is_struct(_q) || _q.done < _q.n || (_tr[$ "after_done"] ?? false)) return;
	_tr.after_done = true;
	var _rg = exped_region(_tr), _ri = _tr[$ "rgi"] ?? 0, _kk = region_kinds();
	var _tn = -1;
	switch (_q.kind) { case "defend": case "well": case "cellars": case "shop": case "rescue": case "escort": case "parcel": case "goat": _tn = _q.node; break; }
	if (_tn >= 0 && _tn < array_length(_rg.nodes)) {
		var _kd = _kk[$ _rg.nodes[_tn].kind];
		if (is_struct(_kd) && _kd.civ) {
			exped_mem_set(_tr.dest, _ri, _tn, "grateful", 168);
			array_push(_tr.log, _rg.nodes[_tn].name + " will remember this. " + choose("a bed there is on the house, for a while", "the shop's prices are kinder, for a while", "there will be a bed and a kind word next time", "the elder said so, in front of everyone"));
		}
	}
	var _line = exped_quest_personal(_tr, _q, _rg);
	if (_line != "") array_push(_tr.log, _line);
	save_mark_dirty();
}
