/// @description exped_party_luck(trip) -> the luck of the crew that is up, summed (the loot ladder leans on it: x 12 rate points a point)
function exped_party_luck(_tr) {
	var _l = 0;
	for (var _k = 0; _k < array_length(_tr.sids); _k++) {
		if (_tr.hp[_k] <= 0) continue;
		var _sp = exped_sprite(_tr.sids[_k]);
		if (!is_undefined(_sp)) _l += sprite_luck(_sp);
	}
	return _l;
}
