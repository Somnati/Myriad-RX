/// @description upgrade_holds(id, [ignore_slot]);
/// @param id
/// @param [ignore_slot]
/// Is this upgrade id already sitting in a slot? `ignore_slot` skips
/// one index, which is what lets a roll ask "is this a duplicate of
/// something ELSEWHERE" while it is standing in the slot it is filling.
function upgrade_holds(_id, _ignore = -1) {
	upgrade_init();
	var _n = upgrade_slots();
	for (var _i = 0; _i < _n; _i++) {
		if (_i == _ignore) continue;
		var _s = g.upg.slot[_i];
		if (is_struct(_s) && _s.id == _id) return true;
	}
	return false;
}
