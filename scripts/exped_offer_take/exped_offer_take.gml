/// @description exped_offer_take(dest, ri, i, trip id) - slot i of the region's offer is this trip's now (it shows as taken until its clock re-deals it)
function exped_offer_take(_d, _ri, _i, _tid) {
	var _sl = exped_region_quests(_d, _ri);
	if (_i < 0 || _i >= array_length(_sl)) return;
	_sl[_i].taken = _tid;
	save_mark_dirty();
}
