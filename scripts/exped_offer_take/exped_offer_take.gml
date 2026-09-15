/// @description exped_offer_take(dest, ri, i, trip id, [quest]) - slot i of the region's offer is this trip's now (it shows as taken until its clock re-deals it)
/// quest = the quest the trip left with: a slot whose clock turned over
/// while the departure page was up holds a DIFFERENT quest now - that
/// one is not marked (the crew left with the one they saw; the board's
/// new offer stays open). Bug hunt 2026-09-15.
function exped_offer_take(_d, _ri, _i, _tid, _q = undefined) {
	var _sl = exped_region_quests(_d, _ri);
	if (_i < 0 || _i >= array_length(_sl)) return;
	if (is_struct(_q) && _sl[_i].q != _q) return;
	_sl[_i].taken = _tid;
	save_mark_dirty();
}
