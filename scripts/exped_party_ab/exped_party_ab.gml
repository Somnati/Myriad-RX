/// @description exped_party_ab(trip, [alive_only]) -> the crew's ROAD lanes summed
/// (pace / sure / night / weather / finds / loot / gold): what the
/// abilities of everyone walking do for the trip as a whole (2026-09-17).
/// alive_only (default true) = the ones still up; false = the whole crew
/// (the pay at the door counts everyone who went)
function exped_party_ab(_tr, _alive = true) {
	var _o = { pace : 0, sure : 0, night : 0, weather : 0, finds : 0, loot : 0, gold : 0 };
	for (var _k = 0; _k < array_length(_tr.sids); _k++) {
		if (_alive && _k < array_length(_tr.hp) && _tr.hp[_k] <= 0) continue;
		var _sp = exped_sprite(_tr.sids[_k]);
		if (is_undefined(_sp)) continue;
		var _ab = sprite_ab(_sp);
		_o.pace += _ab.pace; _o.sure += _ab.sure; _o.night += _ab.night; _o.weather += _ab.weather;
		_o.finds += _ab.finds; _o.loot += _ab.loot; _o.gold += _ab.gold;
	}
	return _o;
}
